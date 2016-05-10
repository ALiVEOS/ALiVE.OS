#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getSideManOrPlayerNear);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getSideManOrPlayerNear

Description:
Get a sides man or player near position in radius

Parameters:
Array - position
Scalar - distance

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [getPos player, 300, _side] call ALIVE_fnc_getSideManOrPlayerNear;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_distance","_targetSide","_probability","_near","_result","_nearPlayer","_nearMan"];

_position = _this select 0;
_distance = _this select 1;
_targetSide = _this select 2;

_probability = 0.5;

_nearMan = [];
_nearPlayer = [];
_result = [];

if(random 1 < _probability) then {

    // try to find a near player
    _nearPlayer = [_position, _distance, _targetSide] call ALIVE_fnc_getSidePlayerNear;

    if(count _nearPlayer > 0) then {
        _result = _nearPlayer;
    }else{
        _result = [_position, _distance, _targetSide] call ALIVE_fnc_getSideManNear;
    };
}else{

    // try to find a near man
    _nearMan = [_position, _distance, _targetSide] call ALIVE_fnc_getSideManNear;

    if(count _nearMan > 0) then {
        _result = _nearMan;
    }else{
        _result = [_position, _distance, _targetSide] call ALIVE_fnc_getSidePlayerNear;
    };
};

_result
