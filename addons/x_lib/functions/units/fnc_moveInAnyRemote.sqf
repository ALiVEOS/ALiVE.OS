#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(moveInAnyRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_moveInAnyRemote

Description:
Executes moveInAny on the units remote location automatically

Parameters:
Array - Units

Returns:
Nothing

Examples:
[_unit,_vehicle] call ALiVE_fnc_moveInAnyRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_unit", objNull, [objNull]],
    ["_vehicle", objNull, [objNull]]
];

if (local _unit) exitwith {
    _unit moveInAny _vehicle;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_moveInAnyRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_moveInAnyRemote",owner _unit];
};
