class ctrlButton;

// The Tablet Catalogue button: opens the Build and Supply Catalogue page in the browser, every
// vehicle, crate, soldier and group the tablet can offer with the names the three lists take.
// The same page as the Player FOBs Build List button. Saves nothing.
class Cfg3DEN {
    class Attributes {
        class Default;
        class Title: Default { class Controls { class Title; }; };
        class ALiVE_PRCatalogueLink: Title {
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
                    text = "$STR_ALIVE_PR_CATALOGUE_OPEN";
                    tooltip = "$STR_ALIVE_PR_CATALOGUE_COMMENT";
                    url = "https://www.alivemod.com/public/alive3/sup_fob_buildlist.htm";
                };
            };
        };
        // The Logistics Hub's Catalogue button: the same page, for the hub's own three lists
        class ALiVE_HubListLink: ALiVE_PRCatalogueLink {
            class Controls: Controls {
                class Title: Title {};
                class Link: Link {
                    text = "$STR_ALIVE_HUB_LIST_OPEN";
                    tooltip = "$STR_ALIVE_HUB_LIST_COMMENT";
                };
            };
        };
        // Who Can Collect at a hub, on ALiVE's compact multi-select
        class ALiVE_SideChoiceMulti;
        class ALiVE_HubCollectChoice: ALiVE_SideChoiceMulti {
            attributeLoad = "[_this, _value, 'STR_ALIVE_HUB_COLLECT_WHO', 'SIDE'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_player_resupply\fnc_hubEdenWhoLoad.sqf'";
            attributeSave = "[_this, 'SIDE'] call compile preprocessFileLineNumbers '\x\alive\addons\sup_player_resupply\fnc_hubEdenWhoSave.sqf'";
        };
        // Who Can Dismantle a hub of its own side: the same rows, nothing ticked (admins only)
        class ALiVE_HubDismantleChoice: ALiVE_SideChoiceMulti {
            attributeLoad = "[_this, _value, 'STR_ALIVE_HUB_DISMANTLE_WHO', ''] call compile preprocessFileLineNumbers '\x\alive\addons\sup_player_resupply\fnc_hubEdenWhoLoad.sqf'";
            attributeSave = "[_this, ''] call compile preprocessFileLineNumbers '\x\alive\addons\sup_player_resupply\fnc_hubEdenWhoSave.sqf'";
        };
    };
};
