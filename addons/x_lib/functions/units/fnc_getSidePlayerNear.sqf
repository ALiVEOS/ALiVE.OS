#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getSidePlayerNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getSidePlayerNear

Description:
Get a sides player near position in radius

Parameters:
Array - position
Scalar - distance

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [getPos player, 300, _side] call ALIVE_fnc_getSidePlayerNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_distance","_near","_result","_player"];

_position = _this select 0;
_distance = _this select 1;
_targetSide = _this select 2;

_near = [];
_result = [];

{

    if(_targetSide == side _x && {_position distance position _x < _distance}) then {
        _near pushback _x;
    }
} forEach allPlayers;

if(count _near > 0) then {
    _player = selectRandom _near;
    _result = [_player];
};

_result