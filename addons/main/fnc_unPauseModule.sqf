#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(unPauseModule);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_unPauseModule

Description:
activates the given module(s) after pause

Parameters:
Array with strings - pass modules like ["ALiVE_sys_profile","ALiVE_mil_OPCOM"] 

Examples:
(begin example)
["ALiVE_sys_profile","ALiVE_mil_OPCOM"] call ALiVE_fnc_unPauseModule
(end)

See Also:
ALiVE_fnc_pauseModule

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_modules"];

_modules = _this;
{_modules set [_foreachIndex,tolower(_x)]} foreach _modules;

if !(isServer) exitwith {
    ["server","ALiVE_PAUSE",[_modules,"ALiVE_fnc_unPauseModule"]] call ALiVE_fnc_BUS;
};

{
    private ["_mod","_handler","_mainclass"];
    
    _mod = _x;
    
    if (tolower(typeOf _mod) in _modules) then {
        
    	_handler = _mod getvariable ["handler",["",[],[],nil]];
        _mainclass = _mod getvariable ["class",([_handler,"class"] call ALiVE_fnc_HashGet)];
        
        if (typeName _mainClass == "STRING") then {_mainclass = compile _mainclass};
        
	    switch (typeOf _mod) do {
            
            //Example for special cases if needed, add your module pause code in here
	        case ("") : {};
            
            //Default: Call "pause" operation of the module main class
	        default {
                if (count (_handler select 1) > 0) then {
			        [_handler,"pause",false] call _mainclass;
				} else {
			        [_mod,"pause",false] call _mainclass;
			    };
            };
	    };
    };
} foreach (entities "Module_F");
