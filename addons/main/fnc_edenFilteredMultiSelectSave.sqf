#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFilteredMultiSelectSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFilteredMultiSelectSave

Description:
    Eden attributeSave handler for ALiVE_FilteredMultiSelect_Base.
    Reads the cumulative selection set from the controlsGroup namespace
    (`alive_selectedClasses`), syncs with the currently-visible listbox
    state (so an in-flight click that LBSelChanged hasn't applied yet
    is captured), appends Override Edit free-text entries, then walks
    the registry to bucket each class into its category.

    Returns the consolidated structured-format string:
        cat1:Class1,Class2;cat2:Class3,Class4

    Eden writes that return value into the consolidated attribute's SQM
    slot. The runtime resolver reads the consolidated key first and
    only falls back to legacy per-category attrs when consolidated is
    empty (a mission saved before this picker was introduced).

    For runtime parity with the new picker, also writes per-category
    setVariable to the legacy listbox attrs and CLEARS the legacy
    Manual back-compat attrs so a runtime path still reading them
    sees consistent state. SQM persistence of those legacy attrs is
    not guaranteed (Eden serialises hidden attrs via their own
    attributeSave, which is "" for ALiVE_HiddenAttribute) - the
    consolidated attr is the authoritative SQM storage.

Parameters:
    [_display, _registryClass, _categoriesCsv, _varNamesCsv,
     _legacyManualVarsCsv]

Returns:
    STRING - consolidated structured value, or "" when nothing is
    selected.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _registryClass = "";
private _categoriesCsv = "";
private _varNamesCsv = "";
private _legacyManualVarsCsv = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _registryClass = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _categoriesCsv = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _varNamesCsv = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _legacyManualVarsCsv = _this select 4; };
} else {
    _display = _this;
};

private _categories = [_categoriesCsv, ","] call CBA_fnc_split;
private _varNames   = [_varNamesCsv, ","] call CBA_fnc_split;
private _legacyManualVars = if (_legacyManualVarsCsv != "") then {
    [_legacyManualVarsCsv, ","] call CBA_fnc_split
} else {
    []
};

if (count _categories == 0 || {count _categories != count _varNames}) exitWith {
    diag_log format [
        "ALIVE FilteredMultiSelect SAVE: categories/varNames length mismatch (cat=%1 var=%2)",
        count _categories, count _varNames
    ];
    ""
};

// ---- Read selection set ---------------------------------------------------
private _sel = _display getVariable ["alive_selectedClasses", []];
// Sync with current listbox visible-row state. LBSelChanged is the
// authoritative path normally, but handlers may fire after attributeSave
// in some Eden flows - reading the listbox here closes any race window.
private _list = _display controlsGroupCtrl 100;
if (!isNull _list) then {
    private _selIdx = lbSelection _list;
    for "_i" from 0 to (lbSize _list - 1) do {
        private _class = _list lbData _i;
        if (typeName _class == "STRING" && {_class != ""}) then {
            if (_i in _selIdx) then {
                _sel pushBackUnique _class;
            } else {
                _sel = _sel - [_class];
            };
        };
    };
};

// Append Override Edit free-text entries (CSV-split, trimmed)
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then {
    private _txt = ctrlText _editCtrl;
    if (typeName _txt == "STRING" && {_txt != ""}) then {
        {
            private _p = _x;
            while {count _p > 0 && {(_p select [0,1]) == " "}} do { _p = _p select [1] };
            while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do {
                _p = _p select [0, count _p - 1];
            };
            if (_p != "") then { _sel pushBackUnique _p };
        } forEach ([_txt, ","] call CBA_fnc_split);
    };
};

// ---- Build classname -> category lookup -----------------------------------
// Re-walk the registry. The LOAD handler stashes a _classToCat hashmap
// on the controlsGroup namespace, but rebuilding here is cheap and
// guards against the (unlikely) case of mid-session mod changes
// invalidating the cache. Walk cost is ~one hashSet per registry entry.
private _classToCat = createHashMap;
private _registry = configFile >> _registryClass;
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _source = _registry select _i;
        if (isClass _source) then {
            private _cp = getText (_source >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                {
                    private _cat = _x;
                    private _catClass = _source >> _cat;
                    if (isClass _catClass) then {
                        // Nested-subclass schema (HumanitarianItems / Animals).
                        for "_j" from 0 to (count _catClass - 1) do {
                            private _entry = _catClass select _j;
                            if (isClass _entry) then {
                                private _cn = configName _entry;
                                private _key = toLower _cn;
                                // First occurrence wins - matches LOAD
                                if !(_key in _classToCat) then {
                                    _classToCat set [_key, _cat];
                                };
                            };
                        };
                    } else {
                        // Flat-array schema (Cfg3rdPartyObjectiveObjects).
                        // Mirrors the LOAD-handler fallback so the SAVE
                        // bucketer can map flat-array classes back to
                        // their declaring category.
                        private _flatArr = getArray (_source >> _cat);
                        {
                            private _cn = _x;
                            if (typeName _cn == "STRING" && {_cn != ""}) then {
                                private _key = toLower _cn;
                                if !(_key in _classToCat) then {
                                    _classToCat set [_key, _cat];
                                };
                            };
                        } forEach _flatArr;
                    };
                } forEach _categories;
            };
        };
    };
};

// ---- Bucket selections by category ----------------------------------------
private _buckets = createHashMap;
{ _buckets set [_x, []] } forEach _categories;
private _defaultBucket = _categories select 0;

{
    private _classn = _x;
    private _key = toLower _classn;
    private _cat = _classToCat getOrDefault [_key, _defaultBucket];
    private _arr = _buckets get _cat;
    _arr pushBackUnique _classn;
} forEach _sel;

// ---- Build consolidated structured value ----------------------------------
// Format: "cat1:A,B;cat2:C,D" - segments only emitted for non-empty
// buckets. Empty selection set yields "" (canonical "user explicitly
// cleared the picker" sentinel).
private _segments = [];
{
    private _cat = _x;
    private _arr = _buckets get _cat;
    if (count _arr > 0) then {
        _segments pushBack format ["%1:%2", _cat, _arr joinString ","];
    };
} forEach _categories;

private _consolidated = _segments joinString ";";

// ---- Logic-side runtime parity --------------------------------------------
// Push per-category buckets to the legacy listbox attrs via setVariable
// (immediate runtime visibility - even though SQM persistence isn't
// guaranteed for hidden attrs, the runtime resolver consults
// setVariable values during the same Eden session). Clear the Manual
// back-compat attrs so any code-path still reading them doesn't
// double-count after the user removes items via the picker.
private _logicSel = get3DENSelected "logic";
private _logicObj = if (count _logicSel > 0) then { _logicSel select 0 } else { objNull };

if (!isNull _logicObj) then {
    {
        private _idx = _forEachIndex;
        private _cat = _x;
        private _vn  = _varNames select _idx;
        private _arr = _buckets get _cat;
        private _serialised = if (count _arr == 0) then {
            "[]"
        } else {
            format ["[%1]", (_arr apply { format ["""%1""", _x] }) joinString ","]
        };
        _logicObj setVariable [_vn, _serialised, true];
    } forEach _categories;
    {
        _logicObj setVariable [_x, "", true];
    } forEach _legacyManualVars;
};

// ---- Eden serialisation -------------------------------------------------
// Eden writes the controlsGroup display "value" string into the
// consolidated attr's SQM slot. The return value is also written -
// belt-and-braces against differing serialisation paths.
_display setVariable ["value", _consolidated];

diag_log format [
    "ALIVE FilteredMultiSelect SAVE: registry=%1 categories=%2 selected=%3 buckets=%4 legacyManualCleared=%5 -> '%6'",
    _registryClass, _categories, count _sel, _buckets, _legacyManualVars, _consolidated
];

_consolidated
