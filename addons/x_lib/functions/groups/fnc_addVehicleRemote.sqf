#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(addVehicleRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_addVehicleRemote

Description:
Executes addVehicle on the units remote location automatically

Parameters:
Grou[]
Vehicle - Object

Returns:
Nothing

Examples:
[_unit,_vehicle] call ALiVE_fnc_addVehicleRemote;

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params [
    ["_group", grpNull, [grpNull]],
    ["_vehicle", objNull, [objNull]]
];

if (local (leader _group)) exitwith {
    _group addVehicle _vehicle;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_addVehicleRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_addVehicleRemote",0];
};
