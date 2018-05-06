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

private "_result";

switch (_operation) do {

    case "create": {

        _args params ["_origin","_gridSize","_sectorSize"];

        private _gridSectorWidth = ceil ((_gridSize - (_origin select 0)) / _sectorSize);
        private _gridSectorHeight = ceil ((_gridSize - (_origin select 1)) / _sectorSize);

        private _sectors = [];
        for "_i" from 0 to _gridSectorHeight do {
            for "_j" from 0 to _gridSectorWidth do {
                // [j, i]
                _sectors pushback [];
            };
        };

        _result = [
            [
                ["origin", _origin],
                ["sectorSize", _sectorSize],
                ["gridSize", _gridSize],
                ["gridSectorWidth", _gridSectorWidth],
                ["gridSectorHeight", _gridSectorHeight],
                ["sectors", _sectors]
            ]
        ] call ALiVE_fnc_hashCreate;

    };

    case "posToCoords": {

        private _pos = _args;

        private _gridOrigin = _logic select 2 select 0;
        private _sectorSize = _logic select 2 select 1;
        private _gridWidth = _logic select 2 select 2;

        if (
            (_pos select 0) >= (_gridOrigin select 0) &&
            {(_pos select 0) <= (_gridOrigin select 0) + _gridWidth} &&
            {(_pos select 1) >= (_gridOrigin select 1)} &&
            {(_pos select 1) <= (_gridOrigin select 1) + _gridWidth}
        ) then {
            _result = [floor ((_pos select 0) / _sectorSize), floor ((_pos select 1) / _sectorSize)];
        } else {
            _result = [-1,-1];
        };

    };

    case "coordsToSector": {

        private _coords = _args;

        private _columnCount = _logic select 2 select 3;

        if !(_coords isEqualTo [-1,-1]) then {
            private _index = (_coords select 0) + ((_coords select 1) * _columnCount);
            _result = (_logic select 2 select 5) select _index;
        };

    };

    case "insert": {

        private _points = _args;

        {
            private _coords = [_logic,"posToCoords", _x select 0] call MAINCLASS;
            private _sector = [_logic,"coordsToSector", _coords] call MAINCLASS;

            if (!isnil "_sector") then {
                _sector pushback _x;
            };
        } foreach _points;

    };

    case "remove": {

        private _point = _args;

        _result = false;

        private _coords = [_logic,"posToCoords", _point select 0] call MAINCLASS;
        private _sector = [_logic,"coordsToSector", _coords] call MAINCLASS;

        if (!isnil "_sector") then {
            private _index = (_sector find _point);

            if (_index != -1) then {
                _sector deleteAt (_sector find _point);
                _result = true;
            };

        };

    };

    case "move": {

        _args params ["_oldPos","_newPos","_data"];

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

        private _sectorSize = _logic select 2 select 1;

        private _minX = floor (((_center select 0) - _radius) / _sectorSize);
        private _minY = floor (((_center select 1) - _radius) / _sectorSize);
        private _maxX = floor (((_center select 0) + _radius) / _sectorSize);
        private _maxY = floor (((_center select 1) + _radius) / _sectorSize);

        private _columnCount = _logic select 2 select 3;
        private _sectors = _logic select 2 select 5;

        _result = [];

        for "_y" from _minY to _maxY do {
            for "_x" from _minX to _maxX do {
                _result append (_sectors select (_x + (_y * _columnCount)));
            };
        };

        _result = _result select {(_x select 0) distance _center <= _radius};

    };

};

if (!isnil "_result") then {_result} else {nil}