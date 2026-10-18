#include "script_component.hpp"

#include "CfgPatches.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"
#include "Cfg3DEN.hpp"

#include "\x\alive\addons\sup_fob\data\ui\fobBuild.hpp"
#include "\x\alive\addons\sup_fob\data\ui\fobManage.hpp"

// The FOB Build List page from the ALiVE menu at the top of the editor, after the preset entries.
// weblink + opensNewWindow is how the engine's own Help entries open a page.
class ctrlMenuStrip;
class Display3DEN {
    class Controls {
        class MenuStrip: ctrlMenuStrip {
            class Items {
                class ALIVE_Strip {
                    items[] += {"Separator", "ALIVE_StripFOBBuildList"};
                };
                class ALIVE_StripFOBBuildList {
                    text = "$STR_ALIVE_FOB_BUILDLIST_MENU";
                    picture = "\a3\3DEN\Data\Controls\ctrlMenu\link_ca.paa";
                    weblink = "https://www.alivemod.com/public/alive3/sup_fob_buildlist.htm";
                    opensNewWindow = 1;
                };
            };
        };
    };
};
