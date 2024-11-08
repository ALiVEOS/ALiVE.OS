#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfileVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfileVehicle

Description:
Create profiles based on vehicle type including vehicle crew

Parameters:
String - Vehicle class name
String - Side name
String - faction
Array - position
Scalar - direction

Returns:
Array of created profiles

Examples:
(begin example)
// create profiles for vehicle class
_result = ["B_Heli_Light_01_F","WEST","BLU_F",getPosATL player] call ALIVE_fnc_createProfileVehicle;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params [
    "_vehicleClass",
    "_side",
    "_faction",
    "_position",
    ["_direction", 0],
    ["_spawnGoodPosition", true],
    ["_prefix", ""],
    ["_cargo", []],
    ["_isSPE", false]
];

// get counts of current profiles

private _vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
private _vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

// create the profile for the vehicle

private _profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "profileID", format["%1-%2",_prefix,_vehicleID]] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "position", _position] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "direction", _direction] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "side", _side] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "faction", _faction] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
[_profileVehicle, "isSPE", _isSPE] call ALIVE_fnc_profileVehicle;

if (count _cargo > 0) then {
    [_profileVehicle, "cargo", _cargo] call ALIVE_fnc_profileVehicle;
};

/*
if(_vehicleKind == "Plane" || _vehicleKind == "Helicopter") then {
    [_profileVehicle, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
};*/

if !(_spawnGoodPosition) then {
    [_profileVehicle, "despawnPosition", _position] call ALIVE_fnc_profileVehicle;
};

[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

_profileVehicle