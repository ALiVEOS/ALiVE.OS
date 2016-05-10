#include <\x\alive\addons\sup_command\script_component.hpp>
SCRIPT(SCOMTabletOnAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_SCOMTabletOnAction
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

[MOD(SUP_COMMAND),"tabletOnAction",[_this select 0,_this select 1]] call ALIVE_fnc_SCOM;
