#include <\x\alive\addons\x_lib\script_component.hpp>
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
private _missionCompositions = format["ALiVE_%1_compositions",missionName];
private _missionDateTime = format["ALiVE_%1_force_pool",missionName];
private _dictionary = format["dictionary_alive_%1",missionName];
private _missionTasks = format["ALiVE_%1_task",missionName];

private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS),[]];
profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - [_mission]];

profileNamespace setVariable [_missionCompositions, nil];
profileNamespace setVariable [_missionDateTime, nil];
profileNamespace setVariable [_missionTasks, nil];
profileNamespace setVariable [_dictionary, nil];
profileNamespace setVariable [_mission, nil];

saveProfileNamespace