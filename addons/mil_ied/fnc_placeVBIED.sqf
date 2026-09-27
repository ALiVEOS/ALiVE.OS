#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(placeVBIED);

// Find or create vehicles in town to use as a VB-IED
// _input: _VBIEDarray = [_pos,_radius,(optional) _numberOfVBIEDs] call ALiVE_fnc_placeVBIED

private ["_location","_radius","_veh", "_vblist","_num","_threat"];

_location = _this select 0;
_radius = _this select 1;

_num = if (count _this > 2) then {
    _threat = 100;

    (_this select 2)*10;
} else {
    _threat = ADDON getvariable ["VB_IED_Threat", 10];

    _threat;
};

_debug = ADDON getVariable ["debug", false];
private _vbSide = ADDON getvariable ["VB_IED_Side", "CIV"];

// The cars within radius that are on the chosen side, judged as createVBIED judges them, wrecks
// and quad bikes (which it never rigs) left out. A town whose cars are all of another side makes cars of the chosen side below, instead
// of picking cars that can never be rigged.
_veh = (nearestObjects [_location, ["Car"], _radius]) select {
    private _car = _x;
    private _carSide = if (((crew _car) findIf {alive _x}) < 0) then {
        [getNumber (configFile >> "CfgVehicles" >> typeOf _car >> "side")] call ALIVE_fnc_sideNumberToText
    } else {
        str (side _car)
    };
    alive _car && {_carSide == _vbSide} && {!(_car isKindOf "Quadbike_01_base_F")}
};

_vblist = [];

if (count _veh > 0) then {

    if (_num > count _veh) then {_num = count _veh};

    // select vehicle(s)
    for "_i" from 0 to (_num-1) do {
        private ["_vb","_select"];

        _vb = _veh select _i;

        // Create VBIED
        [_vb] call ALiVE_fnc_createVBIED;

        // Add vehicle to list to return
        _vblist pushback _vb;
    };

} else {
    private ["_carClasses","_roads","_factions"];
    // Create random vehicles
    // On CIV with Ambient Civilians running, cars come from its vehicle faction, then its
    // civilians' faction, since some civilian factions have no cars. Otherwise, or when neither
    // has any, they come from every faction of the chosen side: createVBIED only rigs a car of
    // that side, so civilian cars made for EAST, WEST or IND were never rigged. The module is
    // checked rather than waited for, as this can run from a town's trigger in one frame.
    private _tryFactions = [];
    if (_vbSide == "CIV" && {!isNil QMOD(amb_civ_placement)}) then {
        _tryFactions pushBack [ALiVE_amb_civ_placement getvariable ["ambientVehicleFaction", ""]];
        _tryFactions pushBack [ALiVE_amb_civ_placement getvariable ["faction", "CIV_F"]];
    };
    _tryFactions pushBack (_vbSide call ALiVE_fnc_getSideFactions);
    _carClasses = [];
    {
        if (_carClasses isEqualTo [] && {!(_x isEqualTo [""])}) then {
            _factions = _x;
            // Unarmed cars only: a military faction's list also has wheeled APCs, armed cars
            // and drones, which would stand empty in the street for anyone to drive off. No quad
            // bikes either, as createVBIED never rigs one.
            _carClasses = (([0,_factions,"Car"] call ALiVE_fnc_findVehicleType) - ALiVE_PLACEMENT_VEHICLEBLACKLIST) select {
                !(_x isKindOf "Wheeled_APC_F")
                && {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") != 1}
                && {!([_x] call ALiVE_fnc_isArmed)}
                && {!(_x isKindOf "Quadbike_01_base_F")}
            };
        };
    } forEach _tryFactions;
    _roads = _location nearRoads _radius;

    _num = _num / 10;

    if (_carClasses isEqualTo [] || {_roads isEqualTo []}) exitWith {
        if (_debug) then {
            ["placeVBIED could not find spawn data at %1. Car classes: %2, roads: %3", _location, count _carClasses, count _roads] call ALiVE_fnc_dump;
        };
        _vblist
    };

    for "_i" from 0 to (_num-1) do {
        private ["_vb","_select","_carType","_position","_road","_roadConnectedTo","_roadDirection"];

        // create a random vehicle
        _select = (floor(random (count _carClasses)));
        _carType = _carClasses select _select;
        _road = _roads select (floor(random (count _roads)));
        _position = [position _road, 0, 4, 1, 0, 4, 0] call bis_fnc_findSafePos;
        // Route through the unified vehicle spawn validator (#850).
        // BIS_fnc_findSafePos isn't bbox-aware - a long-thin VBIED
        // carrier whose centre fits a 4 m radius can still clip a
        // wall or fence with its nose / tail and detonate prematurely
        // on spawn. Validator's geometry sweep catches that.
        private _spawnResult = [_carType, _position, 30, "auto"] call ALiVE_fnc_findVehicleSpawnPosition;
        if (count _spawnResult >= 2) then {
            _position = _spawnResult select 0;
        };
        _vb = createVehicle [_carType, _position, [], 0, "NONE"];
        _roadConnectedTo = roadsConnectedTo _road;
        _roadDirection = if (_roadConnectedTo isEqualTo []) then {
            getDir _road
        } else {
            _road getDir (_roadConnectedTo select 0)
        };
        _vb setDir _roadDirection;

        // Create VBIED
        [_vb,_threat] call ALiVE_fnc_createVBIED;

        // Add vehicle to list to return
        _vblist pushback _vb;

        // NOTE: don't "fix" this by reintroducing `_carClasses set [_select, nil]` -
        // nil'ing an index leaves the array length unchanged, and the next
        // iteration's `_carClasses select <random>` can land on the nil hole,
        // making `_carType` undefined at the createVehicle call above.
    };

};

_vblist
