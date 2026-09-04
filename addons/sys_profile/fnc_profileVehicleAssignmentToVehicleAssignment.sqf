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

params [
    "_vehicleAssignment",
    "_profile",
    ["_orderGetIn", false]
];

private _profilesById = [ALIVE_profileHandler,"profilesById"] call ALiVE_fnc_hashGet;

private _profileType = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;

if (_profileType == "vehicle") then {

    private _vehicle = _profile select 2 select 10; //[_profile,"vehicle"] call ALIVE_fnc_hashGet;
    private _entityProfileID = _vehicleAssignment select 1;
    private _entityProfile = _profilesById get _entityProfileID;

    if !(isnil "_entityProfile") then {
        if ((_entityProfile select 2 select 5) == "entity") then {
            private _entityProfileActive = _entityProfile select 2 select 1; //[_entityProfile,"active"] call ALIVE_fnc_hashGet;

            if !(_entityProfileActive) then {
                [_entityProfile,"spawn"] call ALIVE_fnc_profileEntity;
            } else {
                private _units = _entityProfile select 2 select 21; //[_entityProfile,"units"] call ALIVE_fnc_hashGet;
                private _unitAssignments = [_vehicleAssignment, _units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
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
    private _units = _profile select 2 select 21; //[_profile,"units"] call ALIVE_fnc_hashGet;
    private _vehicleProfileID = _vehicleAssignment select 0;

    private _vehicleProfile = _profilesById get _vehicleProfileID;

    if !(isnil "_vehicleProfile") then {
        if ((_vehicleProfile select 2 select 5) == "vehicle") then {
            private _vehicleProfileActive =  _vehicleProfile select 2 select 1; //[_vehicleProfile,"active"] call ALIVE_fnc_hashGet;

            if !(_vehicleProfileActive) then {
                [_vehicleProfile,"spawn"] call ALIVE_fnc_profileVehicle;
            } else {
                private _vehicle = _vehicleProfile select 2 select 10; //[_vehicleProfile,"vehicle"] call ALIVE_fnc_hashGet;
                private _unitAssignments = [_vehicleAssignment, _units] call ALIVE_fnc_profileVehicleAssignmentIndexesToUnits;
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
