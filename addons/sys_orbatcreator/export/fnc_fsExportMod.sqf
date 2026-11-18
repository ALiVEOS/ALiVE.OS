#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsExportMod);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsExportMod

Description:
Writes a faction mod, or copies its config to the clipboard. Spawned by the
Export tab with a snapshot of the faction (its own copy, which no edit can
reach), after the tab set the session's exportBusy:
    1. plan; any error lists the problems and stops (S_EXPORT_BLOCKED);
    2. every text is built and each config.cpp is checked (E_CONFIG);
    3. "clipboard": config.cpp to the clipboard (S_EXPORT_COPIED), done;
    4. "mod": every file written in order, each emptied first, stopping at
       the first failure (S_EXPORT_FAIL), or between files when the studio was
       closed (S_EXPORT_ABORTED);
    5. each config.cpp read back and its length compared, line ends left out
       (S_EXPORT_VERIFY when it differs, else S_EXPORT_DONE).
exportBusy is cleared on every way out. Results go to the session's
exportResults as [level, text] and the Export tab is redrawn.

Files, under Documents\Arma 3\ALiVE\orbat\<mod folder>\:
    source\alive_fs_<tag>\config.cpp, functions\fn_applyLoadout.sqf,
    PboPrefix.txt; for each optional part source\alive_fs_<tag>_o_<hash>\config.cpp
    and PboPrefix.txt; mod.cpp; README.txt; rebuild.bat.txt; <TAG>.alivefaction.txt
The extension cannot delete, so an optional part's folder left from an earlier
export stays until rebuild.bat removes it; rebuild.bat packs only the current ones.

Parameters:
    _faction - HASHMAP - the snapshot
    _mode    - STRING - "mod" or "clipboard"

Returns:
    BOOL - true when it finished

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_faction", createHashMap, [createHashMap]], ["_mode", "mod", [""]]];

private _session = missionNamespace getVariable ["ALiVE_FS_session", createHashMap];
private _results = [];
private _say = {
    params ["_level", "_key", ["_args", []]];
    _results pushBack [_level, format ([localize ("STR_ALIVE_FS_" + _key)] + _args)];
};
private _finish = {
    params ["_level", "_key", ["_args", []]];
    _session set ["exportResults", _results];
    _session set ["exportBusy", false];
    [_level, _key, _args] call ALiVE_fnc_fsStudioStatus;
    if (!isNil "ALiVE_fnc_fsStudioTabExport") then { ["refresh", []] call ALiVE_fnc_fsStudioTabExport };
};

private _plan = [_faction] call ALiVE_fnc_fsGenPlan;
_session set ["exportPlan", _plan];
{ ([2] + _x) call _say } forEach (_plan get "errors");
{ ([1] + _x) call _say } forEach (_plan get "warnings");
if (count (_plan get "errors") > 0) exitWith {
    [2, "S_EXPORT_BLOCKED", [(count (_plan get "errors")) toFixed 0]] call _finish;
    false
};

private _lf = toString [10];
private _config = [_plan, _faction] call ALiVE_fnc_fsGenConfig;
([_config] call ALiVE_fnc_fsGenCheck) params ["_ok", "_line"];
if (!_ok) exitWith {
    ["ORBAT Creator studio: generated config failed its check at line %1: %2", _line, _config param [_line - 1, ""]] call ALiVE_fnc_dump;
    [2, "E_CONFIG", [_line toFixed 0]] call _say;
    [2, "E_CONFIG", [_line toFixed 0]] call _finish;
    false
};
private _configText = (_config joinString _lf) + _lf;
// the optional parts: [folder, text] each, checked like the main one
private _optTexts = [];
private _optBad = -1;
{
    private _lines = [_plan, _faction, _x] call ALiVE_fnc_fsGenConfig;
    ([_lines] call ALiVE_fnc_fsGenCheck) params ["_okO", "_lineO"];
    if (!_okO) exitWith {
        ["ORBAT Creator studio: generated config of %1 failed its check at line %2: %3", _x select 0, _lineO, _lines param [_lineO - 1, ""]] call ALiVE_fnc_dump;
        _optBad = _lineO;
    };
    _optTexts pushBack [_x select 9, _x select 10, (_lines joinString _lf) + _lf];
} forEach (_plan getOrDefault ["optional", []]);
if (_optBad >= 0) exitWith {
    [2, "E_CONFIG", [_optBad toFixed 0]] call _say;
    [2, "E_CONFIG", [_optBad toFixed 0]] call _finish;
    false
};

if (_mode == "clipboard") exitWith {
    copyToClipboard _configText;
    [0, "S_EXPORT_COPIED", [(count _configText) toFixed 0]] call _finish;
    true
};

private _root = _plan get "root";
private _src = _root + "source/" + (_plan get "pbo") + "/";
private _tag = _plan get "tag";
private _runtime = loadFile "\x\alive\addons\sys_orbatcreator\rt\fn_applyLoadout.sqf";
private _files = [
    [_src + "config.cpp", _configText],
    [_src + "functions/fn_applyLoadout.sqf", _runtime],
    [_src + "PboPrefix.txt", (_plan get "prefix") + _lf]
];
{
    _x params ["_folder", "_prefix", "_text"];
    _files pushBack [_root + "source/" + _folder + "/config.cpp", _text];
    _files pushBack [_root + "source/" + _folder + "/PboPrefix.txt", _prefix + _lf];
} forEach _optTexts;
_files append [
    [_root + "mod.cpp", (([_plan, _faction] call ALiVE_fnc_fsGenModCpp) joinString _lf) + _lf],
    [_root + "README.txt", (([_plan, _faction, true] call ALiVE_fnc_fsGenReadme) joinString _lf) + _lf],
    [_root + "rebuild.bat.txt", (([_plan, _faction] call ALiVE_fnc_fsGenRebuildBat) joinString _lf) + _lf],
    [_root + _tag + ".alivefaction.txt", ([_faction] call ALiVE_fnc_fsDataToText) + _lf]
];
[0, "S_EXPORT_START", [(count _files) toFixed 0]] call ALiVE_fnc_fsStudioStatus;

private _stop = "";
private _stopArgs = [];
// the folder is in the Mod folder box above, so the files are listed from it
_results pushBack [0, localize "STR_ALIVE_FS_EX_FILES"];
{
    _x params ["_path", "_text"];
    if (_session getOrDefault ["exportAbort", false]) exitWith { _stop = "S_EXPORT_ABORTED" };
    if (_text isEqualTo "" || {!([_path, "new", _text] call ALiVE_fnc_toolsWrite)}) exitWith { _stop = "S_EXPORT_FAIL"; _stopArgs = [_path] };
    // the third item indents the row (a file name under its heading)
    _results pushBack [0, _path select [count _root], 1];
} forEach _files;
if !(_stop isEqualTo "") exitWith {
    [2, _stop, _stopArgs] call _finish;
    false
};
[1, "W_BAT_TXT"] call _say;

// the writer turns each line break into a Windows one: compare without carriage returns
private _noCr = { count ((_this splitString (toString [13])) joinString "") };
(call ALiVE_fnc_fsExportToolsInfo) params ["", "", "_base"];
private _full = _base + "\" + ((_root splitString "/") joinString "\");
_session set ["exportPath", _full];
private _bad = [];
{
    _x params ["_path", "_text"];
    private _back = [_path] call ALiVE_fnc_toolsRead;
    private _want = _text call _noCr;
    private _got = if (isNil "_back") then { 0 } else { _back call _noCr };
    if (_got != _want) exitWith { _bad = [_path, _got toFixed 0, _want toFixed 0] };
} forEach ([[_src + "config.cpp", _configText]] + (_optTexts apply { [_root + "source/" + (_x select 0) + "/config.cpp", _x select 2] }));
if (count _bad > 0) exitWith {
    [2, "S_EXPORT_VERIFY", _bad] call _finish;
    false
};
[0, "S_EXPORT_DONE", [_full]] call _finish;
true
