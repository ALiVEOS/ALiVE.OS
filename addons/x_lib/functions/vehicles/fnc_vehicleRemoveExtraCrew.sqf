#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(vehicleRemoveExtraCrew);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleRemoveExtraCrew

Description:
Remove units from a group that are not in a vehicle.
Designed to fix cases where BIS_fnc_spawnCrew spawns too many and they
spawn next to, not in the vehicle.

Parameters:
Group - The group
Vehicle - The vehicle

Returns:
none

Examples:
(begin example)
// move in all assignments
[_veh, _grp] call BIS_fnc_spawnCrew;
[_veh, _grp] call ALIVE_fnc_vehicleRemoveExtraCrew;
(end)

See Also:


Author:
Bradon
---------------------------------------------------------------------------- */
private ["_grp", "_veh", "_grpunits"];
_grp = _this select 0;
_veh = _this select 1;
_grpunits = units _grp;

{
    if (vehicle _x == _x) then {
        deleteVehicle _x;
    };
} foreach _grpunits;
