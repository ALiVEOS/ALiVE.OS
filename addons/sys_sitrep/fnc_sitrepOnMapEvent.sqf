#include <\x\alive\addons\sys_sitrep\script_component.hpp>

SCRIPT(sitrepOnMapEvent);

LOG(str _this);

private ["_display", "_markerName", "_map", "_button", "_pos", "_marker"];

_display = findDisplay 90001;
_map = _this select 0;
_button = _this select 1; if (_button == 1) exitWith {};
_pos = _map ctrlMapScreenToWorld [_this select 2, _this select 3];
_markerName = "MK" + str(random time + 1);


if !(isNil QGVAR(mapStartMarker)) then {
	deleteMarkerLocal GVAR(mapStartMarker);
};

_marker = createMarkerLocal [_markerName, _pos];
GVAR(mapStartMarker) = _marker;

ctrlMapAnimClear _map;
_map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _pos];
ctrlMapAnimCommit _map;

_marker setMarkerPosLocal _pos;
_marker setMarkerAlphaLocal 1;

_marker setMarkerTextLocal "SITREP";
_marker setMarkerTypeLocal "mil_marker";

GVAR(pos) = _pos;

ctrlSetText [LOC_VALUE, mapGridPosition _pos];