#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsExportToolsInfo);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsExportToolsInfo

Description:
Asks the alive_tools extension whether it is loaded, its version and the ALiVE
folder it writes under (Documents\Arma 3\ALiVE). BattlEye blocks the extension,
so a server or client running BattlEye reads as not loaded. The game's error code
says why it is missing (since Arma 3 2.22): 400 failed to load, 403 blocked by
BattlEye, 404 not found, 412 blocked by script, 415 wrong architecture.

Parameters:
    None

Returns:
    ARRAY - [loaded BOOL, version STRING, root STRING, error code NUMBER]

Examples:
    (begin example)
    (call ALiVE_fnc_fsExportToolsInfo) params ["_loaded", "_version", "_root", "_error"];
    (end)

Author:
    Jman
---------------------------------------------------------------------------- */

("alive_tools" callExtension ["info", []]) params [["_reply", "", [""]], ["_return", 0], ["_error", 0, [0]]];
if !((_reply select [0, 1]) isEqualTo "[") exitWith { [false, "", "", _error] };
private _info = parseSimpleArray _reply;
_info params [["_version", "", [""]], ["_root", "", [""]], ["_exists", false, [false]]];
[!(_version isEqualTo ""), _version, _root, _error]
