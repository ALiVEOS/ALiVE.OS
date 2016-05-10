#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetNearPlayerVehicles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetNearPlayerVehicles

Description:
Find any player vehicles nearby

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskPlayers","_radius","_vehicles","_destinationReached","_player","_position","_distance","_playerVehicle"];

_taskPosition = _this select 0;
_taskPlayers = _this select 1;
_radius = if(count _this > 2) then {_this select 2} else { 50 };

_vehicles = [];

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        _position = position _player;
        _distance = _position distance _taskPosition;

        if(_distance <= _radius) then {

            _playerVehicle = vehicle _player;

            if(_playerVehicle != _player) then {
                if!(_playerVehicle in _vehicles) then {
                    _vehicles set [count _vehicles, _playerVehicle];
                };
            };
        };
    };

} forEach _taskPlayers;

_vehicles