/*
    ALIVE_fnc_RespawnGroundAsset
    #690: replace a lost Combat Support ground transport at its base, within the module's
    Ground Transport respawn limit. The lost one is taken off the tablet; when players are
    aboard it or near it, the hull is left where it is (its crew is cleared once they move
    away) and the replacement still comes from base.
    Params: [vehicle, group, callsign, base, direction, class, respawn seconds, code, audio]
    Author: Jman
*/
params ["_veh", "_grp", "_callsign", "_pos", "_dir", "_type", "_respawn", "_code", ["_audio", false], ["_settings", []]];
private _side = _veh getVariable ["NEO_groundSide", switch (getNumber (configFile >> "CfgVehicles" >> _type >> "side")) do { case 1: {WEST}; case 2: {RESISTANCE}; default {EAST} }];
private _say = { [[player, _this, "side", _side], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP };

if (GROUND_RESPAWN_LIMIT == 0) exitWith { ["STR_ALIVE_CS_MSG_OUT_OF_GROUND"] call _say };

// off the tablet straight away
{
    private _list = NEO_radioLogic getVariable [format ["NEO_radioGroundArray_%1", _x], []];
    { if (!(_x isEqualType []) || {isNull (_x param [0, objNull])} || {(_x select 0) == _veh}) then { _list deleteAt _forEachIndex } } forEachReversed _list;
    NEO_radioLogic setVariable [format ["NEO_radioGroundArray_%1", _x], _list, true];
} forEach [WEST, EAST, RESISTANCE, CIVILIAN];

sleep _respawn;
private _out = false;
isNil { if (GROUND_RESPAWN_LIMIT == 0) then { _out = true } else { GROUND_RESPAWN_LIMIT = GROUND_RESPAWN_LIMIT - 1 } };
if (_out) exitWith { ["STR_ALIVE_CS_MSG_OUT_OF_GROUND"] call _say };

// a supply truck still working on it: let it finish or give up first
private _t = time;
waitUntil { sleep 5; !(_veh getVariable ["ALIVE_resupply_inProgress", false]) || {time - _t > 300} };

// kept only while players are aboard; theirs to drive out, its crew cleared once they're gone
private _keep = !isNull _veh && {alive _veh} && {({ isPlayer _x } count crew _veh) > 0};
if (_keep) then {
    _veh setVariable ["NEO_groundDefendPaused", true, true];
    _veh lockDriver false;
    [_veh, _grp] spawn {
        params ["_veh", "_grp"];
        waitUntil { sleep 10; isNull _veh || {({ isPlayer _x } count crew _veh) == 0} };
        { if (!isPlayer _x) then { deleteVehicle _x } } forEach (units _grp);
        _grp call ALiVE_fnc_DeleteGroupRemote;
    };
} else {
    if (!isNull _veh) then { deleteVehicle _veh };
    { deleteVehicle _x } forEach (units _grp);
    _grp call ALiVE_fnc_DeleteGroupRemote;
    waitUntil { isNull _veh };
};

[_type, _pos, _dir, _callsign, _code, _settings] call NEO_fnc_groundSpawn;
["STR_ALIVE_CS_MSG_BACK_ON_STATION", _callsign] call _say;
