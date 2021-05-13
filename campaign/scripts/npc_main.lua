-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
  onStatUpdate();
end

function VisDataCleared()
	update();
  onStatUpdate();
end

function InvisDataAdded()
	update();
  onStatUpdate();
end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end
		
	return self[sControl].update(bReadOnly, bForceHide);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID = LibraryData.getIDState("npc", nodeRecord);

	local bSection1 = false;
	if Session.IsHost then
		if updateControl("nonid_name", bReadOnly) then bSection1 = true; end;
	else
		updateControl("nonid_name", bReadOnly, true);
	end
	divider.setVisible(bSection1);
	
	space.setReadOnly(bReadOnly);
	reach.setReadOnly(bReadOnly);
	senses.setReadOnly(bReadOnly);
	movement.setReadOnly(bReadOnly);
	maneuvers.setReadOnly(bReadOnly);
	
	local bSection2 = false;
	if updateControl("skills", bReadOnly) then bSection2 = true; end;
	if updateControl("maneuvers", bReadOnly) then bSection2 = true; end;
	if updateControl("powers", bReadOnly) then bSection2 = true; end;
	if updateControl("items", bReadOnly) then bSection2 = true; end;
	if updateControl("languages", bReadOnly) then bSection = true; end;
	divider2.setVisible(bSection2);
end

function onStatUpdate()
  local strValue = getStatValue(npc_strength.getValue());
  local dexValue = getStatValue(npc_dexterity.getValue());
  local touValue = getStatValue(npc_toughness.getValue());
  local perValue = getStatValue(npc_perception.getValue());
  local wilValue = getStatValue(npc_willpower.getValue());
  local chaValue = getStatValue(npc_charisma.getValue());
  
  --Update with NPC field names.
  defensePhysical.setValue(math.ceil(dexValue/2)+1);
  defenseMystic.setValue(math.ceil(perValue/2)+1);
  defenseSocial.setValue(math.ceil(chaValue/2)+1);
  npc_unconcious.setValue(touValue*2);
  npc_deathRating.setValue(touValue*2+npc_toughness.getValue());
  npc_woundThresh.setValue(math.ceil(touValue/2)+2);  
  armorMystic.setValue(math.floor(wilValue/5));
  initiative.setValue(npc_dexterity.getValue());
  npc_knockdown.setValue(npc_strength.getValue());
  
end

function getStatValue(input)
  local stat = ((input-1)*3)-1;
  return stat;
end





















