#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionStaticDataSave);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionStaticDataSave

Description:
Eden-attribute `attributeSave` handler for the
ALiVE_FactionStaticDataChoice family. Reads the multi-select listbox
ticks (IDC 100) and the override Edit text (IDC 102), merges them into
the canonical FACTION1=class1,class2;FACTION2=class3 string, and writes
that to both the attribute "value" slot and the consuming module's
logic variable.

Parameters:
    [_display, _varName]
    _display    : DISPLAY - Eden attribute display
    _varName    : STRING - logic-variable name (e.g. "customLandTransport")

Returns:
    STRING - the merged value (also persisted via setVariable + value slot)

Author:
Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "customLandTransport";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _varName = _this select 1; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    diag_log "ALIVE FactionStaticData SAVE: null display";
    "";
};

// ------------------------------------------------------------------------
// Read listbox ticks. Each row's lbData is "FACTION::CLASS".
// ------------------------------------------------------------------------
private _byFaction = createHashMap;

private _ctrl = _display controlsGroupCtrl 100;
if (!isNull _ctrl) then {
    private _selIdxs = lbSelection _ctrl;
    {
        private _data = _ctrl lbData _x;
        private _sepIdx = _data find "::";
        if (_sepIdx > 0) then {
            private _faction = _data select [0, _sepIdx];
            private _cls = _data select [_sepIdx + 2];
            private _bucket = _byFaction getOrDefault [_faction, []];
            _bucket pushBackUnique _cls;
            _byFaction set [_faction, _bucket];
        };
    } forEach _selIdxs;
};

// ------------------------------------------------------------------------
// Read override-field text. Same FACTION=class,class;... syntax.
// Merge into the per-faction buckets.
// ------------------------------------------------------------------------
private _editCtrl = _display controlsGroupCtrl 102;
private _overrideText = if (!isNull _editCtrl) then { ctrlText _editCtrl } else { "" };

if (_overrideText != "") then {
    private _entries = [_overrideText, ";"] call CBA_fnc_split;
    {
        private _entry = _x;
        while {count _entry > 0 && {(_entry select [0, 1]) == " "}} do { _entry = _entry select [1] };
        while {count _entry > 0 && {(_entry select [count _entry - 1, 1]) == " "}} do { _entry = _entry select [0, count _entry - 1] };
        if (_entry != "") then {
            private _eqIdx = _entry find "=";
            if (_eqIdx > 0) then {
                private _factionPart = _entry select [0, _eqIdx];
                private _classesPart = _entry select [_eqIdx + 1];
                while {count _factionPart > 0 && {(_factionPart select [count _factionPart - 1, 1]) == " "}} do { _factionPart = _factionPart select [0, count _factionPart - 1] };
                while {count _classesPart > 0 && {(_classesPart select [0, 1]) == " "}} do { _classesPart = _classesPart select [1] };
                if (_factionPart != "") then {
                    private _bucket = _byFaction getOrDefault [_factionPart, []];
                    {
                        private _cls = _x;
                        while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                        while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                        if (_cls != "") then { _bucket pushBackUnique _cls };
                    } forEach ([_classesPart, ","] call CBA_fnc_split);
                    _byFaction set [_factionPart, _bucket];
                };
            };
        };
    } forEach _entries;
};

// ------------------------------------------------------------------------
// Reassemble canonical string. Sorted faction keys for deterministic
// serialisation across re-saves.
// ------------------------------------------------------------------------
private _factionKeys = keys _byFaction;
_factionKeys sort true;

private _value = "";
{
    private _faction = _x;
    private _classes = _byFaction get _faction;
    if (count _classes > 0) then {
        _classes sort true;
        if (_value != "") then { _value = _value + ";" };
        _value = _value + format ["%1=%2", _faction, _classes joinString ","];
    };
} forEach _factionKeys;

// ------------------------------------------------------------------------
// Persist. Writes both to the Eden attribute's "value" slot (so the
// module dialog round-trips correctly) and the logic variable (so
// runtime / module init reads the right thing).
// ------------------------------------------------------------------------
_display setVariable ["value", _value];

private _selected = get3DENSelected "logic";
if (count _selected > 0) then {
    (_selected select 0) setVariable [_varName, _value];
};

diag_log format ["ALIVE FactionStaticData SAVE: varName=%1 value='%2'", _varName, _value];

_value
