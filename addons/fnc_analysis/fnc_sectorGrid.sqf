#include <\x\ALiVE\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorGrid);

/* ----------------------------------------------------------------------------
Function: ALiVE+fnc_sectorGrid

Description:
Creates the server side object to create a sector grid

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of grid
String - id - ID name of the grid
Array - gridPosition - Array of x, y position for grid start
Scalar - gridSize - Scalar max size for grid creation
Array - sectorDimensions - Array of width, height dimensions for sector creation
String - sectorType - String typename of sector object to build the grid with
Array - positionToGridIndex - Array position gets 2 dimensional grid index reference to sector position is within
Array - gridIndexToSector - Array grid index takes a grid index (as returned by positionToGridIndex) and returns the sector object
Array - positionToSector - Array position takes a position and returns the sector object the position is within
Array - surroundingSectors - Array position takes a position and returns the surrounding sector objects

Examples:
(begin example)
// create a grid
_logic = [nil, "create"] call ALiVE_fnc_sectorGrid;

// the grid id
_result = [_logic, "id", "myGrid"] call ALiVE_fnc_sectorGrid;

// the grid origin position
_result = [_logic, "gridPosition", [0,0]] call ALiVE_fnc_sectorGrid;

// the size of the grid
_result = [_logic, "gridSize", 1000] call ALiVE_fnc_sectorGrid;

// set sector dimensions
_result = [_logic, "sectorDimensions", [500,500]] call ALiVE_fnc_sectorGrid;

// set the sector class type
_result = [_logic, "sectorType", "SECTOR"] call ALiVE_fnc_sectorGrid;

// create the grid
_result = [_logic, "createGrid"] call ALiVE_fnc_sectorGrid;

// get the array of all sectors
_result = [_logic, "sectors"] call ALiVE_fnc_sectorGrid;

// position to grid index
_result = [_logic, "positionToGridIndex", getPos Player] call ALiVE_fnc_sectorGrid;

// grid index to sector
_result = [_logic, "gridIndexToSector", [0,4]] call ALiVE_fnc_sectorGrid;

// position to sector
_result = [_logic, "positionToSector", getPos Player] call ALiVE_fnc_sectorGrid;

// surrounding sectors
_result = [_logic, "surroundingSectors", getPos player] call ALiVE_fnc_sectorGrid;

// sectors in radius
_result = [_logic, "sectorsInRadius", [getPos player, 1000]] call ALiVE_fnc_sectorGrid;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_sectorGrid

private "_result";

TRACE_1("sectorGrid - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_SECTOR_GRID_%1"


switch(_operation) do {

    case "init": {

        /*
        MODEL - no visual just reference data
        - nodes
        - center
        - size
        */

        if (isServer) then {
            // if server, initialise module game logic
            [_logic,"super"] call ALiVE_fnc_hashRem;
            [_logic,"class"] call ALiVE_fnc_hashRem;

            // set defaults
            [_logic,"id","grid"] call ALiVE_fnc_hashSet;
            [_logic,"gridPosition",[0,0]] call ALiVE_fnc_hashSet;
            [_logic,"gridSize",[] call ALiVE_fnc_getMapBounds] call ALiVE_fnc_hashSet;
            [_logic,"sectorDimensions",[1000,1000]] call ALiVE_fnc_hashSet;
            [_logic,"sectorType","SECTOR"] call ALiVE_fnc_hashSet;
        };

        /*
        VIEW - purely visual
        */

        /*
        CONTROLLER  - coordination
        */

    };

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            // if server

            private _allSectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;

            if (count _allSectors > 0) then {
                // switch off debug on all grid sectors
                {
                    _result = [_x, "destroy", false] call ALiVE_fnc_sector;
                } forEach _allSectors;
            };

            [_logic,"super"] call ALiVE_fnc_hashRem;
            [_logic,"class"] call ALiVE_fnc_hashRem;
            [_logic, "destroy"] call SUPERCLASS;
        };

    };

        case "debug": {

            if !(_args isEqualType true) then {
                _args = [_logic,"debug"] call ALiVE_fnc_hashGet;
            } else {
                [_logic,"debug",_args] call ALiVE_fnc_hashSet;
            };

            private _allSectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;

            if (count _allSectors > 0) then {
                // switch off debug on all grid sectors
                {
                    _result = [_x, "debug", false] call ALiVE_fnc_sector;
                } forEach _allSectors;

                if(_args) then {
                    // switch on debug on all grid sectors
                    {
                        _result = [_x, "debug", true] call ALiVE_fnc_sector;
                    } forEach _allSectors;
                };
            };

            _result = _args;

        };

        case "state": {

            if !(_args isEqualType []) then {
                // Save state

                private _state = [] call ALiVE_fnc_hashCreate;

                {
                    if (!(_x == "super") && !(_x == "class")) then {
                        [_state,_x,[_logic,_x] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                    };
                } forEach (_logic select 1);

                _result = _state;
            } else {

                // Restore state

                {
                    [_logic,_x, [_args,_x] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
                } forEach (_args select 1);
            };

        };

        case "id": {

            if (_args isEqualType "") then {
                [_logic,"id", _args] call ALiVE_fnc_hashSet;
            };

            _result = [_logic,"id"] call ALiVE_fnc_hashGet;

        };

        case "gridPosition": {

            if (_args isEqualType []) then {
                [_logic,"gridPosition", _args] call ALiVE_fnc_hashSet;
            };

            _result = [_logic,"gridPosition"] call ALiVE_fnc_hashGet;

        };

        case "gridSize": {

            if (_args isEqualType 0) then {
                [_logic,"gridSize", _args] call ALiVE_fnc_hashSet;
            };

            _result = [_logic,"gridSize"] call ALiVE_fnc_hashGet;

        };

        case "sectorDimensions": {

            if (_args isEqualType []) then {
                [_logic,"sectorDimensions", _args] call ALiVE_fnc_hashSet;
            };

            _result = [_logic,"sectorDimensions"] call ALiVE_fnc_hashGet;

        };

        case "sectorType": {

            if (_args isEqualType "") then {
                [_logic,"sectorType", _args] call ALiVE_fnc_hashSet;
            };

            _result = [_logic,"sectorType"] call ALiVE_fnc_hashGet;

        };

        case "createGrid": {

            private _gridID = [_logic,"id"] call ALiVE_fnc_hashGet;
            private _gridPosition = [_logic,"gridPosition"] call ALiVE_fnc_hashGet;
            private _gridSize = [_logic,"gridSize"] call ALiVE_fnc_hashGet;
            private _sectorDimensions = [_logic,"sectorDimensions"] call ALiVE_fnc_hashGet;
            private _sectorType = [_logic,"sectorType"] call ALiVE_fnc_hashGet;

            private _grid = [];
            private _allSectors = [];

            private _gridPositionX = _gridPosition select 0;
            private _gridPositionY = _gridPosition select 1;
            private _sectorWidth = _sectorDimensions select 0;
            private _sectorHeight = _sectorDimensions select 1;
            private _rows = round(_gridSize / _sectorWidth);
            private _columns = round(_gridSize / _sectorHeight);

            // create a grid of sector objects

            for "_column" from 0 to (_columns-1) do {

                private _sectors = [];

                for "_row" from 0 to (_rows-1) do {

                    private _position = [_gridPositionX + ((_row * _sectorWidth)+(_sectorWidth / 2)), _gridPositionY + ((_column * _sectorHeight)+(_sectorHeight / 2))];

                    private "_sector";

                    // allow different sector sub classes.

                    switch(_sectorType) do {

                        case "SECTOR": {
                            _sector = [nil, "create"] call ALiVE_fnc_sector;
                            [_sector, "init"] call ALiVE_fnc_sector;
                            [_sector, "gridID", _gridID] call ALiVE_fnc_sector;
                            [_sector, "dimensions", [(_sectorWidth / 2), (_sectorHeight / 2)]] call ALiVE_fnc_sector;

                            [_sector, "position", _position] call ALiVE_fnc_sector;
                            [_sector, "id", format["%1_%2",_row,_column]] call ALiVE_fnc_sector;
                        };

                    };

                    _sectors pushback _sector;
                    _allSectors pushback _sector;
                };

                _grid pushback _sectors;
            };

            [_logic,"sectors",_allSectors] call ALiVE_fnc_hashSet;
            [_logic,"grid",_grid] call ALiVE_fnc_hashSet;

            _result = _grid;

        };

        case "sectors": {

           _result = [_logic,"sectors"] call ALiVE_fnc_hashGet;

        };

        case "positionToGridIndex": {

            if (_args isEqualType []) then {

                private _position = _args;
                private _positionX = _position select 0;
                private _positionY = _position select 1;

                private _gridPosition = [_logic,"gridPosition"] call ALiVE_fnc_hashGet;
                private _gridPositionX = _gridPosition select 0;
                private _gridPositionY = _gridPosition select 1;
                private _gridSize = [_logic,"gridSize"] call ALiVE_fnc_hashGet;

                private _sectorDimensions = [_logic,"sectorDimensions"] call ALiVE_fnc_hashGet;
                private _sectorWidth = _sectorDimensions select 0;
                private _sectorHeight = _sectorDimensions select 1;

                _result = [];

                // is the position inside the grid
                if(
                    (_positionX > _gridPositionX) &&
                    (_positionX < (_gridPositionX + _gridSize)) &&
                    (_positionY > _gridPositionY) &&
                    (_positionY < (_gridPositionY + _gridSize))
                ) then {
                    private _relativePositionX = _positionX - _gridPositionX;
                    private _relativePositionY = _positionY - _gridPositionY;

                    private _row = floor(_relativePositionX / _sectorWidth);
                    private _column = floor(_relativePositionY / _sectorHeight);

                    _result = [_row, _column];
                } else {
                    //["!!!!!POS OUTSIDE GRID: %1", _position] call ALiVE_fnc_dump;
                    _result = [0, 0];
                };

            };

        };

        case "gridIndexToSector": {

            if (_args isEqualType []) then {

                private _rowIndex = _args select 0;
                private _columnIndex = _args select 1;

                private _grid = [_logic,"grid"] call ALiVE_fnc_hashGet;

                _result = ["",[],[],nil];

                if((count _grid > 0 && count _grid > _columnIndex && _columnIndex >= 0)) then {
                    private _column = _grid select _columnIndex;

                    if (count _column > _rowIndex && _rowIndex >= 0) then {
                        _result = _column select _rowIndex;
                    }
                };

            };

        };

        case "positionToSector": {

            private["_position","_gridIndex"];

            if (_args isEqualType []) then {

                private _position = _args;

                private _gridIndex = [_logic, "positionToGridIndex", _position] call MAINCLASS;

                _result = [_logic, "gridIndexToSector", _gridIndex] call MAINCLASS;

            };

        };

        case "surroundingSectors": {

            if (_args isEqualType []) then {

                private _position = _args;

                private _gridIndex = [_logic, "positionToGridIndex", _position] call MAINCLASS;

                private _indexX = _gridIndex select 0;
                private _indexY = _gridIndex select 1;

                _result = [];

                // bottom-left

                private _index = [(_indexX - 1),(_indexY - 1)];
                private _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // middle-left

                _index = [(_indexX - 1),(_indexY)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // top-left

                _index = [(_indexX - 1),(_indexY + 1)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // top-middle

                _index = [(_indexX),(_indexY + 1)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // top-right

                _index = [(_indexX + 1),(_indexY + 1)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // middle-right

                _index = [(_indexX + 1),(_indexY)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // bottom-right

                _index = [(_indexX + 1),(_indexY - 1)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

                // bottom-middle

                _index = [(_indexX),(_indexY - 1)];
                _sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;

                if (count (_sector select 1) > 0) then {
                    _result pushback _sector;
                };

            };

        };

        case "sectorsInRadius": {

            if (_args isEqualType []) then {

                private _position = _args select 0;
                private _radius = _args select 1;

                private _sectorDimensions = [_logic,"sectorDimensions"] call ALiVE_fnc_hashGet;

                private _sectorWidth = _sectorDimensions select 0;
                private _sectors = [];

                if (_radius > _sectorWidth) then {
                    private _allSectors = [_logic,"sectors"] call ALiVE_fnc_hashGet;

                    {
                        _center = [_x, "center"] call ALiVE_fnc_sector;

                        if (_center distance2D _position <= _radius) then {
                            _sectors pushback _x;
                        };
                    } forEach _allSectors;

                    _result = _sectors;
                } else {
                    private _sector = [_logic, "positionToSector", _position] call MAINCLASS;
                    private _surroundingSectors = [_logic, "surroundingSectors", _position] call MAINCLASS;

                    _sectors set [0, _sector];

                    {
                        private _sector = _x;
                        private _bounds = [_sector, "bounds"] call ALiVE_fnc_sector;
                        private _within = false;

                        {
                            if (_x distance2D _position <= _radius) then {
                                _within = true;
                            };
                        } forEach _bounds;

                        if (_within) then {
                            _sectors pushback _sector;
                        };
                    } forEach _surroundingSectors;

                    _result = _sectors;
                };

            };

        };

        default {

            _result = [_logic, _operation, _args] call SUPERCLASS;

        };
};

TRACE_1("sectorGrid - output", _result);

_result;