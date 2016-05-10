#include <\x\alive\addons\mil_convoy\script_component.hpp>

SCRIPT(convoy);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_convoy
Description:
XXXXXXXXXX

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

Description:
Transport Module! Detailed description to follow

Examples:
[_logic, "factions", ["OPF_F"] call ALiVE_fnc_Transport;
[_logic, "houses", _nonStrategicHouses] call ALiVE_fnc_Transport;
[_logic, "spawnDistance", 500] call ALiVE_fnc_Transport;
[_logic, "active", true] call ALiVE_fnc_Transport;

See Also:
- <ALIVE_fnc_TransportInit>

Author:
Gunny

---------------------------------------------------------------------------- */

#define SUPERCLASS nil

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);


switch(_operation) do {              
		default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
		/*MODEL - no visual just reference data
		- server side object only
		- enabled/disabled
		*/
		// Ensure only one module is used
		case "init": {  
		
				if (isServer) then {
		 			 //Initialise module game logic on all localities (clientside spawn)
		                _logic setVariable ["super", SUPERCLASS];
		                _logic setVariable ["class", ALIVE_fnc_CONVOY];
		                _logic setVariable ["init", true, true]; 
		
						_logic setvariable ["conv_intensity_setting",(parsenumber (_logic getvariable["conv_intensity_setting","1"])),true];
						_logic setvariable ["conv_safearea_setting",(parsenumber (_logic getvariable["conv_safearea_setting","2000"])),true];
						_logic setvariable ["conv_debug_setting",(call compile (_logic getvariable["conv_debug_setting","false"])),true];
						_logic getvariable ["conv_factions_setting","OPF_F"];
		
						/*
		                CONVOY_GLOBALDEBUG = _logic getvariable ["conv_debug_setting",false];
		                CONVOY_safearea = _logic getvariable ["conv_safearea_setting",2000];
						CONVOY_intensity = _logic getvariable ["conv_intensity_setting",1];
						*/

						[_logic] call ALIVE_fnc_startConvoy;
				};
				
				//Clients
				if(!isDedicated && !isHC) then {};
		};

     	case "destroy": {
			if (isServer) then {

			// if server
			_logic setVariable ["super", nil];
			_logic setVariable ["class", nil];
			_logic setVariable ["init", nil];
			// and publicVariable to clients
			MOD(convoy) = _logic;
			publicVariable QMOD(convoy);
		};
	};
       
};
