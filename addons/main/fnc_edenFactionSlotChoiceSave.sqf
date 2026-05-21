#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenFactionSlotChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenFactionSlotChoiceSave

Description:
    Eden attributeSave handler for ALiVE_FactionSlotChoice. Reads the
    per-slot selection map from the display namespace
    (`alive_slotSelections`, written by the LOAD handler's LBSelChanged
    plus filter cycles), serialises as a pipe-separated string in the
    cycle order, and persists via:

    1. Eden display "value" slot - for SQM serialisation of the
       consolidated attribute (autoGenerateFactions).
    2. setVariable for each LEGACY per-slot attribute
       (autoGenerateBluforFaction etc.) so the runtime path in
       fnc_C2ISTAR.sqf which reads each by name keeps working
       unchanged.
    3. The CfgVehicles `expression` callback re-applies on mission
       start.

Parameters:
    [_display, _consolidatedVar, _legacyVarsCsv]
    _display          : DISPLAY - Eden attribute display
    _consolidatedVar  : STRING  - logic variable name of the
                                  consolidated picker storage
                                  (default "autoGenerateFactions").
    _legacyVarsCsv    : STRING  - six legacy per-slot attribute names,
                                  comma-separated, in cycle order.

Returns:
    STRING - pipe-separated tokens of the six slots' currently-
             selected factions, in cycle order. Empty slot becomes an
             empty token. Example:
             "BLU_F|OPF_F|OPF_F|BLU_F|IND_F|OPF_F"

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _consolidatedVar = "autoGenerateFactions";
private _legacyVarsCsv = "";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _consolidatedVar = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then {
        _legacyVarsCsv = _this select 2;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE FactionSlotChoice SAVE: null display"] call ALiVE_fnc_dump;
    ""
};

private _legacyVars = if (_legacyVarsCsv != "") then {
    _legacyVarsCsv splitString ","
} else {
    []
};

// Read per-slot selections written by the LOAD handler. Each entry is
// either a faction classname STRING (slot has a pick) or "" (unset).
private _slotSelections = _display getVariable ["alive_slotSelections", []];
if (typeName _slotSelections != "ARRAY") then { _slotSelections = []; };

// Pad to six entries so a partially-populated map still serialises
// cleanly (defensive against any future code path that mutates the
// namespace state outside the LOAD handler's invariant).
while {count _slotSelections < 6} do { _slotSelections pushBack ""; };

private _result = _slotSelections joinString "|";

// Path 1: Eden value slot for SQM serialisation of the consolidated attr.
_display setVariable ["value", _result];

// Path 2: each legacy per-slot attribute gets its token via setVariable,
// preserving runtime back-compat.
private _logics = get3DENSelected "logic";
if (count _legacyVars == count _slotSelections) then {
    {
        private _legacyVar = _legacyVars select _forEachIndex;
        private _token = _slotSelections select _forEachIndex;
        {
            _x setVariable [_legacyVar, _token, true];
        } forEach _logics;
    } forEach _legacyVars;
};

[
    "ALIVE FactionSlotChoice SAVE: consolidatedVar='%1' slots=%2 -> '%3'",
    _consolidatedVar,
    str _slotSelections,
    _result
] call ALiVE_fnc_dump;

_result
