/* ----------------------------------------------------------------------------
Function: ALIVE_sys_stat_fnc_hitEH
Description:
Handles a unit hit event for all players. Is defined using XEH_postClientInit.sqf in the sys_stat module. Sends the information to the ALIVE website as a "Hit" record

Parameters:
Object - the unit that was hit
Object - the unit that caused the hit
Float - damage to the unit

Returns:
Nothing

Attributes:
None

Parameters:
_this select 0: OBJECT - unit hit
_this select 1: OBJECT - unit causing the hit
_this select 2: FLOAT - damage done


Examples:
(begin example)
	player addEventHandler ["hit", {_this call GVAR(fnc_hitEH);}];
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
	private ["_msg","_sidehit","_sidesource","_hittype","_sourceweapon","_sourcetype","_distance","_datetime","_factionsource","_factionhit","_data","_hitPos","_sourcePos","_server","_realtime","_source","_hit","_hitVehicleClass","_sourceVehicleClass"];

	// Set Data
	_hit = _this select 0;
	_source = _this select 1;
	_damage = _this select 2;

	if (isNull _source) then {
		_source = _hit;
	};

	if ( ((isPlayer _hit) || (isPlayer _source)) && MOD(sys_data) getVariable ["EventLevel",5] > 5) then {

		_sidehit = side (group _hit); // group side is more reliable
		_sidesource = side _source;

		_factionsource = getText (configFile >> "cfgFactionClasses" >> (faction _source) >> "displayName");
		_factionhit = getText (configFile >> "cfgFactionClasses" >> (faction _hit) >> "displayName");

		_hittype = getText (configFile >> "cfgVehicles" >> (typeof _hit) >> "displayName");
		_sourcetype = getText (configFile >> "cfgVehicles" >> (typeof _source) >> "displayName");
		_sourcecfg = typeOf _source;
		_hitcfg = typeOf _hit;

		_hitVehicleClass = "None";
		_sourceVehicleClass = "None";

		switch true do {
			case (_hit isKindof "LandVehicle"): {_hitVehicleClass = "Vehicle";};
			case (_hit isKindof "Air"): {_hitVehicleClass = "Aircraft";};
			case (_hit isKindof "Ship"): {_hitVehicleClass = "Ship";};
			case (_hit isKindof "Man"): {_hitVehicleClass = "Infantry";};

			case default {_hitVehicleClass = "Other";};
		};

		switch true do {
			case (_source isKindof "LandVehicle"): {_sourceVehicleClass = "Vehicle";};
			case (_source isKindof "Air"): {_sourceVehicleClass = "Aircraft";};
			case (_source isKindof "Ship"): {_sourceVehicleClass = "Ship";};
			case (_source isKindof "Man"): {_sourceVehicleClass = "Infantry";};

			case default {_sourceVehicleClass = "Other";};
		};

		_sourceweapon = getText (configFile >> "cfgWeapons" >> (currentweapon _source) >> "displayName");
		_sourceweaponType = currentweapon _source;

		if !(_source isKindof "Man") then {
				_sourceweapon = _sourceweapon + format[" (%1)", getText (configFile >> "cfgVehicles" >> (typeof (vehicle _source)) >> "displayName")];
		};

		_distance = ceil(_hit distance _source);

		_hitPos = mapgridposition _hit;
		_hitGeoPos = position _hit;
		_sourcePos = mapgridposition _source;
		_sourceGeoPos = position _source;

		// Log data
		_data = [ ["Event","Hit"] , ["hitSide",_sidehit] , ["hitfaction",_factionhit] , ["hitType",_hitType] , ["hitClass",_hitVehicleClass] ,["hitPos",_hitPos] , ["hitGeoPos",_hitGeoPos] ,["sourceSide",_sidesource] , ["sourcefaction",_factionsource] , ["sourceType",_sourceType] , ["sourceClass", _sourceVehicleClass] , ["sourcePos",_sourcePos] , ["sourceGeoPos",_sourceGeoPos] , ["Weapon",_sourceweapon] , ["WeaponType",_sourceweaponType] , ["Distance",_distance] , ["hit",_hit] , ["source",_source] , ["damage",_damage] , ["sourceCfg",_sourcecfg] , ["hitCfg",_hitcfg] ];

		if (isPlayer _hit && (getPlayerUID _hit != getPlayerUID _source)) then { // Player was hit

				_data = _data + [ ["PlayerHit","true"] , ["Player",getplayeruid _hit] , ["PlayerName",name _hit], ["playerGroup", [_hit] call ALiVE_fnc_getPlayerGroup] ];

				// Send data to server to be written to DB
				GVAR(UPDATE_EVENTS) = _data;
				publicVariableServer QGVAR(UPDATE_EVENTS);

		};

		if (isPlayer _source && (getPlayerUID _hit != getPlayerUID _source)) then {

				if (_damage > 0.5) then {
					_data = _data + [ ["Disabled","true"] ];
				};
				_data = _data + [ ["Player",getplayeruid _source] , ["PlayerName",name _source], ["playerGroup", [_source] call ALiVE_fnc_getPlayerGroup] ];

				// Send data to server to be written to DB
				GVAR(UPDATE_EVENTS) = _data;
				publicVariableServer QGVAR(UPDATE_EVENTS);

		};

	};
};
// ====================================================================================