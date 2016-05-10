#include <\x\alive\addons\sys_marker\script_component.hpp>

SCRIPT(markerCheckedChanged);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerCheckedChanged
Description:
Handles the onload event for a dialog

Parameters:
_this select 0: DISPLAY - Reference to calling display

Returns:
Nil

See Also:
- <ALIVE_fnc_marker>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_params","_display","_controls","_okbutton","_xm","_y","_h","_w","_idc","_index","_ctrl","_pos"];

_params = _this select 0;
_display = ctrlparent (_params select 0);
_index = _params select 1;
_idc = _this select 1;

_controls = [80003,
			  80004,
			  801007,
			  801008,
			  801009,
			  801010,
			  801011,
			  801012,
			  801013,
			  801014,
			  801015,
			  801016,
			  801018,
			  801021,
			  801022,
			  801023,
			  801024,
			  801025,
			  801026,
			  801027,
			  80102,
			  80111,
			  801203,
			  801017,
			  801019,
			  801196];

If (_index == 0) then {
// if not checked hide spotrep section
	ctrlShow [801202, false];
	ctrlShow [801201, true];
	ctrlShow [801197, true];
	// hide the spotrep section
	{
		ctrlShow [_x,false];
	 } foreach _controls;

} else {
// if checked unhide sit rep, show long title and move ok button
	ctrlShow [801202, true];
	ctrlShow [801201, false];
	ctrlShow [801197, false];
	{
		ctrlShow [_x,true];
	} foreach _controls;

};


