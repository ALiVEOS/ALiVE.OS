#include <\x\alive\addons\mil_command\script_component.hpp>
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
Highhead
---------------------------------------------------------------------------- */

private ["_type","_waypoints","_unit","_profile","_args","_pos","_radius","_onlyProfiles","_assignments","_group"];

_profile = [_this, 0, ["",[],[],nil], [[]]] call BIS_fnc_param;
_args = [_this, 1, 200, [-1,[]]] call BIS_fnc_param;

_radius = _args;
_onlyProfiles = false;

if (typeName _args == "ARRAY") then {
    _radius = [_args, 0, 200, [-1]] call BIS_fnc_param;
    _onlyProfiles = call compile ([_args, 1, "false", [""]] call BIS_fnc_param);
};

_pos = [_profile,"position"] call ALiVE_fnc_HashGet;
_type = [_profile,"type",""] call ALiVE_fnc_HashGet;
_waypoints = [_profile,"waypoints",[]] call ALiVE_fnc_HashGet;
_assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;

if (isnil "_pos" || {count _waypoints > 0}) exitwith {};

[_profile,_radius/3] call ALiVE_fnc_ambientMovement;

waituntil {sleep 0.5; [_profile,"active"] call ALiVE_fnc_HashGet};
sleep 0.3;

if (_type == "entity" && {count (_assignments select 1) == 0}) then {

    _group = _profile select 2 select 13;

    [_group,_pos,_radius,true,_onlyProfiles] call ALIVE_fnc_groupGarrison;

};