#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(removeProfileVehicleAssignments);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeProfileVehicleAssignments

Description:
Removes all assignments for the passed profile

Parameters:
Array - Entity or Vehicle profile

Returns:

Examples:
(begin example)
// remove vehicle assignments from vehicle perspective
_result = [_vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignments;

// remove vehicle assignments from entity perspective
_result = [_entityProfile] call ALIVE_fnc_removeProfileVehicleAssignments;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profile"];

private _profileType = [_profile,"type"] call ALIVE_fnc_hashGet;
private _vehicleAssignments = [_profile,"vehicleAssignments"] call ALIVE_fnc_hashGet;

private _assignedIDs = _vehicleAssignments select 1;

if (_profileType == "vehicle") then {

    {
        private _entityID = _x;
        private _profileEntity = [ALIVE_profileHandler, "getProfile", _entityID] call ALIVE_fnc_profileHandler;

        if !(isnil "_profileEntity") then {
            [_profileEntity,_profile,true] call ALIVE_fnc_removeProfileVehicleAssignment;
        };
    } forEach _assignedIDs;

} else {

    {
        private _vehicleID = _x;
        private _profileVehicle = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;

        if !(isnil "_profileVehicle") then {
            [_profile,_profileVehicle,true] call ALIVE_fnc_removeProfileVehicleAssignment;
        };
    } forEach _assignedIDs;

};
