#include "\x\alive\addons\sys_GC\script_component.hpp"
SCRIPT(vehicleAbandoned);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_vehicleAbandoned

Description:
Whether a land vehicle profile is abandoned: nobody in it, and either disabled
or left by its crew longer than the delay.

Disabled is any of: the engine can't move it; ACE's vehicle damage has knocked
it out (ace_vehicle_damage_canMove false, the hull ACE leaves standing after the
crew bail out instead of blowing it up); or an engine or track hit point at 0.9
or more. A despawned profile is judged by the canMove and hit points it kept.
Left by its crew: ALiVE_fnc_GCAbandoned marks a profile whose crew is gone
(ALiVE_crewLost) and notes when; ambient vehicles placed empty never get the mark.

Works without ACE (the ACE check then reads its default).

Given a vehicle object instead (FPV drones' Abandoned Vehicles), it is abandoned
when it is a land vehicle, alive, with nobody alive in it, and disabled as above;
there is no crew-lost wait for an object.

Parameters:
    _profile - ARRAY - a vehicle profile, or OBJECT - a vehicle
    _delay   - NUMBER - seconds since the crew was lost before an undamaged vehicle counts (profiles only)

Returns:
    BOOL

Examples:
    (begin example)
    private _abandoned = [_profile, 900] call ALiVE_fnc_vehicleAbandoned;
    (end)

See Also:
    ALiVE_fnc_GCAbandoned

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_profile", [], [[], objNull]], ["_delay", 900, [0]]];

private _fnc_hitDisabled = {
    (_this findIf {
        _x params [["_name", ""], ["_dmg", 0]];
        _dmg isEqualType 0 && {_dmg >= 0.9} && {_name isEqualType ""} && {((toLower _name) find "engine") >= 0 || {((toLower _name) find "track") >= 0}}
    }) >= 0
};
// a vehicle in the game: alive, nobody alive in it, and knocked out
private _fnc_objDisabled = {
    alive _this && {((crew _this) findIf { alive _x }) < 0}
        && {!canMove _this
            || {!(_this getVariable ["ace_vehicle_damage_canMove", true])}
            || {(_this call ALIVE_fnc_vehicleGetDamage) call _fnc_hitDisabled}}
};

// a vehicle object rather than a profile (FPV drones): empty and disabled, with no wait
if (_profile isEqualType objNull) exitWith { !isNull _profile && {_profile isKindOf "LandVehicle"} && {_profile call _fnc_objDisabled} };

if (_profile isEqualTo []) exitWith { false };
if !(([_profile, "entitiesInCommandOf", []] call ALIVE_fnc_hashGet) isEqualTo []) exitWith { false };
if !(([_profile, "entitiesInCargoOf", []] call ALIVE_fnc_hashGet) isEqualTo []) exitWith { false };

private _veh = [_profile, "vehicle", objNull] call ALIVE_fnc_hashGet;
private _disabled = false;
if (!isNull _veh && {[_profile, "active", false] call ALIVE_fnc_hashGet}) then {
    if (!alive _veh) exitWith {};
    if (((crew _veh) findIf { alive _x }) >= 0) exitWith { _disabled = -1 };
    _disabled = _veh call _fnc_objDisabled;
} else {
    _disabled = !([_profile, "canMove", true] call ALIVE_fnc_hashGet)
        || {([_profile, "damage", []] call ALIVE_fnc_hashGet) call _fnc_hitDisabled};
};
if (_disabled isEqualTo -1) exitWith { false };
if (_disabled isEqualTo true) exitWith { true };

// undamaged: abandoned once its crew has been gone longer than the delay
if !([_profile, "ALiVE_crewLost", false] call ALIVE_fnc_hashGet) exitWith { false };
private _lostAt = (missionNamespace getVariable ["ALiVE_GC_crewLostAt", createHashMap]) getOrDefault [[_profile, "profileID", ""] call ALIVE_fnc_hashGet, 1e9];
(time - _lostAt) >= _delay
