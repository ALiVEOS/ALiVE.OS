#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(createProfilesFromGroupConfig);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesFromGroupConfig

Description:
Create profiles based on definitions found in CfgGroups

Parameters:
String - Group class name from CfgGroups
Array - position
Scalar - direction

Returns:
Array of created profiles

Examples:
(begin example)
// create profiles from group config
_result = ["OIA_InfWepTeam",getPosATL player] call ALIVE_fnc_createProfilesFromGroupConfig;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_groupClass","_position","_direction","_spawnGoodPosition","_prefix","_busy","_config","_groupName","_groupSide","_groupFaction",
"_groupProfiles","_groupUnits","_groupVehicles","_class","_rank","_vehicle","_vehicleType"];

_groupClass = _this select 0;
_position = _this select 1;
_direction = if(count _this > 2) then {_this select 2} else {0};
_spawnGoodPosition = if(count _this > 3) then {_this select 3} else {true};
_prefix = if(count _this > 4) then {_this select 4} else {""};
_busy = if(count _this > 5) then {_this select 5} else {false};

_groupProfiles = [];

// Check to see if faction has a mapping
if(!isNil "ALIVE_factionCustomMappings") then {
    if(_prefix in (ALIVE_factionCustomMappings select 1)) then {
        _customMappings = [ALIVE_factionCustomMappings, _prefix] call ALIVE_fnc_hashGet;
        _prefix = [_customMappings, "GroupFactionName"] call ALIVE_fnc_hashGet;
    };
};

// ["Group faction: %1",_prefix] call ALIVE_fnc_dump;

_config = [_prefix, _groupClass] call ALIVE_fnc_configGetGroup;

// ["Group Config: %1 %2",_config,_groupClass] call ALIVE_fnc_dump;

if(count _config > 0) then {

    private ["_entityID","_side","_profileEntity","_classes","_positions","_damages","_ranks","_unit","_customMappings"];

	//["CFG: %1",_config] call ALIVE_fnc_dump;

	_groupName = getText(_config >> "name");
	_groupSide = getNumber(_config >> "side");
	_groupFaction = getText(_config >> "faction");

	if(_groupSide == 0) then {
        _groupSide = _groupFaction call ALiVE_fnc_factionSide;
        _groupSide = [_groupSide] call ALIVE_fnc_sideObjectToNumber;
    };

    /*
	["CFG Name: %1",_groupName] call ALIVE_fnc_dump;
    ["CFG Side: %1",_groupSide] call ALIVE_fnc_dump;
    ["CFG Faction: %1",_groupFaction] call ALIVE_fnc_dump;
    */

	if(!isNil "ALIVE_factionCustomMappings") then {
        if(_groupFaction in (ALIVE_factionCustomMappings select 1)) then {
            _customMappings = [ALIVE_factionCustomMappings, _groupFaction] call ALIVE_fnc_hashGet;
            _side = [_customMappings, "Side"] call ALIVE_fnc_hashGet;
            _groupFaction = [_customMappings, "FactionName"] call ALIVE_fnc_hashGet;
        }else{
            _side = _groupSide call ALIVE_fnc_sideNumberToText;
        };
    }else{
        _side = _groupSide call ALIVE_fnc_sideNumberToText;
    };

	_groupUnits = [];
	_groupVehicles = [];

    /*
	["CFG Name: %1",_groupName] call ALIVE_fnc_dump;
    ["CFG Side: %1",_side] call ALIVE_fnc_dump;
    ["CFG Faction: %1",_groupFaction] call ALIVE_fnc_dump;
    */

    if(_side == "INDEP") then {
    	_side = "GUER";
    };

	// loop through the config for the group
	for "_i" from 0 to count _config -1 do {
		_class = (_config select _i);
		if(isClass _class) then {
			_rank = getText(_class >> "rank");
			_vehicle = getText(_class >> "vehicle");
			_vehicleType = _vehicle call ALIVE_fnc_configGetVehicleClass;

			//["CGROUP Name: %1 VehicleType: %2 vehicle: %3",_groupName,_vehicleType,_vehicle] call ALIVE_fnc_dump;

			// seperate vehicles and units in the group
			//if((_vehicleType == "Car")||(_vehicleType == "Truck")||(_vehicleType == "Tank")||(_vehicleType == "Armored")||(_vehicleType == "Ship")||(_vehicleType == "Air")||(_vehicleType == "LIB_Medium_Tanks")||(_vehicleType == "LIB_Heavy_Tanks")) then {
			if!(_vehicle isKindOf "Man") then {
				_groupVehicles pushback [_vehicle,_rank];
			} else {
				_groupUnits pushback [_vehicle,_rank];
			};
		};
	};

	//["CGROUP Vehicles: %1 Units: %2",_groupVehicles,_groupUnits] call ALIVE_fnc_dump;


	// get counts of current profiles

	_entityID = [ALIVE_profileHandler, "getNextInsertEntityID"] call ALIVE_fnc_profileHandler;


	// create the group entity profile

	_profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
	[_profileEntity, "init"] call ALIVE_fnc_profileEntity;
	[_profileEntity, "profileID", format["%1-%2",_prefix,_entityID]] call ALIVE_fnc_profileEntity;
	[_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
	[_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
	[_profileEntity, "faction", _groupFaction] call ALIVE_fnc_profileEntity;
	[_profileEntity, "objectType", _groupClass] call ALIVE_fnc_profileEntity;
	[_profileEntity, "busy", _busy] call ALIVE_fnc_profileEntity;

	if!(_spawnGoodPosition) then {
		[_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
	};

	_groupProfiles pushback _profileEntity;
	[ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;


	// if there are vehicles for this group

	private ["_vehicleID","_vehicleClass","_vehicleRank","_crew","_profileVehicle","_vehiclePositions","_countCrewPositions","_vehiclePosition","_vehicleKind"];

	{
		// create the profile for the vehicle

		_vehicle = _x;
		_vehicleID = [ALIVE_profileHandler, "getNextInsertVehicleID"] call ALIVE_fnc_profileHandler;
		_vehicleClass = _vehicle select 0;
		_vehicleRank = _vehicle select 1;

	    //["V: %1 %2",_vehicle,_vehicleClass] call ALIVE_fnc_dump;

		_vehicleKind = _vehicleClass call ALIVE_fnc_vehicleGetKindOf;

		_vehiclePosition = _position getPos [(20 * ((_forEachIndex)+1)), random(360)];

		_profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "profileID", format["%1-%2",_prefix,_vehicleID]] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "vehicleClass", _vehicleClass] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "position", _vehiclePosition] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "direction", 0] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "side", _side] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "faction", _groupFaction] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "damage", 0] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "fuel", 1] call ALIVE_fnc_profileVehicle;
		[_profileVehicle, "busy", _busy] call ALIVE_fnc_profileVehicle;

		if(_vehicleKind == "Plane" || _vehicleKind == "Helicopter") then {
			[_profileVehicle, "spawnType", ["preventDespawn"]] call ALIVE_fnc_profileVehicle;
		};

		if!(_spawnGoodPosition) then {
			[_profileVehicle, "despawnPosition", _vehiclePosition] call ALIVE_fnc_profileVehicle;
		};

		_groupProfiles pushback _profileVehicle;
		[ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

		// create crew members for the vehicle

		_crew = _vehicleClass call ALIVE_fnc_configGetVehicleCrew;
		_vehiclePositions = [_vehicleClass] call ALIVE_fnc_configGetVehicleEmptyPositions;
		_countCrewPositions = 0;

		//["VP: %1 %2",_vehiclePositions, count _vehiclePositions] call ALIVE_fnc_dump;
		//_vehiclePositions call ALIVE_fnc_inspectArray;

		// count all non cargo positions
		for "_i" from 0 to count _vehiclePositions -3 do {
			_countCrewPositions = _countCrewPositions + (_vehiclePositions select _i);
		};

		// for all crew positions add units to the entity group
		for "_i" from 0 to _countCrewPositions -1 do {
			[_profileEntity, "addUnit", [_crew,_position,0,_vehicleRank]] call ALIVE_fnc_profileEntity;
		};

		[_profileEntity,_profileVehicle] call ALIVE_fnc_createProfileVehicleAssignment;

	} forEach _groupVehicles;

	// create the group units

	{
		_unit = _x;
		_class = _unit select 0;
		_rank = _unit select 1;
		[_profileEntity, "addUnit", [_class,_position,0,_rank]] call ALIVE_fnc_profileEntity;
	} forEach _groupUnits;

	{
	    [_profileEntity,_profileVehicle,true] call ALIVE_fnc_createProfileVehicleAssignment;
	} forEach _groupVehicles;

};

_groupProfiles