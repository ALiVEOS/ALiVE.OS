#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetGoodSpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileGetGoodSpawnPosition

Description:
Returns a good spawn position for the profile

Parameters:
Array - Entity or Vehicle profile

Returns:

Examples:
(begin example)
// get good spawn position
_result = [_profile] call ALIVE_fnc_profileGetGoodSpawnPosition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_profile","_markerCount","_createMarker","_debug","_active","_position","_side","_profileID","_type","_objectType","_vehicleAssignments",
"_sector","_sectorData","_sectorTerrain","_sectorTerrainSamples","_samples","_sectors","_spawnPosition",
"_vehicleProfile","_vehicleObjectType","_entitiesInCommandOf","_entitiesInCommandOf","_vehicleClass","_direction",
"_vehicles","_fuel","_ammo","_engineOn","_damage","_despawnPosition","_vehiclesInCommandOf","_vehiclesInCargoOf",
"_unitClasses","_damages","_ranks","_waypoints","_despawnPosition","_hasSimulated",
"_inCommand","_inCar","_inAir","_inShip","_inArmor"];

_profile = _this select 0;

_markerCount = 0;

_createMarker = {
	private["_position","_text","_profileID","_m"];

	_position = _this select 0;
	_text = _this select 1;
	_profileID = _this select 2;

	_m = createMarkerLocal [format["M%1_%2", _profileID, _markerCount], _position];
	_m setMarkerShapeLocal "ICON";
	_m setMarkerSizeLocal [1, 1];
	_m setMarkerTypeLocal "hd_dot";
	_m setMarkerColorLocal "ColorYellow";
	_m setMarkerTextLocal _text;

	_markerCount = _markerCount + 1;
};

_debug = _profile select 2 select 0; //[_profile,"debug"] call ALIVE_fnc_hashGet;
_active = _profile select 2 select 1; //[_profile,"active"] call ALIVE_fnc_hashGet;
_position = _profile select 2 select 2; //[_profile,"position"] call ALIVE_fnc_hashGet;
_side = _profile select 2 select 3; //[_profile, "side"] call MAINCLASS;
_profileID = _profile select 2 select 4; //[_profile,"profileID"] call ALIVE_fnc_hashGet;
_type = _profile select 2 select 5; //[_profile,"type"] call ALIVE_fnc_hashGet;
_objectType = _profile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;
_vehicleAssignments = _profile select 2 select 7; //[_profile,"vehicleAssignments"] call ALIVE_fnc_hashGet;
_direction = random 360;

switch(_type) do {
	case "entity": {
		_vehiclesInCommandOf = _profile select 2 select 8; //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
		_vehiclesInCargoOf = _profile select 2 select 9; //[_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
		_unitClasses = _profile select 2 select 11; //[_profile,"unitClasses"] call ALIVE_fnc_hashGet;
		_despawnPosition = _profile select 2 select 23; //[_profile,"despawnPosition"] call ALIVE_fnc_hashGet;
		_hasSimulated = _profile select 2 select 24; //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;

		_inCommand = false;
		_inCar = false;
		_inAir = false;
		_inShip = false;
		_inArmor = false;

		//["GGSP [%1] - commanding vehicles: %2 cargo vehicles: %3 simulated: %4",_profileID,_vehiclesInCommandOf,_vehiclesInCargoOf,_hasSimulated] call ALIVE_fnc_dump;

		// the profile has been moved via simulation
		if(_hasSimulated || ((_despawnPosition select 0) + (_despawnPosition select 1)) == 0) then {

			//["GGSP [%1] - entity has simulated",_profileID] call ALIVE_fnc_dump;

			// entity is not in the cargo of a vehicle
			if(count _vehiclesInCargoOf == 0) then {

				////["GGSP [%1] - entity is not in cargo",_profileID] call ALIVE_fnc_dump;

				// we are commanding vehicles
				// need to take the vehicle types etc into account
				if(count _vehiclesInCommandOf > 0) then {
					_vehicles = [];
					_inCommand = true;
					{
						_vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                        if !(isnil "_vehicleProfile") then {
							//_vehicleClass = _vehicleProfile select 2 select 11; //[_profile,"vehicleClass"] call ALIVE_fnc_hashGet;
							_vehicleObjectType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

							_vehicles pushback _vehicleProfile;

							if(_vehicleObjectType == "Car" || _vehicleObjectType == "Truck" || _vehicleObjectType == "Armored" || _vehicleObjectType == "Tank") then {
								_inCar = true;
							};
							if(_vehicleObjectType == "Plane" || _vehicleObjectType == "Helicopter") then {
								_inAir = true;
							};
							if(_vehicleObjectType == "Ship") then {
								_inShip = true;
							};
                        };
					} forEach _vehiclesInCommandOf;
				};

				_spawnPosition = _position;

				//[_spawnPosition,"DEF",_profileID] call _createMarker;

				//["GGSP [%1] - command: %2 car: %3 air: %4 ship: %5",_profileID,_inCommand,_inCar,_inAir,_inShip] call ALIVE_fnc_dump;

				// if the entity is not commanding any vehicles
				if!(_inCommand) then {

					// spawn position is in the water
					if(surfaceIsWater _position) then {

						//["GGSP [%1] - the position is water",_profileID] call ALIVE_fnc_dump;
						_spawnPosition = [_position] call ALIVE_fnc_getClosestLand;

						//[_spawnPosition,"LAND",_profileID] call _createMarker;
					};


				};

				// if the entity is in a ship
				if(_inShip) then {

					// spawn position is not in the water
					if!(surfaceIsWater _position) then {

						//["GGSP [%1] - ship - the position is land",_profileID] call ALIVE_fnc_dump;
						_spawnPosition = [_position] call ALIVE_fnc_getClosestSea;

						//[_spawnPosition,"SEA",_profileID] call _createMarker;
					};
				};

				// if the entity is in a car
				if(_inCar) then {

					//["GGSP [%1] - entity is in car get road position",_profileID] call ALIVE_fnc_dump;

					_spawnPosition = [_position] call ALIVE_fnc_getClosestRoad;
					_positionSeries = [_spawnPosition,200,10] call ALIVE_fnc_getSeriesRoadPositions;

					if(count _positionSeries > 0) then {
						_spawnPosition = selectRandom _positionSeries;
					};

					if(surfaceIsWater _spawnPosition) then {
						//["GGSP [%1] - car closest road is water",_profileID] call ALIVE_fnc_dump;
						_spawnPosition = [_position] call ALIVE_fnc_getClosestLand;
					};

					//Set position on ground
					_spawnPosition set [2,0];

                    //Check direction of street
                    _roads = _spawnPosition nearRoads 50;
                    _roadsConnected = roadsConnectedTo (_roads select 0);

                    if (!isnil "_roadsConnected" && {count _roadsConnected > 1}) then {
                        _roads = _roadsConnected;
                        _direction = (_roads select 0) getRelDir (_roads select 1);
                    } else {
                        if (count _roads > 1) then {
                            _direction = (_roads select 0) getRelDir (_roads select 1);
                        };
                    };

					//["GGSP [%1] - road position: %2 road direction: %3",_profileID,_spawnPosition,_direction] call ALIVE_fnc_dump;
					//[_spawnPosition,"ROAD",_profileID] call _createMarker;
				};

				// update the entities position

				[_profile,"position",_spawnPosition] call ALIVE_fnc_hashSet;
				[_profile,"mergePositions"] call ALIVE_fnc_profileEntity;

				// update any vehicle profile positions
				if(_inCommand) then {

					//["GGSP [%1] - IN COMMAND count vehicle: %2",_profileID,count _vehicles] call ALIVE_fnc_dump;

					if(count _vehicles > 1) then  {

						// lead vehicle
						_vehicleProfile = _vehicles select 0;

						[_vehicleProfile,"position",_spawnPosition] call ALIVE_fnc_profileVehicle;
						[_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;

						// vehicle is already spawned, move it..

						if(_vehicleProfile select 2 select 1) then {
							_vehicle = _vehicleProfile select 2 select 10;
							if!(isNil '_vehicle') then {
								_vehicle setPos _spawnPosition;
							};
						};

						//["LEAD POS: %1",_spawnPosition] call ALIVE_fnc_dump;
						//[_spawnPosition,"LEAD",_profileID] call _createMarker;

						//Remove Leader
						_vehicles set [0,"x"]; _vehicles = _vehicles - ["x"];

						{

							_vehicleProfile = _x;
                            _vehicleClass = _vehicleProfile select 2 select 11; //[_vehicleProfile,"vehicleClass"] call ALIVE_fnc_hashGet;

						    if(_inAir) then {
						        _position = _spawnPosition getPos [(100 * ((_forEachIndex)+1)), _direction];
						    }else{
                                _position = _spawnPosition getPos [(20 * ((_forEachIndex)+1)), _direction];
						    };

                            //["GROUP POS: %1",_position] call ALIVE_fnc_dump;
							//[_position,"GROUP",_profileID] call _createMarker;

                            _isFlat = _position isflatempty [
					    		3,								//--- Minimal distance from another object
					    		0,								//--- If 0, just check position. If >0, select new one
					    		0.7,							//--- Max gradient
					    		5,								//--- Gradient area
					    		0,								//--- 0 for restricted water, 2 for required water,
					    		false							//--- True if some water can be in 25m radius
					    	];

							if !(count _isFlat > 0) then {_position = [_position, 0, 50, 5, 0, 5 , 0, [], [_position]] call BIS_fnc_findSafePos};

                            //["GROUP POS FINAL: %1",_position] call ALIVE_fnc_dump;
							//[_position,"GROUP FINAL",_profileID] call _createMarker;

                            [_vehicleProfile,"direction",_direction] call ALIVE_fnc_profileVehicle;
							[_vehicleProfile,"position",_position] call ALIVE_fnc_profileVehicle;
							[_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;

							// vehicle is already spawned, move it..

							if(_vehicleProfile select 2 select 1) then {
								_vehicle = _vehicleProfile select 2 select 10;
								if!(isNil '_vehicle') then {
									_vehicle setPos _position;
								};
							};

							/*
							if(_inAir) then {
								[_vehicleProfile,"engineOn", true] call ALIVE_fnc_profileVehicle;
							};
							*/

						} forEach _vehicles;

					} else {
						if (count _vehicles > 0) then {
							_vehicleProfile = _vehicles select 0;
							[_vehicleProfile,"position",_spawnPosition] call ALIVE_fnc_profileVehicle;
							//[_vehicleProfile,"direction",_direction] call ALIVE_fnc_profileVehicle;
							[_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;

							// vehicle is already spawned, move it..

							if(_vehicleProfile select 2 select 1) then {
								_vehicle = _vehicleProfile select 2 select 10;
								if!(isNil '_vehicle') then {
									_vehicle setPos _spawnPosition;
								};
							};

							/*
							if(_inAir) then {
								[_vehicleProfile,"engineOn", true] call ALIVE_fnc_profileVehicle;
							};
	                        */
	                    };
					};
				};
			};
		// the profile has not been moved via simulation
		// set the position to the position it was despawned in
		} else {

			if(count _vehiclesInCargoOf == 0) then {

				if(((_despawnPosition select 0) + (_despawnPosition select 1)) == 0) then {
					_spawnPosition = _position;
				}else{
					_spawnPosition = _despawnPosition;

					//[_spawnPosition,"DESP",_profileID] call _createMarker;
				};

				[_profile,"position",_spawnPosition] call ALIVE_fnc_hashSet;
				[_profile,"mergePositions"] call ALIVE_fnc_profileEntity;
			};

			//["GGSP [%1] - not simulated - set pos as despawn position: %2",_profileID,_spawnPosition] call ALIVE_fnc_dump;
		}
	};
	case "vehicle": {
		/*
		_entitiesInCommandOf = _profile select 2 select 8; //[_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashSet;
		_entitiesInCommandOf = _profile select 2 select 9; //[_profile,"entitiesInCargoOf",[]] call ALIVE_fnc_hashSet;
		_vehicleClass = _profile select 2 select 11; //[_profile,"vehicleClass"] call ALIVE_fnc_hashGet;
		_direction = _profile select 2 select 12; //[_profile,"direction"] call ALIVE_fnc_hashGet;
		_fuel = _profile select 2 select 13; //[_profile,"fuel"] call ALIVE_fnc_hashGet;
		_ammo = _profile select 2 select 14; //[_profile,"ammo"] call ALIVE_fnc_hashGet;
		_engineOn = _profile select 2 select 15; //[_profile,"engineOn"] call ALIVE_fnc_hashGet;
		_damage = _profile select 2 select 16; //[_profile,"damage"] call ALIVE_fnc_hashGet;
		*/
		_despawnPosition = _profile select 2 select 20; //[_profile,"despawnPosition"] call ALIVE_fnc_hashGet;
		_hasSimulated = _profile select 2 select 21; //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;

		// the vehicle has been simulated
		// let the entity profile in command of the vehicle
		// deal with positioning
		if(_hasSimulated) then {

			//["GGSP [%1] - vehicle has been simulated",_profileID] call ALIVE_fnc_dump;

		// the profile has not been moved via simulation
		// set the position to the position it was despawned in
		}else{

			//["GGSP [%1] - vehicle has not been simulated",_profileID] call ALIVE_fnc_dump;

			if(((_despawnPosition select 0) + (_despawnPosition select 1)) == 0) then {
				_spawnPosition = _position;
			}else{
				_spawnPosition = _despawnPosition;

				//[_spawnPosition,"DESP",_profileID] call _createMarker;
			};

			[_profile,"position",_spawnPosition] call ALIVE_fnc_hashSet;

			//["GGSP [%1] - not simulated - set pos as despawn position: %2",_profileID,_result] call ALIVE_fnc_dump;
		};
	};
};