#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(spacialGrid);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_spacialGrid

Description:
Main class for creating and using a uniform grid for spacial queries.

Parameters:
    HashMap - Spatial grid instance, or nil for create
    Operation - String
    Arguments - Any

Returns:
    Any

Examples:
(begin example)
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

private _logic = _this select 0;
private _operation = _this select 1;
private _args = _this select 2;

private _result = nil;

private _pos2cord = {
    private _logic = _this select 0;
    private _argX = _this select 1;
    private _argY = _this select 2;

    private _gridOrigin = _logic get "origin";
    private _sectorSize = _logic get "sectorSize";
    private _maxSector = _logic get "maxSector";

    private _originX = _gridOrigin select 0;
    private _originY = _gridOrigin select 1;

    if (
        _argX >= _originX &&
        {_argY >= _originY} &&
        {_argX < (_originX + (_sectorSize * (_maxSector select 0)))} &&
        {_argY < (_originY + (_sectorSize * (_maxSector select 1)))}
    ) then {
        // offset position to accomodate negative values
        _argX = _argX + (abs _originX);
        _argY = _argY + (abs _originY);

        [floor (_argX / _sectorSize), floor (_argY / _sectorSize)];
    } else {
        [-1,-1];
    };
};

switch (_operation) do {

    case "create": {

        _args params ["_origin","_gridSize","_sectorSize"];

        private _gridSectorLength = ceil (_gridSize / _sectorSize);

        private _sectors = [];
        for "_i" from 0 to _gridSectorLength do {
            for "_j" from 0 to _gridSectorLength do {
                // [j, i]
                _sectors pushback [];

                /*
                _markerstr = createMarker [str random 10000, [((_j * _sectorSize) + (_origin select 0)), ((_i * _sectorSize) + (_origin select 1))]];
                _markerstr setMarkerShape "ICON";
                _markerstr setMarkerType "hd_dot";
                _markerstr setMarkerSize [2,2];
                _markerstr setmarkercolor "colorred";
                */
            };
        };

        _result = createHashMapFromArray [
            ["origin", _origin],
            ["sectorSize", _sectorSize],
            ["gridSize", _gridSize],
            ["minSector", [0,0]],
            ["maxSector", [_gridSectorLength,_gridSectorLength]],
            ["sectors", _sectors]
        ];

    };

    case "posToCoords": {
        _result = [_logic, _args select 0, _args select 1] call _pos2cord;
    };

    case "coordsToSector": {
        if !(_args isEqualTo [-1,-1]) then {
            private _sectorsInColumn = (_logic get "maxSector") select 0;
            private _index = (_args select 0) + ((_args select 1) * _sectorsInColumn);
            _result = (_logic get "sectors") select _index;
        };
    };

    case "insert": {

        private _points = _args;
        private _sectorsInColumn = (_logic get "maxSector") select 0;
        private _sectors = _logic get "sectors";

        {
            private _point = _x;
            private _position = _point select 0;
            private _coords = [_logic, _position select 0, _position select 1] call _pos2cord;

            if !(_coords isEqualTo [-1,-1]) then {
                private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                (_sectors select _sectorIndex) pushBack _point;
            };
        } foreach _points;

    };

    case "remove": {

        private _point = _args;

        _result = false;

        private _position = _point select 0;
        private _coords = [_logic, _position select 0, _position select 1] call _pos2cord;

        if !(_coords isEqualTo [-1,-1]) then {
            private _sectorsInColumn = (_logic get "maxSector") select 0;
            private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
            private _sector = (_logic get "sectors") select _sectorIndex;
            private _index = _sector find _point;

            if (_index != -1) then {
                _sector deleteAt _index;
                _result = true;
            };

        };

    };

    case "move": {

        private _oldPos = _args select 0;
        private _newPos = _args select 1;
        private _data = _args select 2;

        private _oldCoords = [_logic, _oldPos select 0, _oldPos select 1] call _pos2cord;
        private _newCoords = [_logic, _newPos select 0, _newPos select 1] call _pos2cord;
        private _sectorsInColumn = (_logic get "maxSector") select 0;
        private _sectors = _logic get "sectors";

        if (_oldCoords isEqualTo _newCoords) then {
            if !(_oldCoords isEqualTo [-1,-1]) then {
                private _sectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                private _sector = _sectors select _sectorIndex;
                private _index = _sector find [_oldPos,_data];

                if (_index != -1) then {
                    _sector set [_index, [_newPos,_data]];
                };
            };
        } else {
            private _removed = _oldCoords isEqualTo [-1,-1];

            if (!_removed) then {
                private _oldSectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                private _oldSector = _sectors select _oldSectorIndex;
                private _index = _oldSector find [_oldPos,_data];

                if (_index != -1) then {
                    _oldSector deleteAt _index;
                    _removed = true;
                };
            };

            if (_removed && {!(_newCoords isEqualTo [-1,-1])}) then {
                private _newSectorIndex = (_newCoords select 0) + ((_newCoords select 1) * _sectorsInColumn);
                (_sectors select _newSectorIndex) pushBack [_newPos,_data];
            };
        };

    };

    case "clear": {

        private _sectors = _logic get "sectors";
        {
            _x = [];
        } foreach _sectors;

    };

    case "findInRange": {

        private _center = _args select 0;
        private _radius = _args select 1;
        private _filter2D = _args param [2, false];
        private _returnItem = _args param [3, false];
        private _preciseDistance = _args param [4, true];

        private _gridOrigin = _logic get "origin";
        private _sectorSize = _logic get "sectorSize";
        private _maxSector = _logic get "maxSector";
        private _sectors = _logic get "sectors";

        // Clamp the search-box corners to grid bounds BEFORE passing to
        // _pos2cord. _pos2cord returns the sentinel [-1,-1] for any position
        // outside the grid — and the prior post-clamp (`_x max 0` / `_x min
        // maxSector`) only fixed the low-side case (-1 max 0 = 0). For the
        // high-side overflow case `-1 min 15 = -1` stays at -1, leaving the
        // iteration `for from N to -1` to silently do nothing.
        //
        // Pre-clamping the search-box corners means _pos2cord always
        // receives in-grid positions and returns valid cell coords. Symptom
        // before fix: getNearProfiles queries whose radius extended past
        // the grid's high edge returned ZERO results (BFT showed 0 profiles
        // despite hundreds being indexed; affected every module using
        // ALiVE_fnc_getNearProfiles — mil_opcom, mil_ato, mil_logistics,
        // mil_c2istar tasks, mil_ied, fnc_analysis, etc).
        private _originX = _gridOrigin select 0;
        private _originY = _gridOrigin select 1;
        private _maxBoundX = _originX + (_sectorSize * (_maxSector select 0));
        private _maxBoundY = _originY + (_sectorSize * (_maxSector select 1));

        private _minQX = ((_center select 0) - _radius) max _originX;
        private _minQY = ((_center select 1) - _radius) max _originY;
        // -1 on the max bound so the position lies strictly within
        // [originX, originX + N*sectorSize) — _pos2cord's check is `<`
        // not `<=`, and an exactly-at-boundary value rejects.
        private _maxQX = ((_center select 0) + _radius) min (_maxBoundX - 1);
        private _maxQY = ((_center select 1) + _radius) min (_maxBoundY - 1);

        private _minCoords = [_logic, _minQX, _minQY] call _pos2cord;
        private _maxCoords = [_logic, _maxQX, _maxQY] call _pos2cord;

        _result = [];

        // Defensive: if either corner still resolved to [-1,-1] (shouldn't
        // happen after the pre-clamp, but radius could be zero or grid
        // could be in a degenerate state), bail with empty.
        if (_minCoords isEqualTo [-1,-1] || {_maxCoords isEqualTo [-1,-1]}) exitWith {};

        for "_y" from (_minCoords select 1) to (_maxCoords select 1) do {
            for "_x" from (_minCoords select 0) to (_maxCoords select 0) do {
                private _index = _x + (_y * (_maxSector select 0));
                _result append (_sectors select _index);
            };
        };

        if (_preciseDistance) then {
            if (!_filter2D) then {
                _result = _result select {((_x select 0) distance _center) <= _radius};
            } else {
                _result = _result select {((_x select 0) distance2D _center) <= _radius};
            };
        };

        if (_returnItem) then {
            _result = _result apply {_x select 1};
        };

    };

};

if (!isnil "_result") then {_result} else {nil}
