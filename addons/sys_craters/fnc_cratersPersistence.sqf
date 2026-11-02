#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersPersistence);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_cratersPersistence

Description:
Saves the craters and loads them back. The document is a CBA hash holding "data", the shape
Player FOBs saves in (fnc_fobPersistence.sqf), so both ALiVE Data backends take it.
"data" is ["v1", counter, craters, points]:
- craters, oldest first: [id, hx, hy, ci, cj, tier, dir, keys]
- points: [key, x, y, original height, [[id, height], ...]]
The ground itself isn't saved, only what each crater wants of it, so a load puts the ground
back from those and nothing depends on the order things were dug in.

With an ALiVE Data module the craters go where the rest of the mission is saved; without one
they go into the server's profile. A save happens only when something changed, and at most
once per Save Interval, unless forced (an autosave or SERVER SAVE AND EXIT forces one).

Parameters:
String - The operation
Array - Its arguments

Returns:
serialise - [] -> the "data" value
deserialise - [data] -> true when it was read
save - [force] -> true when written
load - [] -> true when something was loaded

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_cratersCaller"}) exitWith {};
if (!isServer) exitWith {false};

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _logic = missionNamespace getVariable ["ALiVE_sys_craters", objNull];
if (isNull _logic) exitWith {false};
private _set = { [_logic, "attribute", [_this]] call ALiVE_fnc_craters };
private _debug = "craters_debug" call _set;
private _useData = !isNil "ALIVE_sys_data" && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", false])};
private _key = if (isNil "ALIVE_sys_data_GROUP_ID") then {
    format ["ALiVE_CRATERS_%1:%2", [missionName, "%20", "-"] call CBA_fnc_replace, worldName]
} else {
    (["_CRATERS"] call ALiVE_fnc_storeKeys) select 0
};
private _result = false;

switch (_operation) do {

    case "serialise": {
        private _rows = ALiVE_craters_order apply {
            private _c = ALiVE_craters get _x;
            [_x, _c get "hx", _c get "hy", _c get "ci", _c get "cj", _c get "tier", _c get "dir", _c get "keys"]
        };
        private _points = [];
        { _points pushBack [_x, _y select 0, _y select 1, _y select 2, +(_y select 3)] } forEach ALiVE_craters_points;
        _result = ["v1", ALiVE_craters_counter, _rows, _points];
    };

    case "deserialise": {
        _args params [["_data", [], [[]]]];
        if !((_data param [0, ""]) isEqualTo "v1") exitWith {
            ["ALiVE Persistent Craters - the saved craters aren't in a form this build reads (%1); starting without them", _data param [0, "nothing"]] call ALiVE_fnc_dumpR;
        };
        ALiVE_craters_counter = (_data param [1, 0]) max ALiVE_craters_counter;
        {
            _x params [["_id", "", [""]], ["_hx", 0, [0]], ["_hy", 0, [0]], ["_ci", 0, [0]], ["_cj", 0, [0]], ["_tier", 1, [0]], ["_dir", 0, [0]], ["_keys", [], [[]]]];
            if (_id != "" && {_tier in [1, 2, 3]} && {([_hx, _hy, _ci, _cj, _dir] findIf { !finite _x }) < 0}) then {
                ALiVE_craters set [_id, createHashMapFromArray [
                    ["id", _id], ["hx", _hx], ["hy", _hy], ["ci", _ci], ["cj", _cj],
                    ["tier", _tier], ["class", ""], ["dir", _dir], ["keys", _keys], ["decal", objNull]
                ]];
                ALiVE_craters_order pushBack _id;
            };
        } forEach (_data param [2, []]);
        {
            _x params [["_k", "", [""]], ["_px", 0, [0]], ["_py", 0, [0]], ["_z", 0, [0]], ["_holders", [], [[]]]];
            // only holders whose crater came back
            private _live = _holders select { (_x param [0, ""]) in ALiVE_craters };
            if (_k != "" && {_live isNotEqualTo []} && {([_px, _py, _z] findIf { !finite _x }) < 0}) then { ALiVE_craters_points set [_k, [_px, _py, _z, _live]] };
        } forEach (_data param [3, []]);

        // the cap may have been lowered since the save: the oldest go, before any ground moves
        private _cap = "craters_cap" call _set;
        private _dropped = 0;
        while { count ALiVE_craters_order > _cap } do {
            private _id = ALiVE_craters_order deleteAt 0;
            {
                private _rec = ALiVE_craters_points getOrDefault [_x, []];
                if (_rec isNotEqualTo []) then {
                    private _holders = (_rec select 3) select { (_x select 0) != _id };
                    if (_holders isEqualTo []) then { ALiVE_craters_points deleteAt _x } else { _rec set [3, _holders] };
                };
            } forEach ((ALiVE_craters get _id) get "keys");
            ALiVE_craters deleteAt _id;
            _dropped = _dropped + 1;
        };
        if (_dropped > 0) then { ALiVE_craters_dirty = true };

        private _blocks = ["applyAll"] call ALiVE_fnc_cratersTerrain;
        ["ALiVE Persistent Craters - put back %1 craters, %2 ground points, %3 ground blocks%4", count ALiVE_craters_order, count ALiVE_craters_points, _blocks,
            ["", format ["; %1 oldest filled in to keep under the cap", _dropped]] select (_dropped > 0)] call ALiVE_fnc_dump;
        _result = true;
    };

    case "save": {
        _args params [["_force", false, [false]]];
        if !("craters_persistent" call _set) exitWith {};
        // never before the saved craters are back, or an empty set would go over them; nor when
        // ALiVE Data never came up, so nothing could be read
        if !(_logic getVariable ["startupComplete", false]) exitWith {};
        if (missionNamespace getVariable ["ALiVE_craters_readOnly", false]) exitWith {};
        private _last = missionNamespace getVariable ["ALiVE_craters_lastSave", -1e9];
        if (!_force && {!ALiVE_craters_dirty || {time - _last < ("craters_save_interval" call _set)}}) exitWith {};

        private _plain = ["serialise"] call ALiVE_fnc_cratersPersistence;
        if (_useData) then {
            if (isNil QGVAR(DATAHANDLER)) then {
                GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
            };
            private _doc = [[["data", _plain]]] call CBA_fnc_hashCreate;
            // the War Room backend updates a document by its revision
            private _prev = [GVAR(DATAHANDLER), "read", ["sys_craters", [], _key]] call ALIVE_fnc_Data;
            if (_prev isEqualType [] && {count _prev > 0}) then {
                private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;
                if (!isNil "_rev") then { [_doc, "_rev", _rev] call CBA_fnc_hashSet };
            };
            _result = [GVAR(DATAHANDLER), "write", ["sys_craters", _doc, false, _key]] call ALIVE_fnc_Data;
            _result = !(!isNil "_result" && {_result isEqualTo false});
        } else {
            profileNamespace setVariable [_key, _plain];
            saveProfileNamespace;
            _result = true;
        };
        // a failed write stays dirty and goes again at the next interval
        if (_result) then { ALiVE_craters_dirty = false };
        ALiVE_craters_lastSave = time;
        if (_debug) then { ["ALiVE Persistent Craters - saved %1 craters to %2 (%3): %4", count (_plain select 2), _key, ["profile", "ALiVE Data"] select _useData, _result] call ALiVE_fnc_dump };
    };

    case "load": {
        if !("craters_persistent" call _set) exitWith {};
        private _plain = [];
        if (_useData) then {
            if (isNil QGVAR(DATAHANDLER)) then {
                GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
            };
            private _doc = [GVAR(DATAHANDLER), "read", ["sys_craters", [], _key]] call ALIVE_fnc_Data;
            if (_doc isEqualType [] && {count _doc > 0}) then {
                private _d = [_doc, "data"] call CBA_fnc_hashGet;
                if (!isNil "_d") then { _plain = _d };
            };
        } else {
            _plain = profileNamespace getVariable [_key, []];
        };
        if (_plain isEqualTo []) exitWith {
            if (_debug) then { ["ALiVE Persistent Craters - nothing saved under %1", _key] call ALiVE_fnc_dump };
        };
        _result = ["deserialise", [_plain]] call ALiVE_fnc_cratersPersistence;
    };
};

_result
