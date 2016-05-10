#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateVehicleExtractionForUnits);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateVehicleExtractionForUnits

Description:
Supply some units and an extraction vehicle for them

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

[_this] spawn {

    private ["_args","_insertionPosition","_taskPosition","_extractionPosition","_taskSide","_taskFaction","_taskProfile","_taskProfileID","_insertionTypes",
    "_countUnits","_insertionType","_carClasses","_heliClasses"];

    _args = _this select 0;

    _insertionPosition = _args select 0;
    _taskPosition = _args select 1;
    _extractionPosition = _args select 2;
    _taskSide = _args select 3;
    _taskFaction = _args select 4;
    _taskProfile = _args select 5;

    _taskProfileID = _taskProfile select 2 select 4;

    _insertionTypes = ["Car","Helicopter"];

    _countUnits = [_taskProfile,"unitCount"] call ALIVE_fnc_profileEntity;

    _carClasses = [_countUnits,_taskFaction,"Car"] call ALiVE_fnc_findVehicleType;
    _carClasses = _carClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

    if(count _carClasses == 0) then {
        _insertionTypes = _insertionTypes - ["Car"];
    };

    _heliClasses = [_countUnits,_taskFaction,"Helicopter"] call ALiVE_fnc_findVehicleType;
    _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

    if(count _heliClasses == 0) then {
        _insertionTypes = _insertionTypes - ["Helicopter"];
    };

    if(count _insertionTypes == 0) then {
        _heliClasses = [_countUnits,nil,"Helicopter"] call ALiVE_fnc_findVehicleType;
        _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;
        _insertionType = "Helicopter";
    }else{
        _insertionType = _insertionTypes call BIS_fnc_selectRandom;
    };

    private ["_vehicleClass","_profiles","_crewProfile","_crewProfileID","_vehicleProfile","_vehicleProfileID","_profileWaypoint"];

    switch(_insertionType) do {
        case "Car":{
            _vehicleClass = _carClasses call BIS_fnc_selectRandom;
            _profiles = [_vehicleClass,_taskSide,_taskFaction,"CAPTAIN",_insertionPosition,random(360),false,_taskFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;
            _crewProfile = _profiles select 0;
            _crewProfileID = _crewProfile select 2 select 4;
            _vehicleProfile = _profiles select 1;
            _vehicleProfileID = _vehicleProfile select 2 select 4;

            _taskPosition = [_taskPosition] call ALIVE_fnc_getClosestRoad;

            _profileWaypoint = [_taskPosition, 100, "MOVE", "LIMITED", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
            [_crewProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
        };
        case "Helicopter":{
            _vehicleClass = _heliClasses call BIS_fnc_selectRandom;
            _profiles = [_vehicleClass,_taskSide,_taskFaction,"CAPTAIN",_insertionPosition,random(360),false,_taskFaction,true,true] call ALIVE_fnc_createProfilesCrewedVehicle;
            _crewProfile = _profiles select 0;
            _crewProfileID = _crewProfile select 2 select 4;
            _vehicleProfile = _profiles select 1;
            _vehicleProfileID = _vehicleProfile select 2 select 4;

            _profileWaypoint = [_taskPosition, 100, "MOVE", "LIMITED", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
            [_crewProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
        };
    };

    private ["_waypointComplete"];

    waitUntil {
        sleep 5;
        _crewProfile = [ALIVE_profileHandler, "getProfile", _crewProfileID] call ALIVE_fnc_profileHandler;
        if!(isNil "_crewProfile") then {
            _waypointComplete = [_crewProfile,"checkWaypointComplete"] call ALIVE_fnc_profileEntity;
        }else{
            _waypointComplete = true;
        };

        _waypointComplete
    };

    _taskProfile = [ALIVE_profileHandler, "getProfile", _taskProfileID] call ALIVE_fnc_profileHandler;
    _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

    if(!(isNil "_taskProfile") && !(isNil "_vehicleProfile")) then {
        [_taskProfile,_vehicleProfile] call ALIVE_fnc_createProfileVehicleAssignment;
    };

    private ["_active","_countUnloaded","_loaded","_group","_units"];

    waitUntil {
        sleep 5;

        _loaded = true;

        _taskProfile = [ALIVE_profileHandler, "getProfile", _taskProfileID] call ALIVE_fnc_profileHandler;
        if!(isNil "_taskProfile") then {

            _loaded = false;

            _active = _taskProfile select 2 select 1;
            _countUnloaded = 0;

            if(_active) then {

                _group = _taskProfile select 2 select 13;
                _units = units _group;

                _loaded = [_units] call ALIVE_fnc_taskHaveUnitsLoadedInVehicle;

            }else{

                _loaded = true;

            };

        };

        _loaded

    };

    _crewProfile = [ALIVE_profileHandler, "getProfile", _crewProfileID] call ALIVE_fnc_profileHandler;

    if!(isNil "_crewProfile") then {

        _profileWaypoint = [_extractionPosition, 100, "MOVE", "LIMITED", 100, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
        [_crewProfile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;
    };


};