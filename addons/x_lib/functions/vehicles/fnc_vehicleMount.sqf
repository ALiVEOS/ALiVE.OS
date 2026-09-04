#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(vehicleMount);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleMount

Description:
Mount vehicle by passed vehicle assignment array

Parameters:
Array - assignments array
Vehicle - The vehicle

Returns:

Examples:
(begin example)
// mount all assignments
_result = [[[_unit],[_unit,_unit],[],[]], _vehicle] call ALIVE_fnc_vehicleMount;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

params ["_assignments","_vehicle"];

// driver
private _driver = _assignments select 0;
{
    _x assignAsDriver _vehicle;
    [_x] orderGetIn true;
} forEach _driver;

// gunner
private _gunners = _assignments select 1;
{
    _x assignAsGunner _vehicle;
    [_x] orderGetIn true;
} forEach _gunners;

// commander
private _commander = _assignments select 2;
{
    _x assignAsCommander _vehicle;
    [_x] orderGetIn true;
} forEach _commander;

// turrets
private _turretAssignments = _assignments select 3;
if (_turretAssignments isnotequalto []) then {
    // get turrets for this class ignoring gunner and commander turrets
    private _turrets = [typeOf _vehicle, true, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

    {
        if (_turrets isEqualTo []) exitWith {};

        private _turretPath = _turrets deleteAt ((count _turrets) - 1);
        _x assignAsTurret [_vehicle, _turretPath];
        [_x] orderGetIn true;
    } forEach _turretAssignments;
};

// cargo
private _cargo = _assignments select 4;
{
    _x assignAsCargo _vehicle;
    [_x] orderGetIn true;
} forEach _cargo;

// player turrets
private _playerTurretAssignments = _assignments select 5;
if (_playerTurretAssignments isnotequalto []) then {
    // get turrets for this class ignoring gunner and commander turrets
    private _turrets = [typeOf _vehicle, true, true, false, true, true] call ALIVE_fnc_configGetVehicleTurretPositions;

    {
        if (_turrets isEqualTo []) exitWith {};

        private _turretPath = _turrets deleteAt ((count _turrets) - 1);
        _x assignAsTurret [_vehicle, _turretPath];
        [_x] orderGetIn true;
    } forEach _playerTurretAssignments;
};
