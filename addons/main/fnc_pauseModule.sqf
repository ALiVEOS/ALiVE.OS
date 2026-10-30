#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(PauseModule);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_pauseModule

Description:
pauses the given module(s) after pause

Parameters:
Array with strings - pass modules like ["ALiVE_sys_profile","ALiVE_mil_OPCOM"]

Examples:
(begin example)
["ALiVE_sys_profile","ALiVE_mil_OPCOM"] call ALiVE_fnc_pauseModule
(end)

See Also:
ALiVE_fnc_unPauseModule

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

private ["_modules"];

_modules = _this;
{_modules set [_foreachIndex,tolower(_x)]} foreach _modules;

if !(isServer) exitwith {
    ["server","ALiVE_PAUSE",[_modules,"ALiVE_fnc_pauseModule"]] call ALiVE_fnc_BUS;
};

// Called from a module's init field (or anywhere unscheduled) the modules haven't started yet and
// their pause has to wait for that, so carry on in a scheduled thread (Jman, 30 Oct)
if (!canSuspend) exitWith {
    _modules spawn ALiVE_fnc_pauseModule;
};

// a module can only be paused once it has started: its class is set, and for the modules that pause
// through a handler (AI Commander, profiles, civilian population) the handler too
private _ready = {
    params ["_mod"];
    private _handler = _mod getVariable "handler";
    if (toLower (typeOf _mod) in ["alive_mil_opcom", "alive_sys_profile", "alive_amb_civ_population"]) exitWith {
        !isNil "_handler" && {_handler isEqualType []} && {count (_handler param [1, []]) > 0}
    };
    !isNil {_mod getVariable "class"}
};
{
    private _mod = _x;
    if (toLower (typeOf _mod) in _modules && {!(_mod call _ready)}) then {
        private _t0 = diag_tickTime;
        waitUntil { sleep 1; (_mod call _ready) || {diag_tickTime - _t0 > 600} };
        if !(_mod call _ready) then {
            ["ALiVE pauseModule: %1 had not started after 10 minutes, so it isn't paused", typeOf _mod] call ALiVE_fnc_dump;
        };
    };
} forEach (entities "Module_F");

{
    private ["_mod","_handler","_mainclass"];

    _mod = _x;

    if (tolower(typeOf _mod) in _modules) then {

        _handler = _mod getvariable ["handler",["",[],[],nil]];
        _mainclass = _mod getvariable ["class",([_handler,"class"] call ALiVE_fnc_HashGet)];

        if (isNil "_mainclass") exitWith {};
        if (typeName _mainClass == "STRING") then {_mainclass = compile _mainclass};

        switch (typeOf _mod) do {

            //Example for special cases if needed, add your module pause code in here
            case ("") : {};

            //Default: Call "pause" operation of the module main class
            default {
                if (count (_handler select 1) > 0) then {
                    [_handler,"pause",true] call _mainclass;
                } else {
                    [_mod,"pause",true] call _mainclass;
                };
            };
        };
    };
} foreach (entities "Module_F");
