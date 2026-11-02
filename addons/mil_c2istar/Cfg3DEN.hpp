// The COP Display Sides picker: ALiVE's compact side multi-select (ALiVE_SideChoiceMulti), pointed at
// copDisplaySides. Eden runs a control's own attributeLoad / attributeSave, not ones set on the attribute,
// so the picker needs its own control class or it reads and writes opcomIntelSides under that row's title.
class Cfg3DEN {
    class Attributes {
        class ALiVE_SideChoiceMulti;
        class ALiVE_C2ISTARCopSidesChoice: ALiVE_SideChoiceMulti {
            attributeLoad = "[_this, 'copDisplaySides', '$STR_ALIVE_C2ISTAR_COP_DISPLAY_SIDES', _value] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenSideChoiceMultiLoad.sqf'";
            attributeSave = "[_this, 'copDisplaySides'] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenSideChoiceMultiSave.sqf'";
        };
    };
};
