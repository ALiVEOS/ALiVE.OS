#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfilesCrewedVehicle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesCrewedVehicle

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
_result = ["B_Heli_Light_01_F","WEST","BLU_F","CAPTAIN",getPosATL player] call ALIVE_fnc_createProfilesCrewedVehicle;

_result = ["O_Heli_Transport_04_bench_F","EAST","OPF_F","CAPTAIN",getPosATL player] call ALIVE_fnc_createProfilesCrewedVehicle;


(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

params [
    "_vehicleClass",
    "_side",
    "_faction",
    "_rank",
    "_position",
    ["_direction", 0],
    ["_spawnGoodPosition", true],
    ["_prefix", ""],
    ["_engineOn", false],
    ["_busy", false],
    ["_cargo", []],
    ["_slingload", []],
    ["_isSPE", false]
];

// Phase 3c.2b: vehicle/static substitution for inferred-faction redirects.
// Callers (mil_placement, mil_placement_spe, mil_logistics, mil_c2istar,
// mil_ato) pass the mod faction directly as _faction. When mil_placement's
// findVehicleType returned a vanilla A3 vehicle (because the mod faction
// has no entry in that category), substitute with a same-kindOf vehicle
// from the mod faction. Curated mappings (CustomFactions.hpp / sys_orbat
// creator output) deliberately keep their declared vehicles - the
// Inferred flag distinguishes inferred from curated.
//
// Crew (_crew, derived later from _vehicleClass via configGetVehicleCrew)
// will use the substituted vehicle's NATIVE crew config entry, which is
// already correct for the mod faction. No separate crew substitution
// needed at this hook point.
if (!isNil "ALIVE_factionCustomMappings" && {_faction in (ALIVE_factionCustomMappings select 1)}) then {
    private _customMappings = [ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet;
    if ([_customMappings,"Inferred", false] call ALIVE_fnc_hashGet) then {
        _vehicleClass = [_vehicleClass, _faction] call ALiVE_fnc_substituteFactionVehicle;
    };
};

private _vehiclePositions = [_vehicleClass] call ALIVE_fnc_configGetVehicleEmptyPositions;
private _vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;
private _crewCountPositions =  if (_vehicleKind != "StaticWeapon") then { count _vehiclePositions - 3 } else { count _vehiclePositions };

 private _countCrewPositions = 0;
for "_i" from 0 to _crewCountPositions - 1  do {
    _countCrewPositions = _countCrewPositions + (_vehiclePositions select _i);
};

// get crew classes

private _crew = _vehicleClass call ALIVE_fnc_configGetVehicleCrew;
private _crewClasses = [];
private _crewPositions = [];
for "_i" from 0 to _countCrewPositions - 1 do {
    _crewClasses pushBack _crew;
    _crewPositions pushBack +_position;
};

private _profileEntity = [_crewClasses, _side, _faction, +_position, 0, "", _busy, _prefix, _spawnGoodPosition, _rank, _crewPositions, false, "SAFE"] call ALIVE_fnc_createProfileEntity;
private _profileVehicle = [_vehicleClass, _side, _faction, +_position, _direction,_spawnGoodPosition, _prefix, _cargo, _isSPE, _engineOn, _slingload,_busy, "AWARE"] call ALIVE_fnc_createProfileVehicle;

[_profileEntity, _profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;


[_profileEntity, _profileVehicle]
