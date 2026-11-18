#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsGenRebuildBat);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsGenRebuildBat

Description:
The rebuild file: packs the faction with Arma 3 Tools' Addon Builder into an
@ folder beside it (the extension cannot make an @ folder itself) and copies
mod.cpp, the README and the data file in. Each optional part is packed too,
after every optional .pbo of the tag is deleted from the @ folder, and an
optional part's source folder from an earlier export is deleted (the
extension cannot delete files). Only the tag (letters and digits) and
the mod folder name (letters, digits, _) are put in; no free text ever reaches
the file.

Parameters:
    _plan    - HASHMAP - from ALiVE_fnc_fsGenPlan
    _faction - HASHMAP - the snapshot

Returns:
    ARRAY - lines

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_plan", createHashMap, [createHashMap]], ["_faction", createHashMap, [createHashMap]]];

private _tag = _plan get "tag";
private _lower = _plan get "tagLower";
private _mod = _faction getOrDefault ["modName", "ALiVE_" + _tag];
// both were checked by their rules; this is the last guard before a .bat. No format below: it would
// read the bat's own % signs
private _opt = (_plan getOrDefault ["optional", []]) apply { _x select 9 };
if !(_tag regexMatch "^[A-Z][A-Z0-9]{1,7}$" && {_mod regexMatch "^[A-Za-z0-9_]{3,40}$"} && {(_opt findIf { !(_x regexMatch ("^alive_fs_" + _lower + "_o_[0-9a-f]{6}$")) }) < 0}) exitWith { ["@echo off", "echo The faction tag or mod folder name is not valid. Export again.", "pause"] };

private _pack = {
    params ["_folder"];
    [
        """%TOOLS%\AddonBuilder\AddonBuilder.exe"" ""%HERE%source\" + _folder + """ ""%OUT%\addons"" -packonly -clear -prefix=alive_fs\" + (_folder select [9]),
        "if errorlevel 1 (",
        "  echo Packing failed. Read the lines above.",
        "  pause",
        "  exit /b 1",
        ")"
    ]
};
private _lines = [
    "@echo off",
    "setlocal",
    "rem Packs this faction into @" + _mod + " beside this file. Needs Arma 3 Tools (free on Steam), with Steam running.",
    "set ""HERE=%~dp0""",
    "set ""OUT=%HERE%@" + _mod + """",
    "set ""TOOLS=""",
    "rem the value line of reg query is: path  REG_SZ  <folder>; no find, which Git's own find can shadow on the PATH",
    "for /f ""skip=2 tokens=2,*"" %%A in ('reg query ""HKCU\Software\Bohemia Interactive\Arma 3 Tools"" /v path 2^>nul') do set ""TOOLS=%%B""",
    "if not exist ""%TOOLS%\AddonBuilder\AddonBuilder.exe"" (",
    "  echo Arma 3 Tools was not found. Install it from Steam, start it once, then run this file again.",
    "  pause",
    "  exit /b 1",
    ")",
    "if not exist ""%OUT%\addons"" mkdir ""%OUT%\addons""",
    "rem optional parts: the packed ones are made again below, and a source folder from an earlier export goes",
    "del /q ""%OUT%\addons\alive_fs_" + _lower + "_o_*.pbo"" 2>nul",
    "for /d %%D in (""%HERE%source\alive_fs_" + _lower + "_o_*"") do ("
];
_lines append (["  set ""KEEP="""] + (_opt apply { "  if /i ""%%~nxD""==""" + _x + """ set ""KEEP=1""" }) + ["  if not defined KEEP rd /s /q ""%%D""", ")"]);
_lines append ([_plan get "pbo"] call _pack);
{ _lines append ([_x] call _pack) } forEach _opt;
_lines append [
    "copy /y ""%HERE%mod.cpp"" ""%OUT%\mod.cpp"" >nul",
    "copy /y ""%HERE%README.txt"" ""%OUT%\README.txt"" >nul",
    "copy /y ""%HERE%" + _tag + ".alivefaction.txt"" ""%OUT%\" + _tag + ".alivefaction.txt"" >nul",
    "echo Done: %OUT%",
    "pause"
];
_lines
