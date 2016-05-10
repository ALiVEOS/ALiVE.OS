#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(landAtRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_landAtRemote

Description:
Executes landAt on the units remote location automatically

Parameters:
Object - Given unit
Array - position

Returns:
Nothing

Examples:
[_unit, _pos] call ALiVE_fnc_landAtRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_unit", objNull, [objNull]],
    ["_args", 1, [-1]]
];

if !(alive _unit) exitwith {diag_log "landAtRemote failed - dead/empty unit"};

//Flag for usage with ALiVE_fnc_unitReadyRemote
_unit setvariable [QGVAR(MOVEDESTINATION),getpos _unit];

if (local _unit) exitwith {
	_unit landAt _args;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_landAtRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_landAtRemote",owner _unit];
};
