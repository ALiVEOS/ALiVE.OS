 #include "script_component.hpp"

 private ["_display","_serverSave","_serverExit"];

 // diag_log str(_this);
 disableSerialization;

_display = _this select 0;

// ALIVE ADMIN BUTTONS
_serverSave = _display displayctrl 195;
_serverSave ctrladdeventhandler ["buttonclick","with uinamespace do {if (serverCommandAvailable '#kick') then {(ctrlParent (_this select 0)) closeDisplay 1; ['SERVERSAVE'] call alive_fnc_buttonAbort};};"];

_serverExit = _display displayctrl 196;
_serverExit ctrladdeventhandler ["buttonclick","with uinamespace do {if (serverCommandAvailable '#kick') then {(ctrlParent (_this select 0)) closeDisplay 1; ['SERVERABORT'] call alive_fnc_buttonAbort};};"];

if !(["ALiVE_sys_data"] call ALIVE_fnc_isModuleAvailable) then {
    _serverSave ctrlEnable false;
    _serverSave ctrlSetTooltip "ALiVE data module was not placed";

    _serverExit ctrlEnable false;
    _serverExit ctrlSetTooltip "ALiVE data module was not placed";

    _playerExit = _display displayctrl 198;
    _playerExit ctrlEnable false;
    _playerExit ctrlSetTooltip "ALiVE data module was not placed";
};