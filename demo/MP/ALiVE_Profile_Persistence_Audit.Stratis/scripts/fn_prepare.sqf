// Called only inside this mission, on the server, while profiles are paused.
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
PA_fixtures = [];
private _entity = {
    params ["_alias", "_classes", "_position"];
    private _profile = [_classes, "WEST", "BLU_F", _position, 0, "", false,
        "PA_" + _alias, false, "SERGEANT", _classes apply {+_position}] call ALIVE_fnc_createProfileEntity;
    PA_fixtures pushBack [_alias, [_profile, "profileID"] call ALIVE_fnc_hashGet];
    _profile
};
private _vehicle = {
    params ["_alias", "_class", "_position"];
    private _profile = [_class, "WEST", "BLU_F", _position, 0, false,
        "PA_" + _alias] call ALIVE_fnc_createProfileVehicle;
    PA_fixtures pushBack [_alias, [_profile, "profileID"] call ALIVE_fnc_hashGet];
    _profile
};
private _crew = ["mounted", ["B_crew_F", "B_crew_F"], [1810, 5500, 0]] call _entity;
private _mrap = ["attritionVehicle", "B_MRAP_01_hmg_F", [1810, 5500, 0]] call _vehicle;
[_crew, _mrap] call ALIVE_fnc_createProfileVehicleAssignment;
private _hook = ["hook", ["B_Soldier_F"], [1810, 5520, 0]] call _entity;
[_hook, "onEachSpawn", '_this params ["_unit"]; _unit setVariable ["PA_hookRan", true, true];'] call ALIVE_fnc_profileEntity;
[_hook, "onEachSpawnOnce", false] call ALIVE_fnc_profileEntity;
private _injured = ["injured", ["B_Soldier_F"], [1810, 5540, 0]] call _entity;
[_injured, "damages", [0.4]] call ALIVE_fnc_profileEntity;

// Capture real vanilla vehicle state rather than inventing ammo/hitpoint schemas.
private _sample = createVehicle ["B_MRAP_01_hmg_F", [1810, 5560, 0], [], 0, "NONE"];
_sample setFuel 0.25;
_sample setDamage 0.35;
_sample setVehicleAmmo 0.25;
[_mrap, "fuel", fuel _sample] call ALIVE_fnc_profileVehicle;
[_mrap, "damage", _sample call ALIVE_fnc_vehicleGetDamage] call ALIVE_fnc_profileVehicle;
[_mrap, "ammo", _sample call ALIVE_fnc_vehicleGetAmmo] call ALIVE_fnc_profileVehicle;
deleteVehicle _sample;

private _cargo = ["cargo", "B_Truck_01_transport_F", [1810, 5580, 0]] call _vehicle;
[_cargo, "cargo", ["B_supplyCrate_F"]] call ALIVE_fnc_profileVehicle;
private _carrier = ["carrier", "B_Heli_Transport_03_unarmed_F", [1810, 5600, 0]] call _vehicle;
[_carrier, "slingload", [[[_cargo, "profileID"] call ALIVE_fnc_hashGet], []]] call ALIVE_fnc_profileVehicle;
[_cargo, "slung", [[[_carrier, "profileID"] call ALIVE_fnc_hashGet], []]] call ALIVE_fnc_profileVehicle;

// A quadbike cannot carry the whole group: the unmounted member must keep
// the group at walking speed after its unit count has been restored.
private _partial = ["partlyMounted", ["B_crew_F", "B_crew_F", "B_Soldier_F"], [1810, 5640, 0]] call _entity;
private _partialVehicle = ["partialVehicle", "B_Quadbike_01_F", [1810, 5640, 0]] call _vehicle;
[_partial, _partialVehicle] call ALIVE_fnc_createProfileVehicleAssignment;
private _partialAssigned = ([_partial, "vehicleAssignments"] call ALIVE_fnc_hashGet) call ALIVE_fnc_profileVehicleAssignmentsGetCount;
private _partialReady = ["Partly mounted fixture has someone on foot and walking speed",
    _partialAssigned > 0 && {_partialAssigned < 3}
        && {([_partial, "speedPerSecond"] call ALIVE_fnc_hashGet) isEqualTo ("Man" call ALIVE_fnc_vehicleGetSpeedPerSecond)},
    "some assigned units, one or more on foot", [_partialAssigned, [_partial, "speedPerSecond"] call ALIVE_fnc_hashGet]] call PA_fnc_assert;

private _mixed = ["multipleVehicles", ["B_crew_F", "B_crew_F", "B_crew_F", "B_crew_F"], [1810, 5660, 0]] call _entity;
private _fast = ["fastVehicle", "B_Quadbike_01_F", [1810, 5660, 0]] call _vehicle;
private _slow = ["slowVehicle", "B_Truck_01_transport_F", [1810, 5680, 0]] call _vehicle;
[_mixed, _fast] call ALIVE_fnc_createProfileVehicleAssignment;
[_mixed, _slow] call ALIVE_fnc_createProfileVehicleAssignment;
private _quadSpeed = "B_Quadbike_01_F" call ALIVE_fnc_vehicleGetSpeedPerSecond;
private _truckSpeed = "B_Truck_01_transport_F" call ALIVE_fnc_vehicleGetSpeedPerSecond;
private _expectedMixed = if ((_quadSpeed select 0) < (_truckSpeed select 0)) then {_quadSpeed} else {_truckSpeed};
private _mixedAssigned = ([_mixed, "vehicleAssignments"] call ALIVE_fnc_hashGet) call ALIVE_fnc_profileVehicleAssignmentsGetCount;
private _mixedReady = ["Multiple-vehicle fixture uses the slowest transport speed",
    _mixedAssigned == 4 && {count ([_mixed, "vehiclesInCommandOf"] call ALIVE_fnc_hashGet) == 2}
        && {(_quadSpeed select 0) != (_truckSpeed select 0)}
        && {([_mixed, "speedPerSecond"] call ALIVE_fnc_hashGet) isEqualTo _expectedMixed},
    _expectedMixed, [_mixed, "speedPerSecond"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
["onFoot", ["B_Soldier_F"], [1810, 5650, 0]] call _entity;

private _pending = ["pending", ["B_Soldier_F"], [1810, 5620, 0]] call _entity;
private _control = [[1850, 5620, 0], 0, "MOVE", "NORMAL", 5] call ALIVE_fnc_createProfileWaypoint;
[_pending, "addWaypointInternal", _control] call ALIVE_fnc_profileEntity;
PA_pendingDestination = [2300, 5800, 0];
private _order = [PA_pendingDestination, 0, "MOVE", "NORMAL", 5] call ALIVE_fnc_createProfileWaypoint;
// Dispatch the actual pathfinding request. The surrounding directCall prevents
// its scheduled callback from finishing between queuing and the save.
[_pending, "addWaypoint", _order] call ALIVE_fnc_profileEntity;
private _queued = [_pending, "pendingWaypointPaths", []] call ALIVE_fnc_hashGet;
private _pendingReady = ["Fixture has a real pathfinding order pending at save time", count _queued > 0, ">0", count _queued] call PA_fnc_assert;
private _mountedReady = ["Mounted fixture has vehicle speed before saving",
    !(([_crew, "speedPerSecond"] call ALIVE_fnc_hashGet) isEqualTo ("Man" call ALIVE_fnc_vehicleGetSpeedPerSecond)),
    "vehicle speed", [_crew, "speedPerSecond"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
_pendingReady && _mountedReady && _partialReady && _mixedReady
