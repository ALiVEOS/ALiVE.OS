#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(doMoveRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_doMoveRemote

Description:
Executes doMove on the units remote location automatically

Parameters:
Object - Given unit
Array - position

Returns:
Nothing

Examples:
[_unit, _pos] call ALiVE_fnc_doMoveRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_unit", objNull, [objNull]],
    ["_pos", [], [[]]]
];

if (!(alive _unit) || {count _pos < 2}) exitwith {diag_log "domoveRemote failed - dead/empty unit"};

//Flag for usage with ALiVE_fnc_unitReadyRemote
_unit setvariable [QGVAR(MOVEDESTINATION),_pos];

if (local _unit) exitwith {
	_unit doMove _pos;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_doMoveRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_doMoveRemote",owner _unit];
};
