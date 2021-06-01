-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if Session.IsHost then
		registerMenuItem(Interface.getString("ct_menu_initmenu"), "turn", 7);
		registerMenuItem(Interface.getString("ct_menu_initRollAll"), "rollAll", 7, 2);
		registerMenuItem(Interface.getString("ct_menu_initreset"), "pointer_circle", 7, 4);
		registerMenuItem(Interface.getString("ct_menu_initRollNPCs"), "rollNPCs", 7, 6);
		registerMenuItem(Interface.getString("ct_menu_initRollPCs"), "rollPCs", 7, 8);

		registerMenuItem(Interface.getString("ct_menu_restmenu"), "rest", 5);
		registerMenuItem(Interface.getString("ct_menu_restShort"), "restShort", 5, 3);
		registerMenuItem(Interface.getString("ct_menu_restOvernight"), "restOvernight", 5, 5);
    
		registerMenuItem(Interface.getString("ct_menu_itemdelete"), "delete", 3);
		registerMenuItem(Interface.getString("ct_menu_itemdeletenonfriendly"), "delete", 3, 1);
		registerMenuItem(Interface.getString("ct_menu_itemdeletefoe"), "delete", 3, 3);
	end
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if button == 1 then
		Interface.openRadialMenu();
		return true;
	end
end

function onMenuSelection(selection, subselection, subsubselection)
	if Session.IsHost then
		if selection == 7 then
			if subselection == 4 then
				CombatManager.resetInit();
			elseif subselection == 2 then
        CombatManagerED4.rollAllInit();
      elseif subselection == 6 then
        CombatManagerED4.rollNPCInit();
      elseif subselection == 8 then
        CombatManagerED4.rollPCInit();
      end
		elseif selection == 3 then
			if subselection == 1 then
				clearNPCs();
			elseif subselection == 3 then
				clearNPCs(true);
			end
		elseif selection == 5 then
			if subselection == 3 then
        CombatManagerED4.ctRestShort();
      elseif subselection == 5 then
        CombatManagerED4.ctRestOvernight();
      end
    end
	end
end

function clearNPCs(bDeleteOnlyFoe)
	for _, vChild in pairs(window.list.getWindows()) do
		local sFaction = vChild.friendfoe.getStringValue();
		if bDeleteOnlyFoe then
			if sFaction == "foe" then
				vChild.delete();
			end
		else
			if sFaction ~= "friend" then
				vChild.delete();
			end
		end
	end
end
