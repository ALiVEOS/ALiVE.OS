#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(spacialGrid);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_spacialGrid

Description:
Creates a uniform spatial-grid HashMapObject.

Parameters:
    Nil
    String - "create"
    Array - Origin, grid size, and sector size

Returns:
    HashMapObject - Spatial grid instance

Examples:
(begin example)
_grid = [nil, "create", [[-3000,-3000], worldSize + 6000, 1000]] call ALiVE_fnc_spacialGrid;
_near = _grid call ["findInRange", [[0,0,0], 500, true, true, true]];
(end)

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

if (isNil "ALiVE_spacialGridClass") then {
    ALiVE_spacialGridClass = [
        ["#type", "ALiVE_SpacialGrid"],
        ["#flags", ["sealed"]],

        ["origin", []],
        ["sectorSize", 0],
        ["gridSize", 0],
        ["minSector", [0,0]],
        ["maxSector", [0,0]],
        ["sectors", []],
        ["queryState", []],

        ["#create", {
            _this params ["_origin","_gridSize","_sectorSize"];

            private _gridSectorLength = ceil (_gridSize / _sectorSize);
            private _sectors = [];

            for "_i" from 0 to _gridSectorLength do {
                for "_j" from 0 to _gridSectorLength do {
                    _sectors pushBack [];
                };
            };

            _self set ["origin", _origin];
            _self set ["sectorSize", _sectorSize];
            _self set ["gridSize", _gridSize];
            _self set ["minSector", [0,0]];
            _self set ["maxSector", [_gridSectorLength,_gridSectorLength]];
            _self set ["sectors", _sectors];
            _self set ["queryState", [
                _origin select 0,
                _origin select 1,
                (_origin select 0) + (_sectorSize * _gridSectorLength),
                (_origin select 1) + (_sectorSize * _gridSectorLength),
                1 / _sectorSize,
                _gridSectorLength,
                _sectors,
                abs (_origin select 0),
                abs (_origin select 1)
            ]];
        }],

        ["posToCoords", {
            private _argX = _this select 0;
            private _argY = _this select 1;

            private _gridOrigin = _self get "origin";
            private _sectorSize = _self get "sectorSize";
            private _maxSector = _self get "maxSector";

            private _originX = _gridOrigin select 0;
            private _originY = _gridOrigin select 1;

            if (
                _argX >= _originX &&
                {_argY >= _originY} &&
                {_argX < (_originX + (_sectorSize * (_maxSector select 0)))} &&
                {_argY < (_originY + (_sectorSize * (_maxSector select 1)))}
            ) then {
                _argX = _argX + (abs _originX);
                _argY = _argY + (abs _originY);

                [floor (_argX / _sectorSize), floor (_argY / _sectorSize)]
            } else {
                [-1,-1]
            };
        }],

        ["coordsToSector", {
            if (_this isEqualTo [-1,-1]) exitWith {nil};

            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _index = (_this select 0) + ((_this select 1) * _sectorsInColumn);
            (_self get "sectors") select _index
        }],

        ["insert", {
            private _points = _this;
            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _sectors = _self get "sectors";

            {
                private _point = _x;
                private _position = _point select 0;
                private _coords = _self call ["posToCoords", _position];

                if !(_coords isEqualTo [-1,-1]) then {
                    private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                    (_sectors select _sectorIndex) pushBack _point;
                };
            } forEach _points;

            if ("onInsert" in _self) then {
                _self call ["onInsert", _points];
            };
        }],

        ["remove", {
            private _point = _this;
            private _result = false;
            private _position = _point select 0;
            private _coords = _self call ["posToCoords", _position];

            if !(_coords isEqualTo [-1,-1]) then {
                private _sectorsInColumn = (_self get "maxSector") select 0;
                private _sectorIndex = (_coords select 0) + ((_coords select 1) * _sectorsInColumn);
                private _sector = (_self get "sectors") select _sectorIndex;
                private _index = _sector find _point;

                if (_index != -1) then {
                    _sector deleteAt _index;
                    _result = true;
                };
            };

            if ("onRemove" in _self) then {
                _self call ["onRemove", _point];
            };

            _result
        }],

        ["move", {
            private _oldPos = _this select 0;
            private _newPos = _this select 1;
            private _data = _this select 2;

            private _oldCoords = _self call ["posToCoords", _oldPos];
            private _newCoords = _self call ["posToCoords", _newPos];
            private _sectorsInColumn = (_self get "maxSector") select 0;
            private _sectors = _self get "sectors";
            private _updated = false;

            if (_oldCoords isEqualTo _newCoords) then {
                if !(_oldCoords isEqualTo [-1,-1]) then {
                    private _sectorIndex = (_oldCoords select 0) + ((_oldCoords select 1) * _sectorsInColumn);
                    private _sector = _sectors select _sectorIndex;
                    private _index = _sector find [_oldPos,_data];

                    if (_index != -1) then {
                        _sector set [_index, [_newPos,_data]];
                        _updated = true;
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

                if (_removed) then {
                    if !(_newCoords isEqualTo [-1,-1]) then {
                        private _newSectorIndex = (_newCoords select 0) + ((_newCoords select 1) * _sectorsInColumn);
                        (_sectors select _newSectorIndex) pushBack [_newPos,_data];
                    };

                    _updated = true;
                };
            };

            if ("onMove" in _self) then {
                _self call ["onMove", [_oldPos,_newPos,_data,_updated,_oldCoords,_newCoords]];
            };
        }],

        ["clear", {
            private _sectors = _self get "sectors";
            {
                _x resize 0;
            } forEach _sectors;

            if ("onClear" in _self) then {
                _self call ["onClear"];
            };
        }],

        ["findInRange", {
            private _findInRangeScope = createProfileScope "ALiVE spacialGrid: findInRange";
            private _center = _this select 0;
            private _radius = _this select 1;
            private _filter2D = _this param [2, false];
            private _returnItem = _this param [3, false];
            private _preciseDistance = _this param [4, true];

            private _queryState = _self get "queryState";
            private _originX = _queryState select 0;
            private _originY = _queryState select 1;
            private _maxBoundX = _queryState select 2;
            private _maxBoundY = _queryState select 3;
            private _inverseSectorSize = _queryState select 4;
            private _sectorsInColumn = _queryState select 5;
            private _sectors = _queryState select 6;
            private _originOffsetX = _queryState select 7;
            private _originOffsetY = _queryState select 8;

            private _centerX = _center select 0;
            private _centerY = _center select 1;
            private _queryMinX = _centerX - _radius;
            private _queryMinY = _centerY - _radius;
            private _queryMaxX = _centerX + _radius;
            private _queryMaxY = _centerY + _radius;
            private _result = [];

            if (
                _queryMaxX >= _originX &&
                {_queryMaxY >= _originY} &&
                {_queryMinX < _maxBoundX} &&
                {_queryMinY < _maxBoundY}
            ) then {
                private _minX = floor (((_queryMinX max _originX) + _originOffsetX) * _inverseSectorSize);
                private _minY = floor (((_queryMinY max _originY) + _originOffsetY) * _inverseSectorSize);
                private _maxX = floor (((_queryMaxX min (_maxBoundX - 1)) + _originOffsetX) * _inverseSectorSize);
                private _maxY = floor (((_queryMaxY min (_maxBoundY - 1)) + _originOffsetY) * _inverseSectorSize);

                for "_y" from _minY to _maxY do {
                    for "_x" from _minX to _maxX do {
                        private _index = _x + (_y * _sectorsInColumn);
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

            _findInRangeScope = nil;
            _result
        }]
    ];
};

private _operation = _this param [1, ""];

if (_operation != "create") exitWith {nil};

private _args = _this param [2, []];
createHashMapObject [ALiVE_spacialGridClass, _args]
