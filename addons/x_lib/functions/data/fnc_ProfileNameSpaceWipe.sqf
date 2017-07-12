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

private _allVariables = +(allvariables profileNamespace);

{
  if ([tolower _x, "alive_"] call CBA_fnc_find != -1) then {profileNamespace setvariable [_x,nil]};
  false
} count _allVariables;

profileNamespace setVariable [QMOD(SAVEDMISSIONS), nil];

saveProfileNamespace