#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAliveCheck);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAliveCheck

Description:
How each category ALiVE draws groups from stands for this faction:
    "ok"       - it has a group with at least one member
    "redirect" - empty, but drawn from another of the faction's categories that
                 has groups (alive.redirects)
    "fillable" - empty, and AUTO GROUPS would fill it from the faction's men or
                 vehicles
    "none"     - empty, and the faction has nothing to fill it with; normal for
                 a small faction, never a warning
Motorized counts as ok when Motorized_MTP has groups, since ALiVE falls back to
it. A civilian faction has no groups, so every category is "none".

Parameters:
    _faction - HASHMAP - the studio faction

Returns:
    ARRAY - [category, state, groups, redirectTo] for each of FS_ALIVE_DRAWN

Examples:
    (begin example)
    private _empty = ([_faction] call ALiVE_fnc_fsAliveCheck) select { (_x select 1) isEqualTo "fillable" };
    (end)

See Also:
    ALiVE_fnc_fsAutoGroups

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]]];

private _civ = (_faction getOrDefault ["side", 1]) == 3;
private _counts = createHashMap;
{
    if (count (_y getOrDefault ["members", []]) > 0) then {
        private _c = _y getOrDefault ["category", "Infantry"];
        _counts set [_c, (_counts getOrDefault [_c, 0]) + 1];
    };
} forEach (_faction getOrDefault ["groups", createHashMap]);

// what AUTO GROUPS could fill
private _fill = createHashMap;
if (!_civ) then {
    private _units = _faction getOrDefault ["units", createHashMap];
    if (count _units > 0) then { _fill set ["Infantry", true] };
    if ((values _units) findIf { _x getOrDefault ["specOps", false] } >= 0) then { _fill set ["SpecOps", true] };
    {
        private _kind = ([_y] call ALiVE_fnc_fsAutoKind) select 0;
        private _cat = switch (_kind) do {
            case "carrier_soft": { "Motorized" };
            case "carrier_armoured": { "Mechanized" };
            case "tank": { "Armored" };
            case "artillery": { "Artillery" };
            case "heli";
            case "plane": { "Air" };
            case "boat": { "Naval" };
            default { "" };
        };
        if !(_cat isEqualTo "") then { _fill set [_cat, true] };
    } forEach (_faction getOrDefault ["vehicles", createHashMap]);
};

private _redirects = createHashMap;
{ _redirects set [_x get "from", _x get "to"] } forEach ((_faction getOrDefault ["alive", createHashMap]) getOrDefault ["redirects", []]);

FS_ALIVE_DRAWN apply {
    private _cat = _x;
    private _n = _counts getOrDefault [_cat, 0];
    private _to = _redirects getOrDefault [_cat, ""];
    switch (true) do {
        case (_n > 0 || {_cat isEqualTo "Motorized" && {(_counts getOrDefault ["Motorized_MTP", 0]) > 0}}): { [_cat, "ok", _n, ""] };
        case (!(_to isEqualTo "") && {(_counts getOrDefault [_to, 0]) > 0}): { [_cat, "redirect", 0, _to] };
        case (_cat in _fill): { [_cat, "fillable", 0, ""] };
        default { [_cat, "none", 0, ""] };
    }
}
