#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(vehicleMoveIn);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleMoveIn

Description:
Move in vehicle by passed vehicle assignment array

Parameters:
Array - assignments array
Vehicle - The vehicle

Returns:

Examples:
(begin example)
// move in all assignments
_result = [[[_unit],[_unit,_unit],[],[]], _vehicle] call ALIVE_fnc_vehicleMoveIn;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_assignments","_vehicle"];

// driver
private _driver = _assignments select 0;
{
    if !(isnil "_x") then {
        _x assignAsDriver _vehicle;
        _x moveInDriver _vehicle;
    };
} forEach _driver;

// gunner
private _gunners = _assignments select 1;
{
    if !(isnil "_x") then {
        _x assignAsGunner _vehicle;
        _x moveInGunner _vehicle;
    };
} forEach _gunners;

// commander
private _commander = _assignments select 2;
{
    if !(isnil "_x") then {
        _x assignAsCommander _vehicle;
        _x moveInCommander _vehicle;
    };
} forEach _commander;

// turrets
private _turret = _assignments select 3;

if (count _turret > 0) then {
    // get turrets for this class ignoring gunner and commander turrets
    private _turrets = [typeOf _vehicle, true, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

    {
        if (_turrets isEqualTo []) exitWith {};

        private _turretPath = _turrets deleteAt ((count _turrets) - 1);
        _x assignAsTurret [_vehicle, _turretPath];
        _x moveInTurret [_vehicle, _turretPath];
    } forEach _turret;
};

// cargo
private _cargo = _assignments select 4;
{
    if !(isnil "_x") then {
        _x assignAsCargo _vehicle;
        _x moveInCargo _vehicle;
    };
} forEach _cargo;

// player turrets
_turret = _assignments select 5;

if (count _turret > 0) then {
    // get turrets for this class ignoring gunner and commander turrets
    private _turrets = [typeOf _vehicle, true, true, false, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

    {
        if (_turrets isEqualTo []) exitWith {};

        private _turretPath = _turrets deleteAt ((count _turrets) - 1);
        _x assignAsTurret [_vehicle, _turretPath];
        _x moveInTurret [_vehicle, _turretPath];
    } forEach _turret;
};
