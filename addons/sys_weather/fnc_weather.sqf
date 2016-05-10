#include <\x\alive\addons\sys_weather\script_component.hpp>
SCRIPT(weather);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weather
Description:
Creates the server side object to store settings

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

The popup menu will change to show status as functions are enabled and disabled.

Examples:
(begin example)
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_weatherInit>


Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS nil

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,[]);

switch(_operation) do {
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
                                - enabled/disabled
                */

                // Ensure only one module is used
                if (isServer && !(isNil QMOD(weather))) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_WEATHER_ERROR1");
                };
                if (isServer) then {
                        MOD(weather) = _logic;
                        publicVariable QMOD(weather);

                        // if server, initialise module game logic
                        _logic setVariable ["super", SUPERCLASS];
                        _logic setVariable ["class", ALIVE_fnc_weather];
                        _logic setVariable ["init", true, true];
                        INITIAL_WEATHER = _logic getvariable ["weather_initial_setting",4];
                } else {
                        // if client clean up client side game logics as they will transfer
                        // to servers on client disconnect
                       // deleteVehicle _logic;
                };
                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil QMOD(weather)};
                waitUntil {MOD(weather) getVariable ["init", false]};

                /*
                VIEW - purely visual
                - initialise
                */
                WEATHER_DEBUG = call compile (_logic getvariable ["weather_debug_setting","false"]);
                WEATHER_DEBUG_CYCLE = _logic getvariable ["weather_debug_cycle_setting",60];
                WEATHER_CYCLE_DELAY = _logic getvariable ["weather_cycle_delay_setting",1800];
                WEATHER_CYCLE_VARIANCE = _logic getvariable ["weather_cycle_variance_setting",0.2];
                WEATHER_CYCLE_REAL_LOCATION = _logic getvariable ["weather_real_location_setting",""];
                WEATHER_OVERRIDE = _logic getvariable ["weather_override_setting",0]; 

                Waituntil {!(isnil "WEATHER_DEBUG")};
				[] call ALIVE_fnc_weatherServerInit;

				if (WEATHER_DEBUG) then { [WEATHER_DEBUG_CYCLE] spawn ALIVE_fnc_weatherDebugEvent; };

        };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        MOD(weather) = _logic;
                        publicVariable QMOD(weather);
                };
        };
        default {
                private["_err"];
                _err = format["%1 does not support %2 operation", _logic, _operation];
                ERROR_WITH_TITLE(str _logic,_err);
        };
};

