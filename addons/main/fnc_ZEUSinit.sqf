#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(ZEUSinit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ZEUSinit

Description:
Inits ZEUS including backwardcompatibility (to be removed after release)
Sets a clientside loop that merges ZEUS module position globally with the local ZEUS camera position.
This way all localities know about ZEUS modules position and server can spawn ALiVE AI when the curator 
moves around with the cam without the use of PVS/PV/BUS and minimising network traffic.

Notes:
dynamic helperfunctions to be removed when commands are available in public, start/end loop if EH for "Zeus called" exists
Important, enable  in Post Init during XEH_postInit.sqf!

Parameters:
none

Examples:
(begin example)
call ALIVE_fnc_ZEUSinit;
(end)

See Also:
- Main/eventhandlers.hpp
- Main/XEH_postInit.sqf
- Main/fnc_anyPlayersInRangeIncludeAir.sqf

Author:
Highhead
---------------------------------------------------------------------------- */

//Exit if Zeus not placed with an empty default function to save perf
if !(["ModuleCurator_F"] call ALiVE_fnc_isModuleAvailable) exitwith {ALiVE_fnc_ZeusRegister = {}};

//Register dynamic helperfunction on all localities
ALiVE_fnc_ZeusRegister = {
    [_this] spawn {
        private ["_unit"];
        _unit = _this select 0;
        {_x addCuratorEditableObjects [_unit]} foreach allCurators;
    };
};

//BIS give me an EH when Zeus is active so I can start and end that loop
//Run loop only on clients
if (hasInterface) then {
    [] spawn {
		private ["_curatorLogic","_curatorCamPos"];
		while {true} do {
			_curatorLogic = getAssignedCuratorLogic player;
		
			if !(isnil "_curatorLogic") then {
		 		if !(isnull curatorcamera) then {
					_curatorCamPos = getposATL curatorcamera;
					_curatorLogic setposATL _curatorCamPos;
				} else {
					_curatorLogic setposATL [-5000,-5000,5000];
				};
			};
			sleep 1;
		};
    };
};