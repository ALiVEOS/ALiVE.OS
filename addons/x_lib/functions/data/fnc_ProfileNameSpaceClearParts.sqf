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
    "player:<UID>" - one player's save only, by their player ID; every other player's is kept.
                  Their own record, the ones per side, and a slot's record they saved last.
                  They start afresh at their next connection, and nothing of theirs is saved
                  again until the mission restarts
String - who asked for it, for the RPT (optional)
String - their UID, for the RPT (optional)

Returns:
Array - [names cleared, how many], or [[], 0] if refused or nothing was there

Examples:
(begin example)
[["forcepool", "ato"], name player, getPlayerUID player] remoteExec ["ALiVE_fnc_ProfileNameSpaceClearParts", 2];

// one player starts afresh: run on the server, or from the debug console as an admin
[["player:76561198000000000"], name player, getPlayerUID player] remoteExec ["ALiVE_fnc_ProfileNameSpaceClearParts", 2];
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
// one player's saves: "player:<UID>"
private _uids = [];
{ if ((_x select [0, 7]) isEqualTo "player:" && {(_x select [7]) != ""}) then { _uids pushBackUnique (_x select [7]) } } forEach _parts;
_parts = _parts select { (_x select [0, 7]) isNotEqualTo "player:" };
private _unknown = _parts - ["all", "forcepool", "ato", "players"];
if (_unknown isNotEqualTo []) then {
    ["[ALiVE Data] Clear parts: %1 are not parts that can be cleared and are skipped", _unknown] call ALiVE_fnc_dump;
};
_parts = _parts - _unknown;
if (_parts isEqualTo [] && {_uids isEqualTo []}) exitWith { [[], 0] };

["[ALiVE Data] Clearing %1 of this mission's saved data on %2, requested by %3 (UID %4)", _parts + (_uids apply { "player " + _x }), worldName, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;

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

// an air commander's save: this map's name followed by _ATO, or by _ATO_ and the commander's key. An old
// name is judged by the name it moves to, so a mission whose own name holds "_ato" is not taken for one.
private _fnc_isAto = {
    params ["_s"];
    private _u = toUpper _s;
    private _b = toUpper _base;
    if !((_u select [0, count _b]) isEqualTo _b) exitWith { false };
    private _rest = _u select [count _b];
    _rest isEqualTo "_ATO" || {(_rest select [0, 5]) isEqualTo "_ATO_"}
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

// one player's records in a store of player saves: under their ID, their ID and a side, or a slot's record they
// saved last. Taken out of the hash given; the keys taken are returned
private _fnc_dropPlayers = {
    params ["_hash"];
    private _gone = [];
    {
        private _key = _x;
        private _rec = (_hash select 2) select _forEachIndex;
        if (_key in _uids
            || {(_uids findIf { (_key select [0, count _x + 1]) isEqualTo (_x + ":") }) >= 0}
            || {[_rec] call ALiVE_fnc_isHash && {([_rec, "puid", ""] call ALiVE_fnc_hashGet) in _uids}}) then { _gone pushBack _key };
    } forEach (_hash select 1);
    { [_hash, _x] call ALiVE_fnc_hashRem } forEach _gone;
    _gone
};

// those records out of a saved name, the rest of it left as it is
private _fnc_stripPlayers = {
    params ["_name"];
    private _was = ["get", _name] call ALiVE_fnc_storeFile;
    if (isNil "_was" || {!([_was] call ALiVE_fnc_isHash)}) exitWith {};
    private _players = [_was, "sys_player"] call ALiVE_fnc_hashGet;
    if (isNil "_players" || {!([_players] call ALiVE_fnc_isHash)}) exitWith {};
    // the store's entries are shared, never changed in place: a copy of its lists and of the players' save
    private _store = [_was select 0, +(_was select 1), +(_was select 2), _was select 3];
    _players = +_players;
    private _gone = [_players] call _fnc_dropPlayers;
    if (_gone isEqualTo []) exitWith {};
    [_store, "sys_player", _players] call ALiVE_fnc_hashSet;
    ["set", _name, _store] call ALiVE_fnc_storeFile;
    _cleared pushBackUnique _name;
    ["[ALiVE Data] Removed player save(s) %1 from %2; not saved again until the mission restarts", _gone, _name] call ALiVE_fnc_dump;
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
        // each air commander saves under its own name, _ATO_<its key>, as well as the shared _ATO
        case ("ato" in _parts && {[[_to, _name] select (_to isEqualTo "")] call _fnc_isAto}): { [_name] call _fnc_drop };
        // players are a slot of the mission date name, under this map's name or an old one moving to it
        case ("players" in _parts && {(_name == _base + "_DATA") || {_to == _base + "_DATA"} || {(_mode == "move") && {_to == _base}}}): {
            [_name, ["sys_player"]] call _fnc_strip;
        };
    };
    // one player's saves, where the players' saves aren't all going anyway
    if (_uids isNotEqualTo [] && {!_all} && {!("players" in _parts)}
        && {(_mode == "slots") || {_name == _base + "_DATA"} || {_to == _base + "_DATA"} || {(_mode == "move") && {_to == _base}}}) then {
        [_name] call _fnc_stripPlayers;
    };
} forEach ([] call ALiVE_fnc_storeKeysOwned);

// and from the running mission: what it holds now would be written back by the next save, so their records go
// from it too, and they are not saved again until the mission restarts (ALIVE_fnc_player's setPlayer)
if (_uids isNotEqualTo [] && {!isNil "ALiVE_sys_player"}) then {
    ALiVE_sys_player setVariable ["clearedUIDs", (ALiVE_sys_player getVariable ["clearedUIDs", []]) + (_uids - (ALiVE_sys_player getVariable ["clearedUIDs", []]))];
    private _inMemory = [];
    {
        private _h = missionNamespace getVariable _x;
        if (!isNil "_h" && {[_h] call ALiVE_fnc_isHash}) then { _inMemory append ([_h] call _fnc_dropPlayers) };
    } forEach ["ALiVE_sys_player_player_data", "ALiVE_sys_player_gear_data"];
    {
        ["[ALiVE Data] Player %1's saved state is cleared: they start afresh at their next connection, and are not saved again until the mission restarts (records %2)", _x, _inMemory] call ALiVE_fnc_dump;
    } forEach _uids;
};

// Held even when nothing was saved yet, so a part cleared before its first save stays clear too.
if ("forcepool" in _parts) then { ["hold", _base + "_FORCE_POOL"] call ALiVE_fnc_storeFile };
if ("ato" in _parts) then {
    // and every running air commander's own name, which it gave ALiVE_fnc_storeMigrate as it started
    { if ([_base + _x] call _fnc_isAto) then { ["hold", _base + _x] call ALiVE_fnc_storeFile } } forEach (["_ATO"] + (missionNamespace getVariable ["ALiVE_storeSuffixes", []]));
};
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

["[ALiVE Data] Cleared %1 of this mission's saved data: %2 name(s) %3", _parts + (_uids apply { "player " + _x }), count _cleared, _cleared] call ALiVE_fnc_dump;
[_cleared, count _cleared]
