#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetRandomSideEntityFromSector);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetRandomSideEntityFromSector

Description:
Get a random entity from a sector

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskSector","_side","_ignoreInVehicle","_targetEntity","_sectorData","_entitiesInSector","_sideEntities","_targetEntityID",
"_entityProfile","_vehiclesInCommandOf","_vehiclesInCargoOf"];

_taskSector = _this select 0;
_side = _this select 1;
_ignoreInVehicle = _this select 2;

_targetEntity = [];

scopeName "main";

if(count _taskSector > 0) then {
    _sectorData = [_taskSector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;

    if("entitiesBySide" in (_sectorData select 1)) then {

        _entitiesInSector = [_sectorData,"entitiesBySide"] call ALIVE_fnc_hashGet;
        _sideEntities = [_entitiesInSector,_side] call ALIVE_fnc_hashGet;

        if(count _sideEntities > 0) then {

            {

                _targetEntityID = _sideEntities call BIS_fnc_selectRandom;
                _targetEntityID = _targetEntityID select 0;

                _entityProfile = [ALIVE_profileHandler, "getProfile", _targetEntityID] call ALIVE_fnc_profileHandler;

                if!(isNil "_entityProfile") then {

                    if(_ignoreInVehicle) then {

                        _vehiclesInCommandOf = _entityProfile select 2 select 8;
                        _vehiclesInCargoOf = _entityProfile select 2 select 9;

                        if(count _vehiclesInCommandOf == 0 && count _vehiclesInCargoOf == 0) then {

                            _targetEntity = _entityProfile;

                            breakTo "main";

                        };

                    }else{

                        _targetEntity = _entityProfile;

                        breakTo "main";

                    };
                };

            } forEach _sideEntities;
        };
    };
};

_targetEntity