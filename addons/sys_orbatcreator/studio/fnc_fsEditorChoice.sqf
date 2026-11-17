#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsEditorChoice);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsEditorChoice

Description:
Says which editor an ORBAT Creator module opens. The one place the module's
Editor attribute (studio) is resolved:
    - "studio" or "classic" on the logic: that value;
    - "auto", no value at all, or anything else: FS_DEFAULT_EDITOR.

Only reads a variable, so it runs anywhere (no interface needed).

Parameters:
    _logic - OBJECT - the module logic (objNull or nil is fine)

Returns:
    STRING - "studio" or "classic"

Examples:
    (begin example)
    if (([MOD(orbatCreator)] call ALiVE_fnc_fsEditorChoice) == "studio") then { [] call ALiVE_fnc_fsStudioReopen };
    (end)

See Also:
    ALiVE_fnc_fsStudioStart, ALiVE_fnc_orbatCreator

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_logic", objNull]];

private _value = "";
if (_logic isEqualType objNull && {!isNull _logic}) then {
    _value = _logic getVariable ["studio", ""];
};

if (_value isEqualType "" && {(toLower _value) in ["studio", "classic"]}) exitWith { toLower _value };

FS_DEFAULT_EDITOR
