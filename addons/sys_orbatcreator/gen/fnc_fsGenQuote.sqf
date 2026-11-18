#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenQuote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenQuote

Description:
Free text to a quoted config string: every " doubled, every character below
code 32 turned into a space, the whole wrapped in ".

Parameters:
    _text - STRING

Returns:
    STRING - the quoted text

Examples:
    (begin example)
    ["Altis ""Militia"""] call ALiVE_fnc_fsGenQuote; // "Altis ""Militia"""
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_text", "", [""]]];

private _out = [34];
{
    if (_x < 32) then {
        _out pushBack 32;
    } else {
        _out pushBack _x;
        if (_x == 34) then { _out pushBack 34 };
    };
} forEach (toArray _text);
_out pushBack 34;
toString _out
