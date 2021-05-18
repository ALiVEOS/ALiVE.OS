params ["_unit"];

if (!isNil "ALiVE_civInteractHandler" && {side group _unit == CIVILIAN}) then {
	_unit addAction ["Interact", {[ALiVE_civInteractHandler,"openMenu", _this select 0] call ALiVE_fnc_civInteract}, "", 50, true, false, "", "alive _target",5];
};