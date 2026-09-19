#include "script_component.hpp"
SCRIPT(presetSerialize);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetSerialize

Description:
Writes a preset out as one line of text, and refuses to hand back anything that
does not read back as exactly what went in.

The text is plain data: brackets, commas, numbers, true and false, and quoted
text. It is read with parseSimpleArray, which cannot run code, so a preset from a
stranger is data all the way through. Measured: code, a code block and a bare
name all come back as an empty array from that reader, and none of them run.

The round trip is checked here rather than trusted. The hard case is a setting
whose value is itself a quoted list, as the commander's factions setting is: the
text ["BLU_F"] held as text, quotes and all. That survives (measured), and if a
future value ever does not, this returns nothing rather than handing somebody a
preset that will not load.

Parameters:
    _preset - ARRAY - the preset, as ALIVE_fnc_presetCollect builds it

Returns:
    STRING - the preset as one line, or "" if it did not survive the round trip

Examples:
    (begin example)
    private _text = _preset call ALIVE_fnc_presetSerialize;
    (end)

See Also:
    ALIVE_fnc_presetCollect, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

// The preset IS the argument, so it is taken whole rather than through params:
// params would read the preset as a list of arguments and take its first element,
// the format's own name, as the preset.
private _preset = _this;

if !(_preset isEqualType []) exitWith { "" };
if (count _preset == 0) exitWith { "" };

private _text = str _preset;
private _back = parseSimpleArray _text;

if !(_back isEqualTo _preset) exitWith {
    ["ALIVE_fnc_presetSerialize - the preset did not survive being written out and read back, so nothing was produced"] call ALiVE_fnc_dump;
    ""
};

_text
