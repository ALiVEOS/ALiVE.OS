#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfilesCrewedVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesUnCrewedVehicle

Description:
Create profiles based on vehicle type without vehicle crew

Parameters:
String - Vehicle class name
String - Side name
Array - position
Scalar - direction

Returns:
Array of created profiles

Examples:
(begin example)
// create profiles for vehicle class
_result = ["B_Heli_Light_01_F","WEST","BLU_F",",getPosATL player] call ALIVE_fnc_createProfilesUnCrewedVehicle;



(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicleClass","_side","_faction","_direction","_spawnGoodPosition","_prefix","_engineOn","_busy","_cargo","_position",
"_groupProfiles","_groupUnits","_groupVehicles","_class","_vehicle","_vehicleType","_vehicleID","_entityID","_isSPE"];

_vehicleClass = _this select 0;
_side = _this select 1;
_faction = _this select 2;
_position = _this select 3;
_direction = if(count _this > 4) then {_this select 4} else {0};
_spawnGoodPosition = if(count _this > 5) then {_this select 5} else {true};
_prefix = if(count _this > 6) then {_this select 6} else {""};
_engineOn = if(count _this > 7) then {_this select 7} else {false};
_busy = if(count _this > 8) then {_this select 8} else {false};
_cargo = if(count _this > 9) then {_this select 9} else {[]};
_slingload = if(count _this > 10) then {_this select 10} else {[]};
_isSPE = if(count _this > 11) then {_this select 11} else {false};

// get counts of current profiles

_vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
_entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;


// create the entity profile

_groupProfiles = [];

private ["_entityID","_side","_profileEntity","_classes","_positions","_damages","_unit"];

_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
[_profileEntity, "profileID", format["%1-%2",_prefix,_entityID]] call ALIVE_fnc_profileEntity;
[_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
[_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
[_profileEntity, "faction", _faction] call ALIVE_fnc_profileEntity;
[_profileEntity, "busy", _busy] call ALIVE_fnc_profileEntity;
[_profileEntity, "isSPE", false] call ALIVE_fnc_profileEntity;
[_profileEntity, "aiBehaviour", "SAFE"] call ALIVE_fnc_profileEntity;

if!(_spawnGoodPosition) then {
    [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
};

_groupProfiles pushback _profileEntity;
[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

private ["_vehicleKind","_vehicleID","_vehicleClass","_profileVehicle"];

_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

// create the profile for the vehicle

_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", format["%1-%2",_prefix,_vehicleID]] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", _position] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", _direction] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", _side] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "faction", _faction] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "busy", _busy] call ALIVE_fnc_profileVehicle;

if(count _cargo > 0) then {
    [_profileVehicle, "cargo", _cargo] call ALIVE_fnc_profileVehicle;
};

if(count _slingload > 0) then {
    [_profileVehicle, "slingload", _slingload] call ALIVE_fnc_profileVehicle;
};

if(_isSPE) then {
    [_profileVehicle, "isSPE", _isSPE] call ALIVE_fnc_profileVehicle;
};

if!(_spawnGoodPosition) then {
    [_profileVehicle, "despawnPosition", _position] call ALIVE_fnc_profileVehicle;
};

if(_engineOn) then {
    [_profileVehicle, "engineOn", true] call ALIVE_fnc_profileVehicle;
};

_groupProfiles pushback _profileVehicle;
[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


_groupProfiles