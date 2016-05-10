#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskSpawnOnTopOf);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskSpawnOnTopOf

Description:
Spawn an object on top of another object

Parameters:

Returns:

Examples:
(begin example)

[table,"Land_SatellitePhone_F"] call ALIVE_fnc_taskSpawnOnTopOf;

(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_target", "_objectClass","_objects"];

_target = _this select 0;
_objectClass = _this select 1;

_objects = [[_target,"TOP"],_objectClass,1,[(random 1)-0.1,(random 1)-0.1,0],(random 20)-10,{0},true] call BIS_fnc_spawnObjects;

_objects