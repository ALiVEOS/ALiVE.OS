#include <\x\alive\addons\civ_placement\script_component.hpp>
SCRIPT(createRoadBlock);
/*
 =======================================================================================================================
Script: fnc_createRoadBlock.sqf v1.0
Author(s): Tupolov
        Thanks to Evaider for roadblock layout

Description:
Group will setup a roadblock on the nearest road within 500m and man it

Parameter(s):
_this select 1: radius
_this select 0: defense position (Array)
_this select 2: number

Returns:
Boolean - success flag

Example(s):
_selectedRoadObject = [group this,(getPos this)] call ALiVE_fnc_createRoadBlock

-----------------------------------------------------------------------------------------------------------------------
Notes:

Type of roadblock will be based on faction.
Roadblock will be deployed on nearest road to the position facing along the road
Group will man static weaponary

to do: Current issue if road ahead bends.
     Change roadblock based on faction

=======================================================================================================================
*/

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

if (isnil QGVAR(ROADBLOCKS)) then {GVAR(ROADBLOCKS) = []};

if (_num > 5) then {_num = 5};

private _fac = [_pos, _radius] call ALiVE_fnc_getDominantFaction;

if (isNil "_fac") exitWith {
    ["Unable to find a dominant faction within %1 radius", _radius] call ALiVE_fnc_Dump;
};

// Find all the checkpoints pos
_roads = _pos nearRoads (_radius + 20);
// scan road positions, filter trails and find those roads on outskirts, filter runways
{
    if (_x distance _pos < (_radius - 10) || {!isOnRoad _x} || {str(_x) find "invisible" != -1}) then {
        _roads set [_foreachIndex,objNull];
    };
} foreach _roads;
_roads = _roads - [objNull];

if (count _roads == 0) exitWith {["ALiVE No roads found for roadblock! Cannot create..."] call ALiVE_fnc_Dump};

if (_num > count _roads) then {_num = count _roads};

_roadpoints = [];

for "_i" from 1 to _num do {
    private "_roadsel";
    while {
        _roadsel = (selectRandom _roads);
        (count _roads > 1 && ({_roadsel distance _x < 60} count _roadpoints) != 0)
    } do {
        _roads = _roads - [_roadsel];
    };

    _roadpoints pushback _roadsel;

};

for "_j" from 1 to (count _roadpoints) do {

    _roadpos = _roadpoints select (_j - 1);

    if ({_roadpos distance _x < 100} count GVAR(ROADBLOCKS) > 0) exitWith {["ALiVE Roadblock %1 to close to another! Not created...",_roadpos] call ALiVE_fnc_Dump};

    // check for non road position (should be obsolete due to filtering at the beginning)
    if (!isOnRoad _roadpos) exitWith {["ALiVE Roadblock %1 is not on a road %2! Not created...",_roadpos, position _roadpos] call ALiVE_fnc_Dump};

    _roadConnectedTo = roadsConnectedTo _roadpos;

    if (count _roadConnectedTo == 0) exitWith {["ALiVE Selected road %1 for roadblock is a dead end! Not created...",_roadpos] call ALiVE_fnc_Dump};

    GVAR(ROADBLOCKS) pushBack (position _roadpos);

    _connectedRoad = _roadConnectedTo select 0;
    _direction = (_roadpos getDir _connectedRoad);

    if (_direction < 181) then {_direction = _direction + 180} else {_direction = _direction - 180;};

    if (_debug) then {
        private ["_id"];

        _id = str(floor((getpos _roadpos) select 0)) + str(floor((getpos _roadpos) select 1));

        ["ALiVE Position of Road Block is %1, dir %2", getpos _roadpos, _direction] call ALiVE_fnc_Dump;

        [format["roadblock_%1", _id], _roadpos, "Icon", [1,1], "TYPE:", "mil_dot", "TEXT:", "RoadBlock",  "GLOBAL"] call CBA_fnc_createMarker;
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

    // Place a vehicle
    _vehtype = (selectRandom ([1, _fac, "Car"] call ALiVE_fnc_findVehicleType));
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

if !(isnil "_roadpos") then {
    _roadpos;
};