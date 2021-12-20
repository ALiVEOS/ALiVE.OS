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
    "_connectedRoads","_checkpointComp","_roadpoints"
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

    _connectedRoads = roadsConnectedTo _roadpos;

    if (count _connectedRoads == 0) exitWith {["Selected road %1 for roadblock is a dead end! Not created...",_roadpos] call ALiVE_fnc_dump};

    // get connected roads and filter out the one that are already in the list
    private ["tempRoads"];
    tempRoads = _connectedRoads select 0;

    for (i=1, count _connectedRoads) do {
        if (isInArray GVAR(ROADBLOCKS) tempRoads) then {
            removeFromArray tempRoads i;
        };
    };

    // get the first road that is not in the list yet and add it to the list of roads to be connected to this roadblock. 
    private ["_connectedRoad"];

    if (count tempRoads > 0) then {
        _connectedRoad = tempRoads select 0;

        GVAR(ROADBLOCKS).insertAt(_j, position _roadpos);

        // check if there are more roads connected to this one and add them as well. 
        private ["_newConnectedRods"];

        _newConnectedRods = roadsConnectedTo position _roadpos select 1;

        for (i=0, count _newConnectedRods) do {
            if (isInArray GVAR(ROADBLOCKS) _newConnectedRods select i) then {
                removeFromArray _newConnectedRods i;
            };

        };

        for (i=0, count _newConnectedRods) do {
            GVAR(ROADBLOCKS).insertAt(_j + 1, position _roadpos);

            // check if there are more roads connected to this one and add them as well. 
            private ["_nextNewConnectedRoads"];

            _nextNewConnectedRoads = roadsConnectedTo position _roadpos select i;

            for (k=0, count _nextNewConnectedRoads) do {
                if (isInArray GVAR(ROADBLOCKS) _nextNewConnectedRoads select k) then {
                    removeFromArray _nextNewConnectedRoads k;
                };

            };

        };        

    } else exitWith {["Selected road %1 for roadblock is a dead end! Not created...",_roadpos] call ALiVE_fnc_dump};

    // get the direction of the connected roads
    private ["_direction"];

    _direction = (_roadpos getDir _connectedRoad);

    if (_debug) then {
        private ["_id"];

        _id = str(floor((getpos _roadpos) select 0)) + str(floor((getpos _roadpos) select 1));

        ["Position of Road Block is %1, dir %2", getpos _roadpos, _direction] call ALiVE_fnc_dump;

        [format["roadblock_%1", _id], position(_x), "Icon", [1,1], "TYPE:", "mil_dot", "TEXT:", "RoadBlock",  "GLOBAL"] call CBA_fnc_createMarker;
    };

    // Get a composition
    private _compType = "Military";

    If (_fac call ALiVE_fnc_factionSide == RESISTANCE) then {
        _compType = "Guerrilla";
    };

    If (!isNil "ALiVE_compositions_roadblocks") then {
        _checkpoint = [(selectRandom ALiVE_compositions_roadblocks), _CompType] call ALiVE_fnc_findComposition;
    } else {
        private ["_cat","_size"];
        _cat = ["CheckpointsBarricades"];
        _size = ["Medium","Small"];
        _checkpoint = (selectRandom ([_compType, _cat, _size] call ALiVE_fnc_getCompositions));
    };

    // Spawn compositions
    [_checkpoint,_roadpos,_direction,_fac] spawn {[_this select 0, position (_this select 1), _this select 2, _this select 3] call ALiVE_fnc_spawnComposition};

    _result pushback _roadpos;

    // Place a vehicle
    private _vehicleTypes = [1, _fac, "Car"] call ALiVE_fnc_findVehicleType;
    _vehicleTypes = _vehicleTypes - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

    _vehtype = selectRandom _vehicleTypes;
    if (!isNil "_vehtype") then {
        if !(isnil "ALiVE_ProfileHandler") then {
            _vehicle = [_vehtype, [_fac call ALiVE_fnc_factionSide] call ALiVE_fnc_sideToSideText, _fac, [position _roadpos, 10,30,2,0,5,0] call BIS_fnc_findsafepos, _direction, true, _fac] call ALiVE_fnc_createProfileVehicle;
        } else {
            _vehicle = createVehicle [_vehtype, [position _roadpos, 10,30,2,0,5,0] call BIS_fnc_findsafepos, [], 0, "NONE"];
            _vehicle setDir _direction;
            _vehicle setposATL (getposATL _vehicle);
        };
    };

    // Spawn static virtual group if Profile System is loaded and get them to defend
    if !(isnil "ALiVE_ProfileHandler") then {
        private _group = ["Infantry",_fac] call ALIVE_fnc_configGetRandomGroup;
        private _guards = [_group, position _roadpos, random(360), true, _fac, true] call ALIVE_fnc_createProfilesFromGroupConfig;

        {
            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[30,"false",[0,0,0]]]] call ALIVE_fnc_profileEntity;
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

            [_blockers, getpos _roadpos, 100, true] call ALiVE_fnc_groupGarrison;
        };
    };

};

_result;
