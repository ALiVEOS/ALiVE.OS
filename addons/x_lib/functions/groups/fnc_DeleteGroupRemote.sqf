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

if (local _group) then {
    deleteGroup _group;
} else {
    if (isserver) then {
        _group remoteExecCall ["deleteGroup", groupOwner _group];
    } else {
        _group remoteExecCall ["ALiVE_fnc_DeleteGroupRemote", 2]; // groupOwner only works on server
    };
};