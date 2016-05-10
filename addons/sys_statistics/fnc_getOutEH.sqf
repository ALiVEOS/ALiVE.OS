/* ----------------------------------------------------------------------------
Function: ALIVE_sys_stat_fnc_getOutEH
Description:
Handles a unit getOut event for all players. Is defined using XEH_postClientInit.sqf in the sys_stat module. Sends the information to the ALIVE website as a "GetOut" record

Parameters:
Object - the vehicle unit gets out of
String - position in the vehicle that the unit was in
Object - unit that got out

Returns:
Nothing

Attributes:
None

Parameters:
_this select 0: OBJECT - vehicle
_this select 1: STRING - position
_this select 2: OBJECT - unit


Examples:
(begin example)
	player addEventHandler ["getOut", {_this call GVAR(fnc_getOutEH);}];
(end)

See Also:
- <ALIVE_sys_stat_fnc_firedEH>
- <ALIVE_sys_stat_fnc_incomingMissileEH>
- <ALIVE_sys_stat_fnc_handleDamageEH>

Author:
Tupolov
---------------------------------------------------------------------------- */
// MAIN
#define DEBUG_MODE_FULL

#include "script_component.hpp"
if (GVAR(ENABLED)) then {
	private ["_sideunit","_sidevehicle","_unittype","_vehicleweapon","_vehicletype","_distance","_datetime","_factionvehicle","_factionunit","_data","_unitPos","_vehiclePos","_server","_realtime","_vehicle","_unit","_unitVehicleClass","_vehicleVehicleClass","_position"];

	// Set Data
	_vehicle = _this select 0;
	_position = _this select 1;
	_unit = _this select 2;

	//diag_log format["GetOut: %1", _this];

	if (local _unit && isPlayer _unit) then {

		_sideunit = side (group _unit); // group side is more reliable
		_sidevehicle = side _vehicle;

		_factionvehicle = getText (configFile >> "cfgFactionClasses" >> (faction _vehicle) >> "displayName");
		_factionunit = getText (configFile >> "cfgFactionClasses" >> (faction _unit) >> "displayName");

		_unittype = getText (configFile >> "cfgVehicles" >> (typeof _unit) >> "displayName");
		_vehicletype = getText (configFile >> "cfgVehicles" >> (typeof _vehicle) >> "displayName");
		_vehiclecfg = typeof _vehicle;

		_unitVehicleClass = "Infantry";
		_vehicleVehicleClass = "None";

		_unitCfg = typeOf _unit;

		switch true do {
			case (_vehicle isKindof "LandVehicle"): {_vehicleVehicleClass = "Vehicle";};
			case (_vehicle isKindof "Air"): {_vehicleVehicleClass = "Aircraft";};
			case (_vehicle isKindof "Ship"): {_vehicleVehicleClass = "Ship";};
			case (_vehicle isKindof "Man"): {_vehicleVehicleClass = "Infantry";};

			case default {_vehicleVehicleClass = "Other";};
		};

		_unitPos = mapgridposition _unit;
		_unitGeoPos = position _unit;
		_vehiclePos = mapgridposition _vehicle;
		_unit setVariable [QGVAR(GetOutTime), diag_tickTime, true];


		// Set Player time spent in vehicle
		_vehMinutes = round(((_unit getVariable QGVAR(GetOutTime)) - (_unit getVariable QGVAR(GetInTime)))/60);

		// Check to see if this is a para jump
		_height = (getposATL _unit) select 2;
		if ( (_vehicle isKindof "Air") && (_height > 100) ) then {

			_data = [ ["Event","ParaJump"] , ["unitSide",_sideunit] , ["unitfaction",_factionunit] , ["unitType",_unitType] , ["unitClass",_unitVehicleClass] , ["unitPos",_unitPos] , ["unitGeoPos",_unitGeoPos] , ["vehicleSide",_sidevehicle] , ["vehiclefaction",_factionvehicle] , ["vehicleType",_vehicleType] , ["vehicleClass",_vehicleVehicleClass] , ["vehiclePos",_position] , ["unit",str(_unit)] , ["vehicle",_vehicle] , ["vehiclePosition",_vehiclePos] , ["vehicleMinutes", _vehMinutes], ["vehicleConfig",_vehiclecfg] , ["jumpHeight",_height], ["unitConfig",_unitCfg]   ];

			_data = _data + [ ["Player",getplayeruid _unit], ["playerGroup", _unit getvariable [QGVAR(playerGroup), "Unknown"]] , ["PlayerName",name _unit] ];

			// Send data to server to be written to DB
			GVAR(UPDATE_EVENTS) = _data;
			publicVariableServer QGVAR(UPDATE_EVENTS);
		} else {
			// Log data
			_data = [ ["Event","GetOut"] , ["unitSide",_sideunit] , ["unitfaction",_factionunit] , ["unitType",_unitType] , ["unitClass",_unitVehicleClass] , ["unitPos",_unitPos] , ["unitGeoPos",_unitGeoPos] , ["vehicleSide",_sidevehicle] , ["vehiclefaction",_factionvehicle] , ["vehicleType",_vehicleType] , ["vehicleClass",_vehicleVehicleClass] , ["vehiclePos",_position] , ["unit",_unit] , ["vehicle",_vehicle] , ["vehiclePosition",_vehiclePos] , ["vehicleMinutes",_vehMinutes], ["vehicleConfig",_vehiclecfg], ["unitConfig",_unitCfg]   ];

			_data = _data + [ ["Player",getplayeruid _unit], ["playerGroup", [_unit] call ALiVE_fnc_getPlayerGroup] , ["PlayerName",name _unit] ];

			// Send data to server to be written to DB
			GVAR(UPDATE_EVENTS) = _data;
			publicVariableServer QGVAR(UPDATE_EVENTS);
		};
	};
};

// ====================================================================================