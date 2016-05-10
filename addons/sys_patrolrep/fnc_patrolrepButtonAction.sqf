#include <\x\alive\addons\sys_patrolrep\script_component.hpp>

SCRIPT(patrolrepButtonAction);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_patrolrepButtonAction
Description:
Handles the button action event for a dialog

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

private ["_params","_display","_patrolrepName","_patrolrepsHash"];

_display = findDisplay 90002;
_spotControl = _display displayCtrl SPOT_LIST;
_sitControl = _display displayCtrl SIT_LIST;

_patrolrepName = "PR" + str(random time + 1);

_patrolrepName = [_patrolrepName, ".", "N"] call CBA_fnc_replace;

_patrolrepHash = [] call ALIVE_fnc_hashCreate;

// Get all the patrolrep info
_DTG = ctrlText DTG_VALUE;
_sdateTime = [ctrlText SDATE_VALUE,"\","-"] call CBA_fnc_replace;
_edateTime = [ctrlText EDATE_VALUE,"\","-"] call CBA_fnc_replace;
_sloc = [ctrlText SLOC_VALUE,"\","-"] call CBA_fnc_replace;
_eloc = [ctrlText ELOC_VALUE,"\","-"] call CBA_fnc_replace;
_eyesIndex = lbCurSel EYES_LIST;
_eyes = lbData [EYES_LIST,_eyesIndex];
_callSign = [ctrlText NAME_VALUE,"\","-"] call CBA_fnc_replace;

_patcomp = [ctrlText PATCOMP_VALUE,"\","-"] call CBA_fnc_replace;
_task = [ctrlText TASK_VALUE,"\","-"] call CBA_fnc_replace;
_enbda = [ctrlText ENBDA_VALUE,"\","-"] call CBA_fnc_replace;
_results = [ctrlText RESULTS_VALUE,"\","-"] call CBA_fnc_replace;

_spotreps = [];
_sitreps =[];

_spotlist = lbSelection _spotControl;
{
	_spotreps set [count _spotreps, lbText [SPOT_LIST, _x]];
} foreach _spotlist;

_sitlist = lbSelection _sitControl;
{
	_sitreps set [count _sitreps, lbText [SIT_LIST, _x]];
} foreach _sitlist;

_ammo = lbText [AMMO_LIST, lbCurSel AMMO_LIST];
_cas = lbText [CAS_LIST, lbCurSel CAS_LIST];
_veh = lbText [VEH_LIST, lbCurSel VEH_LIST];
_cs = lbText [CS_LIST, lbCurSel CS_LIST];

[_patrolrepHash, QGVAR(player), getPlayerUID player] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(callsign), _callsign] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(DTG), _DTG] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(sdateTime), _sdateTime] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(edateTime), _edateTime] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(sloc), _sloc] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(eloc), _eloc] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(patcomp), _patcomp] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(task), _task] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(enbda), _enbda] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(results), _results] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(cs), _cs] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(ammo),_ammo] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(cas),_cas] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(veh), _veh] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(spotreps), _spotreps] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(sitreps), _sitreps] call ALIVE_fnc_hashSet;

[_patrolrepHash, QGVAR(group), str(group player)] call ALIVE_fnc_hashSet;

[_patrolrepHash, QGVAR(spos), GVAR(spos)] call ALIVE_fnc_hashSet;
[_patrolrepHash, QGVAR(epos), GVAR(epos)] call ALIVE_fnc_hashSet;

switch _eyes do {
	case "SIDE" : {
		[_patrolrepHash, QGVAR(localityValue), str(side (group player))] call ALIVE_fnc_hashSet;
	};
	case "GROUP" : {
		[_patrolrepHash, QGVAR(localityValue), str (group player)] call ALIVE_fnc_hashSet;
	};
	case "FACTION" : {
		[_patrolrepHash, QGVAR(localityValue), faction player] call ALIVE_fnc_hashSet;
	};
};

if !(isNil QGVAR(mapStartMarker)) then {
	deleteMarkerLocal GVAR(mapStartMarker);
};

if !(isNil QGVAR(mapEndMarker)) then {
	deleteMarkerLocal GVAR(mapEndMarker);
};

// Create a patrolrep

[MOD(SYS_patrolrep), "addpatrolrep", [_patrolrepName, _patrolrepHash]] call ALiVE_fnc_patrolrep;

closeDialog 0;
