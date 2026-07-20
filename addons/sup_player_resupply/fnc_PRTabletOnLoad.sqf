#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(PRTabletOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRTabletOnLoad
Description:

On load of PR tablet interface

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(SUP_PLAYER_RESUPPLY),"tabletOnLoad"] call ALIVE_fnc_PR;

// #698 the tablet opens satellite (config default); reset the terrain-mode flag so the Terrain button starts in step.
uinamespace setVariable ["PRTerrainMode", true];