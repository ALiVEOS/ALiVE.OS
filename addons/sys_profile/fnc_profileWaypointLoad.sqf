#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWaypointLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileWaypointLoad

Description:
Server-side LOAD processing for a transport's crew entity profile. Omit the
waypoint to resolve the current active LOAD visit and publish its completion to
the group owner. Pass a waypoint to process it directly, including virtual LOADs.
Waypoint data must contain passengerProfileId and vehicleProfileId. The crew must
control that vehicle, and all three profiles must be unlocked and share the same
activation state. The entire passenger profile must fit in passenger seats.

The completionRadius is the pickup radius (25 metres when unspecified). All three
profiles must be within it before starting an assignment. Inactive profiles must
also be within it to complete loading. Active profiles can finish boarding outside
it, such as at a nearby helicopter landing site. Once every passenger has a seat
reserved, loading waits for boarding without repeating capacity or allocation.

Inactive loading merges passenger positions with the vehicle. Active loading
checks actual occupants and dispatches boarding/landing orders when ownership or
loading state changes. Remote command helpers handle acknowledgement and retries.
Waypoint advancement remains with the simulator or native waypoint condition.

Parameters:
Array - Crew entity profile
Array - LOAD profile waypoint (optional; omit to update the current active visit)

Returns:
Boolean - True when passengers are loaded; false while waiting or unable to load.

Examples:
[_crewProfile] call ALIVE_fnc_profileWaypointLoad;
_complete = [_crewProfile, _loadWaypoint] call ALIVE_fnc_profileWaypointLoad;
---------------------------------------------------------------------------- */

params ["_crewProfile", "_waypoint"];
if (!isServer) exitWith {false};

private _active = _crewProfile select 2 select 1;
private _group = _crewProfile select 2 select 13;
private _visit = _group getVariable ["ALIVE_profileLoadVisit", []];
private _updateActive = isNil "_waypoint";
if (_updateActive && {isNull _group || {_visit isEqualTo []}}) exitWith {false};

if (_updateActive) then {
    private _waypointName = _visit select 0;
    private _nativeWaypoint = [_group, currentWaypoint _group];
    if (_active && {!([_crewProfile, "locked", false] call ALIVE_fnc_hashGet)}
        && {_waypointName != ""}
        && {waypointName _nativeWaypoint == _waypointName}
        && {waypointType _nativeWaypoint == "LOAD"}
    ) then {
        private _waypoints = _crewProfile select 2 select 16;
        private _index = _waypoints findIf {([_x, "name"] call ALIVE_fnc_hashGet) == _waypointName};
        if (_index != -1) then {_waypoint = _waypoints select _index};
    };
};

private _data = if (isNil "_waypoint") then {nil} else {[_waypoint, "data"] call ALIVE_fnc_hashGet};
if (isNil "_data" || {!("passengerProfileId" in _data)} || {!("vehicleProfileId" in _data)}) exitWith {
    if (_updateActive) then {[_group, "", false] call ALIVE_fnc_profileWaypointLoadReset};
    false
};
private _passengerID = _data get "passengerProfileId";
private _vehicleID = _data get "vehicleProfileId";
private ["_passengers", "_vehicle"];
private _vehicleObject = objNull;
private _boardingOwner = -1;
private _dispatchOrders = false;

// Keep early loading exits inside this scope so active results are still published.
private _loaded = call {
    if (_passengerID == (_crewProfile select 2 select 4) || {!(_vehicleID in (_crewProfile select 2 select 8))}) exitWith {false};
    private _profilesById = [ALIVE_profileHandler, "profilesById"] call ALIVE_fnc_hashGet;
    _passengers = _profilesById get _passengerID;
    _vehicle = _profilesById get _vehicleID;
    if (isNil "_passengers" || {isNil "_vehicle"}
        || {(_passengers select 2 select 5) != "entity"}
        || {(_vehicle select 2 select 5) != "vehicle"}
        || {(_passengers select 2 select 11) isEqualTo []}
    ) exitWith {false};

    private _position = [_waypoint, "position"] call ALIVE_fnc_hashGet;
    private _pickupRadius = [_waypoint, "completionRadius", -1] call ALIVE_fnc_hashGet;
    if (_pickupRadius < 0) then {_pickupRadius = 25};
    private _profiles = [_crewProfile, _passengers, _vehicle];
    if ((_profiles findIf {
        (_x select 2 select 1) != _active
        || {[_x, "locked", false] call ALIVE_fnc_hashGet}
    }) != -1) exitWith {false};

    // Assigned passengers' stored positions follow the vehicle even while boarding.
    private _positions = if (_active) then {
        _vehicleObject = _vehicle select 2 select 10;
        private _crewLeader = leader _group;
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
        _dispatchOrders = _active;
        true
    };
    private _assignedIndexes = _assignments call ALIVE_fnc_profileVehicleAssignmentGetUsedIndexes;
    private _needsAssignment = false;
    {
        if !(_forEachIndex in _assignedIndexes) exitWith {_needsAssignment = true};
    } forEach (_passengers select 2 select 11);
    if (!_needsAssignment) exitWith {
        _dispatchOrders = _active;
        false
    };
    // Active pickup distance gates new assignments, not boarding already in progress.
    if (_active && {(_positions findIf {(_x distance2D _position) > _pickupRadius}) != -1}) exitWith {false};
    if (([_passengers, _vehicle] call ALIVE_fnc_profileVehicleCanFitPassengers) < 0) exitWith {false};

    if (_active) then {_boardingOwner = groupOwner (_passengers select 2 select 13)};
    private _assigned = [_passengers, _vehicle, false, true] call ALIVE_fnc_createProfileVehicleAssignment;
    if (_active) exitWith {
        // The new assignment already issued boarding orders to this owner.
        if ((_assigned select 0) isEqualTo []) then {_boardingOwner = -1};
        _dispatchOrders = true;
        false
    };
    if !([_passengers, _vehicle] call ALIVE_fnc_profilePassengersLoaded) exitWith {false};
    [_vehicle, "mergePositions"] call ALIVE_fnc_profileVehicle;
    true
};

// Assignment callbacks may replace the route; never dispatch for a superseded visit.
if (_dispatchOrders && {_visit isNotEqualTo []} && {(_visit select 0) != ""}
    && {(_group getVariable ["ALIVE_profileLoadVisit", []]) isEqualTo _visit}
) then {
    private _passengerGroup = _passengers select 2 select 13;
    private _passengerOwner = groupOwner _passengerGroup;
    private _vehicleOwner = owner _vehicleObject;
    private _mode = if (_loaded) then {"NONE"} else {"GET IN"};
    private _previous = _group getVariable ["ALIVE_profileLoadOrders", [[], grpNull, -1, objNull, -1, ""]];
    private _orders = [_visit, _passengerGroup, _passengerOwner, _vehicleObject, _vehicleOwner, _mode];
    if (_orders isNotEqualTo _previous) then {
        _previous params ["_previousVisit", "_previousPassengerGroup", "_previousPassengerOwner",
            "_previousVehicle", "_previousVehicleOwner", "_previousMode"];
        private _newPickup = !(_previousVisit isEqualTo _visit) || {_previousVehicle != _vehicleObject};
        private _modeChanged = _previousMode != _mode;
        if (_previousMode == "GET IN" && {_newPickup}) then {
            [_previousVehicle, "NONE", _group, _previousVisit] call ALIVE_fnc_profileWaypointLoadLand;
        };

        if (!_loaded && {_passengerOwner != _boardingOwner} && {
            _newPickup || {_previousPassengerGroup != _passengerGroup}
                || {_previousPassengerOwner != _passengerOwner} || {_modeChanged}
        }) then {
            private _assignment = [_passengers select 2 select 7, _vehicleID] call ALIVE_fnc_hashGet;
            [_assignment, _passengers, true] call ALIVE_fnc_profileVehicleAssignmentToVehicleAssignment;
        };
        if (_newPickup || {_previousVehicleOwner != _vehicleOwner} || {_modeChanged}) then {
            [_vehicleObject, _mode, _group, _visit] call ALIVE_fnc_profileWaypointLoadLand;
        };
        _group setVariable ["ALIVE_profileLoadOrders", _orders];
    };
};

if (_updateActive && {!((_group getVariable ["ALIVE_profileLoadVisit", []]) isEqualTo _visit)}) exitWith {false};
if (_updateActive) then {
    private _result = [_visit, _loaded];
    if !((_group getVariable ["ALIVE_profileLoadResult", []]) isEqualTo _result) then {
        _group setVariable ["ALIVE_profileLoadResult", _result, true];
    };
};
_loaded
