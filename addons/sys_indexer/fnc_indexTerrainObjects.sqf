#include "\x\alive\addons\sys_indexer\script_component.hpp"
SCRIPT(indexTerrainObjects);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_indexTerrainObjects

Description:
Lists the objects placed on the current terrain for the Map Indexer, in place of the old ALiVEClient
extension, which read them out of the map's WRP file with Mikero's DeWrp. The game is asked for every
terrain object, square by square (1 km at a time), and the models on the shipped blacklist are left out
(data\objectBlacklist.sqf, from alive_object_blacklist.txt). Sets wrp_objects as the old objects file
did, and writes the same file (objects.<map>.sqf) under Documents\Arma 3\ALiVE\indexing\<map>\.

Run it scheduled: a large terrain takes a few minutes.

Parameters:
None

Returns:
Bool - true when the list was made and the file written

Examples:
(begin example)
private _ok = [] call ALiVE_fnc_indexTerrainObjects;
(end)

See Also:
ALiVE_fnc_indexMap, ALiVE_fnc_toolsWrite

Author:
Jman
---------------------------------------------------------------------------- */

private _world = toLower worldName;
// As the old extension did, a model is left out when any blacklist entry appears anywhere in its path, so a folder
// name (plants_f, rocks_f, signs_f) leaves out everything in it. That matched the old Stratis index model for model
// (291 left out, 59 kept); matching the file name alone kept 214 times as many objects, the trees and rocks
private _blacklist = call compile preprocessFileLineNumbers "\x\alive\addons\sys_indexer\data\objectBlacklist.sqf";
private _skipModel = createHashMap;

private _byModel = createHashMap;
private _seen = 0;
private _skipped = 0;
private _tile = 1000;
private _tiles = ceil (worldSize / _tile);

// one ring of squares past each edge as well: some terrains place objects just outside 0..worldSize, and the
// old WRP listing kept them
for "_tx" from -1 to _tiles do {
    for "_ty" from -1 to _tiles do {
        private _x0 = _tx * _tile;
        private _y0 = _ty * _tile;
        private _centre = [_x0 + _tile / 2, _y0 + _tile / 2, 0];
        {
            private _pos = getPosWorld _x;
            // a square's search circle overlaps its neighbours: each object belongs to the square it stands in
            if ((_pos select 0) >= _x0 && {(_pos select 0) < _x0 + _tile} && {(_pos select 1) >= _y0} && {(_pos select 1) < _y0 + _tile}) then {
                private _info = getModelInfo _x;
                private _file = toLower (_info select 0);
                private _model = toLower (_info select 1);
                if (_model != "" && {_file select [count _file - 4] == ".p3d"}) then {
                    _seen = _seen + 1;
                    private _skip = _skipModel get _model;
                    if (isNil "_skip") then {
                        _skip = (_blacklist findIf { _x in _model }) >= 0;
                        _skipModel set [_model, _skip];
                    };
                    if (_skip) then {
                        _skipped = _skipped + 1;
                    } else {
                        // the terrain's own object ID, as the WRP file numbers it: str gives "<address># 154986: shed_f.p3d",
                        // and the cluster scripts find each object again by this ID (nearestObject), so it must be the
                        // number after the "#", never the address before it
                        private _s = str _x;
                        private _h = _s find "#";
                        private _id = parseNumber (_s select [_h + 1, (_s find ":") - _h - 1]);
                        private _list = _byModel getOrDefault [_model, [], true];
                        _list pushBack [_id, [round (_pos select 0), round (_pos select 1)]];
                    };
                };
            };
        } forEach (nearestTerrainObjects [_centre, [], _tile * 0.71, false, true]);
    };
};

// in a fixed order, models by path and each model's objects south to north, then west to east, near the order the
// WRP file keeps them in: the clusters are built from this list and come out a little different when the same
// objects arrive in another order (Stratis civilian clusters went from 96 to 95 when the squares were scanned
// in a different order)
wrp_objects = [];
{
    private _sorted = [_y, [], { (_x select 1 select 1) * 100000 + (_x select 1 select 0) }, "ASCEND"] call BIS_fnc_sortBy;
    wrp_objects pushBack [_x, _sorted];
} forEach _byModel;
wrp_objects sort true;

["[ALiVE Map Indexer] %1: %2 terrain objects, %3 on the blacklist, %4 kept, of %5 models", _world, _seen, _skipped, _seen - _skipped, count wrp_objects] call ALiVE_fnc_dump;

// the same file the old extension wrote, so it can be shipped in fnc_strategic\indexes as before
private _path = format ["indexing/%1/x/alive/addons/fnc_strategic/indexes/objects.%1.sqf", _world];
private _ok = [_path, "new", format ["// ALiVE terrain objects for %1, listed in game by ALiVE_fnc_indexTerrainObjects (%2 models, %3 objects)%4wrp_objects=[%4", _world, count wrp_objects, _seen - _skipped, endl]] call ALiVE_fnc_toolsWrite;
// Written about 200,000 characters at a time, and a model's objects 2,000 at a time: a string can't pass 10 million
// characters, and on Altis one model's list alone did (1.5 million objects in 598 models, NUC 15 Nov)
private _buf = [];
private _bufLen = 0;
private _fnc_put = {
    _buf pushBack _this;
    _bufLen = _bufLen + count _this;
    if (_bufLen > 200000) then {
        if (_ok) then { _ok = [_path, "add", _buf joinString ""] call ALiVE_fnc_toolsWrite };
        _buf = [];
        _bufLen = 0;
    };
};
private _tab = toString [9];
private _tab3 = toString [9, 9, 9];
{
    if (!_ok) exitWith {};
    _x params ["_model", "_list"];
    format ["%1[""%2"",%3%1%1[%3", _tab, _model, endl] call _fnc_put;
    private _n = count _list;
    for "_i" from 0 to (_n - 1) step 2000 do {
        private _part = (_list select [_i, 2000]) apply { format ["%1[%2,[%3,%4]]", _tab3, _x select 0, _x select 1 select 0, _x select 1 select 1] };
        ((_part joinString ("," + endl)) + (["", "," + endl] select (_i + 2000 < _n))) call _fnc_put;
    };
    format ["%2%1%1]%2%1]%3%2", _tab, endl, ["", ","] select (_forEachIndex < count wrp_objects - 1)] call _fnc_put;
} forEach wrp_objects;
if (_ok) then { _ok = [_path, "add", (_buf joinString "") + "];" + endl] call ALiVE_fnc_toolsWrite };

_ok
