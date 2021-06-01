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

function onInit()
	ActionsManager.useFGUDiceValues(true);
  languages = { ["Throalic"] = "Throalic", ["Sperethiel"] = "Sperethiel", ["Human"] = "Human", ["Obsidiman"] = "Obsidiman", ["Or'zet"] = "Or'zet", ["Troll"] = "Troll", ["T'skrang"] = "T'skrang", ["Windling"] = "Windling" };
  languagefonts = { "Throalic", "Sperethiel", "Human", "Obsidiman", "Or'zet", "Troll", "T'skrang", "Windling" };    
end


currencies = { "Gold", "Silver", "Copper" };
currencyDefault = "Silver";

function onInit()
	ActionsManager.useFGUDiceValues(true);
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
