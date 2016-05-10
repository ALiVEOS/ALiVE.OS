#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetRandomSideVehicleFromSector);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetRandomSideVehicleFromSector

Description:
Get side sector that contains vehicles

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskSector","_side","_targetVehicles","_targetVehicle","_sectorData","_vehiclesInSector","_sideVehicles","_targetVehicleID",
"_vehicleProfile","_inCommand","_commandProfileID","_commandProfile","_vehiclesInCommandOf"];

_taskSector = _this select 0;
_side = _this select 1;

_targetVehicles = [];

if(count _taskSector > 0) then {
    _sectorData = [_taskSector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;

    if("vehiclesBySide" in (_sectorData select 1)) then {

        _vehiclesInSector = [_sectorData,"vehiclesBySide"] call ALIVE_fnc_hashGet;
        _sideVehicles = [_vehiclesInSector,_side] call ALIVE_fnc_hashGet;

        if(count _sideVehicles > 0) then {

            _targetVehicleID = _sideVehicles call BIS_fnc_selectRandom;
            _targetVehicleID = _targetVehicleID select 0;

            _vehicleProfile = [ALIVE_profileHandler, "getProfile", _targetVehicleID] call ALIVE_fnc_profileHandler;

            if!(isNil "_vehicleProfile") then {

                _inCommand = _vehicleProfile select 2 select 8;

                if(count _inCommand > 0) then {

                    _commandProfileID = _inCommand select 0;
                    _commandProfile = [ALIVE_profileHandler, "getProfile", _commandProfileID] call ALIVE_fnc_profileHandler;

                    if!(isNil "_commandProfile") then {

                        _vehiclesInCommandOf = _commandProfile select 2 select 8;

                        _targetVehicles = _vehiclesInCommandOf;

                    };

                }else{

                    _targetVehicles = [_vehicleProfile];

                };
            };
        };
    };
};

_targetVehicles