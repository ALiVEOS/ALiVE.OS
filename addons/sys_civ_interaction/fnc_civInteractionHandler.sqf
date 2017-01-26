//#define DEBUG_MODE_FULL
#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteractionHandler);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionHandler
Description:
Serverside handling of civilian interactions

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:

See Also:
- <ALiVE_fnc_civInteraction>

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALIVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_civInteractionHandler

TRACE_1("Civ Interaction Handler - input", _this);

private ["_result"];
params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull]
];

switch(_operation) do {

    case "init": {

        // only one init per instance is allowed

        if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE SYS Orbat Creator - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

        // start init

        if (isserver) then {

            MOD(civInteractionHandler) = _logic;

            _logic setVariable ["initGlobal", false];

            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];
            _logic setVariable ["moduleType", QUOTE(ADDON)];
            _logic setVariable ["startupComplete", false];

            private _state = [] call ALiVE_fnc_hashCreate;
            [_state,"asymmetricFactions", []] call ALiVE_fnc_hashSet;
            [_state,"conventionalFactions", []] call ALiVE_fnc_hashSet;

            [_logic,"debug", false] call MAINCLASS;
            [_logic,"civilianRoles", []] call MAINCLASS;
            [_logic,"state", _state] call MAINCLASS;

            [_logic,"start"] spawn MAINCLASS;

        };

    };

    case "start": {

        // wait for all mil commanders to init
        // exit after 15 minutes to detect commanders who fail init

        private _timer = 0;
        private _timeLimit = 60 * 20;

        waitUntil {
            sleep 1;
            _timer = _timer + 1;
            (_timer > _timeLimit) || {[QMOD(mil_OPCOM)] call ALiVE_fnc_isModuleInitialised};
        };

        if (_timer > _timeLimit) then {
            ["[ALiVE] Civ Interaction Handler - Military Commander stall timer reached"]; // don't exit
        };

        private _state = [_logic,"state"] call MAINCLASS;
        private _asymFac = [_state,"asymmetricFactions"] call ALiVE_fnc_hashGet;
        private _convenFac = [_state,"conventionalFactions"] call AliVE_fnc_hashGet;

        {
            if ([_x,"startupComplete"] call ALiVE_fnc_hashGet) then {

                private _factions = [_x,"factions"] call ALiVE_fnc_hashGet;

                if (([_x,"controltype"] call ALiVE_fnc_hashGet) == "asymmetric") then {
                    _asymFac append _factions;
                } else {
                    _convenFac append _factions;
                };

            };
        } foreach OPCOM_instances;

        // set module as startup complete

        _logic setVariable ["startupComplete", true];

        publicVariable QMOD(civInteractionHandler);

    };

    case "destroy": {

        if (isServer) then {

            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic, "destroy"] call SUPERCLASS;

        };

    };

    case "state": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, [] call ALiVE_fnc_hashCreate];
        };

    };

    case "debug": {

        if (_args isEqualType true) then {
            _logic setVariable [_operation, _args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation, false];
        };

    };

    case "civilianRoles": {

        if (_args isEqualType []) then {
            _logic setVariable [_operation,_args];
            _result = _args;
        } else {
            _result = _logic getVariable [_operation,[]];
        };

    };

    default {

        _result = _this call SUPERCLASS;

    };

};

TRACE_1("Civ Interaction - output", _result);

if (!isnil "_result") then {_result} else {nil};