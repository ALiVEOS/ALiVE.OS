#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileVehicleAssignmentToVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment

Description:
Takes a profile vehicle assignment and creates real vehicle assignment

Parameters:
Array - Profile vehicle assignment
Array - Profile

Returns:

Examples:
(begin example)
// create real vehicle assignment (move in instantly)
_result = [_vehicleAssignment, _profile] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;

// create real vehicle assignment (order get in)
_result = [_vehicleAssignment, _profile, true] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_vehicleAssignment","_profile","_orderGetIn","_profileType","_vehicle","_entityProfileID","_entityProfile",
"_entityProfileActive","_units","_unitAssignments","_vehicleProfileID","_vehicleProfile","_vehicleProfileActive"];

_vehicleAssignment = _this select 0;
_profile = _this select 1;
_orderGetIn = if(count _this > 2) then {_this select 2} else {false};

_profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

if(_profileType == "vehicle") then {

    _vehicle = _profile select 2 select 10; //[_profile,"vehicle"] call ALIVE_fnc_hashGet;
    _entityProfileID = _vehicleAssignment select 1;
    _entityProfile = [ALIVE_profileHandler, "getProfile", _entityProfileID] call ALIVE_fnc_profileHandler;

    if !(isnil "_entityProfile") then {

        // Assignment slot 1 must resolve to an ENTITY profile. If it resolves to a
        // vehicle (or anything else), entity-spawn and the units read below would
        // misread the vehicle schema (slot 18 canFire, slot 21 hasSimulated...) and
        // crash; log the mis-dispatch and skip rather than take the wrong schema.
        if ((_entityProfile select 2 select 5) == "entity") then {
            _entityProfileActive = _entityProfile select 2 select 1; //[_entityProfile,"active"] call ALIVE_fnc_hashGet;

            if!(_entityProfileActive) then {
                [_entityProfile,"spawn"] call ALIVE_fnc_profileEntity;
            } else {
                _units = _entityProfile select 2 select 21; //[_entityProfile,"units"] call ALIVE_fnc_hashGet;
                _unitAssignments = [_vehicleAssignment, _units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
                if (_orderGetIn) then {
                    [_unitAssignments, _vehicle] call ALIVE_fnc_vehicleMount;
                } else {
                    [_unitAssignments, _vehicle] call ALIVE_fnc_vehicleMoveIn;
                };
            };
        } else {
            ["ALiVE VAtoVA: assignment slot 1 resolved to a non-entity profile (id %1, type %2) - skipping entity spawn. Assignment: %3", _entityProfile select 2 select 4, _entityProfile select 2 select 5, _vehicleAssignment] call ALiVE_fnc_dump;
        };
    };

} else {
    _units = _profile select 2 select 21; //[_profile,"units"] call ALIVE_fnc_hashGet;
    _vehicleProfileID = _vehicleAssignment select 0;
    _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleProfileID] call ALIVE_fnc_profileHandler;

    if !(isnil "_vehicleProfile") then {

        // Symmetric guard: assignment slot 0 must resolve to a VEHICLE profile, or
        // vehicle-spawn would misread the entity schema. Log and skip otherwise.
        if ((_vehicleProfile select 2 select 5) == "vehicle") then {
            _vehicleProfileActive =  _vehicleProfile select 2 select 1; //[_vehicleProfile,"active"] call ALIVE_fnc_hashGet;

            if!(_vehicleProfileActive) then {
                [_vehicleProfile,"spawn"] call ALIVE_fnc_profileVehicle;
            } else {
                _vehicle = _vehicleProfile select 2 select 10; //[_vehicleProfile,"vehicle"] call ALIVE_fnc_hashGet;
                _unitAssignments = [_vehicleAssignment, _units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
                if (_orderGetIn) then {
                    [_unitAssignments, _vehicle] call ALIVE_fnc_vehicleMount;
                } else {
                    [_unitAssignments, _vehicle] call ALIVE_fnc_vehicleMoveIn;
                };
            };
        } else {
            ["ALiVE VAtoVA: assignment slot 0 resolved to a non-vehicle profile (id %1, type %2) - skipping vehicle spawn. Assignment: %3", _vehicleProfile select 2 select 4, _vehicleProfile select 2 select 5, _vehicleAssignment] call ALiVE_fnc_dump;
        };
    };
};
