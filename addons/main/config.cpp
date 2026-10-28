#include "script_component.hpp"
#include "CfgMods.hpp"
#include "CfgPatches.hpp"
#include "CfgSettings.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"
#include "CfgMarkers.hpp"
#include "Eventhandlers.hpp"
#include "CfgHints.hpp"
#include "Cfg3rdPartyFactions.hpp"
#include "Cfg3rdPartyObjectiveObjects.hpp"
#include "CfgALiVEHumanitarianItems.hpp"
#include "CfgALiVEAmbientAnimals.hpp"
#include "CfgALiVEC2ISTARAccessItems.hpp"
#include "\x\alive\addons\main\data\ui\main.hpp"

// Marker labels on the game's maps. A map control draws marker text in its "font" face,
// bold TahomaB here, where the COP and ALiVE's tablets use RobotoCondensed. Every game map
// that shows markers (main map, briefing, GPS, respawn, UAV terminal, spectator) inherits
// this class without a font of its own, so this reaches them all.
class RscMapControl {
    font = "RobotoCondensed";
};


class ALiVE {
    class Logistics {
        class Sides {

        };
        class Factions {

        };
    };
};

// Game modes picked on the Required module, and the mods each one needs. A mode whose required
// mod isn't loaded doesn't start: the mission ends with a message naming the mod and its Workshop
// id, rather than quietly running as Standard. An optional mod is only noted in the log.
// Each entry: {CfgPatches class, Workshop id, name shown to players, 1 = required / 0 = optional}.
// Classes split by | are alternatives: any one of them loaded is enough.
class CfgALiVEGameModes {
    class standard {
        displayName = "Standard";
        addons[] = {};
    };
    class outbreak {
        displayName = "Outbreak";
        addons[] = {
            {"WBK_ZombieCreatures", "2789152015", "WebKnight's Zombies and Creatures", 1},
            // stable Improved Melee System, or IMS: DEV for WebKnight's DEV zombies
            {"WBK_MeleeMechanics|WBK_IMS_Animations_Executions", "2291129343, or 3510959070 for the DEV zombies", "Improved Melee System (or IMS: DEV)", 1}
        };
    };
};
