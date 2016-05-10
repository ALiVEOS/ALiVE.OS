#include <\x\alive\addons\sys_patrolrep\script_component.hpp>

SCRIPT(patrolrepOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_patrolrepOnLoad
Description:
Handles the onload event for a dialog

Parameters:
_this select 0: DISPLAY - Reference to calling display

Returns:
Nil

See Also:
- <ALIVE_fnc_patrolrep>

Author:
Tupolov

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

// SPAGHETTI!

private ["_params","_display","_color","_ValueIcon","_ValueSize","_ValueClass","_ValueFill","_class","_brush","_type","_i","_map","_pos","_data"];

_params = _this select 0;

_display = _params select 0;

// Map
_map = _display displayCtrl PATROLREP_MAP;
ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, 1, position player];
ctrlMapAnimCommit _map;
_map ctrlSetEventHandler ["MouseButtonDown", "_this call ALiVE_fnc_patrolrepOnMapEvent"];

GVAR(epos) = position player;
GVAR(mapState) = "START";

// Ammo
_ammoControl = _display displayctrl AMMO_LIST;

// CAS
_casControl = _display displayctrl CAS_LIST;

// veh
_vehControl = _display displayctrl VEH_LIST;

// veh
_csControl = _display displayctrl CS_LIST;

_state = [
	["GREEN", 1],
	["AMBER", 2],
	["RED", 3]
];

{
	_index = _ammoControl lbAdd (_x select 0);
	_ammoControl lbSetData [_index, str(_x select 1)];
	_index = _casControl lbAdd (_x select 0);
	_casControl lbSetData [_index, str(_x select 1)];
	_index = _vehControl lbAdd (_x select 0);
	_vehControl lbSetData [_index, str(_x select 1)];
	_index = _csControl lbAdd (_x select 0);
	_csControl lbSetData [_index, str(_x select 1)];
} foreach _state;


// SPOTREPS
private "_spotreps";
_spotreps = {
	private ["_spotControl"];
	_spotControl = _display displayCtrl SPOT_LIST;
	_spotControl lbAdd _key;
};


[[MOD(SYS_spotrep), "state"] call ALIVE_fnc_spotrep, _spotreps] call CBA_fnc_hashEachPair;

// SITREPS
private "_sitreps";
_sitreps = {
	private ["_sitControl"];
	_sitControl = _display displayCtrl SIT_LIST;
	_sitControl lbAdd _key;
};

[[MOD(SYS_sitrep), "state"] call ALIVE_fnc_sitrep, _sitreps] call CBA_fnc_hashEachPair;


// Eyes Only
_eyesControl = _display displayctrl EYES_LIST;
_eyes = [
	["UNCLASSIFIED (PUBLIC)", "GLOBAL"],
	[format ["CLASSIFIED Confidential (%1 ONLY)", side player], "SIDE"],
	[format ["CLASSIFIED Secret (%1 ONLY)", getText (configFile >> "CfgFactionClasses" >> faction player >> "displayName")], "FACTION"],
	[format ["CLASSIFIED Top Secret (%1 ONLY)", group player], "GROUP"],
	["PRIVATE", "LOCAL"]
];

{
	_index = _eyesControl lbAdd (_x select 0);
	_eyesControl lbSetData [_index, (_x select 1)];
} foreach _eyes;


///--- Initial icon set (after delay to distinguish icon/brush)
[] spawn {
		private ["_markere","_markers","_eyesControl","_markerName"];

		disableSerialization;
		_eyesControl = (findDisplay 90001) displayCtrl EYES_LIST;

		// Set UI controls to defaults
		ctrlSetText [NAME_VALUE, str(player)];
		ctrlSetText [DTG_VALUE, [date] call ALIVE_fnc_dateToDTG];
		ctrlSetText [SDATE_VALUE, [GVAR(sdate)] call ALIVE_fnc_dateToDTG];
		ctrlSetText [SLOC_VALUE, mapGridPosition (GVAR(spos))];
		ctrlSetText [EDATE_VALUE, [date] call ALIVE_fnc_dateToDTG];
		ctrlSetText [ELOC_VALUE, mapGridPosition (position player)];
		lbSetCurSel [EYES_LIST, 1];

		_markerName = "PR" + str(random time + 1);
		_markers = createMarkerLocal [_markerName + "START", GVAR(spos)];
		_markers setMarkerAlphaLocal 1;
		_markers setMarkerTextLocal "PATROLREP START";
		_markers setMarkerTypeLocal "mil_marker";
		GVAR(mapStartMarker) = _markers;

		_markere = createMarkerLocal [_markerName + "END", (position player)];
		_markere setMarkerAlphaLocal 1;
		_markere setMarkerTextLocal "PATROLREP END";
		_markere setMarkerTypeLocal "mil_marker";
		GVAR(mapEndMarker) = _markere;
};

//Sets all static texts toUpper---------------------------------------------------------------------------------------------
_classInsideControls = configfile >> "RscDisplayALiVEPATROLREP" >> "controls";

for "_i" from 0 to (count _classInsideControls - 1) do {   //go to all subclasses
	_current = _classInsideControls select _i;

	//do not toUpper texts inserted by player
	if ( (configName(inheritsFrom(_current)) != "patrolrep_RscEdit")
		&& (configName(inheritsFrom(_current)) != "patrolrep_RscText")
		&& (configName(inheritsFrom(_current)) != "patrolrep_RscGUIListBox") ) then
	{
		//search inside main controls class
		_idc = getnumber (_current >> "idc");
		_control = _display displayctrl _idc;
		// Set combos to 0
		if (getnumber (_current >> "type") == 4) then {
			_control lbSetCurSel 0;
		} else {
			_control ctrlSetText (toUpper (ctrlText _control));
		};

	};
};
//Sets all static texts toUpper---------------------------------------------------------------------------------------------
