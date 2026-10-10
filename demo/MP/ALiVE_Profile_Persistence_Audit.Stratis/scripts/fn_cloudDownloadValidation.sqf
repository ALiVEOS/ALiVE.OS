// Real bulk reader, bulk loader and profile loader; only extension/index I/O is local.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
private _oldHandler = ALIVE_profileDatahandler;
private _oldPlugin = ALIVE_fnc_sendToPlugIn;
private _oldDictionary = +ALIVE_DataDictionary;
private _oldPersistent = ALIVE_loadProfilesPersistent;
private _hadLastLoad = !isNil "ALiVE_sysProfileLastLoadTime";
private _oldLastLoad = missionNamespace getVariable ["ALiVE_sysProfileLastLoadTime", 0];
ALIVE_fnc_bulkLoadData_pa_download = ALIVE_fnc_bulkLoadData_couchdb;
ALIVE_fnc_bulkReadData_pa_download = ALIVE_fnc_bulkReadData_couchdb;
ALIVE_fnc_restoreData_pa_download = ALIVE_fnc_restoreData_couchdb;
ALIVE_fnc_readData_pa_download = {
    params ["_handler", "_args"];
    if ((_args select 2) == PA_missionKey) then {
        [[["_rev", "1-audit"], ["index", [_handler, "PA_index"] call ALIVE_fnc_hashGet]]] call ALIVE_fnc_hashCreate
    } else {"SYS_DATA_ERROR"}
};
private _codec = [[["source", "couchdb"], ["storeType", true]]] call ALIVE_fnc_hashCreate;
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _ids = [];
{
    private _profile = [["B_Soldier_F"], "WEST", "BLU_F", [1810, 5520, 0], 0, "", false,
        "PA_download_" + _x, false, "PRIVATE", [[1810, 5520, 0]]] call ALIVE_fnc_createProfileEntity;
    _ids pushBack ([_profile, "profileID"] call ALIVE_fnc_hashGet);
} forEach ["A", "B"];
private _records = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
private _wires = [];
{
    private _record = [_records, _x] call ALIVE_fnc_hashGet;
    [_record, "_id", PA_missionKey + "-" + _x] call ALIVE_fnc_hashSet;
    _wires pushBack ([_codec, "convert", [_record]] call ALIVE_fnc_Data);
} forEach _ids;
private _noID = [([_records, _ids select 0] call ALIVE_fnc_hashGet)] call ALIVE_fnc_hashCopy;
[_noID, "_id"] call ALIVE_fnc_hashRem;
private _noIDWire = [_codec, "convert", [_noID]] call ALIVE_fnc_Data;
private _unexpected = [([_records, _ids select 0] call ALIVE_fnc_hashGet)] call ALIVE_fnc_hashCopy;
[_unexpected, "_id", "not-requested"] call ALIVE_fnc_hashSet;
private _unexpectedWire = [_codec, "convert", [_unexpected]] call ALIVE_fnc_Data;
{
    _x params ["_case", "_index", "_replies", "_loadedIDs"];
    private _success = _loadedIDs isEqualType [];
    private _handler = [[["source", "pa_download"], ["PA_index", _index]]] call ALIVE_fnc_hashCreate;
    private _responses = +_replies;
    private _bulk = false;
    [{
        ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
        _bulk = [_handler, "bulkRead", ["sys_profile", PA_missionKey, _index]] call ALIVE_fnc_Data;
        ALIVE_fnc_sendToPlugIn = _oldPlugin;
    }, []] call CBA_fnc_directCall;
    private _valid = [_bulk] call ALIVE_fnc_isHash;
    private _correct = if (_success) then {
        _valid && {(_bulk select 1) isEqualTo _loadedIDs}
            && {((_bulk select 2) apply {[_x, "profileID"] call ALIVE_fnc_hashGet}) isEqualTo _loadedIDs}
    } else {_bulk isEqualTo "SYS_DATA_ERROR"};
    private _label = "Cloud download / " + _case;
    [_label + ": bulk result", _correct, if (_success) then {_loadedIDs} else {"SYS_DATA_ERROR"},
        if (_valid) then {_bulk select 1} else {_bulk}] call PA_fnc_assert;
    [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
    private _seed = [["B_Soldier_F"], "WEST", "BLU_F", [1810, 5520, 0], 0, "", false,
        "PA_download_seed", false, "PRIVATE", [[1810, 5520, 0]]] call ALIVE_fnc_createProfileEntity;
    private _seedID = [_seed, "profileID"] call ALIVE_fnc_hashGet;
    ALIVE_profileDatahandler = _handler;
    _responses = +_replies;
    [{
        ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
        ALIVE_loadProfilesPersistent = true;
        ALiVE_sysProfileLastLoadTime = nil;
        call ALIVE_fnc_profilesLoadData;
        ALIVE_fnc_sendToPlugIn = _oldPlugin;
    }, []] call CBA_fnc_directCall;
    private _exists = !isNil {[ALIVE_profileHandler, "getProfile", _seedID] call ALIVE_fnc_profileHandler};
    [_label + ": seed state", _exists isEqualTo !_success, !_success, _exists] call PA_fnc_assert;
    [_label + ": persistence state", ALIVE_loadProfilesPersistent isEqualTo _success,
        _success, ALIVE_loadProfilesPersistent] call PA_fnc_assert;
    private _actualIDs = +(([ALIVE_profileHandler, "getProfiles"] call ALIVE_fnc_profileHandler) select 1);
    private _expectedIDs = if (_success) then {+_loadedIDs} else {[_seedID]};
    _actualIDs sort true;
    _expectedIDs sort true;
    [_label + ": profile IDs", _actualIDs isEqualTo _expectedIDs, _expectedIDs, _actualIDs] call PA_fnc_assert;
} forEach [
    ["start error", [_ids select 0], ["SYS_DATA_ERROR"], false],
    ["stream error", [_ids select 0], ["READY", "SYS_DATA_ERROR"], false],
    ["partial stream error", _ids, ["READY", _wires select 0, "SYS_DATA_ERROR"], [_ids select 0]],
    ["missing document", [_ids select 0], ["READY", "END"], false],
    ["partial missing document", _ids, ["READY", _wires select 0, "END"], [_ids select 0]],
    ["duplicate missing document", _ids, ["READY", _wires select 0, _wires select 0, "END"], [_ids select 0]],
    ["malformed document", [_ids select 0], ["READY", "{""a"":}", "END"], false],
    ["missing ID", [_ids select 0], ["READY", _noIDWire, "END"], false],
    ["unexpected ID", [_ids select 0], ["READY", _unexpectedWire, "END"], false],
    ["malformed first", _ids, ["READY", "{""a"":}", _wires select 1, "END"], [_ids select 1]],
    ["malformed last", _ids, ["READY", _wires select 0, "{""a"":}", "END"], [_ids select 0]],
    ["missing ID first", _ids, ["READY", _noIDWire, _wires select 1, "END"], [_ids select 1]],
    ["unexpected ID first", _ids, ["READY", _unexpectedWire, _wires select 1, "END"], [_ids select 1]],
    ["empty stream error", [], ["READY", "SYS_DATA_ERROR"], false],
    ["empty unexpected document", [], ["READY", _wires select 0, "END"], false],
    ["empty", [], ["READY", "END"], []],
    ["populated", [_ids select 0], ["OK", _wires select 0, "END"], [_ids select 0]],
    ["populated reverse", [_ids select 1, _ids select 0], ["READY", _wires select 0, _wires select 1, "END"], [_ids select 1, _ids select 0]]
];
// Other persistence modules retain their complete-download contract.
private _strict = false;
private _responses = ["READY", _wires select 0, "SYS_DATA_ERROR"];
private _handler = [[["source", "pa_download"]]] call ALIVE_fnc_hashCreate;
[{
    ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
    _strict = [_handler, "bulkRead", ["sys_player", PA_missionKey, _ids]] call ALIVE_fnc_Data;
    ALIVE_fnc_sendToPlugIn = _oldPlugin;
}, []] call CBA_fnc_directCall;
["Cloud download / other module remains strict", _strict isEqualTo "SYS_DATA_ERROR",
    "SYS_DATA_ERROR", _strict] call PA_fnc_assert;

// A recovered crew must walk and replay its orders if its vehicle was skipped.
private _driverID = "";
private _vehicleID = "";
private _driverWire = "";
private _vehicleWire = "";
private _goal = [1907, 5631, 0];
[{
    [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
    private _driver = [["B_Soldier_F"], "WEST", "BLU_F", [1810, 5620, 0], 0, "", false,
        "PA_partial_driver", false, "PRIVATE", [[1810, 5620, 0]]] call ALIVE_fnc_createProfileEntity;
    private _vehicle = ["B_Quadbike_01_F", "WEST", "BLU_F", [1810, 5620, 0], 0, false,
        "PA_partial_vehicle"] call ALIVE_fnc_createProfileVehicle;
    [_driver, _vehicle] call ALIVE_fnc_createProfileVehicleAssignment;
    _driverID = [_driver, "profileID"] call ALIVE_fnc_hashGet;
    _vehicleID = [_vehicle, "profileID"] call ALIVE_fnc_hashGet;
    [_driver, "addWaypoint", [_goal, 2, "MOVE", "FULL", 7] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
    private _saved = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
    {
        private _record = [_saved, _x] call ALIVE_fnc_hashGet;
        [_record, "_id", PA_missionKey + "-" + _x] call ALIVE_fnc_hashSet;
    } forEach [_driverID, _vehicleID];
    _driverWire = [_codec, "convert", [([_saved, _driverID] call ALIVE_fnc_hashGet)]] call ALIVE_fnc_Data;
    _vehicleWire = [_codec, "convert", [([_saved, _vehicleID] call ALIVE_fnc_hashGet)]] call ALIVE_fnc_Data;
    [ALIVE_Pathfinder, "cancelProfilePaths", _driverID] call ALIVE_fnc_pathfinder;
}, []] call CBA_fnc_directCall;
_handler = [[["source", "pa_download"], ["PA_index", [_driverID, _vehicleID]]]] call ALIVE_fnc_hashCreate;
ALIVE_profileDatahandler = _handler;
_responses = ["READY", _driverWire, "END"];
private _driver = [];
[{
    ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
    ALIVE_loadProfilesPersistent = true;
    ALiVE_sysProfileLastLoadTime = nil;
    call ALIVE_fnc_profilesLoadData;
    ALIVE_fnc_sendToPlugIn = _oldPlugin;
    _driver = [ALIVE_profileHandler, "getProfile", _driverID] call ALIVE_fnc_profileHandler;
    ["Cloud download / missing vehicle: crew retained", !isNil "_driver", _driverID,
        if (isNil "_driver") then {"missing"} else {_driverID}] call PA_fnc_assert;
    ["Cloud download / missing vehicle: vehicle excluded",
        isNil {[ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler},
        "missing", _vehicleID] call PA_fnc_assert;
    if (!isNil "_driver") then {
        private _assignments = [_driver, "vehicleAssignments"] call ALIVE_fnc_hashGet;
        ["Cloud download / missing vehicle: assignments cleared", (_assignments select 1) isEqualTo [],
            [], _assignments select 1] call PA_fnc_assert;
        private _links = [_driver, ["vehiclesInCommandOf", "vehiclesInCargoOf"]] call ALIVE_fnc_hashGetMany;
        ["Cloud download / missing vehicle: links cleared", _links isEqualTo [[], []], [[], []], _links] call PA_fnc_assert;
        private _walking = "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond;
        private _speed = [_driver, "speedPerSecond"] call ALIVE_fnc_hashGet;
        ["Cloud download / missing vehicle: walking speed", _speed isEqualTo _walking, _walking, _speed] call PA_fnc_assert;
        private _jobs = (ALIVE_Pathfinder get "pathJobs") select {(_x select 4 select 0) == _driverID};
        ["Cloud download / missing vehicle: walking path", count _jobs == 1 && {(_jobs select 0 select 1 select 0) == "Man"},
            ["Man"], _jobs apply {_x select 1 select 0}] call PA_fnc_assert;
    };
}, []] call CBA_fnc_directCall;
if (!isNil "_driver") then {
    private _deadline = diag_tickTime + 30;
    waitUntil {sleep 0.1; count ([_driver, "pendingWaypointPaths", []] call ALIVE_fnc_hashGet) == 0 || {diag_tickTime > _deadline}};
    private _route = [_driver, "waypoints"] call ALIVE_fnc_hashGet;
    ["Cloud download / missing vehicle: order applied",
        (_route findIf {([_x, "position"] call ALIVE_fnc_hashGet) isEqualTo _goal}) >= 0,
        _goal, _route apply {[_x, "position"] call ALIVE_fnc_hashGet}] call PA_fnc_assert;
};
// The reciprocal case must drop a missing crew from the surviving vehicle.
_responses = ["READY", _vehicleWire, "END"];
[{
    ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
    ALIVE_loadProfilesPersistent = true;
    ALiVE_sysProfileLastLoadTime = nil;
    call ALIVE_fnc_profilesLoadData;
    ALIVE_fnc_sendToPlugIn = _oldPlugin;
    private _vehicle = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
    ["Cloud download / missing crew: vehicle retained", !isNil "_vehicle", _vehicleID,
        if (isNil "_vehicle") then {"missing"} else {_vehicleID}] call PA_fnc_assert;
    if (!isNil "_vehicle") then {
        private _assignments = [_vehicle, "vehicleAssignments"] call ALIVE_fnc_hashGet;
        private _links = [_vehicle, ["entitiesInCommandOf", "entitiesInCargoOf"]] call ALIVE_fnc_hashGetMany;
        ["Cloud download / missing crew: links cleared",
            (_assignments select 1) isEqualTo [] && {_links isEqualTo [[], []]},
            [[], [[], []]], [_assignments select 1, _links]] call PA_fnc_assert;
    };
}, []] call CBA_fnc_directCall;
// Profile sling links are cleared when the other endpoint was excluded.
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _load = ["B_Quadbike_01_F", "WEST", "BLU_F", [1810, 5520, 0], 0, false,
    "PA_partial_sling_load"] call ALIVE_fnc_createProfileVehicle;
private _loadID = [_load, "profileID"] call ALIVE_fnc_hashGet;
private _carrier = ["B_Heli_Transport_03_unarmed_F", "WEST", "BLU_F", [1810, 5520, 0], 0, false,
    "PA_partial_sling_carrier", [], false, false, [[_loadID], []]] call ALIVE_fnc_createProfileVehicle;
private _carrierID = [_carrier, "profileID"] call ALIVE_fnc_hashGet;
[_load, "slung", [[_carrierID], []]] call ALIVE_fnc_profileVehicle;
private _slingRecords = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
_handler = [[["source", "pa_download"], ["PA_index", [_carrierID, _loadID]]]] call ALIVE_fnc_hashCreate;
ALIVE_profileDatahandler = _handler;
{
    _x params ["_alias", "_id", "_field"];
    private _record = [_slingRecords, _id] call ALIVE_fnc_hashGet;
    [_record, "_id", PA_missionKey + "-" + _id] call ALIVE_fnc_hashSet;
    _responses = ["READY", [_codec, "convert", [_record]] call ALIVE_fnc_Data, "END"];
    [{
        ALIVE_fnc_sendToPlugIn = {_responses deleteAt 0};
        ALIVE_loadProfilesPersistent = true;
        ALiVE_sysProfileLastLoadTime = nil;
        call ALIVE_fnc_profilesLoadData;
        ALIVE_fnc_sendToPlugIn = _oldPlugin;
    }, []] call CBA_fnc_directCall;
    private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
    private _label = "Cloud download / missing sling partner / " + _alias;
    [_label + ": restored", !isNil "_profile", _id,
        if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
    if (!isNil "_profile") then {
        private _link = [_profile, _field] call ALIVE_fnc_hashGet;
        [_label + ": link cleared", _link isEqualTo [], [], _link] call PA_fnc_assert;
    };
} forEach [["carrier", _carrierID, "slingload"], ["load", _loadID, "slung"]];
ALIVE_profileDatahandler = _oldHandler;
ALIVE_fnc_sendToPlugIn = _oldPlugin;
ALIVE_DataDictionary = _oldDictionary;
ALIVE_loadProfilesPersistent = _oldPersistent;
ALiVE_sysProfileLastLoadTime = if (_hadLastLoad) then {_oldLastLoad} else {nil};
