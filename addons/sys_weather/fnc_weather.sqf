#include "\x\alive\addons\sys_weather\script_component.hpp"
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
            // weather_initial_setting is a Combo attribute without a
            // typeName = "NUMBER" hint in CfgVehicles, so Eden saves the
            // selected value to SQM as a STRING ("0".."6"). Downstream
            // comparisons (INITIAL_WEATHER == 4, switch cases) need a
            // Number and throw "Generic error in expression" on a
            // String. Normalise to Number at the read site.
            private _iw = _logic getvariable ["weather_initial_setting",4];
            if (_iw isEqualType "") then { _iw = parseNumber _iw };
            INITIAL_WEATHER = _iw;
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
    WEATHER_DEBUG = ((_logic getvariable ["weather_debug_setting","false"]) == "true");
    WEATHER_DEBUG_CYCLE = _logic getvariable ["weather_debug_cycle_setting",60];
    WEATHER_CYCLE_DELAY = _logic getvariable ["weather_cycle_delay_setting",1800];
    WEATHER_CYCLE_VARIANCE = _logic getvariable ["weather_cycle_variance_setting",0.2];
    WEATHER_CYCLE_REAL_LOCATION = _logic getvariable ["weather_real_location_setting",""];
    // weather_override_setting: same Combo-stores-as-String issue as
    // weather_initial_setting above; see rationale there.
    private _wo = _logic getvariable ["weather_override_setting",0];
    if (_wo isEqualType "") then { _wo = parseNumber _wo };
    WEATHER_OVERRIDE = _wo;

    Waituntil {!(isnil "WEATHER_DEBUG")};
    [] call ALIVE_fnc_weatherServerInit;

    if (WEATHER_DEBUG) then { [WEATHER_DEBUG_CYCLE] spawn ALIVE_fnc_weatherDebugEvent; };

    // Precipitation: Snow (#232) makes every machine with a screen draw its rain as falling snow.
    [_logic, "snow"] call ALIVE_fnc_weather;

    };
    // The engine's own snow (Arma 2.08+): the rain particles are swapped for snowflakes on this
    // machine, so it falls where rain would and never indoors. How much falls still follows the
    // rain the module sets. Each machine sets it for itself, joiners included, as the module runs
    // everywhere.
    case "snow": {
        if (hasInterface && {(toLower format ["%1", _logic getVariable ["weather_precipitation_setting", "rain"]]) == "snow"}) then {
            setRain ["a3\data_f\snowflake4_ca.paa", 4, 0.01, 25, 0.05, 2.5, 0.5, 0.5, 0.07, 0.07, [1, 1, 1, 0.5], 0, 0.2, 0.5, 0.5, true, false];
        };
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

