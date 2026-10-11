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
Jman
---------------------------------------------------------------------------- */

params ["_assignments","_vehicle"];

// moveIn takes effect only where the man is local, and a group the AI Distributor hands to a headless client is
// local there, so for one of those it goes to his own machine, with the assignAs before it (which works from
// anywhere) so that both run there in the order sent

// driver
private _driver = _assignments select 0;
{
    if !(isnil "_x") then {
        if (local _x) then {
            _x assignAsDriver _vehicle;
            _x moveInDriver _vehicle;
        } else {
            [_x, _vehicle] remoteExecCall ["assignAsDriver", _x];
            [_x, _vehicle] remoteExecCall ["moveInDriver", _x];
        };
    };
} forEach _driver;

// gunner
private _gunners = _assignments select 1;
{
    if !(isnil "_x") then {
        if (local _x) then {
            _x assignAsGunner _vehicle;
            _x moveInGunner _vehicle;
        } else {
            [_x, _vehicle] remoteExecCall ["assignAsGunner", _x];
            [_x, _vehicle] remoteExecCall ["moveInGunner", _x];
        };
    };
} forEach _gunners;

// commander
private _commander = _assignments select 2;
{
    if !(isnil "_x") then {
        if (local _x) then {
            _x assignAsCommander _vehicle;
            _x moveInCommander _vehicle;
        } else {
            [_x, _vehicle] remoteExecCall ["assignAsCommander", _x];
            [_x, _vehicle] remoteExecCall ["moveInCommander", _x];
        };
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
        if (local _x) then {
            _x assignAsTurret [_vehicle, _turretPath];
            _x moveInTurret [_vehicle, _turretPath];
        } else {
            [_x, [_vehicle, _turretPath]] remoteExecCall ["assignAsTurret", _x];
            [_x, [_vehicle, _turretPath]] remoteExecCall ["moveInTurret", _x];
        };
    } forEach _turret;
};

// cargo
private _cargo = _assignments select 4;
{
    if !(isnil "_x") then {
        if (local _x) then {
            _x assignAsCargo _vehicle;
            _x moveInCargo _vehicle;
        } else {
            [_x, _vehicle] remoteExecCall ["assignAsCargo", _x];
            [_x, _vehicle] remoteExecCall ["moveInCargo", _x];
        };
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
        if (local _x) then {
            _x assignAsTurret [_vehicle, _turretPath];
            _x moveInTurret [_vehicle, _turretPath];
        } else {
            [_x, [_vehicle, _turretPath]] remoteExecCall ["assignAsTurret", _x];
            [_x, [_vehicle, _turretPath]] remoteExecCall ["moveInTurret", _x];
        };
    } forEach _turret;
};

// A light static weapon (a Stinger or Igla tripod) is often knocked over by its own crewman,
// who is created where it stands; he then can't get into a gun on its side and stands next to
// it. For a few seconds after crewing, a static weapon that has gone over is stood back up on
// the ground, and a gunner still outside it is put back in.
if (_vehicle isKindOf "StaticWeapon") then {
    [_vehicle, _gunners] spawn {
        params ["_vehicle", "_gunners"];
        for "_i" from 1 to 10 do {
            sleep 1;
            if (isNull _vehicle || {!alive _vehicle}) exitWith {};
            if (((vectorUp _vehicle) select 2) < 0.8) then {
                private _p = getPosATL _vehicle;
                private _fix = [_vehicle, surfaceNormal _p, [_p select 0, _p select 1, 0]];
                if (local _vehicle) then {
                    _vehicle setVectorUp (_fix select 1);
                    _vehicle setPosATL (_fix select 2);
                } else {
                    [_vehicle, _fix select 1] remoteExecCall ["setVectorUp", _vehicle];
                    [_vehicle, _fix select 2] remoteExecCall ["setPosATL", _vehicle];
                };
            };
            if (isNull (gunner _vehicle)) then {
                {
                    if (!isNil "_x" && {alive _x} && {vehicle _x == _x}) then {
                        if (local _x) then { _x moveInGunner _vehicle } else { [_x, _vehicle] remoteExecCall ["moveInGunner", _x] };
                    };
                } forEach _gunners;
            };
        };
    };
};
