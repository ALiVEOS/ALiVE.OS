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

dismantle takes a FOB down: its objectives, buildings and entry go; its kit comes back, with
what was left of its supply in a crate.

build puts up an item from the build catalog within the FOB's build range, paid for from the
FOB's supply at the catalog's price; recycle takes one down again for half of what was paid.

Dismantle, recycle and rename also need the module's Who Can Dismantle to let the player in
(ALiVE_fnc_FOB "mayManage"); an admin can change it in game with permissions.

Parameters:
String - The operation
Array - Its arguments
Object - The player asking (objNull from the server itself)

Returns:
deploy - [kit, position, direction] -> the new FOB's id, or ""
dismantle - [fobID] -> true when it was taken down
zeusDeploy - [side, position, direction, typeID] -> [id] or ["", refusal string key, its arguments]: a Zeus's FOB,
    with no kit, cost or who-may-deploy check (sys_zeus Create FOB)
build - [class, position, direction, fobID] -> true when built and paid for
recycle - [object] -> true when taken down, with half its price back
restoreObjects - [fobID] -> a saved FOB's built objects made again; the number made
unload - [crate, fobID] -> true when a supply crate went into the FOB
upgrade - [fobID] -> true when the FOB went up a tier and was paid for
respawn - [fobID] -> whether the FOB now has a respawn point (active, at or above the Respawn Point tier)
rename - [fobID, name] -> true when the FOB took the new name
retype - [fobID, type id] -> true when the FOB changed to that FOB type
permissions - [rules, list] -> true when an admin changed Who Can Dismantle and its list
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
kitInit - [object] -> an ALiVE_FOB_Kit or ALiVE_FOB_SupplyCrate the server made becomes one
cleanup - [fobID] -> removes a FOB and everything it made, no checks
arsenalOpen - [box, haveList, fobID] -> true when the player may use that FOB Arsenal now; with a null box and
    a FOB id, the arsenal at that FOB's headquarters
arsenalClose - [loadout] -> true when the visit is being settled
arsenalSettle - [uid, why, loadout] -> the visit paid for from the FOB's supply, or the kit put back
restore - [] -> rebuilds every loaded FOB's headquarters and objectives; the number rebuilt
spawnHub - [fobID] -> the headquarters building, made if missing

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

params [["_op", "", [""]], ["_args", [], [[]]], ["_caller", objNull, [objNull]]];

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];

// An object class from a module setting (AshTray and A. Ares on Discord, 20 Oct): one class for every side, or per side as
// "WEST=ClassA, EAST=ClassB, GUER=ClassC"; the side's own entry, else a plain one, else the default. A class the game
// doesn't have is reported and the default used.
private _pickClass = {
    params [["_raw", "", [""]], ["_side", "", [""]], ["_default", "", [""]]];
    private _plain = ""; private _mine = "";
    {
        private _p = _x splitString "= ";
        if (count _p == 1 && {_plain == ""}) then { _plain = _p select 0 };
        if (count _p >= 2 && {toUpper (_p select 0) == toUpper _side}) then { _mine = _p select 1 };
    } forEach (_raw splitString ",;");
    private _c = [_mine, _plain] select (_mine == "");
    if (_c != "" && {isClass (configFile >> "CfgVehicles" >> _c)}) exitWith { _c };
    if (_c != "") then { ["ALiVE - %1 is not an object class the game has; %2 is used instead", _c, [_default, "the usual one"] select (_default == "")] call ALiVE_fnc_dump };
    _default
};
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

// Who Can Dismantle: whether the caller may take this FOB down, recycle at it or rename it
private _mayManage = {
    params ["_entry"];
    [_logic, "mayManage", [_caller, [_entry, "deployedBy", ""] call ALIVE_fnc_hashGet]] call ALiVE_fnc_FOB
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
        // a kit or crate the module made itself is saved with the FOBs, so a change to one is a change to save
        if (_o getVariable ["ALiVE_FOB_loose", false]) then { ALiVE_FOB_dirty = true };
        _result = true;
    };

    // The FOB Kit and FOB Supply Crate classes, from their init event: placed in Eden, ordered
    // from the Player Resupply tablet (Military Logistics makes them on the server) or put down
    // by Zeus. Only one the server made itself counts; a copy a player's machine makes stays a
    // plain box. Tagged once the module is up, a crate with the module's Crate Supply.
    case "kitInit": {
        _args params [["_o", objNull, [objNull]]];
        _result = false;
        if (isNull _o || {!local _o}) exitWith {};
        _o spawn {
            private _t0 = diag_tickTime;
            waitUntil { sleep 1; (!isNil "ALiVE_sup_fob" && {ALiVE_sup_fob getVariable ["startupComplete", false]}) || {diag_tickTime - _t0 > 600} };
            if (isNull _this || {isNil "ALiVE_sup_fob"}) exitWith {};
            // already given its own value by the server (a dismantled FOB's kit and leftover supply)
            if ((ALiVE_FOB_tagged getOrDefault [netId _this, []]) isNotEqualTo []) exitWith {};
            if (_this isKindOf "ALiVE_FOB_Kit") then { ["tag", [_this, "KIT", true]] call ALiVE_fnc_fobOps } else {
                ["tag", [_this, "CRATE", [ALiVE_sup_fob, "attribute", ["fob_crate_amount"]] call ALiVE_fnc_FOB]] call ALiVE_fnc_fobOps;
            };
        };
        _result = true;
    };

    case "deploy": {
        _result = "";
        _args params [["_kit", objNull, [objNull]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_hubClass", "", [""]], ["_type", "", [""]]];
        if (isNull _caller || {!alive _caller}) exitWith {};
        // the FOB type the player picked: none when the mission has no FOB Types
        private _types = missionNamespace getVariable ["ALiVE_FOB_types", []];
        if (_types isEqualTo []) then { _type = "" };
        private _spec = [_logic, "typeSpec", [_type]] call ALiVE_fnc_FOB;
        if (_spec isEqualTo [] || {_type == "" && {_types isNotEqualTo []} && {!(missionNamespace getVariable ["ALiVE_FOB_typesGeneral", true])}}) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE"] call _tell;
        };
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
        if !([_logic, "mayDeployType", [_caller, _type]] call ALiVE_fnc_FOB) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE_WHO", [_spec select 1]] call _tell;
        };
        if !(["canDeployType", [_side, _type]] call ALiVE_fnc_fobCap) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE_CAP", [_spec select 1, _spec select 11]] call _tell;
        };

        private _minDist = [_logic, "attribute", ["fob_min_distance"]] call ALiVE_fnc_FOB;
        private _near = (ALiVE_FOB_registry select 1) findIf {
            (([[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "pos", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _pos) < _minDist
        };
        if (_near > -1) exitWith { ["STR_ALIVE_FOB_REFUSED_DISTANCE", [_minDist]] call _tell };

        private _id = [_logic, "nextID", [_side]] call ALiVE_fnc_FOB;
        private _entry = [_logic, "newEntry", [_id, _side, faction _caller, _pos, _dir, _hubClass, _type]] call ALiVE_fnc_FOB;
        [_entry, "deployedBy", getPlayerUID _caller] call ALIVE_fnc_hashSet;
        [_logic, "registrySet", [_id, _entry]] call ALiVE_fnc_FOB;

        // a type's cost: from the faction's force pool, or out of the new FOB's starting supply
        private _typeCost = _spec select 10;
        if (_typeCost > 0 && {!(["debit", [_id, _typeCost, "FOB type " + _type]] call ALiVE_fnc_fobSupply)}) exitWith {
            [_logic, "registryRemove", [_id]] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_REFUSED_TYPE_COST", [_spec select 1, _typeCost]] call _tell;
        };

        private _hub = ["spawnHub", [_id]] call ALiVE_fnc_fobOps;
        if (isNull _hub) exitWith {
            if (_typeCost > 0) then { ["credit", [_id, _typeCost, "refund FOB type " + _type]] call ALiVE_fnc_fobSupply };
            [_logic, "registryRemove", [_id]] call ALiVE_fnc_FOB;
            ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
        };

        ["register", [_id]] call ALiVE_fnc_fobObjectives;
        ALiVE_FOB_tagged deleteAt (netId _kit);
        deleteVehicle _kit;
        // a respawn point from deployment when Respawn Point is From tier 1
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;

        ["STR_ALIVE_FOB_DEPLOYED", [[_entry, "name"] call ALIVE_fnc_hashGet]] call _tell;
        ["ALiVE Player FOBs - %1 deployed %2 (%3) at %4", name _caller, _id, [_entry, "name"] call ALIVE_fnc_hashGet, _pos] call ALiVE_fnc_dump;
        _result = _id;
    };

    // A Zeus puts a FOB down (Jman, 29 Oct): no kit, no caller and no cost, and the side cap and
    // who may deploy a type don't apply. Water, slope and the distance between FOBs still do, as
    // the headquarters needs somewhere it can stand.
    case "zeusDeploy": {
        _args params [["_side", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_type", "", [""]]];
        _result = ["", "STR_ALIVE_FOB_REFUSED_SIDE", []];
        if !(_side in ["WEST", "EAST", "GUER"]) exitWith {};
        if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0} && {finite _dir}) exitWith { _result = ["", "STR_ALIVE_FOB_REFUSED_SPOT", []] };
        private _types = missionNamespace getVariable ["ALiVE_FOB_types", []];
        if (_types isEqualTo []) then { _type = "" };
        private _spec = [_logic, "typeSpec", [_type]] call ALiVE_fnc_FOB;
        if (_spec isEqualTo []) exitWith { _result = ["", "STR_ALIVE_FOB_REFUSED_TYPE", []] };
        _pos = [_pos param [0, 0], _pos param [1, 0], 0];
        if (surfaceIsWater _pos || {getTerrainHeightASL _pos < -0.5}) exitWith { _result = ["", "STR_ALIVE_FOB_REFUSED_WATER", []] };
        if (((surfaceNormal _pos) select 2) < 0.966) exitWith { _result = ["", "STR_ALIVE_FOB_REFUSED_SLOPE", []] };
        private _minDist = [_logic, "attribute", ["fob_min_distance"]] call ALiVE_fnc_FOB;
        private _near = (ALiVE_FOB_registry select 1) findIf {
            (([[ALiVE_FOB_registry, _x] call ALIVE_fnc_hashGet, "pos", [0,0,0]] call ALIVE_fnc_hashGet) distance2D _pos) < _minDist
        };
        if (_near > -1) exitWith { _result = ["", "STR_ALIVE_FOB_REFUSED_DISTANCE", [_minDist]] };
        // the faction, as a captured FOB gets one: the side's AI Commander's, else its men's nearest
        // the spot, else the side's base game faction. Supply, the garrison and the supply network need one.
        private _factions = [];
        { if (([_x, "side", ""] call ALiVE_fnc_hashGet) == _side) then { _factions append ([_x, "factions", []] call ALiVE_fnc_hashGet) } } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
        if (_factions isEqualTo []) then {
            private _sideObj = [_side] call ALIVE_fnc_sideTextToObject;
            private _men = (_pos nearEntities [["CAManBase"], 500]) select { alive _x && {side group _x == _sideObj} };
            _factions = [(_men apply { faction _x }) param [0, ["OPF_F", "BLU_F", "IND_F"] param [["EAST", "WEST", "GUER"] find _side, "BLU_F"]]];
        };
        private _id = [_logic, "nextID", [_side]] call ALiVE_fnc_FOB;
        private _entry = [_logic, "newEntry", [_id, _side, _factions param [0, ""], _pos, _dir, "", _type]] call ALiVE_fnc_FOB;
        [_entry, "deployedBy", ""] call ALIVE_fnc_hashSet;
        [_logic, "registrySet", [_id, _entry]] call ALiVE_fnc_FOB;
        private _hub = ["spawnHub", [_id]] call ALiVE_fnc_fobOps;
        if (isNull _hub) exitWith {
            [_logic, "registryRemove", [_id]] call ALiVE_fnc_FOB;
            _result = ["", "STR_ALIVE_FOB_REFUSED_SPOT", []];
        };
        ["register", [_id]] call ALiVE_fnc_fobObjectives;
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        ["ALiVE Player FOBs - a Zeus deployed %1 (%2) for %3 at %4", _id, [_entry, "name"] call ALIVE_fnc_hashGet, _side, _pos] call ALiVE_fnc_dump;
        _result = [_id];
    };

    case "dismantle": {
        _result = false;
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) == "damaged") exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED"] call _tell };
        if !([_entry] call _mayManage) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTALLOWED"] call _tell };

        // anyone in this FOB's arsenal pays first, while it still has its supply
        private _inArsenal = [];
        { if ((_y select 1) == _id) then { _inArsenal pushBack _x } } forEach (missionNamespace getVariable ["ALiVE_FOB_arsenalSessions", createHashMap]);
        { ["arsenalSettle", [_x, "fob"]] call ALiVE_fnc_fobOps } forEach _inArsenal;
        private _name = [_entry, "name", ""] call ALIVE_fnc_hashGet;
        // packed up, not lost: the kit comes back where the headquarters stood and, in FOB supply
        // mode, a crate with what was left in the FOB (in force pool mode the supply is the pool's)
        private _side = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        private _at = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        private _left = if (([_logic, "attribute", ["fob_supply_source"]] call ALiVE_fnc_FOB) == "FORCEPOOL") then { 0 } else { floor (["balance", [_id]] call ALiVE_fnc_fobSupply) };
        ["cleanup", [_id]] call ALiVE_fnc_fobOps;
        private _kitClass = [[_logic, "attribute", ["fob_kit_class"]] call ALiVE_fnc_FOB, _side, "ALiVE_FOB_Kit"] call _pickClass;
        private _kit = createVehicle [_kitClass, _at, [], 2, "NONE"];
        // one of the mission's own objects comes empty, as the ALiVE kit does
        if (_kitClass != "ALiVE_FOB_Kit") then { clearItemCargoGlobal _kit; clearWeaponCargoGlobal _kit; clearMagazineCargoGlobal _kit; clearBackpackCargoGlobal _kit };
        // saved with the FOBs (fnc_fobPersistence), so a restart doesn't lose the kit or the supply left in the crate
        _kit setVariable ["ALiVE_FOB_loose", true];
        ["tag", [_kit, "KIT", _side]] call ALiVE_fnc_fobOps;
        if (_left > 0) then {
            private _crateClass = [[_logic, "attribute", ["fob_crate_class"]] call ALiVE_fnc_FOB, _side, "ALiVE_FOB_SupplyCrate"] call _pickClass;
            private _crate = createVehicle [_crateClass, _at getPos [3, random 360], [], 2, "NONE"];
            if (_crateClass != "ALiVE_FOB_SupplyCrate") then { clearItemCargoGlobal _crate; clearWeaponCargoGlobal _crate; clearMagazineCargoGlobal _crate; clearBackpackCargoGlobal _crate };
            _crate setVariable ["ALiVE_FOB_loose", true];
            ["tag", [_crate, "CRATE", _left]] call ALiVE_fnc_fobOps;
        };
        if (_left > 0) then { ["STR_ALIVE_FOB_DISMANTLED_SUPPLY", [_name, _left]] call _tell } else { ["STR_ALIVE_FOB_DISMANTLED", [_name]] call _tell };
        ["ALiVE Player FOBs - %1 dismantled %2 (%3)", name _caller, _id, _name] call ALiVE_fnc_dump;
        _result = true;
    };

    case "cleanup": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = false };
        // anyone in this FOB's arsenal pays first, while it still has its supply
        private _inArsenal = [];
        { if ((_y select 1) == _id) then { _inArsenal pushBack _x } } forEach (missionNamespace getVariable ["ALiVE_FOB_arsenalSessions", createHashMap]);
        { ["arsenalSettle", [_x, "fob"]] call ALiVE_fnc_fobOps } forEach _inArsenal;
        ["unregister", [_id]] call ALiVE_fnc_fobObjectives;
        ["releaseGarrison", [_id]] call ALiVE_fnc_fobOps;
        ["removeTroops", [_id]] call ALiVE_fnc_fobOps;
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
            // a FOB of a type the mission no longer has (or saved before FOBs had types) is a plain FOB
            private _t = [_e, "type", ""] call ALIVE_fnc_hashGet;
            if !(_t isEqualType "") then { _t = "" };
            if (_t != "" && {([_logic, "typeSpec", [_t]] call ALiVE_fnc_FOB) isEqualTo []}) then {
                ["ALiVE Player FOBs - %1 (%2) was a %3, a type this mission doesn't have; it's a plain FOB now", _x, [_e, "name", ""] call ALIVE_fnc_hashGet, _t] call ALiVE_fnc_dump;
                _t = "";
                ALiVE_FOB_dirty = true;
            };
            [_e, "type", _t] call ALIVE_fnc_hashSet;
            // a damaged FOB comes back damaged, its headquarters still down
            private _hub = if (([_e, "status", ""] call ALIVE_fnc_hashGet) == "damaged") then { objNull } else { ["spawnHub", [_x]] call ALiVE_fnc_fobOps };
            ["reconcile", [_x]] call ALiVE_fnc_fobObjectives;
            ["restoreObjects", [_x]] call ALiVE_fnc_fobOps;
            ["restoreTroops", [_x]] call ALiVE_fnc_fobOps;
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
                    // an aircraft only where nothing stands now, aircraft already made again in this pass
                    // included: two built on one pad at different times would otherwise both come back on it
                    private _taken = false;
                    if (_class isKindOf "Air") then {
                        private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
                        private _r = ((_bb select 0) max (_bb select 1)) * 0.55;
                        _taken = ((nearestObjects [_pos, ["AllVehicles"], _r]) findIf { !(_x isKindOf "CAManBase") }) > -1
                            || {(_live findIf { (_x param [0, objNull]) isEqualTo "vehicle" && {(_x select 1) isKindOf "Air"} && {(_x select 3) != ""} && {((_x select 5) distance2D _pos) < _r} }) > -1};
                    };
                    private _nv = if (_taken) then { [] } else { ["spawnVehicle", [_class, _pos, _dir, toLower getText (configFile >> "CfgVehicles" >> _class >> "faction")]] call ALiVE_fnc_fobOps };
                    if (_nv isNotEqualTo []) then { _live pushBack (["vehicle", _class, _cost] + _nv + [_pos, _dir]); _result = _result + 1 } else {
                        // kept with no profile id, so the watchdog leaves it and the next start makes it
                        ["ALiVE Player FOBs - %1: couldn't make the %2 again now%3; kept for the next start", _id, _class, ["", " (something stands where it was)"] select _taken] call ALiVE_fnc_dumpR;
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
        // the height the player placed at (ASL), for a fortification or supply object on a roof
        private _fromASL = _pos param [2, -1e6];
        _pos = [_pos select 0, _pos select 1, 0];
        if ((_pos select 0) < 0 || {(_pos select 1) < 0} || {(_pos select 0) > worldSize} || {(_pos select 1) > worldSize}) exitWith {};
        if !(finite _dir) exitWith {};
        private _range = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        private _centre = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        // an aircraft's range and water are tested on its pad or taxiway spot further down, as the preview does
        private _isAir = _class isKindOf "Air";
        if ((!_isAir && {_pos distance2D _centre > _range}) || {_caller distance2D _centre > _range}) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _range]] call _tell };
        if (!_isAir && {surfaceIsWater _pos}) exitWith { ["STR_ALIVE_FOB_REFUSED_WATER"] call _tell };

        private _row = (missionNamespace getVariable ["ALiVE_FOB_catalog", []]) select { (_x select 0) == _class };
        if (_row isEqualTo []) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILDABLE"] call _tell };
        // a FOB type's build list: its removals never, another type's extras only there
        if !([_logic, "typeAllows", [[_entry, "type", ""] call ALIVE_fnc_hashGet, _class]] call ALiVE_fnc_FOB) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE_ITEM", [[_entry, "name", ""] call ALIVE_fnc_hashGet]] call _tell;
        };
        (_row select 0) params ["", "_name", "_kind", "_cost", "", ["_tierMin", 1]];
        // soldiers and groups are raised, never placed as objects
        if (_kind in ["SOLDIER", "GROUP"]) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILDABLE"] call _tell };
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
        // An aircraft (Jman, 26 Oct): a helicopter onto the helipad nearest the spot, a plane onto airfield
        // taxiway or parking, the spot worked out here again whatever the preview showed
        private _airRefused = "";
        if (_isVehicle && {_isAir}) then {
            private _bb = [_class] call ALiVE_fnc_getVehicleBoundingBox;
            (["airSpot", [_class, _pos, ((_bb select 0) max (_bb select 1)) * 0.55]] call ALiVE_fnc_fobPlacement) params ["_airPos", "_w"];
            if (_w != "") exitWith { _airRefused = _w };
            if (_airPos distance2D _centre > _range) exitWith { _airRefused = "RANGE" };
            if (surfaceIsWater _airPos) exitWith { _airRefused = "WATER" };
            _pos = _airPos;
        };
        if (_airRefused == "RANGE") exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _range]] call _tell };
        if (_airRefused != "") exitWith { ["STR_ALIVE_FOB_REFUSED_" + _airRefused] call _tell };

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
        // on the first surface at or below the height the player placed at: a roof, a floor or the
        // ground, found here, never taken from the player. No higher than the player's head.
        private _up = surfaceNormal _pos;
        if (_fromASL > -1e5) then {
            (["surface", [_pos, (_fromASL + 0.25) min (((eyePos _caller) select 2) + 1.5)]] call ALiVE_fnc_fobPlacement) params ["_atl", "_n"];
            _pos = _atl; _up = _n;
        };
        private _o = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
        if (isNull _o) exitWith {
            ["credit", [_id, _cost, "refund " + _class]] call ALiVE_fnc_fobSupply;
            ["STR_ALIVE_FOB_REFUSED_SPOT"] call _tell;
        };
        // on the slope or surface, keeping the heading the player chose; turned first, then placed
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
        // made at a Logistics Hub: recycled at one of the side's hubs, its cost back to the force pool it came from
        private _hubMade = _o getVariable "ALiVE_hub_made";
        if (!isNil "_hubMade") exitWith {
            _hubMade params [["_regId", ""], ["_faction", ""], ["_cost", 0]];
            private _side = ["unitSide", [_caller]] call ALIVE_fnc_hub;
            private _atHub = (missionNamespace getVariable ["ALiVE_hub_list", []]) findIf {
                !isNull _x && {((_x getVariable ["ALiVE_hub", []]) param [0, ""]) == _side} && {_o distance2D _x < 100}
            } > -1;
            if (!_atHub) exitWith { ["STR_ALIVE_FOB_REFUSED_HUBFAR", [100]] call _tell };
            private _near = if (_o isKindOf "Air") then { 8 max ((sizeOf typeOf _o) / 2) } else { 8 };
            if (_caller distance _o > _near) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _near]] call _tell };
            if ((crew _o) findIf { alive _x } > -1) exitWith { ["STR_ALIVE_FOB_REFUSED_CREWED"] call _tell };
            private _class = typeOf _o;
            deleteVehicle _o;
            if (_cost > 0 && {!isNil "ALIVE_globalForcePool"} && {!isNil "ALIVE_MLGlobalRegistry"}) then {
                private _pool = [ALIVE_globalForcePool, _faction, 0] call ALIVE_fnc_hashGet;
                if (_pool isEqualType "") then { _pool = parseNumber _pool };
                [ALIVE_MLGlobalRegistry, "updateGlobalForcePool", [_regId, _pool + _cost]] call ALIVE_fnc_MLGlobalRegistry;
            };
            ["STR_ALIVE_FOB_RECYCLED_HUB", [getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _cost]] call _tell;
            _result = true;
        };
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
            // an aircraft from anywhere alongside it: a Huron or Blackfish is out of reach of its middle
            private _near = if (_o isKindOf "Air") then { 8 max ((sizeOf typeOf _o) / 2) } else { 8 };
            if (_caller distance _o > _near) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _near]] call _tell };
            if !([_entry] call _mayManage) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTALLOWED"] call _tell };
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
        if !([_entry] call _mayManage) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTALLOWED"] call _tell };
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

    // The FOB Arsenal (Jman, 25 Oct): a player opens an arsenal built at their FOB, takes what
    // they want, and the FOB's supply pays for it when they close it. The server keeps what they
    // had on opening and charges only what they have more of; gear handed back earns nothing.
    case "arsenalOpen": {
        _result = false;
        _args params [["_box", objNull, [objNull]], ["_haveList", false, [false]], ["_hqId", "", [""]]];
        if (isNull _caller || {!alive _caller} || {isNull _box && {_hqId == ""}}) exitWith {};
        // an arsenal saved with the setting on and loaded with it off is a plain crate
        if !([_logic, "attribute", ["fob_arsenal"]] call ALiVE_fnc_FOB) exitWith { ["STR_ALIVE_FOB_ARSENAL_OFF"] call _tell };
        // the gear list is worked out after start-up
        if (isNil "ALiVE_FOB_gearPrice") exitWith { ["STR_ALIVE_FOB_ARSENAL_LOADING"] call _tell };
        if (isNil "ALiVE_FOB_arsenalSessions") then { ALiVE_FOB_arsenalSessions = createHashMap };
        private _uid = getPlayerUID _caller;
        // a visit still open from before (its close never arrived) is settled first
        if (_uid in ALiVE_FOB_arsenalSessions) then { ["arsenalSettle", [_uid, "reopen"]] call ALiVE_fnc_fobOps };
        private _atHQ = isNull _box;
        // the box's FOB, found as recycle finds it; or the FOB whose headquarters it is opened at
        private _id = if (_atHQ) then { _hqId } else { _box getVariable ["ALiVE_FOB_object", ""] };
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILT"] call _tell };
        if (_atHQ) then { _box = [_entry, "hub", objNull] call ALIVE_fnc_hashGet };
        if (!_atHQ && {!(_box isKindOf "ALiVE_FOB_Arsenal") || {(([_entry, "objects", []] call ALIVE_fnc_hashGet) findIf { (_x param [0, objNull]) isEqualTo _box }) < 0}}) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILT"] call _tell };
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "active" || {isNull _box}) exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED"] call _tell };
        private _why = [];
        if (_atHQ) then {
            // at the headquarters: the FOB has reached the tier the build list's FOB Arsenal crate needs,
            // and its type may build one
            private _cat = uiNamespace getVariable ["ALiVE_FOB_catalogServer", []];
            private _ai = _cat findIf { (_x select 0) == "ALiVE_FOB_Arsenal" };
            private _need = if (_ai < 0) then { -1 } else { (_cat select _ai) select 5 };
            _why = call {
                if (_need < 0 || {!([_logic, "typeAllows", [[_entry, "type", ""] call ALIVE_fnc_hashGet, "ALiVE_FOB_Arsenal"]] call ALiVE_fnc_FOB)}) exitWith { ["STR_ALIVE_FOB_ARSENAL_HQ_NONE"] };
                if (([_entry, "tier", 1] call ALIVE_fnc_hashGet) < _need) exitWith { ["STR_ALIVE_FOB_ARSENAL_HQ_TIER", [_need]] };
                if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25 || {vehicle _caller != _caller}) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] };
                []
            };
        } else {
            _why = [[], ["STR_ALIVE_FOB_REFUSED_RANGE", [8]]] select (_caller distance _box > 8 || {vehicle _caller != _caller});
        };
        if (_why isNotEqualTo []) exitWith { _why call _tell };
        private _loadout = getUnitLoadout _caller;
        private _balance = floor (["balance", [_id]] call ALiVE_fnc_fobSupply);
        // the game's own arsenal fills every part-used magazine as it opens (ACE's doesn't), and
        // that is charged with the rest: say what it costs, and don't open if the FOB can't pay it
        private _topUp = 0;
        if !(isClass (configFile >> "CfgPatches" >> "ace_arsenal")) then {
            private _part = 0;
            {
                {
                    if (_x isEqualType [] && {count _x >= 2} && {(_x select 0) isEqualType ""} && {(_x select 1) isEqualType 0}) then {
                        private _p = ALiVE_FOB_gearPrice getOrDefault [toLower (_x select 0), []];
                        if (_p isNotEqualTo [] && {(_p select 2) > 0}) then {
                            private _n = _x param [2, 1];
                            private _per = _p select 2;
                            // [mag, rounds] in a weapon, [mag, count, rounds] in a container
                            private _short = if (count _x >= 3 && {(_x select 2) isEqualType 0}) then { ((_per - (_x select 2)) max 0) * (_x select 1) } else { (_per - (_x select 1)) max 0 };
                            _part = _part + (_p select 0) * _short / _per;
                        };
                    };
                } forEach _x;
            } forEach ([(_loadout param [0, []]), (_loadout param [1, []]), (_loadout param [2, []])] + (((_loadout select [3, 3]) select { _x isEqualType [] && {count _x >= 2} }) apply { _x select 1 }));
            _topUp = ceil ((round (_part * 1000)) / 1000);
        };
        if (_topUp > _balance) exitWith { ["STR_ALIVE_FOB_ARSENAL_REFUSED_TOPUP", [_topUp, _balance]] call _tell };
        ALiVE_FOB_arsenalSessions set [_uid, [_caller, _id, _box, _loadout, getPosASL _caller, time]];
        // one loop for every open arsenal: both arsenal screens hold the player still, so one who
        // has moved, got in a vehicle or died has closed it, whatever their machine said
        if (isNil "ALiVE_FOB_arsenalLoop" || {scriptDone ALiVE_FOB_arsenalLoop}) then {
            ALiVE_FOB_arsenalLoop = [] spawn {
                while { count ALiVE_FOB_arsenalSessions > 0 } do {
                    sleep 1;
                    private _done = [];
                    {
                        _y params ["_u", "", "", "", "_at", "_t"];
                        if (isNull _u || {!alive _u} || {vehicle _u != _u} || {((getPosASL _u) distance _at) > 5}) then { _done pushBack [_x, "moved"] };
                        if (time - _t > 1800) then { _done pushBack [_x, "timeout"] };
                    } forEach ALiVE_FOB_arsenalSessions;
                    { ["arsenalSettle", _x] call ALiVE_fnc_fobOps } forEach _done;
                };
            };
        };
        // the class list goes once to each machine, with its first open
        if (isNil "ALiVE_FOB_arsenalListSent") then { ALiVE_FOB_arsenalListSent = createHashMap };
        private _sent = _haveList && {ALiVE_FOB_arsenalListSent getOrDefault [_uid, -1] == owner _caller};
        ALiVE_FOB_arsenalListSent set [_uid, owner _caller];
        ["arsenalOpen", [_box, [ALiVE_FOB_gearClasses, []] select _sent]] remoteExecCall ["ALiVE_fnc_fobClient", _caller];
        if (_topUp > 0) then {
            ["STR_ALIVE_FOB_ARSENAL_OPEN_TOPUP", [[_entry, "name", ""] call ALIVE_fnc_hashGet, _balance, _topUp]] call _tell;
        } else {
            ["STR_ALIVE_FOB_ARSENAL_OPEN", [[_entry, "name", ""] call ALIVE_fnc_hashGet, _balance]] call _tell;
        };
        _result = true;
    };

    // The player closed the arsenal; their loadout as their machine saw it says when the
    // server's own copy has caught up
    case "arsenalClose": {
        _args params [["_hint", [], [[]]]];
        _result = false;
        if (isNull _caller) exitWith {};
        private _uid = getPlayerUID _caller;
        private _s = (missionNamespace getVariable ["ALiVE_FOB_arsenalSessions", createHashMap]) getOrDefault [_uid, []];
        if (_s isEqualTo []) exitWith {
            ["ALiVE Player FOBs - FOB Arsenal: %1 closed an arsenal they hadn't opened", name _caller] call ALiVE_fnc_dump;
        };
        // a close from away from the box is no close: the loop settles them as moved
        // (a headquarters is a building: its centre can be further off)
        if (!isNull (_s select 2) && {_caller distance (_s select 2) > ([30, 10] select ((_s select 2) isKindOf "ALiVE_FOB_Arsenal"))}) exitWith {};
        _result = ["arsenalSettle", [_uid, "close", _hint]] call ALiVE_fnc_fobOps;
    };

    // Pay for an arsenal visit, or put the kit back: the server's own. "close" waits up to 3 s
    // for the player's loadout to reach the server; the others (moved, died, left, FOB gone)
    // settle at once.
    case "arsenalSettle": {
        _args params [["_uid", "", [""]], ["_why", "", [""]], ["_hint", [], [[]]]];
        _result = false;
        // taken and removed in one step, so a settle already under way can't be run twice
        private _s = (missionNamespace getVariable ["ALiVE_FOB_arsenalSessions", createHashMap]) deleteAt _uid;
        if (isNil "_s") exitWith {};
        _s params ["_unit", "_id", "_box", "_before"];
        // the arsenal shuts on the player's machine whenever the server settles first
        if (_why != "close" && {!isNull _unit}) then { ["arsenalShut", []] remoteExecCall ["ALiVE_fnc_fobClient", _unit] };

        // a loadout as [counts, rounds] by gear-list class: weapons by their base class, a TFAR
        // radio by its parent, an ACRE radio without its _ID_n
        private _flatten = {
            params ["_lo"];
            private _n = createHashMap; private _r = createHashMap;
            private _key = {
                params ["_c"];
                private _lc = toLower _c;
                private _cfg = configFile >> "CfgWeapons" >> _c;
                if (_lc in ALiVE_FOB_gearPrice || {!isClass _cfg}) exitWith { _lc };
                private _p = getText (_cfg >> "tf_parent");
                if (_p != "") exitWith { toLower _p };
                private _i = _lc find "_id_";
                if (_i > 0) exitWith { _lc select [0, _i] };
                toLower ([_c] call BIS_fnc_baseWeapon)
            };
            private _add = {
                params ["_c", ["_k", 1], ["_rounds", -1]];
                if !(_c isEqualType "" && {_c != ""}) exitWith {};
                private _kc = [_c] call _key;
                _n set [_kc, (_n getOrDefault [_kc, 0]) + _k];
                if (_rounds >= 0) then { _r set [_kc, (_r getOrDefault [_kc, 0]) + _rounds] };
            };
            private _weapon = {
                params ["_w", ["_k", 1]];
                if !(_w isEqualType [] && {count _w > 0}) exitWith {};
                [_w select 0, _k] call _add;
                { if (_x isEqualType "") then { [_x, _k] call _add } } forEach [_w param [1, ""], _w param [2, ""], _w param [3, ""], _w param [6, ""]];
                { if (_x isEqualType [] && {count _x >= 2}) then { [_x select 0, _k, (_x select 1) * _k] call _add } } forEach [_w param [4, []], _w param [5, []]];
            };
            { [_x] call _weapon } forEach [_lo param [0, []], _lo param [1, []], _lo param [2, []], _lo param [8, []]];
            {
                if (_x isEqualType [] && {count _x >= 2}) then {
                    [_x select 0] call _add;
                    {
                        switch (true) do {
                            case ((_x select 0) isEqualType []): { [_x select 0, _x param [1, 1]] call _weapon };
                            case (count _x >= 3 && {(_x select 2) isEqualType 0}): { [_x select 0, _x select 1, (_x select 1) * (_x select 2)] call _add };
                            case ((_x param [1, 1]) isEqualType 0): { [_x select 0, _x param [1, 1]] call _add };
                            default { [_x select 0] call _add };
                        };
                    } forEach (_x select 1);
                };
            } forEach [_lo param [3, []], _lo param [4, []], _lo param [5, []]];
            { [_x] call _add } forEach ([_lo param [6, ""], _lo param [7, ""]] + (_lo param [9, []]));
            [_n, _r]
        };

        // what the visit costs: [supply, classes not on the gear list that the player has more of]
        private _bill = {
            params ["_b", "_a"];
            _b params ["_nb", "_rb"];
            _a params ["_na", "_ra"];
            private _cost = 0; private _mags = 0; private _bad = [];
            {
                private _rose = _y - (_nb getOrDefault [_x, 0]);
                private _p = ALiVE_FOB_gearPrice getOrDefault [_x, []];
                // more of the player's own kit the gear list leaves out (the arsenal offers what they
                // walked in with): a magazine 1 a full one, anything else by its mass
                if (_p isEqualTo [] && {_rose > 0} && {(_nb getOrDefault [_x, 0]) > 0}) then {
                    private _m = configFile >> "CfgMagazines" >> _x;
                    _p = if (isClass _m) then { [1, "OWN", (getNumber (_m >> "count")) max 1] } else {
                        private _c = configFile >> "CfgWeapons" >> _x;
                        if !(isClass _c) then { _c = configFile >> "CfgVehicles" >> _x };
                        if !(isClass _c) then { _c = configFile >> "CfgGlasses" >> _x };
                        [((ceil (((getNumber (_c >> "ItemInfo" >> "mass")) max (getNumber (_c >> "WeaponSlotsInfo" >> "mass")) max (getNumber (_c >> "mass"))) / 10)) max 1) min 25, "OWN", 0]
                    };
                };
                if (_p isEqualTo []) then { if (_rose > 0) then { _bad pushBack _x } } else {
                    _p params ["_price", "", "_per"];
                    // a magazine by the rounds taken, so topping one up costs only what went in
                    if (_per > 0) then {
                        _mags = _mags + _price * (((_ra getOrDefault [_x, 0]) - (_rb getOrDefault [_x, 0])) max 0) / _per;
                    } else {
                        _cost = _cost + _price * (_rose max 0);
                    };
                };
            } forEach _na;
            [_cost + ceil ((round (_mags * 1000)) / 1000), _bad]
        };

        private _settle = {
            params ["_uid", "_why", "_unit", "_id", "_before", "_after"];
            ([[_before] call _flatten, [_after] call _flatten] call _bill) params ["_cost", "_bad"];
            private _who = if (isNull _unit) then { _uid } else { name _unit };
            private _say = { params ["_k", ["_f", []]]; if (!isNull _unit && {isPlayer _unit}) then { ["notify", [_k, _f]] remoteExecCall ["ALiVE_fnc_fobClient", _unit] } };
            private _back = {
                if (!isNull _unit) then { ["arsenalRevert", [_unit, _before]] remoteExecCall ["ALiVE_fnc_fobClient", _unit] };
            };
            isNil {
                switch (true) do {
                    // gear the arsenal never offered can only have been put on by a script: the kit
                    // the player opened with, unless they are gone already
                    case (_bad isNotEqualTo []): {
                        if (_why == "disconnect") then {
                            // gone, so nothing to put back: the FOB pays for what was on the list
                            private _pay = _cost min (floor (["balance", [_id]] call ALiVE_fnc_fobSupply));
                            if (_pay > 0) then { ["debit", [_id, _pay, "arsenal " + _who]] call ALiVE_fnc_fobSupply };
                        } else { call _back; ["STR_ALIVE_FOB_ARSENAL_REVERTED_LIST"] call _say };
                        ["ALiVE Player FOBs - FOB Arsenal: %1 came away with gear the arsenal doesn't offer (%2) (%3)", _who, _bad select [0, 5], _why] call ALiVE_fnc_dumpR;
                    };
                    case (_cost <= 0): {
                        if (_why == "close") then { ["STR_ALIVE_FOB_ARSENAL_FREE"] call _say };
                    };
                    case (["debit", [_id, _cost, "arsenal " + _who]] call ALiVE_fnc_fobSupply): {
                        ["STR_ALIVE_FOB_ARSENAL_CHARGED", [_cost, floor (["balance", [_id]] call ALiVE_fnc_fobSupply)]] call _say;
                        ["ALiVE Player FOBs - FOB Arsenal: %1 took %2 supply of gear at %3 (%4)", _who, _cost, _id, _why] call ALiVE_fnc_dump;
                    };
                    // more than the FOB has: it pays what it has. Putting the kit back instead would
                    // let a player drop what they took before the put-back and keep both
                    default {
                        private _have = floor (["balance", [_id]] call ALiVE_fnc_fobSupply);
                        if (_have > 0) then { ["debit", [_id, _have, "arsenal " + _who]] call ALiVE_fnc_fobSupply };
                        ["STR_ALIVE_FOB_ARSENAL_SHORT", [_cost, _have]] call _say;
                        ["ALiVE Player FOBs - FOB Arsenal: %1 took %2 supply of gear at %3 (%4), which had %5", _who, _cost, _id, _why, _have] call ALiVE_fnc_dump;
                    };
                };
            };
        };

        if (isNull _unit) exitWith {
            ["ALiVE Player FOBs - FOB Arsenal: %1's unit was gone before their visit could be settled", _uid] call ALiVE_fnc_dump;
        };
        if (_why != "close") exitWith {
            [_uid, _why, _unit, _id, _before, getUnitLoadout _unit] call _settle;
            _result = true;
        };
        // the loadout this machine has for a player catches up a moment after theirs: read it until
        // it matches what they sent, three times at most, and settle on the dearest
        [_uid, _unit, _id, _before, _hint, _settle, _flatten, _bill] spawn {
            params ["_uid", "_unit", "_id", "_before", "_hint", "_settle", "_flatten", "_bill"];
            private _fb = [_before] call _flatten;
            private _best = getUnitLoadout _unit;
            private _bestBill = [_fb, [_best] call _flatten] call _bill;
            for "_i" from 1 to 3 do {
                // the player's own copy ends the wait only once the server's has moved off the opening
                // kit, so a close sent straight after opening can't settle on a stale read
                if (isNull _unit || {_best isEqualTo _hint && {_best isNotEqualTo _before}}) exitWith {};
                sleep 1;
                if (isNull _unit) exitWith {};
                private _now = getUnitLoadout _unit;
                private _b = [_fb, [_now] call _flatten] call _bill;
                if (count (_b select 1) > count (_bestBill select 1) || {(_b select 0) > (_bestBill select 0)}) then { _best = _now; _bestBill = _b };
                if (_now isEqualTo _hint && {_now isNotEqualTo _before}) exitWith { _best = _now };
            };
            [_uid, "close", _unit, _id, _before, _best] call _settle;
        };
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
        // anyone in this FOB's arsenal pays first, while it still has its supply
        private _inArsenal = [];
        { if ((_y select 1) == _id) then { _inArsenal pushBack _x } } forEach (missionNamespace getVariable ["ALiVE_FOB_arsenalSessions", createHashMap]);
        { ["arsenalSettle", [_x, "fob"]] call ALiVE_fnc_fobOps } forEach _inArsenal;
        private _name = [_entry, "name", _id] call ALIVE_fnc_hashGet;
        isNil {
            ["unregister", [_id]] call ALiVE_fnc_fobObjectives;
            ["releaseGarrison", [_id]] call ALiVE_fnc_fobOps;
            ["removeTroops", [_id]] call ALiVE_fnc_fobOps;
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
            // taken, so its deployer is on the other side now: Who Can Dismantle's The Player Who
            // Deployed It falls back to group leaders for it
            [_entry, "deployedBy", ""] call ALIVE_fnc_hashSet;
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

    // The respawn point a FOB should have: one at an active FOB at or above the module's Respawn Point tier
    // it, none otherwise. Safe to run any number of times.
    case "respawn": {
        _args params [["_id", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { _result = false };
        // a respawn point from the tier the Respawn Point setting gives (the FOB type's own, else the module's); 0 is never
        private _from = [_logic, "typeAttribute", [[_entry, "type", ""] call ALIVE_fnc_hashGet, "fob_respawn"]] call ALiVE_fnc_FOB;
        private _want = _from > 0 && {([_entry, "tier", 1] call ALIVE_fnc_hashGet) >= _from} && {([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active"};
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

    // A new name for a FOB, from a player of its side standing at it. The map marker and the rally
    // point read the name from the FOB list, so they follow it; the respawn point keeps the name it
    // was made with, so it is made again. The name is cleaned here, never trusted from the request:
    // no control characters, no < > & (the name is shown as structured text), at most 32 characters.
    case "rename": {
        _result = false;
        _args params [["_id", "", [""]], ["_new", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        if (([_entry, "side", ""] call ALIVE_fnc_hashGet) != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        if !([_entry] call _mayManage) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTALLOWED"] call _tell };
        _new = trim toString ((toArray _new) select { _x >= 32 && {!(_x in [38, 60, 62])} });
        _new = trim toString ((toArray _new) select [0, 32]);
        if (_new == "") exitWith { ["STR_ALIVE_FOB_REFUSED_NAME", [32]] call _tell };
        private _old = [_entry, "name", ""] call ALIVE_fnc_hashGet;
        if (_new isEqualTo _old) exitWith {};
        [_entry, "name", _new] call ALIVE_fnc_hashSet;
        private _have = [_entry, "respawn", []] call ALIVE_fnc_hashGet;
        if (_have isEqualType [] && {_have isNotEqualTo []}) then {
            _have call BIS_fnc_removeRespawnPosition;
            [_entry, "respawn", []] call ALIVE_fnc_hashSet;
            ["respawn", [_id]] call ALiVE_fnc_fobOps;
        };
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        ["STR_ALIVE_FOB_RENAMED", [_old, _new]] call _tell;
        ["ALiVE Player FOBs - %1 renamed %2 from %3 to %4", name _caller, _id, _old, _new] call ALiVE_fnc_dump;
        _result = true;
    };

    // A FOB changed to another FOB type (Jman, 29 Oct), from the FOB window, by a player of its side
    // standing at it whom Who Can Dismantle lets in and who may deploy the new type. The type's cap and
    // cost hold as they do at deploy, the cost out of the FOB's supply (or the force pool). What it has
    // built stays; its build menu, map marker, respawn point and supply per minute follow the new type.
    // The headquarters building stays the one it has.
    case "retype": {
        _result = false;
        _args params [["_id", "", [""]], ["_type", "", [""]]];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNull _caller}) exitWith {};
        private _side = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        if (_side != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > 25) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [25]] call _tell };
        if !([_entry] call _mayManage) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTALLOWED"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "active") exitWith { ["STR_ALIVE_FOB_REFUSED_RETYPE_ACTIVE"] call _tell };
        private _old = [_entry, "type", ""] call ALIVE_fnc_hashGet;
        if (_type == _old) exitWith {};
        private _spec = [_logic, "typeSpec", [_type]] call ALiVE_fnc_FOB;
        if (_spec isEqualTo []) exitWith { ["STR_ALIVE_FOB_REFUSED_TYPE"] call _tell };
        if (_type == "" && {!(missionNamespace getVariable ["ALiVE_FOB_typesGeneral", true])}) exitWith { ["STR_ALIVE_FOB_REFUSED_RETYPE_PLAIN"] call _tell };
        if !([_logic, "mayDeployType", [_caller, _type]] call ALiVE_fnc_FOB) exitWith { ["STR_ALIVE_FOB_REFUSED_TYPE_WHO", [_spec select 1]] call _tell };
        if !(["canDeployType", [_side, _type]] call ALiVE_fnc_fobCap) exitWith { ["STR_ALIVE_FOB_REFUSED_TYPE_CAP", [_spec select 1, _spec select 11]] call _tell };
        private _typeCost = _spec select 10;
        if (_typeCost > 0 && {!(["debit", [_id, _typeCost, "FOB type " + _type]] call ALiVE_fnc_fobSupply)}) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE_COST", [_spec select 1, _typeCost]] call _tell;
        };
        [_entry, "type", _type] call ALIVE_fnc_hashSet;
        // a name that still carries the old type's word ("Outpost Bravo") takes the new one's; a name a
        // player gave it stays. Its respawn point is made again under the new name just below.
        private _oldWord = ([_logic, "typeSpec", [_old]] call ALiVE_fnc_FOB) param [2, ""];
        private _name = [_entry, "name", ""] call ALIVE_fnc_hashGet;
        private _phonetic = ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike",
            "November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu"];
        if (_oldWord != "" && {(_spec select 2) != _oldWord} && {(_name select [0, count _oldWord + 1]) == _oldWord + " "} && {(_name select [count _oldWord + 1]) in _phonetic}) then {
            [_entry, "name", (_spec select 2) + (_name select [count _oldWord])] call ALIVE_fnc_hashSet;
            private _have = [_entry, "respawn", []] call ALIVE_fnc_hashGet;
            if (_have isEqualType [] && {_have isNotEqualTo []}) then {
                _have call BIS_fnc_removeRespawnPosition;
                [_entry, "respawn", []] call ALIVE_fnc_hashSet;
            };
        };
        // the new type's respawn tier: the point goes, or comes, as it now should
        ["respawn", [_id]] call ALiVE_fnc_fobOps;
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["save", [true]] call ALiVE_fnc_fobPersistence;
        ["STR_ALIVE_FOB_RETYPED", [[_entry, "name", ""] call ALIVE_fnc_hashGet, _spec select 1]] call _tell;
        ["ALiVE Player FOBs - %1 changed %2 from type '%3' to '%4'", name _caller, _id, _old, _type] call ALiVE_fnc_dump;
        _result = true;
    };

    // An admin changes Who Can Dismantle and its list in game, from the Permissions window. It
    // holds for every FOB until the mission restarts, when the module's settings apply again.
    case "permissions": {
        _result = false;
        _args params [["_rules", "", [""]], ["_names", "", [""]]];
        if (isNull _caller || {!([_logic, "isAdmin", [_caller]] call ALiVE_fnc_FOB)}) exitWith { ["STR_ALIVE_FOB_REFUSED_ADMIN"] call _tell };
        _rules = (((toUpper _rules) splitString "[]""', ") select { _x in ["SIDE", "LEADER", "DEPLOYER", "LIST"] }) joinString ",";
        _names = toString (((toArray _names) select { _x >= 32 && {!(_x in [34, 38, 39, 60, 62])} }) select [0, 2000]);
        _logic setVariable ["ALiVE_FOB_perm", [_rules, _names], true];
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["STR_ALIVE_FOB_PERMISSIONS_SET"] call _tell;
        ["ALiVE Player FOBs - %1 set who can dismantle FOBs to [%2], list [%3]", name _caller, _rules, _names] call ALiVE_fnc_dump;
        _result = true;
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
        private _o = createVehicle [[[_logic, "attribute", [["fob_crate_class", "fob_kit_class"] select (_what == "KIT")]] call ALiVE_fnc_FOB, _side,
            ["B_supplyCrate_F", "Box_NATO_Support_F"] select (_what == "KIT")] call _pickClass, _spot, [], 3, "NONE"];
        clearItemCargoGlobal _o; clearWeaponCargoGlobal _o; clearMagazineCargoGlobal _o; clearBackpackCargoGlobal _o;
        _o setVariable ["ALiVE_FOB_loose", true];
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

    // A tier 2 or 3 FOB's garrison: one infantry group of the FOB's faction (or the side's pick
    // in the module's Garrison Groups), holding the FOB the way a roadblock's guards hold a checkpoint: garrisoned
    // within 30 m, kept busy and stationary so no commander takes it elsewhere. Paid from the
    // FOB's supply unless free (a reload making good a garrison the save didn't keep).
    case "garrison": {
        _args params [["_id", "", [""]], ["_free", false, [false]]];
        _result = false;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNil "ALiVE_ProfileHandler"}) exitWith {};
        private _faction = [_entry, "faction", ""] call ALIVE_fnc_hashGet;
        // the side's Garrison Group ("faction/group"), else a random infantry group of the FOB's faction
        private _pick = ([_logic, "perSide", ["fob_garrison_groups", [_entry, "side", "WEST"] call ALIVE_fnc_hashGet]] call ALiVE_fnc_FOB) splitString "/";
        private _class = "";
        if (count _pick == 2) then { _faction = _pick select 0; _class = _pick select 1 };
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
        // told to the side when it cost something (a faction with no force pool pays nothing)
        private _left = ["balance", [_id]] call ALiVE_fnc_fobSupply;
        if (!_free && {_cost > 0} && {_left >= 0}) then {
            [_logic, "radio", [[_entry, "side", "WEST"] call ALIVE_fnc_hashGet, "STR_ALIVE_FOB_RADIO_GARRISON",
                [[_entry, "name", _id] call ALIVE_fnc_hashGet, round _cost, round _left]]] call ALiVE_fnc_FOB;
        };
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


    // Troops raised from the Build Menu (Jman, 27 Oct): a soldier or a group, made as profiles that
    // hold the FOB as its garrison does (garrisoned within 30 m, busy and pinned, never sent
    // elsewhere), each man tagged ALiVE_FOB_raised so Group Manager can't take him. They are lost
    // with the FOB. Paid from the FOB's supply, or 1 from the group's own faction's force pool in
    // Force pool mode. Priced from the server's own copy of the catalogue.
    case "raise": {
        _result = false;
        _args params [["_key", "", [""]], ["_id", "", [""]]];
        if (isNull _caller || {!alive _caller}) exitWith {};
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith { ["STR_ALIVE_FOB_REFUSED_NOFOB"] call _tell };
        private _fobSide = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        if (_fobSide != str (side group _caller)) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTOURS"] call _tell };
        if (([_entry, "status", ""] call ALIVE_fnc_hashGet) != "active") exitWith { ["STR_ALIVE_FOB_REFUSED_DAMAGED_BUILD"] call _tell };
        private _range = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        if (_caller distance2D ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) > _range) exitWith { ["STR_ALIVE_FOB_REFUSED_RANGE", [round _range]] call _tell };
        private _row = (uiNamespace getVariable ["ALiVE_FOB_catalogServer", []]) select { (_x select 0) == _key && {(_x select 2) in ["SOLDIER", "GROUP"]} };
        if (_row isEqualTo []) exitWith { ["STR_ALIVE_FOB_REFUSED_NOTBUILDABLE"] call _tell };
        if !([_logic, "typeAllows", [[_entry, "type", ""] call ALIVE_fnc_hashGet, _key]] call ALiVE_fnc_FOB) exitWith {
            ["STR_ALIVE_FOB_REFUSED_TYPE_ITEM", [[_entry, "name", ""] call ALIVE_fnc_hashGet]] call _tell;
        };
        (_row select 0) params ["", "_name", "_kind", "_cost", "", ["_tierMin", 1], ["_rowSide", ""], ["_rowFaction", ""], ["_men", 1], "", ["_spawn", ["", ""]]];
        private _tier = [_entry, "tier", 1] call ALIVE_fnc_hashGet;
        if (_tier < _tierMin) exitWith { ["STR_ALIVE_FOB_REFUSED_TIER", [_tierMin]] call _tell };
        // the factions the side's commanders field, or its own side's when it has none, as for static weapons
        private _allowed = ((["factions"] call ALiVE_fnc_fobBuildScan) select { (_x select 0) == _fobSide }) param [0, ["", []]] select 1;
        if ((_allowed isEqualTo [] && {_rowSide != _fobSide}) || {_allowed isNotEqualTo [] && {!(_rowFaction in _allowed)}}) exitWith { ["STR_ALIVE_FOB_REFUSED_TROOP_SIDE"] call _tell };
        if (isNil "ALiVE_ProfileHandler") exitWith { ["STR_ALIVE_FOB_REFUSED_TROOP_PROFILES"] call _tell };
        private _cap = ([_logic, "attribute", ["fob_troop_cap"]] call ALiVE_fnc_FOB) * _tier;
        private _held = ["troopsHeld", [_id]] call ALiVE_fnc_fobOps;
        if (_cap <= 0 || {_held + _men > _cap}) exitWith { ["STR_ALIVE_FOB_REFUSED_TROOP_CAP", [_cap, _held]] call _tell };
        // what it costs is checked first and taken once the troops exist, so a spawn that fails costs nothing
        private _pool = ([_logic, "attribute", ["fob_supply_source"]] call ALiVE_fnc_FOB) == "FORCEPOOL";
        private _poolFaction = _spawn select 0;
        if (_pool) then {
            private _left = if (isNil "ALIVE_globalForcePool" || {!(_poolFaction in (ALIVE_globalForcePool select 1))}) then { -1 } else { [ALIVE_globalForcePool, _poolFaction, 0] call ALIVE_fnc_hashGet };
            if (_left isEqualType "") then { _left = parseNumber _left };
            if (_left >= 0 && {_cost > _left}) then { _pool = "refused" };
        } else {
            if !(["canAfford", [_id, _cost]] call ALiVE_fnc_fobSupply) then { _pool = "short" };
        };
        if (_pool isEqualTo "refused") exitWith { ["STR_ALIVE_FOB_REFUSED_POOL", [_cost]] call _tell };
        if (_pool isEqualTo "short") exitWith { ["STR_ALIVE_FOB_REFUSED_SUPPLY", [_cost, ["balance", [_id]] call ALiVE_fnc_fobSupply]] call _tell };
        (["spawnTroops", [_id, _kind, _spawn select 1, _spawn select 0, _rowSide]] call ALiVE_fnc_fobOps) params ["_ids", "_menMade"];
        if (_ids isEqualTo []) exitWith { ["STR_ALIVE_FOB_REFUSED_TROOP_FAILED"] call _tell };
        if (_pool) then { ["poolDebit", [_poolFaction, _cost]] call ALiVE_fnc_fobSupply } else { ["debit", [_id, _cost, "raise " + _key]] call ALiVE_fnc_fobSupply };
        // a FOB saved before troops existed has no list yet
        private _troops = [_entry, "troops", []] call ALIVE_fnc_hashGet;
        _troops pushBack [_kind, _key, _cost, _ids, _spawn select 0, _rowSide, _menMade, _spawn select 1];
        [_entry, "troops", _troops] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
        [_logic, "broadcastMirror"] call ALiVE_fnc_FOB;
        ["STR_ALIVE_FOB_RAISED", [_name, _cost]] call _tell;
        ["ALiVE Player FOBs - %1: %2 raised %3 (%4 men, %5) for %6", _id, name _caller, _key, _menMade, _ids, _cost] call ALiVE_fnc_dump;
        _result = true;
    };

    // A soldier class or a group class of a faction made as profiles near the FOB, holding it:
    // [profile ids, men], [[], 0] when nothing could be made. A group's vehicles stay behind and
    // their crews come on foot.
    case "spawnTroops": {
        _args params [["_id", "", [""]], ["_kind", "", [""]], ["_class", "", [""]], ["_faction", "", [""]], ["_side", "", [""]]];
        _result = [[], 0];
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry" || {isNil "ALiVE_ProfileHandler"}) exitWith {};
        private _pos = ([_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet) getPos [15, random 360];
        private _hook = format ["(_this select 0) setVariable ['ALiVE_FOB_raised', %1, true]", str _id];
        private _made = [];
        if (_kind == "GROUP") then {
            _made = [_class, _pos, random 360, true, _faction, true, false, "STEALTH", _hook, false, true] call ALIVE_fnc_createProfilesFromGroupConfig;
        } else {
            if (isClass (configFile >> "CfgVehicles" >> _class)) then {
                private _p = [[_class], _side, _faction, _pos, random 360, "", true, "", true] call ALIVE_fnc_createProfileEntity;
                [_p, "onEachSpawn", _hook] call ALIVE_fnc_profileEntity;
                [_p, "onEachSpawnOnce", false] call ALIVE_fnc_profileEntity;
                _made = [_p];
            };
        };
        private _ids = [];
        private _men = 0;
        {
            if (_x isEqualType [] && {([_x, "type", ""] call ALIVE_fnc_hashGet) == "entity"}) then {
                [_x, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [30, "false", [0,0,0], "", 1, 0.3, "SAFE", "LIMITED", ""]]] call ALIVE_fnc_profileEntity;
                [_x, "busy", true] call ALIVE_fnc_hashSet;
                _ids pushBack ([_x, "profileID", ""] call ALIVE_fnc_hashGet);
                _men = _men + count ([_x, "unitClasses", []] call ALIVE_fnc_hashGet);
            };
        } forEach _made;
        ["pinStatic", _ids] call ALiVE_fnc_fobOps;
        _result = [_ids, _men];
    };

    // How many raised soldiers a FOB holds: a row counts while any of its profiles is left, and a
    // row waiting to be made again (no ids) counts too
    case "troopsHeld": {
        _args params [["_id", "", [""]]];
        _result = 0;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith {};
        {
            private _ids = _x param [3, []];
            if (_ids isEqualTo [] || {isNil "ALiVE_ProfileHandler"} || {(_ids findIf { !isNil {[ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler} }) > -1}) then {
                _result = _result + (_x param [6, 0]);
            };
        } forEach ([_entry, "troops", []] call ALIVE_fnc_hashGet);
    };

    // The raised troops go with the FOB: dismantled, salvaged or taken
    case "removeTroops": {
        _args params [["_id", "", [""]]];
        _result = 0;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith {};
        {
            {
                if (!isNil "ALIVE_profileStationary") then { [ALIVE_profileStationary, _x] call ALIVE_fnc_hashRem };
                private _pr = if (isNil "ALiVE_ProfileHandler") then { nil } else { [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler };
                if (!isNil "_pr") then { [_pr, "destroy"] call ALIVE_fnc_profileEntity; _result = _result + 1 };
            } forEach (_x param [3, []]);
        } forEach ([_entry, "troops", []] call ALIVE_fnc_hashGet);
        if (_result > 0) then { ["ALiVE Player FOBs - %1: %2 groups of raised troops gone with the FOB", _id, _result] call ALiVE_fnc_dump };
        [_entry, "troops", []] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
    };

    // A saved FOB's raised troops: kept profiles pinned and garrisoned again (a saved profile keeps no
    // orders). Profile ids are only a counter, so one is the FOB's only when it is of the row's faction
    // and its spawn hook names this FOB (the hook is saved with the profile). Ones not found are made
    // again, free. With no Virtual AI System yet nothing is touched: the watchdog runs this again once
    // it is up, so saved men that load late are found rather than doubled.
    case "restoreTroops": {
        _args params [["_id", "", [""]]];
        _result = 0;
        private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
        if (isNil "_entry") exitWith {};
        private _rows = [_entry, "troops", []] call ALIVE_fnc_hashGet;
        if !(_rows isEqualType []) then { _rows = []; [_entry, "troops", _rows] call ALIVE_fnc_hashSet };
        if (isNil "ALiVE_ProfileHandler") exitWith {
            if (_rows isNotEqualTo []) then { [_entry, "troopsPending", true] call ALIVE_fnc_hashSet };
        };
        [_entry, "troopsPending", false] call ALIVE_fnc_hashSet;
        private _tag = str _id;
        private _active = ([_entry, "status", ""] call ALIVE_fnc_hashGet) == "active";
        private _drop = [];
        {
            private _row = _x;
            _row params ["_kind", "_key", "_cost", ["_ids", []], ["_faction", ""], ["_side", ""], ["_men", 0], ["_class", ""]];
            private _mine = _ids select {
                private _pr = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                !isNil "_pr" && {([_pr, "faction", ""] call ALIVE_fnc_hashGet) == _faction}
                    && {_tag in ([_pr, "onEachSpawn", ""] call ALIVE_fnc_hashGet)}
            };
            if (_mine isNotEqualTo []) then {
                {
                    private _pr = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                    [_pr, "busy", true] call ALIVE_fnc_hashSet;
                    [_pr, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [30, "false", [0,0,0], "", 1, 0.3, "SAFE", "LIMITED", ""]]] call ALIVE_fnc_profileEntity;
                } forEach _mine;
                ["pinStatic", _mine] call ALiVE_fnc_fobOps;
                _row set [3, _mine];
            } else {
                _row set [3, []];
                // a damaged FOB's lost troops wait for the watchdog, which makes them again once it's repaired
                if (_active) then {
                    (["spawnTroops", [_id, _kind, _class, _faction, _side]] call ALiVE_fnc_fobOps) params ["_newIds", "_newMen"];
                    if (_newIds isNotEqualTo []) then {
                        _row set [3, _newIds];
                        _row set [6, _newMen];
                        ["ALiVE Player FOBs - %1: raised %2 not found in the save, made again free (%3)", _id, _key, _newIds] call ALiVE_fnc_dump;
                    } else {
                        // one that can't be made (its mod isn't loaded now) is dropped rather than holding a place
                        ["ALiVE Player FOBs - %1: raised %2 can't be made again, so it's dropped", _id, _key] call ALiVE_fnc_dumpR;
                        _drop pushBack _forEachIndex;
                    };
                };
            };
            _result = _result + 1;
        } forEach _rows;
        reverse _drop;
        { _rows deleteAt _x } forEach _drop;
        if (_result > 0) then { ALiVE_FOB_dirty = true };
    };

    // An empty vehicle as a profile at a spot: its profile id, or "" when it couldn't be made
    case "spawnVehicle": {
        _args params [["_class", "", [""]], ["_pos", [0,0,0], [[]]], ["_dir", 0, [0]], ["_faction", "", [""]]];
        _result = [];
        if (isNil "ALiVE_ProfileHandler" || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {};
        private _cfg = configFile >> "CfgVehicles" >> _class;
        private _side = ["EAST", "WEST", "GUER"] param [getNumber (_cfg >> "side"), "WEST"];
        // an aircraft is made with the profile flag that spawns it exactly where it was left (its own pad or
        // taxiway spot) and skips the faction swap: without it every spawn looks for a "better" spot up to
        // 200 m away and moves a plane off the taxiway to an apron or hangar
        private _keepSpot = _class isKindOf "Helicopter" || {_class isKindOf "Plane"};
        private _made = [_class, _side, getText (_cfg >> "faction"), [_pos select 0, _pos select 1, 0], _dir, false, "", false, false, [], [], _keepSpot] call ALIVE_fnc_createProfilesUnCrewedVehicle;
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
