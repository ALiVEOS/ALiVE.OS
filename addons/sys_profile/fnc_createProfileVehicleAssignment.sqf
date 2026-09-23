#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfileVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileVehicleAssignment

Description:
Assigns unassigned soldiers to available vehicle seats.

Parameters:
Array - Entity profile
Array - Vehicle profile
Boolean - Append (optional, default false)
Boolean - Passengers only (optional, default false); preserves existing assignments

Returns:
Array - [newly assigned unit indexes, remaining unassigned unit indexes]. Invalid input returns nil.

Examples:
(begin example)
// vehicle assignment
_result = [_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

params ["_profileEntity","_profileVehicle",["_append", false],["_passengersOnly", false]];

waituntil {!isnil "ALIVE_profileHandler"};

// if arguments are objects
// convert them to profiles

if (_profileEntity isEqualType objNull) then {
    private _unit = _profileEntity; _profileEntity = nil;
    private _group = group _unit;

    _profileEntity = [ALIVE_profileHandler, "getProfile", (_unit getVariable "profileID")] call ALIVE_fnc_profileHandler;
    if (isnil "_profileEntity") then {
        _profileEntity = [false,[_group],[]] call ALiVE_fnc_CreateProfilesFromUnitsRuntime;
    };
};

if (_profileVehicle isEqualType objNull) then {
    private _vehicle = _profileVehicle; _profileVehicle = nil;

    _profileVehicle = [ALIVE_profileHandler, "getProfile", (_vehicle getVariable "profileID")] call ALIVE_fnc_profileHandler;
    if (isnil "_profileVehicle") then {
        _profileVehicle = [false,[],[_vehicle]] call ALiVE_fnc_CreateProfilesFromUnitsRuntime;
    };
};

if (isnil "_profileVehicle" || { !(_profileVehicle isEqualType []) }) exitwith {};
if (isnil "_profileEntity" || { !(_profileEntity isEqualType []) }) exitwith {};

// Validate profile shape and roles before accessing fixed data slots.
if (count _profileEntity < 3 || {count _profileVehicle < 3}) exitWith {};
if !((_profileEntity select 2) isEqualType [] && {(_profileVehicle select 2) isEqualType []}) exitWith {};
if (count (_profileEntity select 2) < 12 || {count (_profileVehicle select 2) < 12}) exitWith {};
if ((_profileEntity select 2 select 5) != "entity" || {(_profileVehicle select 2 select 5) != "vehicle"}) exitWith {};
if !((_profileEntity select 2 select 11) isEqualType [] && {(_profileVehicle select 2 select 11) isEqualType ""}) exitWith {};
if !(isClass (configFile >> "CfgVehicles" >> (_profileVehicle select 2 select 11))) exitWith {};

private _entityID = _profileEntity select 2 select 4; //[_profileEntity, "profileID"] call ALIVE_fnc_hashGet;
private _unitIndexes = [_profileEntity, "unitIndexes"] call ALIVE_fnc_profileEntity;
private _currentEntityAssignments = [_profileEntity, "vehicleAssignments"] call ALIVE_fnc_hashGet;
private _currentVehicleAssignments = [_profileVehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;
private _vehicleID = _profileVehicle select 2 select 4; //[_profileVehicle, "profileID"] call ALIVE_fnc_hashGet;

// Refuse a malformed self-referential / vehicle-in-entity-slot assignment. The crew ("entity")
// argument must be a genuine entity profile distinct from the vehicle. If it is the SAME profile as
// the vehicle, or is itself vehicle-typed, the resulting assignment points a vehicle at itself in
// its own vehicleAssignments. profileVehicleAssignmentsSetAllPositions then feeds that vehicle
// profile into profileEntity "mergePositions", which re-routes back into profileVehicle
// "mergePositions" and recurses without bound, hard-freezing the sim thread. ATO produces exactly
// this (vehicle,vehicle) case when an airframe's crewID is its own vehicle id. Reject at creation
// (log once). exitWith is correct here: this is function top-level, matching the guards above.
if (_entityID isEqualTo _vehicleID || { (_profileEntity select 2 select 5) == "vehicle" }) exitWith {
    private _logged = missionNamespace getVariable ["ALIVE_createVehAssignRejectLogged", []];
    if !(_vehicleID in _logged) then {
        _logged pushBack _vehicleID;
        missionNamespace setVariable ["ALIVE_createVehAssignRejectLogged", _logged];
        ["fnc_createProfileVehicleAssignment: rejected malformed assignment (entity %1, vehicle %2, entityType %3) -- entity arg equals or is the vehicle; would seed a mergePositions recursion", _entityID, _vehicleID, (_profileEntity select 2 select 5)] call ALiVE_fnc_dump;
    };
};

// get indexes of units that are already assigned to vehicles
private _usedIndexes = _currentEntityAssignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
_unitIndexes = _unitIndexes - _usedIndexes;
private _unitCount = count _unitIndexes;


private _newlyAssigned = [];
if (count _unitIndexes > 0) then {

    // get empty position data for the vehicle
    private _emptyPositionData = _profileVehicle call ALIVE_fnc_profileVehicleAssignmentGetEmptyPositions;

    /*
    ["used indexes:%1",_usedIndexes] call ALIVE_fnc_dump;
    ["unit indexes:%1",_unitIndexes] call ALIVE_fnc_dump;
    ["unit count:%1",_unitCount] call ALIVE_fnc_dump;
    ["empty position data:%1",_emptyPositionData] call ALIVE_fnc_dump;
    */

    private _assignments = [_vehicleID,_entityID,[[],[],[],[],[],[]]];
    private _assignedCount = 0;

    scopeName "main";

    for "_i" from 0 to (count _emptyPositionData - 1) do {
        private _assignment = (_assignments select 2) select _i;
        private _emptyCount = (_emptyPositionData select _i) max 0;
        if (_passengersOnly && {!(_i in [4,5])}) then {_emptyCount = 0};

        /*
        ["empty pos ass: %1",_assignment] call ALIVE_fnc_dump;
        ["empty pos empty count: %1",_emptyCount] call ALIVE_fnc_dump;
        */

        for "_j" from 0 to (_emptyCount - 1) do {
            if (_unitCount == _assignedCount && _assignedCount > 0) then {
                breakTo "main";
            };
            _assignment pushback (_unitIndexes select _assignedCount);
            _newlyAssigned pushBack (_unitIndexes select _assignedCount);
            _assignedCount = _assignedCount + 1;
        };
    };

    // Never create an empty link or overwrite existing seats when no units fit.
    if (_assignedCount == 0) exitWith {};
    if (_append || _passengersOnly) then {
        private _currentEntityAssignment = [_currentEntityAssignments, _vehicleID, []] call ALIVE_fnc_hashGet;
        private _currentVehicleAssignment = [_currentVehicleAssignments, _entityID, []] call ALIVE_fnc_hashGet;

        if ((count _currentEntityAssignment > 0) && {count _currentVehicleAssignment > 0}) then {
            private _newPositions = _assignments select 2;
            private _positions = _currentEntityAssignment select 2;

            {
                private _newPosition = _x;
                private _position = _positions select _forEachIndex;

                _newPositions set [_forEachIndex, _newPosition + _position];
            } forEach _newPositions;
        };
    };

    [_profileEntity,"addVehicleAssignment", _assignments] call ALIVE_fnc_profileEntity;
    [_profileVehicle,"addVehicleAssignment", _assignments] call ALIVE_fnc_profileVehicle;
};
// Report actual remaining assignments, including seats released by legacy replacement mode.
// Allocation does not confirm that spawned units have boarded.
private _assignedIndexes = _currentEntityAssignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
private _allIndexes = [_profileEntity, "unitIndexes"] call ALIVE_fnc_profileEntity;
[_newlyAssigned, _allIndexes - _assignedIndexes]
