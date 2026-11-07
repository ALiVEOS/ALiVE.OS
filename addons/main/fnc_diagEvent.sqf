#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(diagEvent);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_diagEvent

Description:
Records one diagnostics event for the War Room in a DEV build. Does nothing in a
release build, on a client, or while diagnostics are off. Codes, and the shape of
a row, are in diag_codes.hpp.

At most 6 rows a minute for one code: the rest are counted, and the next row of
that code carries the count as its 7th element.

Parameters:
String - category (DIAG_PATH, DIAG_ML, DIAG_SPAWN, DIAG_OPCOM, DIAG_ERROR)
String - code
String - text, cut to 200 characters
Array - (optional) position

Returns:
Nothing

Examples:
(begin example)
if (!isNil "ALiVE_fnc_diagEvent") then { ["PATH", "PATH_ONE_POINT", "LandRoad route came back as one point", _pos] call ALiVE_fnc_diagEvent };
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if !(missionNamespace getVariable ["ALiVE_diag_active", false]) exitWith {};
params [["_category", "", [""]], ["_code", "", [""]], ["_text", "", [""]], ["_pos", [], [[]]]];

private _now = time;
private _times = ALiVE_diag_codeTimes getOrDefault [_code, []];
_times = _times select { _now - _x < 60 };
if (count _times >= 6) exitWith {
    ALiVE_diag_codeTimes set [_code, _times];
    ALiVE_diag_codeHeld set [_code, (ALiVE_diag_codeHeld getOrDefault [_code, 0]) + 1];
};
_times pushBack _now;
ALiVE_diag_codeTimes set [_code, _times];

ALiVE_diag_seq = ALiVE_diag_seq + 1;
private _row = [
    ALiVE_diag_seq, round (_now * 10) / 10, _category, _code, _text select [0, 200],
    if (count _pos >= 2) then { [round (_pos select 0), round (_pos select 1)] } else { [] }
];
private _held = ALiVE_diag_codeHeld getOrDefault [_code, 0];
if (_held > 0) then {
    _row pushBack (_held + 1);
    ALiVE_diag_codeHeld deleteAt _code;
};
ALiVE_diag_events pushBack _row;
if (count ALiVE_diag_events > 200) then { ALiVE_diag_events deleteAt 0 };
