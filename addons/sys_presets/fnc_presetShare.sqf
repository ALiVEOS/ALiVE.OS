#include "script_component.hpp"
SCRIPT(presetShare);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetShare

Description:
Puts the scenario's ALiVE setup on the clipboard as a preset, and says what went
into it.

This is the whole of sharing for now: copy, and paste it wherever you like. The
message names how many modules and settings were taken and what was left out, so
a preset that quietly lost a commander's area marker says so on the way past
rather than on somebody else's map a week later.

Parameters:
    None.

Returns:
    STRING - the preset text, also on the clipboard, or "" if there was nothing
    to share

Examples:
    (begin example)
    [] call ALIVE_fnc_presetShare;
    (end)

See Also:
    ALIVE_fnc_presetCollect, ALIVE_fnc_presetSerialize

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_choice", [], [[]]]];

if (!is3DEN) exitWith { "" };

// Nothing chosen means everything, which is what the right click entry asks for.
// The window hands over two lists instead, so somebody can share part of what is
// in front of them.
([_choice] call ALIVE_fnc_presetCollect) params ["_preset", "_report"];
_report params [["_modules", 0], ["_settings", 0], ["_links", 0], ["_dropped", []], ["_mods", []], ["_missing", []]];

if (count _preset == 0) exitWith {
    ["This scenario has no ALiVE modules to share.", 1, 8] call BIS_fnc_3DENNotification;
    ""
};

private _text = _preset call ALIVE_fnc_presetSerialize;
if (_text isEqualTo "") exitWith {
    ["The preset could not be written out. Nothing was copied.", 2, 10] call BIS_fnc_3DENNotification;
    ""
};

copyToClipboard _text;

private _msg = format ["Preset copied: %1 module%2, %3 setting%4, %5 link%6, %7 characters.",
    _modules, ["s", ""] select (_modules == 1),
    _settings, ["s", ""] select (_settings == 1),
    _links, ["s", ""] select (_links == 1),
    count _text];

private _areas = count (_preset param [7, []]);
if (_areas > 0) then {
    _msg = _msg + format [" %1 area%2 came with it.", _areas, ["s", ""] select (_areas == 1)];
};
if (count _dropped > 0) then {
    _msg = _msg + format [" Left out: %1.", _dropped joinString ", "];
};
// Named by a setting and not carried, which is why that setting was left out.
// Saying only that the setting went would leave the person guessing at the cause.
if (count _missing > 0) then {
    _msg = _msg + format [" These areas are not in the preset, so the settings naming them went too: %1.", _missing joinString ", "];
};
if (count _mods > 0) then {
    _msg = _msg + format [" Expects: %1.", _mods joinString ", "];
};

[_msg, 0, 12] call BIS_fnc_3DENNotification;
["ALIVE_fnc_presetShare - %1", _msg] call ALiVE_fnc_dump;
["ALIVE_fnc_presetShare - %1", _text] call ALiVE_fnc_dump;

_text
