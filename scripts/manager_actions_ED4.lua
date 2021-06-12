-- Action Manager for Earthdawn 4th Edition. 
--  rSource, rRolls, aTargets = decodeActionFromDrag(draginfo, false);

-- This fixes table index being nil.
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	-- Register the new action we're creating.  We'll allow use of the modifier stack for this action type.
	--GameSystem.actions["mytestaction"] = { bUseModStack = true };
	--GameSystem.actions["InitRoll"] = { bUseModStack = true };
	GameSystem.actions["Explode"] = { bUseModStack = false };
  
	GameSystem.actions["InitRoll"] = { bUseModStack = true };
	GameSystem.actions["Recovery"] = { bUseModStack = true };
	GameSystem.actions["Recovery"].sIcon = "iconHeal";
	GameSystem.actions["Heal"] = { bUseModStack = true };
	GameSystem.actions["Heal"].sIcon = "iconHeal";
	GameSystem.actions["Damage"] = { bUseModStack = true };
	GameSystem.actions["Damage"].sIcon = "iconDamage";
	GameSystem.actions["Attack"] = { bUseModStack = true };
	GameSystem.actions["Attack"].sIcon = "iconAttack";
  
  --Register OOB Message Handlers
  
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);
	
	-- Register the result handlers - called after the dice have stopped rolling
  -- We need to use the onResult from ActionStep (onExplode) to use the new explosions, I think.
  --  ActionStep.onResult(rSource, rTarget, rRoll); (from combo)
  -- ActionManagerED4.onExplode(rSource, rTarget, rRoll);
	--ActionsManager.registerResultHandler("mytestaction", onRoll);
	ActionsManager.registerResultHandler("Explode", checkExplode);
	ActionsManager.registerResultHandler("InitRoll", checkExplode);
	ActionsManager.registerResultHandler("Strength", checkExplode);
	ActionsManager.registerResultHandler("Dexterity", checkExplode);
	ActionsManager.registerResultHandler("Toughness", checkExplode);
	ActionsManager.registerResultHandler("Perception", checkExplode);
	ActionsManager.registerResultHandler("Willpower", checkExplode);
	ActionsManager.registerResultHandler("Charisma", checkExplode);
	ActionsManager.registerResultHandler("Recovery", checkExplode);
	ActionsManager.registerResultHandler("Heal", checkExplode);
	ActionsManager.registerResultHandler("Damage", checkExplode);
	ActionsManager.registerResultHandler("Attack", checkExplode);
	ActionsManager.registerResultHandler("Knockdown", checkExplode);
	ActionsManager.registerResultHandler("Karma", checkExplode);
	ActionsManager.registerResultHandler("Talent", checkExplode);
	ActionsManager.registerResultHandler("Skill", checkExplode);
	ActionsManager.registerResultHandler("dice", checkExplode);
	ActionsManager.registerTargetingHandler("Attack", onTargeting);
end

function getRoll(sType, rStep, rActor, bSecretRoll)
	-- Initialise a blank rRoll record
	local rRoll = {};
  rRoll.sDesc = "";
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
  if sType then
    rRoll.sType = sType;
  end
  
	-- A modifier to apply to the roll. This is not used here, StepLookup returns the dice and modifier.
  --[[ if rStep == 1 then 
    rRoll.nMod = -2;
  elseif rStep == 2 then
    rRoll.nMod = -1;
  else
    rRoll.nMod = 0;
  end --]]  
  
	-- The description to show in the chat window
  if rRoll.sType == "InitRoll" then
    rRoll.sDesc = rRoll.sDesc .. "Initiative: ";
  elseif rRoll.sType == "Explode" then
    rRoll.sDesc = rRoll.sDesc .. "Explode: ";
  elseif rRoll.sType == "Strength" then
    rRoll.sDesc = rRoll.sDesc .. "Strength Check: ";
  elseif rRoll.sType == "Dexterity" then
    rRoll.sDesc = rRoll.sDesc .. "Dexterity Check: ";
  elseif rRoll.sType == "Toughness" then
    rRoll.sDesc = rRoll.sDesc .. "Toughness Check: ";
  elseif rRoll.sType == "Perception" then
    rRoll.sDesc = rRoll.sDesc .. "Perception Check: ";
  elseif rRoll.sType == "Willpower" then
    rRoll.sDesc = rRoll.sDesc .. "Willpower Check: ";
  elseif rRoll.sType == "Charisma" then
    rRoll.sDesc = rRoll.sDesc .. "Charisma Check: ";
  elseif rRoll.sType == "Recovery" then
    rRoll.sDesc = rRoll.sDesc .. "Recovery Check: ";
  elseif rRoll.sType == "Knockdown" then
    rRoll.sDesc = rRoll.sDesc .. "Knockdown Check: ";
  elseif rRoll.sType == "Karma" then
    rRoll.sDesc = rRoll.sDesc .. "Karma Die: ";
  elseif rRoll.sType == "Heal" then
    rRoll.sDesc = rRoll.sDesc .. "Heal: ";
  elseif rRoll.sType == "Damage" then
    rRoll.sDesc = rRoll.sDesc .. "Damage: ";
  elseif rRoll.sType == "Attack" then
    rRoll.sDesc = rRoll.sDesc .. "Attack: ";
  elseif rRoll.sType == "Talent" then
    rRoll.sDesc = rRoll.sDesc .. "Talent: ";
  elseif rRoll.sType == "Skill" then
    rRoll.sDesc = rRoll.sDesc .. "Skill: ";
  else
    rRoll.sDesc = rRoll.sDesc .. "Default Roll Description";
  end
  
	-- the dice to roll. Set correct step dice based on rStep
  if rStep then
    rRoll.aDice, rRoll.nMod, rStep = StepLookup.getStepDice(rStep);
    rRoll.sDesc = rRoll.sDesc .. "(Step " .. rStep .. ") ";
  end
  
	-- For GM secret rolls.
	rRoll.bSecret = bSecretRoll;
	
	return rRoll;
end

function dragRoll(draginfo, sType, rStep, rActor, bSecretRoll, rRoll)
  rSource, _, vTargets = ActionsManager.decodeActionFromDrag(draginfo, false);
  if not rRoll then
    rRoll = getRoll(sType, rStep, rActor, bSecretRoll);
  end
  ActionsManager.performAction(draginfo, rActor, rRoll);
end

function pushRoll(sType, rStep, rActor, bSecretRoll, rRoll)
  if not rRoll then
    rRoll = ActionManagerED4.getRoll(sType, rStep, rActor, bSecretRoll)
  end
  if not rRoll.bSecretRoll and OptionsManager.isOption("MANUALROLL", "on") then
    local wManualRoll = Interface.openWindow("manualrolls", "");
    wManualRoll.addRoll(rRoll, rActor, vTargets);
  else
    local rThrow = ActionsManager.buildThrow(rActor, vTargets, rRoll, bMultiTarget);
    Comm.throwDice(rThrow);
  end
end

function isMaxResult(rDie)
  if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
    return rDie.result
  else
    return 0
  end
end

function getReRoll(aDice, iRoll)
	local rRoll = {}
  rRoll.aDice = aDice
  rRoll.nMod = iRoll.nMod 
  rRoll.sType = iRoll.sType
  rRoll.bSecret = iRoll.bSecret 
  rRoll.nStrain = iRoll.nStrain
  rRoll.sDesc = iRoll.sDesc
  
  rRoll.rPreviousResult = serializeTable(iRoll.aDice)
  return rRoll
end

function serializeTable(val)
  local tmp = ""

-- Used ipairs instead of pairs to avoid issues with non numeric keys
-- which cause v.result and v.type to be set to nil

  for k, v in ipairs(val) do
    tmp =  tmp .. v.result .. "," .. v.type .. ";"
  end
  
  return tmp
end


function deserializeTable(val)
  local result = {}
  for k,i in string.gmatch(val, "(%w+),(%w+)") do
    local vvv = {}
    vvv.result = k
    vvv.type = i
    table.insert(result, vvv)
  end
  return result
end


function pushExplode(rRoll, nDieSides)
  -- We don't explode modifiers, if any...
  -- Testing new function to explode die by combo method.
  --[[
  local iRoll = { };
  local newDice = "d" .. nDieSides;
  local stringDice = StringManager.convertDiceToString(rRoll.aDice, rRoll.nMod);
  stringDice = stringDice .. newDice;
  local aDice = StringManager.convertStringToDice(stringDice);
  iRoll.aDice = aDice;
  return iRoll;
  ]]--
  explode = {}
	for i,die in ipairs(rRoll.aDice) do
		local reroll = isMaxResult(die)
		if reroll>0 then
      table.insert(explode, die.type)
		end
	end
  if rRoll.rPreviousResult then
    prev = deserializeTable(rRoll.rPreviousResult)
    for i,roll in ipairs(prev) do
        table.insert(rRoll.aDice, 1, roll)
    end
  end
  if table.getn(explode) > 0 then
    if rSource then
      rMessageTemp = ActionsManager.createActionMessage(rSource, rRoll);
    end
      
    ActionsManager.performAction(draginfo, rActor, getReRoll(explode, rRoll)); 
      
    return false;
  end
end

function onResult(rSource, rTarget, rRoll, nTotal)
  local aTargetNodes = {};
  local aTargets;
  if not rTarget then
    local rActor = ActorManager.resolveActor(rSource);
		if rRoll.bSelfTarget then
			aTargets = { rActor };
		else
			aTargets = TargetingManager.getFullTargets(rActor);
		end
		for _,v in ipairs(aTargets) do
			local sCTNode = ActorManager.getCTNodeName(v);
			if sCTNode ~= "" then
				table.insert(aTargetNodes, sCTNode);
			end
		end
		
		if #aTargetNodes > 0 then
			rRoll.aTargets = table.concat(aTargetNodes, "|");
		end
  end
    
  -- Before we display, make sure the sDesc has the charName in it. (this is for talents, skills, etc.)
  if rSource then
    if rSource.sCreatureNode then
      nodeString = tostring(rSource.sCreatureNode);
      local nStart, nEnd = nodeString:find("talent");
      if nStart then
        --We found a talent, need to upgrade the source and rRoll.sDesc
        rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc;
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
      nStart, nEnd = nodeString:find("skill");
      if nStart then
        --We found a skill, need to upgrade the source and rRoll.sDesc
        rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc;
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
    end
  end
  
  --We need to make sure that rRoll.sType has the correct info for the below functions to work.
  --Extract the type of roll from the rRoll.sDesc.
  if rRoll.sDesc then
    local sDescLower = string.lower(rRoll.sDesc);
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "attack");
    if sDesc == "attack" then
      rRoll.sType = "Attack"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "damage");
    if sDesc == "damage" then
      rRoll.sType = "Damage"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "heal");
    if sDesc == "heal" then
      rRoll.sType = "Heal"
      sDesc = nil;
    end
  end
  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
  if rRoll.sType == "InitRoll" then
    local nTotal = ActionsManager.total(rRoll);
    notifyApplyInit(rSource, nTotal);
  end
  if rRoll.sType == "Recovery" then
    -- check for damage/stun and heal it.
    local nodeChar = ActorManager.getCreatureNode(rSource);
    local oldDamage = DB.getValue(nodeChar, "health.damage.value", 0);
    local oldStun = DB.getValue(nodeChar, "health.damage.stun", 0);
    local wounds = DB.getValue(nodeChar, "health.wounds.value", 0);
    local healValue = 0;
    
    local nTotal = ActionsManager.total(rRoll);
    if nTotal > 0 then
      healValue = healValue + nTotal - wounds;
    end
    if healValue < 1 then
      healValue = 1;
    end
    --[[
    for _,v in ipairs(rRoll.aDice) do
      if v.value then
        --FGU
        healValue = healValue + v.value;
      elseif v.result then
        --FGC
        healValue = healValue + v.result;
      end
    end
    ]]--
    local newDamage = oldDamage - healValue;
    local newStun = oldStun - healValue;
    if newDamage < 0 then
      newDamage = 0;
    end
    if newStun < 0 then
      newStun = 0;
    end
    DB.setValue(nodeChar, "health.damage.value", "number", newDamage);
    DB.setValue(nodeChar, "health.damage.stun", "number", newStun);
  end
  if rRoll.sType == "Karma" then
    local nodeChar = ActorManager.getCreatureNode(rSource);
    local oldKarma = DB.getValue(nodeChar, "karma.value", 0);
    local newKarma = oldKarma - 1;
    DB.setValue(nodeChar, "karma.value", "number", newKarma);
  end
  if rRoll.sType == "Heal" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if #aTargets > 0 then
      for i,v in ipairs(aTargets) do
        local ctTarget = ActorManager.resolveActor(v);
        resolveHeal(ctActor, ctTarget, rRoll);
      end
    end
  end
  if rRoll.sType == "Damage" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if #aTargets > 0 then
      for i,v in ipairs(aTargets) do
        local ctTarget = ActorManager.resolveActor(v);
        resolveDamage(ctActor, ctTarget, rRoll);
      end
    end
  end
  if rRoll.sType == "Attack" then
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if #aTargets > 0 then
      for i,v in ipairs(aTargets) do
        local ctTarget = ActorManager.resolveActor(v);
        resolveAttack(ctActor, ctTarget, rRoll);
      end
    end
  end
end

function resolveAttack(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDefense = DB.getValue(nodeTarget, "defenses.physical.value");
  local hitOrMiss = "missed.";
  if nTotal >= targetDefense then
    hitOrMiss = "hits.";
  end
  rMessage.text = "Attacking "..rTarget.sName..". The attack "..hitOrMiss;
	Comm.deliverChatMessage(rMessage);  
end


function resolveDamage(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.value", 0);
  local newDamage = targetDamage + nTotal;
  DB.setValue(nodeTarget, "health.damage.value", "number", newDamage);
  rMessage.text = "Damaging "..rTarget.sName.." for "..nTotal;
	Comm.deliverChatMessage(rMessage);  
end


function resolveHeal(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.value", 0);
  local targetStun = DB.getValue(nodeTarget, "health.damage.stun", 0);
  local newDamage = targetDamage - nTotal;
  local newStun = targetDamage - nTotal;
  if newDamage < 0 then
    newDamage = 0;
  end
  if newStun < 0 then
    newStun = 0;
  end
  DB.setValue(nodeTarget, "health.damage.value", "number", newDamage);
  DB.setValue(nodeTarget, "health.damage.stun", "number", newStun);
  rMessage.text = "Healing "..rTarget.sName.." for "..nTotal;
	Comm.deliverChatMessage(rMessage);  
end


function explodeDie(nDieSides)
  -- This works, don't break it. Needed to explode dice.
  newResult = genRandNum(nDieSides);
  newResult = genRandNum(nDieSides);
  if newResult == nDieSides then
    -- This means we exploded again, keep rolling.
    newResult = explodeDie(nDieSides)
  end
  newResult = newResult + nDieSides;
  return newResult;
end

function genRandNum(nDieSides)
  -- This works, don't change it. Needed for explodeDie(nDieSides);
  local r = 0;
  r=math.random(nDieSides);
  return r;  
end

function notifyApplyInit(rSource, nTotal)
	if not rSource then
		return;
	end
	
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYINIT;
	
	msgOOB.nTotal = nTotal;

	msgOOB.sSourceNode = ActorManager.getCreatureNodeName(rSource);

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyInit(msgOOB)
	local rSource = ActorManager.resolveActor(msgOOB.sSourceNode);
	local nTotal = tonumber(msgOOB.nTotal) or 0;

	DB.setValue(ActorManager.getCTNode(rSource), "initresult", "number", nTotal);
end

function decodeDiceResults(rRoll)
  --Copied from 5e. Need to update with Earthdawn rules for exploding dice (nDieSides == Max then "green") and Rule of One (v.result == 1 then "Red")
  for i,v in ipairs(rRoll.aDice) do
    if v.result then      
      --Check for explosions.
      local vResult = tonumber(v.result);
      local nDieSides = tonumber(v.type:match("[dgpr](%d+)")) or 0;
      if vResult >= nDieSides then
        -- Found Explosion! We need to color Green!
				rRoll.aDice[i].type = "g" .. string.sub(rRoll.aDice[i].type, 2);
      end
      --Check for result of 1.
      if vResult == 1 then       
        -- Found Rule of One! We need to color Red! 
				rRoll.aDice[i].type = "r" .. string.sub(rRoll.aDice[i].type, 2);
      end
    end
  end
end


--Copied from Combo Ruleset

function checkExplode(rSource, rTarget, rRoll)
  local nodeChar = ActorManager.getCreatureNode(rSource);
	local isMaxResult = function(rDie)
		if tonumber(rDie.type:match("^d(%d+)")) == rDie.result then
			return rDie.result
		else
			return 0
		end
	end
	
--	rSource gets erased during an explode/reroll so this is to keep source.
	if nodeChar then
    charCTNode = ActorManager.resolveActor(nodeChar);
	end
  explode = {}
	for i,die in ipairs(rRoll.aDice) do
		local reroll = isMaxResult(die)
		if reroll>0 then
      table.insert(explode, die.type)
		end
	end
  if rRoll.rPreviousResult then
    prev = deserializeTable(rRoll.rPreviousResult)
    for i,roll in ipairs(prev) do
        table.insert(rRoll.aDice, 1, roll)
    end
  end
  if table.getn(explode) > 0 then
    if rSource then
      rMessageTemp = ActionsManager.createActionMessage(rSource, rRoll);
    end
      
    ActionsManager.performAction(draginfo, rActor, getReRoll(explode, rRoll)); 
      
    return false;
  end
  
	--[[
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
  
  --We have our roll, and our total, after explosions. Now we can check for roll types to apply appropriate actions.
  --Need to call my previous onResult to handle after roll actions.
  
	
	if not rSource then
    if rMessageTemp then
      rMessage.sender = rMessageTemp.sender;
    end
	end
	
	Comm.deliverChatMessage(rMessage); -- Return message to previous handler? (Description, step, strain, dice graphic and total roll)
  ]]--
  
  --Color dice for 1's and Explosions.
	ActionManagerED4.decodeDiceResults(rRoll);
  if not rSource then
    rSource = charCTNode;
  end
  
  local nTotal = ActionsManager.total(rRoll);
  ActionManagerED4.onResult(rSource, rTarget, rRoll, nTotal)
  
end

--Copied from 5e.
function onTargeting(rSource, aTargeting, rRolls)
  --This doesn't seem to get called?
	local bRemoveOnMiss = false;
	local sOptRMMT = OptionsManager.getOption("RMMT");
	if sOptRMMT == "on" then
		bRemoveOnMiss = true;
	elseif sOptRMMT == "multi" then
		bRemoveOnMiss = (#aTargeting > 1);
	end
	
	if bRemoveOnMiss then
		for _,vRoll in ipairs(rRolls) do
			vRoll.bRemoveOnMiss = "true";
		end
	end

	return aTargeting;
end




