#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenC2ISTARAccessItemsLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenC2ISTARAccessItemsLoad

Description:
    Eden attributeLoad handler for ALiVE_C2ISTARAccessItemsChoice.
    Walks CfgALiVEC2ISTARAccessItems and populates the listbox with
    one row per category whose cfgPatchesName is loaded. Reads the
    stored value, parses as CSV / SQF array literal / single token,
    and ticks rows whose category key matches.

    Back-compat: if a parsed token doesn't match a category key but
    DOES appear in some category's classnames[] array, the containing
    category is ticked instead. Mission-makers' pre-consolidation
    saves (single classname like "LaserDesignator") restore to the
    Laser Designators row ticked.

Parameters:
    [_display, _varName, _titleText, _sqmValue]
    _display    : DISPLAY - controlsGroup display
    _varName    : STRING  - logic variable name. Defaults to "c2_item".
    _titleText  : STRING  - label rendered on the Title sub-control.
                            Defaults to "Required Items:".
    _sqmValue   : STRING  - engine-auto-populated SQM value (Cfg3DEN's
                            `_value` magic). Highest-priority source.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "c2_item";
private _titleText = "Required Items:";
private _sqmValue  = "";

if (typeName _this == "ARRAY") then {
    _display = _this select 0;
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"} && {(_this select 2) != ""}) then {
        _titleText = _this select 2;
    };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then {
        _sqmValue = _this select 3;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE C2ISTARAccessItems LOAD: null display";
};

private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then { _titleCtrl ctrlSetText _titleText; };

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    diag_log "ALIVE C2ISTARAccessItems LOAD: listbox control (idc 100) not found";
};

// ---- Walk the registry, collect categories with their classnames -----------
//
// Each row: [categoryKey, displayName, classnamesLower]
private _allRows = [];
{
    private _cfg = _x;
    private _key = configName _cfg;
    if (_key != "") then {
        private _cfgPatches = getText (_cfg >> "cfgPatchesName");
        // Gate: skip categories whose addon isn't loaded.
        if (_cfgPatches == "" || {isClass (configFile >> "CfgPatches" >> _cfgPatches)}) then {
            private _displayName = getText (_cfg >> "displayName");
            if (_displayName == "") then { _displayName = _key; };
            private _classnames = getArray (_cfg >> "classnames");
            private _classnamesLower = _classnames apply { toLower _x };
            _allRows pushBack [_key, _displayName, _classnamesLower];
        };
    };
} forEach ("true" configClasses (configFile >> "CfgALiVEC2ISTARAccessItems"));

// ---- Resolve stored value -------------------------------------------------
//
// Priority: _sqmValue (engine) -> logic getVariable -> display "value"
// slot -> empty.
private _raw = "";
if (_sqmValue != "") then {
    _raw = _sqmValue;
} else {
    private _logics = get3DENSelected "logic";
    if (count _logics > 0) then {
        private _stored = (_logics select 0) getVariable [_varName, ""];
        if (typeName _stored == "STRING") then { _raw = _stored; };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

// ---- Parse stored value into tokens, resolve to category keys -------------
private _selected = [];
if (_raw != "") then {
    private _parsed = _raw splitString "[]""', ";
    {
        private _tok = _x;
        if (_tok != "") then {
            private _tokLower = toLower _tok;
            // First check if the token IS a category key (current form).
            private _categoryMatch = "";
            {
                _x params ["_key", "", ""];
                if ((toLower _key) == _tokLower) exitWith { _categoryMatch = _key; };
            } forEach _allRows;
            // If no direct match, search category classnames[] for legacy
            // back-compat (a bare classname stored from the old Edit).
            if (_categoryMatch == "") then {
                {
                    _x params ["_key", "", "_classnamesLower"];
                    if (_tokLower in _classnamesLower) exitWith { _categoryMatch = _key; };
                } forEach _allRows;
            };
            if (_categoryMatch != "" && {!(_categoryMatch in _selected)}) then {
                _selected pushBack _categoryMatch;
            };
        };
    } forEach _parsed;
};

// ---- Populate listbox -----------------------------------------------------
lbClear _listCtrl;
{
    _x params ["_key", "_displayName", ""];
    private _idx = _listCtrl lbAdd _displayName;
    _listCtrl lbSetData [_idx, _key];
    if (_key in _selected) then {
        _listCtrl lbSetSelected [_idx, true];
    };
} forEach _allRows;

diag_log format [
    "ALIVE C2ISTARAccessItems LOAD: varName='%1' raw='%2' parsed=%3 rows=%4 ticked=%5",
    _varName,
    _raw,
    str _selected,
    count _allRows,
    count (lbSelection _listCtrl)
];
