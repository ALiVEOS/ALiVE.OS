#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(pointAt);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_pointAt
Description:
Sets an objects 3d postion to point towards a target object

Parameters:
Object - source
Object - target

Returns:

Examples:
(begin example)
// Create instance
[_unit1, _unit2] call ALIVE_fnc_pointAt;
(end)

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_source", "_target", "_relDirHor", "_relDirVer"];

_source = _this select 0;
_target = _this select 1;

_relDirHor = _source getRelDir _target;
_source setDir _relDirHor;

_relDirVer = asin ((((getPosASL _source) select 2) - ((getPosASL _target) select 2)) / (_target distance _source));
_relDirVer = (_relDirVer * -1);
[_source, _relDirVer, 0] call BIS_fnc_setPitchBank;