--External functions for managing characters.

function overnightRest(nodeChar)
  updateKarma(nodeChar);
  recoveryTest(nodeChar);
end

function updateTalents(nodeChar)
  --First we find the current window's character sheet.
  local rActor = ActorManager.resolveActor(nodeChar);
  if rActor.sType == "charsheet" then
    --We found a character, now we notify the talent window
    ActionManagerED4.notifyUpdateStat(nodeChar);
  end
end

function updateKarma(nodeChar)
  updateMaxKarma(nodeChar)
  local newKarma = DB.getValue(nodeChar, "karma.max", 0);
  DB.setValue(nodeChar, "karma.value", "number", newKarma);
end

function updateMaxKarma(nodeChar)
  local karmaMod = 0;
  local playerCircle = tonumber(DB.getValue(nodeChar, "circle", 0));
  local playerRace = DB.getValue(nodeChar, "race", "");
  if playerRace == "Dwarf" then
    karmaMod = 4;
  elseif playerRace == "Elf" then
    karmaMod = 4;
  elseif playerRace == "Human" then
    karmaMod = 5;
  elseif playerRace == "Obsidiman" then
    karmaMod = 3;
  elseif playerRace == "Ork" then
    karmaMod = 5;
  elseif playerRace == "Troll" then
    karmaMod = 3;
  elseif playerRace == "T'skrang" then
    karmaMod = 4;
  elseif playerRace == "Windling" then
    karmaMod = 6;
  end
  if playerCircle and karmaMod > 0 then
    local maxKarma = (karmaMod * playerCircle);
    DB.setValue(nodeChar, "karma.max", "number", maxKarma);
  end
end

function recoveryTest(nodeChar)
  local rActor = ActorManager.resolveActor(nodeChar);
  local rStep = DB.getValue(nodeChar, "health.recovery.step", 0);
  local currentHealth = DB.getValue(nodeChar, "health.damage.total", 0);
  local currentBlood = DB.getValue(nodeChar, "health.damage.blood", 0);
  local sType = "recovery";
  if currentHealth > currentBlood then
    ActionManagerED4.pushRoll(sType, rStep, nodeChar);
  end
end

function rollInit(nodeChar, bSecretRoll)
  local rStep = DB.getValue(nodeChar, "initiative.step", 0);
  local sType = "initroll";
  ActionManagerED4.pushRoll(sType, rStep, nodeChar, bSecretRoll);
end

function getKarmaValue(nodeChar)
  local karmaValue = 0;
  --Check to see if we're inside a talent/spell/action
  nodeChar = CharacterManager.verifyActor(nodeChar);
  nodeChar = ActorManager.resolveActor(nodeChar);
  if nodeChar and nodeChar.sCreatureNode then
    local rActor = ActorManager.getCreatureNode(nodeChar);
    --Invalid Parameter for client? but only sometimes?? I hope this is fixed?
    karmaValue = DB.getValue(rActor, "karma.value", 0);
  end
  return karmaValue;
end

function setKarmaValue(nodeChar, kValue)
  --Check to see if we're inside a talent/spell/action
  nodeChar = CharacterManager.verifyActor(nodeChar);
  nodeChar = ActorManager.resolveActor(nodeChar);
  if nodeChar and nodeChar.sCreatureNode then
    local rActor = ActorManager.getCreatureNode(nodeChar);
    kValue = tonumber(kValue);
    if kValue < 1 then
      kValue = 0;
    end
    DB.setValue(rActor, "karma.value", "number", kValue);
  end
end

function getKarmaStep(nodeChar)
  local karmaStep = 4;
  nodeChar = CharacterManager.verifyActor(nodeChar);
  if nodeChar and nodeChar.sCreatureNode then
    local rActor = ActorManager.getCreatureNode(nodeChar);
    --still returning default value???
    karmaStep = DB.getValue(rActor, "karma.step", 4);
  end
  return karmaStep;
end

function setKarmaStep(nodeChar, kStep)
  nodeChar = CharacterManager.verifyActor(nodeChar);
  if nodeChar and nodeChar.sCreatureNode then
    local rActor = ActorManager.getCreatureNode(nodeChar);
    kStep = tonumber(kStep);
    DB.setValue(rActor, "karma.step", "number", kStep);
  end
end

function updateMaxCarry(nodeChar)
  local strValue = DB.getValue(nodeChar, "abilities.strength.value", 0);
  local maxCarry = StepLookup.getMaxCarry(strValue);
  DB.setValue(rActor, "encumbrance.max", "number", maxCarry);  
end

function updateDamage(rActor, dmgValue)
  if not dmgValue then
    dmgValue = 0;
  end
  newDmg = 0;
  local nodePC = ActorManager.getCreatureNode(rActor);
  local pcDmgTotal = DB.getValue(nodePC, "health.damage.total", 0);
  local pcDmgValue = DB.getValue(nodePC, "health.damage.value", 0);
  local pcDmgStun = DB.getValue(nodePC, "health.damage.stun", 0);
  local pcDmgBlood = DB.getValue(nodePC, "health.damage.blood", 0);
  local newValue = dmgValue - pcDmgStun - pcDmgBlood;
  if newValue < 0 then
    newValue = 0;
  end
  local newTotal = newValue + pcDmgStun + pcDmgBlood;
  if newTotal < 0 then
    newTotal = 0;
  end
  if newValue ~= pcDmgValue then
    DB.setValue(nodePC, "health.damage.value", "number", newValue);
    DB.setValue(nodePC, "health.damage.total", "number", newTotal);
  else
  end
end

function verifyActor(rSource, rRoll)
  if rSource then
    rSource = ActorManager.resolveActor(rSource);
    if rSource.sCreatureNode then
      nodeString = tostring(rSource.sCreatureNode);
      local nStart, nEnd = nodeString:find("talent");
      if nStart then
        --We found a talent, need to upgrade the source and rRoll.sDesc
        if rRoll then
          rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc;
        end
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
      nStart, nEnd = nodeString:find("skill");
      if nStart then
        --We found a skill, need to upgrade the source and rRoll.sDesc
        if rRoll then
          rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc;
        end
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
      nStart, nEnd = nodeString:find("spell");
      if nStart then
        --We found a spell roll, need to upgrade the source and rRoll.sDesc
        --And we need to add the VS info to the sDesc.
        if rRoll then
          rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc .. " " .. rRoll.vs;
        end
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
      nStart, nEnd = nodeString:find("action");
      if nStart then
        --We found an action, need to upgrade the source and rRoll.sDesc
        if rRoll then
          rRoll.sDesc = rSource.sName .. ": " .. rRoll.sDesc;
        end
        local rActor = ActorManager.getCreatureNode(rSource);
        -- go up two steps to find character node.
        local rParent = DB.getParent(DB.getParent(rActor));
        rSource = ActorManager.resolveActor(rParent);
        nStart=nil;
      end
    end
  end  
  return rSource, rRoll;
end

