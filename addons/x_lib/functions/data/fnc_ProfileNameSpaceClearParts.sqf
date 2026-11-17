#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceClearParts);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceClearParts

Description:
Clears chosen parts of this mission's Local saves on this map while the mission runs, and
stops them being saved again until it restarts, so what is in the game now is not written
straight back by the next autosave, a player leaving or the mission ending. On the next
start the cleared parts begin afresh.

The names come from ALiVE_fnc_storeKeysOwned, the list Clear Current Mission's Data uses.
Server only. A call from another machine is checked as Clear Current Mission's Data checks
it: refused unless that machine is an admin or the mission's debug console lets it in.

Parameters:
Array - the parts, any of:
    "all"       - every save of this mission on this map; Player Logistics saves nothing more
    "forcepool" - the AI commanders' force pool
    "ato"       - the air commanders' aircraft and records
    "players"   - the players' saves (gear, position and the rest)
String - who asked for it, for the RPT (optional)
String - their UID, for the RPT (optional)

Returns:
Array - [names cleared, how many], or [[], 0] if refused or nothing was there

Examples:
(begin example)
[["forcepool", "ato"], name player, getPlayerUID player] remoteExec ["ALiVE_fnc_ProfileNameSpaceClearParts", 2];
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceClear, ALiVE_fnc_storeKeysOwned, ALiVE_fnc_storeFile

Author:
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitWith { [[], 0] };

params [["_parts", [], [[]]], ["_requestedBy", "", [""]], ["_requestedByUID", "", [""]]];

// The same check as Clear Current Mission's Data, read first because the sender is only known in this call.
private _owner = remoteExecutedOwner;
private _refused = false;
if (isRemoteExecuted && {_owner > 0} && {_owner != clientOwner} && {(admin _owner) == 0}) then {
    private _i = allPlayers findIf {owner _x == _owner};
    private _uid = if (_i > -1) then {getPlayerUID (allPlayers select _i)} else {""};
    private _console = getMissionConfigValue ["enableDebugConsole", 0];
    _refused = !((_console isEqualTo 2) || {_console isEqualType [] && {_uid != ""} && {_uid in _console}});
};
if (_refused) exitWith {
    ["[ALiVE Data] Refused to clear %1 of this mission's saved data for machine %2 (%3, UID %4): not an admin", _parts, _owner, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
    [[], 0]
};

_parts = (_parts select { _x isEqualType "" }) apply { toLower _x };
private _unknown = _parts - ["all", "forcepool", "ato", "players"];
if (_unknown isNotEqualTo []) then {
    ["[ALiVE Data] Clear parts: %1 are not parts that can be cleared and are skipped", _unknown] call ALiVE_fnc_dump;
};
_parts = _parts - _unknown;
if (_parts isEqualTo []) exitWith { [[], 0] };

["[ALiVE Data] Clearing %1 of this mission's saved data on %2, requested by %3 (UID %4)", _parts, worldName, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;

if (isNil "ALIVE_sys_data_GROUP_ID") exitWith {
    ["[ALiVE Data] Nothing cleared: ALiVE Data has not started on the local backend here"] call ALiVE_fnc_dump;
    [[], 0]
};

private _all = "all" in _parts;
private _fnc_endsWith = {
    params ["_s", "_end"];
    private _n = count _end;
    count _s >= _n && {(toUpper (_s select [count _s - _n])) isEqualTo _end}
};

private _cleared = [];
private _deleted = [];

// a whole name: removed from both files and held
private _fnc_drop = {
    params ["_name"];
    ["delete", _name] call ALiVE_fnc_storeFile;
    ["hold", _name] call ALiVE_fnc_storeFile;
    _deleted pushBackUnique _name;
    _cleared pushBackUnique _name;
    ["[ALiVE Data] Removed %1; it is not saved again until the mission restarts", _name] call ALiVE_fnc_dump;
};

// some slots of a name: taken out of it and held, the rest of the name left as it is
private _fnc_strip = {
    params ["_name", "_slots"];
    ["hold", _name, _slots] call ALiVE_fnc_storeFile;
    private _store = ["get", _name] call ALiVE_fnc_storeFile;
    if (isNil "_store" || {!([_store] call ALiVE_fnc_isHash)}) exitWith {};
    _store = +_store;
    private _had = count (_store select 1);
    { [_store, _x] call ALiVE_fnc_hashRem } forEach _slots;
    if (count (_store select 1) == _had) exitWith {};
    if ((_store select 1) isEqualTo []) then {
        ["delete", _name] call ALiVE_fnc_storeFile;
        _deleted pushBackUnique _name;
    } else {
        // written without the held slots, which "set" leaves out
        ["set", _name, _store] call ALiVE_fnc_storeFile;
    };
    _cleared pushBackUnique _name;
    ["[ALiVE Data] Removed %1 from %2; not saved again until the mission restarts", _slots, _name] call ALiVE_fnc_dump;
};

private _base = (["", worldName] call ALiVE_fnc_storeKeys) select 0;
{
    _x params ["_name", "_to", "_mode"];
    switch (true) do {
        // the mission date and player saves of the old name with the map joined on: only those two slots are this mission's
        case (_mode == "slots"): {
            private _slots = [];
            if (_all) then { _slots = ["sys_data", "sys_player"] } else { if ("players" in _parts) then { _slots = ["sys_player"] } };
            if (_slots isNotEqualTo []) then { [_name, _slots] call _fnc_strip };
        };
        case (_all): { [_name] call _fnc_drop };
        case ("forcepool" in _parts && {[_name, "_FORCE_POOL"] call _fnc_endsWith}): { [_name] call _fnc_drop };
        case ("ato" in _parts && {[_name, "_ATO"] call _fnc_endsWith}): { [_name] call _fnc_drop };
        // players are a slot of the mission date name, under this map's name or an old one moving to it
        case ("players" in _parts && {(_name == _base + "_DATA") || {_to == _base + "_DATA"} || {(_mode == "move") && {_to == _base}}}): {
            [_name, ["sys_player"]] call _fnc_strip;
        };
    };
} forEach ([] call ALiVE_fnc_storeKeysOwned);

// Held even when nothing was saved yet, so a part cleared before its first save stays clear too.
if ("forcepool" in _parts) then { ["hold", _base + "_FORCE_POOL"] call ALiVE_fnc_storeFile };
if ("ato" in _parts) then { ["hold", _base + "_ATO"] call ALiVE_fnc_storeFile };
if ("players" in _parts) then { ["hold", _base + "_DATA", ["sys_player"]] call ALiVE_fnc_storeFile };
if (_all) then {
    { ["hold", _base + _x] call ALiVE_fnc_storeFile } forEach (["", "_DATA", "_COMPOSITIONS", "_TASK", "_TASK_OPTOUT", "_FORCE_POOL", "_ATO", "_FOB", "_INTEL", "_HUB", "_CRATERS", "_RALLY"] + (missionNamespace getVariable ["ALiVE_storeSuffixes", []]));
    // Player Logistics writes its own way as well, so it is told to stop too
    if !(isNil QMOD(SYS_LOGISTICS)) then { MOD(SYS_LOGISTICS) setVariable ["DISABLEPERSISTENCE", true, true] };
};

// The names removed come off the list Wipe ALL reads, so it stays a list of saves that exist.
if (_deleted isNotEqualTo []) then {
    private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];
    if !(_allMissions isEqualType []) then { _allMissions = [] };
    profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - _deleted];
    ALiVE_storeFile_dirtyShared = true;
};
["flush"] call ALiVE_fnc_storeFile;

["[ALiVE Data] Cleared %1 of this mission's saved data: %2 name(s) %3", _parts, count _cleared, _cleared] call ALiVE_fnc_dump;
[_cleared, count _cleared]
