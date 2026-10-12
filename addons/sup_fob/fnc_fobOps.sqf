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
unload - [crate, fobID] -> true when a supply crate went into the FOB
upgrade - [fobID] -> true when the FOB went up a tier and was paid for
respawn - [fobID] -> whether the FOB now has a respawn point (tier 3, active, module allows)
fieldHQ - [object, "KIT" or "CRATE"] -> the FOB kit or supply crate handed out, or false
repair - [fobID] -> true when a destroyed headquarters was rebuilt and paid for
repairCost - [fobID] -> the supply a repair costs now
salvage - [fobID] -> the FOB lost for good: everything it had removed
flip - [fobID, side] -> true when the FOB became that side's
garrison - [fobID, free] -> true when a garrison was put in (paid unless free)
releaseGarrison - [fobID] -> its garrison let go to its side's commander
garrisonAlive - [fobID] -> whether its garrison still has anyone
spawnStatic - [fobID, class, position, direction] -> [vehicle profile id, crew profile id]
spawnVehicle - [class, position, direction, faction] -> [vehicle profile id, group profile id], or []
pinStatic - [profile ids] -> keeps them where they are
removeStatic - [vehicle profile id, crew profile id] -> the static weapon and its crew gone
tag - [object, "KIT"/"CRATE"/"HQ", value] -> makes it a FOB kit, supply crate or Field HQ
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

// What the server itself made a FOB kit, a supply crate or a Field HQ. Kept in a list on the
// server keyed by the object's network id: object variables can be set by any client, so the
// public ALiVE_FOB_kit / ALiVE_FOB_crate / ALiVE_FOB_fieldHQ variables are only for players'
// menus and never trusted here.
if (isNil "ALiVE_FOB_tagged") then { ALiVE_FOB_tagged = createHashMap };
private _tagOf = {
    params ["_o", "_kind"];
    if (isNull _o) exitWith { nil };
    private _t = ALiVE_FOB_tagged get (netId _o);
    if (isNil "_t" || {(_t select 0) != _kind}) exitWith { nil };
    _t select 1
};

switch (_op) do {

    // Make an object a FOB kit ("KIT", value true or a side), a supply crate ("CRATE", value the
    // amount) or a Field HQ ("HQ"). For the server and mission scripts: never reachable from a
    // player's machine. Mission makers can hand out kits with
    //     ["tag", [_box, "KIT", true]] call ALiVE_fnc_fobOps;   // on the server
    case "tag": {
        _args params [["_o", objNull, [objNull]], ["_kind", "", [""]], ["_value", true, [true, "", 0]]];
        _result = false;
        if (isNull _o || {!(_kind in ["KIT", "CRATE", "HQ"])}) exitWith {};
        ALiVE_FOB_tagged set [netId _o, [_kind, _value]];
        _o setVariable [["ALiVE_FOB_kit", "ALiVE_FOB_crate", "ALiVE_FOB_fieldHQ"] select (["KIT", "CRATE", "HQ"] find _kind), _value, true];
        _result = true;
    };

    case "deploy": {
        _result = "";
        _args params [["_kit", objNull, [objNull]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]]];
        if (isNull _caller || {!alive _caller}) exitWith {};
        if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0} && {finite _dir}) exitWith {};
        private _side = str (side group _caller);
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith { ["STR_ALIVE_FOB_REFUSED_SIDE"] call _tell };

        // The kit: tagged true (any side) or with a side's name
        private _tag = [_kit, "KIT"] call _tagOf;
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
        ALiVE_FOB_tagged deleteAt (netId _kit);
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
        ["releaseGarrison", [_id]] call ALiVE_fnc_fobOps;
        [_entry, "status", "removed"] call ALIVE_fnc_hashSet;
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        {
            private _o = _x param [0, objNull];
            if (_o isEqualType objNull && {!isNull _o}) then { deleteVehicle _o };
            if (_o isEqualTo "static") then { ["removeStatic", [_x param [3, ""], _x param [4, ""]]] call ALiVE_fnc_fobOps };
        } forEach ([_entry, "objects", []] call ALIVE_fnc_hashGet);
        private _hub = [_entry, "hub", objNull] call ALIVE_fnc_hashGet;
        if (!isNull _hub) then { deleteVehicle _hub };
        // and its place on Military Logistics' supply network, which only the watchdog's pass over
        // this FOB would otherwise have taken away
        if (!isNil "ALIVE_ML_supplyNetwork") then {
            private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
            {
                private _nodes = [ALIVE_ML_supplyNetwork, _x, []] call ALIVE_fnc_hashGet;
                private _i = _nodes findIf { ((_x select 0) distance2D _pos) < 1 && {!(_x param [2, false])} };
                if (_i > -1) then { _nodes deleteAt _i };
            } forEach (ALIVE_ML_supplyNetwork select 1);
        };
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
        // A destroyed headquarters marks the FOB damaged and starts the repair count: repaired
        // in time it's back, otherwise the watchdog salvages the FOB
        _hub addEventHandler ["Killed", {
            params ["_hub"];
            private _e = [ALiVE_FOB_registry, _hub getVariable ["ALiVE_FOB_id", ""]] call ALIVE_fnc_hashGet;
            if (!isNil "_e" && {([_e, "status", ""] call ALIVE_fnc_hashGet) != "damaged"}) then {
                [_e, "status", "damaged"] call ALIVE_fnc_hashSet;
                [_e, "repairRemaining", [ALiVE_sup_fob, "attribute", ["fob_repair_time"]] call ALiVE_fnc_FOB] call ALIVE_fnc_hashSet;
                ["respawn", [_hub getVariable ["ALiVE_FOB_id", ""]]] call ALiVE_fnc_fobOps;
                ALiVE_FOB_dirty = true;
                [ALiVE_sup_fob, "radio", [[_e, "side", "WEST"] call ALIVE_fnc_hashGet, "STR_ALIVE_FOB_RADIO_HQ_DOWN",
                    [[_e, "name", ""] call ALIVE_fnc_hashGet, round (([_e, "repairRemaining", 0] call ALIVE_fnc_hashGet) / 60)]]] call ALiVE_fnc_FOB;
            };
        }];
        // Shot at by a side: that side has found the FOB (Contact targeting)
        _hub addEventHandler ["Hit", {
            params ["_hub", "_source", "", "_instigator"];
            private _who = if (isNull _instigator) then { _source } else { _instigator };
            if (isNull _who) exitWith {};
            private _s = str side group _who;
            private _e = [ALiVE_FOB_registry, _hub getVariable ["ALiVE_FOB_id", ""]] call ALIVE_fnc_hashGet;
            if (isNil "_e" || {!(_s in ["WEST", "EAST", "GUER"])}) exitWith {};
            private _found = [_e, "discoveredBy", []] call ALIVE_fnc_hashGet;
            if (_s != ([_e, "side", ""] call ALIVE_fnc_hashGet) && {!(_s in _found)}) then {
                _found pushBack _s;
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
            private _e = [ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet;
            // a damaged FOB comes back damaged, its headquarters still down
            private _hub = if (([_e, "status", ""] call ALIVE_fnc_hashGet) == "damaged") then { objNull } else { ["spawnHub", [_x]] call ALiVE_fnc_fobOps };
            ["reconcile", [_x]] call ALiVE_fnc_fobObjectives;
            ["restoreObjects", [_x]] call ALiVE_fnc_fobOps;
            ["respawn", [_x]] call ALiVE_fnc_fobOps;
            if (([_e, "tier", 1] call ALIVE_fnc_hashGet) >= 2) then {
                if (["garrisonAlive", [_x]] call ALiVE_fnc_fobOps) then {
                    ["pinStatic", [_e, "garrison", []] call ALIVE_fnc_hashGet] call ALiVE_fnc_fobOps;
                } else {
                    [_e, "garrison", []] call ALIVE_fnc_hashSet;
                    ["garrison", [_x, true]] call ALiVE_fnc_fobOps;
                };
            };
            _result = _result + 1;
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
            if ((_x param [0, objNull]) isEqualTo "vehicle") then {
                _x params ["", "_class", "_cost", "_vid", "", "_pos", "_dir"];
                private _have = if (isNil "ALiVE_ProfileHandler") then { nil } else { [ALiVE_ProfileHandler, "getProfile", _vid] call ALIVE_fnc_profileHandler };
                if (!isNil "_have") then { _live pushBack _x } else {
                    private _nv = ["spawnVehicle", [_class, _pos, _dir, toLower getText (configFile >> "CfgVehicles" >> _class >> "faction")]] call ALiVE_fnc_fobOps;
                    if (_nv isNotEqualTo []) then { _live pushBack (["vehicle", _class, _cost] + _nv + [_pos, _dir]); _result = _result + 1 } else {
                        // kept with no profile id, so the watchdog leaves it and the next start makes it
                        ["ALiVE Player FOBs - %1: couldn't make the %2 again now; kept for the next start", _id, _class] call ALiVE_fnc_dumpR;
                        _live pushBack ["vehicle", _class, _cost, "", "", _pos, _dir];
                    };
                };
                continue;
            };
            if ((_x param [0, objNull]) isEqualTo "static") then {
                // kept when its profile came back with the Virtual AI System's own save, made
                // again otherwise
                _x params ["", "_class", "_cost", "_vid", "_eid", "_pos", "_dir"];
                private _have = if (isNil "ALiVE_ProfileHandler") then { nil } else { [ALiVE_ProfileHandler, "getProfile", _vid] call ALIVE_fnc_profileHandler };
                if (!isNil "_have") then {
                    ["pinStatic", [_vid, _eid]] call ALiVE_fnc_fobOps;
                    _live pushBack _x;
                } else {
                    private _made = ["spawnStatic", [_id, _class, _pos, _dir]] call ALiVE_fnc_fobOps;
                    if (_made isNotEqualTo []) then {
                        _live pushBack (["static", _class, _cost] + _made + [_pos, _dir]);
                        _result = _result + 1;
                    } else {
                        ["ALiVE Player FOBs - %1: couldn't make the %2 again now; kept for the next start", _id, _class] call ALiVE_fnc_dumpR;
                        _live pushBack ["static", _class, _cost, "", "", _pos, _dir];
                    };
                };
                continue;
            };
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
        private _isStatic = _kind == "STATIC";
        private _isVehicle = _kind == "VEHICLE";
        // static weapons and vehicles: from the factions the FOB side's commanders field now, or
        // its own side's when it has no commander
        if (_isStatic || _isVehicle) then {
            private _fobSide = [_entry, "side", ""] call ALIVE_fnc_hashGet;
            private _allowed = ((["factions"] call ALiVE_fnc_fobBuildScan) select { (_x select 0) == _fobSide }) param [0, ["", []]] select 1;
            if (_allowed isEqualTo [] && {((_row select 0) param [6, ""]) != _fobSide}) exitWith { _isStatic = "refused" };
            if (_allowed isNotEqualTo [] && {!(((_row select 0) param [7, ""]) in _allowed)}) exitWith { _isStatic = "refused" };
        };
        if (_isStatic isEqualTo "refused") exitWith { ["STR_ALIVE_FOB_REFUSED_STATIC_SIDE"] call _tell };
        if ((_isStatic || _isVehicle) && {isNil "ALiVE_ProfileHandler"}) exitWith { ["STR_ALIVE_FOB_REFUSED_STATIC_PROFILES"] call _tell };

        if !(["debit", [_id, _cost, "build " + _class]] call ALiVE_fnc_fobSupply) exitWith {
            ["STR_ALIVE_FOB_REFUSED_SUPPLY", [_cost, ["balance", [_id]] call ALiVE_fnc_fobSupply]] call _tell;
        };
        // A vehicle is an empty profile the Virtual AI System looks after; players drive it away
        if (_isVehicle) exitWith {
            private _made = ["spawnVehicle", [_class, _pos, _dir, (_row select 0) param [7, ""]]] call ALiVE_fnc_fobOps;
            if (_made isEqualTo [] || {(_made select 0) == ""}) exitWith {
                ["credit", [_id, _cost, "refund " + _class]] call ALiVE_fnc_fobSupply;
                ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
            };
            ([_entry, "objects", []] call ALIVE_fnc_hashGet) pushBack (["vehicle", _class, _cost] + _made + [_pos, _dir]);
            ALiVE_FOB_dirty = true;
            [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_BUILT", [_name, _cost]] call _tell;
            _result = true;
        };
        // A static weapon is a crewed profile the Virtual AI System looks after, pinned in place:
        // it spawns with its crew while players are near and is kept virtual otherwise
        if (_isStatic) exitWith {
            private _made = ["spawnStatic", [_id, _class, _pos, _dir]] call ALiVE_fnc_fobOps;
            if (_made isEqualTo []) exitWith {
                ["credit", [_id, _cost, "refund " + _class]] call ALiVE_fnc_fobSupply;
                ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
            };
            ([_entry, "objects", []] call ALIVE_fnc_hashGet) pushBack (["static", _class, _cost] + _made + [_pos, _dir]);
            ALiVE_FOB_dirty = true;
            [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_BUILT", [_name, _cost]] call _tell;
            _result = true;
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
        // a static weapon is known by its profile: the spawned gun carries the profile's id
        private _pid = _o getVariable ["profileID", ""];
        private _staticAt = -1;
        if (_id == "" && {_pid != ""}) then {
            {
                private _fid = _x;
                private _i = ([[ALiVE_FOB_registry, _fid] call ALIVE_fnc_hashGet, "objects", []] call ALIVE_fnc_hashGet) findIf { (_x param [0, ""]) in ["static", "vehicle"] && {(_x param [3, ""]) == _pid} };
                if (_i > -1) exitWith { _id = _fid; _staticAt = _i };
            } forEach (ALiVE_FOB_registry select 1);
        };
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILT"] call _tell };
        if (_staticAt > -1) exitWith {
            if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
            if (_caller distance _o > 8) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [8]] call _tell };
            private _objects = [_entry, "objects", []] call ALIVE_fnc_hashGet;
            (_objects select _staticAt) params ["", "_class", ["_cost", 0], "_vid", "_eid"];
            ["removeStatic", [_vid, _eid]] call ALiVE_fnc_fobOps;
            _objects deleteAt _staticAt;
            private _back = floor (_cost * 0.5);
            if (_back > 0) then { ["credit", [_id, _back, "recycle " + _class]] call ALiVE_fnc_fobSupply };
            ALiVE_FOB_dirty = true;
            [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_RECYCLED", [getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _back]] call _tell;
            _result = true;
        };
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

    // A player repairs a destroyed headquarters: the FOB's supply pays, a quarter less with an
    // engineer of its side within 25 m; the wreck and its ruins are cleared and a new one put up
    case "repair": {
        _result = false;
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "damaged") exitWith { ["STR_ALIVE_FOB_REFUSED_NOT_DAMAGED"] call _tell };
        private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        if (_caller distance2D _pos > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        private _cost = ["repairCost", [_id]] call ALiVE_fnc_fobOps;
        if !(["debit", [_id, _cost, "repair"]] call ALiVE_fnc_fobSupply) exitWith {
            ["STR_ALIVE_FOB_REFUSED_SUPPLY", [_cost, ["balance", [_id]] call ALiVE_fnc_fobSupply]] call _tell;
        };
        private _clock = [_entry, "repairRemaining", 0] call ALIVE_fnc_hashGet;
        private _wreck = [_entry, "hub", objNull] call ALIVE_fnc_hashGet;
        if (!isNull _wreck) then { deleteVehicle _wreck };
        { if ((_x distance2D _pos) <= 10) then { deleteVehicle _x } } forEach (nearestObjects [_pos, ["Ruins_F"], 15]);
        [_entry, "hub", objNull] call ALIVE_fnc_hashSet;
        [_entry, "status", "active"] call ALIVE_fnc_hashSet;
        [_entry, "repairRemaining", 0] call ALIVE_fnc_hashSet;
        private _hub = ["spawnHub", [_id]] call ALiVE_fnc_fobOps;
        if (isNull _hub) exitWith {
            ["credit", [_id, _cost, "refund repair"]] call ALiVE_fnc_fobSupply;
            [_entry, "status", "damaged"] call ALIVE_fnc_hashSet;
            [_entry, "repairRemaining", _clock] call ALIVE_fnc_hashSet;
            ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
        };
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        ["STR_ALIVE_FOB_REPAIRED", [[_entry, "name", ""] call ALIVE_fnc_hashGet, _cost]] call _tell;
        _result = true;
    };

    // What a repair costs now: the Repair Cost, x1.5 at tier 2 and x2 at tier 3, a quarter off
    // with an engineer of the FOB's side within 25 m (the watchdog notes that each pass)
    case "repairCost": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = 0 };
        private _c = ([_logic, "attribute", ["fob_repair_cost"]] call ALiVE_fnc_FOB) * ([1, 1.5, 2] param [(([_entry, "tier", 1] call ALIVE_fnc_hashGet) - 1) max 0, 2]);
        if ([_entry, "engineerNear", false] call ALIVE_fnc_hashGet) then { _c = _c * 0.75 };
        _result = round _c;
    };

    // A FOB lost for good: the wreck, everything built there and its objectives go
    case "salvage": {
        _args params [["_id", "", [""]]];
        _result = ["cleanup", [_id]] call ALiVE_fnc_fobOps;
        ["ALiVE Player FOBs - %1 was lost and salvaged", _id] call ALiVE_fnc_dump;
    };

    // The FOB becomes another side's, all at once: its objectives go to the new side's
    // commanders, its marker to the new side's maps, its supply stays with it. The old side's
    // static weapons are let go (no longer pinned, no longer the FOB's). Saved straight away.
    case "flip": {
        _args params [["_id", "", [""]], ["_newSide", "", [""]]];
        _result = false;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {!(_newSide in ["WEST", "EAST", "GUER"])}) exitWith {};
        private _oldSide = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        if (_oldSide == _newSide) exitWith {};
        private _name = [_entry, "name", _id] call ALIVE_fnc_hashGet;
        isNil {
            ["unregister", [_id]] call ALiVE_fnc_fobObjectives;
            ["releaseGarrison", [_id]] call ALiVE_fnc_fobOps;
            // the old side's respawn point goes; the new side gets one if the FOB qualifies
            private _status = [_entry, "status", "active"] call ALIVE_fnc_hashGet;
            [_entry, "status", "flipping"] call ALIVE_fnc_hashSet;
            ["respawn", [_id]] call ALiVE_fnc_fobOps;
            [_entry, "status", _status] call ALIVE_fnc_hashSet;
            private _factions = [];
            { if (([_x, "side", ""] call ALiVE_fnc_hashGet) == _newSide) then { _factions append ([_x, "factions", []] call ALiVE_fnc_hashGet) } } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
            [_entry, "side", _newSide] call ALIVE_fnc_hashSet;
            // no commander of that side: the faction of its men nearest the FOB, else the side's
            // base game faction
            if (_factions isEqualTo []) then {
                private _sideObj = [_newSide] call ALiVE_fnc_sideTextToObject;
                private _men = (([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) nearEntities [["CAManBase"], 500]) select { alive _x && {side group _x == _sideObj} };
                _factions = [(_men apply { faction _x }) param [0, ["OPF_F", "BLU_F", "IND_F"] param [["EAST", "WEST", "GUER"] find _newSide, "BLU_F"]]];
            };
            [_entry, "faction", _factions param [0, ""]] call ALIVE_fnc_hashSet;
            [_entry, "captureSide", ""] call ALIVE_fnc_hashSet;
            [_entry, "captureRemaining", 0] call ALIVE_fnc_hashSet;
            [_entry, "discoveredBy", []] call ALIVE_fnc_hashSet;
            private _objects = [_entry, "objects", []] call ALIVE_fnc_hashGet;
            {
                if ((_x param [0, ""]) isEqualTo "static" && {!isNil "ALIVE_profileStationary"}) then {
                    { [ALIVE_profileStationary, _x] call ALIVE_fnc_hashRem } forEach [_x param [3, ""], _x param [4, ""]];
                };
            } forEach _objects;
            [_entry, "objects", _objects select { !((_x param [0, ""]) in ["static", "vehicle"]) }] call ALIVE_fnc_hashSet;
            private _hub = [_entry, "hub", objNull] call ALIVE_fnc_hashGet;
            if (!isNull _hub) then { _hub setVariable ["ALiVE_FOB_id", _id, true] };
            ["reconcile", [_id]] call ALiVE_fnc_fobObjectives;
            ["respawn", [_id]] call ALiVE_fnc_fobOps;
            ALiVE_FOB_dirty = true;
        };
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        [_logic, "radio", [_oldSide, "STR_ALIVE_FOB_RADIO_LOST", [_name]]] call ALiVE_fnc_FOB;
        [_logic, "radio", [_newSide, "STR_ALIVE_FOB_RADIO_TAKEN", [_name]]] call ALiVE_fnc_FOB;
        ["ALiVE Player FOBs - %1 (%2) taken: %3 to %4", _id, _name, _oldSide, _newSide] call ALiVE_fnc_dump;
        _result = true;
    };

    // A supply crate unloaded into a FOB: as much as the FOB has room for (in force pool mode
    // into the pool), then the crate goes. The crate carries its amount as ALiVE_FOB_crate.
    case "unload": {
        _result = false;
        _args params [["_crate", objNull, [objNull]], ["_id", "", [""]]];
        if (isNull _caller || {!alive _caller} || {isNull _crate}) exitWith {};
        private _amount = [_crate, "CRATE"] call _tagOf;
        if (isNil "_amount" || {!(_amount isEqualType 0)}) then { _amount = 0 };
        if (_amount <= 0) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTCRATE"] call _tell };
        if (_caller distance _crate > 8) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [8]] call _tell };
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOFOB"] call _tell };
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        private _range = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        if (_crate distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > _range) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _range]] call _tell };
        private _have = ["balance", [_id]] call ALiVE_fnc_fobSupply;
        private _cap = ["cap", [_id]] call ALiVE_fnc_fobSupply;
        private _take = if (_cap < 0) then { _amount } else { (_cap - _have) min _amount };
        if (_take <= 0) exitWith { ["STR_ALIVE_FOB_REFUSED_FULL"] call _tell };
        ["credit", [_id, _take, "crate"]] call ALiVE_fnc_fobSupply;
        // what didn't fit stays in the crate
        if (_take < _amount) then { ["tag", [_crate, "CRATE", _amount - _take]] call ALiVE_fnc_fobOps } else { ALiVE_FOB_tagged deleteAt (netId _crate); deleteVehicle _crate };
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["STR_ALIVE_FOB_UNLOADED", [_take, [_entry, "name", ""] call ALIVE_fnc_hashGet]] call _tell;
        _result = true;
    };

    // Tier 2, then tier 3: paid from the FOB's supply, more room for supply and more to build;
    // tier 3 is also a respawn point for its side when the module allows it
    case "upgrade": {
        _result = false;
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "active") exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED_BUILD"] call _tell };
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        private _tier = [_entry, "tier", 1] call ALIVE_fnc_hashGet;
        if (_tier >= 3) exitWith { ["STR_ALIVE_FOB_REFUSED_TOPTIER"] call _tell };
        private _cost = [_logic, "attribute", [format ["fob_tier%1_cost", _tier + 1]]] call ALiVE_fnc_FOB;
        if !(["debit", [_id, _cost, "upgrade"]] call ALiVE_fnc_fobSupply) exitWith {
            ["STR_ALIVE_FOB_REFUSED_SUPPLY", [_cost, ["balance", [_id]] call ALiVE_fnc_fobSupply]] call _tell;
        };
        [_entry, "tier", _tier + 1] call ALIVE_fnc_hashSet;
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        ["STR_ALIVE_FOB_UPGRADED", [[_entry, "name", ""] call ALIVE_fnc_hashGet, _tier + 1, _cost]] call _tell;
        _result = true;
    };

    // The respawn point a FOB should have: one at an active tier 3 FOB when the module allows
    // it, none otherwise. Safe to run any number of times.
    case "respawn": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = false };
        private _want = ([_logic, "attribute", ["fob_respawn"]] call ALiVE_fnc_FOB) && {([_entry, "tier", 1] call ALIVE_fnc_hashGet) >= 3} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"};
        private _have = [_entry, "respawn", []] call ALIVE_fnc_hashGet;
        if !(_have isEqualType []) then { _have = [] };
        if (!_want && {_have isNotEqualTo []}) then {
            _have call BIS_fnc_removeRespawnPosition;
            [_entry, "respawn", []] call ALIVE_fnc_hashSet;
        };
        if (_want && {_have isEqualTo []}) then {
            private _side = [[_entry, "side", "WEST"] call ALIVE_fnc_hashGet] call ALiVE_fnc_sideTextToObject;
            private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
            [_entry, "respawn", [_side, _pos getPos [12, 180], [_entry, "name", ""] call ALIVE_fnc_hashGet] call BIS_fnc_addRespawnPosition] call ALIVE_fnc_hashSet;
        };
        _result = _want;
    };

    // A Field HQ (an object synced to the module) hands out a FOB kit or a supply crate beside
    // it, for the asking player's side. In force pool mode it costs the faction's pool.
    case "fieldHQ": {
        _result = false;
        _args params [["_hq", objNull, [objNull]], ["_what", "", [""]]];
        if (isNull _caller || {isNull _hq} || {isNil {[_hq, "HQ"] call _tagOf}}) exitWith {};
        if !(_what in ["KIT", "CRATE"]) exitWith {};
        if (_caller distance _hq > 10) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [10]] call _tell };
        private _side = str (side group _caller);
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith { ["STR_ALIVE_FOB_REFUSED_SIDE"] call _tell };
        private _amount = [_logic, "attribute", ["fob_crate_amount"]] call ALiVE_fnc_FOB;
        private _cost = if (_what == "KIT") then { [_logic, "attribute", ["fob_kit_cost"]] call ALiVE_fnc_FOB } else { _amount };
        if (([_logic, "attribute", ["fob_supply_source"]] call ALiVE_fnc_FOB) == "FORCEPOOL"
            && {!(["poolDebit", [faction _caller, _cost]] call ALiVE_fnc_fobSupply)}) exitWith { ["STR_ALIVE_FOB_REFUSED_POOL", [_cost]] call _tell };
        private _spot = _hq getPos [6, (getDir _hq) + 90];
        private _o = createVehicle [["B_supplyCrate_F", "Box_NATO_Support_F"] select (_what == "KIT"), _spot, [], 3, "NONE"];
        clearItemCargoGlobal _o; clearWeaponCargoGlobal _o; clearMagazineCargoGlobal _o; clearBackpackCargoGlobal _o;
        if (_what == "KIT") then { ["tag", [_o, "KIT", _side]] call ALiVE_fnc_fobOps } else { ["tag", [_o, "CRATE", _amount]] call ALiVE_fnc_fobOps };
        [["STR_ALIVE_FOB_HQ_CRATE", "STR_ALIVE_FOB_HQ_KIT"] select (_what == "KIT")] call _tell;
        _result = _o;
    };

    // A crewed static weapon as profiles: [vehicle profile id, crew profile id], or [] when it
    // couldn't be made. Its own side's crew; kept where it was put and never sent elsewhere.
    case "spawnStatic": {
        _args params [["_id", "", [""]], ["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]]];
        _result = [];
        if (isNil "ALiVE_ProfileHandler" || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {};
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _side = ["EAST", "WEST", "GUER"] param [getNumber (_cfg >> "side"), "WEST"];
        private _made = [_class, _side, getText (_cfg >> "faction"), "PRIVATE", [_pos select 0, _pos select 1, 0], _dir, false, "", false, true] call ALIVE_fnc_createProfilesCrewedVehicle;
        if (count _made < 2) exitWith {};
        _made params ["_entity", "_vehicle"];
        private _eid = [_entity, "profileID", ""] call ALIVE_fnc_hashGet;
        private _vid = [_vehicle, "profileID", ""] call ALIVE_fnc_hashGet;
        ["pinStatic", [_vid, _eid]] call ALiVE_fnc_fobOps;
        _result = [_vid, _eid];
    };

    // A tier 2 or 3 FOB's garrison: one infantry group of the FOB's faction (or the module's
    // Garrison Group), holding the FOB the way a roadblock's guards hold a checkpoint: garrisoned
    // within 30 m, kept busy and stationary so no commander takes it elsewhere. Paid from the
    // FOB's supply unless free (a reload making good a garrison the save didn't keep).
    case "garrison": {
        _args params [["_id", "", [""]], ["_free", false, [false]]];
        _result = false;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNil "ALiVE_ProfileHandler"}) exitWith {};
        private _faction = [_entry, "faction", ""] call ALIVE_fnc_hashGet;
        private _class = [_logic, "attribute", ["fob_garrison_group"]] call ALiVE_fnc_FOB;
        if (_class == "") then { _class = ["Infantry", _faction] call ALIVE_fnc_configGetRandomGroup };
        // the group lookup answers "FALSE" when the faction has none
        if (!(_class isEqualType "") || {_class in ["", "FALSE"]}) exitWith {
            ["ALiVE Player FOBs - %1: no infantry group for faction %2, so no garrison; trying again in 10 minutes", _id, _faction] call ALiVE_fnc_dumpR;
            [_entry, "garrisonNext", time + 600] call ALIVE_fnc_hashSet;
        };
        private _cost = [_logic, "attribute", ["fob_garrison_cost"]] call ALiVE_fnc_FOB;
        if (!_free && {!(["debit", [_id, _cost, "garrison"]] call ALiVE_fnc_fobSupply)}) exitWith {};
        private _pos = ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) getPos [15, random 360];
        private _made = [_class, _pos, random 360, true, _faction, true] call ALIVE_fnc_createProfilesFromGroupConfig;
        private _ids = [];
        {
            if (([_x, "type", ""] call ALIVE_fnc_hashGet) == "entity") then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [30, "false", [0,0,0], "", 1, 0.3, "SAFE", "LIMITED", ""]]] call ALIVE_fnc_profileEntity;
                [_x, "busy", true] call ALIVE_fnc_hashSet;
                _ids pushBack ([_x, "profileID", ""] call ALIVE_fnc_hashGet);
            };
        } forEach _made;
        if (_ids isEqualTo []) exitWith {
            if (!_free) then { ["credit", [_id, _cost, "refund garrison"]] call ALiVE_fnc_fobSupply };
            [_entry, "garrisonNext", time + 600] call ALIVE_fnc_hashSet;
        };
        ["pinStatic", _ids] call ALiVE_fnc_fobOps;
        [_entry, "garrison", _ids] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
        ["ALiVE Player FOBs - %1: garrison %2 (%3) %4", _id, _class, _ids, ["paid " + str _cost, "free"] select _free] call ALiVE_fnc_dump;
        _result = true;
    };

    // The garrison let go: no longer pinned or kept busy, so its side's commander can use it
    case "releaseGarrison": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = false };
        {
            if (!isNil "ALIVE_profileStationary") then { [ALIVE_profileStationary, _x] call ALIVE_fnc_hashRem };
            private _pr = if (isNil "ALiVE_ProfileHandler") then { nil } else { [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler };
            if (!isNil "_pr") then { [_pr, "busy", false] call ALIVE_fnc_hashSet };
        } forEach ([_entry, "garrison", []] call ALIVE_fnc_hashGet);
        [_entry, "garrison", []] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
        _result = true;
    };

    // Whether the garrison still has anyone: some of its profiles still exist
    case "garrisonAlive": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        _result = !isNil "_entry" && {!isNil "ALiVE_ProfileHandler"}
            && {(([_entry, "garrison", []] call ALIVE_fnc_hashGet) findIf { !isNil {[ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler} }) > -1};
    };

    // An empty vehicle as a profile at a spot: its profile id, or "" when it couldn't be made
    case "spawnVehicle": {
        _args params [["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_faction", "", [""]]];
        _result = [];
        if (isNil "ALiVE_ProfileHandler" || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {};
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _side = ["EAST", "WEST", "GUER"] param [getNumber (_cfg >> "side"), "WEST"];
        private _made = [_class, _side, getText (_cfg >> "faction"), [_pos select 0, _pos select 1, 0], _dir, false] call ALIVE_fnc_createProfilesUnCrewedVehicle;
        // it hands back the vehicle's profile and an empty group's; the vehicle's id is the one kept,
        // the group's goes with it when the vehicle is removed
        private _veh = _made select { ([_x, "type", ""] call ALIVE_fnc_hashGet) == "vehicle" };
        if (_veh isEqualTo []) exitWith {};
        private _grp = _made select { ([_x, "type", ""] call ALIVE_fnc_hashGet) == "entity" };
        _result = [[_veh select 0, "profileID", ""] call ALIVE_fnc_hashGet, ([_grp param [0, []], "profileID", ""] call ALIVE_fnc_hashGet)];
    };

    case "pinStatic": {
        if (isNil "ALIVE_profileStationary") then { ALIVE_profileStationary = [] call ALIVE_fnc_hashCreate };
        { if (_x != "") then { [ALIVE_profileStationary, _x, true] call ALIVE_fnc_hashSet } } forEach _args;
        _result = true;
    };

    // A static weapon's profiles gone: crew first, then the gun, each taking its spawned
    // units and vehicle with it
    case "removeStatic": {
        _args params [["_vid", "", [""]], ["_eid", "", [""]]];
        _result = false;
        if (isNil "ALiVE_ProfileHandler") exitWith {};
        {
            private _pr = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
            if (!isNil "_pr") then {
                if (([_pr, "type", ""] call ALIVE_fnc_hashGet) == "entity") then { [_pr, "destroy"] call ALIVE_fnc_profileEntity } else { [_pr, "destroy"] call ALIVE_fnc_profileVehicle };
                _result = true;
            };
            if (!isNil "ALIVE_profileStationary") then { [ALIVE_profileStationary, _x] call ALIVE_fnc_hashRem };
        } forEach [_eid, _vid];
    };

    default {
        ["ALiVE Player FOBs - no operation called %1", _op] call ALiVE_fnc_dump;
    };
};

if (isNil "_result") then { nil } else { _result }
