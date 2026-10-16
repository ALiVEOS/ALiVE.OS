/*
    NEO_fnc_groundSpawn
    #690: make (or adopt) a Combat Support ground transport, crew it, set it up and start its
    order loop. Used at mission start and on respawn. Server-side.
    Params: [class, position ATL, direction, callsign, code, settings]
      settings: [logistics on, logistics source, disarm chance 0-100, road check on]
    Returns: [vehicle, group, order loop handle]
    Author: Jman
*/
params ["_type", "_pos", "_dir", "_callsign", "_code", ["_settings", []]];
_settings params [["_logistics", false], ["_logisticsSource", 0], ["_disarm", 70], ["_mineCheck", true]];
private _side = switch (getNumber (configFile >> "CfgVehicles" >> _type >> "side")) do { case 1: {WEST}; case 2: {RESISTANCE}; default {EAST} };

// a kept deck or roof height needs something still under it (a building can be destroyed since):
// with nothing there the asset comes back on the ground below, as it always did
_pos = +_pos;
if ((_pos select 2) >= 1.5 && {(lineIntersectsSurfaces [(ATLToASL _pos) vectorAdd [0, 0, 0.5], (ATLToASL _pos) vectorAdd [0, 0, -3], objNull, objNull, true, 1, "GEOM", "NONE"]) isEqualTo []}) then { _pos set [2, 0] };

// an editor-placed one at the module is adopted, but never one another ground transport already runs
// (two parked side by side) or a lost one left where it stopped.
// _pos is above the ground, kept for one on a deck or pier; a search reads above the surface there
private _near = ASLToAGL ATLToASL _pos;
private _veh = ((nearestObjects [_near, [_type], 5]) select {
    alive _x && {isNil {_x getVariable "NEO_groundBrain"}} && {(_x getVariable ["NEO_radioGroundRun", 0]) != -1}
}) param [0, objNull];
private _grp = grpNull;
if (isNull _veh) then {
    // anything already standing on the spot (a kept wreck, another vehicle): set it down beside it
    private _at = _pos;
    // (not on a deck or pier: the free spot found is on the ground below)
    if ((_pos select 2) < 1.5 && {(nearestObjects [_near, ["LandVehicle", "Air"], 6]) isNotEqualTo []}) then {
        private _free = _pos findEmptyPosition [6, 40, _type];
        if (_free isNotEqualTo []) then { _at = _free };
    };
    _grp = createGroup _side;
    _veh = createVehicle [_type, _at, [], 0, "CAN_COLLIDE"];
    _veh setDir _dir;
    _veh setPosATL _at;
    createVehicleCrew _veh;
    (crew _veh) joinSilent _grp;
    _grp addVehicle _veh;
} else {
    // an editor-placed vehicle serves the side of the crew put in it; an empty one gets a crew
    if (isNull driver _veh) then {
        _grp = createGroup _side;
        createVehicleCrew _veh;
        (crew _veh) joinSilent _grp;
        _grp addVehicle _veh;
    } else {
        _grp = group (driver _veh);
        _side = side _grp;
    };
};
_veh setVariable ["NEO_groundBrain", true];
if (getNumber (configFile >> "CfgVehicles" >> _type >> "side") == 3 && {isNull _grp || {side _grp == EAST}}) then {
    ["ALiVE Combat Support - ground transport %1: %2 is a civilian vehicle, so it is crewed and listed as EAST. Place it with a crew of the side it should serve, or pick a military vehicle.", _callsign, _type] call ALiVE_fnc_dump;
};
_veh setVariable ["NEO_groundSide", _side, true];

// a support asset belongs to the players: keep it away from the AI commander and the profiler
if (!isNil "ALIVE_profileHandler") then {
    {
        private _id = _x getVariable ["profileID", ""];
        if (_id != "") then {
            private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
            if (!isNil "_profile") then { [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler };
            _x setVariable ["profileID", nil];
        };
    } forEach ([_veh] + (crew _veh));
};
_veh setVariable ["ALIVE_CombatSupport", true, true];
_veh setVariable ["ALIVE_profileIgnore", true, true];
_grp setVariable ["ALIVE_profileIgnore", true, true];
{ _x setVariable ["VCOM_NOAI", true] } forEach (crew _veh);
_veh lockDriver true;

_veh setVariable ["ALIVE_logistics_enabled", _logistics, true];
_veh setVariable ["ALIVE_logistics_source", _logisticsSource, true];
_veh setVariable ["NEO_groundDisarmChance", (_disarm max 0) min 100, true];
_veh setVariable ["NEO_groundMineCheck", _mineCheck, true];
_veh setVariable ["NEO_groundAvailableTasks", ["PICKUP", "MOVE", "PATROL"], true];
_veh setVariable ["NEO_groundSettings", _settings, true];

private _hdl = [[(units _grp) select 0, _callsign], "fnc_setGroupID", false, false] spawn BIS_fnc_MP;
waitUntil { scriptDone _hdl };

{
    if (_x != "") then { [_veh, _x] spawn { params ["_veh", "_c"]; [_veh] spawn (compile _c) } };
} forEach ([_code, ";"] call CBA_fnc_split);

private _audio = NEO_radioLogic getVariable ["combatsupport_audio", true];
private _brain = [_veh, _grp, _callsign, _pos, _dir, _type, CS_RESPAWN, _code, _audio, _settings] spawn NEO_fnc_groundBrain;
_veh setVariable ["NEO_groundBrain", _brain];

// listed for its own side and every side friendly to it
private _entry = [_veh, _grp, _callsign, _brain];
{
    if (_x == _side || {(_side getFriend _x) >= 0.6}) then {
        private _list = NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", _x], []];
        _list pushBack _entry;
        NEO_radioLogic setVariable [format ["NEO_radioGroundArray_%1", _x], _list, true];
    };
} forEach [WEST, EAST, RESISTANCE, CIVILIAN];

[_veh, _grp, _brain]
