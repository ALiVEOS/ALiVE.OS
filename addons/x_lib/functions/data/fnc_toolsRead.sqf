#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(toolsRead);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_toolsRead

Description:
Reads a whole file from the ALiVE folder in the player's Documents (Arma 3\ALiVE), through the alive_tools
extension; the game itself can't read that folder. The extension hands the file back in pieces of up to
4 KB, which are joined here.

Parameters:
String - the path under the ALiVE folder
Bool - optional, true to take out the comments (block comments and // lines), so the text can be run with
compile, which doesn't skip them as preprocessFile did (default false)

Returns:
String - the text, or nil when the file is missing or can't be read

Examples:
(begin example)
private _text = ["indexing/stratis/x/alive/addons/fnc_strategic/indexes/objects.stratis.sqf"] call ALiVE_fnc_toolsRead;
if (!isNil "_text") then { call compile _text };
(end)

See Also:
ALiVE_fnc_toolsWrite

Author:
Jman
---------------------------------------------------------------------------- */

params [["_path", "", [""]], ["_noComments", false, [false]]];

private _exists = ("alive_tools" callExtension ["exists", [_path]]) param [0, ""];
if (_exists != "true") exitWith { nil };

private _pieces = [];
private _offset = 0;
private _failed = false;
while {_offset >= 0} do {
    // the offset goes as whole digits: past 999999 a plain number is sent as "1.00762e+06" (six figures), which
    // lands a few bytes off and drops them (Altis civilian clusters, 2.3 MB, NUC 16 Nov)
    private _reply = ("alive_tools" callExtension ["read", [_path, _offset toFixed 0]]) param [0, ""];
    private _parsed = if (_reply select [0, 1] == "[") then { parseSimpleArray _reply } else { [] };
    if (count _parsed != 2) exitWith {
        _failed = true;
        ["[ALiVE tools] Could not read %1 at %2: %3", _path, _offset, _reply select [0, 200]] call ALiVE_fnc_dump;
    };
    _pieces pushBack (_parsed select 0);
    _offset = _parsed select 1;
};

if (_failed) exitWith { nil };
private _text = _pieces joinString "";
if (_noComments) then {
    private _at = _text find "/*";
    while {_at >= 0} do {
        private _end = (_text select [_at + 2]) find "*/";
        if (_end < 0) exitWith { _text = _text select [0, _at] };
        _text = (_text select [0, _at]) + (_text select [_at + _end + 4]);
        _at = _text find "/*";
    };
    _text = ((_text splitString toString [13, 10]) select { (trim _x) select [0, 2] != "//" }) joinString endl;
};
_text
