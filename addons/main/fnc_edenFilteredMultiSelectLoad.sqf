#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFilteredMultiSelectLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFilteredMultiSelectLoad

Description:
    Eden attributeLoad handler for ALiVE_FilteredMultiSelect_Base
    derivatives. Walks a registry (e.g. CfgALiVEAmbientAnimals or
    CfgALiVEHumanitarianItems), populates the listbox with entries from
    the named categories, wires the FilterNext button to cycle through
    ["All", category1, category2, ...], and ticks rows whose classnames
    are in the cumulative selection set.

    Storage shape:
      Consolidated attr (preferred, written by SAVE):
        STRING  e.g. "poultry:Hen_F,Cock_F;herd:Sheep_F,Goat_F"
      Legacy per-category attrs (read-only fallback when consolidated
      is empty - i.e. a mission saved before the consolidated picker
      was introduced):
        each STRING SQF array literal "['Hen_F','Cock_F']"

    Cumulative selection set tracked on the controlsGroup namespace
    via `alive_selectedClasses` so the filter cycle (which HIDES rows)
    doesn't lose ticks for non-visible categories. Race-avoidance via
    `alive_populating` gate flag, same pattern as the composition
    picker LOAD.

Parameters:
    [_display, _registryClass, _categoriesCsv, _varNamesCsv,
     _initialDefault, _sqmValue, _titleStr, _legacyManualVarsCsv,
     _consolidatedVar]

    _display            : DISPLAY - controlsGroup display
    _registryClass      : STRING  - "CfgALiVEAmbientAnimals" /
                                    "CfgALiVEHumanitarianItems"
    _categoriesCsv      : STRING  - "poultry,herd" / "water,ration"
                                    (subclass paths inside each registry
                                    entry; first wins when a class is
                                    listed under multiple categories)
    _varNamesCsv        : STRING  - "customPoultryClasses,customHerdClasses"
                                    (1:1 with categories, same length;
                                    legacy fallback storage)
    _initialDefault     : ARRAY of STRINGs - classnames to pre-tick on
                                    fresh placement when nothing is
                                    stored anywhere (mirrors the BLU_F
                                    pattern from FactionChoiceMulti)
    _sqmValue           : STRING  - SQM-deserialised value of the
                                    consolidated attr (Cfg3DEN's
                                    auto-populated `_value`); takes
                                    priority over getVariable when
                                    non-empty
    _titleStr           : STRING  - localised title text or $STR_ key
                                    rendered in the left-column Title
    _legacyManualVarsCsv: STRING  - "customPoultryClassesManual,..."
                                    (per-category free-text Manual edits
                                    from the pre-consolidation UI; also
                                    merged into selection set for
                                    back-compat)
    _consolidatedVar    : STRING  - logic-variable name of the
                                    consolidated picker storage (e.g.
                                    "customAnimalClasses"). Read first;
                                    parsed in structured form; legacy
                                    attrs only consulted when this is
                                    empty.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _registryClass = "";
private _categoriesCsv = "";
private _varNamesCsv = "";
private _initialDefault = [];
private _sqmValue = "";
private _titleStr = "";
private _legacyManualVarsCsv = "";
private _consolidatedVar = "";
// Optional 10th positional parameter: per-consumer override label text
// (replaces the default "Override entries:" with consumer-specific
// wording, e.g. "Override Objects:" for the ObjectiveObjectChoice
// picker). Empty string keeps the default. Stringtable $STR_ keys
// supported, same as _titleStr.
private _overrideLabelStr = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _registryClass = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _categoriesCsv = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _varNamesCsv = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "ARRAY"})  then { _initialDefault = _this select 4; };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"}) then { _sqmValue = _this select 5; };
    if (count _this > 6 && {typeName (_this select 6) == "STRING"}) then { _titleStr = _this select 6; };
    if (count _this > 7 && {typeName (_this select 7) == "STRING"}) then { _legacyManualVarsCsv = _this select 7; };
    if (count _this > 8 && {typeName (_this select 8) == "STRING"}) then { _consolidatedVar = _this select 8; };
    if (count _this > 9 && {typeName (_this select 9) == "STRING"}) then { _overrideLabelStr = _this select 9; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE FilteredMultiSelect LOAD: null display"] call ALiVE_fnc_dump;
};

private _categories = [_categoriesCsv, ","] call CBA_fnc_split;
private _varNames   = [_varNamesCsv, ","] call CBA_fnc_split;
private _legacyManualVars = if (_legacyManualVarsCsv != "") then {
    [_legacyManualVarsCsv, ","] call CBA_fnc_split
} else {
    []
};

if (count _categories == 0 || {count _categories != count _varNames}) exitWith {
    ["ALIVE FilteredMultiSelect LOAD: categories/varNames length mismatch (cat=%1 var=%2)",
        count _categories, count _varNames] call ALiVE_fnc_dump;
};

// ---- Title ----------------------------------------------------------------
private _titleResolved = _titleStr;
if (_titleStr != "" && {(_titleStr select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl && {_titleResolved != ""}) then {
    _titleCtrl ctrlSetText _titleResolved;
};

// ---- OverrideLabel (optional per-consumer text) ---------------------------
// Default substrate text is "Override entries:" (set in CfgVehicles); when
// a consumer plumbs through a non-empty _overrideLabelStr we replace it
// with the consumer-specific label (e.g. "Override Objects:" for the
// ObjectiveObjectChoice picker). $STR_ keys resolved via localize, same
// as _titleStr.
if (_overrideLabelStr != "") then {
    private _overrideResolved = _overrideLabelStr;
    if ((_overrideLabelStr select [0,1]) == "$") then {
        _overrideResolved = localize (_overrideLabelStr select [1]);
    };
    private _overrideLabelCtrl = _display controlsGroupCtrl 103;
    if (!isNull _overrideLabelCtrl) then {
        _overrideLabelCtrl ctrlSetText _overrideResolved;
    };
};

// ---- Resolve logic + stored values ----------------------------------------
private _selectedLogic = get3DENSelected "logic";
private _logicObj = if (count _selectedLogic > 0) then { _selectedLogic select 0 } else { objNull };

// Helper: parse a stored-value string. Accepts SQF array literal
// `["A","B"]`, CSV "A,B", or single classname "A". Returns array of
// trimmed non-empty strings.
private _parseClassList = {
    params [["_raw", "", [""]]];
    private _result = [];
    if (typeName _raw != "STRING" || {_raw == ""}) exitWith { _result };
    private _len = count _raw;
    if (_len >= 2 && {(_raw select [0,1]) == "'"} && {(_raw select [_len-1,1]) == "'"}) then {
        _raw = _raw select [1, _len - 2];
    };
    private _trimmed = _raw;
    while {count _trimmed > 0 && {(_trimmed select [0,1]) == " "}} do { _trimmed = _trimmed select [1] };
    while {count _trimmed > 0 && {(_trimmed select [count _trimmed - 1, 1]) == " "}} do {
        _trimmed = _trimmed select [0, count _trimmed - 1];
    };
    if (count _trimmed > 0 && {(_trimmed select [0,1]) == "["}) then {
        private _parsed = parseSimpleArray _trimmed;
        if (typeName _parsed == "ARRAY") then {
            { if (typeName _x == "STRING" && {_x != ""}) then { _result pushBackUnique _x } } forEach _parsed;
        };
    } else {
        {
            private _p = _x;
            while {count _p > 0 && {(_p select [0,1]) == " "}} do { _p = _p select [1] };
            while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
            if (_p != "") then { _result pushBackUnique _p };
        } forEach ([_trimmed, ","] call CBA_fnc_split);
    };
    _result
};

// Consolidated value resolution priority: SQM `_value` > logic var > "".
private _consolidatedRaw = "";
if (_consolidatedVar != "" && {!isNull _logicObj}) then {
    private _stored = _logicObj getVariable [_consolidatedVar, ""];
    if (typeName _stored == "STRING") then { _consolidatedRaw = _stored };
};
private _edenValue = _display getVariable "value";
if (!isNil "_edenValue" && {typeName _edenValue == "STRING"} && {_edenValue != ""}) then {
    _consolidatedRaw = _edenValue;
};
if (_sqmValue != "") then { _consolidatedRaw = _sqmValue };

// Per-class category + side hashmap (built once from registry, used
// both at LOAD to surface rows and at SAVE to bucket selections - but
// rebuilt by SAVE since handlers don't share scope).
//
// Side detection (hybrid):
//   1. CfgVehicles `side` config: 0=East, 1=West, 2=Indep, 3=Civilian.
//      Most placeable scenery is side -1 (Empty / no side) which we
//      treat as "any" / unfiltered - falls through to step 2.
//   2. Class-name suffix heuristic: _BLUFOR -> 1, _OPFOR -> 0,
//      _IND/_INDFOR -> 2, _CIV -> 3. Catches POOK SAM-style theme-by-
//      suffix conventions where the engine config still reads -1.
//   3. If neither resolves to a meaningful side -> -1 (Empty/Any). The
//      side filter shows these under the "Empty" cycle option.
private _detectSide = {
    params ["_cn"];
    private _cnUpper = toUpper _cn;
    private _sideNum = -1;
    if (isNumber (configFile >> "CfgVehicles" >> _cn >> "side")) then {
        _sideNum = getNumber (configFile >> "CfgVehicles" >> _cn >> "side");
    };
    if (_sideNum < 0 || {_sideNum > 3}) then {
        _sideNum = -1;
        // Class-name suffix heuristic. Order matters: _INDFOR before
        // _IND so the longer suffix wins; _OPFOR before _CIVILIAN to
        // preserve order with _CIV check below.
        if (_cnUpper find "_BLUFOR" > -1)        then { _sideNum = 1 };
        if (_sideNum < 0 && {_cnUpper find "_OPFOR" > -1})  then { _sideNum = 0 };
        if (_sideNum < 0 && {_cnUpper find "_INDFOR" > -1}) then { _sideNum = 2 };
        if (_sideNum < 0 && {_cnUpper find "_IND" > -1})    then { _sideNum = 2 };
        if (_sideNum < 0 && {_cnUpper find "_CIV" > -1})    then { _sideNum = 3 };
    };
    _sideNum
};

private _entries = [];
private _classToCat = createHashMap;
private _classToSide = createHashMap;
private _seen = createHashMap;
// Source-level visibility for mod authors who add their own subclass to
// the registry from their addon's config.cpp. Per-source counts are
// surfaced in the LOAD diagnostic line at function exit so RPT shows
// "MyMod: 12 (radar=4, antenna=8)" alongside ALiVE's pre-registered
// blocks. Lets authors confirm their convention block is detected.
private _sourceCounts = [];
private _registry = configFile >> _registryClass;
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _source = _registry select _i;
        if (isClass _source) then {
            private _cp = getText (_source >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                private _modLabel = getText (_source >> "displayName");
                if (_modLabel == "") then { _modLabel = configName _source };
                private _entriesBefore = count _entries;
                {
                    private _cat = _x;
                    private _catClass = _source >> _cat;
                    if (isClass _catClass) then {
                        // Nested-subclass schema (CfgALiVEAmbientAnimals,
                        // CfgALiVEHumanitarianItems): each category is a
                        // subclass containing per-class subclasses with
                        // displayName overrides.
                        for "_j" from 0 to (count _catClass - 1) do {
                            private _entry = _catClass select _j;
                            if (isClass _entry) then {
                                private _cn = configName _entry;
                                private _cnLower = toLower _cn;
                                // First occurrence wins (registry walk
                                // order). Same class duplicated under a
                                // different category in the same or
                                // another mod: only the first sticks.
                                if !(_cnLower in _seen) then {
                                    _seen set [_cnLower, true];
                                    _classToCat set [_cnLower, _cat];
                                    _classToSide set [_cnLower, ([_cn] call _detectSide)];
                                    private _dn = getText (_entry >> "displayName");
                                    if (_dn == "") then { _dn = _cn };
                                    _entries pushBack [_cn, _dn, _modLabel, _cat];
                                };
                            };
                        };
                    } else {
                        // Flat-array schema (Cfg3rdPartyObjectiveObjects):
                        // each category is a string-array of class names.
                        // displayName resolved at runtime via configFile
                        // CfgVehicles lookup so the registry stays lean
                        // for high-volume mods (POOK SAM 153 entries).
                        private _flatArr = getArray (_source >> _cat);
                        {
                            private _cn = _x;
                            if (typeName _cn == "STRING" && {_cn != ""}) then {
                                private _cnLower = toLower _cn;
                                if !(_cnLower in _seen) then {
                                    _seen set [_cnLower, true];
                                    _classToCat set [_cnLower, _cat];
                                    _classToSide set [_cnLower, ([_cn] call _detectSide)];
                                    private _dn = getText (configFile >> "CfgVehicles" >> _cn >> "displayName");
                                    if (_dn == "") then { _dn = _cn };
                                    _entries pushBack [_cn, _dn, _modLabel, _cat];
                                };
                            };
                        } forEach _flatArr;
                    };
                } forEach _categories;
                private _added = (count _entries) - _entriesBefore;
                if (_added > 0) then {
                    _sourceCounts pushBack format ["%1=%2", _modLabel, _added];
                };
            };
        };
    };
};

// ---- Build cumulative selection set ---------------------------------------
// Priority cascade:
//   1. Consolidated structured value (preferred, set by SAVE) - "cat:A,B;cat:C"
//   2. Legacy listbox attrs union with legacy Manual attrs (back-compat
//      for missions saved before the consolidated picker existed)
//   3. _initialDefault on truly fresh placement
private _selectedClasses = [];

if (_consolidatedRaw != "") then {
    // Parse structured format: "cat:Class1,Class2;cat:Class3"
    {
        private _segment = _x;
        private _colonIdx = _segment find ":";
        private _classCsv = if (_colonIdx >= 0) then {
            // Drop the category prefix - selection set is flat at
            // LOAD/SAVE level; classification happens via
            // _classToCat lookup at SAVE.
            _segment select [_colonIdx + 1]
        } else {
            // Non-prefixed segment - treat as flat CSV
            _segment
        };
        {
            _selectedClasses pushBackUnique _x;
        } forEach ([_classCsv] call _parseClassList);
    } forEach ([_consolidatedRaw, ";"] call CBA_fnc_split);
} else {
    // Legacy fallback - merge listbox + Manual per category
    {
        private _vn = _x;
        private _raw = if (!isNull _logicObj) then { _logicObj getVariable [_vn, ""] } else { "" };
        { _selectedClasses pushBackUnique _x } forEach ([_raw] call _parseClassList);
    } forEach _varNames;
    {
        private _vn = _x;
        private _raw = if (!isNull _logicObj) then { _logicObj getVariable [_vn, ""] } else { "" };
        { _selectedClasses pushBackUnique _x } forEach ([_raw] call _parseClassList);
    } forEach _legacyManualVars;
};

if (count _selectedClasses == 0 && {count _initialDefault > 0}) then {
    {
        if (typeName _x == "STRING" && {_x != ""}) then {
            _selectedClasses pushBackUnique _x;
        };
    } forEach _initialDefault;
};

// ---- Listbox control ------------------------------------------------------
private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE FilteredMultiSelect LOAD: listbox (IDC 100) not found"] call ALiVE_fnc_dump;
};

// Filter options: ["All", category1, category2, ...]
private _filterOptions = ["All"] + _categories;

// Side filter options: parallel arrays. _sideOptions is the cycle
// labels, _sideValues is the matching numeric side (or -2 sentinel
// for "All" = no filter).
//   index 0: "All"      -> -2 (no filter)
//   index 1: "BLUFOR"   ->  1
//   index 2: "OPFOR"    ->  0
//   index 3: "Indep"    ->  2
//   index 4: "Civilian" ->  3
//   index 5: "Empty"    -> -1 (no side declared OR suffix didn't match)
private _sideOptions = ["All", "BLUFOR", "OPFOR", "Indep", "Civilian", "Empty"];
private _sideValues  = [-2, 1, 0, 2, 3, -1];

// Filter state persistence on logic (session-scoped, survives Eden
// dialog close/open within the same session). Keyed on the
// consolidated varName so each picker tracks its own filter state.
private _filterStateKey = format ["%1_filterIdx", _consolidatedVar];
private _sideStateKey   = format ["%1_sideIdx", _consolidatedVar];
private _filterIdx = 0;
private _sideIdx = 0;
if (!isNull _logicObj) then {
    private _saved = _logicObj getVariable [_filterStateKey, nil];
    if (!isNil "_saved" && {typeName _saved == "SCALAR"}) then { _filterIdx = _saved };
    private _savedSide = _logicObj getVariable [_sideStateKey, nil];
    if (!isNil "_savedSide" && {typeName _savedSide == "SCALAR"}) then { _sideIdx = _savedSide };
};
if (_filterIdx >= count _filterOptions) then { _filterIdx = 0 };
if (_sideIdx >= count _sideOptions) then { _sideIdx = 0 };

// Stash everything on the controlsGroup namespace for handlers
_display setVariable ["alive_entries", _entries];
_display setVariable ["alive_classToCat", _classToCat];
_display setVariable ["alive_classToSide", _classToSide];
_display setVariable ["alive_selectedClasses", _selectedClasses];
_display setVariable ["alive_filterOptions", _filterOptions];
_display setVariable ["alive_filterIdx", _filterIdx];
_display setVariable ["alive_sideOptions", _sideOptions];
_display setVariable ["alive_sideValues", _sideValues];
_display setVariable ["alive_sideIdx", _sideIdx];
_display setVariable ["alive_categories", _categories];

// Update FilterLabel
private _filterLabel = _display controlsGroupCtrl 1200;
if (!isNull _filterLabel) then {
    _filterLabel ctrlSetText format ["Type: %1", _filterOptions select _filterIdx];
};

// Update SideFilterLabel
private _sideLabelCtrl = _display controlsGroupCtrl 1201;
if (!isNull _sideLabelCtrl) then {
    _sideLabelCtrl ctrlSetText format ["Side: %1", _sideOptions select _sideIdx];
};

// ---- Populate function ----------------------------------------------------
private _populateFn = {
    params ["_disp"];
    private _ents       = _disp getVariable ["alive_entries", []];
    private _sel        = _disp getVariable ["alive_selectedClasses", []];
    private _fOpts      = _disp getVariable ["alive_filterOptions", ["All"]];
    private _fIdx       = _disp getVariable ["alive_filterIdx", 0];
    private _filter     = _fOpts select _fIdx;
    private _classToSideMap = _disp getVariable ["alive_classToSide", createHashMap];
    private _sideVals   = _disp getVariable ["alive_sideValues", [-2]];
    private _sIdx       = _disp getVariable ["alive_sideIdx", 0];
    private _sideTarget = _sideVals select _sIdx;  // -2 = no side filter
    private _list = _disp controlsGroupCtrl 100;
    if (isNull _list) exitWith {};

    // Gate: every lbSetSelected fires LBSelChanged synchronously, which
    // would otherwise read partial state and remove not-yet-re-ticked
    // classes. Gate makes LBSelChanged a no-op for programmatic ticks.
    _disp setVariable ["alive_populating", true];
    lbClear _list;

    private _selLowerSet = createHashMap;
    { _selLowerSet set [toLower _x, true] } forEach _sel;

    // Surface unrecognised entries (selected classes not in registry)
    // at the top of EVERY filter view. They have no category so can't
    // be hidden by filter; the mission-maker always sees them.
    private _entriesLowerSet = createHashMap;
    { _entriesLowerSet set [toLower (_x select 0), true] } forEach _ents;
    private _unrecognisedAdded = [];
    {
        if !((toLower _x) in _entriesLowerSet) then {
            private _idx = _list lbAdd format ["(unrecognised) %1", _x];
            _list lbSetData [_idx, _x];
            _list lbSetSelected [_idx, true];
            _unrecognisedAdded pushBack _x;
        };
    } forEach _sel;

    // Filter registry-known rows. "All" on category surfaces everything;
    // side filter intersected on top. _sideTarget == -2 = side All
    // (no side filter), otherwise must match the per-class side from
    // _classToSideMap.
    private _matched = _ents select {
        private _entry = _x;
        private _catOk = (_filter == "All") || {(_entry select 3) == _filter};
        private _sideOk = if (_sideTarget == -2) then { true } else {
            private _sideForClass = _classToSideMap getOrDefault [toLower (_entry select 0), -1];
            _sideForClass == _sideTarget
        };
        _catOk && _sideOk
    };

    // Group by mod label, alphabetical within each
    private _modLabels = [];
    {
        if !((_x select 2) in _modLabels) then { _modLabels pushBack (_x select 2) };
    } forEach _matched;
    _modLabels sort true;

    private _surfaced = 0;
    private _ticked   = count _unrecognisedAdded;
    {
        private _ml = _x;
        private _bucket = _matched select { (_x select 2) == _ml };
        _bucket sort true;
        {
            _x params ["_cn", "_dn", "_modLabel", "_cat"];
            private _label = if (_dn == _cn) then {
                format ["%1 - %2 [%3]", _modLabel, _dn, _cat]
            } else {
                format ["%1 - %2 (%3) [%4]", _modLabel, _dn, _cn, _cat]
            };
            private _idx = _list lbAdd _label;
            _list lbSetData [_idx, _cn];
            _surfaced = _surfaced + 1;
            if ((toLower _cn) in _selLowerSet) then {
                _list lbSetSelected [_idx, true];
                _ticked = _ticked + 1;
            };
        } forEach _bucket;
    } forEach _modLabels;

    [
        "ALIVE FilteredMultiSelect POPULATE: filter=%1 surfaced=%2 ticked=%3 unrecog=%4",
        _filter, _surfaced, _ticked, count _unrecognisedAdded
    ] call ALiVE_fnc_dump;
    _disp setVariable ["alive_populating", false];
};

// Initial populate
[_display] call _populateFn;

// Override Edit starts empty - unrecognised entries surface in the
// listbox top row instead. The Edit is the user's input slot for
// typing new mod classes the registry doesn't surface.
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then { _editCtrl ctrlSetText "" };

// ---- Wire FilterNext button (idc 1210) ------------------------------------
private _btn = _display controlsGroupCtrl 1210;
if (!isNull _btn) then {
    _btn setVariable ["alive_disp", _display];
    _btn setVariable ["alive_populateFn", _populateFn];
    _btn setVariable ["alive_logic", _logicObj];
    _btn setVariable ["alive_filterStateKey", _filterStateKey];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_b"];
        private _disp  = _b getVariable "alive_disp";
        private _pop   = _b getVariable "alive_populateFn";
        private _logic = _b getVariable "alive_logic";
        private _fKey  = _b getVariable "alive_filterStateKey";
        private _opts  = _disp getVariable ["alive_filterOptions", ["All"]];
        private _idx   = _disp getVariable ["alive_filterIdx", 0];
        _idx = (_idx + 1) mod (count _opts);
        _disp setVariable ["alive_filterIdx", _idx];
        private _label = _disp controlsGroupCtrl 1200;
        if (!isNull _label) then {
            _label ctrlSetText format ["Type: %1", _opts select _idx];
        };
        if (!isNull _logic && {!isNil "_fKey"} && {_fKey != ""}) then {
            _logic setVariable [_fKey, _idx];
        };
        [_disp] call _pop;
    }];
};

// ---- Wire SideFilterNext button (idc 1211) --------------------------------
// Mirrors the category-cycle pattern, parallel state on alive_sideIdx.
// Same populate fn re-runs on click; populate intersects category + side
// to determine which rows to surface.
private _sideBtn = _display controlsGroupCtrl 1211;
if (!isNull _sideBtn) then {
    _sideBtn setVariable ["alive_disp", _display];
    _sideBtn setVariable ["alive_populateFn", _populateFn];
    _sideBtn setVariable ["alive_logic", _logicObj];
    _sideBtn setVariable ["alive_sideStateKey", _sideStateKey];
    _sideBtn ctrlAddEventHandler ["ButtonClick", {
        params ["_b"];
        private _disp  = _b getVariable "alive_disp";
        private _pop   = _b getVariable "alive_populateFn";
        private _logic = _b getVariable "alive_logic";
        private _sKey  = _b getVariable "alive_sideStateKey";
        private _opts  = _disp getVariable ["alive_sideOptions", ["All"]];
        private _idx   = _disp getVariable ["alive_sideIdx", 0];
        _idx = (_idx + 1) mod (count _opts);
        _disp setVariable ["alive_sideIdx", _idx];
        private _label = _disp controlsGroupCtrl 1201;
        if (!isNull _label) then {
            _label ctrlSetText format ["Side: %1", _opts select _idx];
        };
        if (!isNull _logic && {!isNil "_sKey"} && {_sKey != ""}) then {
            _logic setVariable [_sKey, _idx];
        };
        [_disp] call _pop;
    }];
};

// ---- Wire LBSelChanged on listbox -----------------------------------------
// Sync alive_selectedClasses with currently-visible row toggles. Rows
// hidden by filter retain their selection state because we never see
// them in lbSize iteration - the cumulative set on the namespace is
// the source of truth.
_listCtrl setVariable ["alive_disp", _display];
_listCtrl ctrlAddEventHandler ["LBSelChanged", {
    params ["_lb"];
    private _disp = _lb getVariable "alive_disp";
    if (_disp getVariable ["alive_populating", false]) exitWith {};
    private _sel = _disp getVariable ["alive_selectedClasses", []];
    private _selIdx = lbSelection _lb;
    for "_i" from 0 to (lbSize _lb - 1) do {
        private _class = _lb lbData _i;
        if (typeName _class == "STRING" && {_class != ""}) then {
            if (_i in _selIdx) then {
                _sel pushBackUnique _class;
            } else {
                _sel = _sel - [_class];
            };
        };
    };
    _disp setVariable ["alive_selectedClasses", _sel];
}];

[
    "ALIVE FilteredMultiSelect LOAD: registry=%1 categories=%2 varNames=%3 consolidatedVar='%4' consolidatedRaw='%5' sqm='%6' selected=%7 entries=%8 sources=[%9] legacyManual=%10",
    _registryClass, _categories, _varNames, _consolidatedVar, _consolidatedRaw, _sqmValue,
    count _selectedClasses, count _entries, _sourceCounts joinString ", ", _legacyManualVars
] call ALiVE_fnc_dump;
