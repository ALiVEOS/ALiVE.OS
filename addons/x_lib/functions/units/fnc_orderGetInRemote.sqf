#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(orderGetInRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orderGetInRemote

Description:
Executes orderGetIn on the units remote location automatically

Parameters:
Array - Units

Returns:
Nothing

Examples:
[_units] call ALiVE_fnc_orderGetInRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_units", [objNull], [objNull]]
];

if (local (_units select 0)) exitwith {
    _units orderGetIn true;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_orderGetInRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_orderGetInRemote",owner (_units select 0)];
};
