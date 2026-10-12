#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobOps);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobOps

Description:
Every change to a FOB, done on the server. Reached only through ALiVE_fnc_fobRequest (a
player) or from the server itself (start-up, the watchdog). The side is always the caller's
own, never one the request names.

deploy turns a FOB kit into a FOB: a headquarters building, an entry in the registry, a map
marker for that side and an objective for that side's AI Commanders. It is refused, with the
reason sent back to the player, when the kit isn't a FOB kit for that side, the player is not
by it, the spot is in water or on ground steeper than about 15 degrees, too close to another FOB of any side, or the side already has as
many FOBs as it may.

dismantle takes a FOB down: its objectives, buildings and entry go; its supply is lost.

build puts up an item from the build catalog within the FOB's build range, paid for from the
FOB's supply at the catalog's price; recycle takes one down again for half of what was paid.

Parameters:
String - The operation
Array - Its arguments
Object - The player asking (objNull from the server itself)

Returns:
deploy - [kit, position, direction] -> the new FOB's id, or ""
dismantle - [fobID] -> true when it was taken down
build - [class, position, direction, fobID] -> true when built and paid for
recycle - [object] -> true when taken down, with half its price back
restoreObjects - [fobID] -> a saved FOB's built objects made again; the number made
cleanup - [fobID] -> removes a FOB and everything it made, no checks
restore - [] -> rebuilds every loaded FOB's headquarters and objectives; the number rebuilt
spawnHub - [fobID] -> the headquarters building, made if missing

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

params [["_op", "", [""]], ["_args", [], [[]]], ["_caller", objNull, [objNull]]];

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _debug = [_logic, "attribute", ["fob_debug"]] call ALiVE_fnc_FOB;
private _result = nil;

// Tell the player why, on their own machine only
private _tell = {
    params ["_key", ["_fmt", []]];
    ALiVE_FOB_lastMessage = _key;   // read by the debug output and tests
    if (!isNull _caller && {isPlayer _caller}) then {
        ["notify", [_key, _fmt]] remoteExecCall ["ALiVE_fnc_fobClient", _caller];
    };
    if (_debug) then { ["ALiVE Player FOBs - %1 %2 for %3", _key, _fmt, name _caller] call ALiVE_fnc_dump };
};

switch (_op) do {

    case "deploy": {
        _result = "";
        _args params [["_kit", objNull, [objNull]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]]];
        if (isNull _caller || {!alive _caller}) exitWith {};
        private _side = str (side group _caller);
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith { ["STR_ALIVE_FOB_REFUSED_SIDE"] call _tell };

        // The kit: tagged true (any side) or with a side's name
        private _tag = if (isNull _kit) then { nil } else { _kit getVariable "ALiVE_FOB_kit" };
        if (isNil "_tag" || {!(_tag isEqualTo true || {_tag isEqualTo _side})}) exitWith { ["STR_ALIVE_FOB_REFUSED_KIT"] call _tell };
        if (_caller distance _kit > 50) exitWith { ["STR_ALIVE_FOB_REFUSED_KIT"] call _tell };

        _pos = [_pos param [0, 0], _pos param [1, 0], 0];
        if (_pos distance2D _kit > 50) then { _pos = getPosATL _kit; _pos set [2, 0] };
        if (surfaceIsWater _pos || {getTerrainHeightASL _pos < -0.5}) exitWith { ["STR_ALIVE_FOB_REFUSED_WATER"] call _tell };
        // Steeper than about 15 degrees and the headquarters stands half in the hillside
        if (((surfaceNormal _pos) select 2) < 0.966) exitWith { ["STR_ALIVE_FOB_REFUSED_SLOPE"] call _tell };

        if !(["canDeploy", [_side]] call ALiVE_fnc_fobCap) exitWith {
            ["STR_ALIVE_FOB_REFUSED_CAP", [["capForSide", [_side]] call ALiVE_fnc_fobCap]] call _tell;
        };

        private _minDist = [_logic, "attribute", ["fob_min_distance"]] call ALiVE_fnc_FOB;
        private _near = (ALiVE_FOB_registry select 1) findIf {
            (([[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "pos", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _pos) < _minDist
        };
        if (_near > -1) exitWith { ["STR_ALIVE_FOB_REFUSED_DISTANCE", [_minDist]] call _tell };

        private _id = [_logic, "nextID", [_side]] call ALiVE_fnc_FOB;
        private _entry = [_logic, "newEntry", [_id, _side, faction _caller, _pos, _dir]] call ALiVE_fnc_FOB;
        [_logic, "registrySet", [_id, _entry]] call ALiVE_fnc_FOB;

        private _hub = ["spawnHub", [_id]] call ALiVE_fnc_fobOps;
        if (isNull _hub) exitWith {
            [_logic, "registryRemove", [_id]] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
        };

        ["register", [_id]] call ALiVE_fnc_fobObjectives;
        deleteVehicle _kit;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;

        ["STR_ALIVE_FOB_DEPLOYED", [[_entry, "name"] call ALIVE_fnc_hashGet]] call _tell;
        ["ALiVE Player FOBs - %1 deployed %2 (%3) at %4", name _caller, _id, [_entry, "name"] call ALIVE_fnc_hashGet, _pos] call ALiVE_fnc_dump;
        _result = _id;
    };

    case "dismantle": {
        _result = false;
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) == "damaged") exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED"] call _tell };

        private _name = [_entry, "name", ""] call ALIVE_fnc_hashGet;
        ["cleanup", [_id]] call ALiVE_fnc_fobOps;
        ["STR_ALIVE_FOB_DISMANTLED", [_name]] call _tell;
        ["ALiVE Player FOBs - %1 dismantled %2 (%3)", name _caller, _id, _name] call ALiVE_fnc_dump;
        _result = true;
    };

    case "cleanup": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = false };
        ["unregister", [_id]] call ALiVE_fnc_fobObjectives;
        {
            private _o = _x param [0, objNull];
            if (_o isEqualType objNull && {!isNull _o}) then { deleteVehicle _o };
        } forEach ([_entry, "objects", []] call ALIVE_fnc_hashGet);
        private _hub = [_entry, "hub", objNull] call ALIVE_fnc_hashGet;
        if (!isNull _hub) then { deleteVehicle _hub };
        [_logic, "registryRemove", [_id]] call ALiVE_fnc_FOB;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        _result = true;
    };

    case "spawnHub": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = objNull };
        private _hub = [_entry, "hub", objNull] call ALIVE_fnc_hashGet;
        if (!isNull _hub && {alive _hub}) exitWith { _result = _hub };

        private _class = [_entry, "hubClass", ""] call ALIVE_fnc_hashGet;
        private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        if !(isClass (configFile >> "CfgVehicles" >> _class)) exitWith {
            ["ALiVE Player FOBs - %1: no building class %2 in this game; set another in the module", _id, _class] call ALiVE_fnc_dumpR;
            _result = objNull;
        };
        _hub = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
        // Sits on the slope and keeps its heading: setVectorUp alone twists the heading round.
        // Turned first, then placed, as turning moves it a little
        private _d = [_entry, "dir", 0] call ALIVE_fnc_hashGet;
        private _up = surfaceNormal _pos;
        // the heading's own x and y, tipped up or down to lie along the slope
        private _tip = -((sin _d) * (_up select 0) + (cos _d) * (_up select 1)) / ((_up select 2) max 0.1);
        _hub setVectorDirAndUp [vectorNormalized [sin _d, cos _d, _tip], _up];
        _hub setPosATL _pos;
        _hub setVariable ["ALiVE_FOB_id", _id, true];
        // A destroyed headquarters marks the FOB damaged: it can't be taken down until repaired
        _hub addEventHandler ["Killed", {
            params ["_hub"];
            private _e = [ALiVE_FOB_registry, _hub getVariable ["ALiVE_FOB_id", ""]] call ALIVE_fnc_hashGet;
            if (!isNil "_e") then {
                [_e, "status", "damaged"] call ALIVE_fnc_hashSet;
                ALiVE_FOB_dirty = true;
            };
        }];
        [_entry, "hub", _hub] call ALIVE_fnc_hashSet;
        _result = _hub;
    };

    // After a load: the buildings and objectives a saved FOB had, made again
    case "restore": {
        _result = 0;
        {
            private _hub = ["spawnHub", [_x]] call ALiVE_fnc_fobOps;
            ["reconcile", [_x]] call ALiVE_fnc_fobObjectives;
            ["restoreObjects", [_x]] call ALiVE_fnc_fobOps;
            if (!isNull _hub) then { _result = _result + 1 };
        } forEach +(ALiVE_FOB_registry select 1);
        if (_result > 0) then { ["ALiVE Player FOBs - rebuilt %1 FOBs from the save", _result] call ALiVE_fnc_dump };
    };

    // A saved FOB's built objects, made again where they stood: a saved one is
    // [class, posWorld, vectorDir, vectorUp, cost], a live one [object, class, cost]
    case "restoreObjects": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = 0 };
        _result = 0;
        private _live = [];
        {
            if ((_x param [0, objNull]) isEqualType "") then {
                _x params ["_class", "_pos", "_vdir", "_vup", ["_cost", 0]];
                if (isClass (configFile >> "CfgVehicles" >> _class)) then {
                    private _o = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
                    // the world position read at save time: unlike setPosATL, setPosWorld puts a
                    // tilted object back exactly where it stood
                    _o setVectorDirAndUp [_vdir, _vup];
                    _o setPosWorld _pos;
                    _o setVariable ["ALiVE_FOB_object", _id, true];
                    _live pushBack [_o, _class, _cost];
                    _result = _result + 1;
                } else {
                    ["ALiVE Player FOBs - %1: %2 isn't in this game any more, so it wasn't rebuilt", _id, _class] call ALiVE_fnc_dumpR;
                };
            } else {
                _live pushBack _x;
            };
        } forEach ([_entry, "objects", []] call ALIVE_fnc_hashGet);
        [_entry, "objects", _live] call ALIVE_fnc_hashSet;
    };

    // A player builds a catalog item at their side's FOB. Only the class, place, heading and
    // FOB come from the player; the price comes from the server's catalog. Paid first, refunded
    // if the object can't be made.
    case "build": {
        _result = false;
        _args params [["_class", "", [""]], ["_pos", [], [[]]], ["_dir", 0, [0]], ["_id", "", [""]]];
        if (isNull _caller || {!alive _caller}) exitWith {};
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOFOB"] call _tell };
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "active") exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED_BUILD"] call _tell };
        if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0}) exitWith {};
        _pos = [_pos select 0, _pos select 1, 0];
        if ((_pos select 0) < 0 || {(_pos select 1) < 0} || {(_pos select 0) > worldSize} || {(_pos select 1) > worldSize}) exitWith {};
        if !(finite _dir) exitWith {};
        private _range = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        private _centre = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        if (_pos distance2D _centre > _range || {_caller distance2D _centre > _range}) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _range]] call _tell };
        if (surfaceIsWater _pos) exitWith { ["STR_ALIVE_FOB_REFUSED_WATER"] call _tell };

        private _row = (missionNamespace getVariable ["ALiVE_FOB_catalog", []]) select { (_x select 0) == _class };
        if (_row isEqualTo []) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILDABLE"] call _tell };
        (_row select 0) params ["", "_name", "_kind", "_cost", "", ["_tierMin", 1]];
        if (([_entry, "tier", 1] call ALIVE_fnc_hashGet) < _tierMin) exitWith { ["STR_ALIVE_FOB_REFUSED_TIER", [_tierMin]] call _tell };

        if !(["debit", [_id, _cost, "build " + _class]] call ALiVE_fnc_fobSupply) exitWith {
            ["STR_ALIVE_FOB_REFUSED_SUPPLY", [_cost, ["balance", [_id]] call ALiVE_fnc_fobSupply]] call _tell;
        };
        private _o = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
        if (isNull _o) exitWith {
            ["credit", [_id, _cost, "refund " + _class]] call ALiVE_fnc_fobSupply;
            ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
        };
        // on the slope, keeping the heading the player chose; turned first, then placed
        private _up = surfaceNormal _pos;
        private _tip = -((sin _dir) * (_up select 0) + (cos _dir) * (_up select 1)) / ((_up select 2) max 0.1);
        _o setVectorDirAndUp [vectorNormalized [sin _dir, cos _dir, _tip], _up];
        _o setPosATL _pos;
        if (((getPosATL _o) select 2) < 0) then { _o setPosATL [_pos select 0, _pos select 1, 0] };
        _o setVariable ["ALiVE_FOB_object", _id, true];
        ([_entry, "objects", []] call ALIVE_fnc_hashGet) pushBack [_o, _class, _cost];
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["STR_ALIVE_FOB_BUILT", [_name, _cost]] call _tell;
        _result = true;
    };

    // Half the price back, worked out from what was paid, never from the object itself
    case "recycle": {
        _result = false;
        _args params [["_o", objNull, [objNull]]];
        if (isNull _caller || {!alive _caller} || {isNull _o}) exitWith {};
        private _id = _o getVariable ["ALiVE_FOB_object", ""];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILT"] call _tell };
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (_caller distance _o > 8) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [8]] call _tell };
        private _objects = [_entry, "objects", []] call ALIVE_fnc_hashGet;
        private _i = _objects findIf { (_x param [0, objNull]) isEqualTo _o };
        if (_i < 0) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILT"] call _tell };
        (_objects select _i) params ["", "_class", ["_cost", 0]];
        _objects deleteAt _i;
        deleteVehicle _o;
        private _back = floor (_cost * 0.5);
        if (_back > 0) then { ["credit", [_id, _back, "recycle " + _class]] call ALiVE_fnc_fobSupply };
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["STR_ALIVE_FOB_RECYCLED", [getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _back]] call _tell;
        _result = true;
    };

    default {
        ["ALiVE Player FOBs - no operation called %1", _op] call ALiVE_fnc_dump;
    };
};

if (isNil "_result") then { nil } else { _result }
