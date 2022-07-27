#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(DeleteGroupRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_DeleteGroupRemote

Description:
Deletes a group on all locations

Parameters:
Group - Given group

Returns:
Nothing

Examples:
_group call ALiVE_fnc_DeleteGroupRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

private _group = _this;

if (isnil "_group") exitWith {
	["Warning: An undefined group (nil) has been passed to ALiVE_fnc_DeleteGroupRemote from %1!", _fnc_scriptNameParent] call ALiVE_fnc_dump;
};

if !(_group isEqualType grpNull) exitWith {
	["Warning: %1 which is not a group but a %2 was sent to ALiVE_fnc_DeleteGroupRemote by %3.", _group, typeName _group, _fnc_scriptNameParent] call ALiVE_fnc_dump;
};

// all is fine, group is not nil and actually a group
if (local _group) then {
    deleteGroup _group;
} else {
    if (isserver) then {
        _group remoteExecCall ["deleteGroup", groupOwner _group];
    } else {
        _group remoteExecCall ["ALiVE_fnc_DeleteGroupRemote", 2]; // groupOwner only works on server
    };
};