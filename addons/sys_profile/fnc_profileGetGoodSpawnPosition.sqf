#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileGetGoodSpawnPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_profileGetGoodSpawnPosition

Description:
Finds an appropriate spawn position for the profile
and any vehicles it may command

Parameters:
Array - Entity or Vehicle profile

Returns:

Examples:
(begin example)
[_profile] call ALIVE_fnc_profileGetGoodSpawnPosition;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_profile"];

private _profilePosition = _profile select 2 select 2;  //[_profile,"position"] call ALIVE_fnc_hashGet;
private _profileType = _profile select 2 select 5;      //[_profile,"type"] call ALIVE_fnc_hashGet;
private _profileID = _profile select 2 select 4;        //[_profile,"profileID"] call ALIVE_fnc_hashGet;

if (_profileType == "vehicle") then {

    private _hasSimulated = _profile select 2 select 21;                //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;
    if (!_hasSimulated) then {
        // the vehicle has been simulated
        // let the entity profile in command of the vehicle
        // deal with positioning

        private _despawnPosition = _profile select 2 select 20; //[_profile,"despawnPosition"] call ALIVE_fnc_hashGet;
        private _despawnPositionCorrupted = (_despawnPosition select [0,2]) isequalto [0,0];
        private _spawnPosition = if (_despawnPositionCorrupted) then { _profilePosition } else { _despawnPosition };

        [_profile,"position", _spawnPosition] call ALIVE_fnc_profileVehicle;
    };

} else {

    private _vehiclesInCargoOf = _profile select 2 select 9;    //[_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
    private _inCargo = !(_vehiclesInCargoOf isequalto []);

    if (!_inCargo) then {
        private _vehiclesInCommandOf = _profile select 2 select 8;  //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
        private _inCommand = !(_vehiclesInCommandOf isequalto []);

        if (!_inCommand) then {
            if (surfaceIsWater _profilePosition) then {
                //_spawnPosition = [_profilePosition] call ALIVE_fnc_getClosestLand;
                private _spawnPosition = [_profilePosition,0,500,1,0,0.5,0,[],[_profilePosition]] call BIS_fnc_findSafePos;

                [_profile,"position", _spawnPosition] call ALIVE_fnc_profileEntity;
                [_profile,"mergePositions"] call ALIVE_fnc_profileEntity;
            };
        } else {
            private _hasSimulated = _profile select 2 select 24;                //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;

            if (_hasSimulated && !_inCargo) then {
                private _spawnPosition = _profilePosition;

                // determine type of vehicle this profile commands

                private _vehicles = _vehiclesInCommandOf apply { [ALIVE_profileHandler,"getProfile", _x] call ALIVE_fnc_profileHandler };

                private _inCar = false;
                private _inAir = false;
                private _inShip = false;

                {
                    private _vehicleProfile = _x;
                    private _vehicleType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

                    switch (tolower _vehicleType) do {
                        case "car" :        {_inCar = true};
                        case "truck" :      {_inCar = true};
                        case "armored" :    {_inCar = true};
                        case "tank" :       {_inCar = true};
                        case "helicopter" : {_inAir = true};
                        case "plane" :      {_inAir = true};
                        case "ship" :       {_inShip = true};
                    };
                } forEach _vehicles;

                // validate profile position is correct for it's vehicle type
                // if not, correct it

                private "_direction";

                if (_inShip) then {
                    if !(surfaceIsWater _profilePosition) then {
                        //_spawnPosition = [_profilePosition] call ALIVE_fnc_getClosestSea;
                        _spawnPosition = [_profilePosition,0,100,1,1,0.5,0,[],[_profilePosition]] call BIS_fnc_findSafePos;
                    };
                };

                if (_inCar) then {
                    private _closestRoadPos = [_profilePosition] call ALIVE_fnc_getClosestRoad;
                    private _positionSeries = [_closestRoadPos,50,10] call ALIVE_fnc_getSeriesRoadPositions;

                    if !(_positionSeries isequalto []) then {
                        _closestRoadPos = selectRandom _positionSeries;
                    };

                    _spawnPosition = if (surfaceIsWater _closestRoadPos) then {
                        //_spawnPosition = [_profilePosition] call ALIVE_fnc_getClosestLand;
                        [_profilePosition,0,500,1,1,0.5,0,[],[_profilePosition]] call BIS_fnc_findSafePos
                    } else {
                        _closestRoadPos
                    };

                    _spawnPosition set [2,0];

                    // determine direction to spawn the vehicle

                    private _roads = _spawnPosition nearRoads 15;
                    private _roadsConnected = roadsConnectedTo (_roads select 0);

                    _direction = if (count _roadsConnected > 1) then {
                        (_roadsConnected select 0) getDir (_roadsConnected select 1);
                    } else {
                        if (count _roads > 1) then {
                            (_roads select 0) getDir (_roads select 1);
                        };
                    };

                    //_spawnPosition = [_position,0,100,10,0,0.5,0,[],[_position]] call BIS_fnc_findSafePos;
                };

                [_profile,"position", _spawnPosition] call ALIVE_fnc_profileEntity;
                [_profile,"mergePositions"] call ALIVE_fnc_profileEntity;

                // update positions for vehicles profile command

                private _moveSpawnedVehicle = {
                    params ["_vehicleProfile","_spawnPosition"];

                    private _active = _vehicleProfile select 2 select 1;
                    if (_active) then {
                        private _vehicleObject = _vehicleProfile select 2 select 10;
                        if (!isnil "_vehicle") then {
                            _vehicleObject setPos _spawnPosition;
                        };
                    };
                };

                // handle lead vehicle

                private _vehicleProfile = _vehicles select 0;
                [_vehicleProfile,"position", _spawnPosition] call ALIVE_fnc_profileVehicle;
                [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
                [_vehicleProfile,_spawnPosition] call _moveSpawnedVehicle;

                _vehicles deleteat 0;

                if (isnil "_direction") then { _direction = random 360 };

                {
                    private _vehicleProfile = _x;

                    private _position = if (_inAir) then {
                        _spawnPosition getPos [100 * (_forEachIndex + 1), _direction];
                    } else {
                        _spawnPosition getPos [20 * (_forEachIndex + 1), _direction];
                    };

                    _position = [_position,0,20,10,0,0.5,0,[],[_position]] call BIS_fnc_findSafePos;

                    [_vehicleProfile,"direction", _direction] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"position", _position] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
                    [_vehicleProfile,_position] call _moveSpawnedVehicle;
                } foreach _vehicles;
            };
        };
    };

};