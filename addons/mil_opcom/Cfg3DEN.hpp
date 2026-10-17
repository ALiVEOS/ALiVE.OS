// The AI Commander's High Value Target pickers: soldier classes of one side, loaded mods and CDLC
// included, on ALiVE's filtered multi-select; the typed field below adds classes the list doesn't show
class Cfg3DEN {
    class Attributes {
        class ALiVE_FilteredMultiSelect_Base;
        class ALiVE_HVTClassChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'CLASS', _value, '$STR_ALIVE_OPCOM_HVT_CLASS'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_RecruiterClassChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'CLASS', _value, '$STR_ALIVE_OPCOM_RECRUITER_CLASS', 'STR_ALIVE_OPCOM_RECRUITER_CLASS_COMMENT'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_HVTGuardsChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, 'GUARDS', _value, '$STR_ALIVE_OPCOM_HVT_GUARDS'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_InsTypesChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, _value] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_insTypesEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_InsPropsFactoryChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, _value, '$STR_ALIVE_OPCOM_INSPROPS_FACTORY', 'Factory'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_insPropsEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_InsPropsDepotChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, _value, '$STR_ALIVE_OPCOM_INSPROPS_DEPOT', 'Depot'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_insPropsEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_InsPropsHQChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, _value, '$STR_ALIVE_OPCOM_INSPROPS_HQ', 'HQ'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_insPropsEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
        class ALiVE_InsPropsLabChoice: ALiVE_FilteredMultiSelect_Base {
            attributeLoad = "[_this, _value, '$STR_ALIVE_OPCOM_INSPROPS_LAB', 'Lab'] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_insPropsEdenChoiceLoad.sqf'";
            attributeSave = "[_this] call compile preprocessFileLineNumbers '\x\alive\addons\mil_opcom\fnc_hvtEdenChoiceSave.sqf'";
        };
    };
};
