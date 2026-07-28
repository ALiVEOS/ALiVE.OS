#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenATOAircraftSlotChoiceSave);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_edenATOAircraftSlotChoiceSave

Description:
    Eden attributeSave handler for ALiVE_ATOAircraftSlotChoice. Reads the
    per-slot selection map from the display namespace
    (`alive_slotSelections`, written by the LOAD handler's LBSelChanged plus
    the slot cycle), serialises it as a pipe-separated string in slot order,
    and hands it back through the Eden display "value" slot for SQM.

    There is no legacy per-slot fan-out here. This picker was born
    consolidated - nothing has ever read these slots by individual attribute
    name - so the single stored string is the only representation there is.

Parameters:
    [_display, _varName, _slotCount]
    _display   : DISPLAY - Eden attribute display
    _varName   : STRING  - logic variable name, for the log line
    _slotCount : NUMBER  - how many slots to serialise

Returns:
    STRING - pipe-separated tokens in slot order. A slot left on Auto
             becomes an empty token, so an untouched picker returns pipes
             alone. Example:
             "B_Plane_CAS_01_F||O_Heli_Attack_02_F|||||||||"

Author:
    Jman
---------------------------------------------------------------------------- */

private _display   = controlNull;
private _varName   = "ingressSlotClasses";
private _slotCount = 12;

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"} && {(_this select 1) != ""}) then {
        _varName = _this select 1;
    };
    if (count _this > 2 && {typeName (_this select 2) == "SCALAR"} && {(_this select 2) > 0}) then {
        _slotCount = _this select 2;
    };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE ATOAircraftSlotChoice SAVE: null display"] call ALiVE_fnc_dump;
    ""
};

// Read per-slot selections written by the LOAD handler. Each entry is either
// an aircraft classname STRING or "" for a slot left on Auto.
private _slotSelections = _display getVariable ["alive_slotSelections", []];
if (typeName _slotSelections != "ARRAY") then { _slotSelections = []; };

// Pad so a partially-populated map still serialises cleanly, and so the
// tokens line up with slot numbers however few were touched.
while {count _slotSelections < _slotCount} do { _slotSelections pushBack ""; };

private _result = _slotSelections joinString "|";

// Eden value slot, for SQM serialisation.
_display setVariable ["value", _result];

[
    "ALIVE ATOAircraftSlotChoice SAVE: varName='%1' slots=%2 -> '%3'",
    _varName,
    str _slotSelections,
    _result
] call ALiVE_fnc_dump;

_result
