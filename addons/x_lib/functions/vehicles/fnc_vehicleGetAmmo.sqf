#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGetAmmo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGetAmmo

Description:
Returns an array of magazines with current and max round counts.

Parameters:
Vehicle - The vehicle

Returns:
Array of magazine ammo classnames, current and max counts  [["2000Rnd_65x39_Belt_Tracer_Green","1846","2000"],["12Rnd_PG_missiles","5","12"],["180Rnd_CMFlare_Chaff_Magazine","180","180"]]

Examples:
(begin example)
_result = _vehicle call ALIVE_fnc_vehicleGetAmmo;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_type","_result","_magazines","_magazinesDetail","_turrets","_magazine","_detail","_detailSplit","_ammoCount","_ammoMax"];
	
_vehicle = _this;

_result = [];
_type = typeof _vehicle;
_magazines = magazines _vehicle;
_magazinesDetail = magazinesDetail _vehicle;

//["magazines: %1",_magazines] call ALIVE_fnc_dump;
//["magazines detail: %1",_magazinesDetail] call ALIVE_fnc_dump;

// need to test this with turreted vehicles..
//_turrets = [_type] call ALIVE_fnc_configGetVehicleTurrets;
//["turrets: %1",_turrets] call ALIVE_fnc_dump;

for "_i" from 0 to (count _magazines)-1 do {
	_magazine = [];
	_magazine set [0, _magazines select _i];
	_detail = _magazinesDetail select _i;
	_detailSplit = [_detail, "("] call CBA_fnc_split;
	_detail = _detailSplit select (count _detailSplit)-1;
	_detailSplit = [_detail, "/"] call CBA_fnc_split;
	_ammoCount = parseNumber(_detailSplit select 0);
	_detail = _detailSplit select 1;
	_detailSplit = [_detail, ")"] call CBA_fnc_split;
	_ammoMax = parseNumber(_detailSplit select 0);
	_magazine set [1, _ammoCount];
	_magazine set [2, _ammoMax];
	_result set [_i, _magazine];
};

_result