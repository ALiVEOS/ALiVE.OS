 private ["_display","_serverSave","_serverExit"];

 // diag_log str(_this);
 disableSerialization;

_display = _this select 0;

// ALIVE ADMIN BUTTONS
_serverSave = _display displayctrl 195;
_serverSave ctrladdeventhandler ["buttonclick","with uinamespace do {if (serverCommandAvailable '#kick') then {['SERVERSAVE'] call alive_fnc_buttonAbort};};"];

_serverExit = _display displayctrl 196;
_serverExit ctrladdeventhandler ["buttonclick","with uinamespace do {if (serverCommandAvailable '#kick') then {closeDialog 0; ['SERVERABORT'] call alive_fnc_buttonAbort};};"];
