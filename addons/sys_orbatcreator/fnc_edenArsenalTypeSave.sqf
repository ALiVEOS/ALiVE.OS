#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(edenArsenalTypeSave);

private _display = _this;
private _control = _display controlsGroupCtrl 100;
private _selection = lbCurSel _control;
private _value = if (_selection < 0) then {"BIS"} else {_control lbData _selection};

if !(_value in ["BIS", "ACE"]) then {
    _value = "BIS";
};

if (_value == "ACE" && {!isClass (configFile >> "CfgPatches" >> "ace_arsenal")}) then {
    _value = "BIS";
};

_display setVariable ["value", _value];
{
    _x setVariable ["arsenalType", _value, true];
} forEach (get3DENSelected "logic");

_value
