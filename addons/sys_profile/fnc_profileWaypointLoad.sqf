#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoad

Description:
Processes a LOAD waypoint belonging to a transport's crew entity profile.
Waypoint data must contain passengerProfileId and vehicleProfileId. The crew must
control that vehicle, and all three profiles must be unlocked and share the same
activation state. Active profiles use live leader/vehicle positions.

The waypoint's completionRadius is the pickup radius (25 metres when unspecified).
All three profiles must be within that radius before starting an assignment.
Inactive profiles must also be within the radius to complete loading. Active
profiles can finish boarding outside it, such as at a nearby helicopter landing site.
The entire passenger profile must fit; assignments to other vehicles or crew seats
leave the waypoint pending. Existing passenger assignments to this vehicle can be
completed without replacing them. Once every passenger has a seat reserved, calls
only wait for boarding rather than repeating capacity checks and assignment creation.

Inactive loading immediately merges passenger positions with the vehicle. Active
loading orders boarding through the vehicle assignment and waits for actual seat
occupants. Helicopters are ordered to lower for boarding and released when loaded.
Missing metadata or targets, activation transitions, and insufficient capacity all
return false. Waypoint advancement is left to the simulator or native waypoint.

Parameters:
Array - Crew entity profile
Array - LOAD profile waypoint

Returns:
Boolean - True when profilePassengersLoaded confirms loading; otherwise false.

Examples:
_complete = [_crewProfile, _loadWaypoint] call ALIVE_fnc_profileWaypointLoad;
---------------------------------------------------------------------------- */

params ["_crewProfile", "_waypoint"];

private _data = [_waypoint, "data"] call ALIVE_fnc_hashGet;
if (isNil "_data") exitWith {false};
private _passengerID = _data getOrDefault ["passengerProfileId", ""];
private _vehicleID = _data getOrDefault ["vehicleProfileId", ""];
if (_passengerID == (_crewProfile select 2 select 4) || {!(_vehicleID in (_crewProfile select 2 select 8))}) exitWith {false};

private _profilesById = [ALIVE_profileHandler, "profilesById"] call ALIVE_fnc_hashGet;
private _passengers = _profilesById get _passengerID;
private _vehicle = _profilesById get _vehicleID;
if (isNil "_passengers" || {isNil "_vehicle"}
    || {(_passengers select 2 select 5) != "entity"}
    || {(_vehicle select 2 select 5) != "vehicle"}
    || {(_passengers select 2 select 11) isEqualTo []}
) exitWith {false};

private _position = [_waypoint, "position"] call ALIVE_fnc_hashGet;
private _pickupRadius = [_waypoint, "completionRadius", -1] call ALIVE_fnc_hashGet;
if (_pickupRadius < 0) then {_pickupRadius = 25};
private _active = _crewProfile select 2 select 1;
private _profiles = [_crewProfile, _passengers, _vehicle];
if ((_profiles findIf {
    (_x select 2 select 1) != _active
    || {[_x, "locked", false] call ALIVE_fnc_hashGet}
}) != -1) exitWith {false};

private _vehicleObject = objNull;
// Assigned passengers' stored positions follow the vehicle even while boarding.
private _positions = if (_active) then {
    _vehicleObject = _vehicle select 2 select 10;
    private _crewLeader = leader (_crewProfile select 2 select 13);
    private _passengerLeader = leader (_passengers select 2 select 13);
    if (!alive _vehicleObject || {isNull _crewLeader} || {isNull _passengerLeader}) exitWith {[]};
    [getPosATL (vehicle _crewLeader), getPosATL (vehicle _passengerLeader), getPosATL _vehicleObject]
} else {
    _profiles apply {_x select 2 select 2}
};
// Virtual loading still requires arrival, even when all seats are already assigned.
if (_positions isEqualTo [] || {
    !_active && {(_positions findIf {(_x distance2D _position) > _pickupRadius}) != -1}
}) exitWith {false};

// A pickup must transport the whole entity, not just its currently unassigned units.
private _assignments = _passengers select 2 select 7;
private _assignment = [_assignments, _vehicleID] call ALIVE_fnc_hashGet;
if (((_assignments select 1) findIf {_x != _vehicleID}) != -1 || {
    !isNil "_assignment" && {(((_assignment select 2) select [0, 4]) findIf {_x isNotEqualTo []}) != -1}
}) exitWith {false};

if ([_passengers, _vehicle] call ALIVE_fnc_profilePassengersLoaded) exitWith {
    if (_active && {_vehicleObject isKindOf "Helicopter"}) then {
        _vehicleObject land "NONE";
    };
    true
};
// Reserved seats distinguish waiting for boarding from starting an assignment.
private _assignedIndexes = _assignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
private _needsAssignment = false;
{
    if !(_forEachIndex in _assignedIndexes) exitWith {_needsAssignment = true};
} forEach (_passengers select 2 select 11);
// Active pickup distance gates new assignments, not boarding already in progress.
if (!_needsAssignment || {
    _active && {(_positions findIf {(_x distance2D _position) > _pickupRadius}) != -1}
}) exitWith {false};
if (([_passengers, _vehicle] call ALIVE_fnc_profileVehicleCanFitPassengers) < 0) exitWith {false};

private _assigned = [_passengers, _vehicle, false, true] call ALIVE_fnc_createProfileVehicleAssignment;
if (_active) exitWith {
    // New assignments already issue orderGetIn. Do not repeat it while units board.
    if ((_assigned select 0) isNotEqualTo [] && {_vehicleObject isKindOf "Helicopter"}) then {
        _vehicleObject land "GET IN";
    };
    false
};
if !([_passengers, _vehicle] call ALIVE_fnc_profilePassengersLoaded) exitWith {false};
[_vehicle, "mergePositions"] call ALIVE_fnc_profileVehicle;
true
