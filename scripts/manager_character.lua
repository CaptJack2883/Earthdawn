--External functions for managing characters.

function overnightRest(nodeChar)
  --print("Testing overnightRest Function.");
  updateKarma(nodeChar);
  --recoveryTest(nodeChar);
  --print("Ending overnightRest Function.");
end

function updateKarma(nodeChar)
  --print("Testing updateKarma Function.");
  local newKarma = DB.getValue(nodeChar, "karma.max", 0);
	DB.setValue(nodeChar, "karma.value", "number", newKarma);
  --print(newKarma);
  --print("Ending updateKarma Function.");
end

function recoveryTest(nodeChar)
  -- WIP: Not Finished. need to be able to create a roll without draginfo.
  --print("Testing recoveryTest Function.");
  local recStep = DB.getValue(nodeChar, "health.recovery.step", 0);
  local dragInfo = { };
  dragInfo.type = "dice";
  dragInfo.slots = StepLookup.getStepDice(recStep);
  dragInfo.shortcuts = { nodeChar };
  --local dragInfo = setData(dragTable);
  ManagerED4.performRoll(dragInfo, "Recovery", recStep, nodeChar, false);
  --print("Ending recoveryTest Function.");
end