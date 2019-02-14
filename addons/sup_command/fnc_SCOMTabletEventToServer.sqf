#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(SCOMTabletEventToServer);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_SCOMTabletEventToServer
Description:

Transfers event from client instance to server module

Parameters:
Array - event hash

Returns:

See Also:

Author:
ARJay

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(commandHandler),"handleEvent", _this] call ALiVE_fnc_commandHandler;