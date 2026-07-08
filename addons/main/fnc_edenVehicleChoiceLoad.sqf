#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenVehicleChoiceLoad);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_edenVehicleChoiceLoad

Description:
    Eden attributeLoad handler for the ALiVE_VehicleCombo_* dropdown
    controls (SUP CAS / SUP Artillery / SUP Transport vehicle pickers).
    Fills the BI Combo attribute control (combo at IDC 100) with every
    role-suitable vehicle from the loaded factions, enumerated by
    fnc_listFactionRoleVehicles. Same dynamic-dropdown pattern as
    ALiVE_FactionChoice / fnc_edenFactionChoiceLoad.

    Storage shape: ONE bare CfgVehicles classname STRING - identical to
    the free-text Edit this control replaces, so existing missions and
    the runtime consumers are untouched. Saving is BI's default Combo
    save (selected row's data string).

    A stored classname that isn't in the enumeration (unloaded mod, typo)
    surfaces as a selected "(unrecognised)" top row so an open+OK
    round-trip never rewrites the mission.

Parameters:
    [_display, _varName, _role, _defaultClass]

Author:
    Jman
---------------------------------------------------------------------------- */

private _display = controlNull;
private _varName = "cas_type";
private _role = "cas";
private _defaultClass = "B_Heli_Attack_01_F";

if (typeName _this == "ARRAY") then {
    if (count _this > 0) then { _display = _this select 0; };
    if (count _this > 1 && {typeName (_this select 1) == "STRING"}) then { _varName = _this select 1; };
    if (count _this > 2 && {typeName (_this select 2) == "STRING"}) then { _role = _this select 2; };
    if (count _this > 3 && {typeName (_this select 3) == "STRING"}) then { _defaultClass = _this select 3; };
} else {
    _display = _this;
};

if (isNull _display) exitWith {
    ["ALIVE VehicleChoice LOAD: null display"] call ALiVE_fnc_dump;
};

// Resolve the stored value (priority: logic variable > Eden value slot > role default)
private _selected = get3DENSelected "logic";
private _storedFromLogic = if (count _selected > 0) then {
    (_selected select 0) getVariable [_varName, nil]
} else {
    nil
};
private _edenValue = _display getVariable "value";

private _value = _defaultClass;
if (!isNil "_edenValue" && {typeName _edenValue == "STRING"} && {_edenValue != ""}) then { _value = _edenValue };
if (!isNil "_storedFromLogic" && {typeName _storedFromLogic == "STRING"} && {_storedFromLogic != ""}) then { _value = _storedFromLogic };

// trim + strip stray quotes from legacy hand-typed values
while {count _value > 0 && {(_value select [0, 1]) == " "}} do { _value = _value select [1] };
while {count _value > 0 && {(_value select [count _value - 1, 1]) == " "}} do { _value = _value select [0, count _value - 1] };
private _len = count _value;
if (_len >= 2 && {(_value select [0, 1]) == "'"} && {(_value select [_len - 1, 1]) == "'"}) then {
    _value = _value select [1, _len - 2];
};

// BI Combo template exposes its combo at IDC 100
private _ctrl = _display controlsGroupCtrl 100;
if (isNull _ctrl) exitWith {
    ["ALIVE VehicleChoice LOAD: combo control (IDC 100) not found"] call ALiVE_fnc_dump;
};
lbClear _ctrl;

// Enumerate role vehicles (compile-invoke: cfgFunctions registrations
// don't reliably propagate to the 3DEN context)
private _vehicles = [_role] call compile preprocessFileLineNumbers "\x\alive\addons\main\fnc_listFactionRoleVehicles.sqf";
if (typeName _vehicles != "ARRAY") then { _vehicles = [] };

// order: side, then source mod, then class
private _ordered = [+_vehicles, [], { format ["%1|%2|%3", _x select 2, _x select 4, _x select 0] }, "ASCEND"] call BIS_fnc_sortBy;

private _valueLower = toLower _value;
private _known = false;
{ if ((toLower (_x select 0)) == _valueLower) exitWith { _known = true } } forEach _ordered;
if (!_known && {_value != ""}) then {
    private _idx = _ctrl lbAdd format ["(unrecognised) %1", _value];
    _ctrl lbSetData [_idx, _value];
    _ctrl lbSetCurSel _idx;
};

{
    _x params ["_class", "_dispName", "_sideText", "_factionDisplay", "_src"];
    // classname first so variant suffixes stay visible through truncation
    private _idx = _ctrl lbAdd format ["[%1] %2 | %3 [%4] %5", _sideText, _class, _dispName, _factionDisplay, _src];
    _ctrl lbSetData [_idx, _class];
    if ((toLower _class) == _valueLower) then {
        _ctrl lbSetCurSel _idx;
    };
} forEach _ordered;

// guarantee a selection so the default save always returns a classname
if (lbCurSel _ctrl < 0 && {lbSize _ctrl > 0}) then { _ctrl lbSetCurSel 0 };

[
    "ALIVE VehicleChoice LOAD: varName='%1' role='%2' stored='%3' vehicles=%4",
    _varName, _role, _value, count _vehicles
] call ALiVE_fnc_dump;
