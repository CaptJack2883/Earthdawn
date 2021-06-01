aRecordOverrides = {
	-- CoreRPG overrides
	
	-- New record types
	
	["races"] = {
		bExport = true, 
		aDataMap = { "races", "reference.racedata" }, 
		aDisplayIcon = { "button_races", "button_races_down" },
		--sRecordDisplayClass = "reference_race", 
    sEditMode = "play",
    sDisplayText = "Races",
    sEmptyNameText = "New Race",
    sListDisplayClass = "masterindexitem_id",
	},
	["racials"] = {
		bExport = true, 
		aDataMap = { "racials", "reference.racialdata" }, 
		aDisplayIcon = { "button_racials", "button_racials_down" },
		--sRecordDisplayClass = "reference_racial", 
    sEditMode = "play",
    sDisplayText = "Racials",
    sEmptyNameText = "New Racial",
    sListDisplayClass = "masterindexitem_id",
	},
  ["talents"] = {
    bExport = true,
    aDataMap = { "talents", "reference.talentdata" },
    aDisplayIcon = { "button_talents", "button_talents_down" },
    --sRecordDisplayClass = "reference_talent",
    sEditMode = "play",
    sDisplayText = "Talents",
    sEmptyNameText = "New Talent",
    sListDisplayClass = "masterindexitem_id",
  },
  ["disciplines"] = {
    bExport = true,
    aDataMap = { "disciplines", "reference.disciplinedata" },
    aDisplayIcon = { "button_disciplines", "button_disciplines_down" },
    --sRecordDisplayClass = "reference_discipline",
    sEditMode = "play",
    sDisplayText = "Disciplines",
    sEmptyNameText = "New Discipline",
    sListDisplayClass = "masterindexitem_id",
  },
	["skills"] = {
		bExport = true, 
		aDataMap = { "skills", "reference.skilldata" }, 
		aDisplayIcon = { "button_skills", "button_skills_down" },
		--sRecordDisplayClass = "reference_skill", 
    sEditMode = "play",
    sDisplayText = "Skills",
    sEmptyNameText = "New Skill",
    sListDisplayClass = "masterindexitem_id",
	},
	["spells"] = {
		bExport = true, 
		aDataMap = { "spells", "reference.spelldata" }, 
		aDisplayIcon = { "button_spells", "button_spells_down" },
		--sRecordDisplayClass = "reference_spell", 
    sEditMode = "play",
    sDisplayText = "Spells",
    sEmptyNameText = "New Spell",
    sListDisplayClass = "masterindexitem_id",
		aCustomFilters = {
			["Source"] = { sField = "source", fGetValue = getSpellSourceValue },
			["Level"] = { sField = "level", sType = "number" };
    },
  },
};

function onInit()
	for kRecordType,vRecordType in pairs(aRecordOverrides) do
		LibraryData.overrideRecordTypeInfo(kRecordType, vRecordType);
	end
end
