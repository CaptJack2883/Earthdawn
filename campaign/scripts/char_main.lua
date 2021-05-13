
function onInit()
  --nodeSrc = window.getinfo();  NOPE
  --DB.addHandler("charsheet.*", "onObserverUpdate", onUpdate);  NOPE
  --DB.addHandler("charsheet_main.*", "onUpdate", onUpdate);  NOPE
  
  --DB.addHandler(DB.getPath(charsheet_main, "Str_Value"), "onObserverUpdate", onUpdate);  NOPE

  --[[  NOPE
  DB.addHandler(DB.getPath(nodeSrc, "Str_Value"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Dex_Value"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Tou_Value"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Per_Value"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Wil_Value"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Cha_Value"), "onUpdate", onUpdate);
  
  DB.addHandler(DB.getPath(nodeSrc, "Str_Step"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Dex_Step"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Tou_Step"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Per_Step"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Wil_Step"), "onUpdate", onUpdate);
  DB.addHandler(DB.getPath(nodeSrc, "Cha_Step"), "onUpdate", onUpdate);
  ]]--
  
  --DB.addHandler(DB.getPath(nodeSrc, "charsheet_main"), "onUpdate", onValueChanged);  NOPE
  
  --local node = getDatabaseNode();    NOPE
  --DB.addHandler(DB.getPath(node, "Str_Value"), "onUpdate", onUpdate);  NOPE  
  --print(Str_Value);
  
  -- DB.addHandler("Parameter1", "Parameter2", Parameter3);
  
  --DB.addHandler("Str_Value", "onValueChanged", onValueChanged);
  
  print("Initializing Attributes");
  Global.cmUpdating = false;
  onUpdate(); -- This works.    
end

function onUpdate()
  -- This function will update all the values on the character sheet, based on the Characteristics Table (EDPG pg63)
  
  print("Updating Attributes");
  
  -- Update the Step for each Ability Value.
  -- Working!! Just doesn't immediately update??
  Str_Step.setValue(StepLookup.getStep(Str_Value.getValue()));  
  Dex_Step.setValue(StepLookup.getStep(Dex_Value.getValue()));
  Tou_Step.setValue(StepLookup.getStep(Tou_Value.getValue()));
  Per_Step.setValue(StepLookup.getStep(Per_Value.getValue()));
  Wil_Step.setValue(StepLookup.getStep(Wil_Value.getValue()));
  Cha_Step.setValue(StepLookup.getStep(Cha_Value.getValue()));
  
  -- Update the Dice for each Ability Step
  -- Working!! 
  --[[
  Str_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Str_Step.getValue())) do
		Str_Dice.addDie(vDie);
  end
  Dex_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Dex_Step.getValue())) do
		Dex_Dice.addDie(vDie);
  end
  Tou_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Tou_Step.getValue())) do
		Tou_Dice.addDie(vDie);
  end
  Per_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Per_Step.getValue())) do
		Per_Dice.addDie(vDie);
  end
  Wil_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Wil_Step.getValue())) do
		Wil_Dice.addDie(vDie);
  end
  Cha_Dice.reset();
	for _, vDie in ipairs(StepLookup.getStepDice(Cha_Step.getValue())) do
		Cha_Dice.addDie(vDie);
  end
  ]]--
  
  --Update Defense Ratings
  Physical_Def.setValue(math.ceil(Dex_Value.getValue()/2)+1);
  Mystic_Def.setValue(math.ceil(Per_Value.getValue()/2)+1);
  Social_Def.setValue(math.ceil(Cha_Value.getValue()/2)+1);
  Uncon_Rating.setValue(Tou_Value.getValue()*2);
  Death_Rating.setValue(Tou_Value.getValue()*2+Tou_Step.getValue());
  Wound_Threshold.setValue(math.ceil(Tou_Value.getValue()/2)+2);  
  Mystic_Armor.setValue(math.floor(Wil_Value.getValue()/5));
  Initiative_Step.setValue(Dex_Step.getValue());
  Knockdown_Step.setValue(Str_Step.getValue());
  
  --This is not causing the recursive call.
  updateKarma();
  
end

function updateKarma()
  local karmaMod = 0;
  local playerCircle = tonumber(circle.getValue());
  local playerRace = race.getValue();
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
    MaxKarma.setValue(karmaMod * playerCircle);
  end
end
  
function testObj(obj)  
  print("Running testObj Function.");
  for i,v in pairs(obj) do
    print(i);
    print(v);
  end
  print("Ending testObj Function.");
end


















