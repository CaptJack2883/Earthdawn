-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
};

targetactions = {
	"effect",
};

currencies = { "Gold", "Silver", "Copper" };
currencyDefault = "Silver";


function onInit()
	ActionsManager.useFGUDiceValues(true);
  languages = { 
    [Interface.getString("language_value_throalic")] = "Throalic",
    [Interface.getString("language_value_sperethiel")] = "Sperethiel",
    [Interface.getString("language_value_human")] = "Human",
    [Interface.getString("language_value_obsidiman")] = "Obsidiman",
    [Interface.getString("language_value_orzet")] = "Or'zet",
    [Interface.getString("language_value_troll")] = "Troll",
    [Interface.getString("language_value_tskrang")] = "T'skrang",
    [Interface.getString("language_value_windling")] = "Windling",
    };
  languagefonts = { "Throalic", "Sperethiel", "Human", "Obsidiman", "Or'zet", "Troll", "T'skrang", "Windling" };
end

function getCharSelectDetailHost(nodeChar)
	return "";
end

function requestCharSelectDetailClient()
	return "name";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails, "";
end

function getCharSelectDetailLocal(nodeLocal)
	return DB.getValue(nodeLocal, "name", ""), "";
end

function getDistanceUnitsPerGrid()
	return 2;
end
