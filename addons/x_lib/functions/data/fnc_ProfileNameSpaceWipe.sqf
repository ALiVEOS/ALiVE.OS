#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(ProfileNameSpaceWipe);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceWipe

Description:
Deletes all data for current mission from ProfileNameSpace

Parameters:
none

Returns:
nothing

Examples:
(begin example)
_state = call ALiVE_fnc_ProfileNameSpaceWipe
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceClear

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

_allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];

{
    profileNamespace setVariable [_x,nil];
} foreach _allMissions;

profileNamespace setVariable [QMOD(SAVEDMISSIONS), nil];

saveProfileNamespace