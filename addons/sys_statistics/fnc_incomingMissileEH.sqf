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
	private ["_sidetarget","_sidesource","_targettype","_sourceweapon","_sourcetype","_distance","_datetime","_factionsource","_factiontarget","_data","_targetPos","_sourcePos","_source","_target","_targetVehicleClass","_sourceVehicleClass","_currenttime","_projectile"];

	// Set Data
	_target = _this select 0;
	_projectile = _this select 1;
	_source = _this select 2;

	if (isServer) then {
		// diag_log _this;

		if ((isPlayer _target) || (isPlayer _source) || (isPlayer (gunner _target))  || (isPlayer (gunner _source)) ) then {

			_sideTarget = side (group _target); // group side is more reliable
			_sidesource = side _source;

			_factionsource = getText (configFile >> "cfgFactionClasses" >> (faction _source) >> "displayName");
			_factionTarget = getText (configFile >> "cfgFactionClasses" >> (faction _target) >> "displayName");

			_targettype = getText (configFile >> "cfgVehicles" >> (typeof _target) >> "displayName");
			_sourcetype = getText (configFile >> "cfgVehicles" >> (typeof _source) >> "displayName");

			_sourcecfg = typeOf _source;
			_targetcfg = typeOf _target;

			_targetVehicleClass = "None";
			_sourceVehicleClass = "None";

			switch (true) do {
				case (_target isKindof "LandVehicle"): {_targetVehicleClass = "Vehicle";};
				case (_target isKindof "Air"): {_targetVehicleClass = "Aircraft";};
				case (_target isKindof "Ship"): {_targetVehicleClass = "Ship";};
				case (_target isKindof "Man"): {_targetVehicleClass = "Infantry";};
				default {_targetVehicleClass = "Other";};
			};

			switch (true) do
			{
				case (_source isKindof "LandVehicle"):
				{
					_sourceVehicleClass = "Vehicle";
				};
				case (_source isKindof "Air"):
				{
					_sourceVehicleClass = "Aircraft";
				};
				case (_source isKindof "Ship"):
				{
					_sourceVehicleClass = "Ship";
				};
				case (_source isKindof "Man"):
				{
					_sourceVehicleClass = "Infantry";
				};
				default
				{
					_sourceVehicleClass = "Other";
				};
			};

			_sourceweapon = getText (configFile >> "cfgWeapons" >> (currentweapon _source) >> "displayName");
			_sourceweaponType = currentweapon _source;

			if !(_source isKindof "Man") then {
					_sourceweapon = _sourceweapon + format[" (%1)", getText (configFile >> "cfgVehicles" >> (typeof (vehicle _source)) >> "displayName")];
			};

			_distance = ceil(_target distance _source);

			_targetPos = mapgridposition _target;
			_targetGeoPos = position _target;
			_sourcePos = mapgridposition _source;
			_sourceGeoPos = position _source;

			// Log data
			_data = [ ["Event","Missile"] , ["targetSide",_sideTarget] , ["targetFaction",_factionTarget] , ["targetType",_targetType] , ["targetClass", _targetVehicleClass] , ["targetPos",_targetPos] , ["targetGeoPos",_targetGeoPos], ["sourceSide",_sidesource] , ["sourceFaction",_factionsource] , ["sourceType",_sourceType] , ["sourceClass",_sourceVehicleClass] , ["sourcePos", _sourcePos] , ["sourceGeoPos",_sourceGeoPos] , ["Weapon",_sourceweapon] , ["WeaponType",_sourceweaponType] ,["Distance",_distance] , ["target",_target] , ["source",_source] , ["projectile", _projectile], ["sourceCfg",_sourcecfg] , ["targetCfg",_targetcfg] ];

			if (isPlayer _target) then { // Player was Target

					_data = _data + [ ["FiredAt","true"] , ["Player", getplayeruid _target] , ["PlayerName", name _target], ["playerGroup", [_target] call ALiVE_fnc_getPlayerGroup] ];

					// Send data to server to be written to DB
					ALIVE_SYS_STAT_UPDATE_EVENTS = _data;
					publicVariableServer "ALIVE_SYS_STAT_UPDATE_EVENTS";

			};

			if (isPlayer _source) then { // Player was firing

					_data = _data + [ ["Player",getplayeruid _source] , ["PlayerName",name _source], ["playerGroup", [_source] call ALiVE_fnc_getPlayerGroup] ];

					// Send data to server to be written to DB
					ALIVE_SYS_STAT_UPDATE_EVENTS = _data;
					publicVariableServer "ALIVE_SYS_STAT_UPDATE_EVENTS";

			};

		};
	};
};
// ====================================================================================