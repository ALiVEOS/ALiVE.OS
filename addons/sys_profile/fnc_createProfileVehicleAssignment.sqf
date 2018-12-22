#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfileVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileVehicleAssignment

Description:
Creates a vehicle assignment array for the group and vehicle

Parameters:
Array - Entity profile
Array - Vehicle profile

Returns:
A vehicle assignment array

Examples:
(begin example)
// vehicle assignment
_result = [_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profileEntity","_profileVehicle",["_append", false]];

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

private _entityID = _profileEntity select 2 select 4; //[_profileEntity, "profileID"] call ALIVE_fnc_hashGet;
private _unitIndexes = [_profileEntity, "unitIndexes"] call ALIVE_fnc_profileEntity;
private _currentEntityAssignments = [_profileEntity, "vehicleAssignments"] call ALIVE_fnc_hashGet;
private _currentVehicleAssignments = [_profileVehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;
private _vehicleID = _profileVehicle select 2 select 4; //[_profileVehicle, "profileID"] call ALIVE_fnc_hashGet;

// get indexes of units that are already assigned to vehicles
private _usedIndexes = _currentEntityAssignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
_unitIndexes = _unitIndexes - _usedIndexes;
private _unitCount = count _unitIndexes;


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
        private _emptyCount = _emptyPositionData select _i;

        /*
        ["empty pos ass: %1",_assignment] call ALIVE_fnc_dump;
        ["empty pos empty count: %1",_emptyCount] call ALIVE_fnc_dump;
        */

        for "_j" from 0 to (_emptyCount - 1) do {
            if (_unitCount == _assignedCount && _assignedCount > 0) then {
                breakTo "main";
            };
            _assignment pushback (_unitIndexes select _assignedCount);
            _assignedCount = _assignedCount + 1;
        };
    };

    if (_append) then {
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