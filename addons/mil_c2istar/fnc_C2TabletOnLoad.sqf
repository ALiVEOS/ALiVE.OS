#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(C2TabletOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2TabletOnLoad
Description:

On load of C2 tablet interface

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(MIL_C2ISTAR),"tabletOnLoad"] call ALIVE_fnc_C2ISTAR;

// #698 the tasking map opens satellite (config default); reset the terrain-mode flag so the Terrain button
// starts in step, and clear any stale recorded click handler from a previous open.
uinamespace setVariable ["C2TerrainMode", true];
uinamespace setVariable ["C2Tablet_taskingMapClickHandler", ""];