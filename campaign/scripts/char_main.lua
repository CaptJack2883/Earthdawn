
function onInit()
  onUpdate();
end

function onUpdate()
  -- This function will update all the values on the character sheet, based on the Characteristics Table (EDPG pg63)
  -- Update the Step for each Ability Value.
  Str_Step.setValue(StepLookup.getStep(Str_Value.getValue()));  
  Dex_Step.setValue(StepLookup.getStep(Dex_Value.getValue()));
  Tou_Step.setValue(StepLookup.getStep(Tou_Value.getValue()));
  Per_Step.setValue(StepLookup.getStep(Per_Value.getValue()));
  Wil_Step.setValue(StepLookup.getStep(Wil_Value.getValue()));
  Cha_Step.setValue(StepLookup.getStep(Cha_Value.getValue()));
    
  --Update Characteristics (Table (EDPG pg63))
  Physical_Def.setValue(math.ceil(Dex_Value.getValue()/2)+1);
  Mystic_Def.setValue(math.ceil(Per_Value.getValue()/2)+1);
  Social_Def.setValue(math.ceil(Cha_Value.getValue()/2)+1);
  Uncon_Rating.setValue(Tou_Value.getValue()*2);
  Death_Rating.setValue(Tou_Value.getValue()*2+Tou_Step.getValue());
  Wound_Threshold.setValue(math.ceil(Tou_Value.getValue()/2)+2);  
  Mystic_Armor.setValue(math.floor(Wil_Value.getValue()/5));
  Initiative_Step.setValue(Dex_Step.getValue());
  Knockdown_Step.setValue(Str_Step.getValue());
  Recovery_max.setValue(math.ceil(Tou_Value.getValue()/6));
  
  --Other updating functions.
  updateKarma();
  udpateCarry();
  updateDamage();
  
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
  local karmaStep = KarmaStep.getValue();
  if not karmaStep == 4 then
    karmaStep = 4;
  end
end

function udpateCarry()
  local nodeChar = getDatabaseNode();
  CharacterManager.updateMaxCarry(nodeChar);
end

function updateDamage()
  local dmgTotal = 0;
  local dmgCurrent = 0;
  local dmgStun = 0;
  local dmgBlood = 0;
  dmgBlood = Blood_Damage.getValue();
  dmgCurrent = Current_Damage.getValue();
  dmgStun = Stun_Damage.getValue();
  dmgTotal = dmgCurrent + dmgStun + dmgBlood;
  Total_Damage.setValue(dmgTotal);  
end
















