#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(configGetVehicleEmptyPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleEmptyPositions

Description:
Get an array of empty positions for the vehicle from config

Parameters:
String - The vehicle class name

Returns:
Array of empty positions [driver, gunner, commander, turretsEmpty, cargo]

Examples:
(begin example)
// get empty positions array
_result = ["B_Truck_01_transport_F"] call ALIVE_fnc_configGetVehicleEmptyPositions;
// returns [1,0,0,0,17]
(end)

See Also:

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_vehicle","_positions","_class","_turretEmptyCount","_playerTurretEmptyCount","_findRecurse","_turrets"];

_vehicle = _this select 0;

_positions = [0,0,0,0,0,0];
_class = (configFile >> "CfgVehicles" >> _vehicle);

_positions set [0, getNumber(_class >> "hasDriver")];

// get turrets for this class ignoring gunner and commander turrets
_turretEmptyCount = 0;
_playerTurretEmptyCount = 0;

_findRecurse = {
    {
        if (getNumber (_x >> "dontCreateAi") != 1) then {
            if (getNumber (_x >> "showAsCargo") == 0) then {
                if(getNumber(_x >> "primaryGunner") == 1) then {
                    _positions set [1, 1];
                } else {
                    if(getNumber(_x >> "primaryObserver") == 1) then {
                        _positions set [2, 1];
                    } else {
                        _turretEmptyCount = _turretEmptyCount + 1;
                    };
                };
            } else {
                _playerTurretEmptyCount = _playerTurretEmptyCount + 1;
            };

            if (isClass (_x >> "Turrets")) then {
                _x call _findRecurse;
            };
        };
    } forEach ("true" configClasses (_this >> "Turrets")); // mimic BIS_fnc_crewCount (this skips over the inherited MainTurret which is good :))
};

_class call _findRecurse;


_positions set [3, _turretEmptyCount];
_positions set [4, getNumber(_class >> "transportSoldier")];
_positions set [5, _playerTurretEmptyCount];

_positions;
