#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(GMTabletOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GMTabletOnLoad
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

[MOD(SUP_GROUP_MANAGER),"tabletOnLoad"] call ALIVE_fnc_GM;

// #698 the group-view maps open satellite (config default); reset the terrain-mode flag so the Terrain button starts in step.
uinamespace setVariable ["GMTerrainMode", true];