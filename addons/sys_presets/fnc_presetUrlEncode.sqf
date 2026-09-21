#include "script_component.hpp"
SCRIPT(presetUrlEncode);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetUrlEncode

Description:
Percent-encodes a string so it can be carried in a link.

A preset is mostly brackets, quotes and commas, every one of which has a meaning
in a URL, so none of it can be put in a link as it stands. Everything outside the
unreserved set is written as %XX.

Characters above 127 are passed through as they are. SQF has no way to get at the
bytes of a string, only its code points, so there is nothing here that could
write the UTF-8 for one; the browser encodes what it is handed. That is fine for
the one place this is used, a link the person clicks, and it is why the preset is
also put on the clipboard at the same time: if a name in another alphabet ever
does confuse the round trip, pasting it always works.

Parameters:
    _text - STRING - anything

Returns:
    STRING - the same text, safe to put after a # or a = in a URL

Examples:
    (begin example)
    private _safe = ["[""ALIVEPRESET"",1]"] call ALIVE_fnc_presetUrlEncode;
    (end)

See Also:
    ALIVE_fnc_presetWindow, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_text", "", [""]]];

if (_text isEqualTo "") exitWith { "" };

// The unreserved set from the URI rules: letters, digits, and these four. Held
// as code points because that is what toArray gives, so no character has to be
// compared as a string.
private _plain = toArray "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
private _digits = "0123456789ABCDEF";

private _out = "";
{
    private _code = _x;
    if (_code in _plain || {_code > 127}) then {
        _out = _out + (toString [_code]);
    } else {
        _out = _out + "%"
            + (_digits select [floor (_code / 16), 1])
            + (_digits select [_code % 16, 1]);
    };
} forEach (toArray _text);

_out
