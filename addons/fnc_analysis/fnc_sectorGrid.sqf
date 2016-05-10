#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorGrid);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
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
_logic = [nil, "create"] call ALIVE_fnc_sectorGrid;

// the grid id
_result = [_logic, "id", "myGrid"] call ALIVE_fnc_sectorGrid;

// the grid origin position
_result = [_logic, "gridPosition", [0,0]] call ALIVE_fnc_sectorGrid;

// the size of the grid
_result = [_logic, "gridSize", 1000] call ALIVE_fnc_sectorGrid;

// set sector dimensions 
_result = [_logic, "sectorDimensions", [500,500]] call ALIVE_fnc_sectorGrid;

// set the sector class type
_result = [_logic, "sectorType", "SECTOR"] call ALIVE_fnc_sectorGrid;

// create the grid
_result = [_logic, "createGrid"] call ALIVE_fnc_sectorGrid;

// get the array of all sectors
_result = [_logic, "sectors"] call ALIVE_fnc_sectorGrid;

// position to grid index
_result = [_logic, "positionToGridIndex", getPos Player] call ALIVE_fnc_sectorGrid;

// grid index to sector
_result = [_logic, "gridIndexToSector", [0,4]] call ALIVE_fnc_sectorGrid;

// position to sector
_result = [_logic, "positionToSector", getPos Player] call ALIVE_fnc_sectorGrid;

// surrounding sectors
_result = [_logic, "surroundingSectors", getPos player] call ALIVE_fnc_sectorGrid;

// sectors in radius
_result = [_logic, "sectorsInRadius", [getPos player, 1000]] call ALIVE_fnc_sectorGrid;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_sectorGrid

private ["_result"];

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
                        [_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;

						// set defaults
						[_logic,"id","grid"] call ALIVE_fnc_hashSet;
						[_logic,"gridPosition",[0,0]] call ALIVE_fnc_hashSet;
						[_logic,"gridSize",[] call ALIVE_fnc_getMapBounds] call ALIVE_fnc_hashSet;
						[_logic,"sectorDimensions",[1000,1000]] call ALIVE_fnc_hashSet;
						[_logic,"sectorType","SECTOR"] call ALIVE_fnc_hashSet;
                };                
                
                /*
                VIEW - purely visual
                */
                
                /*
                CONTROLLER  - coordination
                */
        };
        case "destroy": {
                private["_allSectors"];
                [_logic, "debug", false] call MAINCLASS;
                if (isServer) then {
                        // if server
                        
						_allSectors = [_logic,"sectors"] call ALIVE_fnc_hashGet;
						
						if(count _allSectors > 0) then {
							// switch off debug on all grid sectors
							{
								_result = [_x, "destroy", false] call ALIVE_fnc_sector;
							} forEach _allSectors;
						};				
						
						[_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
						[_logic, "destroy"] call SUPERCLASS;						
                };
                
        };
        case "debug": {
				private["_allSectors"];
                if(typeName _args != "BOOL") then {
						_args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };                
                ASSERT_TRUE(typeName _args == "BOOL",str _args);
				
				_allSectors = [_logic,"sectors"] call ALIVE_fnc_hashGet;
				
				if(count _allSectors > 0) then {
					// switch off debug on all grid sectors
					{
						_result = [_x, "debug", false] call ALIVE_fnc_sector;
					} forEach _allSectors;					
					
					if(_args) then {
						// switch on debug on all grid sectors
                        {
							_result = [_x, "debug", true] call ALIVE_fnc_sector;
						} forEach _allSectors;
					};
				};				
                
                _result = _args;
        };        
        case "state": {
				private["_state"];
                
				if(typeName _args != "ARRAY") then {
						
						// Save state
				
                        _state = [] call ALIVE_fnc_hashCreate;
						
						{
							if(!(_x == "super") && !(_x == "class")) then {
								[_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
							};
						} forEach (_logic select 1);
                       
                        _result = _state;
						
                } else {
						ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

                        // Restore state
						
                        {
							[_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
						} forEach (_args select 1);
                };
        };
		case "id": {
				if(typeName _args == "STRING") then {
						[_logic,"id",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"id"] call ALIVE_fnc_hashGet;
        };
		case "gridPosition": {
				if(typeName _args == "ARRAY") then {
						[_logic,"gridPosition",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"gridPosition"] call ALIVE_fnc_hashGet;
        };
		case "gridSize": {
				if(typeName _args == "SCALAR") then {
						[_logic,"gridSize",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"gridSize"] call ALIVE_fnc_hashGet;
        };
		case "sectorDimensions": {
				if(typeName _args == "ARRAY") then {
						[_logic,"sectorDimensions",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"sectorDimensions"] call ALIVE_fnc_hashGet;
        };
		case "sectorType": {
				if(typeName _args == "STRING") then {
						[_logic,"sectorType",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"sectorType"] call ALIVE_fnc_hashGet;
        };
		case "createGrid": {
				private["_gridID","_gridPosition","_gridSize","_sectorDimensions","_sectorType","_grid","_allSectors","_gridPositionX","_gridPositionY","_sectorWidth","_sectorHeight","_rows","_columns","_sectors","_row","_column","_sector","_position"];
				
				_gridID = [_logic,"id"] call ALIVE_fnc_hashGet;
				_gridPosition = [_logic,"gridPosition"] call ALIVE_fnc_hashGet;
				_gridSize = [_logic,"gridSize"] call ALIVE_fnc_hashGet;
				_sectorDimensions = [_logic,"sectorDimensions"] call ALIVE_fnc_hashGet;
				_sectorType = [_logic,"sectorType"] call ALIVE_fnc_hashGet;
				
				_grid = [];
				_allSectors = [];
				
				_gridPositionX = _gridPosition select 0;
				_gridPositionY = _gridPosition select 1;
				_sectorWidth = _sectorDimensions select 0;
				_sectorHeight = _sectorDimensions select 1;
				_rows = round(_gridSize / _sectorWidth);
				_columns = round(_gridSize / _sectorHeight);

				// create a grid of sector objects
				
				for "_column" from 0 to (_columns-1) do {
				
					_sectors = [];
					
					for "_row" from 0 to (_rows-1) do {					
					
						_position = [_gridPositionX + ((_row * _sectorWidth)+(_sectorWidth / 2)), _gridPositionY + ((_column * _sectorHeight)+(_sectorHeight / 2))];
						
						// allow different sector sub classes.
						switch(_sectorType) do
						{
							case "SECTOR": {							
								_sector = [nil, "create"] call ALIVE_fnc_sector;
								[_sector, "init"] call ALIVE_fnc_sector;
								[_sector, "gridID", _gridID] call ALIVE_fnc_sector;
								[_sector, "dimensions", [(_sectorWidth / 2), (_sectorHeight / 2)]] call ALIVE_fnc_sector;
								_result = [_sector, "position", _position] call ALIVE_fnc_sector;
								_result = [_sector, "id", format["%1_%2",_row,_column]] call ALIVE_fnc_sector;
							};
						};	

						_sectors set [count _sectors, _sector];
						_allSectors set [count _allSectors, _sector];
					};
					
					_grid set [count _grid, _sectors];
				};
				
				[_logic,"sectors",_allSectors] call ALIVE_fnc_hashSet;
				[_logic,"grid",_grid] call ALIVE_fnc_hashSet;
								
				_result = _grid;
        };
		case "sectors": {
			   _result = [_logic,"sectors"] call ALIVE_fnc_hashGet;
        };
		case "positionToGridIndex": {
				private["_position","_positionX","_positionY","_gridPosition","_gridPositionX","_gridPositionY","_gridSize","_sectorDimensions","_sectorWidth","_sectorHeight","_relativePositionX","_relativePositionY","_column","_row"];
				
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_position = _args;
				_positionX = _position select 0;
				_positionY = _position select 1;
				
				_gridPosition = [_logic,"gridPosition"] call ALIVE_fnc_hashGet;				
				_gridPositionX = _gridPosition select 0;
				_gridPositionY = _gridPosition select 1;
				_gridSize = [_logic,"gridSize"] call ALIVE_fnc_hashGet;
				
				_sectorDimensions = [_logic,"sectorDimensions"] call ALIVE_fnc_hashGet;
				_sectorWidth = _sectorDimensions select 0;
				_sectorHeight = _sectorDimensions select 1;
				
				_result = [];
					
				// is the position inside the grid
				if(
					(_positionX > _gridPositionX) &&
					(_positionX < (_gridPositionX + _gridSize)) &&
					(_positionY > _gridPositionY) &&
					(_positionY < (_gridPositionY + _gridSize))
				) then {	
					_relativePositionX = _positionX - _gridPositionX;
					_relativePositionY = _positionY - _gridPositionY;
					
					_row = floor(_relativePositionX / _sectorWidth);
					_column = floor(_relativePositionY / _sectorHeight);
					
					_result = [_row, _column];
				}else{
					//["!!!!!POS OUTSIDE GRID: %1", _position] call ALIVE_fnc_dump;
					_result = [0, 0];
				};
        };
		case "gridIndexToSector": {
				private["_rowIndex","_columnIndex","_grid","_column"];
				
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_rowIndex = _args select 0;
				_columnIndex = _args select 1;
				
				_grid = [_logic,"grid"] call ALIVE_fnc_hashGet;
				
				_result = ["",[],[],nil];
				
				if((count _grid > 0 && count _grid > _columnIndex && _columnIndex >= 0)) then {
					_column = _grid select _columnIndex;
					if(count _column > _rowIndex && _rowIndex >= 0) then {
						_result = _column select _rowIndex;
					}					
				};
        };
		case "positionToSector": {
				private["_position","_gridIndex"];
				
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_position = _args;
				
				_gridIndex = [_logic, "positionToGridIndex", _position] call MAINCLASS;
				_result = [_logic, "gridIndexToSector", _gridIndex] call MAINCLASS;
        };
		case "surroundingSectors": {
				private["_position","_gridIndex","_indexX","_indexY","_index","_sector"];
				
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_position = _args;
				
				_gridIndex = [_logic, "positionToGridIndex", _position] call MAINCLASS;
				_indexX = _gridIndex select 0;
				_indexY = _gridIndex select 1;
				
				_result = [];
				
				//bl
				_index = [(_indexX - 1),(_indexY - 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//ml
				_index = [(_indexX - 1),(_indexY)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//tl
				_index = [(_indexX - 1),(_indexY + 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//tm
				_index = [(_indexX),(_indexY + 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//tr
				_index = [(_indexX + 1),(_indexY + 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//mr
				_index = [(_indexX + 1),(_indexY)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//br
				_index = [(_indexX + 1),(_indexY - 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
				
				//bm
				_index = [(_indexX),(_indexY - 1)];
				_sector = [_logic, "gridIndexToSector", _index] call MAINCLASS;
				if(count (_sector select 1) > 0) then {
				    _result set [count _result, _sector];
                };
        };
		case "sectorsInRadius": {
				private["_position","_radius","_sectorDimensions","_sectorWidth","_sectors","_sector","_allSectors","_centre","_surroundingSectors","_bounds","_within"];
				
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_position = _args select 0;
				_radius = _args select 1;
				
				_sectorDimensions = [_logic,"sectorDimensions"] call ALIVE_fnc_hashGet;
				
				_sectorWidth = _sectorDimensions select 0;
				_sectors = [];
				
				if(_radius > _sectorWidth) then {
					_allSectors = [_logic,"sectors"] call ALIVE_fnc_hashGet;
					
					{
						_centre = [_x, "center"] call ALIVE_fnc_sector;
						
						if(_centre distance _position <= _radius) then {
							_sectors set [count _sectors, _x];
						};
					} forEach _allSectors;
					
					_result = _sectors;
				}else{
					_sector = [_logic, "positionToSector", _position] call MAINCLASS;
					_surroundingSectors = [_logic, "surroundingSectors", _position] call MAINCLASS;
					_sectors set [0, _sector];

					{
						_sector = _x;
						_bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
						_within = false;
						{
							if(_x distance _position <= _radius) then {
								_within = true;
							};
						} forEach _bounds;
						
						if(_within) then {
							_sectors set [count _sectors, _sector];
						};
					} forEach _surroundingSectors;
					
					_result = _sectors;
				}
		};
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("sectorGrid - output",_result);
_result;