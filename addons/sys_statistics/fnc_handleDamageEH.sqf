/*
 * Filename:
 * fnc_handleDamageEH.sqf
 *
 * Description:
 * Extended handleDamage Eventhandler
 *
 * Created by Tupolov
 * Creation date: 21/03/2013
 *
 * */

// ====================================================================================
// MAIN
#define DEBUG_MODE_FULL

#include "script_component.hpp"
if (GVAR(ENABLED)) then {
	private ["_sidewounded","_sidesource","_woundedtype","_sourceweapon","_sourcetype","_distance","_datetime","_factionsource","_factionwounded","_data","_woundedPos","_sourcePos","_server","_realtime","_source","_wounded","_woundedVehicleClass","_sourceVehicleClass"];

	// Set Data
	_wounded = _this select 0;
	_hitSelection = _this select 1;
	_damage = _this select 2;
	_source = _this select 3;
	_projectile = _this select 4;

	if (isNull _source) then {
		_source = _wounded;
	};

	if ((isPlayer _wounded) || (isPlayer _source)) then {

		_sideWounded = side (group _wounded); // group side is more reliable
		_sidesource = side _source;

		_factionsource = getText (configFile >> "cfgFactionClasses" >> (faction _source) >> "displayName");
		_factionwounded = getText (configFile >> "cfgFactionClasses" >> (faction _wounded) >> "displayName");

		_woundedtype = getText (configFile >> "cfgVehicles" >> (typeof _wounded) >> "displayName");
		_sourcetype = getText (configFile >> "cfgVehicles" >> (typeof _source) >> "displayName");

		_woundedVehicleClass = "None";
		_sourceVehicleClass = "None";

		switch true do {
			case (_wounded isKindof "LandVehicle"): {_woundedVehicleClass = "Vehicle";};
			case (_wounded isKindof "Air"): {_woundedVehicleClass = "Aircraft";};
			case (_wounded isKindof "Ship"): {_woundedVehicleClass = "Ship";};
			case (_wounded isKindof "Man"): {_woundedVehicleClass = "Infantry";};

			case default {_woundedVehicleClass = "Other";};
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

		if (vehicle _source != _source) then {
				_sourceweapon = _sourceweapon + format[" (%1)", getText (configFile >> "cfgVehicles" >> (typeof (vehicle _source)) >> "displayName")];
				_sourceweaponType = currentweapon (vehicle _source);
		};

		_distance = ceil(_wounded distance _source);

		_woundedPos = mapgridposition _wounded;
		_sourcePos = mapgridposition _source;

		if (_hitSelection == "head_hit") then { _hitSelection = "head"; };
		if (_hitSelection == "") then { _hitSelection = "body"; };

		// Log data
		_data = [ ["Event","Wounded"] , ["woundedSide",_sidewounded,] , ["woundedfaction",_factionwounded] , ["woundedType", _woundedType] , ["woundedClass",_woundedVehicleClass] , ["woundedPos",_woundedPos] , ["sourceSide",_sidesource] , ["sourcefaction",_factionsource] , ["sourceType",_sourceType] , ["sourceClass",_sourceVehicleClass] , ["sourcePos",_sourcePos] , ["Weapon",_sourceweapon] , ["WeaponType",_sourceweaponType] ,["Distance",_distance],["wounded",_wounded] , ["source",_source] , ["projectile",_projectile], ["wound",_hitSelection], ["damage",_damage] ];


		if (isPlayer _wounded) then { // Player was wounded

				_data = _data + [["PlayerWounded","true"] , ["Player",getplayeruid _wounded] , ["PlayerName", name _wounded ], ["playerGroup", _wounded getvariable [QGVAR(playerGroup), "Unknown"]]];

				// Send data to server to be written to DB
				ALIVE_SYS_STAT_UPDATE_EVENTS = _data;
				publicVariableServer "ALIVE_SYS_STAT_UPDATE_EVENTS";

		};

		if (isPlayer _source) then {

				_data = _data + [["Player",getplayeruid _source] , ["PlayerName",name _source], ["playerGroup", _source getvariable [QGVAR(playerGroup), "Unknown"]]];

				// Send data to server to be written to DB
				ALIVE_SYS_STAT_UPDATE_EVENTS = _data;
				publicVariableServer "ALIVE_SYS_STAT_UPDATE_EVENTS";

		};




	};
};
	_this select 2;
// ====================================================================================