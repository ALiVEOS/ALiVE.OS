#include <\x\alive\addons\sys_sitrep\script_component.hpp>

SCRIPT(sitrepButtonAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepButtonAction
Description:
Handles the button action event for a dialog

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

private ["_params","_display","_sitrepName","_sitrepsHash"];

_display = findDisplay 90001;

_sitrepName = "ST" + str(random time + 1);

_sitrepName = [_sitrepName, ".", "N"] call CBA_fnc_replace;

_sitrepHash = [] call ALIVE_fnc_hashCreate;

// Get all the sitrep info
_DTG = ctrlText DTG_VALUE;
_dateTime = [ctrlText DATE_VALUE,"\","-"] call CBA_fnc_replace;
_loc = [ctrlText LOC_VALUE,"\","-"] call CBA_fnc_replace;
_remarks = [ctrlText REMARKS_VALUE,"\","-"] call CBA_fnc_replace;
_eyesIndex = lbCurSel EYES_LIST;
_eyes = lbData [EYES_LIST,_eyesIndex];
_callSign = [ctrlText NAME_VALUE,"\","-"] call CBA_fnc_replace;

_ekia = [ctrlText EKIA_VALUE,"\","-"] call CBA_fnc_replace;
_en = [ctrlText EN_VALUE,"\","-"] call CBA_fnc_replace;
_civ = [ctrlText CIV_VALUE,"\","-"] call CBA_fnc_replace;
_fkia = [ctrlText FKIA_VALUE,"\","-"] call CBA_fnc_replace;
_fwia = [ctrlText FWIA_VALUE,"\","-"] call CBA_fnc_replace;
_ff = [ctrlText FF_VALUE,"\","-"] call CBA_fnc_replace;


_ammo = lbText [AMMO_LIST, lbCurSel AMMO_LIST];
_cas = lbText [CAS_LIST, lbCurSel CAS_LIST];
_veh = lbText [VEH_LIST, lbCurSel VEH_LIST];
_cs = lbText [CS_LIST, lbCurSel CS_LIST];

[_sitrepHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(callsign), _callsign] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(DTG), _DTG] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(dateTime), _dateTime] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(loc), _loc] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(remarks), _remarks] call ALIVE_fnc_hashSet;

[_sitrepHash, QGVAR(ekia), _ekia] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(en), _en] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(civ), _civ] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(fkia), _fkia] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(fwia), _fwia] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(ff), _ff] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(ammo), _ammo] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(cas), _cas] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(veh), _veh] call ALIVE_fnc_hashSet;
[_sitrepHash, QGVAR(cs), _cs] call ALIVE_fnc_hashSet;

[_sitrepHash, QGVAR(group), str(group player)] call ALIVE_fnc_hashSet;

[_sitrepHash, QGVAR(pos), GVAR(pos)] call ALIVE_fnc_hashSet;



switch _eyes do {
	case "SIDE" : {
		[_sitrepHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
	};
	case "GROUP" : {
		[_sitrepHash, QGVAR(localityValue), str (group player)] call ALIVE_fnc_hashSet;
	};
	case "FACTION" : {
		[_sitrepHash, QGVAR(localityValue), faction player] call ALIVE_fnc_hashSet;
	};
};

if !(isNil QGVAR(mapStartMarker)) then {
	deleteMarkerLocal GVAR(mapStartMarker);
};

// Create a sitrep

[MOD(SYS_sitrep), "addsitrep", [_sitrepName, _sitrepHash]] call ALiVE_fnc_sitrep;



closeDialog 0;
