#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionStaticDataLoad);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionStaticDataLoad

Description:
Eden-attribute `attributeLoad` handler for the
ALiVE_FactionStaticDataChoice family. Populates the multi-select listbox
(IDC 100) with kind-filtered CfgVehicles classes for the consuming
module's currently-selected factions, ticks rows that match the saved
value, and pre-fills the override Edit (IDC 102) with any saved classes
the listbox doesn't surface.

Storage format on the logic / SQM:
    FACTION1=class1,class2;FACTION2=class3
Empty value = no override (the resolver leaves the static-data hash
unchanged at runtime).

Flow:
1. Resolve stored value (priority: SQM `_value` > logic var > "")
2. Parse into a hash:    { FACTION -> [classes...] }
3. Read module's selected factions from its `factions` / `CQB_FACTIONS`
   / etc. logic var
4. Feed listbox via ALIVE_fnc_listFactionVehicleClasses(_kind, _factions)
   tagged rows: lbData = "FACTION::CLASSNAME", display = "FACTION - CLASSNAME"
5. Tick rows that match parsed entries
6. Anything in the parsed value not surfaced in the listbox goes into
   the override Edit (formatted back into the same FACTION=class syntax)

Parameters:
    [_display, _kind, _varName, _titleStr, _sqmValue]
    _display    : DISPLAY - Eden attribute display
    _kind       : STRING - one of "land", "air", "container", "support",
                  "supply" (passed to listFactionVehicleClasses)
    _varName    : STRING - logic-variable name (e.g. "customLandTransport")
    _titleStr   : STRING - localised title text (or $STR_ key) shown above
                  the listbox
    _sqmValue   : STRING - SQM-deserialised value (Cfg3DEN's `_value`)

Author:
Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _kind = "land";
private _varName = "customLandTransport";
private _titleStr = "Override:";
private _sqmValue = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _kind = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _varName = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _titleStr = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _sqmValue = _this select 4; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE FactionStaticData LOAD: null display";
};

// ------------------------------------------------------------------------
// Resolve title text (accepts $STR_ keys via localize, plain text passes
// through unchanged) and apply to the title control IDC 101.
// ------------------------------------------------------------------------
private _titleResolved = _titleStr;
if (count _titleStr > 0 && {(_titleStr select [0, 1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then { _titleCtrl ctrlSetText _titleResolved; };

// ------------------------------------------------------------------------
// Stored-value resolution (same priority order as the FactionChoiceMulti
// handlers - SQM-deserialised value wins over logic var wins over Eden
// attribute "value" slot).
// ------------------------------------------------------------------------
private _selected = get3DENSelected "logic";
private _logicObj = if (count _selected > 0) then { _selected select 0 } else { objNull };

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
if (_sqmValue != "") then {
    _value = _sqmValue;
};

// ------------------------------------------------------------------------
// Parse stored value into hash { FACTION -> [class, ...] }.
// Defensive against trailing semicolons, whitespace, and missing class lists.
// ------------------------------------------------------------------------
private _parsedByFaction = createHashMap;
if (_value != "") then {
    private _entries = [_value, ";"] call CBA_fnc_split;
    {
        private _entry = _x;
        // trim
        while {count _entry > 0 && {(_entry select [0, 1]) == " "}} do { _entry = _entry select [1] };
        while {count _entry > 0 && {(_entry select [count _entry - 1, 1]) == " "}} do { _entry = _entry select [0, count _entry - 1] };
        if (_entry != "") then {
            private _eqIdx = _entry find "=";
            if (_eqIdx > 0) then {
                private _factionPart = _entry select [0, _eqIdx];
                private _classesPart = _entry select [_eqIdx + 1];
                while {count _factionPart > 0 && {(_factionPart select [count _factionPart - 1, 1]) == " "}} do { _factionPart = _factionPart select [0, count _factionPart - 1] };
                while {count _classesPart > 0 && {(_classesPart select [0, 1]) == " "}} do { _classesPart = _classesPart select [1] };
                private _classList = [];
                {
                    private _cls = _x;
                    while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                    while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                    if (_cls != "") then { _classList pushBackUnique _cls };
                } forEach ([_classesPart, ","] call CBA_fnc_split);
                if (_factionPart != "") then {
                    _parsedByFaction set [_factionPart, _classList];
                };
            };
        };
    } forEach _entries;
};

// ------------------------------------------------------------------------
// Resolve module's selected factions. Try common variable names; first
// non-empty wins. Falls back to empty list (listbox shows nothing, user
// can still type into the override field).
// ------------------------------------------------------------------------
private _moduleFactions = [];
if (!isNull _logicObj) then {
    private _candidates = ["factions", "CQB_FACTIONS", "insurgentFaction", "skillFactionsBLUFOR", "skillFactionsOPFOR", "skillFactionsINDFOR", "skillFactionsCIVILIAN", "pr_factionWhitelist"];
    {
        private _v = _logicObj getVariable [_x, nil];
        if (!isNil "_v") then {
            if (typeName _v == "ARRAY") exitWith { _moduleFactions = +_v; };
            if (typeName _v == "STRING" && {_v != ""}) exitWith {
                // Could be array literal or comma-separated
                if ((_v select [0, 1]) == "[") then {
                    private _p = parseSimpleArray _v;
                    if (typeName _p == "ARRAY") then { _moduleFactions = _p; };
                } else {
                    _moduleFactions = [_v, ","] call CBA_fnc_split;
                };
            };
        };
    } forEach _candidates;
};

// Filter to non-empty strings
_moduleFactions = _moduleFactions select { typeName _x == "STRING" && {_x != ""} };

// ------------------------------------------------------------------------
// Build listbox feed via the kind helper.
// ------------------------------------------------------------------------
private _feed = [_kind, _moduleFactions] call ALIVE_fnc_listFactionVehicleClasses;

// ------------------------------------------------------------------------
// Populate listbox.
// ------------------------------------------------------------------------
private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {
    diag_log "ALIVE FactionStaticData LOAD: listbox control (IDC 100) not found";
};
lbClear _ctrl;

private _surfacedKey = createHashMap;  // "FACTION::CLASS" -> idx
{
    _x params ["_faction", "_classes"];
    {
        private _cls = _x;
        private _label = format ["%1 - %2", _faction, _cls];
        private _idx = _ctrl lbAdd _label;
        _ctrl lbSetData [_idx, format ["%1::%2", _faction, _cls]];
        _surfacedKey set [format ["%1::%2", _faction, _cls], _idx];
    } forEach _classes;
} forEach _feed;

// ------------------------------------------------------------------------
// Tick rows from parsed value, accumulate misses for the override field.
// ------------------------------------------------------------------------
private _missesByFaction = createHashMap;  // faction -> [class, ...]

{
    private _faction = _x;
    private _classList = _parsedByFaction get _faction;
    {
        private _cls = _x;
        private _key = format ["%1::%2", _faction, _cls];
        private _idx = _surfacedKey getOrDefault [_key, -1];
        if (_idx >= 0) then {
            _ctrl lbSetSelected [_idx, true];
        } else {
            private _bucket = _missesByFaction getOrDefault [_faction, []];
            _bucket pushBackUnique _cls;
            _missesByFaction set [_faction, _bucket];
        };
    } forEach _classList;
} forEach (keys _parsedByFaction);

// ------------------------------------------------------------------------
// Reassemble override-field text from misses.
// ------------------------------------------------------------------------
private _overrideText = "";
{
    private _faction = _x;
    private _classes = _missesByFaction get _faction;
    if (count _classes > 0) then {
        if (_overrideText != "") then { _overrideText = _overrideText + ";" };
        _overrideText = _overrideText + format ["%1=%2", _faction, _classes joinString ","];
    };
} forEach (keys _missesByFaction);

private _editCtrl = _display controlsGroupCtrl 102;
if (!isNull _editCtrl) then { _editCtrl ctrlSetText _overrideText; };

diag_log format [
    "ALIVE FactionStaticData LOAD: kind=%1 varName=%2 sqm='%3' resolved='%4' moduleFactions=%5 listboxRows=%6 override='%7'",
    _kind, _varName, _sqmValue, _value, _moduleFactions, lbSize _ctrl, _overrideText
];
