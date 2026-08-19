#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(edenArsenalTypeLoad);

private _display = _this;
private _control = _display controlsGroupCtrl 100;

if (isNull _control) exitWith {
    ["ORBAT Arsenal Type LOAD: combo control (IDC 100) not found"] call ALiVE_fnc_dump;
};

private _aceAvailable = isClass (configFile >> "CfgPatches" >> "ace_arsenal");
private _value = _display getVariable ["value", "BIS"];
private _selectedLogics = get3DENSelected "logic";

if (count _selectedLogics > 0) then {
    private _storedValue = (_selectedLogics select 0) getVariable ["arsenalType", nil];
    if (_storedValue isEqualType "" && {_storedValue != ""}) then {
        _value = _storedValue;
    };
};

if !(_value in ["BIS", "ACE"]) then {
    _value = "BIS";
};

if (_value == "ACE" && {!_aceAvailable}) then {
    _value = "BIS";
};

lbClear _control;

private _index = _control lbAdd (localize "STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_BIS");
_control lbSetData [_index, "BIS"];

private _aceIndex = _control lbAdd (localize "STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_ACE");
_control lbSetData [_aceIndex, "ACE"];

if (!_aceAvailable) then {
    _control lbSetColor [_aceIndex, [0.5, 0.5, 0.5, 1]];
    _control lbSetTooltip [_aceIndex, localize "STR_ALIVE_ORBATCREATOR_ARSENAL_TYPE_ACE_UNAVAILABLE"];
};

_control setVariable ["ALiVE_aceArsenalAvailable", _aceAvailable];
_control ctrlSetEventHandler ["LBSelChanged", "
    params [""_control"", ""_index""];
    if (_index == 1 && {!(_control getVariable [""ALiVE_aceArsenalAvailable"", false])}) then {
        _control lbSetCurSel 0;
    };
"];

private _selectedIndex = -1;
for "_i" from 0 to (lbSize _control - 1) do {
    if ((_control lbData _i) == _value) exitWith {
        _selectedIndex = _i;
    };
};

_control lbSetCurSel (if (_selectedIndex < 0) then {0} else {_selectedIndex});

_display setVariable ["value", _value];
