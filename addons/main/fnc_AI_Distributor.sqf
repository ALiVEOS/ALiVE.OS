#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(AI_Distributor);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AI_Distributor

Description:
Switches AI to available headlessClients

Parameters:
BOOL (true to turn on, false to turn off, default is false)
SCALAR (seconds between distribution cycles, default is 60)

Examples:
(begin example)
[true] spawn ALiVE_fnc_AI_Distributor
[true, 30] spawn ALiVE_fnc_AI_Distributor
[false] spawn ALiVE_fnc_AI_Distributor
(end)

See Also:
-

Author:
Highhead
---------------------------------------------------------------------------- */

params
[
    ["_mode", false],
    ["_interval", 60]
];

if (!isServer) exitwith {["ALiVE AI Distributor should ONLY run on the server !"] call ALiVE_fnc_Dump};

waituntil {time > 0};

// ACEX Headless detection //
if ((isClass(configFile >> "CfgPatches" >> "acex_headless")) && {!isNil "acex_headless_enabled"}) exitWith {["ALiVE AI Distributor detected ACEX Headless module enabled, shutting down !"] call ALiVE_fnc_Dump};

GVAR(AI_DISTRIBUTOR_MODE) = _mode;

// Handle mode: <false> (disabled) calls //
if (!GVAR(AI_DISTRIBUTOR_MODE) && {isNil QGVAR(AI_DISTRIBUTOR)}) exitWith {["ALiVE AI Distributor not enabled (mode: %1).", GVAR(AI_DISTRIBUTOR_MODE)] call ALiVE_fnc_Dump};

// Handle duplicate calls //
if (GVAR(AI_DISTRIBUTOR_MODE) && {!isNil QGVAR(AI_DISTRIBUTOR)}) exitwith {["ALiVE AI Distributor already running !"] call ALiVE_fnc_Dump};

// Handle shutdown call //
if (!GVAR(AI_DISTRIBUTOR_MODE) && {!isNil QGVAR(AI_DISTRIBUTOR)}) exitWith {
    ["ALiVE AI Distributor shutting down (mode: %1).", GVAR(AI_DISTRIBUTOR_MODE)] call ALiVE_fnc_Dump;
    terminate GVAR(AI_DISTRIBUTOR);
};


GVAR(AI_DISTRIBUTOR) = [_interval] spawn {

    params ["_delay"];

    private _HC_index = 0;
    private _debug = false;

    waitUntil {!isNil QMOD(REQUIRE_INITIALISED)};

    ["ALIVE AI Distributor starting."] call ALiVE_fnc_Dump;

    while {GVAR(AI_DISTRIBUTOR_MODE)} do {

        // Create data //
        GVAR(AI_LOCALITIES) = [] call ALiVE_fnc_HashCreate;

        // Detect HCs //
        GVAR(AI_DISTRIBUTOR_HCLIST) = [];

        {
            if ((typeOf _x) == "HeadlessClient_F") then
            {
                GVAR(AI_DISTRIBUTOR_HCLIST) pushBack _x;
            };
        } forEach allPlayers;

        {
            // Abandon loop if no HCs connected //
            if (GVAR(AI_DISTRIBUTOR_HCLIST) isEqualTo []) exitWith {["ALiVE AI Distributor detected no HCs, idling for %1 seconds.", _delay] call ALiVE_fnc_Dump};

            if ((local _x) && {{(alive _x) && {!((vehicle _x) getVariable ["ALiVE_CombatSupport", false])}} count (units _x) > 0}) then {

                // Distribute to available HCs //
                if (_HC_index > ((count GVAR(AI_DISTRIBUTOR_HCLIST)) -1)) then {_HC_index = 0};

                private _HC = (GVAR(AI_DISTRIBUTOR_HCLIST) select _HC_index);
                _HC_index = (_HC_index + 1);

                _x setGroupOwner (owner _HC);

                ["ALIVE AI Distributor switching group '%1' to HC '%2'.", _x, _HC] call ALiVE_fnc_Dump;
            };

            [GVAR(AI_LOCALITIES), (groupOwner _x), ([GVAR(AI_LOCALITIES), (groupOwner _x), []] call ALiVE_fnc_HashGet) + [_x]] call ALiVE_fnc_HashSet;

            sleep 0.5;
       } foreach allGroups;

        // Debug section //
        if (_debug) then {
            private _t = ["AI DISTRIBUTION", lineBreak];
            {
                private _key = ((GVAR(AI_LOCALITIES) select 1) select _foreachIndex);
                private _valueCount = (count _x);

                _t = _t + [format ["Loc. %1 | Groups: %2", _key, _valueCount], lineBreak];
            } foreach (GVAR(AI_LOCALITIES) select 2);

            [composeText _t] call ALiVE_fnc_DumpMPH;
        };

        // Delete data //
        GVAR(AI_LOCALITIES) = nil;

        sleep _delay;
    };

    ["ALiVE AI Distributor stopped."] call ALiVE_fnc_Dump;
};
