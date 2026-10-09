#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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
Jman
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
            // The vehicle a player came in still counts once they step out to secure the landing zone, while it
            // stays near the pick up point and can still move: only the player sitting in it counted before, so
            // getting out stopped the troops boarding.
            if(_playerVehicle != _player) then {
                _player setVariable ["ALiVE_taskLastVehicle", _playerVehicle];
            } else {
                private _last = _player getVariable ["ALiVE_taskLastVehicle", objNull];
                if (!isNull _last && {alive _last} && {canMove _last} && {(_last distance _taskPosition) <= _radius}) then { _playerVehicle = _last };
            };

            if(_playerVehicle != _player) then {
                if!(_playerVehicle in _vehicles) then {
                    _vehicles pushback _playerVehicle;
                };
            };
        };
    };

} forEach _taskPlayers;

_vehicles
