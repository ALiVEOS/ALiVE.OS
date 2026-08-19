#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(dumpR);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpR

Description:
Dumps variables to the RPT file and also to the players radio

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable
[getPos player] call ALIVE_fnc_dumpR;

// dump as format
["position: %1", getPos player] call ALIVE_fnc_dumpR;
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */
private ["_variable","_variableType","_output"];

_variable = _this select 0;
_variableType = typename _variable;
_output = "";

if(count _this > 1) then {
    _variable = format _this;
};

if(isNil {_variableType}) then {
    _output = ["IS NIL"];
} else {
    if(_variableType == "STRING") then {
        _output = _variable;
    } else {
        _output = str _variable;
    };
};

// Keep the faults raised while the mission is still starting up, so the startup screen can
// show them. Something going wrong during startup is exactly what someone sitting in front of
// that screen wants to know about, and otherwise it goes only to the log, which nobody is
// reading at the time.
//
// Only faults are taken from here. What a module is doing belongs to module init, which
// reports its own starts and finishes; this channel carries anything a module cares to say,
// and taking all of it put "Garbage Collector starting..." in front of players in red, then
// filled the screen with OPCOM debug traffic that says nothing about loading.
//
// Sorted into two kinds, because they do not mean the same thing and should not look alike.
// Something that stopped is an error. Something that carried on anyway is a warning: ATO
// giving up on a slow AI Commander after two minutes reads as a failure but is not one, as it
// goes straight on to merge that commander's factions and continues starting up.
//
// The words below were taken from what the modules actually say rather than picked in advance.
// "no" and "can't" were tried and dropped: they match "Zeus is inactive and no unit is remote
// controlled" and "The civilian can't understand what you are saying", neither of which is a
// fault.
//
// Server only, and only until startup finishes, so this costs nothing during play.
if (isServer && {isNil "ALiVE_REQUIRE_INITIALISED"} && {_output isEqualType ""}) then {
    private _lower = toLower _output;

    private _severity = "";
    {
        if ((_lower find _x) > -1) exitWith { _severity = "error" };
    } forEach ["error", "fail", "abort", "cannot", "unable", "invalid"];

    if (_severity == "") then {
        {
            if ((_lower find _x) > -1) exitWith { _severity = "warning" };
        } forEach ["warn", "gave up", "timeout", "timed out"];
    };

    if (_severity != "") then {
        // Kept for the whole of startup rather than rotated, so ordinary progress cannot push
        // a fault off the screen seconds after it appeared. Repeats of one already listed are
        // dropped, or a single fault raised in a loop would fill the screen with itself and
        // hide everything else.
        if (isNil "ALiVE_initWarnings") then { ALiVE_initWarnings = [] };

        if ((ALiVE_initWarnings findIf {(_x select 1) == _output}) < 0) then {
            ALiVE_initWarnings pushBack [_severity, _output];
            while {count ALiVE_initWarnings > 5} do { ALiVE_initWarnings deleteAt 0 };

            publicVariable "ALiVE_initWarnings";
        };
    };
};

player sidechat _output;

_this call ALIVE_fnc_dump;