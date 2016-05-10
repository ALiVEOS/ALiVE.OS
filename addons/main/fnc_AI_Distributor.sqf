#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(AI_Distributor);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AI_Distributor

Description:
Switches AI to available headlessClients

Parameters:
BOOL (true to turn on, false to turn off)

Examples:
(begin example)
true call ALiVE_fnc_AI_Distributor
(end)

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

waituntil {time > 0};

private ["_mode","_headlessClients"];

GVAR(AI_DISTRIBUTOR_MODE) = _this;

if (!isServer || {isnil "HEADLESSCLIENTS"} || {count HEADLESSCLIENTS == 0}) exitwith {["ALIVE AI Distributor exiting, no headless clients %1 or not server %2",HEADLESSCLIENTS,!isServer] call ALiVE_fnc_Dump};

GVAR(AI_DISTRIBUTOR) = [] spawn {
    
    private ["_HC_index","_debug"];
    
    _HC_index = 0;
    _debug = false;
    
	WHILE {GVAR(AI_DISTRIBUTOR_MODE)} do {
        
        // Create data
        GVAR(AI_LOCALITIES) = [] call ALiVE_fnc_HashCreate;
	
		{
			if (local _x && {{alive _x && {!((vehicle _x) getvariable ["ALiVE_CombatSupport",false])}} count units _x > 0}) then {
		
				//Distribute to all available HCs
				if (_HC_index > ((count HEADLESSCLIENTS)-1)) then {_HC_index = 0};
			   
				_HC = HEADLESSCLIENTS select _HC_index; _HC_index = _HC_index + 1;
			    
				_x setGroupOwner (owner _HC);
		
				["ALIVE AI Distributor switching group %1 to HC %2",_x, _HC] call ALiVE_fnc_Dump;
			};
            
            [GVAR(AI_LOCALITIES),groupOwner _x,([GVAR(AI_LOCALITIES),groupOwner _x,[]] call ALiVE_fnc_HashGet) + [_x]] call ALiVE_fnc_HashSet;
            
			sleep 0.5;
	   } foreach allGroups;

		if (_debug) then {
	        _t = ["AI DISTRIBUTION",lineBreak];
			{
	            _key = (GVAR(AI_LOCALITIES) select 1) select _foreachIndex;
	       		_valueCount = count _x;
	            
				_t = _t + [format["Loc. %1 | Groups: %2",_key,_valueCount],lineBreak];
			} foreach (GVAR(AI_LOCALITIES) select 2);
	                        
			[composeText _t] call ALiVE_fnc_DumpMPH;
        };

		// Delete data
		GVAR(AI_LOCALITIES) = nil;
	
		sleep 10;
	};
    
    ["ALIVE AI Distributor turned off (mode: %1)",GVAR(AI_DISTRIBUTOR_MODE)] call ALiVE_fnc_Dump;
    
    terminate GVAR(AI_DISTRIBUTOR);
};
