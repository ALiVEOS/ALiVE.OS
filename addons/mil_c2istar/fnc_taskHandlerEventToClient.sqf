#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskHandlerEventToClient);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHandlerEventToClient
Description:

Transfers event from server task handler to client task handler. Needs to run on client!

Parameters:
Array - event hash

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
Highhead
---------------------------------------------------------------------------- */

if (isnil "ALIVE_taskHandlerClient") then {
            // create the client task handler
            ALIVE_taskHandlerClient = [] call ALiVE_fnc_HashCreate;
            [ALIVE_taskHandlerClient, "init"] call ALIVE_fnc_taskHandlerClient;
};

[ALIVE_taskHandlerClient,"handleEvent",_this] call ALIVE_fnc_taskHandlerClient;
