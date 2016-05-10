#include <\x\alive\addons\sup_player_resupply\script_component.hpp>
SCRIPT(PRTabletEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PRTabletEventToClient
Description:

Transfers event from server module to client instance

Parameters:
Array - event hash

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(SUP_PLAYER_RESUPPLY),"handleLOGCOMResponse",_this] call ALIVE_fnc_PR;
