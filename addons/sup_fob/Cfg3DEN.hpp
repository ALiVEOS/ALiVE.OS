// The Player FOBs pickers: one pick per side, on ALiVE's slot picker (ALiVE_FactionSlotChoice),
// and who may take a FOB down, on ALiVE's compact multi-select (ALiVE_SideChoiceMulti)
class Cfg3DEN {
    class Attributes {
        class ALiVE_FactionSlotChoice;
        class ALiVE_SideChoiceMulti;
        class ALiVE_FOBManageChoice: ALiVE_SideChoiceMulti {
            attributeLoad = "[_this, _value] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenManageLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\sup_fob\fnc_fobEdenManageSave.sqf'";
        };
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
