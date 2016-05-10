#include <\x\alive\addons\sys_patrolrep\script_component.hpp>

SCRIPT(patrolrepOnMapEvent);

private ["_display", "_markerName", "_map", "_button", "_pos", "_marker","_text"];

_display = findDisplay 90001;
_map = _this select 0;
_button = _this select 1; if (_button == 1) exitWith {};
_pos = _map ctrlMapScreenToWorld [_this select 2, _this select 3];

_markerName = "PR" + str(random time + 1);

if (GVAR(mapState) == "START") then {

	if !(isNil QGVAR(mapStartMarker)) then {
		deleteMarkerLocal GVAR(mapStartMarker);
	};

	_marker = createMarkerLocal [_markerName, _pos];
	GVAR(mapStartMarker) = _marker;

	_text = "PATROLREP START";
	GVAR(spos) = _pos;
	ctrlSetText [SLOC_VALUE, mapGridPosition _pos];
	GVAR(mapState) = "END";

} else {

	if !(isNil QGVAR(mapEndMarker)) then {
		 deleteMarkerLocal GVAR(mapEndMarker);
	};

	_marker = createMarkerLocal [_markerName, _pos];
	GVAR(mapEndMarker) = _marker;

	_text = "PATROLREP END";
	GVAR(epos) = _pos;
	ctrlSetText [ELOC_VALUE, mapGridPosition _pos];
	GVAR(mapState) = "START";
};

ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _pos];
ctrlMapAnimCommit _map;

_marker setMarkerPosLocal _pos;
_marker setMarkerAlphaLocal 1;

_marker setMarkerTextLocal _text;
_marker setMarkerTypeLocal "mil_marker";