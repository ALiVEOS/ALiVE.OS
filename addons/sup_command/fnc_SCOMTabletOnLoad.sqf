#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMTabletOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMTabletOnLoad
Description:

On load of GM tablet interface

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(SUP_COMMAND),"tabletOnLoad"] call ALIVE_fnc_SCOM;

// #698 the main map opens satellite (config default); reset the terrain-mode flag so the Terrain button starts in step.
uinamespace setVariable ["SCOMTerrainMode", true];