-- Action Manager for Earthdawn 4th Edition. 
--  rSource, rRolls, aTargets = decodeActionFromDrag(draginfo, false);

-- This fixes table index being nil.
OOB_MSGTYPE_APPLYINIT = "applyinit";

function onInit()
	-- Register the new action we're creating.  We'll allow use of the modifier stack for this action type.
	--GameSystem.actions["mytestaction"] = { bUseModStack = true };
	--GameSystem.actions["InitRoll"] = { bUseModStack = true };
	--GameSystem.actions["Explode"] = { bUseModStack = false };
  
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
	ActionsManager.registerResultHandler("dice", onResult);
end

function getRoll(rType, rStep, rActor, bSecretRoll)
	-- Initialise a blank rRoll record
	local rRoll = {};
	
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
    rRoll.sDesc = "Initiative: ";
  elseif rRoll.sType == "Strength" then
    rRoll.sDesc = "Strength Check: ";
  elseif rRoll.sType == "Dexterity" then
    rRoll.sDesc = "Dexterity Check: ";
  elseif rRoll.sType == "Toughness" then
    rRoll.sDesc = "Toughness Check: ";
  elseif rRoll.sType == "Perception" then
    rRoll.sDesc = "Perception Check: ";
  elseif rRoll.sType == "Willpower" then
    rRoll.sDesc = "Willpower Check: ";
  elseif rRoll.sType == "Charisma" then
    rRoll.sDesc = "Charisma Check: ";
  elseif rRoll.sType == "Recovery" then
    rRoll.sDesc = "Recovery Check: ";
  elseif rRoll.sType == "Knockdown" then
    rRoll.sDesc = "Knockdown Check: ";
  elseif rRoll.sType == "Karma" then
    rRoll.sDesc = "Karma Die: ";
  else
    rRoll.sDesc = "Default Roll Description";
  end
	-- the dice to roll. Set correct step dice based on rStep
  if rStep then
    rRoll.aDice, rRoll.nMod = StepLookup.getStepDice(rStep);
    rRoll.sDesc = rRoll.sDesc .. "Step " .. rStep .. ":";
  end
	-- For GM secret rolls.
	rRoll.bSecret = bSecretRoll;
	
	return rRoll;
end

function performRoll(draginfo, rType, rStep, rActor, bSecretRoll)
  rSource, _, vTargets = decodeActionFromDrag(draginfo, false);
  print("Testing performRoll");
  
  --[[
  if not rSource then
    print("rSource is Empty?");
  else
    print(rSource);
  end
  ]]--
  
  local rRoll = getRoll(rType, rStep, rActor, bSecretRoll);
  ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performExplode(draginfo, nDieSides, rActor, bSecretRoll)
  rSource, _, vTargets = decodeActionFromDrag(draginfo, false);
  print("Testing performExplode");
  if not rSource then
    print("rSource is Empty?");
  else
    print(rSource);
  end
  local addDie = string.format("d%s",nDieSides);
  -- This is working.
  print(addDie);
  -- finish explosion.
  local rRoll = {};
  rRoll.aDice = addDie
  ActionsManager.roll(rSource, vTargets, rRoll, bMultiTarget);
end

function onPostRoll(rSource, rRoll)
  --print("Testing onPostRoll function.");
end

function onResult(rSource, rTarget, rRoll)
  --print("Testing onResult function.");
  print("Testing onResult");
  if not rSource then
    print("rSource is Empty?");
    return;
  else
    print(rSource);
  end
  
  for _,v in ipairs(rRoll.aDice) do
    if v.value then
      --print("Printing v.value.");
      --print(v.value);
    end
    if v.result then
      --print("Printing v.result.");
      --print(v.result);
      -- Check for Max Value, and reroll.
      local nDieSides = tonumber(v.type:match("[dgpr](%d+)")) or 0;
      if v.result == nDieSides then
        -- We need to explode! Roll another die and add it to v.result.
        -- Separate function to allow recursion. 
        --print("Exploding Dice!");
        v.result,rRoll.nMod = explodeDie(nDieSides,rRoll.nMod);
      end
    end
  end
  
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	-- Display the message in chat.
	Comm.deliverChatMessage(rMessage);
  if rRoll.sType == "InitRoll" then
    print("Testing Initiative Rolls");
    if not rSource then
      print("rSource is Empty?");
    else
      print(rSource);
    end
    local nTotal = ActionsManager.total(rRoll);
    print(nTotal);
    notifyApplyInit(rSource, nTotal);
  end
  if rRoll.sType == "Recovery" then
    --handle recovery rolls
  end
end

function explodeDie(nDieSides, nMod, nExplode)
  -- This works, don't change it.
  newResult = genRandNum(nDieSides);
  newResult = genRandNum(nDieSides);
  --print(newResult);
  if newResult == nDieSides then
    -- This means we exploded again, keep rolling.
    newResult, nMod = explodeDie(nDieSides, nMod)
    --print(newResult);
  end
  if nMod then 
    nMod = nMod + nMod;
  end
  newResult = newResult + nDieSides;
  --print(newResult);
  return newResult, nMod;
end

function genRandNum(nDieSides)
  -- This works, don't change it.
  local r = 0;
  r=math.random(nDieSides);
  --print("Checking...");
  --print(r);
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
  print("Testing DecodeActionFromDrag");
	local rSource, aTargets = ActionsManager.decodeActors(draginfo);
  
  --[[
  if rSource.sName then
    print(rSource.sName);
  else
    print("rSource is Empty?");
  end
  ]]--
  
	local rRolls = {};
	for i = 1, draginfo.getSlotCount() do
		table.insert(rRolls, ActionsManager.decodeRollFromDrag(draginfo, i, bFinal));
	end
	
	return rSource, rRolls, aTargets;
end

function testObject(obj)
  print("Testing Object.");
  for i,v in ipairs(obj) do
    print(i);
    print(i.sName);
    print(v);
    print(v.sName);
  end
  print(obj.sName);
  --print(obj.getName());
  print("Done Testing Object");
end





