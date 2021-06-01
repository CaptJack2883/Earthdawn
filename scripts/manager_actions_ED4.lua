-- Action Manager for Earthdawn 4th Edition. 
--  rSource, rRolls, aTargets = decodeActionFromDrag(draginfo, false);

-- This fixes table index being nil.
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	-- Register the new action we're creating.  We'll allow use of the modifier stack for this action type.
	--GameSystem.actions["mytestaction"] = { bUseModStack = true };
	--GameSystem.actions["InitRoll"] = { bUseModStack = true };
	--GameSystem.actions["Explode"] = { bUseModStack = false };
  
	GameSystem.actions["Recovery"] = { bUseModStack = true };
	GameSystem.actions["Recovery"].sIcon = "iconHeal";
  
  --Register OOB Message Handlers
  
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYINIT, handleApplyInit);
	
	-- Register the result handlers - called after the dice have stopped rolling
	--ActionsManager.registerResultHandler("mytestaction", onRoll);
	ActionsManager.registerResultHandler("InitRoll", onResult);
	ActionsManager.registerResultHandler("Strength", onResult);
	ActionsManager.registerResultHandler("Dexterity", onResult);
	ActionsManager.registerResultHandler("Toughness", onResult);
	ActionsManager.registerResultHandler("Perception", onResult);
	ActionsManager.registerResultHandler("Willpower", onResult);
	ActionsManager.registerResultHandler("Charisma", onResult);
	ActionsManager.registerResultHandler("Recovery", onResult);
	ActionsManager.registerResultHandler("Knockdown", onResult);
	ActionsManager.registerResultHandler("Karma", onResult);
	ActionsManager.registerResultHandler("Talent", onResult);
	ActionsManager.registerResultHandler("Skill", onResult);
	ActionsManager.registerResultHandler("dice", onResult);
end

function getRoll(rType, rStep, rActor, bSecretRoll)
	-- Initialise a blank rRoll record
	local rRoll = {};
  rRoll.sDesc = "";
	
	-- Add the 4 minimum parameters needed:
	-- the action type.
  if rType then
    rRoll.sType = rType;
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

function dragRoll(draginfo, rType, rStep, rActor, bSecretRoll)
  rSource, _, vTargets = decodeActionFromDrag(draginfo, false);
  
  local rRoll = getRoll(rType, rStep, rActor, bSecretRoll);
  ActionsManager.performAction(draginfo, rActor, rRoll);
end

function pushRoll(rType, rStep, rActor, bSecretRoll)
  local rRoll = ActionManagerED4.getRoll(rType, rStep, rActor, bSecretRoll)
  if not rRoll.bTower and OptionsManager.isOption("MANUALROLL", "on") then
    local wManualRoll = Interface.openWindow("manualrolls", "");
    wManualRoll.addRoll(rRoll, rActor, vTargets);
  else
    local rThrow = ActionsManager.buildThrow(rActor, vTargets, rRoll, bMultiTarget);
    Comm.throwDice(rThrow);
  end
end

function pushExplode(nDieSides)
  -- We don't explode modifiers, if any...
  -- Testing new function to explode die by Comm.throwDice()?
  local stringDice = "d" .. nDieSides;
  local bData = { };
	local rSlot = { };
	rSlot.dice = stringDice;
  bData.type = "dice";
	bData.slots = { rSlot };
  Comm.throwDice(bData);
end

function onResult(rSource, rTarget, rRoll)  
  -- Check for Max Value, and explode if needed.
  for _,v in ipairs(rRoll.aDice) do
    if v.result then
      local nDieSides = tonumber(v.type:match("[dgpr](%d+)")) or 0;
      if v.result == nDieSides then
        -- We need to explode! Roll another die and add it to v.result.
        -- Separate function to allow recursion.
        v.result = explodeDie(nDieSides);
      end
    end
  end
  
  --Now we're gonna see if we need to color the dice.
  decodeDiceResults(rRoll);
  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
  if rRoll.sType == "InitRoll" then
    local nTotal = ActionsManager.total(rRoll);
    notifyApplyInit(rSource, nTotal);
  end
  if rRoll.sType == "Recovery" then
    local nodeChar = ActorManager.getCreatureNode(rSource);
    local oldDamage = DB.getValue(nodeChar, "health.damage.value", 0);
    local healValue = 0;
    for _,v in ipairs(rRoll.aDice) do
      if v.result then
        healValue = healValue + v.result;
      end
    end
    local newDamage = oldDamage - healValue;
    if newDamage < 0 then
      newDamage = 0;
    end
    DB.setValue(nodeChar, "health.damage.value", "number", newDamage);
  end
  if rRoll.sType == "Karma" then
    local nodeChar = ActorManager.getCreatureNode(rSource);
    local oldKarma = DB.getValue(nodeChar, "karma.value", 0);
    local newKarma = oldKarma - 1;
    DB.setValue(nodeChar, "karma.value", "number", newKarma);
  end
end

function explodeDie(nDieSides)
  -- This works, don't break it.
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
  -- This works, don't change it.
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

function decodeActionFromDrag(draginfo, bFinal)
	local rSource, aTargets = ActionsManager.decodeActors(draginfo);
	local rRolls = {};
	for i = 1, draginfo.getSlotCount() do
		table.insert(rRolls, ActionsManager.decodeRollFromDrag(draginfo, i, bFinal));
	end
	
	return rSource, rRolls, aTargets;
end

function decodeDiceResults(rRoll)
  --Copied from 5e. Need to update with Earthdawn rules for exploding dice (nDieSides == Max then "green") and Rule of One (v.result == 1 then "Red")
  for i,v in ipairs(rRoll.aDice) do
    if v.result then
      --Check for explosions.
      local nDieSides = tonumber(v.type:match("[dgpr](%d+)")) or 0;
      if v.result > nDieSides then
        -- Found Explosion! We need to color Green!
				rRoll.aDice[i].type = "g" .. string.sub(rRoll.aDice[i].type, 2);
      end
      --Check for result of 1.
      if v.result == 1 then       
        -- Found Rule of One! We need to color Red! 
				rRoll.aDice[i].type = "r" .. string.sub(rRoll.aDice[i].type, 2);
      end
    end
  end
  
	if (bADV and not bDIS) or (bDIS and not bADV) then
		if #(rRoll.aDice) > 1 then
			local nDecodeDie;
			if (bADV and not bDIS) then
				nDecodeDie = math.max(rRoll.aDice[1].result, rRoll.aDice[2].result);
				nDroppedDie = math.min(rRoll.aDice[1].result, rRoll.aDice[2].result);
				rRoll.aDice[1].type = "g" .. string.sub(rRoll.aDice[1].type, 2);
			else
				nDecodeDie = math.min(rRoll.aDice[1].result, rRoll.aDice[2].result);
				nDroppedDie = math.max(rRoll.aDice[1].result, rRoll.aDice[2].result);
				rRoll.aDice[1].type = "r" .. string.sub(rRoll.aDice[1].type, 2);
			end
			rRoll.aDice[1].result = nDecodeDie;
			rRoll.aDice[1].value = nil;
			table.remove(rRoll.aDice, 2);
			rRoll.aDice.expr = nil;
			rRoll.sDesc = rRoll.sDesc .. " [DROPPED " .. nDroppedDie .. "]";
		end
	end	
  
end






