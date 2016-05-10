#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfileWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileWaypoint

Description:
Creates a waypoint hash for storage in agent profiles

Parameters:
Array - position array
Scalar - the waypoint creation random placement radius
String - type of waypoint
String - speed of waypoint movement
Scalar - completion radius of waypoint
Array - timeout array of scalars [min, mid, max]
String - formation type
String - combat mode
String - behaviour type
String - description
Vehicle - vehicle object

Returns:
A hash of waypoint settings for storage in a profile

Examples:
(begin example)
// simple move waypoint
_result = [getPos player, 100] call ALIVE_fnc_createProfileWaypoint;

// search and destroy waypoint
_result = [getPos player, 100, "SAD"] call ALIVE_fnc_createProfileWaypoint;

// transport unload waypoint with complex parameters
_result = [getPos player, 100, "TR UNLOAD", "FULL", 100] call ALIVE_fnc_createProfileWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_type","_formation","_behaviour","_combatMode","_speed","_completionRadius","_timeout","_description","_attachVehicle","_statements","_waypoint"];
	
_position = _this select 0;
_radius = if(count _this > 1) then {_this select 1} else {0};
_type = if(count _this > 2) then {_this select 2} else {"MOVE"};
_speed = if(count _this > 3) then {_this select 3} else {"UNCHANGED"};
_completionRadius = if(count _this > 4) then {_this select 4} else {-1};
_timeout = if(count _this > 5) then {_this select 5} else {[]};
_formation = if(count _this > 6) then {_this select 6} else {"NO CHANGE"};
_combatMode = if(count _this > 7) then {_this select 7} else {"NO CHANGE"};
_behaviour = if(count _this > 8) then {_this select 8} else {"UNCHANGED"}; // bugged
_description = if(count _this > 9) then {_this select 9} else {""};
_attachVehicle = if(count _this > 10) then {_this select 10} else {""};
_statements = if(count _this > 11) then {_this select 11} else {""};

_waypoint = [] call ALIVE_fnc_hashCreate;
[_waypoint,"position",_position] call ALIVE_fnc_hashSet;
[_waypoint,"radius",_radius] call ALIVE_fnc_hashSet;
[_waypoint,"type",_type] call ALIVE_fnc_hashSet;
[_waypoint,"speed",_speed] call ALIVE_fnc_hashSet;
[_waypoint,"completionRadius",_completionRadius] call ALIVE_fnc_hashSet;
[_waypoint,"timeout",_timeout] call ALIVE_fnc_hashSet;
[_waypoint,"formation",_formation] call ALIVE_fnc_hashSet;
[_waypoint,"combatMode",_combatMode] call ALIVE_fnc_hashSet;
[_waypoint,"behaviour",_behaviour] call ALIVE_fnc_hashSet;
[_waypoint,"description",_description] call ALIVE_fnc_hashSet;
[_waypoint,"attachVehicle",_attachVehicle] call ALIVE_fnc_hashSet;
[_waypoint,"statements",_statements] call ALIVE_fnc_hashSet;

_waypoint