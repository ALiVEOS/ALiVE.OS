params [["_mode", "roundtrip"]];
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
// The empty-save regression does not depend on mounted or pathfinding fixtures.
private _ready = true;
if (_mode == "empty") then {
    [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
    PA_fixtures = [];
    PA_pendingDestination = [];
} else {
    _ready = call PA_fnc_prepare;
};
if (!_ready) exitWith {
    "[PA] BLOCKED: a fixture prerequisite failed; no profile save was taken." remoteExec ["systemChat", 0];
};
private _snapshot = [] call PA_fnc_snapshot;
private _savedMode = ["normal", "empty"] select (_mode == "empty");
private _baseline = [_savedMode, _snapshot, +PA_pendingDestination];
// Force the normal save entry point: this is real PNS persistence under the
// mission's own store key, not an in-memory export/import shortcut.
ALIVE_saveProfilesPersistent = true;
private _saveResult = [true] call ALIVE_fnc_profilesSaveData;
private _saved = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
if !(_saved isEqualType [] && {count _saved >= 3}) exitWith {
    ["PNS wrote a readable profile document", false, "CBA hash", _saved] call PA_fnc_assert;
};
private _expectedIDs = +(([ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler) select 1);
private _savedIDs = +(_saved select 1);
_expectedIDs sort true;
_savedIDs sort true;
private _expectedCount = count _expectedIDs;
["PNS document contains the expected number of profiles", count (_saved select 1) == _expectedCount,
    _expectedCount, count (_saved select 1)] call PA_fnc_assert;
["PNS document contains the current profile IDs", _savedIDs isEqualTo _expectedIDs, _expectedIDs, _savedIDs] call PA_fnc_assert;
if !(_savedIDs isEqualTo _expectedIDs) exitWith {};
profileNamespace setVariable [PA_baselineKey, _baseline];
saveProfileNamespace;
diag_log format ["[PA] PNS save result: %1 | mission key=%2", _saveResult, PA_missionKey];
if (_mode == "save") exitWith {
    "[PA] Saved. Use ordinary Abort, then restart this mission. Automatic verification will inspect the cold load. Do not use ALiVE Save and Exit: that would take another snapshot." remoteExec ["systemChat", 0];
};
// Model the loss of old engine jobs at a restart. Otherwise the original
// callback can later find the imported profile by the same ID and hide the loss.
{
    [ALIVE_Pathfinder, "cancelProfilePaths", _x select 1] call ALIVE_fnc_pathfinder;
} forEach PA_fixtures;
if (_mode == "empty") then {
    // Existing non-player state makes refusal to load an empty save observable.
    // A correct loader removes this seed instead of treating the save as absent.
    [["B_Soldier_F"], "WEST", "BLU_F", [1810, 5500, 0], 0, "", false,
        "PA_empty_seed", false, "PRIVATE", [[1810, 5500, 0]]] call ALIVE_fnc_createProfileEntity;
};
ALIVE_loadProfilesPersistent = true;
ALiVE_sysProfileLastLoadTime = nil;
call ALIVE_fnc_profilesLoadData;
[] call PA_fnc_verify;
if (_mode == "empty") then {[] call PA_fnc_emptyValidation};
if (_mode == "roundtrip") then {[_saved, _baseline] call PA_fnc_mountedValidation};
