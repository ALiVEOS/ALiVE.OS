#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sector);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates the server side object to create a sector

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis
String - gridID - Id of grid
Array - dimensions - Array of width, height dimensions for sector creation
Array - position - Array of width, height dimensions for sector creation
center - Returns the center point of the sector
bounds - Returns Array of corner postions BL, TL, TR, BR
Array - within - Returns if the passed position is within the sector
String - id - Id of sector
Array - data - Array of key values for storage in the sectors data hash

Examples:
(begin example)
// create a sector
_logic = [nil, "create"] call ALIVE_fnc_sector;

// set sector parent grid id
_result = [_logic, "gridID", "Grid Id"] call ALIVE_fnc_sector;

// set sector dimension
_result = [_logic, "dimensions", _dimension_array] call ALIVE_fnc_sector;

// set sector position
_result = [_logic, "position", _position_array] call ALIVE_fnc_sector;

// set sector id
_result = [_logic, "id", "Sector Id"] call ALIVE_fnc_sector;

// get sector center
_result = [_logic, "center"] call ALIVE_fnc_sector;

// get sector bounds
_result = [_logic, "bounds"] call ALIVE_fnc_sector;

// get position within sector
_result = [_logic, "within", getPos player] call ALIVE_fnc_sector;

// set arbitrary data on the sectors data hash
_result = [_logic, "data", ["key" ["values"]]] call ALIVE_fnc_sector;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_sector

private ["_result","_deleteMarkers","_createMarkers"];

TRACE_1("sector - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_SECTOR_%1"

_deleteMarkers = {
		private ["_logic"];
        _logic = _this;
        {
                deleteMarker _x;
		} forEach ([_logic,"debugMarkers", []] call ALIVE_fnc_hashGet);
};

_createMarkers = {
        private ["_logic","_markers","_m","_position","_dimensions","_debugColor","_gridID","_id"];
        _logic = _this;
        _markers = [];
		
		_position = [_logic,"position"] call ALIVE_fnc_hashGet;
		_dimensions = [_logic,"dimensions"] call ALIVE_fnc_hashGet;
		_debugColor = [_logic,"debugColor"] call ALIVE_fnc_hashGet;
		_gridID = [_logic,"gridID"] call ALIVE_fnc_hashGet;
		_id = [_logic,"id"] call ALIVE_fnc_hashGet;
		
        if((count _position > 0) && (count _dimensions > 0)) then {

				_m = createMarker [format[MTEMPLATE, format["b%1_%2",_gridID,_id]], _position];
				_m setMarkerShape "RECTANGLE";
                _m setMarkerSize _dimensions;
				_m setMarkerBrush "Border";
				_m setMarkerColor _debugColor;
							
                _markers set [count _markers, _m];
				
				_m = createMarker [format[MTEMPLATE, format["g%1_%2",_gridID,_id]], _position];
				_m setMarkerShape "RECTANGLE";
                _m setMarkerSize _dimensions;
				_m setMarkerAlpha 0.2;
				_m setMarkerBrush "Solid";
				_m setMarkerColor "ColorGreen";
							
                _markers set [count _markers, _m];
				
				_m = createMarker [format[MTEMPLATE, format["l%1_%2",_gridID,_id]], _position];
				_m setMarkerShape "ICON";
				_m setMarkerSize [0.5, 0.5];
				_m setMarkerType "mil_dot";
				_m setMarkerColor _debugColor;
                _m setMarkerText _id;
				
				_markers set [count _markers, _m];
				
				[_logic,"debugMarkers",_markers] call ALIVE_fnc_hashSet;
        };
};

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
                        TRACE_1("After module init",_logic);

						// set defaults
						[_logic,"data",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
						[_logic,"gridID","grid"] call ALIVE_fnc_hashSet;
						[_logic,"debugColor","ColorBlack"] call ALIVE_fnc_hashSet;						
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
						[_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
                        
                        [_logic, "destroy"] call SUPERCLASS;
                };
                
        };
        case "debug": {
                if(typeName _args != "BOOL") then {
						_args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
                } else {
						[_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };                
                ASSERT_TRUE(typeName _args == "BOOL",str _args);
                _logic call _deleteMarkers;
                
                if(_args) then {
                        _logic call _createMarkers;
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
		case "gridID": {
				if(typeName _args == "STRING") then {
						[_logic,"gridID",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"gridID"] call ALIVE_fnc_hashGet;
        };
		case "dimensions": {
				if(typeName _args == "ARRAY") then {
						[_logic,"dimensions",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"dimensions"] call ALIVE_fnc_hashGet;
        };
		case "position": {
				if(typeName _args == "ARRAY") then {
						[_logic,"position",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"position"] call ALIVE_fnc_hashGet;
        };
		case "id": {
				if(typeName _args == "STRING") then {
						[_logic,"id",_args] call ALIVE_fnc_hashSet;
                };
				_result = [_logic,"id"] call ALIVE_fnc_hashGet;
        };
		case "data": {
		        private ["_key","_value","_data"];
				if(typeName _args == "ARRAY") then {
					_key = _args select 0;
					_value = _args select 1;		
					_data = [_logic,"data"] call ALIVE_fnc_hashGet;
					
					_result = [_data, _key, _value] call ALIVE_fnc_hashSet;
					[_logic,"data",_result] call ALIVE_fnc_hashSet;
				};					
				_result = [_logic,"data"] call ALIVE_fnc_hashGet;
        };
		case "center": {
				_result = [_logic,"position"] call ALIVE_fnc_hashGet;
        };
		case "bounds": {
				private["_position","_dimensions","_positionX","_positionY","_sectorWidth","_sectorHeight","_positionBL","_positionTL","_positionTR","_positionBR"];
				_position = [_logic,"position"] call ALIVE_fnc_hashGet;
				_dimensions = [_logic,"dimensions"] call ALIVE_fnc_hashGet;
				
				_positionX = _position select 0;
				_positionY = _position select 1;
				_sectorWidth = _dimensions select 0;
				_sectorHeight = _dimensions select 1;
				
				_positionBL = [(_positionX - _sectorWidth), (_positionY - _sectorHeight)];
				_positionTL = [(_positionX - _sectorWidth), (_positionY + _sectorHeight)];
				_positionTR = [(_positionX + _sectorWidth), (_positionY + _sectorHeight)];
				_positionBR = [(_positionX + _sectorWidth), (_positionY - _sectorHeight)];
				
				_result = [_positionBL, _positionTL, _positionTR, _positionBR]
        };
		case "within": {
				private["_position","_positionX","_positionY","_bounds","_positionBL","_positionBLX","_positionBLY","_positionTR","_positionTRX","_positionTRY"];
				ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
				
				_position = _args;
				_positionX = _position select 0;
				_positionY = _position select 1;
				
				_bounds = [_logic, "bounds"] call MAINCLASS;
				
				_positionBL = _bounds select 0;
				_positionBLX = _positionBL select 0;
				_positionBLY = _positionBL select 1;
				_positionTR = _bounds select 2;
				_positionTRX = _positionTR select 0;
				_positionTRY = _positionTR select 1;
				
				_result = false;
				
				if(
					(_positionX > _positionBLX) &&
					(_positionY > _positionBLY) &&
					(_positionX < _positionTRX) &&
					(_positionY < _positionTRY)
				) then {
					_result = true;
				};
        };
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("sector - output",_result);

if (isnil "_result") then {nil} else {_result};