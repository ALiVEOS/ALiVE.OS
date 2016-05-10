#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getRandomManNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getRandomManNear

Description:
Get a random man near position in radius

Parameters:
Array - position
Scalar - distance

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [getPos player, 300] call ALIVE_fnc_getRandomManNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_distance","_near","_result","_man"];

_position = _this select 0;
_distance = _this select 1;

_near = [];
_result = [];

{
    if(_position distance position _x < _distance) then {
        _near pushback _x;
    }
} forEach (_position nearObjects ["CAManBase",_distance]);

if(count _near > 0) then {
    _man = selectRandom _near;
    _result = [_man];
};

_result