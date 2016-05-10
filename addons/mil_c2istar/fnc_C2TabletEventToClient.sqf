#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(C2TabletEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_C2TabletEventToClient
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

[MOD(MIL_C2ISTAR),"handleServerResponse",_this] call ALIVE_fnc_C2ISTAR;
