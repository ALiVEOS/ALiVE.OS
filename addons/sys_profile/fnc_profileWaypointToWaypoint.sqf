#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileWaypointToWaypoint);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointToWaypoint

Description:
Takes a profile waypoint and creates a real waypoint

Parameters:
Hash - profile waypoint
Group - The group

Returns:
A waypoint

Examples:
(begin example)
_result = [_profileWaypoint, _group] call ALIVE_fnc_profileWaypointToWaypoint;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profileWaypoint", "_group","_setCurrent","_position","_radius","_type","_formation","_behaviour","_combatMode","_speed","_completionRadius","_timeout","_description","_attachVehicle","_attachObject","_waypointStatements","_waypoint"];
	
_profileWaypoint = _this select 0;
_group = _this select 1;
_setCurrent = if(count _this > 2) then {_this select 2} else {false};

if (isnil "_profileWaypoint" || {!(typeName _profileWaypoint == "ARRAY")}) exitwith {["ALiVE - ALiVE_fnc_ProfileWaypointToWaypoint retrieved wrong input: %1!",_this] call ALiVE_fnc_Dump};

_position = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;
_radius = [_profileWaypoint,"radius"] call ALIVE_fnc_hashGet;
_type = [_profileWaypoint,"type"] call ALIVE_fnc_hashGet;
_speed = [_profileWaypoint,"speed"] call ALIVE_fnc_hashGet;
_completionRadius = [_profileWaypoint,"completionRadius"] call ALIVE_fnc_hashGet;
_timeout = [_profileWaypoint,"timeout"] call ALIVE_fnc_hashGet;
_formation = [_profileWaypoint,"formation"] call ALIVE_fnc_hashGet;
_combatMode = [_profileWaypoint,"combatMode"] call ALIVE_fnc_hashGet;
_behaviour = [_profileWaypoint,"behaviour"] call ALIVE_fnc_hashGet;
_description = [_profileWaypoint,"description"] call ALIVE_fnc_hashGet;
_attachVehicle = [_profileWaypoint,"attachVehicle"] call ALIVE_fnc_hashGet;
_waypointStatements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;

_position set [2,0];

_waypoint = _group addWaypoint [_position, _radius];
_waypoint setWaypointDescription _description;
_waypoint setWaypointType _type;
_waypoint setWaypointFormation _formation;
_waypoint setWaypointBehaviour _behaviour;
_waypoint setWaypointCombatMode _combatMode;
_waypoint setWaypointSpeed _speed;

if (_completionRadius >= 0) then
{
	_waypoint setWaypointCompletionRadius _completionRadius;
};

if ((count _timeout) == 3) then
{
	_waypoint setWaypointTimeout _timeout;
};

if !(_attachVehicle == "") then
{
	_waypoint waypointAttachVehicle _attachVehicle;
};

if (typeName _waypointStatements == "ARRAY") then
{
	_waypoint setWaypointStatements _waypointStatements;
};

if(_setCurrent) then {
	_group setCurrentWaypoint _waypoint;
};

//["p wp to wp"] call ALIVE_fnc_dump;
//_profileWaypoint call ALIVE_fnc_inspectHash;

_waypoint