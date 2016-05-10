#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(waypointsToProfileWaypoints);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_waypointsToProfileWaypoints

Description:
Takes real waypoints and creates profile waypoints

Parameters:
Array - The waypoints

Returns:

Examples:
(begin example)
_result = [_profile, _group] call ALIVE_fnc_waypointsToProfileWaypoints;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_group","_isCycling","_waypoints","_statements","_profileWaypoint","_profilePosition"];

_profile = _this select 0;
_group = _this select 1;
if (isnil "_profile" || isnil "_group") exitwith {["ALiVE SYS PROFILE Warning: ALIVE_fnc_waypointsToProfileWaypoints has wrong inputs!"] call ALiVE_fnc_Dump};

_isCycling = _profile select 2 select 25;

_waypoints = waypoints _group;
if !(count _waypoints > 0) exitwith {["ALiVE SYS PROFILE Warning: ALIVE_fnc_waypointsToProfileWaypoints has wrong inputs!"] call ALiVE_fnc_Dump};

if(_isCycling) then {
	// if the entity has a cycle waypoint need to get all completed waypoints and 
	// stick them in the end of the waypoints array
	
	for "_i" from (currentWaypoint _group) to (count _waypoints)-1 do
	{
		_profileWaypoint = [(_waypoints select _i)] call ALIVE_fnc_waypointToProfileWaypoint;
		_profilePosition = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;

		_statements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;

		/*
        ["STAMENTS :%1",_statements select 1] call ALIVE_fnc_dump;
        if(_statements select 1 == "_disableSimulation = true;") then {
            ["SIM DISABLED: TRUE"] call ALIVE_fnc_dump;
        }else{
            ["SIM DISABLED: FALSE"] call ALIVE_fnc_dump;
        };
        */

		if(_profilePosition select 0 > 0 && _profilePosition select 1 > 0 && {(_statements select 1 != "_disableSimulation = true;")}) then {
			[_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
		};
	};
	
	for "_i" from 1 to (currentWaypoint _group)-1 do {
		_profileWaypoint = [(_waypoints select _i)] call ALIVE_fnc_waypointToProfileWaypoint;
		_profilePosition = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;

		_statements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;

        /*
        ["STAMENTS :%1",_statements select 1] call ALIVE_fnc_dump;
        if(_statements select 1 == "_disableSimulation = true;") then {
            ["SIM DISABLED: TRUE"] call ALIVE_fnc_dump;
        }else{
            ["SIM DISABLED: FALSE"] call ALIVE_fnc_dump;
        };
        */

		if(_profilePosition select 0 > 0 && _profilePosition select 1 > 0 && {(_statements select 1 != "_disableSimulation = true;")}) then {
			[_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
		};
	};
	
} else {

	// convert any non completed waypoints to profile waypoints
	if(currentWaypoint _group < count waypoints _group) then {
		for "_i" from (currentWaypoint _group) to (count _waypoints)-1 do
		{
			_profileWaypoint = [(_waypoints select _i)] call ALIVE_fnc_waypointToProfileWaypoint;
			_profilePosition = [_profileWaypoint,"position"] call ALIVE_fnc_hashGet;

			_statements = [_profileWaypoint,"statements"] call ALIVE_fnc_hashGet;

            /*
            ["STAMENTS :%1",_statements select 1] call ALIVE_fnc_dump;
            if(_statements select 1 == "_disableSimulation = true;") then {
                ["SIM DISABLED: TRUE"] call ALIVE_fnc_dump;
            }else{
                ["SIM DISABLED: FALSE"] call ALIVE_fnc_dump;
            };
            */

			if(_profilePosition select 0 > 0 && _profilePosition select 1 > 0 && {(_statements select 1 != "_disableSimulation = true;")}) then {
				[_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
			};
		};
	};
};