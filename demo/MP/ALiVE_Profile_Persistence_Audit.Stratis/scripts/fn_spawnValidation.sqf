// Scheduled physical-spawn regression, using real Local/PNS saves and loads.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _hook = '_this params ["_unit", "_profileID", "_side", "_faction"]; _unit setVariable ["PA_hookContext", [_profileID, _side, _faction]]; private _key = _profileID + "_PA_hookRuns"; missionNamespace setVariable [_key, (missionNamespace getVariable [_key, 0]) + 1];';
private _fixtures = [];
{
    private _alias = _x;
    private _position = [1810, 5520 + 30 * _forEachIndex, 0];
    private _profile = [["B_Soldier_F", "B_Soldier_F"], "WEST", "BLU_F", _position,
        0, "", false, "PA_spawn_" + _alias, false, "PRIVATE", [+_position, +_position]] call ALIVE_fnc_createProfileEntity;
    [_profile, "onEachSpawn", _hook] call ALIVE_fnc_profileEntity;
    [_profile, "onEachSpawnOnce", _alias == "once"] call ALIVE_fnc_profileEntity;
    private _id = [_profile, "profileID"] call ALIVE_fnc_hashGet;
    missionNamespace setVariable [_id + "_PA_hookRuns", 0];
    _fixtures pushBack [_alias, _id];
} forEach ["repeat", "once", "legacy"];
private _legacyID = (_fixtures select 2) select 1;
private _saveReload = {
    params ["_round"];
    ALIVE_saveProfilesPersistent = true;
    [true] call ALIVE_fnc_profilesSaveData;
    private _saved = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
    private _valid = [_saved] call ALIVE_fnc_isHash;
    [format ["Spawn hooks / round %1: PNS document readable", _round],
        _valid, true, _valid] call PA_fnc_assert;
    if (!_valid) exitWith {};
    [format ["Spawn hooks / round %1: all fixture IDs saved", _round],
        count (_saved select 1) == count _fixtures && {(_fixtures findIf {!((_x select 1) in (_saved select 1))}) == -1},
        _fixtures apply {_x select 1}, _saved select 1] call PA_fnc_assert;
    // Model saves written before customization fields existed.
    private _legacy = [_saved, _legacyID] call ALIVE_fnc_hashGet;
    {[_legacy, _x] call ALIVE_fnc_hashRem} forEach ["onEachSpawn", "onEachSpawnOnce", "spawnCodeRun"];
    [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _saved, PA_missionKey, false]] call ALIVE_fnc_Data;
    ALIVE_loadProfilesPersistent = true;
    ALiVE_sysProfileLastLoadTime = nil;
    call ALIVE_fnc_profilesLoadData;
};
private _spawnCheck = {
    params ["_alias", "_profile", "_round"];
    private _id = [_profile, "profileID"] call ALIVE_fnc_hashGet;
    private _shouldRun = _alias == "repeat" || {_alias == "once" && {_round == 1}};
    private _expectedCount = switch (_alias) do {
        case "repeat": {2 * _round};
        case "once": {2};
        default {0};
    };
    private _task = [_profile, "spawn"] spawn ALIVE_fnc_profileEntity;
    private _deadline = diag_tickTime + 15;
    waitUntil {
        sleep 0.05;
        (scriptDone _task && {(missionNamespace getVariable [_id + "_PA_hookRuns", 0]) == _expectedCount})
        || {diag_tickTime > _deadline}
    };
    private _finished = scriptDone _task;
    if (!_finished) then {terminate _task};
    sleep 0.2;
    private _units = [_profile, "units", []] call ALIVE_fnc_hashGet;
    [format ["Spawn hooks / round %1 / %2: physical spawn completed", _round, _alias],
        _finished && {count _units == 2} && {(_units findIf {isNull _x}) == -1},
        2, count _units] call PA_fnc_assert;
    private _actualCount = missionNamespace getVariable [_id + "_PA_hookRuns", 0];
    [format ["Spawn hooks / round %1 / %2: execution count", _round, _alias],
        _actualCount == _expectedCount, _expectedCount, _actualCount] call PA_fnc_assert;
    private _expectedContext = if (_shouldRun) then {[_id, "WEST", "BLU_F"]} else {[]};
    [format ["Spawn hooks / round %1 / %2: unit customization and arguments", _round, _alias],
        count _units == 2 && {(_units findIf {!((_x getVariable ["PA_hookContext", []]) isEqualTo _expectedContext)}) == -1},
        _expectedContext, _units apply {_x getVariable ["PA_hookContext", []]}] call PA_fnc_assert;
    {_x allowDamage false; _x disableAI "ALL"} forEach _units;
};
{
    private _round = _x;
    [{params ["_round", "_saveReload"]; [_round] call _saveReload}, [_round, _saveReload]] call CBA_fnc_directCall;
    {
        _x params ["_alias", "_id"];
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        [format ["Spawn hooks / round %1 / %2: profile restored", _round, _alias],
            !isNil "_profile", _id, if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
        if (!isNil "_profile") then {
            private _expectedHook = if (_alias == "legacy") then {""} else {_hook};
            private _expectedOnce = _alias != "repeat";
            private _actualHook = [_profile, "onEachSpawn"] call ALIVE_fnc_hashGet;
            private _actualOnce = [_profile, "onEachSpawnOnce"] call ALIVE_fnc_hashGet;
            [format ["Spawn hooks / round %1 / %2: code restored or defaults retained", _round, _alias],
                _actualHook isEqualTo _expectedHook, _expectedHook, _actualHook] call PA_fnc_assert;
            [format ["Spawn hooks / round %1 / %2: once flag restored or defaults retained", _round, _alias],
                _actualOnce isEqualTo _expectedOnce, _expectedOnce, _actualOnce] call PA_fnc_assert;
            private _expectedRan = _alias == "once" && {_round == 2};
            private _ran = [_profile, "spawnCodeRun", false] call ALIVE_fnc_hashGet;
            [format ["Spawn hooks / round %1 / %2: prior execution state restored", _round, _alias],
                _ran isEqualTo _expectedRan, _expectedRan, _ran] call PA_fnc_assert;
            [_alias, _profile, _round] call _spawnCheck;
            [_profile, "despawn"] call ALIVE_fnc_profileEntity;
            [format ["Spawn hooks / round %1 / %2: despawn completed", _round, _alias],
                !([_profile, "active"] call ALIVE_fnc_hashGet), false,
                [_profile, "active"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
        };
    } forEach _fixtures;
} forEach [1, 2];
