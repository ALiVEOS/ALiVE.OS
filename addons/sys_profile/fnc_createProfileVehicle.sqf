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
Boolean - optional spawn-good-position flag
String - optional profile-ID prefix
Array - optional cargo
Boolean - optional isSPE flag
Boolean - optional engine-on state
Array - optional slingload data
Boolean - optional busy state
String - optional AI behaviour

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
    ["_isSPE", false],
    ["_engineOn", false],
    ["_slingload", []],
    ["_busy", false],
    ["_aiBehaviour", "AWARE"]
];

// get counts of current profiles

private _vehicleID = [ALIVE_profileHandler,"getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
private _vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

// create the profile for the vehicle

private _profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
[_profileVehicle,"init"] call ALIVE_fnc_profileVehicle;
[_profileVehicle,"vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;

// use hashset for operations that don't have internal processing
// speeds up profile creation
[_profileVehicle, [
    ["profileID", if (_prefix isEqualTo "") then { _vehicleID } else { format ["%1-%2", _prefix, _vehicleID] }],
    ["position", _position],
    ["direction", _direction],
    ["side", _side],
    ["faction", _faction],
    ["damage", []],
    ["fuel", 1],
    ["isSPE", _isSPE],
    ["cargo", _cargo],
    ["engineOn", _engineOn],
    ["slingload", _slingload],
    ["busy", _busy],
    ["aiBehaviour", _aiBehaviour]
]] call ALiVE_fnc_hashSetMany;

if !(_spawnGoodPosition) then {
    [_profileVehicle,"despawnPosition", _position] call ALIVE_fnc_profileVehicle;
};

[ALIVE_profileHandler,"registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

_profileVehicle
