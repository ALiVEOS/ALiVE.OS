/* ----------------------------------------------------------------------------
Function: ALIVE_sys_stat_fnc_landedTouchDownEH
Description:
Handles a unit landedTouchDown event for all players. Is defined using XEH_postClientInit.sqf in the sys_stat module. Sends the information to the ALIVE website as a "Landed" record

Parameters:
Object - the vehicle unit gets out of
Integer - airport ID

Returns:
Nothing

Attributes:
None

Parameters:
_this select 0: OBJECT - vehicle
_this select 1: INTEGER - airport


Examples:
(begin example)
	player addEventHandler ["landedTouchDown", {_this call GVAR(fnc_landedTouchDownEH);}];
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
	private ["_ptime","_LandedInterval","_sidevehicle","_vehicletype","_factionvehicle","_data","_vehiclePos","_vehicle","_airport"];

	// Set Data
	_vehicle = _this select 0;
	_airport = _this select 1;

	diag_log format["LandedTouchDown: %1", _this];

	if (isPlayer (driver _vehicle)) then {
		// Check to see if vehicle is having a "bumpy" landing
		_LandedInterval = time - (_vehicle getVariable [QGVAR(LandedTime),31]);

		diag_log format["Last landed %1 seconds ago (%2)", _LandedInterval, time];

		if (_LandedInterval > 30) then {
			_sidevehicle = side (group _vehicle); // group side is more reliable

			_factionvehicle = getText (configFile >> "cfgFactionClasses" >> (faction _vehicle) >> "displayName");

			_vehicletype = getText (configFile >> "cfgVehicles" >> (typeof _vehicle) >> "displayName");
			_vehicleConfig = typeOf _vehicle;

			_vehiclePos = mapgridposition _vehicle;
			_vehicleGeoPos = position _vehicle;

			_ptime = time;
			_vehicle setVariable [QGVAR(LandedTime), _ptime, true];

			// Log data
			_data = [ ["Event","Landed"] , ["vehicleSide",_sidevehicle] , ["vehiclefaction",_factionvehicle] , ["vehicleType",_vehicleType] , ["vehiclePos",_vehiclePos] , ["vehicleGeoPos",_vehicleGeoPos] , ["vehicle",_vehicle] , ["Airport",_airport], ["vehicleConfig",_vehicleConfig] ];

			_data = _data + [ ["Player",getplayeruid _vehicle] , ["PlayerName",name _vehicle], ["playerGroup", [(driver _vehicle)] call ALiVE_fnc_getPlayerGroup] ];

			// Send data to server to be written to DB
			GVAR(UPDATE_EVENTS) = _data;
			publicVariableServer QGVAR(UPDATE_EVENTS);

		};
	};
};
// ====================================================================================