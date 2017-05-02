 #include "script_component.hpp"

 private ["_display","_spSave"];

 // diag_log str(_this);
 disableSerialization;

_display = _this select 0;

// ALIVE ADMIN BUTTONS
_spSave = _display displayctrl 195;

_spSave ctrladdeventhandler ["buttonclick","
	if (call ALiVE_fnc_isServerAdmin) then {
	    ['SERVERSAVE'] spawn alive_fnc_buttonAbort;
	};
"];

if !(["ALiVE_sys_data"] call ALIVE_fnc_isModuleAvailable && {!isNil "ALIVE_sys_data"} && {!ALIVE_sys_data_DISABLED}) then {
    _spSave ctrlEnable false;
    _spSave ctrlSetTooltip "ALiVE SP / Host mission persistence not available!";
};