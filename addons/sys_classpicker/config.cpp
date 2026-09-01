#include "script_component.hpp"

#include "CfgPatches.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"

// Right click a placement module in the editor to put a picked list into its
// Preferred Garrison Buildings.
//
// Its own ALiVE folder at the root of the menu rather than buried in the stock
// Log one, which is for copying things to the clipboard and is the wrong place
// for something that edits the mission. The folder pattern is the one the Biki
// documents: name the folder in the root items list, then give the folder its
// own items list.
//
// value = 0 keeps the folder in the root of the menu. Both the folder and the
// entry carry the module condition, since a module is a logic rather than an
// object, and gating only the entry would leave an empty ALiVE folder showing
// on everything else.
class ctrlMenu;
class display3DEN {
    class ContextMenu: ctrlMenu {
        class Items {
            items[] += {"ALIVE_Menu"};

            class ALIVE_Menu {
                text = "ALiVE";
                value = 0;
                conditionShow = "selectedLogicModule";
                items[] = {"ALIVE_ApplyGarrisonList"};
            };

            class ALIVE_ApplyGarrisonList {
                text = "Apply Picked Garrison List";
                conditionShow = "selectedLogicModule";
                action = "[get3DENSelected 'logic'] call ALIVE_fnc_edenApplyGarrisonList;";
            };
        };
    };
};
