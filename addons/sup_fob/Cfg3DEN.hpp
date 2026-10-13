// The Player FOBs pickers: one pick per side, on ALiVE's slot picker (ALiVE_FactionSlotChoice)
class Cfg3DEN {
    class Attributes {
        class ALiVE_FactionSlotChoice;
        class ALiVE_FOBHubChoice: ALiVE_FactionSlotChoice {
            attributeLoad = "[_this, 'HUB', _value, '$STR_ALIVE_FOB_HUBS'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenChoiceSave.sqf'";
        };
        class ALiVE_FOBGroupChoice: ALiVE_FactionSlotChoice {
            attributeLoad = "[_this, 'GROUP', _value, '$STR_ALIVE_FOB_GARRISON_GROUPS'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenChoiceSave.sqf'";
        };
    };
};
