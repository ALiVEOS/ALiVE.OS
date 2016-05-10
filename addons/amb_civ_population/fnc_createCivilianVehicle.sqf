#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createCivilianVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createCivilianVehicle

Description:
Create profiles based on vehicle type including vehicle crew

Parameters:
String - Vehicle class name
String - Side name
String - Rank
Array - position
Scalar - direction

Returns:
Array of created profiles

Examples:
(begin example)
// create profiles for vehicle class
_result = ["B_Heli_Light_01_F","WEST",getPosATL player] call ALIVE_fnc_createCivilianVehicle;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicleClass","_side","_faction","_direction","_spawnGoodPosition","_prefix","_clusterID","_buildingPosition","_position","_vehicleID","_vehicleKind","_civilianVehicle"];

_vehicleClass = _this select 0;
_side = _this select 1;
_faction = _this select 2;
_position = _this select 3;
_direction = if(count _this > 4) then {_this select 4} else {0};
_spawnGoodPosition = if(count _this > 5) then {_this select 5} else {true};
_prefix = if(count _this > 6) then {_this select 6} else {""};
_clusterID = if(count _this > 7) then {_this select 7} else {""};
_buildingPosition = if(count _this > 8) then {_this select 8} else {[0,0,0]};

// get counts of current profiles

_vehicleID = format["agent_%1",[ALIVE_agentHandler, "getNextInsertID"] call ALIVE_fnc_agentHandler];

_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

// create the profile for the vehicle
								
_civilianVehicle = [nil, "create"] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "init"] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "agentID", _vehicleID] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "agentClass", _vehicleClass] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "position", _position] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "direction", _direction] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "side", _side] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "faction", _faction] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "damage", 0] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "fuel", 1] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "homeCluster", _clusterID] call ALIVE_fnc_civilianVehicle;
[_civilianVehicle, "homePosition", _buildingPosition] call ALIVE_fnc_civilianVehicle;

[ALIVE_agentHandler, "registerAgent", _civilianVehicle] call ALIVE_fnc_agentHandler;

_civilianVehicle