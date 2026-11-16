#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataFileWrite);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataFileWrite

Description:
Writes a faction data file: the share text (ALiVE_fnc_fsDataToText) plus a line
end, through the alive_tools extension (ALiVE_fnc_toolsWrite), which only writes
under Documents\Arma 3\ALiVE\indexing or orbat, and on a dedicated server only
when that folder holds allow_server.txt. The file is emptied first.

Parameters:
    _faction - HASHMAP - the faction
    _path    - STRING - path under the ALiVE folder, e.g. "orbat/ALiVE_AMIL/AMIL.alivefaction.txt"

Returns:
    BOOL - true when every piece was written

Examples:
    (begin example)
    [_faction, "orbat/import/AMIL.alivefaction.txt"] call ALiVE_fnc_fsDataFileWrite;
    (end)

See Also:
    ALiVE_fnc_fsDataFileRead, ALiVE_fnc_toolsWrite, ALiVE_fnc_fsDataToText

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]], ["_path", "", [""]]];

if (_path isEqualTo "" || {(_path find "..") >= 0}) exitWith { false };

[_path, "new", ([_faction] call ALiVE_fnc_fsDataToText) + endl] call ALiVE_fnc_toolsWrite
