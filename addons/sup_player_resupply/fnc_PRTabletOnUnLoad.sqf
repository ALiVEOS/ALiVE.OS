#include <\x\alive\addons\sup_player_resupply\script_component.hpp>
SCRIPT(PRTabletOnUnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRTabletOnUnLoad
Description:

On unload of PR tablet interface

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(SUP_PLAYER_RESUPPLY),"tabletOnUnLoad"] call ALIVE_fnc_PR;