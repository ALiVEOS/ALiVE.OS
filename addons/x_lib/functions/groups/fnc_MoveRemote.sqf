#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(MoveRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_MoveRemote

Description:
Executes Move on a groups remote location automatically

Parameters:
Group - Given group
Array - position

Returns:
Nothing

Examples:
[_group, _pos] call ALiVE_fnc_MoveRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_group", grpNull, [grpNull]],
    ["_pos", [], [[]]]
];

if (!({alive _x} count (units _group) > 0) || {count _pos < 2}) exitwith {diag_log "moveRemote failed - invalid inputs"};

//Flag group with destination
_group setvariable [QGVAR(MOVEDESTINATION),_pos];

if (local _group) exitwith {
	_group move _pos;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExec ["ALiVE_fnc_MoveRemote",2];
} else {
    _this remoteExec ["ALiVE_fnc_MoveRemote",groupOwner _group];
};

