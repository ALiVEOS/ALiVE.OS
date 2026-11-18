#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsDataCheckValue);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsDataCheckValue

Description:
Checks one value against one rule of the studio faction model. The same rules
apply to typed values, values read from config and values read from a stranger's
share text, so the model never holds a value its own reload would refuse.

Rules:
    class      - ^[A-Za-z][A-Za-z0-9_]{1,63}$
    gear       - ^[A-Za-z0-9_]{0,80}$ (may be empty)
    tag        - ^[A-Z][A-Z0-9]{1,7}$
    path       - at most 200 characters of letters, digits, space, _ - . \ /; no ..
    text60     - at most 60 characters (counted as characters, not bytes), none below code 32, and none of the
                 preprocessor words __eval, __exec, #include, #define
    id         - a letter then 1 to 6 digits ("u12", "c1", "f482913")
    ref        - a unit or vehicle id, or # and a gear-rule class
    rank       - PRIVATE, CORPORAL, SERGEANT, LIEUTENANT, CAPTAIN, MAJOR, COLONEL
    modName    - ^[A-Za-z0-9_]{3,40}$
    cfgPath    - at most 200 characters of letters, digits, _ and /
    date       - [] or five whole numbers 0..9999
    turretPath - at most four whole numbers 0..99
    pos        - [] or three finite numbers, none above 999999 either way
    loadout    - ALiVE_fnc_fsDataLoadoutCheck
    [min, max] - a finite number inside the range
    ""         - any string
A rule name ending in ? also accepts "".

Parameters:
    _value - ANY - the value
    _rule  - STRING or ARRAY - the rule

Returns:
    STRING - "" when the value passes, else the problem text key
             (S_NAME_BAD, S_TAG_BAD, S_TEXT_BAD or E_BAD_LOADOUT)

Examples:
    (begin example)
    ["B_Soldier_F", "class"] call ALiVE_fnc_fsDataCheckValue; // ""
    [5, [0, 3]] call ALiVE_fnc_fsDataCheckValue; // "S_TEXT_BAD"
    (end)

See Also:
    ALiVE_fnc_fsDataLoadoutCheck, ALiVE_fnc_fsDataFromPlain

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params ["_value", ["_rule", "", ["", []]]];

if (isNil "_value") exitWith { "S_TEXT_BAD" };

// Numbers: [min, max].
if (_rule isEqualType []) exitWith {
    _rule params [["_min", 0], ["_max", 999999]];
    if (_value isEqualType 0 && {finite _value} && {_value >= _min} && {_value <= _max} && {abs _value <= 999999}) then { "" } else { "S_TEXT_BAD" }
};

// A rule ending in ? also accepts the empty string.
private _name = _rule;
if ((count _name) > 1 && {(_name select [(count _name) - 1]) isEqualTo "?"}) then {
    _name = _name select [0, (count _name) - 1];
    if (_value isEqualTo "") then { _name = "" };
};

// Every character of _this is in the allowed codes (letters and digits always).
private _onlyCodes = {
    params ["_text", "_extra"];
    (toArray _text) findIf {
        !((_x >= 48 && {_x <= 57}) || {_x >= 65 && {_x <= 90}} || {_x >= 97 && {_x <= 122}} || {_x in _extra})
    } < 0
};

switch (_name) do {
    case "": {
        if (_value isEqualType "") then { "" } else { "S_TEXT_BAD" }
    };
    case "class": {
        if (_value isEqualType "" && {_value regexMatch "^[A-Za-z][A-Za-z0-9_]{1,63}$"}) then { "" } else { "S_NAME_BAD" }
    };
    case "gear": {
        // One engine regex, not a loop over the characters: an import checks every string of every loadout.
        if (_value isEqualType "" && {_value regexMatch "^[A-Za-z0-9_]{0,80}$"}) then { "" } else { "S_NAME_BAD" }
    };
    case "tag": {
        // The upper-case test does not lean on whether regexMatch is case-sensitive.
        if (_value isEqualType "" && {_value regexMatch "^[A-Z][A-Z0-9]{1,7}$"} && {_value isEqualTo (toUpper _value)}) then { "" } else { "S_TAG_BAD" }
    };
    case "path": {
        // Space, - . / \ and _ ; checked by character code because a / inside a
        // regex pattern is read as the start of its flags.
        if (_value isEqualType "" && {(count _value) <= 200} && {[_value, [32, 45, 46, 47, 92, 95]] call _onlyCodes} && {(_value find "..") < 0}) then { "" } else { "S_TEXT_BAD" }
    };
    case "text60": {
        private _ok = _value isEqualType "" && {(count (toArray _value)) <= 60} && {((toArray _value) findIf { _x < 32 }) < 0} && {
            private _lower = toLower _value;
            // The words are built from pieces so this file never holds them whole.
            ([toString [95, 95] + "eval", toString [95, 95] + "exec", toString [35] + "include", toString [35] + "define"] findIf { (_lower find _x) >= 0 }) < 0
        };
        if (_ok) then { "" } else { "S_TEXT_BAD" }
    };
    case "id": {
        if (_value isEqualType "" && {_value regexMatch "^[a-z][0-9]{1,6}$"}) then { "" } else { "S_NAME_BAD" }
    };
    case "ref": {
        if (_value isEqualType "" && {_value regexMatch "^([uv][0-9]{1,6}|#[A-Za-z0-9_]{1,80})$"}) then { "" } else { "S_NAME_BAD" }
    };
    case "rank": {
        if (_value isEqualType "" && {_value in ["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"]}) then { "" } else { "S_NAME_BAD" }
    };
    case "modName": {
        if (_value isEqualType "" && {_value regexMatch "^[A-Za-z0-9_]{3,40}$"}) then { "" } else { "S_NAME_BAD" }
    };
    case "cfgPath": {
        if (_value isEqualType "" && {(count _value) <= 200} && {[_value, [47, 95]] call _onlyCodes}) then { "" } else { "S_NAME_BAD" }
    };
    case "date": {
        private _ok = _value isEqualType [] && {
            (_value isEqualTo []) || {
                (count _value) == 5 && {(_value findIf { !(_x isEqualType 0) || {!(finite _x)} || {_x < 0} || {_x > 9999} || {_x != floor _x} }) < 0}
            }
        };
        if (_ok) then { "" } else { "S_TEXT_BAD" }
    };
    case "turretPath": {
        private _ok = _value isEqualType [] && {(count _value) <= 4} && {(_value findIf { !(_x isEqualType 0) || {!(finite _x)} || {_x < 0} || {_x > 99} || {_x != floor _x} }) < 0};
        if (_ok) then { "" } else { "S_TEXT_BAD" }
    };
    case "pos": {
        private _ok = _value isEqualType [] && {
            (_value isEqualTo []) || {
                (count _value) == 3 && {(_value findIf { !(_x isEqualType 0) || {!(finite _x)} || {abs _x > 999999} }) < 0}
            }
        };
        if (_ok) then { "" } else { "S_TEXT_BAD" }
    };
    case "role": {
        if (_value isEqualType "" && {_value in FS_ROLES}) then { "" } else { "S_NAME_BAD" }
    };
    case "aliveCat": {
        if (_value isEqualType "" && {_value in FS_ALIVE_CATEGORIES}) then { "" } else { "S_NAME_BAD" }
    };
    case "listName": {
        if (_value isEqualType "" && {_value in FS_ALIVE_LISTS}) then { "" } else { "S_NAME_BAD" }
    };
    case "poolWeapon": {
        // [] for an item that is not a weapon, else one weapon entry of a loadout, checked as a primary weapon
        if (_value isEqualTo [] || {_value isEqualType [] && {count _value == 7} && {([[_value, [], [], [], [], [], "", "", [], ["", "", "", "", "", ""]]] call ALiVE_fnc_fsDataLoadoutCheck) select 0}}) then { "" } else { "S_TEXT_BAD" }
    };
    case "loadout": {
        if (([_value] call ALiVE_fnc_fsDataLoadoutCheck) select 0) then { "" } else { "E_BAD_LOADOUT" }
    };
    default { "S_TEXT_BAD" };
}
