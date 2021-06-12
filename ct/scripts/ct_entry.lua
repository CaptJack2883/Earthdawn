-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- Register the deletion menu item for the host
	registerMenuItem(Interface.getString("list_menu_deleteitem"), "delete", 6);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);

	-- Set the displays to what should be shown
	setTargetingVisible();
	setSpacingVisible();
	setEffectsVisible();
	setDefensiveVisible();
  
	-- Acquire token reference, if any
	linkToken();
	
	-- Update the displays
	onLinkChanged();
	onFactionChanged();
end

function updateDisplay()
	local sFaction = friendfoe.getStringValue();

	if DB.getValue(getDatabaseNode(), "active", 0) == 1 then
		name.setFont("sheetlabel");
		nonid_name.setFont("sheetlabel");
		
		active_spacer_top.setVisible(true);
		active_spacer_bottom.setVisible(true);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend_active");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral_active");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe_active");
		else
			setFrame("ctentrybox_active");
		end
	else
		name.setFont("sheettext");
		nonid_name.setFont("sheettext");
		
		active_spacer_top.setVisible(false);
		active_spacer_bottom.setVisible(false);
		
		if sFaction == "friend" then
			setFrame("ctentrybox_friend");
		elseif sFaction == "neutral" then
			setFrame("ctentrybox_neutral");
		elseif sFaction == "foe" then
			setFrame("ctentrybox_foe");
		else
			setFrame("ctentrybox");
		end
	end
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onMenuSelection(selection, subselection)
	if selection == 6 and subselection == 7 then
		delete();
	end
end

function delete()
	local node = getDatabaseNode();
	if not node then
		close();
		return;
	end
	
	-- Remember node name
	local sNode = node.getPath();
	
	-- Clear any effects and wounds first, so that rolls aren't triggered when initiative advanced
	effects.reset(false);
	
	-- Move to the next actor, if this CT entry is active
	if DB.getValue(node, "active", 0) == 1 then
		CombatManager.nextActor();
	end

	-- Delete the database node and close the window
	local cList = windowlist;
	node.delete();

	-- Update list information (global subsection toggles)
	cList.onVisibilityToggle();
	cList.onEntrySectionToggle();
end

function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
	onIDChanged();
end

function onIDChanged()
	local nodeRecord = getDatabaseNode();
	local sClass = DB.getValue(nodeRecord, "link", "", "");
	if sClass == "npc" then
		local bID = LibraryData.getIDState("npc", nodeRecord, true);
		name.setVisible(bID);
		nonid_name.setVisible(not bID);
		isidentified.setVisible(true);
    --This works for NPCs, but NPC needs to be initialized?
    linkNPCFields(); 
	else
		name.setVisible(true);
		nonid_name.setVisible(false);
		isidentified.setVisible(false);
    --linkNPCFields(); This breaks PCs.
	end
end

function onFactionChanged()
	-- Update the entry frame
	updateDisplay();

	-- If not a friend, then show visibility toggle
	if friendfoe.getStringValue() == "friend" then
		tokenvis.setVisible(false);
	else
		tokenvis.setVisible(true);
	end
end

function onVisibilityChanged()
	TokenManager.updateVisibility(getDatabaseNode());
	windowlist.onVisibilityToggle();
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		senses.setLink(nodeChar.createChild("senses", "string"), true);
    deathrating.setLink(nodeChar.createChild("health.death.value", "number"), true);
    unconrating.setLink(nodeChar.createChild("health.uncon.value", "number"), true);
    threshold.setLink(nodeChar.createChild("health.wound.threshold", "number"), true);
    damage.setLink(nodeChar.createChild("health.damage.total", "number"));
    wounds.setLink(nodeChar.createChild("health.wounds.value", "number"));
    phys_def.setLink(nodeChar.createChild("defenses.physical.value", "number"), true);
    myst_def.setLink(nodeChar.createChild("defenses.mystic.value", "number"), true);
    social_def.setLink(nodeChar.createChild("defenses.social.value", "number"), true);
	end
end

function linkNPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
    --nodeChar.npc_main.onInit();
		senses.setLink(nodeChar.createChild("senses", "string"), true);
    deathrating.setLink(nodeChar.createChild("health.death.value", "number"), true);
    unconrating.setLink(nodeChar.createChild("health.uncon.value", "number"), true);
    threshold.setLink(nodeChar.createChild("health.wound.threshold", "number"), true);
    damage.setLink(nodeChar.createChild("health.damage.value", "number"));
    wounds.setLink(nodeChar.createChild("health.wounds.value", "number"));
    phys_def.setLink(nodeChar.createChild("defenses.physical.value", "number"), true);
    myst_def.setLink(nodeChar.createChild("defenses.mystic.value", "number"), true);
    social_def.setLink(nodeChar.createChild("defenses.social.value", "number"), true);
	end
end
--
-- SECTION VISIBILITY FUNCTIONS
--

function setTargetingVisible()
	local v = false;
	if activatetargeting.getValue() == 1 then
		v = true;
	end

	targetingicon.setVisible(v);
	
	sub_targeting.setVisible(v);
	
	frame_targeting.setVisible(v);

	target_summary.onTargetsChanged();
end

function setSpacingVisible()
	local v = false;
	if activatespacing.getValue() == 1 then
		v = true;
	end

	spacingicon.setVisible(v);
	
	space.setVisible(v);
	spacelabel.setVisible(v);
	reach.setVisible(v);
	reachlabel.setVisible(v);
	
	frame_spacing.setVisible(v);
end

function setEffectsVisible()
	local v = false;
	if activateeffects.getValue() == 1 then
		v = true;
	end
	
	effecticon.setVisible(v);
	
	effects.setVisible(v);
	effects_iadd.setVisible(v);
	for _,w in pairs(effects.getWindows()) do
		w.idelete.setValue(0);
	end

	frame_effects.setVisible(v);

	effect_summary.onEffectsChanged();
end

function setDefensiveVisible()
	local v = false;
	if activatedefensive.getValue() == 1 then
		v = true;
	end
	defensiveicon.setVisible(v);
	phys_def.setVisible(v);
	phys_def_label.setVisible(v);
	myst_def.setVisible(v);
	myst_def_label.setVisible(v);
	social_def.setVisible(v);
	social_def_label.setVisible(v);
	specialqualities.setVisible(v);
	specialqualitieslabel.setVisible(v);
	frame_defensive.setVisible(v);
	
  
end









