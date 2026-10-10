// Real save/load and physical-spawn checks for cached and active infantry damage.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
[ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
private _classes = ["B_Soldier_F", "B_Soldier_TL_F", "B_medic_F"];
private _fixtures = [];
{
    _x params ["_alias", "_cached", "_expected"];
    private _position = [1810, 5400 + 30 * _forEachIndex, 0];
    private _profile = [_classes, "WEST", "BLU_F", _position, 0, "", false,
        "PA_damage_" + _alias, false, "PRIVATE", _classes apply {+_position}] call ALIVE_fnc_createProfileEntity;
    [_profile, "damages", _cached] call ALIVE_fnc_profileEntity;
    private _expectedClasses = +_classes;
    if (_alias == "filtered") then {
        [_profile, "unitClasses", ["B_Soldier_F", false, "B_medic_F"]] call ALIVE_fnc_profileEntity;
        _expectedClasses = ["B_Soldier_F", "B_medic_F"];
    };
    _fixtures pushBack [_alias, [_profile, "profileID"] call ALIVE_fnc_hashGet, _expectedClasses, _expected];
} forEach [
    ["virtual", [0, 0.25, 0.6], [0, 0.25, 0.6]],
    ["active", [0, 0, 0], [0.1, 0.45, 0.7]],
    ["legacy", [0.2, 0.4, 0.6], [0, 0, 0]],
    ["short", [0.2, 0.4, 0.6], [0.25, 0, 0]],
    ["strings", [0.2, 0.4, 0.6], [0.1, 0.45, 0.7]],
    ["filtered", [0.2, 0.99, 0.65], [0.2, 0.65]]
];
private _close = {
    params ["_actual", "_expected"];
    if !(_actual isEqualType [] && {count _actual == count _expected}) exitWith {false};
    private _matches = true;
    {
        if (!(_x isEqualType 0) || {abs (_x - (_expected select _forEachIndex)) > 0.001}) then {
            _matches = false;
        };
    } forEach _actual;
    _matches
};
private _spawn = {
    params ["_profile", "_label", "_count"];
    private _task = [_profile, "spawn"] spawn ALIVE_fnc_profileEntity;
    private _deadline = diag_tickTime + 15;
    waitUntil {sleep 0.05; scriptDone _task || {diag_tickTime > _deadline}};
    private _finished = scriptDone _task;
    if (!_finished) then {terminate _task};
    private _units = [_profile, "units", []] call ALIVE_fnc_hashGet;
    [_label, _finished && {count _units == _count} && {(_units findIf {isNull _x}) == -1},
        _count, count _units] call PA_fnc_assert;
    {_x disableAI "ALL"} forEach _units;
    _units
};
private _activeID = (_fixtures select 1) select 1;
private _active = [ALIVE_profileHandler, "getProfile", _activeID] call ALIVE_fnc_profileHandler;
private _liveUnits = [_active, "Damage / active: fixture spawned", 3] call _spawn;
if (count _liveUnits == 3) then {
    {_x setDamage ([0.1, 0.45, 0.7] select _forEachIndex)} forEach _liveUnits;
};
["Damage / active: live damage differs from cached damage",
    [_liveUnits apply {damage _x}, [0.1, 0.45, 0.7]] call _close
        && {([_active, "damages"] call ALIVE_fnc_hashGet) isEqualTo [0, 0, 0]},
    [[0, 0, 0], [0.1, 0.45, 0.7]], [[_active, "damages"] call ALIVE_fnc_hashGet, _liveUnits apply {damage _x}]] call PA_fnc_assert;
ALIVE_saveProfilesPersistent = true;
[true] call ALIVE_fnc_profilesSaveData;
private _saved = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
private _valid = [_saved] call ALIVE_fnc_isHash;
["Damage / PNS document readable", _valid, true, _valid] call PA_fnc_assert;
if (!_valid) exitWith {};
["Damage / all fixture IDs saved", count (_saved select 1) == count _fixtures
    && {(_fixtures findIf {!((_x select 1) in (_saved select 1))}) == -1},
    _fixtures apply {_x select 1}, _saved select 1] call PA_fnc_assert;
{
    _x params ["_alias", "_id", "_expectedClasses", "_expected"];
    private _record = [_saved, _id] call ALIVE_fnc_hashGet;
    if (_alias in ["virtual", "active", "filtered"]) then {
        private _actual = [_record, "damages", []] call ALIVE_fnc_hashGet;
        [format ["Damage / %1: saved damage matches source units", _alias],
            [_actual, _expected] call _close, _expected, _actual] call PA_fnc_assert;
        [format ["Damage / %1: saved class alignment", _alias],
            ([_record, "unitClasses"] call ALIVE_fnc_hashGet) isEqualTo _expectedClasses,
            _expectedClasses, [_record, "unitClasses"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
    };
    switch (_alias) do {
        case "legacy": {[_record, "damages"] call ALIVE_fnc_hashRem};
        case "short": {[_record, "damages", [0.25]] call ALIVE_fnc_hashSet};
        case "strings": {[_record, "damages", ["0.1", "0.45", "0.7"]] call ALIVE_fnc_hashSet};
    };
} forEach _fixtures;
[ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _saved, PA_missionKey, false]] call ALIVE_fnc_Data;
private _legacyKey = format ["ALiVE_%1_%2", missionName, worldName];
private _legacyExisted = !isNil {profileNamespace getVariable _legacyKey};
private _legacyOriginal = profileNamespace getVariable [_legacyKey, false];
private _legacyStore = [] call ALIVE_fnc_hashCreate;
[_legacyStore, "ALiVE_SYS_PROFILE", _saved] call ALIVE_fnc_hashSet;
profileNamespace setVariable [_legacyKey, _legacyStore];
{
    _x params ["_loaderName", "_loader"];
    ALIVE_loadProfilesPersistent = true;
    ALiVE_sysProfileLastLoadTime = nil;
    [{params ["_loader"]; call _loader}, [_loader]] call CBA_fnc_directCall;
    {
        _x params ["_alias", "_id", "_expectedClasses", "_expected"];
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        private _label = format ["Damage / %1 / %2", _loaderName, _alias];
        [_label + ": profile restored", !isNil "_profile", _id,
            if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
        if (!isNil "_profile") then {
            private _actual = [_profile, "damages"] call ALIVE_fnc_hashGet;
            [_label + ": cached damage restored", [_actual, _expected] call _close,
                _expected, _actual] call PA_fnc_assert;
            private _units = [_profile, _label + ": physical spawn completed", count _expectedClasses] call _spawn;
            private _actualDamage = _units apply {damage _x};
            [_label + ": physical damage restored", [_actualDamage, _expected] call _close,
                _expected, _actualDamage] call PA_fnc_assert;
            {_x allowDamage false} forEach _units;
            [_profile, "despawn"] call ALIVE_fnc_profileEntity;
            [_label + ": despawn completed", !([_profile, "active"] call ALIVE_fnc_hashGet),
                false, [_profile, "active"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
        };
    } forEach _fixtures;
} forEach [["Normal", ALIVE_fnc_profilesLoadData], ["Legacy PNS", ALIVE_fnc_profilesLoadDataPNS]];
if (_legacyExisted) then {
    profileNamespace setVariable [_legacyKey, _legacyOriginal];
} else {
    profileNamespace setVariable [_legacyKey, nil];
};
