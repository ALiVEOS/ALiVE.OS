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

_mission = format["ALiVE_%1",missionName];
_allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS),[]];

profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - _mission];

profileNamespace setVariable [_mission, nil];

saveProfileNamespace