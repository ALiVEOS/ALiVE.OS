#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataFileRead);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataFileRead

Description:
Reads a faction data file, Documents\Arma 3\ALiVE\orbat\import\<name>.alivefaction.txt,
through the alive_tools extension (ALiVE_fnc_toolsRead), then ALiVE_fnc_fsDataParse.
The file holds the share text on one line; its line end is trimmed by the parse.

Parameters:
    _name - STRING - the file name without .alivefaction.txt: letters, digits,
            space, _ and - only

Returns:
    ARRAY - as ALiVE_fnc_fsDataParse; [false, createHashMap, [["S_FILE_MISSING", name]], []]
            when the name is not usable, the file is missing or the extension is
            not loaded

Examples:
    (begin example)
    (["AMIL"] call ALiVE_fnc_fsDataFileRead) params ["_ok", "_faction", "_problems", "_notes"];
    (end)

See Also:
    ALiVE_fnc_fsDataFileWrite, ALiVE_fnc_toolsRead, ALiVE_fnc_fsDataParse

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_name", "", [""]]];

private _missing = [false, createHashMap, [["S_FILE_MISSING", _name + ".alivefaction.txt"]], []];

private _usable = !(_name isEqualTo "") && {(count _name) <= 60} && {
    ((toArray _name) findIf { !((_x >= 48 && {_x <= 57}) || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}} || {_x in [32, 45, 95]}) }) < 0
};
if (!_usable) exitWith { _missing };

private _text = ["orbat/import/" + _name + ".alivefaction.txt"] call ALiVE_fnc_toolsRead;
if (isNil "_text") exitWith { _missing };

[_text] call ALiVE_fnc_fsDataParse
