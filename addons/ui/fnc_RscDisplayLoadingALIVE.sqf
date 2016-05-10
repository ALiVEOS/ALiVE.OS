#include "\A3\ui_f\hpp\defineResincl.inc"
#include "\A3\ui_f\hpp\defineResinclDesign.inc"

private ["_display","_ctrlMission","_ctrlALIVELogo"];
// diag_log str(_this);
disableSerialization;

_display = _this select 0;

_ctrlMission = _display displayctrl IDC_LOADING_MISSION;
if (!(isnull _ctrlMission)) then {

	_ctrlALIVELogo = _display displayctrl 1202;
	_ctrlALIVELogo ctrlsettext "\x\alive\addons\UI\logo_alive.paa";
};
