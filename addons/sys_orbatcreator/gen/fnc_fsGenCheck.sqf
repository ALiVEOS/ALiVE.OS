#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenCheck);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenCheck

Description:
Checks generated config lines before anything is written: every line holds an
even number of ", and outside quotes the braces balance and never go below
zero. Comment lines (starting //) are skipped, since they carry the faction
name.

Parameters:
    _lines - ARRAY of STRING - the config, one line each

Returns:
    ARRAY - [ok, line number of the first fault (1-based), 0 when ok]

Examples:
    (begin example)
    ([_lines] call ALiVE_fnc_fsGenCheck) params ["_ok", "_line"];
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_lines", [], [[]]]];

private _depth = 0;
private _bad = 0;
{
    private _line = _x;
    if !(((trim _line) select [0, 2]) isEqualTo "//") then {
        private _in = false;
        private _quotes = 0;
        {
            if (_x == 34) then {
                _in = !_in;
                _quotes = _quotes + 1;
            } else {
                if (!_in) then {
                    if (_x == 123) then { _depth = _depth + 1 };
                    if (_x == 125) then { _depth = _depth - 1 };
                };
            };
        } forEach (toArray _line);
        if ((_quotes % 2) == 1 || {_depth < 0}) then { _bad = _forEachIndex + 1 };
    };
    if (_bad > 0) exitWith {};
} forEach _lines;

if (_bad == 0 && {_depth != 0}) then { _bad = count _lines };
[_bad == 0, _bad]
