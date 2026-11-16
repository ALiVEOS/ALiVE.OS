#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsImportBase);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsImportBase

Description:
The real CfgVehicles class a class stands on, walking past exported and stub
classes:
    - exported: ALiVE_orbatCreator_owned 1 or ALiVE_FS_owned 1;
    - stub: ALiVE_FS_stub 1 (a studio stub; the exported vehicle sets it back to 0),
      or _OCimport_ in the class name (a classic stub).
The first class that is neither is the base. A class that is not owned is its own
base. No pattern match on the studio stub name: regexMatch has to match the whole
string, so a suffix pattern would never find it.

Parameters:
    _class - STRING - the class

Returns:
    ARRAY - [base, owned]; owned is "studio", "orbat" or "" for the class itself

Examples:
    (begin example)
    (["AMIL_Rifleman"] call ALiVE_fnc_fsImportBase) params ["_base", "_owned"];
    (end)

See Also:
    ALiVE_fnc_fsImportMan, ALiVE_fnc_fsImportVehicle

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_class", "", [""]]];

private _cfg = configFile >> "CfgVehicles" >> _class;
if !(isClass _cfg) exitWith { [_class, ""] };

private _owned = "";
if (getNumber (_cfg >> "ALiVE_FS_owned") == 1) then {
    _owned = "studio";
} else {
    if (getNumber (_cfg >> "ALiVE_orbatCreator_owned") == 1) then { _owned = "orbat" };
};

private _isStep = {
    params ["_c"];
    getNumber (_c >> "ALiVE_FS_owned") == 1 || {getNumber (_c >> "ALiVE_orbatCreator_owned") == 1}
        || {getNumber (_c >> "ALiVE_FS_stub") == 1} || {"_OCimport_" in (configName _c)}
};

private _current = _cfg;
private _guard = 0;
while { isClass _current && {[_current] call _isStep} && {_guard < 32} } do {
    _current = inheritsFrom _current;
    _guard = _guard + 1;
};

private _base = if (isClass _current) then { configName _current } else { _class };
[_base, _owned]
