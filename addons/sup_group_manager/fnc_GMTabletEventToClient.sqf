#include <\x\alive\addons\sup_group_manager\script_component.hpp>
SCRIPT(GMTabletEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_GMTabletEventToClient
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

[MOD(SUP_GROUP_MANAGER),"handleServerResponse",_this] call ALIVE_fnc_GM;
