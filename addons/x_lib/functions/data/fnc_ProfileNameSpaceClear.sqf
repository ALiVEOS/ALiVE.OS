#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceClear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceClear

Description:
Deletes all data for current mission from ProfileNameSpace

Parameters:
none

Returns:
nothing

Examples:
(begin example)
_state = call ALiVE_fnc_ProfileNameSpaceClear
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceSave

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

// Who asked for it. The admin menu logs on the machine the admin is sitting
// at, which on a dedicated server is a client, so the server kept no record
// of a destructive wipe at all and whoever runs it had nothing to go on.
// Optional, so an existing caller passing nothing still works. (#1041)
params [["_requestedBy", ""], ["_requestedByUID", ""]];
if (_requestedBy isNotEqualTo "") then {
    ["[ALiVE Data] Clearing this mission's saved data, requested by %1 (UID %2)", _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
} else {
    ["[ALiVE Data] Clearing this mission's saved data"] call ALiVE_fnc_dump;
};

// Storage key includes `worldName` so copies of `mission.sqm` across
// map folders don't collide on the same profileNamespace entry. See
// 4990aaad for the parallel fix in sys_data + sys_player.
private _mission = format["ALiVE_%1_%2",missionName,worldName];

if (count (profileNamespace getVariable [_mission,[]]) == 0) then {
	_mission = [missionName,"%20","-"] call CBA_fnc_replace;
	_mission = format["ALiVE_%1_%2",_mission,worldName];
};

private _missionCompositions = format["%1_compositions",_mission];
private _missionDateTime = format["%1_force_pool",_mission];
private _dictionary = format["dictionary_%1",_mission];
private _missionTasks = format["%1_task",_mission];
private _ato = format["%1_ato",_mission];

private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS),[]];
profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - [_mission]];

profileNamespace setVariable [_missionCompositions, nil];
profileNamespace setVariable [_missionDateTime, nil];
profileNamespace setVariable [_missionTasks, nil];
profileNamespace setVariable [_dictionary, nil];
profileNamespace setVariable [_mission, nil];
profileNamespace setVariable [_ato, nil];

saveProfileNamespace