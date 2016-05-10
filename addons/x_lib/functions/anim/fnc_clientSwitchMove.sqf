#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(clientSwitchMove);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_clientSwitchMove

Description:
Call switchMove on client

Parameters:
Object - target object to perform switchMove on
String - move to switch to

Returns:

Examples:
(begin example)
[_agent, "acts_PointingLeftUnarmed"] call ALIVE_fnc_clientSwitchMove
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_target","_move"];

_target = _this select 0;
_move = _this select 1;

_target switchMove _move;