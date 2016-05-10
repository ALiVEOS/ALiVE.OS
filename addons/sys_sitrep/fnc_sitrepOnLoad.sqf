#include <\x\alive\addons\sys_sitrep\script_component.hpp>

SCRIPT(sitrepOnLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepOnLoad
Description:
Handles the onload event for a dialog

Parameters:
_this select 0: DISPLAY - Reference to calling display

Returns:
Nil

See Also:
- <ALIVE_fnc_sitrep>

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
_map = _display displayCtrl SITREP_MAP;
ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, 1, position player];
ctrlMapAnimCommit _map;
_map ctrlSetEventHandler ["MouseButtonDown", "_this call ALiVE_fnc_sitrepOnMapEvent"];

GVAR(pos) = position player;

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
		private ["_ammoControl","_casControl","_eyesControl"];

		disableSerialization;
		_eyesControl = (findDisplay 90001) displayCtrl EYES_LIST;

		// Set UI controls to defaults
		ctrlSetText [NAME_VALUE, str(player)];
		ctrlSetText [DTG_VALUE, [date] call ALIVE_fnc_dateToDTG];
		ctrlSetText [DATE_VALUE, [date] call ALIVE_fnc_dateToDTG];
		ctrlSetText [LOC_VALUE, mapGridPosition (position player)];
		lbSetCurSel [EYES_LIST, 1];

};

//Sets all static texts toUpper---------------------------------------------------------------------------------------------
_classInsideControls = configfile >> "RscDisplayALiVESITREP" >> "controls";

for "_i" from 0 to (count _classInsideControls - 1) do {   //go to all subclasses
	_current = _classInsideControls select _i;

	//do not toUpper texts inserted by player
	if ( (configName(inheritsFrom(_current)) != "SITREP_RscEdit")
		&& (configName(inheritsFrom(_current)) != "SITREP_RscText") ) then
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
