#include <\x\alive\addons\sup_command\script_component.hpp>
SCRIPT(SCOMTabletEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMTabletEventToClient
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

[MOD(SUP_COMMAND),"handleServerResponse",_this] call ALIVE_fnc_SCOM;
