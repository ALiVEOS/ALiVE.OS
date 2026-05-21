#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenSideChoiceMultiLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenSideChoiceMultiLoad

Description:
    Eden attributeLoad handler for ALiVE_SideChoiceMulti. Populates a
    multi-select listbox (idc 100) with the three commander-able sides
    (EAST / WEST / GUER), reads the stored value from the logic
    variable (or from the engine-passed `_value` if available), parses
    it through a backward-compat parser that accepts CSV / SQF array
    literal / single token / empty forms, and ticks the matching rows.

    Title sub-control (idc 101) text is overridden so the visible
    label reflects the consuming attribute rather than the default
    "Override Factions:" inherited from ALiVE_FactionChoiceMulti_Base.

    Legacy mission-text "Independent" or "RESISTANCE" tokens are
    normalised to "GUER" on load (the canonical token mil_opcom's
    spotrep pipeline compares against). Saving the picker re-emits
    the canonical token.

Parameters:
    [_display, _varName, _titleText, _sqmValue]
    _display    : DISPLAY - Eden attribute display (controlsGroup)
    _varName    : STRING  - logic variable name. Defaults to
                            "opcomIntelSides".
    _titleText  : STRING  - label rendered on the Title sub-control.
                            Pass either a literal English string OR a
                            stringtable key prefixed with "$" (e.g.
                            "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES") — the
                            "$" form is resolved via `localize` so
                            translations live in stringtable.xml. Defaults
                            to STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES.
    _sqmValue   : STRING  - engine-auto-populated SQM value passed
                            via Cfg3DEN's `_value` magic. Highest-
                            priority source - lets the listbox ticks
                            survive Eden re-open even when the
                            consuming attribute's expression writes
                            to a logic var with a non-default name.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "opcomIntelSides";
private _titleText = "$STR_ALIVE_C2ISTAR_OPCOM_INTEL_SIDES";
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
    ["ALIVE SideChoiceMulti LOAD: null display"] call ALiVE_fnc_dump;
};

// Stringtable resolution: "$STR_FOO" → localize. Literal strings pass through.
// Matches the pattern in fnc_edenAAUnitChoiceLoad / fnc_edenFilteredMultiSelectLoad
// so all module-attribute labels flow through stringtable.xml.
private _titleResolved = _titleText;
if (_titleText != "" && {(_titleText select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleText select [1]);
};

// Override the inherited Title sub-control text.
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText _titleResolved;
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE SideChoiceMulti LOAD: listbox control (idc 100) not found"] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// 1. Resolve stored value. Priority order:
//    a) _sqmValue (engine-auto-populated, highest priority)
//    b) _logic getVariable _varName (already loaded from SQM)
//    c) display getVariable "value" (Eden save slot)
//    d) "" (empty fallback)
// ------------------------------------------------------------------------
private _raw = "";
if (_sqmValue != "") then {
    _raw = _sqmValue;
} else {
    private _logics = get3DENSelected "logic";
    if (count _logics > 0) then {
        private _stored = (_logics select 0) getVariable [_varName, ""];
        if (typeName _stored == "STRING") then {
            _raw = _stored;
        } else {
            if (typeName _stored == "ARRAY") then {
                // Runtime may have already converted to array on a
                // previously-initialised logic - re-serialise to the
                // canonical CSV form for re-load.
                _raw = (_stored apply { toupper (str _x) }) joinString ",";
            };
        };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

// ------------------------------------------------------------------------
// 2. Parse stored value into an array of uppercase side tokens.
//    Accepts:
//      - ""                       -> []
//      - "EAST"                   -> ["EAST"]
//      - "EAST,WEST"              -> ["EAST", "WEST"]
//      - "[\"EAST\",\"WEST\"]"    -> ["EAST", "WEST"]  (via stringListToArray)
//      - " East, west "           -> ["EAST", "WEST"]  (whitespace stripped)
// ------------------------------------------------------------------------
private _selected = [];
if (_raw != "") then {
    // BIS-native splitString handles all the legacy forms in one call:
    //   EAST,WEST               -> ["EAST", "WEST"]
    //   [EAST,WEST]             -> ["EAST", "WEST"]
    //   ['EAST','WEST']         -> ["EAST", "WEST"]
    //   ["EAST","WEST"]         -> ["EAST", "WEST"]
    //    EAST , WEST            -> ["EAST", "WEST"]
    // by treating each delimiter char as a split point. Empty tokens
    // from adjacent delimiters get filtered in the forEach below.
    //
    // Embedded double quote in the delimiter string is "" (doubled),
    // NOT \" - SQF strings don't recognise backslash escapes; \" would
    // close the string early and break the file parse.
    private _parsed = _raw splitString "[]""', ";
    {
        private _t = toupper _x;
        if (_t == "INDEPENDENT" || {_t == "RESISTANCE"}) then { _t = "GUER"; };
        if (_t != "" && {!(_t in _selected)}) then { _selected pushBack _t; };
    } forEach _parsed;
};

// ------------------------------------------------------------------------
// 3. Populate listbox. Three rows, lbData = canonical uppercase token
//    consumed by mil_opcom's `_side in _opcomIntelSides` check.
// ------------------------------------------------------------------------
lbClear _listCtrl;

private _rows = [
    ["EAST", "Opfor (East)"],
    ["WEST", "Blufor (West)"],
    ["GUER", "Independent (Guerrilla)"]
];

{
    _x params ["_token", "_label"];
    private _idx = _listCtrl lbAdd _label;
    _listCtrl lbSetData [_idx, _token];
    if (_token in _selected) then {
        _listCtrl lbSetSelected [_idx, true];
    };
} forEach _rows;

[
    "ALIVE SideChoiceMulti LOAD: varName='%1' raw='%2' parsed=%3 rows=%4 ticked=%5",
    _varName,
    _raw,
    str _selected,
    count _rows,
    count (lbSelection _listCtrl)
] call ALiVE_fnc_dump;
