#include "\x\alive\addons\sys_profile\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */
params ["_profile"];

private _profileData = _profile select 2;
private _position = _profileData select 2;
private _type = _profileData select 5;

/*
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
*/

switch(_type) do {

    case "entity": {
        private _vehiclesInCommandOf = _profileData select 8; //[_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashSet;
        private _vehiclesInCargoOf = _profileData select 9; //[_profile,"vehiclesInCargoOf",[]] call ALIVE_fnc_hashSet;
        private _despawnPosition = _profileData select 23; //[_profile,"despawnPosition"] call ALIVE_fnc_hashGet;
        private _hasSimulated = _profileData select 24; //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;
        private _inCommand = count _vehiclesInCommandOf > 0;
        private _inCar = false;
        private _inAir = false;
        private _inShip = false;
        private _spawnPosition = [];

        //["GGSP [%1] - commanding vehicles: %2 cargo vehicles: %3 simulated: %4",_profileID,_vehiclesInCommandOf,_vehiclesInCargoOf,_hasSimulated] call ALIVE_fnc_dump;

        // the profile has been moved via simulation and is commanding a vehicle or has corrupt positions
        if (_inCommand && {_hasSimulated || {_despawnPosition select 0 < 5 && {_despawnPosition select 1 < 5}}}) then {

            //["GGSP [%1] - entity has simulated",_profileID] call ALIVE_fnc_dump;

            // entity is not in the cargo of a vehicle
            if (count _vehiclesInCargoOf == 0) then {

                ////["GGSP [%1] - entity is not in cargo",_profileID] call ALIVE_fnc_dump;

                _spawnPosition = _position;
                //[_spawnPosition,"DEF",_profileID] call _createMarker;

                // we are commanding vehicles
                // need to take the vehicle types etc into account
                private _vehicles = [];
                {
                    private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

                    if !(isnil "_vehicleProfile") then {
                        private _vehicleObjectType = _vehicleProfile select 2 select 6; //[_profile,"objectType"] call ALIVE_fnc_hashGet;

                        _vehicles pushback _vehicleProfile;

                        switch tolower(_vehicleObjectType) do {
                            case "car" : {_inCar = true};
                            case "truck" : {_inCar = true};
                            case "armored" : {_inCar = true};
                            case "tank" : {_inCar = true};
                            case "helicopter" : {_inAir = true};
                            case "plane" : {_inAir = true};
                            case "ship" : {_inShip = true};
                        };
                    };
                } forEach _vehiclesInCommandOf;

                //["GGSP [%1] - command: %2 car: %3 air: %4 ship: %5",_profileID,_inCommand,_inCar,_inAir,_inShip] call ALIVE_fnc_dump;

                // if the entity is in a ship
                if(_inShip) then {

                    // spawn position is not in the water
                    if !(surfaceIsWater _position) then {

                        //["GGSP [%1] - ship - the position is land",_profileID] call ALIVE_fnc_dump;
                        //_spawnPosition = [_position] call ALIVE_fnc_getClosestSea;
                        // #943 - waterMode 1 made water OPTIONAL, so a dry-land crew
                        // position could stay on land and beach the boat at spawn.
                        // Require water (mode 2), and supply both default slots - the
                        // malformed one-element default fell through to the map centre
                        // on a failed search.
                        _spawnPosition = [_position,0,100,1,2,0.5,0,[],[_position,_position]] call BIS_fnc_findSafePos;

                        //[_spawnPosition,"SEA",_profileID] call _createMarker;
                    };
                };

                // if the entity is in a car
                if (_inCar) then {

                    //["GGSP [%1] - entity is in car get road position",_profileID] call ALIVE_fnc_dump;

					///*

                   _spawnPosition = _position;

                    if (surfaceIsWater _spawnPosition) then {
                        //["GGSP [%1] - car closest road is water",_profileID] call ALIVE_fnc_dump;
                        //_spawnPosition = [_position] call ALIVE_fnc_getClosestLand;
                        _spawnPosition = [_position,0,500,1,1,0.5,0,[],[_position]] call BIS_fnc_findSafePos;
                    };

                    //*/
                    //_vehicleClass = _vehicleProfile select 2 select 11;
                    //systemChat str (_vehicleClass);
                    //_spawnPosition = [_spawnPosition,0,100,10,0,0.5,0,[],[_spawnPosition], _vehicleClass] call ALIVE_fnc_findFilteredSafePos;
                    //_spawnPosition = [_position,0,100,10,0,0.5,0,[],[_position]] call BIS_fnc_findSafePos;
                    
                    //["GGSP [%1] - road position: %2 road direction: %3",_profileID,_spawnPosition,_direction] call ALIVE_fnc_dump;
                    //[_spawnPosition,"ROAD",_profileID] call _createMarker;
                };

                // update the entities position

                [_profile,"position",_spawnPosition] call ALIVE_fnc_profileEntity;
                [_profile,"mergePositions"] call ALIVE_fnc_profileEntity;

                // update any vehicle profile positions
                if (_inCommand) then {
                    //systemChat "In command of a vehicle!";

                    //["GGSP [%1] - IN COMMAND count vehicle: %2",_profileID,count _vehicles] call ALIVE_fnc_dump;

                    if (count _vehicles > 1) then  {
                        //systemChat "More than 1 vehicle!";
                        private _direction = random 360;

                        // lead vehicle
                        private _vehicleProfile = _vehicles select 0;

                        [_vehicleProfile,"position",_spawnPosition] call ALIVE_fnc_profileVehicle;
                        [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;

                        // #1024 - every vehicle BEHIND the lead one was put 20m out on a
                        // single random bearing with no check of any kind, while the lead
                        // got a validated position and aircraft got findFilteredSafePos.
                        // In a river channel narrower than 40m most bearings are the bank,
                        // which is how one boat of a pair floated and the other did not.
                        //
                        // Steer rather than guess, for boats only. The lead vehicle's
                        // stored direction is its last simulated travel bearing, and a
                        // virtual boat travels the water route, so on a river that bearing
                        // runs along the channel. Try astern of the lead first, then a fan
                        // of bearings around it, then one ring further out, and take the
                        // first sample that is wet, no shallower than the water the lead
                        // boat is already floating in, and not on top of a boat placed
                        // earlier in this pass. The common case is one surfaceIsWater and
                        // one getTerrainHeightASL: no object queries, no findSafePos, so
                        // it stays inside the budget the spawn path was optimised to.
                        //
                        // Ground vehicles keep the plain offset deliberately. profileVehicle
                        // runs the unified spawn-position validator on them at spawn time,
                        // which is why they never showed this.
                        private _leadDirection = _vehicleProfile select 2 select 12;
                        private _minDepth = 0.5;
                        private _placed = [_spawnPosition];
                        if (_inShip) then {
                            // The lead boat is floating by definition, so its own water is
                            // the yardstick. A fixed 2m would reject every position in a
                            // shallow delta and fall through to the unchecked offset.
                            _minDepth = ((-(getTerrainHeightASL _spawnPosition)) min 2) max 0.5;
                        };
                        private _fnc_shipFloats = {
                            params ["_p"];
                            (surfaceIsWater _p)
                                && {(getTerrainHeightASL _p) <= -_minDepth}
                                && {_placed findIf { (_p distance2D _x) < 15 } < 0}
                        };

                        _vehicles deleteAt 0;

                        {
                            private _vehicleProfile = _x;
                            private _index = _forEachIndex + 1;
                            // Named, rather than assigning to the _position declared at the
                            // top of this function. That assignment clobbered the profile's
                            // own position for the rest of the call.
                            private _followerPosition = [];
                            private _followerDirection = _direction;

                            if (_inAir) then {
                                _followerPosition = _spawnPosition getPos [(100 * _index), _direction];
                                //group of vehicles being paradropped?
                                _followerPosition = [_followerPosition,0,50,20,0,0.5,0,[],[_followerPosition], _vehicleProfile select 2 select 6] call ALIVE_fnc_findFilteredSafePos;
                            } else {
                                if ((tolower (_vehicleProfile select 2 select 6)) == "ship") then {
                                    private _astern = 20 * _index;
                                    private _tried = 0;
                                    {
                                        private _distance = _x;
                                        {
                                            _tried = _tried + 1;
                                            private _sample = _spawnPosition getPos [_distance, _leadDirection + _x];
                                            if ([_sample] call _fnc_shipFloats) exitWith { _followerPosition = _sample };
                                        } forEach [180, 0, 150, 210, 30, 330, 120, 240, 60, 300, 90, 270];
                                        if !(_followerPosition isEqualTo []) exitWith {};
                                    } forEach [_astern, _astern + 30];

                                    // Nothing floats on either ring. Anchor it astern anyway
                                    // and let the shallow-water search in profileVehicle take
                                    // over from there, which is a better starting point than a
                                    // random bearing was.
                                    if (_followerPosition isEqualTo []) then {
                                        _followerPosition = _spawnPosition getPos [_astern, _leadDirection + 180];
                                    };
                                    _placed pushBack _followerPosition;
                                    _followerDirection = _leadDirection;

                                    if (_profileData select 0) then {
                                        ["ALIVE_fnc_profileGetGoodSpawnPosition - boat follower for %1: lead %2 bearing %3 minDepth %4 -> %5 after %6 samples (wet %7)",
                                            _profileData select 4, _spawnPosition, _leadDirection, _minDepth,
                                            _followerPosition, _tried, surfaceIsWater _followerPosition] call ALIVE_fnc_dump;
                                    };
                                } else {
                                    _followerPosition = _spawnPosition getPos [(20 * _index), _direction];
                                };
                            };

                            [_vehicleProfile,"direction",_followerDirection] call ALIVE_fnc_profileVehicle;
                            [_vehicleProfile,"position",_followerPosition] call ALIVE_fnc_profileVehicle;
                            [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;

                        } forEach _vehicles;

                    } else {
                        if (count _vehicles > 0) then {
                            private _vehicleProfile = _vehicles select 0;
                            [_vehicleProfile,"position",_spawnPosition] call ALIVE_fnc_profileVehicle;
                            [_vehicleProfile,"mergePositions"] call ALIVE_fnc_profileVehicle;
                        };
                    };
                };
            };
        // the profile has not been moved via simulation
        // set the position to the position it was despawned in
        } else {

            //Not in command of a vehicle
            if !(_inCommand) then {
                //systemChat "Not in command of a vehicle!";
                // spawn position is in the water
                if (surfaceIsWater _position) then {

                    //["GGSP [%1] - the position is water",_profileID] call ALIVE_fnc_dump;
                    //_spawnPosition = [_position] call ALIVE_fnc_getClosestLand;
                    _spawnPosition = [_position,0,500,1,0,0.5,0,[],[_position]] call BIS_fnc_findSafePos;

                    [_profile,"position",_spawnPosition] call ALIVE_fnc_profileEntity;
                    [_profile,"mergePositions"] call ALIVE_fnc_profileEntity;

                    //[_spawnPosition,"LAND",_profileID] call _createMarker;
                } else {

                    // Foot infantry have no spawn-position validator (vehicles use
                    // findVehicleSpawnPosition). An anchor in an A3 rock cluster puts
                    // the whole group inside the geometry (#913 / sys_profile Item 1).
                    // Rocks are terrain objects (findSafePos / isFlatEmpty miss them),
                    // but a flat proximity radius missed large formations - a unit on a
                    // 20m+ boulder sits well over 6m from that rock's origin, so a small
                    // radius never detects it. Test against each rock's actual footprint
                    // (boundingBoxReal half-extent + body margin) within a generous find
                    // radius, then step out to the nearest clear, dry spot.
                    private _nearRocks = nearestTerrainObjects [_position, ["ROCK","ROCKS"], 80];
                    if !(_nearRocks isEqualTo []) then {
                        // precompute each rock's horizontal half-footprint (+ body margin) once
                        private _rockReach = _nearRocks apply {
                            private _bb = boundingBoxReal _x;
                            private _p0 = _bb select 0;
                            private _p1 = _bb select 1;
                            [_x, (((abs (_p0 select 0)) max (abs (_p1 select 0))) max ((abs (_p0 select 1)) max (abs (_p1 select 1)))) + 1.5]
                        };
                        // true if _pos lies within any nearby rock's footprint
                        private _fnc_inRock = {
                            params ["_pos", "_reach"];
                            _reach findIf { (_pos distance2D (_x select 0)) < (_x select 1) } >= 0
                        };
                        if ([_position, _rockReach] call _fnc_inRock) then {
                            private _nudged = [];
                            {
                                private _cand = _position getPos _x;
                                if (!([_cand, _rockReach] call _fnc_inRock) && {!surfaceIsWater _cand}) exitWith { _nudged = _cand; };
                            } forEach [[15,0],[15,72],[15,144],[15,216],[15,288],[30,36],[30,108],[30,180],[30,252],[30,324],[50,0],[50,60],[50,120],[50,180],[50,240],[50,300]];
                            if (count _nudged > 0) then {
                                [_profile,"position",_nudged] call ALIVE_fnc_profileEntity;
                                [_profile,"mergePositions"] call ALIVE_fnc_profileEntity;
                            };
                        };
                    };
                };
            };

            //["GGSP [%1] - not simulated - set pos as despawn position: %2",_profileID,_spawnPosition] call ALIVE_fnc_dump;
        };
    };

    case "vehicle": {
        private _despawnPosition = _profileData select 20; //[_profile,"despawnPosition"] call ALIVE_fnc_hashGet;
        private _hasSimulated = _profileData select 21; //[_profile,"hasSimulated"] call ALIVE_fnc_hashGet;

        if (!_hasSimulated) then {
            // the profile has not been moved via simulation
            // set the position to the position it was despawned in

            private _spawnPosition = if (((_despawnPosition select 0) + (_despawnPosition select 1)) == 0) then {
                _position
            } else {
                _despawnPosition
            };

            [_profile,"position", _spawnPosition] call ALIVE_fnc_profileVehicle;

            //["GGSP [%1] - not simulated - set pos as despawn position: %2",_profileID,_result] call ALIVE_fnc_dump;
        } else {
            // the vehicle has been simulated
            // let the entity profile in command of the vehicle
            // deal with positioning
            //["GGSP [%1] - vehicle has been simulated",_profileID] call ALIVE_fnc_dump;
        };
    };
};
