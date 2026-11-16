#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(toolsWrite);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_toolsWrite

Description:
Writes text to a file under the ALiVE folder in the player's Documents (Arma 3\ALiVE), through the
alive_tools extension that replaced the old ALiVEClient one for the Map Indexer and the ORBAT export.
The text is written as given: each line break becomes a Windows one, and nothing is added at the end,
so a caller ends its own lines. Long text goes in several pieces (the extension takes 8 KB at a time).

On a dedicated server the extension only writes when that folder holds a file named allow_server.txt
(the web indexer's server has one).

Parameters:
String - the path under the ALiVE folder, e.g. "indexing/stratis/x/alive/addons/main/static/stratis_staticData.sqf"
String - "new" (empty the file first) or "add" (append)
String - the text

Returns:
Bool - true when every piece was written

Examples:
(begin example)
["indexing/stratis/log.txt", "add", "Started" + endl] call ALiVE_fnc_toolsWrite;
(end)

See Also:
ALiVE_fnc_toolsRead, ALiVE_fnc_exportWrite

Author:
Jman
---------------------------------------------------------------------------- */

params [["_path", "", [""]], ["_mode", "add", [""]], ["_text", "", [""]]];

// 8 KB a call: ASCII text goes 8000 characters at a time, anything else 2700 (at most 3 bytes a character)
private _step = if (_text regexMatch "^[\x00-\x7F]*$") then {8000} else {2700};
private _ok = true;
private _at = 0;
private _len = count _text;

while {_ok && {_at < _len || {_at == 0}}} do {
    private _piece = _text select [_at, _step];
    // a piece never ends half way through a surrogate pair
    if (_at + _step < _len && {count _piece > 0}) then {
        private _last = (toArray _piece) select (count _piece - 1);
        if (_last >= 55296 && {_last <= 56319}) then { _piece = _piece select [0, count _piece - 1] };
    };
    private _reply = "alive_tools" callExtension ["write", [_path, _mode, _piece]];
    private _answer = _reply param [0, ""];
    if (_answer != "ok") then {
        _ok = false;
        ["[ALiVE tools] Could not write %1: %2", _path, if (_answer == "") then {"the alive_tools extension is not loaded"} else {_answer}] call ALiVE_fnc_dump;
    };
    _mode = "add";
    _at = _at + ((count _piece) max 1);
};

_ok
