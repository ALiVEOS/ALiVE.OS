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

private ["_profileEntity","_profileVehicle","_append","_entityID","_unitIndexes","_currentEntityAssignments","_currentVehicleAssignments","_vehicleID",
"_usedIndexes","_unitCount","_emptyPositionData","_vehicleAssignments","_unitAssignments","_assignments","_assignedCount","_assignment","_emptyCount"];
	
_profileEntity = _this select 0;
_profileVehicle = _this select 1;
_append = if(count _this > 2) then {_this select 2} else {false};

waituntil {!isnil "ALIVE_profileHandler"};

if (typeName _profileEntity == "OBJECT") then {
    private ["_unit","_group"];
    
    _unit = _profileEntity; _profileEntity = nil;
    _group = group _unit;

	_profileEntity = [ALIVE_profileHandler, "getProfile", (_unit getVariable "profileID")] call ALIVE_fnc_profileHandler;
    if (isnil "_profileEntity") then {_profileEntity = [false,[_group],[]] call ALiVE_fnc_CreateProfilesFromUnitsRuntime};
};
if (typeName _profileVehicle == "OBJECT") then {
    private ["_vehicle"];
    
    _vehicle = _profileVehicle; _profileVehicle = nil;

	_profileVehicle = [ALIVE_profileHandler, "getProfile", (_vehicle getVariable "profileID")] call ALIVE_fnc_profileHandler;
    if (isnil "_profileVehicle") then {_profileVehicle = [false,[],[_vehicle]] call ALiVE_fnc_CreateProfilesFromUnitsRuntime};
};

if !(!isnil "_profileVehicle" && {(typeName _profileVehicle == "ARRAY")}) exitwith {};
if !(!isnil "_profileEntity" && {(typeName _profileEntity == "ARRAY")}) exitwith {};

_entityID = _profileEntity select 2 select 4; //[_profileEntity, "profileID"] call ALIVE_fnc_hashGet;
_unitIndexes = [_profileEntity, "unitIndexes"] call ALIVE_fnc_profileEntity;
_currentEntityAssignments = [_profileEntity, "vehicleAssignments"] call ALIVE_fnc_hashGet;
_currentVehicleAssignments = [_profileVehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;
_vehicleID = _profileVehicle select 2 select 4; //[_profileVehicle, "profileID"] call ALIVE_fnc_hashGet;

// get indexes of units that are already assigned to vehicles
_usedIndexes = _currentEntityAssignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
_unitIndexes = _unitIndexes - _usedIndexes;
_unitCount = count _unitIndexes;


if(count(_unitIndexes) > 0) then {

	// get empty position data for the vehicle
	_emptyPositionData = _profileVehicle call ALIVE_fnc_profileVehicleAssignmentGetEmptyPositions;

	/*
	["used indexes:%1",_usedIndexes] call ALIVE_fnc_dump;
	["unit indexes:%1",_unitIndexes] call ALIVE_fnc_dump;
	["unit count:%1",_unitCount] call ALIVE_fnc_dump;
	["empty position data:%1",_emptyPositionData] call ALIVE_fnc_dump;
	*/

	_assignments = [_vehicleID,_entityID,[[],[],[],[],[],[]]];
	_assignedCount = 0;

	scopeName "main";

	for "_i" from 0 to (count _emptyPositionData)-1 do {
		_assignment = (_assignments select 2) select _i;
		_emptyCount = _emptyPositionData select _i;
		
		/*
		["empty pos ass: %1",_assignment] call ALIVE_fnc_dump;
		["empty pos empty count: %1",_emptyCount] call ALIVE_fnc_dump;
		*/

		for "_j" from 0 to (_emptyCount)-1 do {
		
			if(_unitCount == _assignedCount && _assignedCount > 0) then {
				breakTo "main";
			};			
			_assignment pushback (_unitIndexes select _assignedCount);			
			_assignedCount = _assignedCount + 1;			
		};
	};

	if(_append) then {
	    private ["_currentEntityAssignment","_currentVehicleAssignment","_newPositions","_positions","_newPosition","_position"];

	    _currentEntityAssignment = [_currentEntityAssignments, _vehicleID, []] call ALIVE_fnc_hashGet;
	    _currentVehicleAssignment = [_currentVehicleAssignments, _entityID, []] call ALIVE_fnc_hashGet;

        if((count _currentEntityAssignment > 0) && (count _currentVehicleAssignment > 0)) then {

            _newPositions = _assignments select 2;
            _positions = _currentEntityAssignment select 2;

            {
                _newPosition = _x;
                _position = _positions select _forEachIndex;
                _newPositions set [_forEachIndex, _newPosition + _position];
            } forEach _newPositions;
        };
	};

	[_profileEntity, "addVehicleAssignment", _assignments] call ALIVE_fnc_profileEntity;
	[_profileVehicle, "addVehicleAssignment", _assignments] call ALIVE_fnc_profileVehicle;
};