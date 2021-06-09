--External functions for managing characters.

function overnightRest(nodeChar)
  updateKarma(nodeChar);
  recoveryTest(nodeChar);
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
  local currentHealth = DB.getValue(nodeChar, "health.damage.value", 0);
  local rType = "Recovery";
  local bSecretRoll = false;
  if currentHealth > 0 then
    ActionManagerED4.pushRoll(rType, rStep, nodeChar, bSecretRoll);
  end
end

function rollInit(nodeChar, bSecretRoll)
  local rStep = DB.getValue(nodeChar, "initiative.step", 0);
  local rType = "InitRoll";
  ActionManagerED4.pushRoll(rType, rStep, nodeChar, bSecretRoll);
end

function getKarmaStep(nodeChar)
  Debug.printstack();
  local rActor = ActorManager.resolveActor(nodeChar);
  --Invalid Parameter for client? but only sometimes??
  local karmaStep = DB.getValue(actorPath, "karma.step", 4);
  return karmaStep;
end

function setKarmaStep(nodeChar, kStep)
  local rActor = ActorManager.resolveActor(nodeChar);
  kStep = tonumber(kStep);
  DB.setValue(rActor, "karma.step", "number", kStep);
end

function updateMaxCarry(nodeChar)
  local strValue = DB.getValue(nodeChar, "abilities.strength.value", 0);
  local maxCarry = StepLookup.getMaxCarry(strValue);
  DB.setValue(nodeChar, "encumbrance.max", "number", maxCarry);  
end




