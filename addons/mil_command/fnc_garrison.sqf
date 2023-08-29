#include "\x\alive\addons\mil_command\script_component.hpp"
SCRIPT(garrison);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrison

Description:
Garrison command for active units, run on spawn of profiles for guarding of objectives via placement modules

Parameters:
Array - Virtual Profile
Number/Array - Radius or [_radius, only Profiles]

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",200]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead, Jman
---------------------------------------------------------------------------- */

private ["_type","_waypoints","_unit","_profile","_active","_args","_pos","_radius","_onlyProfiles","_assignments","_group","_profileType","_profileCount","_guardPatrolPercentage"];

_profile = [_this, 0, ["",[],[],nil], [[]]] call BIS_fnc_param;
_args = [_this, 1, 200, [-1,[]]] call BIS_fnc_param;
// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
 ["ALIVE_fnc_garrison - _args: %1",_args] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------
_radius = _args;
_onlyProfiles = true;
_profileType = "";
_profileCount = 0;
_guardPatrolPercentage = 50;


if (_args isEqualType []) then {
    _radius = [_args, 0, 200, [-1]] call BIS_fnc_param;
    _onlyProfiles = (_args param [1, "false", [""]]) == "true";
    _profileType = _args param [3, ""];
    _profileCount = _args param [4, 0];
    _guardPatrolPercentage = _args param [5, 50];
    // DEBUG -------------------------------------------------------------------------------------
    if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
     ["ALIVE_fnc_garrison - _profileType: %1, _profileCount: %2, _guardPatrolPercentage: %3", _profileType, _profileCount, _guardPatrolPercentage] call ALiVE_fnc_dump;
    };
    // DEBUG -------------------------------------------------------------------------------------
};


if (isnil "_profile") exitWith {};
_id = [_profile,"profileID","error"] call ALiVE_fnc_HashGet;
_pos = [_profile,"position"] call ALiVE_fnc_HashGet;
_type = [_profile,"type",""] call ALiVE_fnc_HashGet;
_waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
_assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;

if (isnil "_pos") exitwith {
    // ["MIL COMMAND Garrison - Detected wrong input for profile %1! Exiting...",_id] call ALiVE_fnc_dump;
};

if (count _waypoints > 0) then {
    // ["MIL COMMAND Garrison - Detected existing waypoints for profile %1! Deleting...",_id] call ALiVE_fnc_dump;
	[_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
};

[_profile,_radius/3] call ALiVE_fnc_ambientMovement;

waituntil {
    sleep 0.5;
    [_profile,"active"] call ALiVE_fnc_HashGet;
};
sleep 0.3;

if (_type == "entity" && {count (_assignments select 1) == 0}) then {

    _group = _profile select 2 select 13;

    if (_profileType == "SPE") then {
    	// DEBUG -------------------------------------------------------------------------------------
    	if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
       ["ALIVE_fnc_garrison - calling ALIVE_fnc_groupGarrisonSPE - _profileType: %1",_profileType] call ALiVE_fnc_dump;
      };
      // DEBUG -------------------------------------------------------------------------------------
     [_group, _pos, _radius, true, _onlyProfiles] call ALIVE_fnc_groupGarrisonSPE;
    } else {
    	// DEBUG -------------------------------------------------------------------------------------
    	if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
       ["ALIVE_fnc_garrison - calling ALIVE_fnc_groupGarrison - _radius: %4,  _profileID: %3, _profileType: %1, _group: %2, _guardPatrolPercentage: %5", _profileType, _group, _id, _radius, _guardPatrolPercentage] call ALiVE_fnc_dump;
      };
      // DEBUG -------------------------------------------------------------------------------------
     [_group, _pos, _radius, true, _onlyProfiles, _profileCount, _id, _guardPatrolPercentage] call ALIVE_fnc_groupGarrison;
    };

};
