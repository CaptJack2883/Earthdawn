-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["initroll"] = { bUseModStack = true };
	["recovery"] = {sIcon = "iconHeal", bUseModStack = true };
	["heal"] = {sIcon = "iconHeal", sTargeting = "all", bUseModStack = true };
	["damage"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = true };
	["stun"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = true };
	["effectRoll"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = true };
	["attack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = true };
	["mysticattack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = true };
	["socialattack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = true };
	["spellcasting"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = true };
	["spell"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = true };
  
};

targetactions = {
	"effect",
	"attack",
	"mysticattack",
	"socialattack",
	"spellcasting",
	"spell",
	"effectRoll",
	"damage",
	"stun",
	"heal",
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
