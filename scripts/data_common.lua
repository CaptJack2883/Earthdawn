-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

rsname = "ED4E";
rsversion = 1;

-- Abilities (database names)
abilities = {
	"dexterity",
	"strength",
	"toughness",
	"perception",
	"willpower",
	"charisma"
};

ability_ltos = {
	["dexterity"] = "DEX",
	["strength"] = "STR",
	["toughness"] = "TOU",
	["perception"] = "PER",
	["willpower"] = "WIL",
	["charisma"] = "CHA"
};

ability_stol = {
	["STR"] = "strength",
	["DEX"] = "dexterity",
	["TOU"] = "toughness",
	["PER"] = "perception",
	["WIL"] = "willpower",
	["CHA"] = "charisma"
};

-- Values for wound comparison
healthstatushalf = "bloodied";
healthstatuswounded = "wounded";


-- Values supported in effect conditionals
conditionaltags = {
};

-- Conditions supported in effect conditionals and for token widgets
-- TODO - Added :1 of :XX to indicate that the condition has a numerical value.  How does this effect code that runs off this for conditions icons and widgets?
conditions = {
	"astral sight",
	"blinded",
	"blindsided",
	"cover, full",
	"cover, partial",
	"darkness, full",
	"darkness, partial",
	"darkvision",
	"dazzled",
	"dead",
	"grappled",
	"harried",
	"heat sight",
	"low-light vision",
	"knocked down",
	"range, long",
	"slowed, heavy",
	"slowed, light",
	"overwhelmed",
	"prone",
	"surprised",
	"unconscious",
};

-- Bonus/penalty effect types for token widgets
bonuscomps = {
	"ABIL",
	"ACTN",
	"ATK",
	"DEF",
	"DMG",
	"DMGS",
	"HEAL",
	"INIT",
	"SKILL",
	"TALENT",
	"STR",
	"TOU",
	"DEX",
	"PER",
	"WIL",
	"CHA",
};

-- Condition effect types for token widgets
-- Code for PFRPG2
condcomps = {
	["blinded"] = "cond_blinded",
	["blindsided"] = "cond_blindsided",
	["coverfull"] = "cond_conceal",
	["coverpartial"] = "cond_conceal",
	["darknessfull"] = "cond_blinded",
	["darknesspartial"] = "cond_blinded",
	["dazzled"] = "cond_dazzled",
	["dead"] = "cond_dead",
	["grappled"] = "cond_grappled",
	["harried"] = "cond_flatfooted",
	["knockeddown"] = "cond_prone",
	["longrange"] = "cond_longrange",
	["impairedmoveheavy"] = "cond_slowed",
	["impairedmovelight"] = "cond_slowed",
	["overwhelmed"] = "cond_flatfooted",
	["prone"] = "cond_prone",
	["surprised"] = "cond_surprised",
	["unconscious"] = "cond_unconscious"
};

-- Other visible effect types for token widgets
othercomps = {
	["FCOVER"] = "cond_cover",
	["PCOVER"] = "cond_cover",
	["IMMUNE"] = "cond_immune",
	["RESIST"] = "cond_resist",
	["VULN"] = "cond_vuln",
	["REGEN"] = "cond_regen",
	["FHEAL"] = "cond_fheal",
	["DMGO"] = "cond_ongoing",
	["PERS"] = "cond_ongoing"
};

-- Effect components which can be targeted
targetableeffectcomps = {
	"ACTN",
	"ATK",
	"FCOVER",
	"PCOVER",
	"DEF",
	"DMG",
	"HIDDEN",
	"IMMUNE",
	"VULN",
	"RESIST"
};

connectors = {
	"and",
	"or"
};

-- Range types supported
rangetypes = {
	"melee",
	"ranged"
};

-- Damage types supported
energytypes = {
	"air",  		-- ENERGY DAMAGE TYPES
	"cold",  		
	"electricity",
	"fire",
	"water",
	"wood",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative"
};

-- Immunity types supported
immunetypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"water",
	"wood",
	"stun",	-- SPECIAL DAMAGE TYPES
	"poison",		-- OTHER IMMUNITY TYPES
	"sleep",
	"charm",
	"fear",
	"disease",
	"mind-affecting",
	"confused",
	"death",	-- Covers "death" and "death effects"
	"visual",
	"magic",
	"nonmagical",	-- Covers nonmagical attacks.
	"bleed",
	"polymorph",
	"precision",
	"possession",
	"unconscious"
};

dmgtypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"water",
	"wood",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative",
	"bludgeoning", 	-- WEAPON PROPERTY DAMAGE TYPES
	"magic",
	"piercing",
	"silver",
	"slashing",
	"stun",	-- MISC DAMAGE TYPE
	"spell",
	"critical",
	"precision",
	"poison",
	"mental", 
	"area",
	"splash",
	"bleed",
	"ghost touch",	-- This is needed for avoiding incorporeal resistances.  Is there a better way to do this?
	"physical",
	"nonmagical",
	"persistent"	-- Added to allow matching of persistent damage in attack/damage string.  ActionDamage then handles this differently.
};

checkresultlevels = {
	"critical-success",
	"success",
	"failure",
};

resultlevelsstringtonumerical = {
	["critical-success"] = 2,
	["success"] = 1,
	["failure"] = 0,
};

resultlevelsnumericaltostring = {
	[0] = "FAILURE",
	[1] = "SUCCESS",
	[2] = "CRITICAL SUCCESS",
};
