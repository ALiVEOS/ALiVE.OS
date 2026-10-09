if (isNil "ALIVE_fnc_bulkSaveData_couchdb" || {isNil "ALIVE_fnc_bulkLoadData_couchdb"}) exitWith {
    "[PA] BLOCKED: the loaded ALiVE build does not expose the CouchDB functions." remoteExec ["systemChat", 0];
};
// A unique source selects production backend code and local I/O.
// Every other Data handler retains its normal source and implementation.
ALIVE_fnc_bulkSaveData_pa_memory = ALIVE_fnc_bulkSaveData_couchdb;
ALIVE_fnc_bulkLoadData_pa_memory = ALIVE_fnc_bulkLoadData_couchdb;
ALIVE_fnc_convertData_pa_memory = ALIVE_fnc_convertData_couchdb;
ALIVE_fnc_readData_pa_memory = {(_this + ["read"]) call PA_fnc_cloudTransport};
ALIVE_fnc_writeData_pa_memory = {(_this + ["write"]) call PA_fnc_cloudTransport};
ALIVE_fnc_bulkWriteData_pa_memory = {(_this + ["bulkWrite"]) call PA_fnc_cloudTransport};
ALIVE_fnc_bulkReadData_pa_memory = {(_this + ["bulkRead"]) call PA_fnc_cloudTransport};
private _newHandler = {
    private _handler = [] call ALIVE_fnc_hashCreate;
    [_handler, [["source", "pa_memory"], ["storeType", false],
        ["PA_docs", createHashMap], ["PA_revision", 0]]] call ALIVE_fnc_hashSetMany;
    _handler
};
private _newRecord = {
    params ["_id"];
    [[["profileID", _id], ["type", 1], ["side", 1],
        ["unitClasses", ["B_Soldier_F"]]]] call ALIVE_fnc_hashCreate
};
private _module = "sys_profile_PA";
private _key = "PA_isolated_cloud";
private _handler = call _newHandler;
private _large = [] call ALIVE_fnc_hashCreate;
for "_i" from 0 to 2399 do {
    private _id = format ["PA_LONG_FACTION_FOR_INDEX_OVERFLOW-entity_%1", _i];
    [_large, _id, [_id] call _newRecord] call ALIVE_fnc_hashSet;
};
[_handler, "bulkSave", [_module, _large, _key, false]] call ALIVE_fnc_Data;
private _firstLoad = [_handler, "bulkLoad", [_module, _key, false]] call ALIVE_fnc_Data;
private _pages = [_handler, "indexRevs", []] call ALIVE_fnc_hashGet;
["Cloud overflow fixture actually creates multiple index pages", count _pages > 1, ">1", count _pages] call PA_fnc_assert;
["Cloud control loads every profile from the large save", count (_firstLoad select 1) == 2400, 2400, count (_firstLoad select 1)] call PA_fnc_assert;
if (count _pages <= 1 || {count (_firstLoad select 1) != 2400}) exitWith {
    "[PA] BLOCKED: Cloud overflow prerequisites failed." remoteExec ["systemChat", 0];
};
private _liveID = (_large select 1) select 0;
private _deadID = (_large select 1) select 2399;
private _small = [] call ALIVE_fnc_hashCreate;
// Use the loaded revision, just as a continued campaign does.
[_small, _liveID, [_firstLoad, _liveID] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
private _shrinkResult = [_handler, "bulkSave", [_module, _small, _key, false]] call ALIVE_fnc_Data;
private _afterShrink = [_handler, "bulkLoad", [_module, _key, false]] call ALIVE_fnc_Data;
["Cloud shrink keeps only the one surviving profile", count (_afterShrink select 1) == 1, 1, count (_afterShrink select 1)] call PA_fnc_assert;
["Cloud shrink does not resurrect a removed tail-page profile", !(_deadID in (_afterShrink select 1)), false, _deadID in (_afterShrink select 1)] call PA_fnc_assert;
diag_log format ["[PA] Cloud shrink backend result=%1", _shrinkResult];

// A successful control save precedes the injected document-write failure.
_handler = call _newHandler;
private _good = [] call ALIVE_fnc_hashCreate;
[_good, "PA_good", ["PA_good"] call _newRecord] call ALIVE_fnc_hashSet;
[_handler, "bulkSave", [_module, _good, _key, false]] call ALIVE_fnc_Data;
private _control = [_handler, "bulkLoad", [_module, _key, false]] call ALIVE_fnc_Data;
["Cloud write control produces a readable record", "PA_good" in (_control select 1), true, "PA_good" in (_control select 1)] call PA_fnc_assert;
[_handler, "PA_failNextWrite", true] call ALIVE_fnc_hashSet;
private _replacement = [] call ALIVE_fnc_hashCreate;
[_replacement, "PA_new", ["PA_new"] call _newRecord] call ALIVE_fnc_hashSet;
private _failureResult = [_handler, "bulkSave", [_module, _replacement, _key, false]] call ALIVE_fnc_Data;
private _indexAfterFailure = [_handler, "read", [_module, [], _key]] call ALIVE_fnc_Data;
private _index = [_indexAfterFailure, "index", []] call ALIVE_fnc_hashGet;
["Cloud bulk save reports the injected document failure", ((toUpper str _failureResult) find "ERROR") >= 0, "error result", _failureResult] call PA_fnc_assert;
["Cloud failed write leaves the last good index published", _index isEqualTo ["PA_good"], ["PA_good"], _index] call PA_fnc_assert;

// Exercise the real encoder with ordinary spawn code containing quotes.
private _quoted = [[["onEachSpawn", '_this params ["_unit"];']]] call ALIVE_fnc_hashCreate;
private _wire = [_handler, "convert", [_quoted]] call ALIVE_fnc_Data;
["Cloud JSON encoder escapes embedded quotes in spawn code", (_wire find '\"_unit\"') >= 0, '\"_unit\"', _wire] call PA_fnc_assert;
diag_log "[PA] Cloud tests finished. Documents existed only in memory; no Cloud connection was used.";
