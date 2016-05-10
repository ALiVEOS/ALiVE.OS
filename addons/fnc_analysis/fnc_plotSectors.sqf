#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(plotSectors);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates visual representations of sector data

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters
String - id - ID name of the grid

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Array - plot - Array of sectors and key to plot data

Examples:
(begin example)
// create a sector plot
_logic = [nil, "create"] call ALIVE_fnc_plotSectors;

// the grid id
_result = [_logic, "id", "myPlotter"] call ALIVE_fnc_plotSectors;

// plot sectors
_result = [_logic, "plot", [_sectors, "key"]] call ALIVE_fnc_plotSectors;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_plotSectors

private ["_result"];

TRACE_1("plotSectors - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_PLOTSECTORS_%1"

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
						
						[_logic,"id","plotter"] call ALIVE_fnc_hashSet;
						[_logic,"plots",[]] call ALIVE_fnc_hashSet;
                };
                
                /*
                VIEW - purely visual
                */
                
                /*
                CONTROLLER  - coordination
                */
        };
        case "destroy": {
				
                if (isServer) then {
				
						// clear plots
						[_logic, "clear"] call MAINCLASS;
												
                        // if server
                        [_logic,"super"] call ALIVE_fnc_hashRem;
						[_logic,"class"] call ALIVE_fnc_hashRem;
                        
                        [_logic, "destroy"] call SUPERCLASS;					
                };
                
        };
		case "id": {
				if(typeName _args == "STRING") then {
						[_logic,"id",_args] call ALIVE_fnc_hashSet;
                };
				
				_result = [_logic,"id"] call ALIVE_fnc_hashGet;
        };
		case "plot": {
				private["_sectors","_sector","_key","_plotterID","_plots","_plot"];
				
				_sectors = _args select 0;
				_key = _args select 1;
				
				_plotterID = [_logic,"id"] call ALIVE_fnc_hashGet;
				
				_plots = [];
				
				{
					_sector = _x;
					_plot = [nil, "create"] call ALIVE_fnc_sectorPlot;
					[_plot, "plotterID", _plotterID] call ALIVE_fnc_sectorPlot;
					[_plot, "plot", [_sector, _key]] call ALIVE_fnc_sectorPlot;
					_plots set [count _plots, _plot];
				} forEach _sectors;

				[_logic,"plots",_plots] call ALIVE_fnc_hashSet;
        };
		case "clear": {
				private["_plots"];
				
				_plots = [_logic,"plots"] call ALIVE_fnc_hashGet;
				
				{
					_result = [_x, "destroy", false] call ALIVE_fnc_sectorPlot;
				} forEach _plots;
		};
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("plotSectors - output",_result);
_result;