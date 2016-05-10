#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetAnyLinkedInRange);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles

Description:
Check entities and vehicles via vehicle assignment linkages and return if any are within range

Parameters:
Vehicle - The vehicle

Returns:
Array - Hash of profiles linked via vehicle assignments

Examples:
(begin example)
// return a count of vehicles within range
_result = [_vehicle] call ALIVE_fnc_profileGetAnyLinkedInRange;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_spawnDistance","_result","_profiles","_position"];

_profile = _this select 0;
_spawnDistance = _this select 1;

_result = 0;
scopeName "MAIN";

_profiles = [_profile] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles;

{
    _position = getposATL (_x select 2 select 10);
    if(([_position, _spawnDistance] call ALiVE_fnc_anyPlayersInRange > 0) || ([_position, _spawnDistance] call ALiVE_fnc_anyAutonomousInRange > 0)) then {
        _result = _result + 1;
        breakTo "MAIN";
    };
} forEach (_profiles select 2);
//[] call ALIVE_fnc_timer;

_result