-- Action Manager for Earthdawn 4th Edition. 
--  rSource, rRolls, aTargets = decodeActionFromDrag(draginfo, false);

-- This fixes table index being nil.
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
  --Register OOB Message Handlers
  
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);
	
	-- Register the result handlers - called after the dice have stopped rolling
  -- We need to use the onResult from ActionStep (onExplode) to use the new explosions, I think.
  --  ActionStep.onResult(rSource, rTarget, rRoll); (from combo)
  -- ActionManagerED4.onExplode(rSource, rTarget, rRoll);
	--ActionsManager.registerResultHandler("mytestaction", onRoll);
	ActionsManager.registerResultHandler("explode", onResult);
	ActionsManager.registerResultHandler("initroll", onResult);
	ActionsManager.registerResultHandler("strength", onResult);
	ActionsManager.registerResultHandler("dexterity", onResult);
	ActionsManager.registerResultHandler("toughness", onResult);
	ActionsManager.registerResultHandler("perception", onResult);
	ActionsManager.registerResultHandler("willpower", onResult);
	ActionsManager.registerResultHandler("charisma", onResult);
	ActionsManager.registerResultHandler("recovery", onResult);
	ActionsManager.registerResultHandler("heal", onResult);
	ActionsManager.registerResultHandler("damage", onResult);
	ActionsManager.registerResultHandler("stun", onResult);
	ActionsManager.registerResultHandler("attack", onResult);
	ActionsManager.registerResultHandler("knockdown", onResult);
	ActionsManager.registerResultHandler("karma", onResult);
	ActionsManager.registerResultHandler("talent", onResult);
	ActionsManager.registerResultHandler("skill", onResult);
	ActionsManager.registerResultHandler("dice", onResult);
	ActionsManager.registerTargetingHandler("attack", onTargeting);
end

function getRoll(sType, rStep, rActor, bSecretRoll)
	-- Initialise a blank rRoll record
	local rRoll = {};
  rRoll.sDesc = "";
	-- the dice to roll. Set correct step dice based on rStep
  if not rStep then
    Debug.console("ActionManagerED4: Called getRoll, but rStep was nil.");
    rStep = 1;
  end
  if rStep then
    rRoll = StepLookup.getRoll(rStep);
    --rRoll.aDice, rRoll.nMod, rStep = StepLookup.getStepDice(rStep);
    --rRoll.sDesc =  "(Step " .. rStep .. ") ";
    --Debug.chat("Testing aDice inside getRoll");
    --Debug.chat(rRoll);
  end
	-- Action type.
  if sType then
    rRoll.sType = sType;
  end  
	-- The description to show in the chat window
  if rRoll.sType == "initroll" then
    rRoll.sDesc = "Initiative: " .. rRoll.sDesc;
  elseif rRoll.sType == "explode" then
    rRoll.sDesc =  "Explode: " .. rRoll.sDesc;
  elseif rRoll.sType == "strength" then
    rRoll.sDesc =  "Strength Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "dexterity" then
    rRoll.sDesc =  "Dexterity Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "toughness" then
    rRoll.sDesc =  "Toughness Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "perception" then
    rRoll.sDesc =  "Perception Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "willpower" then
    rRoll.sDesc =  "Willpower Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "charisma" then
    rRoll.sDesc =  "Charisma Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "recovery" then
    rRoll.sDesc =  "Recovery Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "knockdown" then
    rRoll.sDesc =  "Knockdown Check: " .. rRoll.sDesc;
  elseif rRoll.sType == "karma" then
    rRoll.sDesc =  "Karma Die: " .. rRoll.sDesc;
  elseif rRoll.sType == "heal" then
    rRoll.sDesc =  "Heal: " .. rRoll.sDesc;
  elseif rRoll.sType == "damage" then
    rRoll.sDesc =  "Damage: " .. rRoll.sDesc;
  elseif rRoll.sType == "stun" then
    rRoll.sDesc =  "Stun Damage: " .. rRoll.sDesc;
  elseif rRoll.sType == "attack" then
    rRoll.sDesc =  "Attack: " .. rRoll.sDesc;
  elseif rRoll.sType == "talent" then
    rRoll.sDesc =  "Talent: " .. rRoll.sDesc;
  elseif rRoll.sType == "skill" then
    rRoll.sDesc =  "Skill: " .. rRoll.sDesc;
  else
    rRoll.sDesc =  "Default Roll Description";
  end
	-- For GM secret rolls.
	rRoll.bSecret = bSecretRoll;
	return rRoll;
end

function dragRoll(draginfo, sType, rStep, rActor, bSecretRoll, rRoll)
  rSource, _, vTargets = ActionsManager.decodeActionFromDrag(draginfo, false);
  if not rRoll then
    rRoll = ActionManagerED4.getRoll(sType, rStep, rActor, bSecretRoll);
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
      rRoll.sType = "attack"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "damage");
    if sDesc == "damage" then
      rRoll.sType = "damage"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "stun");
    if sDesc == "stun" then
      rRoll.sType = "stun"
      sDesc = nil;
    end
    sDesc, sRemainder = StringManager.extractPattern(sDescLower, "heal");
    if sDesc == "heal" then
      rRoll.sType = "heal"
      sDesc = nil;
    end
  end
  
  if rRoll.aDice.expr then
    --Debug.chat(rRoll.aDice.expr);
  elseif rRoll.aDice then
    --Debug.chat(rRoll.aDice);
  end
    
  --Color dice for 1's and Explosions.
	ActionManagerED4.decodeDiceResults(rRoll);
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
  if rRoll.sType == "initroll" then
    local nTotal = ActionsManager.total(rRoll);
    if nTotal < 1 then
      nTotal = 1;
    end
    notifyApplyInit(rSource, nTotal);
  end
  if rRoll.sType == "recovery" then
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
  if rRoll.sType == "karma" then
    local nodeChar = ActorManager.getCreatureNode(rSource);
    local oldKarma = DB.getValue(nodeChar, "karma.value", 0);
    local newKarma = oldKarma - 1;
    DB.setValue(nodeChar, "karma.value", "number", newKarma);
  end
  if rRoll.sType == "heal" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveHeal(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveHeal(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "damage" then
    --Debug.chat("Testing Damage Function");
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveDamage(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveDamage(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "stun" then
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveStunDamage(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveStunDamage(ctActor, ctTarget, rRoll);
    end
  end
  if rRoll.sType == "attack" then
    --Debug.chat("Testing Attack Function");
    local nTotal = ActionsManager.total(rRoll);
    -- rSource is a creatureNode, and we need the CT node if there is one. 
    local ctActor = ActorManager.resolveActor(rSource);
    if aTargets then
      if #aTargets > 0 then
        for i,v in ipairs(aTargets) do
          local ctTarget = ActorManager.resolveActor(v);
          resolveAttack(ctActor, ctTarget, rRoll);
        end
      end
    elseif rTarget then
      local ctTarget = ActorManager.resolveActor(rTarget);
      resolveAttack(ctActor, ctTarget, rRoll);
    end
  end
  if rTarget then
    --Debug.chat("Clearing rTarget.");
    rTarget = nil;
  end
  if nodeTarget then
    --Debug.chat("Clearing nodeTarget.");
    nodeTarget = nil;
  end
  if targetCTNode then
    --Debug.chat("Clearing targetCTNode.");
    targetCTNode = nil;
  end
  if ctTarget then
    --Debug.chat("Clearing ctTarget.");
    ctTarget = nil;
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
  rMessage.text = "Damaging "..rTarget.sName.." for "..nTotal.." Lethal Damage.";
	Comm.deliverChatMessage(rMessage);  
end

function resolveStunDamage(rSource, rTarget, rRoll)
  local rActor = ActorManager.resolveActor(rSource);
  local nodeTarget = ActorManager.getCreatureNode(rTarget);
  local nTotal = ActionsManager.total(rRoll);
	local rMessage = ChatManager.createBaseMessage(rSource, rRoll.sUser);
  local targetDamage = DB.getValue(nodeTarget, "health.damage.stun", 0);
  local newDamage = targetDamage + nTotal;
  DB.setValue(nodeTarget, "health.damage.stun", "number", newDamage);
  rMessage.text = "Damaging "..rTarget.sName.." for "..nTotal.." Stun Damage.";
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
  local newStun = targetStun - nTotal;
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



--[[ POSSIBLY DEPRECATED ]]--


--Copied from Combo Ruleset

function checkExplode(rSource, rTarget, rRoll)
  if rSource then
    local nodeChar = ActorManager.getCreatureNode(rSource);
  end
  if rTarget then
    -- This is working.
    nodeTarget = ActorManager.getCreatureNode(rTarget);
  end
  if not rTarget then
    --Debug.chat("No drop targets, looking for CT targets.");
    --Debug.chat(aTargets);
  end
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
  if nodeTarget then
    targetCTNode = ActorManager.resolveActor(nodeTarget);
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
  
  --We have our roll, and our total, after explosions. Now we can check for roll types to apply appropriate actions.
  --Need to call my previous onResult to handle after roll actions.
  --Color dice for 1's and Explosions.
	ActionManagerED4.decodeDiceResults(rRoll);
  if not rSource then
    rSource = charCTNode;
  end
  if not rTarget then
    if targetCTNode then
      rTarget = targetCTNode;
    end
  end
  
  local nTotal = ActionsManager.total(rRoll);
  ActionManagerED4.onResult(rSource, rTarget, rRoll, nTotal)
  
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
