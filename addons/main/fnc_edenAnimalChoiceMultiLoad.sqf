#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenAnimalChoiceMultiLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenAnimalChoiceMultiLoad

Description:
Eden-attribute `attributeLoad` handler for the ALiVE_AnimalChoiceMulti
control family. Multi-select listbox populated from the
CfgALiVEAmbientAnimals registry, filtered by category (poultry or
herd) and by loaded mods (via each registry entry's cfgPatchesName).

Mirrors fnc_edenItemChoiceMultiLoad - same parse / unrecognised-at-top
/ alphabetical-by-mod ordering pattern. Differences:
  - Reads CfgALiVEAmbientAnimals (animals) instead of
    CfgALiVEHumanitarianItems (water / ration items).
  - Accepts a 4th _initialDefault array (faction-choice-style) so the
    control class can pre-tick a vanilla default pool on fresh
    placement. Mirrors the BLU_F default pattern used by mil_opcom's
    factions multi-select.
  - Accepts a 5th _value (engine-auto-populated SQM value) so persisted
    selections are highlighted on Eden re-open regardless of which
    logic var name the consuming attribute uses (matches the same
    fix landed for FactionChoiceMulti in commit 4d9d7e14).

Backward-compatible stored-value parsing -- accepts:
  - Empty string / nil           -> seed from _initialDefault if any
  - Empty array literal "[]"     -> seed from _initialDefault if any
  - SQF array literal            -> parseSimpleArray to list
  - CSV "a,b,c"                  -> split on comma
  - Single classname "a"         -> treated as [a]

Unrecognised classnames (stored but not currently in the registry --
typical when a mission was built with a mod loaded that's now absent)
appear at the TOP of the list labelled "(unrecognised)" so the
mission-maker sees the value wasn't lost.

Parameters:
    [_display, _category, _varName, _initialDefault, _sqmValue]
    _display        : DISPLAY - Eden attribute display. ListBox at IDC 100.
    _category       : STRING  - "poultry" or "herd". Selects which
                                sub-class of each registry entry to
                                enumerate.
    _varName        : STRING  - logic variable name storing the value.
    _initialDefault : ARRAY of STRINGs - classnames to pre-tick when
                                no value is stored. Defaults to [].
    _sqmValue       : STRING  - SQM-serialised attribute value passed in
                                from attributeLoad's auto-populated
                                `_value` magic. Highest-priority source.

Author:
Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _category = "poultry";
private _varName = "customPoultryClasses";
private _initialDefault = [];
private _sqmValue = "";
if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then {
        _category = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"} && {(_this select 2) != ""}) then {
        _varName = _this select 2;
    };
    if (count _this > 3 && {typeName (_this select 3) == "ARRAY"}) then {
        _initialDefault = _this select 3;
    };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then {
        _sqmValue = _this select 4;
    };
} else {
    _display = _this;
};

// ---- 1. Resolve the currently-stored value --------------------------
// Priority: SQM `_value` > logic variable > display.value > "".
private _selected = get3DENSelected "logic";
private _storedFromLogic = if (count _selected > 0) then {
    (_selected select 0) getVariable [_varName, nil]
} else {
    nil
};
private _edenValue = _display getVariable "value";

private _value = "";
if (!isNil "_edenValue" && {typeName _edenValue == "STRING"} && {_edenValue != ""}) then {
    _value = _edenValue;
};
if (!isNil "_storedFromLogic" && {typeName _storedFromLogic == "STRING"} && {_storedFromLogic != ""}) then {
    _value = _storedFromLogic;
};
if (_sqmValue != "") then {
    _value = _sqmValue;  // SQM-supplied value wins over both
};

private _len = count _value;
if (
    _len >= 2 &&
    {(_value select [0, 1]) == "'"} &&
    {(_value select [_len - 1, 1]) == "'"}
) then {
    _value = _value select [1, _len - 2];
};

// ---- 2. Parse stored value into an array of classnames -------------
private _selectedItems = [];
if (_value != "") then {
    private _trimmed = _value;
    while {count _trimmed > 0 && {(_trimmed select [0, 1]) == " "}} do {
        _trimmed = _trimmed select [1];
    };
    while {count _trimmed > 0 && {(_trimmed select [count _trimmed - 1, 1]) == " "}} do {
        _trimmed = _trimmed select [0, count _trimmed - 1];
    };
    if (count _trimmed > 0 && {(_trimmed select [0, 1]) == "["}) then {
        private _parsed = parseSimpleArray _trimmed;
        if (typeName _parsed == "ARRAY") then {
            { if (typeName _x == "STRING") then { _selectedItems pushBack _x } } forEach _parsed;
        };
    } else {
        private _parts = [_trimmed, ","] call CBA_fnc_split;
        {
            private _p = _x;
            while {count _p > 0 && {(_p select [0, 1]) == " "}} do { _p = _p select [1] };
            while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
            if (_p != "") then { _selectedItems pushBack _p };
        } forEach _parts;
    };
};

// Initial-default fallback. Triggers when parse yielded nothing AND the
// caller passed a non-empty _initialDefault. Mirrors the FactionChoice
// BLU_F-default pattern - on fresh placement the listbox shows the
// vanilla pool pre-ticked rather than blank.
if (count _selectedItems == 0 && {count _initialDefault > 0}) then {
    {
        if (typeName _x == "STRING" && {_x != ""}) then {
            _selectedItems pushBack _x;
        };
    } forEach _initialDefault;
};

// ---- 3. Locate the ListBox control (IDC 100) -----------------------
private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {
    diag_log "ALIVE AnimalChoiceMulti LOAD: listbox control (IDC 100) not found";
};

lbClear _ctrl;

// ---- 4. Enumerate animals from the registry ------------------------
// For each subclass of CfgALiVEAmbientAnimals whose cfgPatchesName is
// loaded, collect entries from the given category (poultry / herd).
// Shape: [classname, displayName, modLabel]
private _entries = [];
private _seen = createHashMap;
private _registry = configFile >> "CfgALiVEAmbientAnimals";
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _source = _registry select _i;
        if (isClass _source) then {
            private _cp = getText (_source >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                private _modLabel = getText (_source >> "displayName");
                if (_modLabel == "") then { _modLabel = configName _source };
                private _catClass = _source >> _category;
                if (isClass _catClass) then {
                    for "_j" from 0 to (count _catClass - 1) do {
                        private _animalEntry = _catClass select _j;
                        if (isClass _animalEntry) then {
                            private _cn = configName _animalEntry;
                            private _cnLower = toLower _cn;
                            if !(_cnLower in _seen) then {
                                _seen set [_cnLower, true];
                                private _dn = getText (_animalEntry >> "displayName");
                                if (_dn == "") then { _dn = _cn };
                                _entries pushBack [_cn, _dn, _modLabel];
                            };
                        };
                    };
                };
            };
        };
    };
};

// ---- 5. Pre-add unrecognised entries at top ------------------------
private _entriesLowerSet = createHashMap;
{ _entriesLowerSet set [toLower (_x select 0), true] } forEach _entries;

private _unrecognisedTickIdxs = [];
{
    private _selLower = toLower _x;
    if !(_selLower in _entriesLowerSet) then {
        private _idx = _ctrl lbAdd format ["(unrecognised) %1", _x];
        _ctrl lbSetData [_idx, _x];
        _unrecognisedTickIdxs pushBack _idx;
    };
} forEach _selectedItems;

// ---- 6. Populate listbox grouped by mod, alphabetical within each --
private _selectedLowerSet = createHashMap;
{ _selectedLowerSet set [toLower _x, true] } forEach _selectedItems;

private _modLabels = [];
{ if !((_x select 2) in _modLabels) then { _modLabels pushBack (_x select 2) } } forEach _entries;
_modLabels sort true;

private _tickIdxs = +_unrecognisedTickIdxs;
{
    private _modLabel = _x;
    private _bucket = _entries select { (_x select 2) == _modLabel };
    _bucket sort true;
    {
        _x params ["_cn", "_dn"];
        private _label = if (_dn == _cn) then {
            format ["%1 - %2", _modLabel, _dn]
        } else {
            format ["%1 - %2 (%3)", _modLabel, _dn, _cn]
        };
        private _idx = _ctrl lbAdd _label;
        _ctrl lbSetData [_idx, _cn];
        if ((toLower _cn) in _selectedLowerSet) then {
            _tickIdxs pushBack _idx;
        };
    } forEach _bucket;
} forEach _modLabels;

// ---- 7. Apply selection --------------------------------------------
{ _ctrl lbSetSelected [_x, true] } forEach _tickIdxs;

diag_log format [
    "ALIVE AnimalChoiceMulti LOAD: varName='%1' category='%2' sqm='%3' resolved='%4' parsed=%5 populated=%6 ticked=%7 (incl %8 unrecognised at top)",
    _varName, _category, _sqmValue, _value, _selectedItems,
    lbSize _ctrl, count _tickIdxs, count _unrecognisedTickIdxs
];
