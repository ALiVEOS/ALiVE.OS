#include "script_component.hpp"

#include "CfgPatches.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"

// "Index this terrain" in the editor's top menu, under its own ALiVE heading.
// It sits on the top menu rather than in the right click ALiVE folder because
// the right click menu is rebuilt from config every time it opens, so nothing
// can relabel or grey an entry there while the editor runs. The top menu is
// built once per editor visit, and ALIVE_fnc_indexTerrainMenu (run from
// main/XEH_preInit.sqf) relabels this entry, greys it where it cannot help, and
// points it at the index page with the terrain's Workshop item and name filled
// in. It starts greyed, so if that function never finds it the entry stays
// harmless instead of opening an empty form.
// weblink + opensNewWindow is how the engine's own Help entries open a page.
class ctrlMenuStrip;
class Display3DEN {
    class Controls {
        class MenuStrip: ctrlMenuStrip {
            class Items {
                items[] += {"ALIVE_Strip"};
                class ALIVE_Strip {
                    text = "$STR_ALIVE_INDEX_TERRAIN_MENU";
                    data = "ALIVE_Strip";
                    items[] = {"ALIVE_IndexTerrain"};
                };
                class ALIVE_IndexTerrain {
                    text = "$STR_ALIVE_INDEX_TERRAIN";
                    // What ALIVE_fnc_indexTerrainMenu searches the menu for.
                    data = "ALIVE_IndexTerrain";
                    picture = "\a3\3DEN\Data\Controls\ctrlMenu\link_ca.paa";
                    weblink = "https://www.alivemod.com/public/alive3/index_terrain.htm";
                    opensNewWindow = 1;
                    enable = 0;
                };
            };
        };
    };
};

// The engine quietly ignores a link that is not whitelisted. sys_presets
// whitelists the same site; repeating it keeps this addon working on its own,
// and adding the same entries twice does no harm.
class CfgCommands {
    allowedHTMLLoadURIs[] += {
        "*.alivemod.com",
        "*.alivemod.com/*"
    };
};
