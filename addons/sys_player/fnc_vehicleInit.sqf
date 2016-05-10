#include <\x\alive\addons\sys_player\script_component.hpp>
SCRIPT(vehicleInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleInit
Description:
Gives each vehicle a unique name in game for persistence purposes

Parameters:
Object - If Nil, return a new instance. If Object, reference an existing instance.

Returns:
None

Examples:
(begin example)
//
(end)

See Also:
- <ALIVE_fnc_playerInit>
- <ALIVE_fnc_playerMenuDef>

Author:
Tupolov

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_vehicle","_vehicleID"];

_vehicle = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;

if (isServer && !isHC) then {
	if (isNil QGVAR(VEHICLEID)) then {
		GVAR(VEHICLEID) = 0;
	};

	if ((_vehicle getVariable ["vehicleID","MISSING"]) == "MISSING" && vehicleVarName _vehicle == "") then {
		_vehicleID = format ["vehicle_%1",GVAR(VEHICLEID)];

		TRACE_2("SYS_PLAYER giving vehicle an ID", _vehicle, _vehicleID);

		_vehicle setVariable ["vehicleID", _vehicleID, true];
		_vehicle setVehicleVarName _vehicleID;
		_vehicle call compile format ["%1 = _this; publicVariable ""%1""", _vehicleID];

		GVAR(VEHICLEID) = GVAR(VEHICLEID) + 1;
	};
};

