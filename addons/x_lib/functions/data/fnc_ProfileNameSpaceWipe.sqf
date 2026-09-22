#include "\x\alive\addons\x_lib\script_component.hpp"
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

// Who asked for it. The admin menu logs on the machine the admin is sitting
// at, which on a dedicated server is a client, so the server kept no record
// of a destructive wipe at all and whoever runs it had nothing to go on.
// Optional, so an existing caller passing nothing still works. (#1041)
params [["_requestedBy", ""], ["_requestedByUID", ""]];
if (_requestedBy isNotEqualTo "") then {
    ["[ALiVE Data] Clearing ALL ALiVE saved data, requested by %1 (UID %2)", _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
} else {
    ["[ALiVE Data] Clearing ALL ALiVE saved data"] call ALiVE_fnc_dump;
};

private _allVariables = +(allvariables profileNamespace);

{
  if ([tolower _x, "alive_"] call CBA_fnc_find != -1) then {profileNamespace setvariable [_x,nil]};
} foreach _allVariables;

profileNamespace setVariable [QMOD(SAVEDMISSIONS), nil];

saveProfileNamespace