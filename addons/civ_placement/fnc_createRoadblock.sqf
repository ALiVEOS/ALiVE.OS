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
null = [group this,(getPos this)] call ALiVE_fnc_createRoadBlock

-----------------------------------------------------------------------------------------------------------------------
Notes:

Type of roadblock will be based on faction.
Roadblock will be deployed on nearest road to the position facing along the road
Group will man static weaponary

to do: Current issue if road ahead bends.
     Change roadblock based on faction

=======================================================================================================================
*/

private ["_vehicle","_checkpoint"];

params [
    ["_pos", [0,0,0], [[]]],
    ["_radius", 100, [-1]],
    ["_num", 1, [-1]],
    ["_debug", false, [true]]
];

if (isnil QGVAR(ROADBLOCKS)) then {GVAR(ROADBLOCKS) = []};

if (_num > 5) then {_num = 5};

private _fac = [_pos, _radius] call ALiVE_fnc_getDominantFaction;

if (isNil "_fac") then {
    _fac = "OPF_G_F";
};

// Find all the checkpoints pos
private _roads = _pos nearRoads (_radius + 20);
// scan road positions and find those on outskirts
{
    if (_x distance _pos < (_radius - 10)) then {
        _roads = _roads - [_x];
    };
} foreach _roads;

if (count _roads == 0) exitWith {["ALiVE No roads found for roadblock! Cannot create..."] call ALiVE_fnc_Dump};

if (_num > count _roads) then {_num = count _roads};

private _roadpoints = [];

for "_i" from 1 to _num do {
    while {
        private _roadsel = selectRandom _roads;
        (count _roads > 1 && ({_roadsel distance _x < 60} count _roadpoints) != 0)
    } do {
        _roads = _roads - [_roadsel];
    };

    _roadpoints pushback _roadsel;
};

for "_j" from 1 to (count _roadpoints) do {

    private _roadpos = _roadpoints select (_j - 1);

    if ({_roadpos distance _x < 60} count GVAR(ROADBLOCKS) > 0) exitWith {["ALiVE Roadblock to close to another! Not created..."] call ALiVE_fnc_Dump};

    // check for non road position
    if (!isOnRoad _roadpos) exitWith {["ALiVE Roadblock is not on a road! Not created..."] call ALiVE_fnc_Dump};

    private _roadConnectedTo = roadsConnectedTo _roadpos;

    if (count _roadConnectedTo == 0) exitWith {["ALiVE Selected road for roadblock is a dead end! Not created..."] call ALiVE_fnc_Dump};

    GVAR(ROADBLOCKS) pushBack _roadpos;

    private _connectedRoad = _roadConnectedTo select 0;
    private _direction = [_roadpos, _connectedRoad] call BIS_fnc_DirTo;

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
        _checkpoint = [ALiVE_compositions_roadblocks call BIS_fnc_selectRandom, _CompType] call ALiVE_fnc_findComposition;
    } else {
        private _cat = ["CheckpointsBarricades"];
        private _size = ["Medium","Small"];
        _checkpoint = selectRandom ([_compType, _cat, _size] call ALiVE_fnc_getCompositions);
    };

    // Spawn compositions
    [_checkpoint,_roadpos,_direction,_fac] spawn {[_this select 0, position (_this select 1), _this select 2, _this select 3] call ALiVE_fnc_spawnComposition};

    // Place a vehicle
    private _vehtype = ([1, _fac, "Car"] call ALiVE_fnc_findVehicleType) call BIS_fnc_selectRandom;
    if (!isNil "_vehtype") then {
        _vehicle = createVehicle [_vehtype, [position _roadpos, 10,30,2,0,5,0] call BIS_fnc_findsafepos, [], 0, "NONE"];
        _vehicle setDir _direction;
        _vehicle setposATL (getposATL _vehicle);
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
            params ["_vehicle","_roadpos","_fac"];

            private _side = _fac call ALiVE_fnc_factionSide;

            // Spawn group and get them to defend
            private _blockers = [getpos _roadpos, _side, "Infantry", _fac] call ALiVE_fnc_randomGroupByType;
            _blockers addVehicle _vehicle;

            sleep 1;

            [_blockers, getpos _roadpos, 100, true] call ALiVE_fnc_groupGarrison;
        };
    };

};