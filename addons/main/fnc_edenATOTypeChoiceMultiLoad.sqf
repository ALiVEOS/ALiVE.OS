#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenATOTypeChoiceMultiLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenATOTypeChoiceMultiLoad

Description:
    Eden attributeLoad handler for ALiVE_ATOTypeChoiceMulti. Populates a
    multi-select listbox (idc 100) with the air mission types mil_ato can
    fly, spelled out in full rather than as bare acronyms, and ticks the
    rows present in the stored value.

    Replaces a free-text Edit field in which the mission maker hand-typed
    an SQF array literal. A typo in that field silently disabled a mission
    type with no feedback of any kind, and the acronyms told a newcomer
    nothing about what they selected.

    CASE IS SIGNIFICANT and is the one trap in this list. mil_ato gates
    requests with `_eventType in _types` (fnc_ATO.sqf), an exact,
    case-sensitive string match against the event type raised by
    mil_opcom. Five tokens are upper case but "Strike" and "Recce" are
    title case, so the uppercase-everything normalisation used by
    fnc_edenSideChoiceMultiLoad would silently break those two. Parsed
    tokens are therefore matched case-INsensitively against the canonical
    list and re-emitted in their canonical form.

    Storage shape: CSV of canonical tokens, e.g. "CAP,DCA,Strike". The
    parser also accepts the legacy SQF array literal form written by the
    old Edit field ("['CAP','DCA']"), a single bare token, and an empty
    string, so missions saved before the picker existed load cleanly.

Parameters:
    [_display, _varName, _titleText, _sqmValue]
    _display    : DISPLAY - Eden attribute display (controlsGroup)
    _varName    : STRING  - logic variable name. Defaults to "types".
    _titleText  : STRING  - label for the Title sub-control. Either a
                            literal string or a stringtable key prefixed
                            with "$", resolved via localize.
    _sqmValue   : STRING  - engine-populated SQM value via Cfg3DEN's
                            `_value` magic. Highest priority source.

See Also:
    ALIVE_fnc_edenSideChoiceMultiSave - reused verbatim as this control's
    attributeSave. That handler is token-agnostic: it reads lbData off the
    selected rows and joins them with commas, with nothing side-specific
    in it.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "types";
private _titleText = "$STR_ALIVE_ATO_TYPES";
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
    ["ALIVE ATOTypeChoiceMulti LOAD: null display"] call ALiVE_fnc_dump;
};

// Stringtable resolution: "$STR_FOO" -> localize. Literal strings pass through.
private _titleResolved = _titleText;
if (_titleText != "" && {(_titleText select [0,1]) == "$"}) then {
    _titleResolved = localize (_titleText select [1]);
};

private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then {
    _titleCtrl ctrlSetText _titleResolved;
};

private _listCtrl = _display controlsGroupCtrl 100;
if (isNull _listCtrl) exitWith {
    ["ALIVE ATOTypeChoiceMulti LOAD: listbox control (idc 100) not found"] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// Canonical rows. lbData carries the token mil_ato matches on; the label
// spells it out. Order is the order the mission maker sees.
//
// "AS" is deliberately absent - it appears in the module's code-side
// default but has no implementation anywhere, so offering it would
// advertise a capability that does not exist.
// ------------------------------------------------------------------------
private _rows = [
    ["CAP",    "Combat Air Patrol (CAP)"],
    ["DCA",    "Defensive Counter-Air (DCA)"],
    ["SEAD",   "Suppression of Enemy Air Defences (SEAD)"],
    ["CAS",    "Close Air Support (CAS)"],
    ["Strike", "Strike"],
    ["Recce",  "Reconnaissance (Recce)"],
    ["OCA",    "Offensive Counter-Air (OCA)"]
];

private _canonical = _rows apply {_x select 0};

// ------------------------------------------------------------------------
// 1. Resolve stored value. Priority: engine _value, then the logic
//    variable, then the Eden save slot, then empty.
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
                // Already converted to an array on a previously-initialised
                // logic - re-serialise to the canonical CSV form.
                _raw = (_stored apply {str _x}) joinString ",";
            };
        };
    };
    if (_raw == "") then {
        private _slotVal = _display getVariable ["value", ""];
        if (typeName _slotVal == "STRING") then { _raw = _slotVal; };
    };
};

// ------------------------------------------------------------------------
// 2. Parse into canonical tokens. splitString on every delimiter character
//    covers CSV, SQF array literal, quoted or unquoted, spaced or not:
//      CAP,DCA              ['CAP','DCA']          ["CAP","DCA"]
//      [CAP, DCA]            CAP                    ""
//    The embedded double quote in the delimiter string is doubled ("") -
//    SQF has no backslash escapes, so \" would end the string early.
// ------------------------------------------------------------------------
private _selected = [];
if (_raw != "") then {
    private _parsed = _raw splitString "[]""', ";
    {
        private _t = toLower _x;
        if (_t != "") then {
            // Case-insensitive match, canonical-case emit. Without this,
            // "strike" or "STRIKE" from a hand-edited mission would fail
            // mil_ato's exact-match gate and the type would go silently dead.
            {
                if (toLower _x == _t && {!(_x in _selected)}) then {
                    _selected pushBack _x;
                };
            } forEach _canonical;
        };
    } forEach _parsed;
};

// ------------------------------------------------------------------------
// 3. Populate the listbox.
// ------------------------------------------------------------------------
lbClear _listCtrl;

{
    _x params ["_token", "_label"];
    private _idx = _listCtrl lbAdd _label;
    _listCtrl lbSetData [_idx, _token];
    if (_token in _selected) then {
        _listCtrl lbSetSelected [_idx, true];
    };
} forEach _rows;

[
    "ALIVE ATOTypeChoiceMulti LOAD: varName='%1' raw='%2' parsed=%3 rows=%4 ticked=%5",
    _varName,
    _raw,
    str _selected,
    count _rows,
    count (lbSelection _listCtrl)
] call ALiVE_fnc_dump;
