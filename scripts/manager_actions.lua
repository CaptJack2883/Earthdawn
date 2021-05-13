-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--  ACTION FLOW
--
--	1. INITIATE ACTION (DRAG OR DOUBLE-CLICK)
--	2. DETERMINE TARGETS (DROP OR TARGETING SUBSYSTEM)
--	3. APPLY MODIFIERS
--	4. PERFORM ROLLS (IF ANY)
--	5. RESOLVE ACTION

-- NOTE: Rolls with sTargeting = "all" which use effect modifiers need to 
-- 		handle effect application on resolution by checking target order field;
--		since there will be no target specified in mod handler, 
--		but will be specified in the result handler.
--		i.e. "if rSource and rTarget and rTarget.nOrder then"

-- ROLL
--		.sType
--		.sDesc
--		.aDice
--		.nMod
--		(Any other fields added as string -> string map, if possible)

function onInit()
	Interface.onHotkeyActivated = actionHotkey;
end

local bUseFGUDiceValues = false;
function useFGUDiceValues(bState)
	bUseFGUDiceValues = bState;
end

--
-- HANDLERS
--

function initAction(sActionType)
	if not GameSystem.actions[sActionType] then
		GameSystem.actions[sActionType] = { bUseModStack = "true" };
	end
end

local aTargetingHandlers = {};
function registerTargetingHandler(sActionType, callback)
	ActionsManager.initAction(sActionType);
	aTargetingHandlers[sActionType] = callback;
end
function unregisterTargetingHandler(sActionType)
	if aTargetingHandlers then
		aTargetingHandlers[sActionType] = nil;
	end
end

local aModHandlers = {};
function registerModHandler(sActionType, callback)
	ActionsManager.initAction(sActionType);
	aModHandlers[sActionType] = callback;
end
function unregisterModHandler(sActionType)
	if aModHandlers then
		aModHandlers[sActionType] = nil;
	end
end

local aPostRollHandlers = {};
function registerPostRollHandler(sActionType, callback)
	ActionsManager.initAction(sActionType);
	aPostRollHandlers[sActionType] = callback;
end
function unregisterPostRollHandler(sActionType)
	if aPostRollHandlers then
		aPostRollHandlers[sActionType] = nil;
	end
end

local aResultHandlers = {};
function registerResultHandler(sActionType, callback)
	ActionsManager.initAction(sActionType);
	aResultHandlers[sActionType] = callback;
end
function unregisterResultHandler(sActionType)
	if aResultHandlers then
		aResultHandlers[sActionType] = nil;
	end
end

--
-- HELPER FUNCTIONS
--


function doesRollHaveDice(rRoll)
	if rRoll and rRoll.aDice then
		if #(rRoll.aDice) > 0 then
			return true;
		end
		if (rRoll.aDice.expr or "") ~= "" then
			return true;
		end
	end
	return false;
end


function processPercentiles(draginfo)
	local aDragDieList = draginfo.getDieList();
	if not aDragDieList then
		return nil;
	end

	local aD100Indexes = {};
	local aD10Indexes = {};
	for k, v in pairs(aDragDieList) do
		if v["type"] == "d100" then
			table.insert(aD100Indexes, k);
		elseif v["type"] == "d10" then
			table.insert(aD10Indexes, k);
		end
	end

	local nMaxMatch = #aD100Indexes;
	if #aD10Indexes < nMaxMatch then
		nMaxMatch = #aD10Indexes;
	end
	if nMaxMatch <= 0 then
		return aDragDieList;
	end
	
	local nMatch = 1;
	local aNewDieList = {};
	for k, v in pairs(aDragDieList) do
		if v["type"] == "d100" then
			if nMatch > nMaxMatch then
				table.insert(aNewDieList, v);
			else
				v["result"] = aDragDieList[aD100Indexes[nMatch]]["result"] + aDragDieList[aD10Indexes[nMatch]]["result"];
				table.insert(aNewDieList, v);
				nMatch = nMatch + 1;
			end
		elseif v["type"] == "d10" then
			local bInsert = true;
			for i = 1, nMaxMatch do
				if aD10Indexes[i] == k then
					bInsert = false;
				end
			end
			if bInsert then
				table.insert(aNewDieList, v);
			end
		else
			table.insert(aNewDieList, v);
		end
	end

	return aNewDieList;
end

--
--  ACTIONS
--

function performAction(draginfo, rActor, rRoll)
	if not rRoll then
		return;
	end
	
	ActionsManager.performMultiAction(draginfo, rActor, rRoll.sType, { rRoll });
end

function performMultiAction(draginfo, rActor, sType, rRolls)
	if not rRolls or #rRolls < 1 then
		return false;
	end
	
	if draginfo then
		ActionsManager.encodeActionForDrag(draginfo, rActor, sType, rRolls);
	else
		ActionsManager.actionDirect(rActor, sType, rRolls);
	end
	return true;
end

function actionHotkey(draginfo)
	local sDragType = draginfo.getType();
	if not GameSystem.actions[sDragType] then
		return;
	end
	
	local rSource, rRolls = ActionsManager.decodeActionFromDrag(draginfo, false);
	ActionsManager.actionDirect(rSource, sDragType, rRolls);
	return true;
end

function actionDrop(draginfo, rTarget)
	local sDragType = draginfo.getType();
	if not GameSystem.actions[sDragType] then
		return false;
	end
	
	local rSource, rRolls = ActionsManager.decodeActionFromDrag(draginfo, false);
	local aTargeting = {};
	if rTarget or ModifierStack.getTargeting() then
		aTargeting = ActionsManager.getTargeting(rSource, rTarget, sDragType, rRolls);
	else
		aTargeting = { { } };
	end

	ActionsManager.actionRoll(rSource, aTargeting, rRolls);
		
	return true;
end

function actionDropHelper(draginfo, bResolveIfNoDice)
	local rSource, aTargets = ActionsManager.decodeActors(draginfo);
	
	local bModStackUsed = false;
	ActionsManager.lockModifiers();
	
	draginfo.setSlot(1);
	for i = 1, draginfo.getSlotCount() do
		if ActionsManager.applyModifiersToDragSlot(draginfo, i, rSource, bResolveIfNoDice) then
			bModStackUsed = true;
		end
	end
	
	ActionsManager.unlockModifiers(bModStackUsed);
	
	return rSource, aTargets;
end

function actionDirect(rActor, sDragType, rRolls, aTargeting)
	if not aTargeting then
		if ModifierStack.getTargeting() then
			aTargeting = ActionsManager.getTargeting(rActor, nil, sDragType, rRolls);
		else
			aTargeting = { { } };
		end
	end
	
	ActionsManager.actionRoll(rActor, aTargeting, rRolls);
end

function getTargeting(rSource, rTarget, sDragType, rRolls)
	local aTargeting = {};
	
	if rTarget then
		table.insert(aTargeting, { rTarget });
	elseif GameSystem.actions[sDragType] and GameSystem.actions[sDragType].sTargeting then
		if (#rRolls == 1) and rRolls[1].bSelfTarget then
			aTargeting = { { rSource } };
		elseif GameSystem.actions[sDragType].sTargeting == "all" then
			aTargeting = { TargetingManager.getFullTargets(rSource) };
		elseif GameSystem.actions[sDragType].sTargeting == "each" then
			local aTempTargets = TargetingManager.getFullTargets(rSource);
			if #aTempTargets <= 1 then
				aTargeting = { aTempTargets };
			else
				aTargeting = {};
				for _,vTarget in ipairs(aTempTargets) do
					table.insert(aTargeting, { vTarget });
				end
			end
		end
	end
	
	local fTarget = aTargetingHandlers[sDragType];
	if fTarget then
		aTargeting = fTarget(rSource, aTargeting, rRolls);
	end
	if not aTargeting then
		aTargeting = {};
	end
	if #aTargeting == 0 then
		table.insert(aTargeting, {});
	end
	
	return aTargeting;
end

function encodeActors(draginfo, rSource, aTargets)
	local sSourceNode = nil;
	if rSource then
		sSourceNode = ActorManager.getCreatureNodeName(rSource);
	end
	if sSourceNode then
		draginfo.addShortcut(ActorManager.getRecordType(rSource), sSourceNode);
	else
		draginfo.addShortcut();
	end
	
	if aTargets then
		for _,v in ipairs(aTargets) do
			local sTargetNode = ActorManager.getCreatureNodeName(v);
			if sTargetNode then
				draginfo.addShortcut(ActorManager.getRecordType(v), sTargetNode);
			end
		end
	end
end

function decodeActors(draginfo)
	local rSource = nil;
	local aTargets = {};
  
	print("Testing decodeActors(draginfo) from ActionsManager");
	for k,v in ipairs(draginfo.getShortcutList()) do
		if k == 1 then
			rSource = ActorManager.resolveActor(v.recordname);
      if rSource then
        print("Printing rSource.sName");
        print(rSource.sName);
      end
		else
			local rTarget = ActorManager.resolveActor(v.recordname);
			if rTarget then
        print("Printing rTarget.sName");
        print(rTarget.sName);
				table.insert(aTargets, rTarget);
			end
		end	
	print("End of Testing decodeActors(draginfo) from ActionsManager");
  end
	
	return rSource, aTargets;
end

function encodeRollForDrag(draginfo, i, vRoll)
	draginfo.setSlot(i);

	for k,v in pairs(vRoll) do
		if k == "sType" then
			draginfo.setSlotType(v);
		elseif k == "sDesc" then
			draginfo.setStringData(v);
		elseif k == "aDice" then
			draginfo.setDieList(v);
		elseif k == "nMod" then
			draginfo.setNumberData(v);
		elseif type(k) ~= "table" then
			local sk = tostring(k) or "";
			if sk ~= "" then
				draginfo.setMetaData(sk, tostring(v) or "");
			end
		end
	end
end

function encodeActionForDrag(draginfo, rSource, sType, rRolls)
	ActionsManager.encodeActors(draginfo, rSource);
	
	draginfo.setType(sType);
	
	if GameSystem.actions[sType] and GameSystem.actions[sType].sIcon then
		draginfo.setIcon(GameSystem.actions[sType].sIcon);
	elseif sType ~= "dice" then
		draginfo.setIcon("action_roll");
	end
	if #rRolls == 1 then
		draginfo.setDescription(rRolls[1].sDesc);
	end
	
	for kRoll, vRoll in ipairs(rRolls) do
		ActionsManager.encodeRollForDrag(draginfo, kRoll, vRoll);
	end
	
	if #rRolls > 0 then
		draginfo.setSecret(rRolls[1].bSecret or false);
	end
end

function decodeRollFromDrag(draginfo, i, bFinal)
	draginfo.setSlot(i);
	
	local vRoll = draginfo.getMetaDataList();
	
	vRoll.sType = draginfo.getSlotType();
	if vRoll.sType == "" then
		vRoll.sType = draginfo.getType();
	end
	
	vRoll.sDesc = draginfo.getStringData();
	if bFinal and vRoll.sDesc == "" then
		vRoll.sDesc = draginfo.getDescription();
	end
	vRoll.nMod = draginfo.getNumberData();
	
	vRoll.aDice = {};
	if UtilityManager.isClientFGU() then
		vRoll.aDice = draginfo.getDieList() or {};
	else
		if bFinal then
			vRoll.aDice = ActionsManager.processPercentiles(draginfo) or {};
		else
			local aDragDice = draginfo.getDieList();
			if aDragDice then
				for k, v in ipairs(aDragDice) do
					if type(v) == "string" then
						table.insert(vRoll.aDice, v);
					elseif type(v) == "table" then
						table.insert(vRoll.aDice, v["type"]);
					end
				end
			end
		end
	end
	
	vRoll.bSecret = draginfo.getSecret();
	return vRoll;
end

function decodeActionFromDrag(draginfo, bFinal)
	local rSource, aTargets = ActionsManager.decodeActors(draginfo);

	local rRolls = {};
	for i = 1, draginfo.getSlotCount() do
		table.insert(rRolls, ActionsManager.decodeRollFromDrag(draginfo, i, bFinal));
	end
	
	return rSource, rRolls, aTargets;
end

--
--  APPLY MODIFIERS
--

function actionRoll(rSource, vTarget, rRolls)
	local bModStackUsed = false;
	ActionsManager.lockModifiers();
	
	for _,vTargetGroup in ipairs(vTarget) do
		for _,vRoll in ipairs(rRolls) do
			if ActionsManager.applyModifiersAndRoll(rSource, vTargetGroup, true, vRoll) then
				bModStackUsed = true;
			end
		end
	end
	
	ActionsManager.unlockModifiers(bModStackUsed);
end

function applyModifiersAndRoll(rSource, vTarget, bMultiTarget, rRoll)
	local rNewRoll = UtilityManager.copyDeep(rRoll);

	local bModStackUsed = false;
	if bMultiTarget then
		if vTarget and #vTarget == 1 then
			bModStackUsed = ActionsManager.applyModifiers(rSource, vTarget[1], rNewRoll);
		else
			-- Only apply non-target specific modifiers before roll
			bModStackUsed = ActionsManager.applyModifiers(rSource, nil, rNewRoll);
		end
	else
		bModStackUsed = ActionsManager.applyModifiers(rSource, vTarget, rNewRoll);
	end
	
	ActionsManager.roll(rSource, vTarget, rNewRoll, bMultiTarget);
	
	return bModStackUsed;
end

function applyModifiersToDragSlot(draginfo, i, rSource, bResolveIfNoDice)
	local rRoll = ActionsManager.decodeRollFromDrag(draginfo, i);

	local bHasDice = ActionsManager.doesRollHaveDice(rRoll);
	local nDice = #(rRoll.aDice);
	local bModStackUsed = ActionsManager.applyModifiers(rSource, nil, rRoll);
	
	if bResolveIfNoDice and not bHasDice then
		ActionsManager.resolveAction(rSource, nil, rRoll);
	else
		for k,v in pairs(rRoll) do
			if k == "sType" then
				draginfo.setSlotType(v);
			elseif k == "sDesc" then
				draginfo.setStringData(v);
			elseif k == "aDice" then
				local nNewDice = #(rRoll.aDice);
				for i = nDice + 1, nNewDice do
					draginfo.addDie(rRoll.aDice[i]);
				end
			elseif k == "nMod" then
				draginfo.setNumberData(v);
			else
				local sk = tostring(k) or "";
				if sk ~= "" then
					draginfo.setMetaData(sk, tostring(v) or "");
				end
			end
		end
	end
	
	return bModStackUsed;
end

function lockModifiers()
	ModifierStack.lock();
	EffectManager.lock();
end

function unlockModifiers(bReset)
	ModifierStack.unlock(bReset);
	EffectManager.unlock();
end

function applyModifiers(rSource, rTarget, rRoll, bSkipModStack)	
	local bAddModStack = ActionsManager.doesRollHaveDice(rRoll);
	if bSkipModStack then
		bAddModStack = false;
	elseif GameSystem.actions[rRoll.sType] then
		bAddModStack = GameSystem.actions[rRoll.sType].bUseModStack;
	end

	local fMod = aModHandlers[rRoll.sType];
	if fMod then
		local bReturn = fMod(rSource, rTarget, rRoll);
		if bReturn ~= true then
			rRoll.aDice.expr = nil;
		end
	end

	if bAddModStack then
		local bDescNotEmpty = (rRoll.sDesc ~= "");
		local sStackDesc, nStackMod = ModifierStack.getStack(bDescNotEmpty);
		
		if sStackDesc ~= "" then
			if bDescNotEmpty then
				rRoll.sDesc = rRoll.sDesc .. " [" .. sStackDesc .. "]";
			else
				rRoll.sDesc = sStackDesc;
			end
		end
    -- This is for adding a numerical bonus to the roll. 
    -- Earthdawn Rules do not use a static modifier, instead the step number is modified before calculating the roll in StepLookup.getStepDice(stepNum)
		--rRoll.nMod = rRoll.nMod + nStackMod;
	end
	
	return bAddModStack;
end

--
--	RESOLVE DICE
--

function buildThrow(rSource, vTargets, rRoll, bMultiTarget)
	local rThrow = {};
	
	rThrow.type = rRoll.sType;
	rThrow.description = rRoll.sDesc;
	rThrow.secret = rRoll.bSecret;
	
	rThrow.shortcuts = {};
	if rSource then
		local sSourceActorPath = ActorManager.getCreatureNodeName(rSource);
		table.insert(rThrow.shortcuts, { recordname = sSourceActorPath });
	else
		table.insert(rThrow.shortcuts, {});
	end
	if vTargets then
		if bMultiTarget then
			for _,v in ipairs(vTargets) do
				local sTargetActorPath = ActorManager.getCreatureNodeName(v);
				table.insert(rThrow.shortcuts, { recordname = sTargetActorPath });
			end
		else
			local sTargetActorPath = ActorManager.getCreatureNodeName(vTargets);
			table.insert(rThrow.shortcuts, { recordname = sTargetActorPath });
		end
	end
	
	local rSlot = {};
	rSlot.number = rRoll.nMod;
	rSlot.dice = rRoll.aDice;
	rSlot.metadata = rRoll;
	rThrow.slots = { rSlot };
	
	return rThrow;
end

function roll(rSource, vTargets, rRoll, bMultiTarget)
	if ActionsManager.doesRollHaveDice(rRoll) then
		if not rRoll.bTower and OptionsManager.isOption("MANUALROLL", "on") then
			local wManualRoll = Interface.openWindow("manualrolls", "");
			wManualRoll.addRoll(rRoll, rSource, vTargets);
		else
			local rThrow = ActionsManager.buildThrow(rSource, vTargets, rRoll, bMultiTarget);
			Comm.throwDice(rThrow);
		end
	else
		if bMultiTarget then
			ActionsManager.handleResolution(rRoll, rSource, vTargets);
		else
			ActionsManager.handleResolution(rRoll, rSource, { vTargets });
		end
	end
end 

function onDiceLanded(draginfo)
	local sDragType = draginfo.getType();
	if GameSystem.actions[sDragType] then
		local rSource, rRolls, aTargets = ActionsManager.decodeActionFromDrag(draginfo, true);
		
		for _,vRoll in ipairs(rRolls) do
			if ActionsManager.doesRollHaveDice(vRoll) then
				ActionsManager.handleResolution(vRoll, rSource, aTargets);
			end
		end
		
		return true;
	end
end

function handleResolution(vRoll, rSource, aTargets)
	if vRoll.sReplaceDieResult then
		local aReplaceDieResult = StringManager.split(vRoll.sReplaceDieResult, "|");
		for kDie,vDie in ipairs(vRoll.aDice) do
			if aReplaceDieResult[kDie] then
				vDie.result = tonumber(aReplaceDieResult[kDie]) or 0;
				vDie.value = nil;
			end
		end
	end

	local fPostRoll = aPostRollHandlers[vRoll.sType];
	if fPostRoll then
		fPostRoll(rSource, vRoll);
	end
	
	if not aTargets or (#aTargets == 0) then
		ActionsManager.resolveAction(rSource, nil, vRoll);
	elseif #aTargets == 1 then
		ActionsManager.resolveAction(rSource, aTargets[1], vRoll);
	else
		for kTarget,rTarget in ipairs(aTargets) do
			rTarget.nOrder = kTarget;
			ActionsManager.resolveAction(rSource, rTarget, vRoll);
		end
	end
end

function onChatDragStart(draginfo)
	local sDragType = draginfo.getType();
	if GameSystem.actions[sDragType] and GameSystem.actions[sDragType].sIcon then
		draginfo.setIcon(GameSystem.actions[sDragType].sIcon);
	end
end

-- 
--  RESOLVE ACTION
--  (I.E. DISPLAY CHAT MESSAGE, COMPARISONS, ETC.)
--

function resolveAction(rSource, rTarget, rRoll)
	local fResult = aResultHandlers[rRoll.sType];
	if fResult then
		fResult(rSource, rTarget, rRoll);
	else
		local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
		Comm.deliverChatMessage(rMessage);
	end
end

function createActionMessage(rSource, rRoll)
	local sDesc = rRoll.sDesc;
	
	-- Build the basic message to deliver
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
	rMessage.type = rRoll.sType;
	rMessage.text = rMessage.text .. sDesc;
	rMessage.dice = rRoll.aDice;
	rMessage.diemodifier = rRoll.nMod;
	
	-- Check to see if this roll should be secret (GM or dice tower tag)
	if rRoll.bSecret then
		rMessage.secret = true;
		if rRoll.bTower then
			rMessage.icon = "dicetower_icon";
		end
	elseif Session.IsHost and OptionsManager.isOption("REVL", "off") then
		rMessage.secret = true;
	end
	
	-- Show total if option enabled
	if not UtilityManager.isClientFGU() then
		if OptionsManager.isOption("TOTL", "on") and ActionsManager.doesRollHaveDice(rRoll) then
			rMessage.dicedisplay = 1;
		end
	end
	
	return rMessage;
end

function total(rRoll)
	local nTotal = 0;

	for _,v in ipairs(rRoll.aDice) do
		if bUseFGUDiceValues and v.value then
			nTotal = nTotal + v.value;
		else
			nTotal = nTotal + v.result;
		end
	end
	nTotal = nTotal + rRoll.nMod;
	
	return nTotal;
end

function outputResult(bTower, rSource, rTarget, rMessageGM, rMessagePlayer)
	if bTower then
		rMessageGM.secret = true;
		Comm.deliverChatMessage(rMessageGM, "");
	else
		ActionsManager.messageResult(false, rSource, rTarget, rMessageGM, rMessagePlayer);
	end
end

function messageResult(bSecret, rSource, rTarget, rMessageGM, rMessagePlayer)
	local bShowResultsToPlayer;
	local sOptSHRR = OptionsManager.getOption("SHRR");
	if sOptSHRR == "off" then
		bShowResultsToPlayer = false;
	elseif sOptSHRR == "pc" then
		if (not rSource or ActorManager.getFaction(rSource) == "friend") and (not rTarget or ActorManager.getFaction(rTarget) == "friend") then
			bShowResultsToPlayer = true;
		else
			bShowResultsToPlayer = false;
		end
	else
		bShowResultsToPlayer = true;
	end
	
	if bShowResultsToPlayer then
		local nodeCT = ActorManager.getCTNode(rTarget);
		if nodeCT and CombatManager.isCTHidden(nodeCT) then
			rMessageGM.secret = true;
			Comm.deliverChatMessage(rMessageGM, "");
		else
			rMessageGM.secret = false;
			Comm.deliverChatMessage(rMessageGM);
		end
	else
		rMessageGM.secret = true;
		Comm.deliverChatMessage(rMessageGM, "");

		if Session.IsHost then
			local aUsers = User.getActiveUsers();
			if #aUsers > 0 then
				Comm.deliverChatMessage(rMessagePlayer, aUsers);
			end
		else
			Comm.addChatMessage(rMessagePlayer);
		end
	end
end
