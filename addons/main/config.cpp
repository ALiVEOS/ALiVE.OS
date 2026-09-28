#include "script_component.hpp"
#include "CfgMods.hpp"
#include "CfgPatches.hpp"
#include "CfgSettings.hpp"
#include "CfgVehicles.hpp"
#include "CfgFunctions.hpp"
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