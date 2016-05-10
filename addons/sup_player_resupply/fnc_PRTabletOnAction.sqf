#include <\x\alive\addons\sup_player_resupply\script_component.hpp>
SCRIPT(PRTabletOnAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRTabletOnAction
Description:

Sets current tablet action

Parameters:

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(SUP_PLAYER_RESUPPLY),"tabletOnAction",[_this select 0,_this select 1]] call ALIVE_fnc_PR;
