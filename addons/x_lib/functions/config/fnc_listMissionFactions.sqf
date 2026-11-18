#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(listMissionFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_listMissionFactions

Description:
The factions the running mission fields: those of its AI Commanders, Military Placement
and Military Placement (Custom) modules. Read-only.

Parameters:
None

Returns:
Array - faction class names, each once

Examples:
(begin example)
[] call ALiVE_fnc_listMissionFactions;
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

private _found = [];
private _add = {
    params ["_value"];
    private _names = if (_value isEqualType []) then { _value } else { (_value splitString "[]"", ") select { _x != "" } };
    {
        private _name = _x;
        if (_name isEqualType "" && {_name != ""} && {(toUpper _name) != "NONE"} && {((_found apply { toLower _x }) find (toLower _name)) == -1}) then {
            _found pushBack _name;
        };
    } forEach _names;
};

{
    if (_x isEqualType []) then { [[_x, "factions", []] call ALiVE_fnc_hashGet] call _add };
} forEach (missionNamespace getVariable ["OPCOM_instances", []]);

{
    [_x getVariable ["faction", ""]] call _add;
    [_x getVariable ["factions", ""]] call _add;
} forEach ((entities "ALiVE_mil_placement") + (entities "ALiVE_mil_placement_custom"));

_found
