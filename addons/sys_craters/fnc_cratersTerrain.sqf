#include "\x\alive\addons\sys_craters\script_component.hpp"
SCRIPT(cratersTerrain);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_cratersTerrain

Description:
Digs and fills craters and places their marks. The only place this module changes the ground.

The ground moves in whole blocks of grid points (ALiVE_craters_block a side, 8 by default, so
32 m on a 4 m grid). A dig or a fill sends every block it touches, every point in it at the
height it should have now. A player who joins later gets the same blocks, and since blocks
never overlap, the order they arrive in can't leave a point at an old height.

Where craters overlap, a point sits at the lowest height any of them wants, and goes back to
its original height only when the last of them fills in.

Server only.

Parameters:
String - The operation
Array - Its arguments

Returns:
points - [tier, ci, cj, depth] -> [[key, x, y, drop], ...] the grid points a crater lowers
make - [tier, ci, cj, hitASL] -> the new crater's id
fill - [id] -> nothing; the crater fills in and its mark goes
sendBlocks - [block keys, restore] -> nothing; restore is "i_j" -> height for points going back
applyAll - [] -> nothing; the ground and marks for every crater loaded from a save
claim - [id, keys] / release - [id, keys] -> nothing; the crater's hold on trench ground

Author:
Jman
---------------------------------------------------------------------------- */

// a save started from an admin's machine (SERVER SAVE AND EXIT) comes through ALiVE_fnc_cratersSaveData,
// which marks itself; anything else remote is refused
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_cratersCaller"}) exitWith {};
if (!isServer) exitWith {};

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _result = nil;
private _cell = getTerrainInfo select 2;

switch (_operation) do {

    case "points": {
        _args params ["_tier", "_ci", "_cj", "_depth"];
        _result = [];
        if (_tier < 2) exitWith {};
        private _r = [1, 2] select (_tier == 3);
        if (_tier == 3) then { _depth = (_depth * 1.5) min 1.2 };
        private _max = getTerrainInfo select 3;
        for "_di" from -_r to _r do {
            for "_dj" from -_r to _r do {
                private _i = _ci + _di;
                private _j = _cj + _dj;
                if (_i >= 0 && {_j >= 0} && {_i <= _max} && {_j <= _max}) then {
                    private _ring = (abs _di) max (abs _dj);
                    private _f = if (_tier == 2) then { [1, 0.4] select (_ring > 0) } else { [1, 0.6, 0.25] select _ring };
                    _result pushBack [format ["%1_%2", _i, _j], _i * _cell, _j * _cell, _depth * _f];
                };
            };
        };
    };

    case "blockOf": {
        _args params ["_key"];
        private _ij = (_key splitString "_") apply { parseNumber _x };
        _result = format ["%1_%2", floor ((_ij select 0) / ALiVE_craters_block), floor ((_ij select 1) / ALiVE_craters_block)];
    };

    case "sendBlocks": {
        _args params [["_blocks", [], [[]]], ["_restore", createHashMap, [createHashMap]]];
        private _B = ALiVE_craters_block;
        private _max = getTerrainInfo select 3;
        private _debug = [ALiVE_sys_craters, "attribute", ["craters_debug"]] call ALiVE_fnc_craters;
        {
            private _bij = (_x splitString "_") apply { parseNumber _x };
            private _i0 = (_bij select 0) * _B;
            private _j0 = (_bij select 1) * _B;
            private _list = [];
            for "_j" from _j0 to ((_j0 + _B - 1) min _max) do {
                for "_i" from _i0 to ((_i0 + _B - 1) min _max) do {
                    private _k = format ["%1_%2", _i, _j];
                    private _px = _i * _cell;
                    private _py = _j * _cell;
                    private _rec = ALiVE_craters_points getOrDefault [_k, []];
                    private _z = if (_rec isNotEqualTo []) then {
                        private _m = _rec select 2;
                        { _m = _m min (_x select 1) } forEach (_rec select 3);
                        _m
                    } else {
                        _restore getOrDefault [_k, getTerrainHeightASL [_px, _py]]
                    };
                    _list pushBack [_px, _py, _z];
                };
            };
            private _t = diag_tickTime;
            setTerrainHeight [_list, false];
            if (_debug) then { ["ALiVE Persistent Craters - ground block %1: %2 points in %3 ms", _x, count _list, ((diag_tickTime - _t) * 1000) toFixed 2] call ALiVE_fnc_dump };
            if (canSuspend) then { sleep 0.05 };
        } forEach _blocks;
    };

    case "claim": {
        _args params ["_id", "_keys"];
        if (isNil "ALiVE_OPCOM_trenchCells") then { ALiVE_OPCOM_trenchCells = createHashMap };
        { if ((ALiVE_OPCOM_trenchCells getOrDefault [_x, ""]) == "") then { ALiVE_OPCOM_trenchCells set [_x, "crater:" + _id] } } forEach _keys;
    };

    case "release": {
        _args params ["_id", "_keys"];
        if (isNil "ALiVE_OPCOM_trenchCells") exitWith {};
        // every key here has no crater left on it, so any crater's claim on it is stale: the
        // first crater to dig a shared point keeps its name on it after it fills
        { if (((ALiVE_OPCOM_trenchCells getOrDefault [_x, ""]) select [0, 7]) == "crater:") then { ALiVE_OPCOM_trenchCells deleteAt _x } } forEach _keys;
    };

    case "mark": {
        // the crater's mark, lying on the ground; and on the map when debugging
        _args params ["_c"];
        private _class = ALiVE_craters_classes select ((_c get "tier") - 1);
        if (_class == "") exitWith {};
        private _x0 = _c get "hx";
        private _y0 = _c get "hy";
        if ((_c get "tier") >= 2) then { _x0 = (_c get "ci") * _cell; _y0 = (_c get "cj") * _cell };
        private _d = createSimpleObject [_class, [_x0, _y0, (getTerrainHeightASL [_x0, _y0]) + 0.02]];
        private _up = surfaceNormal [_x0, _y0];
        private _a = _c get "dir";
        private _flat = [sin _a, cos _a, 0];
        private _dir = vectorNormalized (_flat vectorDiff (_up vectorMultiply (_flat vectorDotProduct _up)));
        _d setVectorDirAndUp [_dir, _up];
        _c set ["decal", _d];
        _c set ["class", _class];
        if ([ALiVE_sys_craters, "attribute", ["craters_debug"]] call ALiVE_fnc_craters) then {
            private _m = createMarker ["ALiVE_crater_" + (_c get "id"), [_x0, _y0]];
            _m setMarkerType "mil_dot";
            _m setMarkerColor (["ColorYellow", "ColorOrange", "ColorRed"] select ((_c get "tier") - 1));
            _m setMarkerText (_c get "id");
        };
    };

    case "make": {
        _args params ["_tier", "_ci", "_cj", "_hit"];
        private _id = format ["C%1", ALiVE_craters_counter];
        ALiVE_craters_counter = ALiVE_craters_counter + 1;
        private _keys = [];
        if (_tier >= 2) then {
            private _depth = [ALiVE_sys_craters, "attribute", ["craters_depth"]] call ALiVE_fnc_craters;
            {
                _x params ["_k", "_px", "_py", "_drop"];
                private _rec = ALiVE_craters_points getOrDefault [_k, []];
                if (_rec isEqualTo []) then {
                    _rec = [_px, _py, getTerrainHeightASL [_px, _py], []];
                    ALiVE_craters_points set [_k, _rec];
                };
                (_rec select 3) pushBack [_id, (_rec select 2) - _drop];
                _keys pushBack _k;
            } forEach (["points", [_tier, _ci, _cj, _depth]] call ALiVE_fnc_cratersTerrain);
        };
        // recorded before the dig: a save while the blocks go out finds the crater and its ground together
        private _c = createHashMapFromArray [
            ["id", _id], ["hx", _hit select 0], ["hy", _hit select 1], ["ci", _ci], ["cj", _cj],
            ["tier", _tier], ["class", ""], ["dir", random 360], ["keys", _keys], ["decal", objNull]
        ];
        ALiVE_craters set [_id, _c];
        ALiVE_craters_order pushBack _id;
        if (_keys isNotEqualTo []) then {
            ["claim", [_id, _keys]] call ALiVE_fnc_cratersTerrain;
            private _blocks = _keys apply { ["blockOf", [_x]] call ALiVE_fnc_cratersTerrain };
            ["sendBlocks", [_blocks arrayIntersect _blocks]] call ALiVE_fnc_cratersTerrain;
        };
        ["mark", [_c]] call ALiVE_fnc_cratersTerrain;
        _result = _id;
    };

    case "fill": {
        _args params ["_id"];
        private _c = ALiVE_craters getOrDefault [_id, createHashMap];
        if (count _c == 0) exitWith {};
        deleteVehicle (_c get "decal");
        deleteMarker ("ALiVE_crater_" + _id);
        // gone from the record before the ground moves back, as "make" records first
        ALiVE_craters deleteAt _id;
        ALiVE_craters_order deleteAt (ALiVE_craters_order find _id);
        private _keys = _c get "keys";
        if (_keys isNotEqualTo []) then {
            private _restore = createHashMap;
            {
                private _rec = ALiVE_craters_points getOrDefault [_x, []];
                if (_rec isNotEqualTo []) then {
                    private _holders = (_rec select 3) select { (_x select 0) != _id };
                    _rec set [3, _holders];
                    if (_holders isEqualTo []) then {
                        _restore set [_x, _rec select 2];
                        ALiVE_craters_points deleteAt _x;
                    };
                };
            } forEach _keys;
            ["release", [_id, keys _restore]] call ALiVE_fnc_cratersTerrain;
            private _blocks = _keys apply { ["blockOf", [_x]] call ALiVE_fnc_cratersTerrain };
            ["sendBlocks", [_blocks arrayIntersect _blocks, _restore]] call ALiVE_fnc_cratersTerrain;
        };
        ALiVE_craters_dirty = true;
    };

    case "applyAll": {
        private _all = [];
        {
            private _c = ALiVE_craters get _x;
            ["claim", [_x, _c get "keys"]] call ALiVE_fnc_cratersTerrain;
            _all append ((_c get "keys") apply { ["blockOf", [_x]] call ALiVE_fnc_cratersTerrain });
            ["mark", [_c]] call ALiVE_fnc_cratersTerrain;
        } forEach ALiVE_craters_order;
        ["sendBlocks", [_all arrayIntersect _all]] call ALiVE_fnc_cratersTerrain;
        _result = count (_all arrayIntersect _all);
    };
};

if (!isNil "_result") then { _result } else { nil }
