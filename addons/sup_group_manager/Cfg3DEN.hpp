// Who Can Manage a rally point (rename or pick up a squad leader's, rename a synced one), on
// ALiVE's compact multi-select, as the Logistics Hub's Who Can lists are
class Cfg3DEN {
    class Attributes {
        class ALiVE_SideChoiceMulti;
        class ALiVE_RallyManageChoice: ALiVE_SideChoiceMulti {
            attributeLoad = "[_this, _value, 'STR_ALIVE_RALLY_MANAGE_WHO', 'OWNER'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_group_manager\fnc_rallyEdenWhoLoad.sqf'";
            attributeSave = "[_this, 'OWNER'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_group_manager\fnc_rallyEdenWhoSave.sqf'";
        };
    };
};
