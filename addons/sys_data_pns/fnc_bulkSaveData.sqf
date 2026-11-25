#include "script_component.hpp"
SCRIPT(bulkSaveData_pns);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_bulkSaveData_pns

Description:
Saves multiple records to a table using pns Bulk API

Parameters:
Object - Data handler logic
Array - Module (string), Data (CBA Hash), mission key (string), Async (bool) optional

Returns:
String - Returns a response error or confirmation of write

Examples:
(begin example)
    _result = [_logic, "save", ["sys_player", GVAR(player_data), _missionKey, _ondisconnect]] call ALIVE_fnc_Data;
(end)

Author:
Tupolov
Jman
Peer Reviewed:

---------------------------------------------------------------------------- */
private ["_logic","_args","_result","_error","_module","_data","_async","_missionKey","_saveData", "_indexRev","_indexDoc","_index","_newIndexDoc","_createIndex","_indexArray","_tempIndexDoc","_indexCount","_indexRevs"];

_logic = _this select 0;
_args = _this select 1;

_module = _args select 0;
_data = _args select 1;
_missionKey  = _args select 2;
_async = _args select 3;

_data = +_data;

TRACE_2("Saving data", _logic, _args);

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["SYS_DATA_PNS - BULK SAVE"] call ALiVE_fnc_dump;
};

_result = "";

// Only the store's own key and value lists are copied, not every module's data in it: one module's save
// used to copy the whole store, so an autosave of N modules copied it N times. Each module's entry is
// replaced whole (from the copy above), never changed in place, so sharing the others is safe.
private _was = ["get", _missionKey] call ALiVE_fnc_storeFile;
MOD(PNS_STORE) = if (isNil "_was") then { nil } else { [_was select 0, +(_was select 1), +(_was select 2), _was select 3] };
if (isNil QMOD(PNS_STORE)) then { MOD(PNS_STORE) = [] call ALiVE_fnc_HashCreate };

[MOD(PNS_STORE),_module,_data] call ALiVE_fnc_HashSet;

["set", _missionKey, MOD(PNS_STORE)] call ALiVE_fnc_storeFile;

// What the save screen shows after "Save Result:": it was always empty, which players read as a failed save
// (#1108). True once the store holds it; after Clear Current Mission's Data the store keeps nothing until the
// mission restarts, and the answer says so. Not false either way: a caller treats only false as a failure.
private _held = (missionNamespace getVariable ["ALiVE_storeFile_held", createHashMap]) getOrDefault [_missionKey, nil];
_result = if (!isNil "_held" && {_held isEqualTo [] || {_module in _held}}) then { "not kept, this mission's data was cleared" } else { true };

// Recorded by name as well, so Wipe ALL can find it again: a dedicated server's
// profile cannot list its own variables.
private _savedMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];
if !(_savedMissions isEqualType []) then { _savedMissions = [] };
if ((_savedMissions findIf {_x isEqualType "" && {_x == _missionKey}}) < 0) then {
    _savedMissions pushBack _missionKey;
    profileNamespace setVariable [QMOD(SAVEDMISSIONS), _savedMissions];
    ALiVE_storeFile_dirtyShared = true;
};

// Save Docs
TRACE_1("Saving Data", _data);
// An autosave writes the file once, after its last module (Jman 10 Nov 2026): this whole file is
// rewritten on every call, and once per module froze a large mission's server for 2-3 s per autosave.
if ((missionNamespace getVariable [QMOD(PNS_HOLD_FRAME), -1]) == diag_frameNo) then {
    MOD(PNS_HOLD_DIRTY) = true;
} else {
    ["flush"] call ALiVE_fnc_storeFile;
};

_result;
