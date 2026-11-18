#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioTabExport);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioTabExport

Description:
The Export tab.

    - "refresh": the mod folder and its full path, the two options, the last
      results (errors red, warnings amber, written files green) and "Needs: ...";
      without the alive_tools extension, Export mod is off and the first result
      row says why and what to do;
    - "norandom", "force": the faction's options (stop random headgear, always
      apply the loadout);
    - "check": the export plan on a snapshot, in the handler, nothing written;
    - "export": a snapshot written as a mod by ALiVE_fnc_fsExportMod (spawned);
    - "copy": the same, config.cpp to the clipboard only;
    - "copyPath": the mod folder's full path to the clipboard (script cannot
      open Explorer);
    - "advanced": not in this build.
While an export is being written, check, export, copy and advanced answer
S_BUSY_EXPORT and do nothing; ordinary edits stay allowed, since the writer
only reads its snapshot.

Parameters:
    _op   - STRING - the event
    _args - ARRAY - the event arguments

Returns:
    Nothing

Examples:
    (begin example)
    ["check", []] call ALiVE_fnc_fsStudioTabExport;
    (end)

See Also:
    ALiVE_fnc_fsExportMod, ALiVE_fnc_fsGenPlan

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

disableSerialization;

params [["_op", "", [""]], ["_args", []]];

private _session = missionNamespace getVariable "ALiVE_FS_session";
if (isNil "_session") exitWith {};
private _display = _session getOrDefault ["display", displayNull];
private _faction = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
private _ctrl = { _display displayCtrl _this };

// the width a line of text takes on screen, measured on a hidden text control in the given font and
// size (ctrlTextWidth), so long lines can be wrapped or shortened to fit their box
private _measure = {
    params ["_text", "_font", "_size"];
    private _probe = _display getVariable ["ALiVE_FS_measure", controlNull];
    if (isNull _probe) then {
        _probe = _display ctrlCreate ["RscText", -1];
        _probe ctrlSetPosition [-10, -10, 10, 0.1];
        _probe ctrlShow false;
        _probe ctrlCommit 0;
        _display setVariable ["ALiVE_FS_measure", _probe];
    };
    _probe ctrlSetFont _font;
    _probe ctrlSetFontHeight _size;
    _probe ctrlSetText _text;
    ctrlTextWidth _probe
};
private _busy = _session getOrDefault ["exportBusy", false];

// why the extension is missing: 403 is the game saying BattlEye blocked it, 404 that its files aren't in the mod
// folder, and any other code gets the general advice
private _toolsText = {
    private _code = _session getOrDefault ["toolsError", 0];
    if (_code == 403) exitWith { localize "STR_ALIVE_FS_EX_TOOLS_BE" };
    if (_code == 404) exitWith { localize "STR_ALIVE_FS_EX_TOOLS_MISSING" };
    format [localize "STR_ALIVE_FS_EX_TOOLS_OTHER", _code toFixed 0]
};

// a copy of the faction no edit can reach, through the same round trip the profile uses
private _snapshot = {
    ([[_faction] call ALiVE_fnc_fsDataToPlain] call ALiVE_fnc_fsDataFromPlain) params ["_ok", "_copy"];
    if (_ok) then { _copy } else { createHashMap }
};
private _fullPath = {
    (call ALiVE_fnc_fsExportToolsInfo) params ["_loaded", "", "_root"];
    private _mod = _faction getOrDefault ["modName", ""];
    if (_mod isEqualTo "") exitWith { "" };
    if (!_loaded || {_root isEqualTo ""}) exitWith { "Documents\Arma 3\ALiVE\orbat\" + _mod };
    _root + "\orbat\" + _mod
};

switch (_op) do {
    case "refresh": {
        if (isNull _display) exitWith {};
        private _path = call _fullPath;
        // both rows at the panel's text size; a path too long for the box is cut from the left
        // ("...\Arma 3\ALiVE\orbat\ALiVE_X"), the whole one is in the tooltip and Copy path
        private _pathCtrl = FS_IDC_E_PATH call _ctrl;
        private _shown = _path;
        private _room = ((ctrlPosition _pathCtrl) select 2) * 0.94;
        private _textSize = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85;
        while { count _shown > 8 && {([_shown, "RobotoCondensed", _textSize] call _measure) > _room} } do {
            private _cut = (_shown select [4]) find "\";
            _shown = "..." + (if (_cut < 0) then { _shown select [4] } else { _shown select [4 + _cut] });
        };
        private _safe = { ((_this regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"] };
        _pathCtrl ctrlSetStructuredText parseText (if (_path isEqualTo "") then { localize "STR_ALIVE_FS_EX_PATH_NONE" } else {
            format ["%1<br/><t color='#B0B0B0'>%2</t>", (_faction getOrDefault ["modName", ""]) call _safe, _shown call _safe]
        });
        _pathCtrl ctrlSetTooltip _path;
        private _options = _faction getOrDefault ["options", createHashMap];
        (FS_IDC_E_NORANDOM call _ctrl) cbSetChecked (_options getOrDefault ["noRandom", true]);
        (FS_IDC_E_FORCE call _ctrl) cbSetChecked (_options getOrDefault ["force", false]);
        private _toolsOk = _session getOrDefault ["toolsOk", true];
        (FS_IDC_E_EXPORT call _ctrl) ctrlEnable _toolsOk;

        // one structured-text row per message in the results box: every row starts at the same margin, a file
        // name (third item 1) at one fixed indent, and a long message wraps inside its own row, under its first line
        private _box = FS_IDC_E_RESULTS call _ctrl;
        { ctrlDelete _x } forEach (_box getVariable ["ALiVE_FS_rows", []]);
        private _made = [];
        private _gw = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 40);
        private _gh = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
        // room for the scrollbar on the right
        private _width = ((ctrlPosition _box) select 2) - _gw * 1.1;
        private _y = _gh * 0.15;
        {
            _x params ["_level", "_text", ["_indent", 0]];
            private _colour = ["#93C47D", "#E5B422", "#E06666"] select ((_level max 0) min 2);
            private _x0 = _gw * (0.4 + 1.2 * ((_indent max 0) min 3));
            private _row = (ctrlParent _box) ctrlCreate ["ALiVE_FS_RscStructuredText", -1, _box];
            _row ctrlSetPosition [_x0, _y, _width - _x0, _gh];
            _row ctrlCommit 0;
            _row ctrlSetStructuredText parseText format ["<t color='%1'>%2</t>", _colour, (_text regexReplace ["^ +", ""]) call _safe];
            _row ctrlSetTooltip _text;
            private _h = ctrlTextHeight _row;
            _row ctrlSetPosition [_x0, _y, _width - _x0, _h];
            _row ctrlCommit 0;
            _y = _y + _h;
            _made pushBack _row;
        } forEach ((if (_toolsOk) then { [] } else { [[2, call _toolsText]] }) + (_session getOrDefault ["exportResults", []]));
        _box setVariable ["ALiVE_FS_rows", _made];

        private _plan = _session getOrDefault ["exportPlan", createHashMap];
        private _mods = ((_plan getOrDefault ["deps", createHashMap]) getOrDefault ["mods", []]) select { !(_x select 2) } apply { _x select 0 };
        (FS_IDC_E_DEPS call _ctrl) ctrlSetStructuredText parseText (format [localize "STR_ALIVE_FS_EX_DEPS", (["CBA_A3"] + _mods) joinString ", "]);
        (FS_IDC_E_ADVANCED call _ctrl) ctrlEnable false;
    };

    case "norandom";
    case "force": {
        _args params [["_c", controlNull], ["_state", 0]];
        private _options = _faction getOrDefault ["options", createHashMap];
        _options set [["noRandom", "force"] select (_op == "force"), _state isEqualTo 1 || {_state isEqualTo true}];
        _faction set ["options", _options];
        ["export option", false] call ALiVE_fnc_fsDataTouch;
        [-1] call ALiVE_fnc_fsStudioStatus;
    };

    case "check": {
        if (_busy) exitWith { [1, "S_BUSY_EXPORT"] call ALiVE_fnc_fsStudioStatus };
        private _copy = call _snapshot;
        private _plan = [_copy] call ALiVE_fnc_fsGenPlan;
        private _results = [];
        { _results pushBack [2, format ([localize ("STR_ALIVE_FS_" + (_x select 0))] + (_x select 1))] } forEach (_plan get "errors");
        { _results pushBack [1, format ([localize ("STR_ALIVE_FS_" + (_x select 0))] + (_x select 1))] } forEach (_plan get "warnings");
        _session set ["exportResults", _results];
        _session set ["exportPlan", _plan];
        ["refresh", []] call ALiVE_fnc_fsStudioTabExport;
        if (count (_plan get "errors") > 0) then {
            [2, "S_EXPORT_BLOCKED", [(count (_plan get "errors")) toFixed 0]] call ALiVE_fnc_fsStudioStatus;
        } else {
            private _groups = 0;
            { _groups = _groups + count _y } forEach (_plan get "groups");
            [0, "S_CHECK_OK", [(count (_plan get "men")) toFixed 0, (count (_plan get "vehicles")) toFixed 0, _groups toFixed 0, (count (_plan get "warnings")) toFixed 0]] call ALiVE_fnc_fsStudioStatus;
        };
    };

    case "export";
    case "copy": {
        if (_busy) exitWith { [1, "S_BUSY_EXPORT"] call ALiVE_fnc_fsStudioStatus };
        ["export", true] call ALiVE_fnc_fsDataTouch;
        private _copy = call _snapshot;
        if (count _copy == 0) exitWith { [2, "S_EXPORT_BLOCKED", ["1"]] call ALiVE_fnc_fsStudioStatus };
        private _tools = call ALiVE_fnc_fsExportToolsInfo;
        if (_op == "export" && {!(_tools select 0)}) exitWith {
            _session set ["toolsOk", false];
            _session set ["toolsError", _tools select 3];
            ["refresh", []] call ALiVE_fnc_fsStudioTabExport;
            [2, "S_EXPORT_NOTOOLS"] call ALiVE_fnc_fsStudioStatus;
        };
        _session set ["exportBusy", true];
        _session set ["exportAbort", false];
        _session set ["exportResults", []];
        [_copy, ["mod", "clipboard"] select (_op == "copy")] spawn ALiVE_fnc_fsExportMod;
    };

    case "copyPath": {
        private _path = _session getOrDefault ["exportPath", call _fullPath];
        if (_path isEqualTo "") exitWith { [1, "EX_PATH_NONE"] call ALiVE_fnc_fsStudioStatus };
        copyToClipboard _path;
        [0, "S_PATH_COPIED"] call ALiVE_fnc_fsStudioStatus;
    };

    case "advanced": {
        if (_busy) exitWith { [1, "S_BUSY_EXPORT"] call ALiVE_fnc_fsStudioStatus };
    };
};
