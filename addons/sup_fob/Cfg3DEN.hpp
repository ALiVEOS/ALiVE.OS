class ctrlButton;

// The Player FOBs pickers: one pick per side, on ALiVE's slot picker (ALiVE_FactionSlotChoice),
// and who may take a FOB down, on ALiVE's compact multi-select (ALiVE_SideChoiceMulti)
class Cfg3DEN {
    class Attributes {
        // A button that opens the FOB Build List page in the browser: every object players can build, with
        // its class name and cost, which are the names Never Build and Also Build take. Saves nothing.
        class Default;
        class Title: Default { class Controls { class Title; }; };
        class ALiVE_FOBBuildListLink: Title {
            attributeLoad = "";
            attributeSave = "''";
            class Controls: Controls {
                class Title: Title {};
                class Link: ctrlButton {
                    idc = 310;
                    x = "48 * (pixelW * pixelGrid * 0.50)";
                    y = "0.5 * (pixelH * pixelGrid * 0.50)";
                    w = "82 * (pixelW * pixelGrid * 0.50)";
                    h = "4 * (pixelH * pixelGrid * 0.50)";
                    text = "$STR_ALIVE_FOB_BUILDLIST_OPEN";
                    tooltip = "$STR_ALIVE_FOB_BUILDLIST_COMMENT";
                    url = "https://www.alivemod.com/public/alive3/sup_fob_buildlist.htm?for=fob";
                };
            };
        };
        // The same for the FOB Types editor, which makes the FOB Types module's list
        class ALiVE_FOBTypesLink: ALiVE_FOBBuildListLink {
            class Controls: Controls {
                class Title: Title {};
                class Link: Link {
                    text = "$STR_ALIVE_FOB_TYPES_OPEN";
                    tooltip = "$STR_ALIVE_FOB_TYPES_OPEN_COMMENT";
                    url = "https://www.alivemod.com/public/alive3/sup_fob_types.htm";
                };
            };
        };
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
