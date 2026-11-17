#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioStatus);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioStatus

Description:
The studio's status line (IDC 14005).
    - the text is format ([localize ("STR_ALIVE_FS_" + key)] + args);
    - shown in the level's colour: 0 green, 1 amber, 2 red;
    - kept in the session's log (last 50 lines), so a status set before the
      display exists is shown when it opens;
    - level 2 also goes to the RPT;
    - also refreshes the faction name and unsaved mark (IDC 14003), since every
      action ends with one status call.
A negative level repaints the last line and the faction name without logging
(used by ALiVE_fnc_fsStudioOpen). No systemChat, no hints.

Parameters:
    _level - NUMBER - 0 ok, 1 warning, 2 error; below 0 repaint only
    _key   - STRING - key after STR_ALIVE_FS_, e.g. "S_ESC"
    _args  - ARRAY - format arguments

Returns:
    STRING - the text shown

Examples:
    (begin example)
    [1, "S_BUSY_EXPORT", []] call ALiVE_fnc_fsStudioStatus;
    [0, "S_READY", [FS_NAME, "Altis Militia"]] call ALiVE_fnc_fsStudioStatus;
    (end)

See Also:
    ALiVE_fnc_fsStudioOpen

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith { "" };

disableSerialization;

params [["_level", 0, [0]], ["_key", "", [""]], ["_args", [], [[]]]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
private _log = if (isNil "_session") then { [] } else { _session getOrDefault ["log", []] };

private _text = "";
if (_level >= 0) then {
    _text = format ([localize ("STR_ALIVE_FS_" + _key)] + _args);
    _level = (_level min 2);
    _log pushBack [_level, _text];
    if ((count _log) > 50) then { _log deleteRange [0, (count _log) - 50] };
    if (!isNil "_session") then { _session set ["log", _log] };
    if (_level == 2) then { ["ORBAT Creator studio: %1", _text] call ALiVE_fnc_dump };
} else {
    if ((count _log) > 0) then {
        (_log select ((count _log) - 1)) params ["_l", "_t"];
        _level = _l;
        _text = _t;
    };
};

private _display = findDisplay FS_IDD_STUDIO;
if (!isNull _display) then {
    // structured text: escape the three characters it reads as markup
    private _safe = {
        ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"]
    };

    private _colour = ["#93C47D", "#E6B422", "#E06666"] select ((_level max 0) min 2);
    (_display displayCtrl FS_IDC_STATUS) ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", _colour, _text call _safe];

    private _faction = missionNamespace getVariable "ALiVE_FS_faction";
    private _name = "";
    if (!isNil "_faction" && {_faction isEqualType createHashMap}) then {
        _name = _faction getOrDefault ["name", ""];
        if (_name isEqualTo "") then { _name = _faction getOrDefault ["tag", ""] };
    };
    if (missionNamespace getVariable ["ALiVE_FS_dirty", false]) then { _name = _name + " *" };
    (_display displayCtrl FS_IDC_FACTION) ctrlSetText _name;
};

_text
