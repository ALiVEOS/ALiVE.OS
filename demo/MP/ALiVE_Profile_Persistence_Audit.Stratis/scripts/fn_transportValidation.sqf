// Scheduled transport regression: production PNS loaders and vehicle spawners.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _make = {
    params ["_alias", "_class", "_position", ["_cargo", []], ["_slingload", []]];
    [_class, "WEST", "BLU_F", _position, 0, false, "PA_transport_" + _alias,
        _cargo, false, false, _slingload] call ALIVE_fnc_createProfileVehicle
};
private _truck = ["truck", "B_Truck_01_transport_F", [1810, 5200, 0], ["B_supplyCrate_F", "B_supplyCrate_F"]] call _make;
private _load = ["load", "B_Quadbike_01_F", [1810, 5300, 0], ["Land_CanisterFuel_F"]] call _make;
private _loadID = [_load, "profileID"] call ALIVE_fnc_hashGet;
private _carrier = ["carrier", "B_Heli_Transport_03_unarmed_F", [1810, 5360, 0], [], [[_loadID], []]] call _make;
private _carrierID = [_carrier, "profileID"] call ALIVE_fnc_hashGet;
[_load, "slung", [[_carrierID], []]] call ALIVE_fnc_profileVehicle;
private _classCarrier = ["classCarrier", "B_Heli_Transport_03_unarmed_F", [1810, 5500, 0], [],
    ["B_supplyCrate_F", ["Land_CanisterFuel_F"]]] call _make;
private _legacy = ["legacy", "B_MRAP_01_F", [1810, 5600, 0]] call _make;
private _empty = ["empty", "B_MRAP_01_F", [1810, 5660, 0]] call _make;
private _fixtures = [];
{
    _x params ["_alias", "_profile"];
    _fixtures pushBack [_alias, [_profile, "profileID"] call ALIVE_fnc_hashGet,
        ["cargo", "slingload", "slung"] apply {[_x, [_profile, _x] call ALIVE_fnc_hashGet]}];
} forEach [["truck", _truck], ["carrier", _carrier], ["load", _load],
    ["classCarrier", _classCarrier], ["legacy", _legacy], ["empty", _empty]];
ALIVE_saveProfilesPersistent = true;
[true] call ALIVE_fnc_profilesSaveData;
private _saved = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
private _valid = [_saved] call ALIVE_fnc_isHash;
["Transport / PNS document readable", _valid, true, _valid] call PA_fnc_assert;
if (!_valid) exitWith {};
["Transport / all fixture IDs saved", count (_saved select 1) == count _fixtures
    && {(_fixtures findIf {!((_x select 1) in (_saved select 1))}) == -1},
    _fixtures apply {_x select 1}, _saved select 1] call PA_fnc_assert;
private _legacyID = [_legacy, "profileID"] call ALIVE_fnc_hashGet;
private _legacyRecord = [_saved, _legacyID] call ALIVE_fnc_hashGet;
{[_legacyRecord, _x] call ALIVE_fnc_hashRem} forEach ["cargo", "slingload", "slung"];
private _legacyKey = format ["ALiVE_%1_%2", missionName, worldName];
private _legacyExisted = !isNil {profileNamespace getVariable _legacyKey};
private _legacyOriginal = profileNamespace getVariable [_legacyKey, false];
private _spawn = {
    params ["_profile", "_label"];
    private _task = [_profile, "spawn"] spawn ALIVE_fnc_profileVehicle;
    private _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.05; (scriptDone _task && {[_profile, "active"] call ALIVE_fnc_hashGet}) || {diag_tickTime > _deadline}};
    private _finished = scriptDone _task;
    if (!_finished) then {terminate _task};
    private _vehicle = [_profile, "vehicle"] call ALIVE_fnc_hashGet;
    [_label, _finished && {!isNull _vehicle} && {[_profile, "active"] call ALIVE_fnc_hashGet},
        "active vehicle", if (isNull _vehicle) then {"missing"} else {typeOf _vehicle}] call PA_fnc_assert;
    if (!isNull _vehicle) then {_vehicle allowDamage false};
    _vehicle
};
private _cargoCheck = {
    params ["_vehicle", "_expected", "_label"];
    private _objects = _vehicle getVariable ["ALiVE_SYS_LOGISTICS_CARGO", []];
    private _actual = _objects apply {typeOf _x};
    private _classes = +_expected;
    _actual sort true; _classes sort true;
    [_label, !isNull _vehicle && {_actual isEqualTo _classes}
        && {(_objects findIf {isNull _x || {!((_x getVariable ["ALiVE_SYS_LOGISTICS_CONTAINER", objNull]) isEqualTo _vehicle)}}) == -1},
        _classes, _actual] call PA_fnc_assert;
};
{
    _x params ["_loaderName", "_firstAlias", "_loader"];
    private _case = _loaderName + " / " + _firstAlias + " first";
    private _firstID = [_carrierID, _loadID] select (_firstAlias == "load");
    private _ordered = [] call ALIVE_fnc_hashCreate;
    private _ids = [_firstID] + ((_saved select 1) - [_firstID]);
    {[_ordered, _x, [_saved, _x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet} forEach _ids;
    [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _ordered, PA_missionKey, false]] call ALIVE_fnc_Data;
    private _written = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
    ["Transport / " + _case + ": record order saved", (_written select 1) isEqualTo _ids,
        _ids, _written select 1] call PA_fnc_assert;
    private _legacyStore = [] call ALIVE_fnc_hashCreate;
    [_legacyStore, "ALiVE_SYS_PROFILE", _ordered] call ALIVE_fnc_hashSet;
    profileNamespace setVariable [_legacyKey, _legacyStore];
    ALIVE_loadProfilesPersistent = true;
    ALiVE_sysProfileLastLoadTime = nil;
    [{params ["_loader"]; call _loader}, [_loader]] call CBA_fnc_directCall;
    {
        _x params ["_alias", "_id", "_fields"];
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        private _label = "Transport / " + _case + " / " + _alias;
        [_label + ": profile restored", !isNil "_profile", _id,
            if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
        if (!isNil "_profile") then {
            {
                _x params ["_field", "_expected"];
                private _actual = [_profile, _field, "(missing)"] call ALIVE_fnc_hashGet;
                [_label + ": " + _field + " restored", _actual isEqualTo _expected,
                    _expected, _actual] call PA_fnc_assert;
            } forEach _fields;
        };
    } forEach _fixtures;
    private _profiles = _fixtures apply {[ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler};
    private _prefix = "Transport / " + _case;
    private _truckVehicle = [_profiles select 0, _prefix + ": cargo truck spawned"] call _spawn;
    [_truckVehicle, ["B_supplyCrate_F", "B_supplyCrate_F"], _prefix + ": duplicate cargo recreated"] call _cargoCheck;
    private _first = [1, 2] select (_firstAlias == "load");
    private _second = [2, 1] select (_firstAlias == "load");
    [_profiles select _first, _prefix + ": first sling vehicle spawned"] call _spawn;
    [_profiles select _second, _prefix + ": second sling vehicle spawned"] call _spawn;
    private _carrierVehicle = [_profiles select 1, "vehicle"] call ALIVE_fnc_hashGet;
    private _loadVehicle = [_profiles select 2, "vehicle"] call ALIVE_fnc_hashGet;
    [_prefix + ": profiled sling attachment recreated", !isNull _carrierVehicle && {!isNull _loadVehicle}
        && {(getSlingLoad _carrierVehicle) isEqualTo _loadVehicle},
        "carrier attached to restored load", typeOf (getSlingLoad _carrierVehicle)] call PA_fnc_assert;
    [_loadVehicle, ["Land_CanisterFuel_F"], _prefix + ": profiled load cargo recreated"] call _cargoCheck;
    private _classVehicle = [_profiles select 3, _prefix + ": class sling carrier spawned"] call _spawn;
    private _classLoad = getSlingLoad _classVehicle;
    [_prefix + ": class sling attachment recreated", !isNull _classLoad && {typeOf _classLoad == "B_supplyCrate_F"},
        "B_supplyCrate_F", typeOf _classLoad] call PA_fnc_assert;
    [_classLoad, ["Land_CanisterFuel_F"], _prefix + ": class load cargo recreated"] call _cargoCheck;
    private _spawnedCargo = (_truckVehicle getVariable ["ALiVE_SYS_LOGISTICS_CARGO", []])
        + (_loadVehicle getVariable ["ALiVE_SYS_LOGISTICS_CARGO", []])
        + (_classLoad getVariable ["ALiVE_SYS_LOGISTICS_CARGO", []]);
    // Cleanup the test's stowed objects and class-created load through the real
    // despawn path. Release the load's protection only for fixture cleanup.
    [_profiles select 1, "despawn"] call ALIVE_fnc_profileVehicle;
    [_profiles select 2, "spawnType", []] call ALIVE_fnc_profileVehicle;
    {[_x, "despawn"] call ALIVE_fnc_profileVehicle} forEach _profiles;
    // deleteVehicle can finish at the end of the engine frame.
    private _cleanupDeadline = diag_tickTime + 3;
    waitUntil {
        sleep 0.05;
        ((_spawnedCargo findIf {!isNull _x}) == -1 && {isNull _classLoad})
            || {diag_tickTime > _cleanupDeadline}
    };
    [_prefix + ": spawned cargo cleaned up", (_spawnedCargo findIf {!isNull _x}) == -1
        && {isNull _classLoad}, "cargo and class-created load removed",
        [(_spawnedCargo select {!isNull _x}) apply {typeOf _x}, typeOf _classLoad]] call PA_fnc_assert;
} forEach [["Normal", "carrier", ALIVE_fnc_profilesLoadData],
    ["Normal", "load", ALIVE_fnc_profilesLoadData], ["Legacy PNS", "carrier", ALIVE_fnc_profilesLoadDataPNS]];
if (_legacyExisted) then {
    profileNamespace setVariable [_legacyKey, _legacyOriginal];
} else {
    profileNamespace setVariable [_legacyKey, nil];
};
