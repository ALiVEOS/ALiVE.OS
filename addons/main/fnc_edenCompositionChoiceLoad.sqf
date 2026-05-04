#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenCompositionChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenCompositionChoiceLoad

Description:
    Eden-attribute `attributeLoad` handler for the ALiVE_CompositionChoice
    control. Populates Side / Size / Category filter rows, sets up the
    ButtonClick + LBSelChanged handlers that drive the reactive listbox,
    and ticks rows that match the saved value.

    Filter rows use the FactionStaticDataChoice button-cycle pattern -
    a label showing the current filter value + a "Next >" button that
    cycles through the available options. Filtering uses 5-tuples
    [class, display, side, size, category] from listFactionCompositions.

    Storage format on the logic / SQM (unchanged):
        Class1,Class2,Class3
    Empty value = no compositions selected. Legacy single-class strings
    round-trip cleanly.

    State stored on the controlsGroup via setVariable so the button-click
    handlers can re-read it without re-running the feeder:
        _allComps           - full feeder result (5-tuples)
        _selectedClasses    - class names the user has ticked (preserved
                              across filter changes, because LBSelChanged
                              only knows about currently-visible rows)
        _sideOptions        - ["All", side1, side2, ...]
        _sizeOptions        - ["All", "Large", "Medium", "Small", ...]
        _categoryOptions    - ["All", "Camps", "Outposts", ...]
        _sideIdx / _sizeIdx / _categoryIdx - current filter indices

Parameters:
    [_display, _varName, _factionVar, _titleStr, _sqmValue, _categoryPatterns, _categoryDisplayLabel]
    _display              : DISPLAY - Eden attribute display (controls-group)
    _varName              : STRING  - logic-variable name of the composition attribute
                                      (e.g. "composition")
    _factionVar           : STRING  - logic-variable name of the module's faction
                                      attribute (e.g. "faction")
    _titleStr             : STRING  - localised title text or $STR_ key
    _sqmValue             : STRING  - SQM-deserialised value (Cfg3DEN's `_value`)
    _categoryPatterns     : STRING  - optional. Comma-separated substring patterns
                                      (case-insensitive) used to HARD-FILTER the
                                      listbox to a category family. Empty string =
                                      no filter (full Category cycle remains active).
                                      For the roadblock picker pass e.g.
                                      "checkpoint,barricade,roadblock" so 3rd-party
                                      mod compositions whose category names don't
                                      exactly match the BIS "CheckpointsBarricades"
                                      label still surface.
    _categoryDisplayLabel : STRING  - optional. Display label shown in the locked
                                      Category row. Defaults to `_categoryPatterns`
                                      itself (fine for single-pattern locks); per-
                                      module wrappers pass a friendly name when the
                                      pattern list contains multiple keywords
                                      (e.g. "Roadblocks").

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "";
private _factionVar = "";
private _titleStr = "Compositions:";
private _sqmValue = "";
private _categoryPatterns = "";
private _categoryDisplayLabel = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _varName = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _factionVar = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _titleStr = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _sqmValue = _this select 4; };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"}) then { _categoryPatterns = _this select 5; };
    if (count _this > 6 && {typeName (_this select 6) == "STRING"}) then { _categoryDisplayLabel = _this select 6; };
} else {
    _display = _this;
};

// Display label defaults to the pattern string itself when not supplied -
// fine when the lock is a single exact category (legacy MPCustom case
// passing nothing at all leaves _categoryPatterns "" and the lock is
// inactive entirely).
if (_categoryDisplayLabel == "") then { _categoryDisplayLabel = _categoryPatterns };

if (isNull _display) exitWith {
    diag_log "ALIVE CompositionChoice LOAD: null display";
};

// Title text (left-col).
private _titleResolved = _titleStr;
if (count _titleStr > 0 && {(_titleStr select [0, 1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then { _titleCtrl ctrlSetText _titleResolved; };

// Read module's currently-selected faction.
private _selected = get3DENSelected "logic";
private _logicObj = if (count _selected > 0) then { _selected select 0 } else { objNull };

private _faction = "";
if (!isNull _logicObj && {_factionVar != ""}) then {
    private _f = _logicObj getVariable [_factionVar, ""];
    if (typeName _f == "STRING") then { _faction = _f };
};
if (_faction == "") then { _faction = "BLU_F" };

// Stored composition value resolution (priority: SQM > logic var > "")
private _storedFromLogic = if (!isNull _logicObj && {_varName != ""}) then {
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
if (_sqmValue != "") then {
    _value = _sqmValue;
};

// Stored format may include a filter-state prefix:
//     [F:sideIdx,sizeIdx,categoryIdx,sourceIdx]Class1,Class2,...
// The prefix persists the picker's filter state across mission save/reload
// (the picker's setVariable on the logic is session-only). Legacy missions
// stored without the prefix get default filters (all "All").
private _value_classes = _value;
private _persistedFilters = nil;
if (count _value > 3 && {(_value select [0, 3]) == "[F:"}) then {
    private _closeIdx = _value find "]";
    if (_closeIdx > 3) then {
        private _filterPart = _value select [3, _closeIdx - 3];
        private _filterArr = [];
        {
            private _n = parseNumber _x;
            _filterArr pushBack _n;
        } forEach ([_filterPart, ","] call CBA_fnc_split);
        if (count _filterArr == 4) then { _persistedFilters = _filterArr };
        _value_classes = _value select [_closeIdx + 1];
    };
};

// Parse class CSV (post-prefix) into a deduped list. Trims surrounding whitespace.
private _selectedClasses = [];
if (_value_classes != "") then {
    {
        private _t = _x;
        while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
        while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
        if (_t != "") then { _selectedClasses pushBackUnique _t };
    } forEach ([_value_classes, ","] call CBA_fnc_split);
};

// Get all compositions for the faction (5-tuples).
private _allComps = [_faction] call compile preprocessFileLineNumbers "\x\alive\addons\main\fnc_listFactionCompositions.sqf";
if (typeName _allComps != "ARRAY") then { _allComps = [] };

// Hard category lock. When the per-module subclass passes a category
// pattern list (e.g. "checkpoint,barricade,roadblock" for roadblock
// picker), the listbox MUST never surface compositions outside that
// family - it's not a "default view" hint, it's a domain restriction.
// Substring match (case-insensitive) so 3rd-party mods whose category
// names don't exactly match BIS labels still surface (e.g. a mod's
// "INS_Checkpoints" matches the "checkpoint" pattern). Filter the
// feeder result here so every downstream option list (Side / Size /
// Source) only enumerates values present in the locked subset, and
// the Category cycle becomes a no-op showing just the display label.
if (_categoryPatterns != "") then {
    private _patterns = [];
    {
        _patterns pushBack (toLower _x);
    } forEach ([_categoryPatterns, ","] call CBA_fnc_split);
    private _preCount = count _allComps;
    private _categoriesSeen = [];
    {
        _categoriesSeen pushBackUnique (_x select 4);
    } forEach _allComps;
    private _filtered = [];
    {
        private _comp = _x;
        private _cat = toLower (_comp select 4);
        private _matched = false;
        {
            if (_cat find _x >= 0) exitWith { _matched = true };
        } forEach _patterns;
        if (_matched) then { _filtered pushBack _comp };
    } forEach _allComps;
    _allComps = _filtered;
    diag_log format ["ALIVE CompositionChoice CategoryFilter: patterns=%1 preCount=%2 postCount=%3 categoriesSeen=%4", _patterns, _preCount, count _allComps, _categoriesSeen];
};

// Auto-upgrade legacy class-only entries in _selectedClasses to fully
// qualified `class|category|size` keys.
//
// Two-pass to handle "mixed save" cases left behind by the bug fix
// rollout: a save can contain BOTH a legacy `Checkpoint_BLU_F` entry
// AND qualified `Checkpoint_BLU_F|...|Medium` / `|...|Small` entries
// in the same string. The user's last explicit action was per-variant
// (qualified), and the legacy entry is leftover noise from a save made
// before per-variant selection landed.
//
// Pass 1 collects the set of classes that already have qualified
// entries.
// Pass 2 processes each entry:
//   - Qualified -> keep
//   - Legacy, class has qualified entries -> DROP (qualified wins)
//   - Legacy, class has no qualified entries -> expand into qualified
//     keys for every matching row in _allComps (preserves old "all
//     variants" semantic for clean legacy saves)
//   - Legacy, no matching row in _allComps -> keep legacy (mod not
//     loaded this session; Override Edit will surface it)
private _classesWithQualified = [];
{
    private _pipeIdx = _x find "|";
    if (_pipeIdx > 0) then {
        _classesWithQualified pushBackUnique (_x select [0, _pipeIdx]);
    };
} forEach _selectedClasses;

private _upgradedSelected = [];
{
    private _entry = _x;
    private _pipeIdx = _entry find "|";
    if (_pipeIdx > 0) then {
        _upgradedSelected pushBackUnique _entry;
    } else {
        private _legacyClass = _entry;
        if (_legacyClass in _classesWithQualified) then {
            // Drop - the qualified entries for this class are
            // authoritative; the legacy is leftover from a save made
            // before per-variant selection was wired up.
        } else {
            private _expanded = false;
            {
                _x params ["_class", "", "", "_size", "_category"];
                if (_class == _legacyClass) then {
                    private _sizeKey = if (_size == "") then { "Unspecified" } else { _size };
                    _upgradedSelected pushBackUnique (format ["%1|%2|%3", _class, _category, _sizeKey]);
                    _expanded = true;
                };
            } forEach _allComps;
            if (!_expanded) then { _upgradedSelected pushBackUnique _legacyClass };
        };
    };
} forEach _selectedClasses;
_selectedClasses = _upgradedSelected;

// Build filter option lists from the data. "All" is always the first option.
// Note: avoid `_display` as a destructure name here - it would shadow the
// outer-scope `_display` (controlsGroup control), and even though `params`
// is scope-local in theory, the SQF engine has been observed to leak the
// shadow into surrounding code when the forEach iterator is the same scope
// the outer var lives in. Use `_dispName` for the tuple's display-name slot.
private _sidesPresent = [];
private _sizesPresent = [];
private _categoriesPresent = [];
private _sourcesPresent = [];
{
    _x params ["_class", "_dispName", "_side", "_size", "_category", "_source"];
    _sidesPresent pushBackUnique _side;
    _sizesPresent pushBackUnique (if (_size == "") then { "Unspecified" } else { _size });
    _categoriesPresent pushBackUnique _category;
    _sourcesPresent pushBackUnique _source;
} forEach _allComps;

_sidesPresent sort true;
_sizesPresent sort true;
_categoriesPresent sort true;
_sourcesPresent sort true;

private _sideOptions = ["All"] + _sidesPresent;
private _sizeOptions = ["All"] + _sizesPresent;
// When the picker is category-locked (roadblock picker, etc.), drop
// "All" from the Category options so the displayed value reads as the
// locked category display label itself rather than "Category: All".
// Cycling has nothing to advance to, which is the intended UX -
// telling the user "this picker is roadblocks-only, that's it".
private _categoryOptions = if (_categoryPatterns != "") then {
    [_categoryDisplayLabel]
} else {
    ["All"] + _categoriesPresent
};
private _sourceOptions = ["All"] + _sourcesPresent;

// Filter state persistence cascade:
//   1. SQM-persisted prefix (parsed above into _persistedFilters) - survives
//      mission save/reload because it lives in the composition CSV which IS
//      a Cfg3DEN attribute Eden serialises.
//   2. Logic-namespace getVariable - session-scoped, survives Eden dialog
//      close/open within the same session (faster + simpler than re-reading
//      the SQM each time).
//   3. Default [0,0,0,0] (all "All") on first open with no prior state.
private _filterStateKey = format ["%1_filterState", _varName];
private _savedFilters = nil;
if (!isNil "_persistedFilters") then {
    _savedFilters = _persistedFilters;
} else {
    if (!isNull _logicObj) then {
        private _sessionFilters = _logicObj getVariable [_filterStateKey, nil];
        if (!isNil "_sessionFilters" && {typeName _sessionFilters == "ARRAY"} && {count _sessionFilters >= 4}) then {
            _savedFilters = _sessionFilters;
        };
    };
};
if (isNil "_savedFilters") then { _savedFilters = [0, 0, 0, 0] };
// When the picker is category-locked, force the Category index to 0
// regardless of any saved filter prefix - the locked options array
// only has one entry. Pre-lock missions saved with e.g. [F:0,0,2,0]
// would otherwise clamp downstream but going through this branch
// keeps intent explicit.
if (_categoryPatterns != "") then { _savedFilters set [2, 0] };

private _sideIdx     = _savedFilters select 0;
private _sizeIdx     = _savedFilters select 1;
private _categoryIdx = _savedFilters select 2;
private _sourceIdx   = _savedFilters select 3;
// Clamp indices in case the option lists shrunk between sessions (e.g.
// faction changed and removed a previously-available source mod).
if (_sideIdx     >= count _sideOptions)     then { _sideIdx = 0 };
if (_sizeIdx     >= count _sizeOptions)     then { _sizeIdx = 0 };
if (_categoryIdx >= count _categoryOptions) then { _categoryIdx = 0 };
if (_sourceIdx   >= count _sourceOptions)   then { _sourceIdx = 0 };

// Stash state on the controlsGroup for the button-click handlers.
_display setVariable ["alive_allComps", _allComps];
_display setVariable ["alive_selectedClasses", _selectedClasses];
_display setVariable ["alive_sideOptions", _sideOptions];
_display setVariable ["alive_sizeOptions", _sizeOptions];
_display setVariable ["alive_categoryOptions", _categoryOptions];
_display setVariable ["alive_sourceOptions", _sourceOptions];
_display setVariable ["alive_sideIdx", _sideIdx];
_display setVariable ["alive_sizeIdx", _sizeIdx];
_display setVariable ["alive_categoryIdx", _categoryIdx];
_display setVariable ["alive_sourceIdx", _sourceIdx];
// Lock flag: signals to populate that the category filter has already
// been applied at feeder pre-filter time (substring patterns), so the
// per-row exact-match _passCat check should pass-through. Without this
// flag, populate rejects every row whose actual `_category` doesn't
// equal the display label string (e.g. real category
// "CheckpointsBarricades" vs display label "Roadblocks").
_display setVariable ["alive_categoryLocked", (_categoryPatterns != "")];

// Update the filter labels with their current values.
private _sideLabel     = _display controlsGroupCtrl 1200;
private _sizeLabel     = _display controlsGroupCtrl 1201;
private _categoryLabel = _display controlsGroupCtrl 1202;
private _sourceLabel   = _display controlsGroupCtrl 1203;
if (!isNull _sideLabel)     then { _sideLabel     ctrlSetText format ["Side: %1",     _sideOptions     select _sideIdx];     };
if (!isNull _sizeLabel)     then { _sizeLabel     ctrlSetText format ["Size: %1",     _sizeOptions     select _sizeIdx];     };
if (!isNull _categoryLabel) then { _categoryLabel ctrlSetText format ["Category: %1", _categoryOptions select _categoryIdx]; };
if (!isNull _sourceLabel)   then { _sourceLabel   ctrlSetText format ["Source: %1",   _sourceOptions   select _sourceIdx];   };

// Filter+populate function (closes over _display via the EH that calls it).
private _populateFn = {
    params ["_disp"];
    private _all       = _disp getVariable ["alive_allComps", []];
    private _sel       = _disp getVariable ["alive_selectedClasses", []];
    private _sOpts     = _disp getVariable ["alive_sideOptions", ["All"]];
    private _zOpts     = _disp getVariable ["alive_sizeOptions", ["All"]];
    private _cOpts     = _disp getVariable ["alive_categoryOptions", ["All"]];
    private _mOpts     = _disp getVariable ["alive_sourceOptions", ["All"]];
    private _sIdx      = _disp getVariable ["alive_sideIdx", 0];
    private _zIdx      = _disp getVariable ["alive_sizeIdx", 0];
    private _cIdx      = _disp getVariable ["alive_categoryIdx", 0];
    private _mIdx      = _disp getVariable ["alive_sourceIdx", 0];
    private _catLocked = _disp getVariable ["alive_categoryLocked", false];
    private _sFilt     = _sOpts select _sIdx;
    private _zFilt     = _zOpts select _zIdx;
    private _cFilt     = _cOpts select _cIdx;
    private _mFilt     = _mOpts select _mIdx;

    private _list = _disp controlsGroupCtrl 100;
    if (isNull _list) exitWith {};
    // Gate the LBSelChanged handler. Each lbSetSelected call below
    // fires LBSelChanged synchronously, which reads partial selection
    // state and would incorrectly remove classes that haven't been
    // re-ticked yet. The gate makes LBSelChanged a no-op for
    // programmatic ticks; only genuine user clicks (with the gate
    // off) update the cumulative selection set.
    _disp setVariable ["alive_populating", true];
    lbClear _list;

    private _surfaced = 0;
    private _ticked   = 0;
    {
        _x params ["_class", "_dispName", "_side", "_size", "_category", "_source"];
        private _sizeKey = if (_size == "") then { "Unspecified" } else { _size };
        private _passSide   = (_sFilt == "All") || (_side     == _sFilt);
        private _passSize   = (_zFilt == "All") || (_sizeKey  == _zFilt);
        // _catLocked: feeder pre-filter already restricted _allComps
        // to the matching category family (substring patterns); skip
        // the exact-match per-row check so e.g. real category
        // "CheckpointsBarricades" passes when the display label is
        // "Roadblocks".
        private _passCat    = _catLocked || (_cFilt == "All") || (_category == _cFilt);
        private _passSource = (_mFilt == "All") || (_source   == _mFilt);

        if (_passSide && _passSize && _passCat && _passSource) then {
            private _sizeLabel = if (_size == "") then { "?" } else { _size };
            private _label = if (_dispName != _class) then {
                format ["%1 [%2/%3] (%4) {%5}", _dispName, _side, _sizeLabel, _class, _source]
            } else {
                format ["%1 [%2/%3] {%4}", _class, _side, _sizeLabel, _source]
            };
            private _idx = _list lbAdd _label;
            // Qualified key `class|category|size` lets size variants of
            // the same class (e.g. BIS Checkpoint_BLU_F appears 3x in
            // CfgGroups under CheckpointsBarricadesLarge / Medium /
            // Small) be selected independently. Class-only storage was
            // ambiguous - selecting Large would tick all 3 size variants
            // on reload. lbData is what LBSelChanged + SAVE both read,
            // so qualifying it here propagates everywhere.
            private _qKey = format ["%1|%2|%3", _class, _category, _sizeKey];
            _list lbSetData [_idx, _qKey];
            _surfaced = _surfaced + 1;
            // Exact qualified-key match only. The auto-upgrade pass at
            // LOAD time has already expanded any legacy class-only
            // entries into qualified keys, so a bare-class match here
            // would only re-introduce the wildcard bug it was meant to
            // patch around (legacy entry ticking all size variants of
            // the same class).
            if (_qKey in _sel) then {
                _list lbSetSelected [_idx, true];
                _ticked = _ticked + 1;
            };
        };
    } forEach _all;

    diag_log format ["ALIVE CompositionChoice POPULATE: side=%1 size=%2 category=%3 source=%4 surfaced=%5 ticked=%6", _sFilt, _zFilt, _cFilt, _mFilt, _surfaced, _ticked];
    // Re-open the LBSelChanged gate. From here on, any selection
    // change is a genuine user click and SHOULD mutate _sel.
    _disp setVariable ["alive_populating", false];
};

// Initial population (All/All/All).
[_display] call _populateFn;

// Override-Edit pre-fill: any saved class not in _allComps goes here.
// Saved entries can be qualified (`class|category|size`) or legacy
// (class-only). Extract the class portion either way before checking
// against the registry. Missing entries are surfaced as their original
// (qualified or legacy) string so the user can edit them directly.
private _allClassesInData = [];
{ _allClassesInData pushBackUnique (_x select 0); } forEach _allComps;
private _missing = [];
{
    private _entry = _x;
    private _classPart = _entry;
    private _pipeIdx = _entry find "|";
    if (_pipeIdx > 0) then { _classPart = _entry select [0, _pipeIdx] };
    if !(_classPart in _allClassesInData) then { _missing pushBackUnique _entry };
} forEach _selectedClasses;
private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then {
    _editCtrl ctrlSetText (_missing joinString ",");
};

// Wire button-click handlers for each filter row. Each click cycles the
// filter index, updates the label, persists the new state to the logic
// (session-scoped), and re-runs the populate function.
private _attachCycle = {
    params ["_btnIdc", "_labelIdc", "_idxKey", "_optsKey", "_labelPrefix"];
    private _btn = _display controlsGroupCtrl _btnIdc;
    if (isNull _btn) exitWith {};
    _btn setVariable ["alive_disp",        _display];
    _btn setVariable ["alive_labelIdc",    _labelIdc];
    _btn setVariable ["alive_idxKey",      _idxKey];
    _btn setVariable ["alive_optsKey",     _optsKey];
    _btn setVariable ["alive_labelPrefix", _labelPrefix];
    _btn setVariable ["alive_populateFn",  _populateFn];
    _btn setVariable ["alive_logic",       _logicObj];
    _btn setVariable ["alive_filterStateKey", _filterStateKey];
    _btn ctrlAddEventHandler ["ButtonClick", {
        params ["_b"];
        private _disp        = _b getVariable "alive_disp";
        private _labelIdc    = _b getVariable "alive_labelIdc";
        private _idxKey      = _b getVariable "alive_idxKey";
        private _optsKey     = _b getVariable "alive_optsKey";
        private _labelPrefix = _b getVariable "alive_labelPrefix";
        private _populateFn  = _b getVariable "alive_populateFn";
        private _logic       = _b getVariable "alive_logic";
        private _filterKey   = _b getVariable "alive_filterStateKey";
        private _opts = _disp getVariable [_optsKey, ["All"]];
        private _idx  = _disp getVariable [_idxKey, 0];
        _idx = (_idx + 1) mod (count _opts);
        _disp setVariable [_idxKey, _idx];
        private _label = _disp controlsGroupCtrl _labelIdc;
        if (!isNull _label) then { _label ctrlSetText format ["%1: %2", _labelPrefix, _opts select _idx]; };
        // Persist the full 4-tuple filter state on the logic.
        if (!isNull _logic && {!isNil "_filterKey"}) then {
            _logic setVariable [_filterKey, [
                _disp getVariable ["alive_sideIdx",     0],
                _disp getVariable ["alive_sizeIdx",     0],
                _disp getVariable ["alive_categoryIdx", 0],
                _disp getVariable ["alive_sourceIdx",   0]
            ]];
        };
        [_disp] call _populateFn;
    }];
};
[1210, 1200, "alive_sideIdx",     "alive_sideOptions",     "Side"]     call _attachCycle;
[1211, 1201, "alive_sizeIdx",     "alive_sizeOptions",     "Size"]     call _attachCycle;
[1212, 1202, "alive_categoryIdx", "alive_categoryOptions", "Category"] call _attachCycle;
[1213, 1203, "alive_sourceIdx",   "alive_sourceOptions",   "Source"]   call _attachCycle;

// When category is hard-locked, the Category row is dead UI - cycling
// has nothing to advance to and the picker context (e.g. "Roadblock
// Compositions:" Eden label) already implies the lock. Hide the label
// and Next button, then reflow the layout: Source row shifts up to
// the freed slot, and the listbox grows upward to claim the recovered
// 5 grid units. Override row at y=63 stays put.
//
// Reflow uses ctrlSetPosition + ctrlCommit at runtime rather than
// touching the shared base's positions in CfgVehicles, so the camp
// picker variant (which doesn't lock and needs all 4 filter rows
// visible) is unaffected.
if (_categoryPatterns != "") then {
    private _catLabel    = _display controlsGroupCtrl 1202;
    private _catBtn      = _display controlsGroupCtrl 1212;
    private _sourceLabel = _display controlsGroupCtrl 1203;
    private _sourceBtn   = _display controlsGroupCtrl 1213;
    private _listbox     = _display controlsGroupCtrl 100;

    if (!isNull _catLabel) then { _catLabel ctrlShow false };
    if (!isNull _catBtn)   then { _catBtn   ctrlShow false };

    // 5 grid units = same delta the Category row used. Use the same
    // pixel-grid math the CfgVehicles definitions use so positions
    // stay aligned with the rest of the layout.
    private _shift = 5 * (pixelH * pixelGrid * 0.5);
    {
        if (!isNull _x) then {
            private _pos = ctrlPosition _x;
            _pos set [1, (_pos select 1) - _shift];
            _x ctrlSetPosition _pos;
            _x ctrlCommit 0;
        };
    } forEach [_sourceLabel, _sourceBtn];

    if (!isNull _listbox) then {
        private _pos = ctrlPosition _listbox;
        _pos set [1, (_pos select 1) - _shift];
        _pos set [3, (_pos select 3) + _shift];
        _listbox ctrlSetPosition _pos;
        _listbox ctrlCommit 0;
    };
};

// Wire LBSelChanged on the listbox to keep _selectedClasses in sync with
// user clicks. Only updates classes for currently-visible rows; classes
// from previously-filtered views remain in the set.
private _list = _display controlsGroupCtrl 100;
if (!isNull _list) then {
    _list setVariable ["alive_disp", _display];
    _list ctrlAddEventHandler ["LBSelChanged", {
        params ["_lb"];
        private _disp = _lb getVariable "alive_disp";
        // Gate: ignore programmatic selection changes during populate.
        // _populateFn flips this off after re-ticking is complete.
        if (_disp getVariable ["alive_populating", false]) exitWith {};
        private _sel  = _disp getVariable ["alive_selectedClasses", []];
        private _selIdx = lbSelection _lb;
        // For each currently-visible row, sync its class membership in _sel.
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
        diag_log format ["ALIVE CompositionChoice LBSelChanged: visible=%1 selectedRows=%2 cumulative=%3", lbSize _lb, count _selIdx, count _sel];
    }];
};

diag_log format [
    "ALIVE CompositionChoice LOAD: varName=%1 faction=%2 sqm='%3' resolved='%4' allComps=%5 sides=%6 sizes=%7 categories=%8 sources=%9 selected=%10 missing=%11",
    _varName, _faction, _sqmValue, _value, count _allComps, count _sideOptions - 1, count _sizeOptions - 1, count _categoryOptions - 1, count _sourceOptions - 1, count _selectedClasses, count _missing
];
