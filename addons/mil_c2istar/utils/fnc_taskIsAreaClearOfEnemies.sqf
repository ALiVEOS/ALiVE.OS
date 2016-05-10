#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskIsAreaClearOfEnemies);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskIsAreaClearOfEnemies

Description:
Is the area clear of enemies

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskPosition","_taskPlayers","_taskSide","_radius","_areaClear","_playersNear","_player","_position",
"_distance","_enemyNear"];

_taskPosition = _this select 0;
_taskPlayers = _this select 1;
_taskSide = _this select 2;
_radius = if(count _this > 3) then {_this select 3} else { 50 };

_areaClear = false;

_playersNear = false;

{
    _player = [_x] call ALIVE_fnc_getPlayerByUID;

    if !(isNull _player) then {
        _position = position _player;
        _distance = _position distance _taskPosition;

        // if any player is near the position

        if(_distance < 1000) exitWith {

            _playersNear = true;
        };
    };

} forEach _taskPlayers;

// there are players near the objective
// check for near enemies including profiles

if(_playersNear) then {

    _enemyNear = [_taskPosition, _taskSide, _radius,true] call ALIVE_fnc_isEnemyNear;

    if!(_enemyNear) then {

        _areaClear = true;

    };

};

_areaClear