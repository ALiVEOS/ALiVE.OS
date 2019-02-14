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

private _mission = format["ALiVE_%1",missionName];

if (count (profileNamespace getVariable [_mission,[]]) == 0) then {
	_mission = [missionName,"%20","-"] call CBA_fnc_replace;
	_mission = format["ALiVE_%1",_mission];
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