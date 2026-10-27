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
    };
};
