#include "\x\alive\addons\civ_placement\script_component.hpp"
SCRIPT(createRoadBlock);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createRoadBlock

Description:
Generates a RoadBlock

Parameters:
Array - position
Scalar - radius
Scalar - roadblock count
(Bool - Debugmode)

Returns:
Array of road positions where roadblocks have been created

Examples:
(begin example)
[getPos player, 100, 2] call ALiVE_fnc_createRoadblock;
(end)

See Also:

Author:
Tupolov
shukari
---------------------------------------------------------------------------- */

private [
    "_grp","_roadpos","_vehicle","_vehtype","_blockers","_roads",
    "_roadConnectedTo", "_connectedRoad","_direction","_checkpoint",
    "_checkpointComp","_roadpoints"
];

params [
    ["_pos", [0,0,0], [[]]],
    ["_radius", 500, [-1]],
    ["_num", 1, [-1]],
    ["_debug", false, [true]]
];

private _result = [];

if (isnil QGVAR(ROADBLOCKS)) then {GVAR(ROADBLOCKS) = []};

private _fac = [_pos, _radius] call ALiVE_fnc_getDominantFaction;

if (isNil "_fac") exitWith {
    ["Unable to find a dominant faction within %1 radius", _radius] call ALiVE_fnc_Dump;

    _result;
};

// Limit Roadblock number
if (_num > 5) then {_num = 5};

// Find all the roads
_roads = _pos nearRoads (_radius + 20);

// scan road positions, filter trails, filter runways and find those roads on outskirts
_roads = _roads select {_x distance _pos >= (_radius - 10) || {isOnRoad _x} || {(str _x) find "invisible" == -1}};

if (_roads isEqualTo []) exitWith {
    ["No roads found for roadblock! Cannot create..."] call ALiVE_fnc_dump;

    _result;
};

if (_num > count _roads) then {_num = count _roads};

private _roadpoints = [];
for "_i" from 1 to _num do {
    private "_roadsel";
    while {
        _roadsel = selectRandom _roads;
        (count _roads > 1 && ({_roadsel distance _x < 60} count _roadpoints) != 0)
    } do {
        _roads = _roads - [_roadsel];
    };

    _roadpoints pushback _roadsel;
};

for "_j" from 1 to (count _roadpoints) do {

    _roadpos = _roadpoints select (_j - 1);

    if ({_roadpos distance _x < 100} count GVAR(ROADBLOCKS) > 0) exitWith {["Roadblock %1 to close to another! Not created...",_roadpos] call ALiVE_fnc_dump};

    // check for non road position (should be obsolete due to filtering at the beginning)
    if (!isOnRoad _roadpos) exitWith {["Roadblock %1 is not on a road %2! Not created...",_roadpos, position _roadpos] call ALiVE_fnc_dump};

    _roadConnectedTo = roadsConnectedTo _roadpos;

    if (count _roadConnectedTo == 0) exitWith {["Selected road %1 for roadblock is a dead end! Not created...",_roadpos] call ALiVE_fnc_dump};

    // DEBUG -------------------------------------------------------------------------------------
    if(_debug) then {
     ["Roadblock %1 nearestBuilding: %2", _roadpos, ((nearestBuilding position _roadpos) distance2D position _roadpos)] call ALiVE_fnc_dump;
    };        
    // DEBUG -------------------------------------------------------------------------------------
    if (((nearestBuilding position _roadpos) distance2D position _roadpos) < 20) exitWith {["Roadblock %1 too close (20m) to building. Not created...", _roadpos] call ALiVE_fnc_dump; _result; };
    
    
    // DEBUG -------------------------------------------------------------------------------------
    if(_debug) then {
     ["Roadblock %1 not flat: %2", _roadpos, position _roadpos isFlatEmpty [-1, -1, 0.3, 10, -1] isEqualTo []] call ALiVE_fnc_dump;
    };        
    // DEBUG -------------------------------------------------------------------------------------
    if (position _roadpos isFlatEmpty [-1, -1, 0.3, 10, -1] isEqualTo []) exitWith {["Roadblock %1 is not on flat area. Not created...", _roadpos] call ALiVE_fnc_dump; _result; };
    
		
    GVAR(ROADBLOCKS) pushBack (position _roadpos);

    _connectedRoad = _roadConnectedTo select 0;
    _direction = (_roadpos getDir _connectedRoad);

    if (_direction < 181) then {_direction = _direction + 180} else {_direction = _direction - 180;};

    if (_debug) then {
        private ["_id"];

        _id = str(floor((getpos _roadpos) select 0)) + str(floor((getpos _roadpos) select 1));

        ["Position of Road Block is %1, dir %2", getpos _roadpos, _direction] call ALiVE_fnc_dump;

        [format["roadblock_%1", _id], _roadpos, "Icon", [1,1], "TYPE:", "mil_dot", "TEXT:", "RoadBlock",  "GLOBAL"] call CBA_fnc_createMarker;
    };

    // Get a composition
    private _compType = "Military";

    if (_fac call ALiVE_fnc_factionSide == RESISTANCE) then {
        _compType = "Guerrilla";
    };

    if (!isNil "ALiVE_compositions_roadblocks") then {
        _checkpoint = [(selectRandom ALiVE_compositions_roadblocks), _CompType] call ALiVE_fnc_findComposition;
    } else {
        private ["_cat","_size"];
        _cat = ["CheckpointsBarricades"];
        _size = ["Medium","Small"];
        _checkpoint = (selectRandom ([_compType, _cat, _size] call ALiVE_fnc_getCompositions));
    };

      
      private _config = _checkpoint;
      if (typename _checkpoint == "ARRAY") then {
     	 _config = [_checkpoint, configFile] call BIS_fnc_configPath;
      };
      private _compClassnames = [];
      private _objects = [];
      for "_i" from 0 to ((count _config) - 1) do {
     	 private _item = _config select _i;
     	 if (isClass _item) then {
     	  	_objects pushback (getText(_item >> "vehicle"));
     	 };
      };
      for "_i" from 0 to ((count _objects) - 1) do {
     	 private _object = _objects select _i;
     	
     	 if !(_object in _compClassnames) then {
     		 _compClassnames pushback _object;
     	 };
      };
         // DEBUG -------------------------------------------------------------------------------------
         if(_debug) then {
           ["*********** _compClassnames: %1", _compClassnames] call ALiVE_fnc_dump;
         };        
         // DEBUG -------------------------------------------------------------------------------------


    // Spawn compositions
    [_checkpoint,_roadpos,_direction,_fac] spawn {[_this select 0, position (_this select 1), _this select 2, _this select 3] call ALiVE_fnc_spawnComposition};

    _result pushback _roadpos;

    // Place a vehicle at side of road
    private _vehicleTypes = [1, _fac, "Car"] call ALiVE_fnc_findVehicleType;
    _vehicleTypes = _vehicleTypes - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

    _vehtype = selectRandom _vehicleTypes;
   
    // randomise 50/50 spawn...
    private _randomVehicleDice = round(random 99);
    if (_randomVehicleDice % 2 == 0) then {   
      if (!isNil "_vehtype") then {
     	 private _parkingPosition = [_vehtype, _roadpos, _compClassnames, false] call ALIVE_fnc_getParkingPosition; 	   
     	 if (count _parkingPosition > 0) then {
     	  	private _parkPosition = _parkingPosition select 0;
     	  	private _parkDirection = _parkingPosition select 1; 
         if !(isnil "ALiVE_ProfileHandler") then {
            _vehicle = [_vehtype, [_fac call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText, _fac, _parkPosition, _parkDirection, true, _fac, [], true] call ALiVE_fnc_createProfileVehicle;
         } else {
             _vehicle = createVehicle [_vehtype, _parkPosition, [], 0, "NONE"];
             _vehicle setDir _parkDirection;
             _vehicle setposATL (getposATL _vehicle);
         };
         // DEBUG -------------------------------------------------------------------------------------
         if(_debug) then {
           ["ALIVE_fnc_createRoadBlock _vehicleClass: %1, _parkPosition: %2, _parkDirection: %3", _vehtype, _parkPosition, _parkDirection] call ALiVE_fnc_dump;
         };        
         // DEBUG -------------------------------------------------------------------------------------
       };
      };
    };

    // Spawn static virtual group if Profile System is loaded and get them to defend
    if !(isnil "ALiVE_ProfileHandler") then {
        private _group = ["Infantry",_fac] call ALIVE_fnc_configGetRandomGroup;
        private _guards = [_group, position _roadpos, random(360), true, _fac, true] call ALIVE_fnc_createProfilesFromGroupConfig;

           // DEBUG -------------------------------------------------------------------------------------
           // if(_debug) then {
                ["ALIVE_fnc_createRoadBlock [%1] - Calling ALIVE_fnc_configGetRandomGroup", _fac] call ALiVE_fnc_dump;
           // };        
           // DEBUG -------------------------------------------------------------------------------------

        {
            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                //[_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0],"",1, 1]]] call ALIVE_fnc_profileEntity;
                [_x,"busy",true] call ALIVE_fnc_hashSet;
            };
        } foreach _guards;

    // else spawn real AI and get them to defend
    } else {
        [_vehicle, _roadpos, _fac] spawn {
            private["_roadpos","_fac","_vehicle","_side","_blockers"];

            _vehicle = _this select 0;
            _roadpos = _this select 1;
            _fac = _this select 2;
            _side = _fac call ALiVE_fnc_factionSide;

            // Spawn group and get them to defend
            _blockers = [getpos _roadpos, _side, "Infantry", _fac] call ALiVE_fnc_randomGroupByType;
            if (isNil "_vehicle") then {
                _blockers addVehicle _vehicle;
            };

            sleep 1;
            
           // DEBUG -------------------------------------------------------------------------------------
           // if(_debug) then {
                ["ALIVE_fnc_createRoadBlock [%1] - Calling ALIVE_fnc_groupGarrison", _fac] call ALiVE_fnc_dump;    
           // };        
           // DEBUG -------------------------------------------------------------------------------------
                  
           // [_blockers, getpos _roadpos, 100, true] call ALiVE_fnc_groupGarrison;
            [_blockers, getpos _roadpos, 100, true, false, 1, nil, 50] call ALIVE_fnc_groupGarrison;
        };
    };

};

_result;
