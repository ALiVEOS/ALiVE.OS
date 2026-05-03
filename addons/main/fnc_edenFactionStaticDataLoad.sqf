#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionStaticDataLoad);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionStaticDataLoad

Description:
Eden-attribute `attributeLoad` handler for the
ALiVE_FactionStaticDataChoice family. Sets up the reactive faction-
picker UI:

1. Discover factions:
     - module's own `factions` logic var (modules that store their own)
     - else fall back to factions on synced OPCOM modules (most
       common case for mil_logistics, which doesn't store its own
       faction list - it inherits from the OPCOM it's wired to)
2. Parse stored value into a per-faction hash { FACTION -> [picks, overrideText] }
3. Populate the faction-picker combo (idc 200)
4. Cache state on the display via setVariable so the LBSelChanged
   handler on the combo can flush + reload views without re-running
   the discovery / parsing logic
5. Render the first faction's view in the listbox + override Edit
6. Attach the LBSelChanged handler that:
     a. flushes the current view's listbox ticks + override text into
        the per-faction hash under the previously-shown faction
     b. reads the newly-picked faction
     c. repopulates listbox + override Edit for the new faction

Storage format on the logic / SQM:
    FACTION1=class1,class2;FACTION2=class3
Empty value = no override (the resolver leaves the static-data hash
unchanged at runtime).

Parameters:
    [_display, _kind, _varName, _titleStr, _sqmValue]
    _display    : DISPLAY - Eden attribute display
    _kind       : STRING - one of "land" / "air" / "container" /
                  "support" / "supply"
    _varName    : STRING - logic-variable name (e.g.
                  "customLandTransport")
    _titleStr   : STRING - localised title text or $STR_ key
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
// Resolve title text and apply to title control IDC 101.
// ------------------------------------------------------------------------
private _titleResolved = _titleStr;
if (count _titleStr > 0 && {(_titleStr select [0, 1]) == "$"}) then {
    _titleResolved = localize (_titleStr select [1]);
};
private _titleCtrl = _display controlsGroupCtrl 101;
if (!isNull _titleCtrl) then { _titleCtrl ctrlSetText _titleResolved; };

// ------------------------------------------------------------------------
// Per-kind override-row label so the three CUSTOM CLASSES rows aren't
// all labelled identically "Override classes:". Picks a kind-specific
// noun so a quick scan distinguishes the three override fields.
// ------------------------------------------------------------------------
private _overrideLabelText = switch (_kind) do {
    case "land":      { "Override trucks:"     };
    case "air":       { "Override helis:"      };
    case "container": { "Override containers:" };
    case "support":   { "Override supports:"   };
    case "supply":    { "Override supplies:"   };
    default           { "Override classes:"    };
};
private _overrideLabelCtrl = _display controlsGroupCtrl 103;
if (!isNull _overrideLabelCtrl) then { _overrideLabelCtrl ctrlSetText _overrideLabelText; };

// ------------------------------------------------------------------------
// Stored-value resolution.
//   Priority: SQM `_value` > logic var > Eden attribute "value" slot > "".
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
// Parse stored value into per-faction hash. Each entry is
// [pickedClasses, overrideText]. The split between picks and override
// is computed below once we know which classes the listbox surfaces.
// For now everything goes into picks; classes that don't surface in the
// listbox get re-shuffled into override at view-render time.
// ------------------------------------------------------------------------
private _hashByFaction = createHashMap;
if (_value != "") then {
    private _entries = [_value, ";"] call CBA_fnc_split;
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
                private _classList = [];
                {
                    private _cls = _x;
                    while {count _cls > 0 && {(_cls select [0, 1]) == " "}} do { _cls = _cls select [1] };
                    while {count _cls > 0 && {(_cls select [count _cls - 1, 1]) == " "}} do { _cls = _cls select [0, count _cls - 1] };
                    if (_cls != "") then { _classList pushBackUnique _cls };
                } forEach ([_classesPart, ","] call CBA_fnc_split);
                if (_factionPart != "") then {
                    // Stored as [allClasses, ""]. View-render below splits
                    // surfaced vs not-surfaced into picks vs override.
                    _hashByFaction set [_factionPart, [_classList, ""]];
                };
            };
        };
    } forEach _entries;
};

// ------------------------------------------------------------------------
// Faction discovery. Order:
//   1. Module's own factions var (whatever name common variants use)
//   2. Synced modules' factions (3DEN connections - covers mil_logistics
//      which inherits from synced OPCOM)
//   3. Stored-value's faction keys (so missions saved against factions
//      not currently loaded still see the entries in the picker)
// ------------------------------------------------------------------------
private _addFromValue = {
    params ["_v", "_acc"];
    if (typeName _v == "ARRAY") exitWith {
        { if (typeName _x == "STRING" && {_x != ""}) then { _acc pushBackUnique _x } } forEach _v;
    };
    if (typeName _v == "STRING" && {_v != ""}) exitWith {
        if ((_v select [0, 1]) == "[") then {
            private _p = parseSimpleArray _v;
            if (typeName _p == "ARRAY") then {
                { if (typeName _x == "STRING" && {_x != ""}) then { _acc pushBackUnique _x } } forEach _p;
            };
        } else {
            {
                private _t = _x;
                while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
                while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
                if (_t != "") then { _acc pushBackUnique _t };
            } forEach ([_v, ","] call CBA_fnc_split);
        };
    };
};

private _moduleFactions = [];

if (!isNull _logicObj) then {
    // 1. Self
    private _candidates = ["factions", "CQB_FACTIONS", "insurgentFaction", "skillFactionsBLUFOR", "skillFactionsOPFOR", "skillFactionsINDFOR", "skillFactionsCIVILIAN", "pr_factionWhitelist"];
    {
        private _v = _logicObj getVariable [_x, nil];
        if (!isNil "_v") then { [_v, _moduleFactions] call _addFromValue; };
    } forEach _candidates;

    // 2. Synced modules (covers mil_logistics -> OPCOM and similar).
    // get3DENConnections is unary - returns [[type, target], ...].
    // Filter to Sync edges and unwrap the target object.
    private _synced = (get3DENConnections _logicObj) select {(_x select 0) == "Sync"};
    {
        private _peer = _x select 1;
        if (typeName _peer == "OBJECT" && {!isNull _peer}) then {
            {
                private _candidate = _x;
                private _v = _peer getVariable [_candidate, nil];
                if (!isNil "_v") then { [_v, _moduleFactions] call _addFromValue; };
            } forEach _candidates;
        };
    } forEach _synced;
};

// 3. Saved-value keys (so unloaded-mod factions still appear)
{ _moduleFactions pushBackUnique _x; } forEach (keys _hashByFaction);

// ------------------------------------------------------------------------
// Cache state on the display so LBSelChanged + attributeSave can read it.
// ------------------------------------------------------------------------
_display setVariable ["customStateByFaction", _hashByFaction];
_display setVariable ["customKind", _kind];
_display setVariable ["customVarName", _varName];
_display setVariable ["customCurrentFaction", ""];

// ------------------------------------------------------------------------
// Define view-flush + view-load closures and stash them on the display.
// LBSelChanged on the combo and the save handler call into them.
// ------------------------------------------------------------------------
private _flushView = {
    params ["_d"];
    private _state = _d getVariable "customStateByFaction";
    private _curFac = _d getVariable ["customCurrentFaction", ""];
    if (_curFac == "" || {isNil "_state"}) exitWith {};

    private _listCtrl = _d controlsGroupCtrl 100;
    private _editCtrl = _d controlsGroupCtrl 102;

    private _picks = [];
    if (!isNull _listCtrl) then {
        {
            private _data = _listCtrl lbData _x;
            if (_data != "") then { _picks pushBackUnique _data };
        } forEach (lbSelection _listCtrl);
    };

    private _override = if (!isNull _editCtrl) then { ctrlText _editCtrl } else { "" };

    _state set [_curFac, [_picks, _override]];
};

private _loadView = {
    params ["_d", "_faction"];
    private _state = _d getVariable "customStateByFaction";
    private _kindLocal = _d getVariable ["customKind", "land"];
    if (isNil "_state") exitWith {};

    private _listCtrl = _d controlsGroupCtrl 100;
    private _editCtrl = _d controlsGroupCtrl 102;

    // Listbox: feed kind classes for THIS faction, tick rows that match
    // the saved entry, and stash leftover (non-surfaced) classes for
    // re-injection into the override field.
    private _saved = _state getOrDefault [_faction, [[], ""]];
    private _savedClasses = _saved select 0;
    private _savedOverride = _saved select 1;

    private _surfacedSet = createHashMap;
    if (!isNull _listCtrl) then {
        lbClear _listCtrl;
        // CfgFunctions-registered helpers aren't reliably available in
        // 3DEN editor context. Lazy-compile the feeder on first use and
        // cache it on the display so subsequent view-loads (after combo
        // changes) reuse the compiled code.
        private _feeder = _d getVariable ["customListFeeder", nil];
        if (isNil "_feeder") then {
            _feeder = compile preprocessFileLineNumbers "\x\alive\addons\main\fnc_listFactionVehicleClasses.sqf";
            _d setVariable ["customListFeeder", _feeder];
        };
        private _feed = [_kindLocal, [_faction]] call _feeder;
        diag_log format ["ALIVE FactionStaticData VIEW: faction=%1 kind=%2 feed=%3", _faction, _kindLocal, _feed];
        if (count _feed > 0) then {
            (_feed select 0) params ["", "_classes"];
            {
                private _idx = _listCtrl lbAdd _x;
                _listCtrl lbSetData [_idx, _x];
                _surfacedSet set [_x, _idx];
            } forEach _classes;
        };

        // Tick saved classes that the listbox surfaces.
        {
            private _idx = _surfacedSet getOrDefault [_x, -1];
            if (_idx >= 0) then { _listCtrl lbSetSelected [_idx, true]; };
        } forEach _savedClasses;
    };

    if (!isNull _editCtrl) then {
        // Override field shows the saved-override text PLUS any saved
        // classes the listbox didn't surface (mod classes from a previous
        // session whose mod isn't currently loaded).
        private _missing = _savedClasses select { !(_x in _surfacedSet) };
        private _txt = _savedOverride;
        if (count _missing > 0) then {
            if (_txt != "") then { _txt = _txt + "," };
            _txt = _txt + (_missing joinString ",");
        };
        _editCtrl ctrlSetText _txt;
    };

    _d setVariable ["customCurrentFaction", _faction];
};

_display setVariable ["customFlushView", _flushView];
_display setVariable ["customLoadView", _loadView];

// ------------------------------------------------------------------------
// Populate the faction-picker (static label + Next button) and attach
// the cycle handler.
// ------------------------------------------------------------------------
_moduleFactions sort true;
_display setVariable ["customFactionList", _moduleFactions];

private _labelCtrl  = _display controlsGroupCtrl 200;
private _buttonCtrl = _display controlsGroupCtrl 202;

private _renderLabel = {
    params ["_d"];
    private _l = _d getVariable ["customFactionList", []];
    private _f = _d getVariable ["customCurrentFaction", ""];
    private _lc = _d controlsGroupCtrl 200;
    if (isNull _lc) exitWith {};
    if (count _l == 0) then {
        _lc ctrlSetText "(no factions)";
    } else {
        private _idx = _l find _f;
        if (_idx < 0) then { _idx = 0; };
        _lc ctrlSetText format ["Faction: %1  (%2/%3)", _l select _idx, _idx + 1, count _l];
    };
};
_display setVariable ["customRenderLabel", _renderLabel];

diag_log format ["ALIVE FactionStaticData LOAD: button isNull=%1", isNull _buttonCtrl];
if (!isNull _buttonCtrl) then {
    private _ehId = _buttonCtrl ctrlAddEventHandler ["ButtonClick", {
        params ["_btn"];
        diag_log "ALIVE FactionStaticData CYCLE: ButtonClick fired";
        // ctrlParent returns the DIALOG, not the controlsGroup that owns
        // the per-faction state setVariables. Use ctrlParentControlsGroup
        // to walk up to my controlsGroup.
        private _d = ctrlParentControlsGroup _btn;
        if (isNull _d) exitWith { diag_log "ALIVE FactionStaticData CYCLE: ctrlParentControlsGroup returned null"; };
        private _l = _d getVariable ["customFactionList", []];
        if (count _l == 0) exitWith { diag_log "ALIVE FactionStaticData CYCLE: empty faction list, no-op"; };

        // Flush current view's UI state into the per-faction hash
        // before swapping.
        private _flush = _d getVariable "customFlushView";
        if (!isNil "_flush") then { [_d] call _flush; };

        // Cycle to next faction.
        private _cur = _d getVariable ["customCurrentFaction", ""];
        private _idx = _l find _cur;
        _idx = (_idx + 1) mod (count _l);
        private _newFaction = _l select _idx;
        diag_log format ["ALIVE FactionStaticData CYCLE: %1 -> %2 (idx=%3 of %4)", _cur, _newFaction, _idx, count _l];

        private _load = _d getVariable "customLoadView";
        if (!isNil "_load") then { [_d, _newFaction] call _load; };

        private _render = _d getVariable "customRenderLabel";
        if (!isNil "_render") then { [_d] call _render; };
    }];
    diag_log format ["ALIVE FactionStaticData LOAD: ButtonClick handler attached, ehId=%1", _ehId];
};

// Pick the first faction (alphabetical) and render its view + label.
if (count _moduleFactions > 0) then {
    [_display, _moduleFactions select 0] call _loadView;
    [_display] call _renderLabel;
} else {
    if (!isNull _labelCtrl) then { _labelCtrl ctrlSetText "(no factions)"; };
};

diag_log format [
    "ALIVE FactionStaticData LOAD: kind=%1 varName=%2 sqm='%3' resolved='%4' moduleFactions=%5 storedKeys=%6",
    _kind, _varName, _sqmValue, _value, _moduleFactions, keys _hashByFaction
];
