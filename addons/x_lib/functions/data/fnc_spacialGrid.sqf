#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(spacialGrid);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_spacialGrid

Description:
Main class for creating and using a uniform grid for spacial queries.

Parameters:
    Logic - Nil or Object
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

#define MAINCLASS ALiVE_fnc_spacialGrid

private _logic = _this select 0;
private _operation = _this select 1;
private _args = _this select 2;

private _result = nil;

switch (_operation) do {

    case "create": {

        private _origin = _args select 0;
        private _gridSize = _args select 1;
        private _sectorSize = _args select 2;

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

        _result = [
            [
                ["origin", _origin],            // select 2 select 0
                ["sectorSize", _sectorSize],    // select 2 select 1
                ["gridSize", _gridSize],        // select 2 select 2
                ["minSector", [0,0]],           // select 2 select 3
                ["maxSector", [_gridSectorLength,_gridSectorLength]],   // select 2 select 4
                ["sectors", _sectors]           // select 2 select 5
            ]
        ] call ALiVE_fnc_hashCreate;

    };

    case "posToCoords": {

        private _gridOrigin = _logic select 2 select 0;
        private _sectorSize = _logic select 2 select 1;
        private _maxSector = _logic select 2 select 4;

        if (
            (_args select 0) >= (_gridOrigin select 0) &&
            {(_args select 1) >= (_gridOrigin select 1)} &&
            {(_args select 0) < ((_gridOrigin select 0) + (_sectorSize * (_maxSector select 0)))} &&
            {(_args select 1) < ((_gridOrigin select 1) + (_sectorSize * (_maxSector select 1)))}
        ) then {
            // offset position to accomodate negative values
            _args = [
                (_args select 0) + (abs (_gridOrigin select 0)),
                (_args select 1) + (abs (_gridOrigin select 1))
            ];

            _result = [floor ((_args select 0) / _sectorSize), floor ((_args select 1) / _sectorSize)];
        } else {
            _result = [-1,-1];
        };

    };

    case "coordsToSector": {

        if !(_args isEqualTo [-1,-1]) then {
            private _sectorsInColumn = (_logic select 2 select 4) select 0;
            private _index = (_args select 0) + ((_args select 1) * _sectorsInColumn);
            _result = (_logic select 2 select 5) select _index;
        } else {
            _result = nil;
        };

    };

    case "insert": {

        private _points = _args;

        {
            private _coords = [_logic,"posToCoords", _x select 0] call MAINCLASS;

            if !(_coords isEqualTo [-1,-1]) then {
                ([_logic,"coordsToSector", _coords] call MAINCLASS) pushback _x;
            };
        } foreach _points;

    };

    case "remove": {

        private _point = _args;

        _result = false;

        private _coords = [_logic,"posToCoords", _point select 0] call MAINCLASS;

        if !(_coords isEqualTo [-1,-1]) then {
            private _sector = [_logic,"coordsToSector", _coords] call MAINCLASS;
            private _index = (_sector find _point);

            if (_index != -1) then {
                _sector deleteAt (_sector find _point);
                _result = true;
            };

        };

    };

    case "move": {

        private _oldPos = _args select 0;
        private _newPos = _args select 1;
        private _data = _args select 2;

        if ([_logic,"remove", [_oldPos,_data]] call MAINCLASS) then {
            [_logic,"insert", [[_newPos,_data]]] call MAINCLASS;
        };

    };

    case "clear": {

        private _sectors = _logic select 2 select 5;
        {
            _x = [];
        } foreach _sectors;

    };

    case "findInRange": {

        private _center = _args select 0;
        private _radius = _args select 1;
        private _filter2D = _args param [2, false];

        private _minCoords = [_logic,"posToCoords", [(_center select 0) - _radius, (_center select 1) - _radius]] call MAINCLASS;
        private _maxCoords = [_logic,"posToCoords", [(_center select 0) + _radius, (_center select 1) + _radius]] call MAINCLASS;

        private _maxSector = _logic select 2 select 4;
        private _sectors = _logic select 2 select 5;

        _result = [];

        // constrict sector indexes to grid bounds
        _minCoords = _minCoords apply {_x max 0};
        _maxCoords = _maxCoords apply {_x min ((_maxSector select 0) + 1)};

        for "_y" from (_minCoords select 1) to (_maxCoords select 1) do {
            for "_x" from (_minCoords select 0) to (_maxCoords select 0) do {
                private _sector = [_logic,"coordsToSector", [_x,_y]] calL MAINCLASS;
                _result append _sector;
            };
        };

        if (!_filter2D) then {
            _result = _result select {((_x select 0) distance _center) <= _radius};
        } else {
            _result = _result select {((_x select 0) distance2D _center) <= _radius};
        };

    };

};

if (!isnil "_result") then {_result} else {nil}