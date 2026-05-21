#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionStaticDataSave);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionStaticDataSave

Description:
Eden-attribute `attributeSave` handler for the
ALiVE_FactionStaticDataChoice family. Flushes the currently-rendered
faction's listbox ticks + override Edit text into the per-faction
state hash on the display (last user edits before clicking OK), then
serialises the hash to the canonical
    FACTION1=class1,class2;FACTION2=class3
string and writes it to the logic variable + Eden value slot.

The override text follows the same FACTION=class,class;... syntax (so
the user can paste raw text in there directly) plus -- to keep the
single-faction-view UX intuitive -- the comma-separated bare list form
"class1,class2" is also accepted, in which case the classes attach to
the currently-displayed faction. The save handler normalises both
forms to canonical FACTION=class,...; output.

Parameters:
    [_display, _varName]
    _display    : DISPLAY - Eden attribute display
    _varName    : STRING - logic-variable name (e.g.
                  "customLandTransport")

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
    ["ALIVE FactionStaticData SAVE: null display"] call ALiVE_fnc_dump;
    "";
};

// ------------------------------------------------------------------------
// Final flush: serialise the currently-shown faction's UI state into
// the per-faction hash before reading it.
// ------------------------------------------------------------------------
private _flush = _display getVariable "customFlushView";
if (!isNil "_flush") then { [_display] call _flush; };

private _state = _display getVariable "customStateByFaction";
if (isNil "_state") then { _state = createHashMap; };

// ------------------------------------------------------------------------
// For each faction in the hash, merge picks + override text into a single
// dedupe class list, then emit FACTION=class,class;... entries.
// Override text accepts two shapes:
//   "FACTION1=cls;FACTION2=cls"  (full canonical syntax - applies as-is)
//   "cls1,cls2"                  (bare list - attaches to this faction)
// ------------------------------------------------------------------------
private _factionKeys = keys _state;
_factionKeys sort true;

// Pre-pass: harvest any cross-faction overrides (FACTION=cls;... in
// override text under faction X gets re-routed to that target faction).
private _crossFactionOverride = createHashMap;

private _normalised = createHashMap;
{
    private _faction = _x;
    private _entryRaw = _state get _faction;
    private _picks = if (typeName _entryRaw == "ARRAY" && {count _entryRaw >= 1}) then { _entryRaw select 0 } else { [] };
    private _override = if (typeName _entryRaw == "ARRAY" && {count _entryRaw >= 2}) then { _entryRaw select 1 } else { "" };
    private _bucket = _normalised getOrDefault [_faction, []];
    { if !(_x in _bucket) then { _bucket pushBack _x } } forEach _picks;

    // Parse override text. Detect "FACTION=" syntax by looking for "=".
    if (_override != "") then {
        private _hasEquals = (_override find "=" >= 0);
        if (_hasEquals) then {
            // Treat as canonical syntax. Split on ; and apply each entry.
            private _entries = [_override, ";"] call CBA_fnc_split;
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
                            private _crossBucket = _crossFactionOverride getOrDefault [_factionPart, []];
                            {
                                private _cls = _x;
                                while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                                while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                                if (_cls != "") then {
                                    if !(_cls in _crossBucket) then { _crossBucket pushBack _cls };
                                };
                            } forEach ([_classesPart, ","] call CBA_fnc_split);
                            _crossFactionOverride set [_factionPart, _crossBucket];
                        };
                    } else {
                        // Trailing/leading "=" with empty side - ignore.
                    };
                };
            } forEach _entries;
        } else {
            // Bare comma-separated list - attaches to THIS faction.
            {
                private _cls = _x;
                while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                if (_cls != "") then {
                    if !(_cls in _bucket) then { _bucket pushBack _cls };
                };
            } forEach ([_override, ","] call CBA_fnc_split);
        };
    };

    _normalised set [_faction, _bucket];
} forEach _factionKeys;

// Merge cross-faction overrides into the per-faction hash. New factions
// added by this path show up in the canonical output even if they weren't
// in the picker (mission-maker authored overrides for an unloaded mod).
{
    private _faction = _x;
    private _crossClasses = _crossFactionOverride get _faction;
    private _bucket = _normalised getOrDefault [_faction, []];
    {
        if !(_x in _bucket) then { _bucket pushBack _x };
    } forEach _crossClasses;
    _normalised set [_faction, _bucket];
} forEach (keys _crossFactionOverride);

// ------------------------------------------------------------------------
// Serialise the hash to canonical syntax. Faction keys sorted for
// deterministic output across re-saves.
// ------------------------------------------------------------------------
private _outKeys = keys _normalised;
_outKeys sort true;

private _value = "";
{
    private _faction = _x;
    private _classes = _normalised get _faction;
    if (count _classes > 0) then {
        _classes sort true;
        if (_value != "") then { _value = _value + ";" };
        _value = _value + format ["%1=%2", _faction, _classes joinString ","];
    };
} forEach _outKeys;

// ------------------------------------------------------------------------
// Persist.
// ------------------------------------------------------------------------
_display setVariable ["value", _value];

private _selected = get3DENSelected "logic";
if (count _selected > 0) then {
    (_selected select 0) setVariable [_varName, _value];
};

["ALIVE FactionStaticData SAVE: varName=%1 value='%2'", _varName, _value] call ALiVE_fnc_dump;

_value
