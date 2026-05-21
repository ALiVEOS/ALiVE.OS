#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionTierChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionTierChoiceSave

Description:
    Eden attributeSave handler for ALiVE_FactionTierChoice. Reads the
    per-tier selection sets from the controlsGroup namespace, absorbs
    the current Override Edit text into the active tier's bucket, then
    serialises everything into a structured-format string:
        recruit:Faction1;regular:Faction2,Faction3;...

    Eden writes the return value into the consolidated attr's SQM slot.
    The runtime resolver in fnc_aiskill reads the consolidated key first
    and only falls back to per-tier legacy attrs when consolidated is
    empty (mission saved before this picker was introduced).

    Logic-side runtime parity: pushes each per-tier bucket to its legacy
    listbox attr via setVariable, and clears legacy Manual back-compat
    attrs so the existing init-merge loop in fnc_aiskill consumes the
    consolidated state on the same module-init pass. SQM persistence
    of those legacy attrs isn't guaranteed for hidden attrs - the
    consolidated attr is the authoritative storage.

Parameters:
    [_display, _consolidatedVar, _legacyVarsCsv, _legacyManualVarsCsv,
     _tierLabelsCsv]

Returns:
    STRING - structured consolidated value, or "" when nothing selected
    across any tier.

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _consolidatedVar = "";
private _legacyVarsCsv = "";
private _legacyManualVarsCsv = "";
private _tierLabelsCsv = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _consolidatedVar = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _legacyVarsCsv = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _legacyManualVarsCsv = _this select 3; };
    if (count _this > 4 && {typeName (_this select 4) == "STRING"}) then { _tierLabelsCsv = _this select 4; };
} else {
    _display = _this;
};

private _legacyVars       = if (_legacyVarsCsv != "")       then { [_legacyVarsCsv, ","]       call CBA_fnc_split } else { [] };
private _legacyManualVars = if (_legacyManualVarsCsv != "") then { [_legacyManualVarsCsv, ","] call CBA_fnc_split } else { [] };
private _tierLabels       = if (_tierLabelsCsv != "")       then { [_tierLabelsCsv, ","]       call CBA_fnc_split } else { [] };
private _tierKeys         = _tierLabels apply { toLower _x };

if (count _tierKeys == 0) exitWith {
    ["ALIVE FactionTierChoice SAVE: no tier keys"] call ALiVE_fnc_dump;
    ""
};

// ---- Absorb Override Edit text into active tier --------------------------
private _per       = _display getVariable ["alive_perTier", createHashMap];
private _filterIdx = _display getVariable ["alive_filterIdx", 0];

if (_filterIdx < count _tierKeys) then {
    private _activeTier = _tierKeys select _filterIdx;
    private _editCtrl = _display controlsGroupCtrl 102;
    if (!isNull _editCtrl) then {
        private _txt = ctrlText _editCtrl;
        if (typeName _txt == "STRING" && {_txt != ""}) then {
            private _arr = _per get _activeTier;
            if (!isNil "_arr") then {
                {
                    private _p = _x;
                    while {count _p > 0 && {(_p select [0,1]) == " "}} do { _p = _p select [1] };
                    while {count _p > 0 && {(_p select [count _p - 1, 1]) == " "}} do {
                        _p = _p select [0, count _p - 1];
                    };
                    if (_p != "") then { _arr pushBackUnique _p };
                } forEach ([_txt, ","] call CBA_fnc_split);
            };
        };
    };
};

// ---- Build structured consolidated value ---------------------------------
// Format: "tier1:A,B;tier2:C,D" - empty buckets emit "tier:" segments so
// the round-trip preserves "user explicitly cleared this tier" intent
// (prevents legacy fallback re-firing for tiers the user emptied).
private _segments = [];
{
    private _key = _x;
    private _arr = _per get _key;
    if (isNil "_arr") then { _arr = [] };
    _segments pushBack format ["%1:%2", _key, _arr joinString ","];
} forEach _tierKeys;

// All-empty case: return "" so the legacy fallback can still resolve from
// SQM-stored per-tier attrs on a fresh module never touched by the picker.
private _allEmpty = true;
{
    if (count (_per get _x) > 0) exitWith { _allEmpty = false };
} forEach _tierKeys;
private _consolidated = if (_allEmpty) then { "" } else { _segments joinString ";" };

// ---- Logic-side runtime parity -------------------------------------------
private _logicSel = get3DENSelected "logic";
private _logicObj = if (count _logicSel > 0) then { _logicSel select 0 } else { objNull };

if (!isNull _logicObj) then {
    {
        private _idx = _forEachIndex;
        private _key = _x;
        private _arr = _per get _key;
        if (isNil "_arr") then { _arr = [] };
        private _serialised = if (count _arr == 0) then {
            "[]"
        } else {
            format ["[%1]", (_arr apply { format ["""%1""", _x] }) joinString ","]
        };
        if (_idx < count _legacyVars) then {
            _logicObj setVariable [_legacyVars select _idx, _serialised, true];
        };
    } forEach _tierKeys;
    {
        _logicObj setVariable [_x, "", true];
    } forEach _legacyManualVars;
};

_display setVariable ["value", _consolidated];

[
    "ALIVE FactionTierChoice SAVE: tiers=%1 perTier=%2 -> '%3' legacyManualCleared=%4",
    _tierLabels, _per, _consolidated, _legacyManualVars
] call ALiVE_fnc_dump;

_consolidated
