#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetClosestPlayerDistanceToDestination);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetClosestPlayerDistanceToDestination

Description:
Get the closest players distance to the destination position

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskPlayers","_radius","_closest","_player","_position","_distance"];

_taskPosition = _this select 0;
_taskPlayers = _this select 1;

_closest = 10000;

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        _position = position _player;
        _distance = _position distance _taskPosition;

        if(_distance <= _closest) then {
            _closest = _distance;
        };
    };

} forEach _taskPlayers;

_closest