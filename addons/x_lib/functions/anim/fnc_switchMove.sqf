#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(switchMove);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_switchMove

Description:
Call switchMove on proper locality

Parameters:

Object - target object to perform switchMove on
String - move to switch to

Returns:

Examples:
(begin example)
[_agent, "acts_PointingLeftUnarmed"] call ALIVE_fnc_switchMove
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_target","_move"];

_target = _this select 0;
_move = _this select 1;

if((isServer && isMultiplayer) || isDedicated) then
{
    [_target, _move] remoteExec ["ALIVE_fnc_clientSwitchMove"];
}
else
{
    _target switchMove _move;
};