#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionTierChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionTierChoiceLoad

Description:
    Eden attributeLoad handler for ALiVE_FactionTierChoice. Multi-select
    listbox of military-side factions where the filter cycle button SWAPS
    which tier's selection set is currently displayed (NOT hides rows).
    Each faction can be ticked under any tier independently; toggling a
    row mutates only the currently-active tier's set.

    Different from ALiVE_FilteredMultiSelect (Phase 7a hide-rows variant)
    in that all rows are visible at all times. The filter is a "view"
    onto N selection sets, not a row-visibility filter.

    Storage shape:
      Consolidated attr (preferred, written by SAVE):
        STRING e.g. "recruit:OPF_F;regular:BLU_F,IND_F;veteran:;expert:;custom:"
      Legacy per-tier attrs (read-only fallback when consolidated is
      empty - mission saved before the consolidated picker existed):
        each STRING SQF array literal "['BLU_F','IND_F']" or ARRAY
        (engine push from setVariable in fnc_aiskill init merge)

    Override Edit semantics: shared field that displays the CURRENT
    tier's "unrecognised" entries (those typed via Manual edit in the
    pre-consolidation UI, or for mod factions the registry doesn't
    surface). On filter cycle, the Edit's current text is absorbed
    into the OLD active tier's bucket before swapping; the NEW active
    tier's missing entries pre-fill the Edit.

Parameters:
    [_display, _allowedSides, _consolidatedVar, _legacyVarsCsv,
     _legacyManualVarsCsv, _tierLabelsCsv, _sqmValue, _titleStr]

    _display              : DISPLAY - controlsGroup display
    _allowedSides         : ARRAY of NUMBERs - sides to include
                            (military: [0,1,2])
    _consolidatedVar      : STRING - logic-variable name of the
                            consolidated picker storage (e.g.
                            "skillTierFactions")
    _legacyVarsCsv        : STRING - per-tier legacy listbox attrs
                            CSV, 1:1 with tier labels
    _legacyManualVarsCsv  : STRING - per-tier legacy Manual attrs
                            CSV, 1:1 with tier labels
    _tierLabelsCsv        : STRING - tier labels CSV
                            (e.g. "Recruit,Regular,Veteran,Expert,Custom")
                            User-facing labels; lowercased to form
                            structured-storage tier keys.
    _sqmValue             : STRING - SQM-deserialised consolidated
                            value (Cfg3DEN's auto-populated `_value`)
    _titleStr             : STRING - localised title or $STR_ key

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _allowedSides = [0,1,2];
private _consolidatedVar = "";
private _legacyVarsCsv = "";
private _legacyManualVarsCsv = "";
private _tierLabelsCsv = "Recruit,Regular,Veteran,Expert,Custom";
private _sqmValue = "";
private _titleStr = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "ARRAY"})  then { _allowedSides = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _consolidatedVar = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _legacyVarsCsv = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _legacyManualVarsCsv = _this select 4; };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"}) then { _tierLabelsCsv = _this select 5; };
    if (count _this > 6 && {typeName (_this select 6) == "STRING"}) then { _sqmValue = _this select 6; };
    if (count _this > 7 && {typeName (_this select 7) == "STRING"}) then { _titleStr = _this select 7; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE FactionTierChoice LOAD: null display"] call ALiVE_fnc_dump;
};

private _legacyVars       = if (_legacyVarsCsv != "")       then { [_legacyVarsCsv, ","]       call CBA_fnc_split } else { [] };
private _legacyManualVars = if (_legacyManualVarsCsv != "") then { [_legacyManualVarsCsv, ","] call CBA_fnc_split } else { [] };
private _tierLabels       = [_tierLabelsCsv, ","] call CBA_fnc_split;
// Tier keys are lowercased labels; they form the structured-storage prefix.
private _tierKeys         = _tierLabels apply { toLower _x };

if (count _tierKeys == 0 || {count _tierKeys != count _legacyVars}) exitWith {
    [
        "ALIVE FactionTierChoice LOAD: tierKeys/legacyVars length mismatch (tiers=%1 legacy=%2)",
        count _tierKeys, count _legacyVars
    ] call ALiVE_fnc_dump;
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

// ---- Resolve logic + helper ------------------------------------------------
private _selectedLogic = get3DENSelected "logic";
private _logicObj = if (count _selectedLogic > 0) then { _selectedLogic select 0 } else { objNull };

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

// Resolve consolidated raw (priority cascade)
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

// ---- Build per-tier selection sets ---------------------------------------
private _perTier = createHashMap;
{ _perTier set [_x, []] } forEach _tierKeys;

if (_consolidatedRaw != "") then {
    // Parse "tier:Faction1,Faction2;tier:Faction3"
    {
        private _segment = _x;
        private _colonIdx = _segment find ":";
        if (_colonIdx > 0) then {
            private _segKey = toLower (_segment select [0, _colonIdx]);
            if (_segKey in _tierKeys) then {
                private _classCsv = _segment select [_colonIdx + 1];
                private _arr = _perTier get _segKey;
                { _arr pushBackUnique _x } forEach ([_classCsv] call _parseClassList);
            };
        };
    } forEach ([_consolidatedRaw, ";"] call CBA_fnc_split);
} else {
    // Legacy fallback: per-tier listbox + Manual union
    {
        private _idx = _forEachIndex;
        private _tierKey = _x;
        private _vn = _legacyVars select _idx;
        private _raw = if (!isNull _logicObj) then { _logicObj getVariable [_vn, ""] } else { "" };
        private _bucket = _perTier get _tierKey;
        // Logic-var value can be ARRAY (already-resolved by fnc_aiskill init
        // merge) or STRING (raw SQM array literal); handle both shapes.
        if (typeName _raw == "ARRAY") then {
            { if (typeName _x == "STRING" && {_x != ""}) then { _bucket pushBackUnique _x } } forEach _raw;
        } else {
            { _bucket pushBackUnique _x } forEach ([_raw] call _parseClassList);
        };
    } forEach _tierKeys;
    {
        private _idx = _forEachIndex;
        if (_idx < count _tierKeys) then {
            private _tierKey = _tierKeys select _idx;
            private _bucket = _perTier get _tierKey;
            private _raw = if (!isNull _logicObj) then { _logicObj getVariable [_x, ""] } else { "" };
            { _bucket pushBackUnique _x } forEach ([_raw] call _parseClassList);
        };
    } forEach _legacyManualVars;
};

// ---- Listbox + faction enumeration ---------------------------------------
private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE FactionTierChoice LOAD: listbox (IDC 100) not found"] call ALiVE_fnc_dump;
};

// Same enumeration pattern as fnc_edenFactionChoiceMultiLoad: side filter +
// CfgGroups usability + civilian blacklist + Cfg3rdPartyFactions overrides
// + inferability check.
private _sideCfgGroupsName = ["East", "West", "Indep", "Civilian"];
private _civilianBlacklist = ["virtual_f", "interactive_f"];

private _registryOverrides = createHashMap;
private _registry = configFile >> "Cfg3rdPartyFactions";
if (isClass _registry) then {
    for "_i" from 0 to (count _registry - 1) do {
        private _entry = _registry select _i;
        if (isClass _entry) then {
            private _cp = getText (_entry >> "cfgPatchesName");
            if (_cp != "" && {isClass (configFile >> "CfgPatches" >> _cp)}) then {
                private _factionsClass = _entry >> "factions";
                if (isClass _factionsClass) then {
                    for "_j" from 0 to (count _factionsClass - 1) do {
                        private _facOverride = _factionsClass select _j;
                        if (isClass _facOverride) then {
                            private _facCN = configName _facOverride;
                            private _override = createHashMap;
                            if (isText (_facOverride >> "displayName")) then {
                                _override set ["displayName", getText (_facOverride >> "displayName")];
                            };
                            if (isNumber (_facOverride >> "excluded")) then {
                                _override set ["excluded", getNumber (_facOverride >> "excluded") > 0];
                            };
                            _registryOverrides set [toLower _facCN, _override];
                        };
                    };
                };
            };
        };
    };
};

private _seen = createHashMap;
private _entries = [];
private _configPaths = [missionConfigFile >> "CfgFactionClasses", configFile >> "CfgFactionClasses"];
{
    private _root = _x;
    for "_i" from 0 to (count _root - 1) do {
        private _fac = _root select _i;
        if (isClass _fac) then {
            private _cn = configName _fac;
            private _cnLower = toLower _cn;
            if !(_cnLower in _seen) then {
                _seen set [_cnLower, true];
                private _side = getNumber (_fac >> "side");
                if !(isNumber (_fac >> "side")) then { _side = -1 };
                if (_side in [0, 1, 2, 3] && {_side in _allowedSides}) then {
                    private _usable = if (_side == 3) then {
                        !(_cnLower in _civilianBlacklist)
                    } else {
                        private _sideName = _sideCfgGroupsName select _side;
                        private _groupsEntry = configFile >> "CfgGroups" >> _sideName >> _cn;
                        if (isClass _groupsEntry && {count _groupsEntry > 0}) then { true }
                        else {
                            private _vehicles = "true" configClasses (configFile >> "CfgVehicles");
                            (_vehicles findIf {
                                (toLower (getText (_x >> "faction"))) == _cnLower &&
                                {(configName _x) isKindOf "Man"}
                            }) >= 0
                        };
                    };
                    if (_usable) then {
                        private _override = _registryOverrides getOrDefault [_cnLower, createHashMap];
                        if !(_override getOrDefault ["excluded", false]) then {
                            private _dn = _override getOrDefault ["displayName", ""];
                            if (_dn isEqualTo "") then {
                                _dn = getText (_fac >> "displayName");
                                if (_dn isEqualTo "") then { _dn = _cn };
                            };
                            _entries pushBack [_cn, _dn, _side];
                        };
                    };
                };
            };
        };
    };
} forEach _configPaths;

// ---- Filter state persistence (session-scoped via logic) ------------------
private _filterStateKey = format ["%1_filterIdx", _consolidatedVar];
private _filterIdx = 0;
if (!isNull _logicObj) then {
    private _saved = _logicObj getVariable [_filterStateKey, nil];
    if (!isNil "_saved" && {typeName _saved == "SCALAR"}) then { _filterIdx = _saved };
};
if (_filterIdx >= count _tierLabels) then { _filterIdx = 0 };

// ---- Stash on namespace ---------------------------------------------------
_display setVariable ["alive_perTier", _perTier];
_display setVariable ["alive_entries", _entries];
_display setVariable ["alive_tierKeys", _tierKeys];
_display setVariable ["alive_tierLabels", _tierLabels];
_display setVariable ["alive_filterIdx", _filterIdx];

// FilterLabel
private _filterLabel = _display controlsGroupCtrl 1200;
if (!isNull _filterLabel) then {
    _filterLabel ctrlSetText format ["Tier: %1", _tierLabels select _filterIdx];
};

// ---- Override Edit absorb / refill helpers -------------------------------
private _absorbOverride = {
    params ["_disp", "_tierKey"];
    private _editCtrl = _disp controlsGroupCtrl 102;
    if (isNull _editCtrl) exitWith {};
    private _txt = ctrlText _editCtrl;
    if (typeName _txt != "STRING" || {_txt == ""}) exitWith {};
    private _per = _disp getVariable ["alive_perTier", createHashMap];
    private _arr = _per get _tierKey;
    if (isNil "_arr") exitWith {};
    {
        private _p = _x;
        while {count _p > 0 && {(_p select [0,1]) == " "}} do { _p = _p select [1] };
        while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do { _p = _p select [0, count _p - 1] };
        if (_p != "") then { _arr pushBackUnique _p };
    } forEach ([_txt, ","] call CBA_fnc_split);
};

private _refillOverride = {
    params ["_disp", "_tierKey"];
    private _editCtrl = _disp controlsGroupCtrl 102;
    if (isNull _editCtrl) exitWith {};
    private _per = _disp getVariable ["alive_perTier", createHashMap];
    private _ents = _disp getVariable ["alive_entries", []];
    private _entriesLowerSet = createHashMap;
    { _entriesLowerSet set [toLower (_x select 0), true] } forEach _ents;
    private _bucket = _per get _tierKey;
    if (isNil "_bucket") exitWith { _editCtrl ctrlSetText "" };
    private _missing = [];
    {
        if !((toLower _x) in _entriesLowerSet) then { _missing pushBackUnique _x };
    } forEach _bucket;
    _editCtrl ctrlSetText (_missing joinString ",");
};

// ---- Populate listbox once (rows constant across filter cycles) ----------
// The filter swaps which tier's ticks display - rows themselves don't move.
private _sideBuckets = [
    [0, "OPFOR"],
    [1, "BLUFOR"],
    [2, "INDFOR"],
    [3, "CIVILIAN"]
];
{
    _x params ["_sideValue", "_sideLabel"];
    if !(_sideValue in _allowedSides) then { continue };
    private _bucketEntries = _entries select { _x params ["", "", "_s"]; _s == _sideValue };
    _bucketEntries sort true;
    {
        _x params ["_cn", "_dn"];
        private _label = if (_dn == _cn) then {
            format ["%1 - %2", _sideLabel, _dn]
        } else {
            format ["%1 - %2 (%3)", _sideLabel, _dn, _cn]
        };
        private _idx = _listCtrl lbAdd _label;
        _listCtrl lbSetData [_idx, _cn];
    } forEach _bucketEntries;
} forEach _sideBuckets;

// ---- Apply ticks function (called on init + every filter cycle) ----------
private _applyTicks = {
    params ["_disp"];
    private _list = _disp controlsGroupCtrl 100;
    if (isNull _list) exitWith {};
    private _per = _disp getVariable ["alive_perTier", createHashMap];
    private _tk  = _disp getVariable ["alive_tierKeys", []];
    private _idx = _disp getVariable ["alive_filterIdx", 0];
    if (_idx >= count _tk) exitWith {};
    private _activeTier = _tk select _idx;
    private _bucket = _per get _activeTier;
    if (isNil "_bucket") then { _bucket = [] };
    private _bucketLowerSet = createHashMap;
    { _bucketLowerSet set [toLower _x, true] } forEach _bucket;

    // Gate prevents LBSelChanged from mutating buckets during programmatic
    // tick application (every lbSetSelected fires the EH synchronously).
    _disp setVariable ["alive_populating", true];
    for "_i" from 0 to (lbSize _list - 1) do {
        private _data = _list lbData _i;
        if ((toLower _data) in _bucketLowerSet) then {
            _list lbSetSelected [_i, true];
        } else {
            _list lbSetSelected [_i, false];
        };
    };
    _disp setVariable ["alive_populating", false];
};

[_display] call _applyTicks;
[_display, _tierKeys select _filterIdx] call _refillOverride;

// ---- Wire FilterNext button (idc 1210) -----------------------------------
private _btn = _display controlsGroupCtrl 1210;
if (!isNull _btn) then {
    _btn setVariable ["alive_disp", _display];
    _btn setVariable ["alive_applyTicks", _applyTicks];
    _btn setVariable ["alive_absorbOverride", _absorbOverride];
    _btn setVariable ["alive_refillOverride", _refillOverride];
    _btn setVariable ["alive_logic", _logicObj];
    _btn setVariable ["alive_filterStateKey", _filterStateKey];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_b"];
        private _disp   = _b getVariable "alive_disp";
        private _apply  = _b getVariable "alive_applyTicks";
        private _absorb = _b getVariable "alive_absorbOverride";
        private _refill = _b getVariable "alive_refillOverride";
        private _logic  = _b getVariable "alive_logic";
        private _fKey   = _b getVariable "alive_filterStateKey";
        private _tk     = _disp getVariable ["alive_tierKeys", []];
        private _tl     = _disp getVariable ["alive_tierLabels", []];
        private _idx    = _disp getVariable ["alive_filterIdx", 0];
        // Absorb current Override Edit text into OLD active tier
        if (_idx < count _tk) then {
            [_disp, _tk select _idx] call _absorb;
        };
        // Cycle filter
        _idx = (_idx + 1) mod (count _tl);
        _disp setVariable ["alive_filterIdx", _idx];
        private _label = _disp controlsGroupCtrl 1200;
        if (!isNull _label) then {
            _label ctrlSetText format ["Tier: %1", _tl select _idx];
        };
        if (!isNull _logic && {!isNil "_fKey"} && {_fKey != ""}) then {
            _logic setVariable [_fKey, _idx];
        };
        // Re-apply ticks for new tier + refill Override Edit
        [_disp] call _apply;
        if (_idx < count _tk) then {
            [_disp, _tk select _idx] call _refill;
        };
    }];
};

// ---- Wire LBSelChanged - mutate ONLY current tier's bucket ---------------
_listCtrl setVariable ["alive_disp", _display];
_listCtrl ctrlAddEventHandler ["LBSelChanged", {
    params ["_lb"];
    private _disp = _lb getVariable "alive_disp";
    if (_disp getVariable ["alive_populating", false]) exitWith {};
    private _per = _disp getVariable ["alive_perTier", createHashMap];
    private _tk  = _disp getVariable ["alive_tierKeys", []];
    private _idx = _disp getVariable ["alive_filterIdx", 0];
    if (_idx >= count _tk) exitWith {};
    private _activeTier = _tk select _idx;
    private _bucket = _per get _activeTier;
    if (isNil "_bucket") exitWith {};

    // Rebuild the bucket: keep entries NOT in the listbox (Override-only
    // mod factions); re-add ticked entries from the listbox.
    private _ents = _disp getVariable ["alive_entries", []];
    private _entriesLowerSet = createHashMap;
    { _entriesLowerSet set [toLower (_x select 0), true] } forEach _ents;
    private _newBucket = [];
    {
        if !((toLower _x) in _entriesLowerSet) then { _newBucket pushBackUnique _x };
    } forEach _bucket;
    private _selIdx = lbSelection _lb;
    {
        private _data = _lb lbData _x;
        if (typeName _data == "STRING" && {_data != ""}) then {
            _newBucket pushBackUnique _data;
        };
    } forEach _selIdx;
    _per set [_activeTier, _newBucket];
}];

[
    "ALIVE FactionTierChoice LOAD: consolidated='%1' sqm='%2' tiers=%3 perTier=%4 entries=%5 filter=%6",
    _consolidatedRaw, _sqmValue, _tierLabels, _perTier, count _entries, _tierLabels select _filterIdx
] call ALiVE_fnc_dump;
