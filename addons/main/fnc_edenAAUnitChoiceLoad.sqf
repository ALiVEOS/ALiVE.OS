#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenAAUnitChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenAAUnitChoiceLoad

Description:
    Eden attributeLoad handler for ALiVE_AAUnitChoiceMulti. Multi-select
    listbox of faction AA-shape vehicle classes (from CfgVehicles via
    fnc_listFactionAAUnits) with single-axis Role filter and free-text
    override field.

    Storage shape: comma-separated classnames on a single logic variable
    (default "aaClasses"). Empty value means "use faction default AA list
    from ALIVE_factionDefaultAA at runtime".

    Filter cycle (idc 1210 button): All / Vehicle / Static. "All"
    surfaces every faction AA unit; Vehicle / Static narrow to the
    role classification from fnc_listFactionAAUnits.

    Selection-set management mirrors the composition picker - cumulative
    selection on the controlsGroup namespace via `alive_selectedClasses`
    so cycling the filter doesn't drop ticks for non-visible roles. Gate
    flag `alive_populating` blocks LBSelChanged from mutating state
    during programmatic re-tick.

Parameters:
    [_display, _varName, _factionVar, _titleStr, _sqmValue]
    _display     : DISPLAY - controlsGroup display
    _varName     : STRING  - logic variable (default "aaClasses")
    _factionVar  : STRING  - logic variable holding the module's faction
                             (e.g. "faction")
    _titleStr    : STRING  - localised title text or $STR_ key
    _sqmValue    : STRING  - SQM-deserialised value (Cfg3DEN's `_value`)

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "aaClasses";
private _factionVar = "faction";
private _titleStr = "AA Units:";
private _sqmValue = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _varName = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _factionVar = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _titleStr = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _sqmValue = _this select 4; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE AAUnitChoice LOAD: null display";
};

// Title
private _titleResolved = _titleStr;
if (count _titleStr > 0 && {(_titleStr select [0, 1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then { _titleCtrl ctrlSetText _titleResolved };

// Resolve module faction
private _selectedLogic = get3DENSelected "logic";
private _logicObj = if (count _selectedLogic > 0) then { _selectedLogic select 0 } else { objNull };

private _faction = "";
if (!isNull _logicObj && {_factionVar != ""}) then {
    private _f = _logicObj getVariable [_factionVar, ""];
    if (typeName _f == "STRING") then { _faction = _f };
};
if (_faction == "") then { _faction = "BLU_F" };

// Resolve stored selection (priority: SQM > logic var > "")
private _storedFromLogic = if (!isNull _logicObj) then {
    _logicObj getVariable [_varName, nil]
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
if (_sqmValue != "") then { _value = _sqmValue };

// Parse stored CSV into selection set
private _selectedClasses = [];
if (_value != "") then {
    private _trimmed = _value;
    while {count _trimmed > 0 && {(_trimmed select [0, 1]) == " "}} do { _trimmed = _trimmed select [1] };
    while {count _trimmed > 0 && {(_trimmed select [count _trimmed - 1, 1]) == " "}} do {
        _trimmed = _trimmed select [0, count _trimmed - 1];
    };
    {
        private _t = _x;
        while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
        while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
        if (_t != "") then { _selectedClasses pushBackUnique _t };
    } forEach ([_trimmed, ","] call CBA_fnc_split);
};

// Get faction's AA units via feeder. Direct compile + invoke instead
// of `call ALiVE_fnc_listFactionAAUnits` because cfgFunctions addon-fn
// registrations don't reliably propagate to 3DEN editor context;
// fnc_listFactionVehicleClasses uses the same workaround for its
// dependencies.
private _aaUnits = [_faction] call compile preprocessFileLineNumbers "\x\alive\addons\main\fnc_listFactionAAUnits.sqf";
if (typeName _aaUnits != "ARRAY") then { _aaUnits = [] };

// Filter options: All + roles seen in the data
private _rolesPresent = [];
{ _rolesPresent pushBackUnique (_x select 3) } forEach _aaUnits;
_rolesPresent sort true;
private _filterOptions = ["All"] + _rolesPresent;

// Filter state persistence keyed on varName
private _filterStateKey = format ["%1_filterIdx", _varName];
private _filterIdx = 0;
if (!isNull _logicObj) then {
    private _saved = _logicObj getVariable [_filterStateKey, nil];
    if (!isNil "_saved" && {typeName _saved == "SCALAR"}) then { _filterIdx = _saved };
};
if (_filterIdx >= count _filterOptions) then { _filterIdx = 0 };

// Stash on namespace
_display setVariable ["alive_aaUnits", _aaUnits];
_display setVariable ["alive_selectedClasses", _selectedClasses];
_display setVariable ["alive_filterOptions", _filterOptions];
_display setVariable ["alive_filterIdx", _filterIdx];

// Update FilterLabel
private _filterLabel = _display controlsGroupCtrl 1200;
if (!isNull _filterLabel) then {
    _filterLabel ctrlSetText format ["Role: %1", _filterOptions select _filterIdx];
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    diag_log "ALIVE AAUnitChoice LOAD: listbox (IDC 100) not found";
};

// Populate function (closes over _display)
private _populateFn = {
    params ["_disp"];
    private _all   = _disp getVariable ["alive_aaUnits", []];
    private _sel   = _disp getVariable ["alive_selectedClasses", []];
    private _fOpts = _disp getVariable ["alive_filterOptions", ["All"]];
    private _fIdx  = _disp getVariable ["alive_filterIdx", 0];
    private _filter = _fOpts select _fIdx;
    private _list = _disp controlsGroupCtrl 100;
    if (isNull _list) exitWith {};

    _disp setVariable ["alive_populating", true];
    lbClear _list;

    // Variant tag derivation: when multiple entries share the same
    // displayName (e.g. four RHS Stinger pods all read "FIM-92F (DMS)"
    // because RHS gives the same display to every camo / branch
    // variant), strip the longest common classname prefix from each
    // and use the remainder as a [tag] appended to the visible name.
    // Singleton displays (no shared name) get no tag.
    private _displayGroups = createHashMap;
    {
        private _d = _x select 1;
        private _c = _x select 0;
        private _bucket = if (_d in _displayGroups) then { _displayGroups get _d } else { [] };
        _bucket pushBack _c;
        _displayGroups set [_d, _bucket];
    } forEach _all;

    private _variantTags = createHashMap;
    {
        private _classesInGroup = _displayGroups get _x;
        if (count _classesInGroup > 1) then {
            private _prefArr = toArray (_classesInGroup select 0);
            {
                private _otherArr = toArray _x;
                private _maxLen = (count _prefArr) min (count _otherArr);
                private _newLen = 0;
                for "_i" from 0 to (_maxLen - 1) do {
                    if ((_prefArr select _i) != (_otherArr select _i)) exitWith {};
                    _newLen = _i + 1;
                };
                _prefArr = _prefArr select [0, _newLen];
            } forEach _classesInGroup;
            private _prefLen = count _prefArr;
            {
                private _c = _x;
                private _tag = _c select [_prefLen];
                if ((count _tag > 0) && {(_tag select [0, 1]) == "_"}) then {
                    _tag = _tag select [1];
                };
                _variantTags set [toLower _c, _tag];
            } forEach _classesInGroup;
        };
    } forEach (keys _displayGroups);

    private _selLowerSet = createHashMap;
    { _selLowerSet set [toLower _x, true] } forEach _sel;

    // Surface unrecognised entries (selected classes not in the
    // faction's AA list) at the top with "(unrecognised)" prefix
    private _allClassesLower = createHashMap;
    { _allClassesLower set [toLower (_x select 0), true] } forEach _all;
    {
        if !((toLower _x) in _allClassesLower) then {
            private _idx = _list lbAdd format ["(unrecognised) %1", _x];
            _list lbSetData [_idx, _x];
            _list lbSetSelected [_idx, true];
        };
    } forEach _sel;

    // Filter rows by role
    private _matched = if (_filter == "All") then { _all } else {
        _all select { (_x select 3) == _filter }
    };

    // Group by source mod, alphabetical within
    private _sources = [];
    { _sources pushBackUnique (_x select 5) } forEach _matched;
    _sources sort true;

    {
        private _src = _x;
        private _bucket = _matched select { (_x select 5) == _src };
        _bucket sort true;
        {
            _x params ["_class", "_display", "_side", "_role", "_category", ""];
            // Classname first so its variant suffix stays visible
            // through listbox truncation, plus an auto-derived [tag]
            // on the displayName when entries share a name (see
            // variant-tag computation above).
            private _displayLabel = _display;
            if ((toLower _class) in _variantTags) then {
                private _tag = _variantTags get (toLower _class);
                if (_tag != "") then { _displayLabel = format ["%1 [%2]", _display, _tag] };
            };
            private _label = format ["%1 | %2 [%3] %4", _class, _displayLabel, _role, _src];
            private _idx = _list lbAdd _label;
            _list lbSetData [_idx, _class];
            if ((toLower _class) in _selLowerSet) then {
                _list lbSetSelected [_idx, true];
            };
        } forEach _bucket;
    } forEach _sources;

    _disp setVariable ["alive_populating", false];
};

[_display] call _populateFn;

// Override Edit pre-fill: nothing (unrecognised entries surface in
// listbox); user types new mod classes here for missing entries
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then { _editCtrl ctrlSetText "" };

// Wire FilterNext button
private _btn = _display controlsGroupCtrl 1210;
if (!isNull _btn) then {
    _btn setVariable ["alive_disp", _display];
    _btn setVariable ["alive_populateFn", _populateFn];
    _btn setVariable ["alive_logic", _logicObj];
    _btn setVariable ["alive_filterStateKey", _filterStateKey];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_b"];
        private _disp = _b getVariable "alive_disp";
        private _pop  = _b getVariable "alive_populateFn";
        private _logic = _b getVariable "alive_logic";
        private _fKey = _b getVariable "alive_filterStateKey";
        private _opts = _disp getVariable ["alive_filterOptions", ["All"]];
        private _idx  = _disp getVariable ["alive_filterIdx", 0];
        _idx = (_idx + 1) mod (count _opts);
        _disp setVariable ["alive_filterIdx", _idx];
        private _label = _disp controlsGroupCtrl 1200;
        if (!isNull _label) then { _label ctrlSetText format ["Role: %1", _opts select _idx]; };
        if (!isNull _logic && {!isNil "_fKey"} && {_fKey != ""}) then {
            _logic setVariable [_fKey, _idx];
        };
        [_disp] call _pop;
    }];
};

// Wire LBSelChanged to keep selection set in sync
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

diag_log format [
    "ALIVE AAUnitChoice LOAD: varName='%1' faction='%2' sqm='%3' aaUnits=%4 selected=%5",
    _varName, _faction, _sqmValue, count _aaUnits, count _selectedClasses
];
