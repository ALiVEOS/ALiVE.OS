#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHavePlayersReachedDestination);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHavePlayersReachedDestination

Description:
Have players reached the destination

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskPlayers","_radius","_destinationReached","_player","_position","_distance"];

_taskPosition = _this select 0;
_taskPlayers = _this select 1;
_radius = if(count _this > 2) then {_this select 2} else { 50 };

_destinationReached = false;

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        _position = position _player;
        _distance = _position distance _taskPosition;

        if(_distance <= _radius) exitWith {

            _destinationReached = true;
        };
    };

} forEach _taskPlayers;

_destinationReached