#include <\x\alive\addons\sys_marker\script_component.hpp>

SCRIPT(markerButtonAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerButtonAction
Description:
Handles the button action event for a dialog

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

private ["_params","_display","_controls","_shape","_xm","_y","_h","_w","_idc","_index","_ctrl","_pos","_check","_markerName","_markersHash"];

_display = findDisplay 80001;

_check = uiNamespace getVariable [QGVAR(edit), false];

_markerName = "MKR" + str(random time + 1);
_markersHash = [] call ALIVE_fnc_hashCreate;

// If editing a marker, delete the old one and create a new one.
if (typeName _check != "BOOL") then {

	private "_tempHash";

	_tempHash = [GVAR(STORE), _check] call ALIVE_fnc_hashGet;

	if ([_tempHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashGet) then {
		private "_spotrep";
		_spotrep = [_tempHash, QGVAR(spotrep)] call ALIVE_fnc_hashGet;
		[MOD(sys_spotrep), "removespotrep", [_spotrep]] call ALiVE_fnc_spotrep;
	};

	[MOD(sys_marker), "removeMarker", [_check]] call ALiVE_fnc_marker;

};

// Get all the marker info

_colorIndex = lbCurSel COLOR_LIST;
_color = lbData [COLOR_LIST, _colorIndex];
_pos = uiNamespace getVariable [QGVAR(pos),[0,0,0]];
_size = [parseNumber(ctrlText SIZEA_VALUE), parseNumber(ctrlText SIZEB_VALUE)];
_dir = parseNumber(ctrlText ANGLE_VALUE);
_text = [ctrlText LABEL_VALUE,"\","-"] call CBA_fnc_replace;
_shapeIndex = uiNamespace getVariable [QGVAR(shape),0];
_eyesIndex = lbCurSel EYES_LIST;
_eyes = lbData [EYES_LIST,_eyesIndex];

if (_shapeIndex == 0) then {
	_shape = "ICON";
	_size = [1,1];
	_classIndex = lbCurSel CLASS_LIST;
	_typeIndex = lbCurSel ICON_LIST;
	_type = lbData [ICON_LIST, _typeIndex];
	[_markersHash, QGVAR(classIndex), _classIndex] call ALIVE_fnc_hashSet;
	[_markersHash, QGVAR(typeIndex), _typeIndex] call ALIVE_fnc_hashSet;
	[_markersHash, QGVAR(type), _type] call ALIVE_fnc_hashSet;
} else {
	if (_shapeIndex == 1) then {_shape = "RECTANGLE";} else {_shape = "ELLIPSE";};
	_brushIndex = lbCurSel FILL_LIST;
	_brush = lbData [FILL_LIST, _brushIndex];
	[_markersHash, QGVAR(brush), _brush] call ALIVE_fnc_hashSet;
	[_markersHash, QGVAR(brushIndex), _brushIndex] call ALIVE_fnc_hashSet;
};

[_markersHash, QGVAR(shape), _shape] call ALIVE_fnc_hashSet;
[_markersHash, QGVAR(color), _color] call ALIVE_fnc_hashSet;
[_markersHash, QGVAR(size), _size] call ALIVE_fnc_hashSet;
[_markersHash, QGVAR(pos), _pos] call ALIVE_fnc_hashSet;
// [_markersHash, QGVAR(alpha), _alpha] call ALIVE_fnc_hashSet; TO DO
[_markersHash, QGVAR(dir), _dir] call ALIVE_fnc_hashSet;

[_markersHash, QGVAR(text), _text] call ALIVE_fnc_hashSet;

[_markersHash, QGVAR(locality), _eyes] call ALIVE_fnc_hashSet;

switch _eyes do {
	case "SIDE" : {
		[_markersHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
	};
	case "GROUP" : {
		[_markersHash, QGVAR(localityValue), str (group player)] call ALIVE_fnc_hashSet;
	};
	case "FACTION" : {
		[_markersHash, QGVAR(localityValue), faction player] call ALIVE_fnc_hashSet;
	};
};

[_markersHash, QGVAR(colorIndex), _colorIndex] call ALIVE_fnc_hashSet;
// [_markersHash, QGVAR(alphaIndex), _alphaIndex] call ALIVE_fnc_hashSet; TO DO
[_markersHash, QGVAR(shapeIndex), _shapeIndex] call ALIVE_fnc_hashSet;
[_markersHash, QGVAR(localityIndex), _eyesIndex] call ALIVE_fnc_hashSet;
[_markersHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;

[_markersHash, QGVAR(hasspotrep), false] call ALIVE_fnc_hashSet;

// spotrep DATA

_spotrepCheck = _display displayCtrl spotrep_CHECK;
if (cbChecked _spotrepCheck) then {

	private ["_spotrepHash","_spotrepName","_callsign"];

	_spotrepName = "SP" + str(random time + 1);

	_spotrepName = [_spotrepName, ".", "N"] call CBA_fnc_replace;

	[_markersHash, QGVAR(hasspotrep), true] call ALIVE_fnc_hashSet;

	_callSign = [ctrlText NAME_VALUE,"\","-"] call CBA_fnc_replace;
	_DTG = ctrlText DTG_VALUE;
	_dateTime = [ctrlText DATE_VALUE,"\","-"] call CBA_fnc_replace;
	_loc = [ctrlText LOC_VALUE,"\","-"] call CBA_fnc_replace;
	_factionIndex = lbCurSel FACTION_LIST;
	_faction = lbText [FACTION_LIST, _factionIndex];
	_factionCfg = [lbData [FACTION_LIST, _factionIndex],"\","\\"] call CBA_fnc_replace;
	_sizeIndex = lbCurSel SIZE_LIST;
	_size = lbData [SIZE_LIST, _sizeIndex];
	_typeIndex = lbCurSel TYPE_LIST;
	_type = lbText [TYPE_LIST, _typeIndex];
	_typeCfg = [lbData [TYPE_LIST, _typeIndex],"\","\\"] call CBA_fnc_replace;
	_activityIndex = lbCurSel ACTIVITY_LIST;
	_activity = lbText [ACTIVITY_LIST, _activityIndex];
	_factivityIndex = lbCurSel FACTIVITY_LIST;
	_factivity = lbText [FACTIVITY_LIST, _factivityIndex];
	_remarks = [ctrlText REMARKS_VALUE,"\","-"] call CBA_fnc_replace;
	_remarks = [_remarks, """", ""] call CBA_fnc_replace;
	_remarks = [_remarks, "'", ""] call CBA_fnc_replace;

	_spotrepHash = [] call ALIVE_fnc_hashCreate;

	[_spotrepHash, QMOD(SYS_spotrep_callsign), _callsign] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_DTG), _DTG] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_dateTime), _dateTime] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_loc), _loc] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_factionIndex), _factionIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_faction), _faction] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_factionCfg), _factionCfg] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_sizeIndex), _sizeIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_size), _size] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_typeIndex), _typeIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_type), _type] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_typeCfg), _typeCfg] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_activityIndex), _activityIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_activity), _activity] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_factivityIndex), _factivityIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_factivity), _factivity] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_remarks), _remarks] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_markername), _markerName] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_locality), _eyes] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_localityIndex), _eyesIndex] call ALIVE_fnc_hashSet;
	[_spotrepHash, QMOD(SYS_spotrep_player), getPlayerUID player] call ALIVE_fnc_hashSet;

	switch _eyes do {
		case "SIDE" : {
			[_spotrepHash, QMOD(SYS_spotrep_localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
		};
		case "GROUP" : {
			[_spotrepHash, QMOD(SYS_spotrep_localityValue), str (group player)] call ALIVE_fnc_hashSet;
		};
		case "FACTION" : {
			[_spotrepHash, QMOD(SYS_spotrep_localityValue), faction player] call ALIVE_fnc_hashSet;
		};
	};

	[MOD(sys_spotrep), "addspotrep", [_spotrepName, _spotrepHash]] call ALiVE_fnc_spotrep;

	[_markersHash, QGVAR(spotrep), _spotrepName] call ALIVE_fnc_hashSet;

};

// Create a marker

[MOD(SYS_marker), "addMarker", [_markerName, _markersHash]] call ALiVE_fnc_marker;

closeDialog 0;
