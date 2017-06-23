#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(clientSwitchMove);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clientSwitchMove

Description:
Call switchMove on client

Parameters:
Object - target object to perform switchMove on
String - move to switch to

Returns: Nothing

Examples:
(begin example)
[_agent, "acts_PointingLeftUnarmed"] call ALIVE_fnc_clientSwitchMove
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

(_this select 0) switchMove (_this select 1);