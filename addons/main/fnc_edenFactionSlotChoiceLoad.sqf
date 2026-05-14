#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionSlotChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionSlotChoiceLoad

Description:
    Eden attributeLoad handler for ALiVE_FactionSlotChoice. Populates a
    single-select listbox with all loaded military-side factions
    (sides 0/1/2; civilian excluded), then wires two filter cycles:

    - FilterNext (idc 1210) cycles SLOTS: BLU Friendly, BLU Enemy,
      OPF Friendly, OPF Enemy, IND Friendly, IND Enemy. Each slot
      stores one faction classname.
    - SideFilterNext (idc 1211) cycles SIDE FILTER MODE: Auto (per-slot
      natural side - BLU Friendly shows WEST factions etc.) and All
      (every military faction visible).

    LBSelChanged on the listbox stores the clicked row's lbData under
    the current slot index in the display namespace's
    `alive_slotSelections` array. Re-cycling the slot re-populates the
    listbox and re-ticks the previously-stored selection for the new
    current slot.

    Storage shape:
      Consolidated attr (preferred, written by SAVE):
        STRING e.g. "BLU_F|OPF_F|OPF_F|BLU_F|IND_F|OPF_F"
      Legacy per-slot attrs (read when consolidated is empty - i.e.
      pre-consolidation missions):
        each STRING faction classname.

Parameters:
    [_display, _consolidatedVar, _legacyVarsCsv, _slotLabelsCsv,
     _slotSidesStr, _defaultsCsv, _sqmValue, _titleStr]

    _display          : DISPLAY - controlsGroup display
    _consolidatedVar  : STRING  - "autoGenerateFactions"
    _legacyVarsCsv    : STRING  - six legacy attr names, CSV, in cycle
                                  order
    _slotLabelsCsv    : STRING  - six slot labels, CSV, displayed in
                                  the FilterLabel as "Slot: <label>"
    _slotSidesStr     : STRING  - per-slot Auto-mode side indices.
                                  Format: pipe-separated slot entries,
                                  each entry comma-separated side
                                  indices. E.g. "1|0,2|0|1,2|2|0,1"
                                  means slot 0 = side 1 only (WEST),
                                  slot 1 = sides 0,2 (EAST + GUER),
                                  etc.
    _defaultsCsv      : STRING  - default faction per slot when nothing
                                  is stored, CSV in cycle order.
    _sqmValue         : STRING  - SQM-deserialised consolidated value
                                  (Cfg3DEN's auto-populated `_value`)
    _titleStr         : STRING  - localised title text or $STR_ key,
                                  rendered in the Title sub-control
                                  (idc 101).

Author:
    Jman
---------------------------------------------------------------------------- */

private _display          = controlNull;
private _consolidatedVar  = "autoGenerateFactions";
private _legacyVarsCsv    = "";
private _slotLabelsCsv    = "";
private _slotSidesStr     = "";
private _defaultsCsv      = "";
private _sqmValue         = "";
private _titleStr         = "Auto Task Factions:";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _consolidatedVar = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _legacyVarsCsv = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _slotLabelsCsv = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _slotSidesStr  = _this select 4; };
    if (count _this > 5 && {typeName (_this select 5) == "STRING"}) then { _defaultsCsv   = _this select 5; };
    if (count _this > 6 && {typeName (_this select 6) == "STRING"}) then { _sqmValue      = _this select 6; };
    if (count _this > 7 && {typeName (_this select 7) == "STRING"} && {(_this select 7) != ""}) then {
        _titleStr = _this select 7;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE FactionSlotChoice LOAD: null display";
};

private _legacyVars = if (_legacyVarsCsv != "") then { _legacyVarsCsv splitString "," } else { [] };
private _slotLabels = if (_slotLabelsCsv != "") then { _slotLabelsCsv splitString "," } else { [] };
private _defaults   = if (_defaultsCsv   != "") then { _defaultsCsv   splitString "," } else { [] };

// Parse slot-sides string. "1|0,2|0|1,2|2|0,1" -> [[1],[0,2],[0],[1,2],[2],[0,1]]
private _slotSides = [];
if (_slotSidesStr != "") then {
    private _slotChunks = _slotSidesStr splitString "|";
    {
        private _sideTokens = _x splitString ",";
        private _sideIndices = [];
        {
            private _n = parseNumber _x;
            // parseNumber returns 0 for non-numeric strings; guard via re-check.
            if (_x == "0" || {_n > 0} || {_x == "0.0"}) then {
                _sideIndices pushBack _n;
            };
        } forEach _sideTokens;
        _slotSides pushBack _sideIndices;
    } forEach _slotChunks;
};

if (count _slotLabels != 6 || {count _legacyVars != 6} || {count _slotSides != 6} || {count _defaults != 6}) exitWith {
    diag_log format [
        "ALIVE FactionSlotChoice LOAD: arg-count mismatch (labels=%1 legacyVars=%2 slotSides=%3 defaults=%4)",
        count _slotLabels, count _legacyVars, count _slotSides, count _defaults
    ];
};

// ---- Title sub-control ----------------------------------------------------
private _titleResolved = _titleStr;
if (_titleStr != "" && {(_titleStr select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText _titleResolved;
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    diag_log "ALIVE FactionSlotChoice LOAD: listbox control (idc 100) not found";
};

private _filterLabelCtrl     = _display controlsGroupCtrl 1200;
private _filterNextCtrl      = _display controlsGroupCtrl 1210;
private _sideFilterLabelCtrl = _display controlsGroupCtrl 1201;
private _sideFilterNextCtrl  = _display controlsGroupCtrl 1211;

// ---- Resolve stored value -------------------------------------------------
//
// Priority order:
//   a) _sqmValue (engine-auto-populated for the consolidated attr)
//   b) logic getVariable _consolidatedVar (mission previously saved
//      with the consolidated picker)
//   c) legacy per-slot getVariable read (mission saved before the
//      consolidated picker existed)
//   d) defaults (fresh placement)
//
// Per-slot selection result is an ARRAY of six STRINGs.
private _slotSelections = [];
for "_i" from 0 to 5 do { _slotSelections pushBack ""; };

private _logics = get3DENSelected "logic";
private _logicObj = if (count _logics > 0) then { _logics select 0 } else { objNull };

private _raw = "";
if (_sqmValue != "") then {
    _raw = _sqmValue;
} else {
    if (!isNull _logicObj) then {
        private _stored = _logicObj getVariable [_consolidatedVar, ""];
        if (typeName _stored == "STRING") then { _raw = _stored; };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

if (_raw != "") then {
    // Parse pipe-separated consolidated form.
    private _parts = _raw splitString "|";
    {
        if (_forEachIndex < 6) then {
            _slotSelections set [_forEachIndex, _x];
        };
    } forEach _parts;
} else {
    // Fall back to legacy per-slot attrs.
    if (!isNull _logicObj) then {
        {
            private _legacyVal = _logicObj getVariable [_x, ""];
            if (typeName _legacyVal == "STRING" && {_legacyVal != ""}) then {
                _slotSelections set [_forEachIndex, _legacyVal];
            };
        } forEach _legacyVars;
    };
};

// Apply defaults for any slot still empty.
{
    if ((_slotSelections select _forEachIndex) == "") then {
        _slotSelections set [_forEachIndex, _x];
    };
} forEach _defaults;

// ---- Walk CfgFactionClasses for military factions -------------------------
//
// Each row: [classname, displayName, side, modTag]. Side comes from
// CfgFactionClasses >> faction >> side. Civilian (side 3) excluded.
private _allRows = [];
{
    private _cfg = _x;
    private _classname = configName _cfg;
    if (_classname != "") then {
        private _side = -1;
        if (isNumber (_cfg >> "side")) then { _side = getNumber (_cfg >> "side"); };
        if (_side in [0, 1, 2]) then {
            private _displayName = getText (_cfg >> "displayName");
            if (_displayName == "") then { _displayName = _classname; };
            _allRows pushBack [_classname, _displayName, _side];
        };
    };
} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));

// Sort by side then displayName for a stable, browsable order.
_allRows sort true;

// ---- Filter cycle state ---------------------------------------------------
//
// alive_currentSlot   : NUMBER 0..5 - which slot's tick the listbox shows
// alive_sideMode      : STRING "AUTO" or "ALL"
// alive_slotSelections: ARRAY of 6 STRINGs - per-slot picks
// alive_populating    : BOOL - LBSelChanged gate flag (true while
//                       LOAD is repopulating the listbox - the
//                       handler short-circuits to avoid recording a
//                       phantom user-click during programmatic ticks).
_display setVariable ["alive_currentSlot", 0];
_display setVariable ["alive_sideMode", "AUTO"];
_display setVariable ["alive_slotSelections", _slotSelections];
_display setVariable ["alive_populating", false];
_display setVariable ["alive_allRows", _allRows];
_display setVariable ["alive_slotSides", _slotSides];
_display setVariable ["alive_slotLabels", _slotLabels];

// ---- Populate function ----------------------------------------------------
//
// Walks _allRows, filters by current slot's Auto-side set when
// alive_sideMode == "AUTO", populates the listbox, ticks the row whose
// classname matches the current slot's stored selection.
private _populateFn = {
    params ["_display"];
    private _listCtrl = _display controlsGroupCtrl 100;
    if (isNull _listCtrl) exitWith {};

    private _allRows        = _display getVariable ["alive_allRows", []];
    private _slotSides      = _display getVariable ["alive_slotSides", []];
    private _slotSelections = _display getVariable ["alive_slotSelections", []];
    private _slotLabels     = _display getVariable ["alive_slotLabels", []];
    private _currentSlot    = _display getVariable ["alive_currentSlot", 0];
    private _sideMode       = _display getVariable ["alive_sideMode", "AUTO"];

    private _allowedSides = if (_sideMode == "ALL") then { [0,1,2] } else {
        _slotSides param [_currentSlot, [0,1,2]]
    };

    _display setVariable ["alive_populating", true];

    lbClear _listCtrl;
    private _selectedClass = _slotSelections param [_currentSlot, ""];
    private _selectedIdx = -1;
    {
        _x params ["_classname", "_displayName", "_side"];
        if (_side in _allowedSides) then {
            private _idx = _listCtrl lbAdd _displayName;
            _listCtrl lbSetData [_idx, _classname];
            if (_classname == _selectedClass) then {
                _selectedIdx = _idx;
            };
        };
    } forEach _allRows;

    // Tick the stored selection for the current slot (if visible under
    // the active filter).
    if (_selectedIdx >= 0) then {
        _listCtrl lbSetCurSel _selectedIdx;
    };

    // Update labels.
    private _filterLabelCtrl     = _display controlsGroupCtrl 1200;
    private _sideFilterLabelCtrl = _display controlsGroupCtrl 1201;
    if (!isNull _filterLabelCtrl) then {
        private _slotLabel = _slotLabels param [_currentSlot, format ["Slot %1", _currentSlot]];
        _filterLabelCtrl ctrlSetText format ["Slot: %1", _slotLabel];
    };
    if (!isNull _sideFilterLabelCtrl) then {
        _sideFilterLabelCtrl ctrlSetText format ["Side: %1", _sideMode];
    };

    _display setVariable ["alive_populating", false];
};

// Store the populate function so handlers can re-invoke it.
_display setVariable ["alive_populateFn", _populateFn];

// ---- Initial populate -----------------------------------------------------
[_display] call _populateFn;

// ---- LBSelChanged handler -------------------------------------------------
//
// Records the clicked row's classname under the current slot index.
// Suppressed during programmatic populate via alive_populating gate on
// the controlsGroup display (stored as `alive_disp` on the listbox so
// the handler can recover the controlsGroup without relying on
// ctrlParent - which returns the topmost Eden dialog, not the
// controlsGroup).
_listCtrl setVariable ["alive_disp", _display];
_listCtrl ctrlAddEventHandler ["LBSelChanged", {
    params ["_ctrl", "_selIdx"];
    private _disp = _ctrl getVariable "alive_disp";
    if (isNull _disp) exitWith {};
    if (_disp getVariable ["alive_populating", false]) exitWith {};
    if (_selIdx < 0) exitWith {};

    private _classname = _ctrl lbData _selIdx;
    if (typeName _classname != "STRING" || {_classname == ""}) exitWith {};

    private _slotSelections = _disp getVariable ["alive_slotSelections", []];
    private _currentSlot    = _disp getVariable ["alive_currentSlot", 0];
    while {count _slotSelections < 6} do { _slotSelections pushBack ""; };
    _slotSelections set [_currentSlot, _classname];
    _disp setVariable ["alive_slotSelections", _slotSelections];
}];

// ---- Slot cycle button (idc 1210) -----------------------------------------
//
// State recovered via setVariable on the button itself rather than via
// ctrlParent. Same rationale as the listbox handler above.
if (!isNull _filterNextCtrl) then {
    _filterNextCtrl setVariable ["alive_disp", _display];
    _filterNextCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_btn"];
        private _disp = _btn getVariable "alive_disp";
        if (isNull _disp) exitWith {};
        private _currentSlot = _disp getVariable ["alive_currentSlot", 0];
        _currentSlot = (_currentSlot + 1) mod 6;
        _disp setVariable ["alive_currentSlot", _currentSlot];
        private _populateFn = _disp getVariable ["alive_populateFn", {}];
        [_disp] call _populateFn;
    }];
};

// ---- Side filter cycle button (idc 1211) ---------------------------------
if (!isNull _sideFilterNextCtrl) then {
    _sideFilterNextCtrl setVariable ["alive_disp", _display];
    _sideFilterNextCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_btn"];
        private _disp = _btn getVariable "alive_disp";
        if (isNull _disp) exitWith {};
        private _sideMode = _disp getVariable ["alive_sideMode", "AUTO"];
        _sideMode = if (_sideMode == "AUTO") then { "ALL" } else { "AUTO" };
        _disp setVariable ["alive_sideMode", _sideMode];
        private _populateFn = _disp getVariable ["alive_populateFn", {}];
        [_disp] call _populateFn;
    }];
};

diag_log format [
    "ALIVE FactionSlotChoice LOAD: consolidatedVar='%1' raw='%2' slots=%3 rows=%4",
    _consolidatedVar,
    _raw,
    str _slotSelections,
    count _allRows
];
