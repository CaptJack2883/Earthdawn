-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = false },
	["stepRoll"] = { bUseModStack = false },
	["karma"] = { bUseModStack = false },
	["dexterity"] = { bUseModStack = false },
	["strength"] = { bUseModStack = false },
	["toughness"] = { bUseModStack = false },
	["perception"] = { bUseModStack = false },
	["willpower"] = { bUseModStack = false },
	["charisma"] = { bUseModStack = false },
	["talent"] = { bUseModStack = false },
	["skill"] = { bUseModStack = false },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["initroll"] = { bUseModStack = false };
	["recovery"] = {sIcon = "iconHeal", bUseModStack = false };
	["heal"] = {sIcon = "iconHeal", sTargeting = "all", bUseModStack = false };
	["damage"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = false };
	["mysticdamage"] = { bUseModStack = false },
	["stun"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = false };
	["knockdown"] = { bUseModStack = false },
	["effectRoll"] = {sIcon = "iconDamage", sTargeting = "all", bUseModStack = false };
	["attack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = false };
	["mysticattack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = false };
	["socialattack"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = false };
	["spellcasting"] = {sIcon = "iconAttack", bUseModStack = false };
	["spell"] = {sIcon = "iconAttack", sTargeting = "each", bUseModStack = false };
	["threadweaving"] = { bUseModStack = false },
  
};

targetactions = {
	"effect",
	"attack",
	"mysticattack",
	"socialattack",
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
