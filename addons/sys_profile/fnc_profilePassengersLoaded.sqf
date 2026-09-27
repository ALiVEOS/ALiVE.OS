#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profilePassengersLoaded);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profilePassengersLoaded

Description:
Read-only check that the entire entity profile is loaded as passengers in the
specified vehicle profile. Cargo seats and person turrets count; crew seats do not.

When both profiles are inactive, every unit index must have a passenger assignment
to this vehicle. When both are active, actual seat occupants are checked instead of
assignment records, and dead units are ignored. This does not create assignments,
order boarding, or change either profile.

Parameters:
Array - Passenger entity profile
Array - Vehicle profile

Returns:
Boolean - True when all passengers are loaded. False for partial loading, an empty
profile, no surviving active units, missing live objects, or profiles with different
activation states. Both arguments must be valid profiles of the specified types.

Examples:
_loaded = [_passengerProfile, _vehicleProfile] call ALIVE_fnc_profilePassengersLoaded;
---------------------------------------------------------------------------- */

params ["_profileEntity", "_profileVehicle"];

private _entityData = _profileEntity select 2;
private _vehicleData = _profileVehicle select 2;
private _unitClasses = _entityData select 11;
private _entityActive = _entityData select 1;
if (_unitClasses isEqualTo [] || {_entityActive != (_vehicleData select 1)}) exitWith {false};

if (_entityActive) exitWith {
    private _vehicle = _vehicleData select 10;
    private _units = _entityData select 21;
    // Missing objects may indicate an incomplete spawn, not a completed pickup.
    if (!alive _vehicle || {count _units != count _unitClasses} || {(_units findIf {isNull _x}) != -1}) exitWith {false};

    private _survivors = _units select {alive _x};
    private _passengers = ((fullCrew _vehicle) select {
        (_x select 1) == "cargo" || {_x select 4}
    }) apply {_x select 0};

    _survivors isNotEqualTo [] && {(_survivors findIf {!(_x in _passengers)}) == -1}
};

private _assignment = [_entityData select 7, _vehicleData select 4] call ALIVE_fnc_hashGet;
if (isNil "_assignment") exitWith {false};
private _seats = _assignment select 2;

private _passengerIndexes = (_seats select 4) + (_seats select 5);
private _loaded = true;
for "_index" from 0 to (count _unitClasses - 1) do {
    if !(_index in _passengerIndexes) exitWith {_loaded = false};
};
_loaded
