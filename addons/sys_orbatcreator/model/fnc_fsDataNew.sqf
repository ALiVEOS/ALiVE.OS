#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataNew);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataNew

Description:
Makes a new studio faction with the schema defaults and the five default editor
categories (Infantry, Special Forces, Support, Vehicles, Aircraft).

The faction is built as a short plain form and read through
ALiVE_fnc_fsDataFromPlain, so it holds nothing its own reload would refuse:
    - the name is cut to 60 characters, control characters turned into spaces,
      and left empty if it still fails the text60 rule;
    - the tag is upper-cased and left empty when it fails the tag rule (the
      studio asks for one before export);
    - class = tag, modName = "ALiVE_" + tag, author = the profile name when it
      passes text60, the flag is the side's stock flag.

Parameters:
    _name - STRING - display name
    _tag  - STRING - tag, 2 to 8 letters or digits
    _side - NUMBER - 0 east, 1 west, 2 independent, 3 civilian

Returns:
    HASHMAP - the faction

Examples:
    (begin example)
    missionNamespace setVariable ["ALiVE_FS_faction", ["Altis Militia", "AMIL", 2] call ALiVE_fnc_fsDataNew];
    (end)

See Also:
    ALiVE_fnc_fsDataFromPlain, ALiVE_fnc_fsDataSchema

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_name", "", [""]], ["_tag", "", [""]], ["_side", 1, [0]]];

private _clean60 = {
    // Cut by characters, not bytes, so a name in another alphabet is not split.
    private _t = toString (((toArray _this) apply { if (_x < 32) then { 32 } else { _x } }) select [0, 60]);
    if (([_t, "text60"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") then { _t } else { "" }
};

_name = _name call _clean60;
_tag = toUpper _tag;
if !(([_tag, "tag"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") then { _tag = "" };
if (!(finite _side) || {!(_side in [0, 1, 2, 3])}) then { _side = 1 };

private _flag = [
    "\a3\Data_f\Flags\flag_CSAT_co.paa",
    "\a3\Data_f\Flags\flag_nato_co.paa",
    "\a3\Data_f\Flags\flag_AAF_co.paa",
    "\a3\Data_f\Flags\flag_white_co.paa"
] select _side;

private _now = systemTime select [0, 5];
private _version = (getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "versionStr")) call _clean60;

private _categories = [];
{
    _categories pushBack [["id", "c" + ((_forEachIndex + 1) toFixed 0)], ["name", _x]];
} forEach ["Infantry", "Special Forces", "Support", "Vehicles", "Aircraft"];

private _plain = [
    ["schema", FS_SCHEMA],
    ["id", "f" + (((100000 + floor (random 900000)) min 999999) toFixed 0)],
    ["name", _name],
    ["tag", _tag],
    ["class", _tag],
    ["side", _side],
    ["flag", _flag],
    ["author", profileName call _clean60],
    ["modName", "ALiVE_" + _tag],
    ["categories", _categories],
    ["meta", [
        ["counter", count _categories],
        ["created", _now],
        ["modified", +_now],
        ["aliveVersion", _version],
        ["source", "new"]
    ]]
];

private _result = [_plain] call ALiVE_fnc_fsDataFromPlain;
if (_result select 0) exitWith { _result select 1 };

// Should never happen: every value above passed its rule. Fall back to the bare
// defaults so the caller always gets a faction.
diag_log format ["ALiVE_fnc_fsDataNew - refused its own new faction: %1", _result select 2];
([[["categories", _categories], ["meta", [["counter", count _categories]]]]] call ALiVE_fnc_fsDataFromPlain) select 1
