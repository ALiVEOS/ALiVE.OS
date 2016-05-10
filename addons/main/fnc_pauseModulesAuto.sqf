#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(PauseModulesAuto);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_PauseModulesAuto

Description:
Adds connected EHs with checks for players on server to auto-pause the main modules

Parameters:
- none

Examples:
(begin example)
call ALiVE_fnc_pauseModulesAuto
(end)

See Also:
ALiVE_fnc_PauseModule

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

[QMOD(PAUSEMODULES_EH_DISCONNECTED),"onPlayerDisconnected", {
    [] spawn {
       
        sleep 30;
        
		if (({isPlayer _x} count playableUnits) == 0) then {
            
            ["ALiVE - Pausing Modules"] call ALiVE_fnc_DumpR;
            
			[
            	"ALIVE_SYS_PROFILE",
				"ALIVE_MIL_OPCOM",
                "ALiVE_MIL_CQB",
				"ALIVE_AMB_CIV_POPULATION"
			] call ALiVE_fnc_pauseModule;
            
            GVAR(PAUSEMODULES_PAUSED) = true;
            PublicVariable QGVAR(PAUSEMODULES_PAUSED);
		};
    };
}] call BIS_fnc_addStackedEventHandler;

[QMOD(PAUSEMODULES_EH_CONNECTED),"onPlayerConnected", {
            
			if (!isnil QGVAR(PAUSEMODULES_PAUSED)) then {
 
                GVAR(PAUSEMODULES_PAUSED) = nil;
                PublicVariable QGVAR(PAUSEMODULES_PAUSED);                               
                
                ["ALiVE - Starting Modules"] call ALiVE_fnc_DumpR;
        
		[
        	"ALIVE_SYS_PROFILE",
			"ALIVE_MIL_OPCOM",
            "ALiVE_MIL_CQB",
			"ALIVE_AMB_CIV_POPULATION"
		] call ALiVE_fnc_unPauseModule;
	};
}] call BIS_fnc_addStackedEventHandler;        
