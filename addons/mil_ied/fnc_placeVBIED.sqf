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

// Find all vehicles within radius
_veh = nearestObjects [_location, ["Car"], _radius];

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
    // If ALiVE Ambient civilians are available get the faction from there
    if (["ALiVE_amb_civ_placement"] call ALiVE_fnc_isModuleAvailable) then {

        waituntil {!isnil QMOD(amb_civ_placement)};

        _factions = [ALiVE_amb_civ_placement getvariable ["faction","CIV_F"]];
    } else {
        _factions = ADDON getvariable ["VB_IED_Side", "CIV"] call ALiVE_fnc_getSideFactions;
    };

    _carClasses = [0,_factions,"Car"] call ALiVE_fnc_findVehicleType;
    _carClasses = _carClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;
    _roads = _location nearRoads _radius;

    _num = _num / 10;

    for "_i" from 0 to (_num-1) do {
        private ["_vb","_select","_carType","_position","_road"];

        // create a random vehicle
        _select = (floor(random (count _carClasses)));
        _carType = _carClasses select _select;
        _road = _roads select (floor(random (count _roads)));
        _position = [position _road, 0, 4, 1, 0, 4, 0] call bis_fnc_findSafePos;
        _vb = createVehicle [_carType, _position, [], 0, "NONE"];
        _vb setdir (direction _road);

        // Create VBIED
        [_vb,_threat] call ALiVE_fnc_createVBIED;

        // Add vehicle to list to return
        _vblist pushback _vb;

        // remove from working list to avoid duplicates
        _veh set [_select, nil];
    };

};

_vblist
