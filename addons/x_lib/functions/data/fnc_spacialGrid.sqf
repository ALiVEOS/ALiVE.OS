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

        _args params ["_argX","_argY"];

        private _gridOrigin = _logic select 2 select 0;
        private _sectorSize = _logic select 2 select 1;
        private _maxSector = _logic select 2 select 4;

        _gridOrigin params ["_originX","_originY"];

        if (
            _argX >= _originX &&
            {_argY >= _originY} &&
            {_argX < (_originX + (_sectorSize * (_maxSector select 0)))} &&
            {_argY < (_originY + (_sectorSize * (_maxSector select 1)))}
        ) then {
            // offset position to accomodate negative values
            _argX = _argX + (abs _originX);
            _argY = _argY + (abs _originY);

            _result = [floor (_argX / _sectorSize), floor (_argY / _sectorSize)];
        } else {
            _result = [-1,-1];
        };

    };

    case "coordsToSector": {

        if !(_args isEqualTo [-1,-1]) then {
            private _sectorsInColumn = (_logic select 2 select 4) select 0;
            private _index = (_args select 0) + ((_args select 1) * _sectorsInColumn);
            _result = (_logic select 2 select 5) select _index;
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
            private _index = _sector find _point;

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
        _maxCoords = _maxCoords apply {_x min (_maxSector select 0)};

        for "_y" from (_minCoords select 1) to (_maxCoords select 1) do {
            for "_x" from (_minCoords select 0) to (_maxCoords select 0) do {
                private _index = _x + (_y * (_maxSector select 0));
                _result append (_sectors select _index);
            };
        };

        if (!_filter2D) then {
            _result = _result select {((_x select 0) distance _center) <= _radius};
        } else {
            _result = _result select {((_x select 0) distance2D _center) <= _radius};
        };

    };

    /*
    case "findNearest": {

        private _center = _args select 0;
        private _maxRadius = _args param [1, 0];
        private _filter2D = _args param [2, false];

        private _centerCoords = [_logic,"posToCoords", _center] call MAINCLASS;

        if !(_centerCoords isEqualTo [-1,-1]) then {
            // phase one:
            // search inwards-out till points are found
            // or grid bounds are all covered

            private _sectorsInColumn = (_logic select 2 select 4) select 0;
            private _maxSector = _logic select 2 select 4;
            private _sectors = _logic select 2 select 5;

            private _points = [];
            private _layer = 1;
            private _sectorsLeft = true; // results in a lot of unnecessary indexchecking

            while {_points isEqualTo [] && _sectorsLeft} do {
                private _neighborCoords = [
                    // top row
                    [(_centerCoords select 0) - _layer, (_centerCoords select 1) - _layer],
                    [(_centerCoords select 0), (_centerCoords select 1) - _layer],
                    [(_centerCoords select 0) + _layer, (_centerCoords select 1) - _layer],

                    // middle row
                    [(_centerCoords select 0) - _layer, (_centerCoords select 1)],
                    [(_centerCoords select 0) + _layer, (_centerCoords select 1)],

                    // bottom row
                    [(_centerCoords select 0) - _layer, (_centerCoords select 1) + _layer],
                    [(_centerCoords select 0), (_centerCoords select 1) + _layer],
                    [(_centerCoords select 0) + _layer, (_centerCoords select 1) + _layer]
                ];

                {
                    if (
                        (_x select 0) >= 0 && {(_x select 0) <= (_maxSector select 0)} &&
                        {(_x select 1) >= 0} && {(_x select 1) <= (_maxSector select 1)}
                    ) then {
                        _sectors append (_sectors select ((_x select 0) + ((_x select 1) * _sectorsInColumn)));
                        _sectorsLeft = true;
                    };
                } foreach _neighborCoords;

                _layer = _layer + 1;
            };

            // phase two:
            // sort points by distance
            // select closest

            if !(_points isEqualTo []) then {
                private _min = [999999, -1];

                if (!_filter2D) then {
                    {
                        private _dist = _x distance _center;
                        if (_dist < (_min select 0)) then {_min = [_dist,_foreachindex]};
                    } foreach _points;
                } else {
                    {
                        private _dist = _x distance2D _center;
                        if (_dist < (_min select 0)) then {_min = [_dist,_foreachindex]};
                    } foreach _points;
                };

                _result = _points select (_min select 1);
            };
        };

    };
    */

};

if (!isnil "_result") then {_result} else {nil}