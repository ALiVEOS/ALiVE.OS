#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHandlerEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHandlerEventToClient
Description:

Transfers event from server task handler to client task handler

Parameters:
Array - event hash

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_time"];

//Wait for client to be ready in case event is sent to early including timeout
_time = time; waituntil {!isnil "ALIVE_taskHandlerClient" || {time - _time > 30}};

[ALIVE_taskHandlerClient,"handleEvent",_this] call ALIVE_fnc_taskHandlerClient;
