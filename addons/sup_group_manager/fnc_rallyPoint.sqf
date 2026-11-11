#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(rallyPoint);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_rallyPoint

Description:
Rally points: places a player (and, for a group leader, the AI of their group) can travel
between. The Rally Points module uses this, and missions can call it themselves.

The list of rally points is kept by the server and sent to everybody (ALiVE_rallyPoints):
adding or removing one from a client is passed to the server, which takes it from an admin's
machine only. Travel runs on the machine where the travelling unit is local; the server checks
for enemies at both ends first, ALiVE's virtual groups included. A request from a player's
machine acts only for that machine's own units.

Parameters:
_this select 0: STRING - operation
_this select 1: ARRAY - arguments

Operations:
"add"     [object, name, side]  a rally point. Name "" uses the object's ALiVE_rallyName
                                variable, else the nearest place's name. Side "ANY" (default),
                                "WEST", "EAST" or "GUER": who may use it.
"remove"  [object]
"rename"  [unit, name, object]  a new name for a rally point the unit stands at and may manage
                                (Who Can Manage); without the object, its squad's own
"pickup"  [unit, object]        a squad leader's rally point taken up, by a unit that may manage
                                it; without the object, its squad's own
"mayManage" [unit, row, what]   whether the unit may "RENAME" or "PICKUP" that row of
                                ALiVE_rallyPoints: admins always; a squad leader's point by Who
                                Can Manage, where Owner is the leader of the squad that put it
                                down; a synced point only renamed, and Owner lets no one in there.
                                An admin's change in game (ALiVE_rally_perm) wins over the module
"manageable" [unit, what]       the row of the rally point within 5 m the unit may manage that
                                way, or []
"permissions" [unit, rules, names] an admin's Who Can Manage for every rally point, from the
                                Permissions window (ALiVE_fnc_siteWhoDialog); kept over a restart
                                when the mission saves
"permReset" [unit]              an admin puts Who Can Manage back to the module's settings
"plant"   [group, leader or posATL, dir, name]
                                server: a squad leader's rally point made and watched (deploy, and
                                its return after Overrun Repair Time)
"restore" [row, token]          server: a placed rally point back after Overrun Repair Time
"leaderBack" [group, token, posATL, dir, name]  server, from the sites' shared clock: a squad's overrun point back
"siteLabel" [name, group]      how the sites' shared notifications and down marker name a point
"permLoad", "permSave", "storeQueue", "pendingWatch"
                                server: Who Can Manage and the squad leaders' and Zeus' rally points
                                kept over a restart when the mission saves (ALiVE Data, or Player
                                FOBs set to Persistent)
"list"    [unit]                the rally points the unit may use:
                                [[name, posASL, object or objNull, FOB id or ""], ...]
"near"    [unit]                the rally point the unit stands at, or []
"travel"  [unit, destination, force]
                                destination: a row from "list", an object, or a position.
                                force true skips the enemy check and the wait between trips.
                                Returns true when the trip was asked for.

Examples:
(begin example)
["add", [myFlag, "Alpha"]] call ALiVE_fnc_rallyPoint;
["travel", [player, myFlag, true]] call ALiVE_fnc_rallyPoint;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", [], [[]]]];

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

// the module's setting, or a default when the function is used without the module
private _set = {
    params ["_name", "_default"];
    private _v = (missionNamespace getVariable ["ALiVE_rallyLogic", objNull]) getVariable [_name, _default];
    // a number setting saved as text; a mission saved when Player FOB Rally Points was Yes or No reads as tier 2 or off,
    // and one saved with the field empty takes the default rather than 0 (off)
    if (_default isEqualType 0 && {_v isEqualType ""}) then { _v = switch (toLower _v) do { case "true"; case "": { _default }; case "false": { 0 }; default { parseNumber _v } } };
    if (_default isEqualType 0 && {_v isEqualType true}) then { _v = [0, _default] select _v };
    if (_default isEqualType true && {_v isEqualType ""}) then { _v = toLower _v != "false" };
    _v
};

private _autoName = {
    params ["_pos"];
    private _loc = nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "NameMarine", "Hill", "Airport"], 1500];
    if (_loc isNotEqualTo [] && {text (_loc select 0) != ""}) then { text (_loc select 0) } else { format [localize "STR_ALIVE_RALLY_UI_GRID", mapGridPosition _pos] }
};

private _result = true;

// What another machine may ask for. A trip, its move and its refusal only from the server, on any
// machine. On the server: a request for a unit only for the asking machine's own unit, and adding, removing
// or the class scan only from an admin's machine. The server's own calls, and the calls this function makes
// for itself (_ALiVE_rallyInner, seen down the call chain), always pass.
private _refused = false;
if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_rallyInner"}) then {
    private _sender = remoteExecutedOwner;
    _refused = if (_op in ["travel", "move", "refused", "plant", "restore", "leaderBack", "permLoad", "permSave", "pendingWatch", "storeQueue"]) then { true } else {
        switch (true) do {
            case (isServer && {_op in ["deploy", "pickup", "rename", "check", "permissions", "permReset"]}): {
                private _u = _args param [0, objNull];
                !(_u isEqualType objNull) || {isNull _u} || {owner _u != _sender}
            };
            case (isServer && {_op in ["add", "remove", "sync"]}): {
                private _i = allPlayers findIf { owner _x == _sender };
                _i < 0 || {!(["isAdmin", [allPlayers select _i]] call ALiVE_fnc_siteWho)}
            };
            default { false };
        }
    };
    if (_refused) then { ["ALiVE Rally Points - refused %1 from machine %2: not that machine's own unit, or not an admin's machine", _op, _sender] call ALiVE_fnc_dump };
};
if (_refused) exitWith { false };
private _ALiVE_rallyInner = true;

switch (_op) do {

    case "add": {
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        _args params [["_obj", objNull, [objNull]], ["_name", "", [""]], ["_side", "ANY", [""]], ["_kind", "script", [""]], ["_owner", grpNull, [grpNull]], ["_squad", grpNull, [grpNull]]];
        if (isNull _obj) exitWith { _result = false };
        if (_name == "") then { _name = _obj getVariable ["ALiVE_rallyName", ""] };
        if (_name == "") then { _name = [getPosATL _obj] call _autoName };
        private _list = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_x select 0) != _obj} };
        // a squad leader's point keeps the squad that put it down, also when the whole side may use it
        _list pushBack [_obj, _name, toUpper _side, _kind, _owner, objNull, _squad];
        ALiVE_rallyPoints = _list;
        publicVariable "ALiVE_rallyPoints";
        // the squad leaders' and Zeus' are kept over a restart
        if (_kind in ["leader", "zeus", "zeusObj"]) then { ["storeQueue"] call ALiVE_fnc_rallyPoint };
    };

    case "remove": {
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        _args params [["_obj", objNull, [objNull]]];
        // removed: a wait to bring it back after Overrun Repair Time is called off (an overrun sets its own after this)
        if (!isNull _obj) then {
            ["cancel", [_obj getVariable ["ALiVE_rallyBack", ""]]] call ALiVE_fnc_siteClock;
            _obj setVariable ["ALiVE_rallyBack", nil];
        };
        ALiVE_rallyPoints = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_x select 0) != _obj} };
        publicVariable "ALiVE_rallyPoints";
        // so the module's class scan doesn't bring it back
        ALiVE_rallyRemoved = ((missionNamespace getVariable ["ALiVE_rallyRemoved", []]) select { !isNull _x }) + [_obj];
        ["storeQueue"] call ALiVE_fnc_rallyPoint;
    };

    // server, from the module's class scan: the objects of the listed classes now on the map. Objects
    // already listed (synced, added by a script) keep their own name and side; one broadcast per change
    case "sync": {
        if (!isServer) exitWith {};
        _args params ["_now", "_side", ["_module", objNull, [objNull]]];
        private _removed = missionNamespace getVariable ["ALiVE_rallyRemoved", []];
        _now = _now select { alive _x && {!(_x in _removed)} };
        private _list = missionNamespace getVariable ["ALiVE_rallyPoints", []];
        // only this module's own class points are dropped when gone: with two modules (a side each), each
        // scan dropped the other's points until its next scan (A. Ares on Discord, 26 Oct)
        private _keep = _list select { !isNull (_x select 0) && {alive (_x select 0)} && {(_x select 3) != "class" || {!((_x param [5, objNull]) isEqualTo _module)} || {(_x select 0) in _now}} };
        private _known = _keep apply { _x select 0 };
        private _new = _now select { !(_x in _known) };
        { _keep pushBack [_x, (_x getVariable ["ALiVE_rallyName", ""]) call { if (_this != "") then { _this } else { [getPosATL _x] call _autoName } }, toUpper _side, "class", grpNull, _module] } forEach _new;
        if (count _keep != count _list || {_new isNotEqualTo []}) then {
            ALiVE_rallyPoints = _keep;
            publicVariable "ALiVE_rallyPoints";
        };
    };

    // a squad leader puts down the squad's own rally point where they stand (Leader Rally Points):
    // one per squad, refused with enemies within Enemy Radius or before Leader Rally Point Cooldown
    // has passed, and gone once enemies hold it for Leader Rally Point Overrun Time or the squad is gone
    case "deploy": {
        _args params [["_unit", objNull, [objNull]]];
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        private _mode = toUpper (["leaderRally", "OFF"] call _set);
        private _grp = group _unit;
        private _tell = { [localize "STR_ALIVE_RALLY", _this] remoteExecCall ["ALIVE_fnc_sendHint", _unit] };
        if (_mode == "OFF" || {isNull _unit} || {leader _grp != _unit} || {!alive _unit} || {vehicle _unit != _unit}) exitWith { _result = false };
        private _key = "ALiVE_rallyDeployNext_" + str _grp;
        private _wait = (missionNamespace getVariable [_key, 0]) - time;
        if (_wait > 0) exitWith { format [localize "STR_ALIVE_RALLY_UI_DEPLOY_WAIT", ceil _wait] call _tell; _result = false };
        private _r = (["enemyRadius", 300] call _set) max 50;
        if ([getPosATL _unit, str side _grp, _r, !isNil "ALIVE_profileHandler"] call ALIVE_fnc_isEnemyNear) exitWith {
            format [localize "STR_ALIVE_RALLY_UI_DEPLOY_ENEMY", round _r] call _tell; _result = false
        };
        // the squad's earlier one goes
        private _old = _grp getVariable ["ALiVE_rallyDeployed", objNull];
        if (!isNull _old) then { ["remove", [_old]] call ALiVE_fnc_rallyPoint; deleteVehicle _old };
        missionNamespace setVariable [_key, time + (["leaderCooldown", 120] call _set)];
        ["plant", [_grp, _unit, getDir _unit, format [localize "STR_ALIVE_RALLY_LEADER_NAME", groupId _grp]]] call ALiVE_fnc_rallyPoint;
        localize "STR_ALIVE_RALLY_UI_DEPLOYED" call _tell;
    };

    // server: a squad leader's rally point made and watched, put down by "deploy" (in front of the leader) or brought
    // back after Overrun Repair Time (where it stood). Gone once enemies hold it for Leader Rally Point Overrun Time or
    // the squad is gone; overrun, it comes back after Overrun Repair Time unless the squad has put another one down.
    // [group, leader or posATL, dir, name] -> the object, or false
    case "plant": {
        if (!isServer) exitWith { _result = false };
        _args params [["_grp", grpNull, [grpNull]], ["_where", objNull, [objNull, []]], ["_dir", 0, [0]], ["_name", "", [""]]];
        private _mode = toUpper (["leaderRally", "OFF"] call _set);
        if (isNull _grp || {_mode == "OFF"}) exitWith { _result = false };
        private _r = (["enemyRadius", 300] call _set) max 50;
        // a ground holder carrying the backpack is the rally point: a backpack made with createVehicle
        // sits inside a holder of its own and reports a position kilometres away, so the marker went
        // there and deleting it left the holder behind (The Horny Latino on Discord, 14 Oct)
        // the mission's own object if it sets one (A. Ares, 20 Oct): a backpack goes in a holder as the usual one does,
        // anything else stands there itself
        private _rc = [["leaderRallyClass", ""] call _set, str side _grp, ""] call _pickClass;
        private _bag = _rc == "" || {_rc isKindOf "Bag_Base"};
        private _posATL = if (_where isEqualType objNull) then { _where modelToWorld [0, [1.5, 1.2] select _bag, 0] } else { _where };
        private _obj = objNull;
        // the backpack is a simple object, a picture of the bag with no inventory: a real one in a ground holder
        // came with Arma's own "Take" action, which no script can take off (Jman, 24 Oct). The rally point's
        // own actions are on the player, so nothing needs the object to carry one.
        if (_bag) then {
            _obj = createSimpleObject [[_rc, "B_Carryall_oli"] select (_rc == ""), AGLToASL _posATL];
        } else {
            _obj = createVehicle [_rc, _posATL, [], 0, "CAN_COLLIDE"];
            clearItemCargoGlobal _obj; clearWeaponCargoGlobal _obj; clearMagazineCargoGlobal _obj; clearBackpackCargoGlobal _obj;
        };
        _obj setDir _dir;
        // stood flush with the slope it is on rather than upright (A. Ares on Discord, 23 Oct)
        _obj setVectorUp (surfaceNormal (getPosATL _obj));
        _grp setVariable ["ALiVE_rallyDeployed", _obj, true];
        // a new one: an earlier one waiting to come back stays gone, and so does one from before a restart
        ["cancel", [_grp getVariable ["ALiVE_rallyBack", ""]]] call ALiVE_fnc_siteClock;
        _grp setVariable ["ALiVE_rallyBack", nil];
        if (!isNil "ALiVE_rallyPending") then { ALiVE_rallyPending = ALiVE_rallyPending select { !((_x select 0) == str side _grp && {(_x select 1) == groupId _grp}) } };
        ["add", [_obj, _name, str side _grp, "leader", [_grp, grpNull] select (_mode == "SIDE"), _grp]] call ALiVE_fnc_rallyPoint;
        _result = _obj;
        // Leader Rally Point Init (A. Ares on Discord, 27 Oct): the mission's own code on each object a squad leader's rally
        // point makes, put down or brought back, as Eden and Zeus points have their init fields. _this = [object, group]
        private _init = ["leaderRallyInit", ""] call _set;
        if (_init isEqualType "" && {_init != ""}) then { [_obj, _grp] call compile _init };
        [_obj, _grp, _r, ["leaderOverrun", 30] call _set, ["repairTime", 0] call _set] spawn {
            params ["_obj", "_grp", "_r", "_overrun", "_repair"];
            // the server's own: this runs on from a player's deploy request, which it would otherwise count as asking
            private _ALiVE_rallyInner = true;
            private _held = 0;
            // 0 or less: never overrun (A. Ares on Discord, 26 Oct); it used to go the moment it was put down
            private _never = _overrun <= 0;
            while { alive _obj && {!isNull _grp} && {({ alive _x } count units _grp) > 0} && {_never || {_held < _overrun}} } do {
                sleep 5;
                if (!_never) then {
                    _held = if ([getPosATL _obj, str side _grp, _r, !isNil "ALIVE_profileHandler"] call ALIVE_fnc_isEnemyNear) then { _held + 5 } else { 0 };
                };
            };
            private _lost = !_never && {_held >= _overrun} && {!isNull _grp};
            // only forget the squad's rally point if it is still this one: when the leader puts a new one down the old one
            // is deleted, and clearing here then wiped the new one, so it lost Rename and Pick Up and the next one put down
            // left it standing (A. Ares on Discord, 24 Oct)
            private _mine = !isNull _grp && {(_grp getVariable ["ALiVE_rallyDeployed", objNull]) isEqualTo _obj};
            // where it stood and what it is called now, to bring it back
            private _list = missionNamespace getVariable ["ALiVE_rallyPoints", []];
            private _name = (_list param [_list findIf { (_x select 0) isEqualTo _obj }, []]) param [1, ""];
            private _posATL = if (isNull _obj) then { [] } else { getPosATL _obj };
            private _dir = if (isNull _obj) then { 0 } else { getDir _obj };
            private _back = _lost && {_mine} && {_repair > 0} && {_posATL isNotEqualTo []} && {_name != ""};
            private _label = ["siteLabel", [_name, _grp]] call ALiVE_fnc_rallyPoint;
            // the squad is told, worded as every site's is (ALiVE_fnc_siteClock)
            if (_lost) then { ["notify", [["lost", "down"] select _back, units _grp, _label, _repair / 60]] call ALiVE_fnc_siteClock };
            ["remove", [_obj]] call ALiVE_fnc_rallyPoint;
            if (!isNull _obj) then { deleteVehicle _obj };
            if (_mine) then { _grp setVariable ["ALiVE_rallyDeployed", nil, true] };
            // Overrun Repair Time, on the sites' shared clock: back where it stood, unless the squad has put another
            // one down or is gone by then. The clock's key is the token: a new one put down calls it off
            if (_back) then {
                private _token = ["newKey", ["rally"]] call ALiVE_fnc_siteClock;
                _grp setVariable ["ALiVE_rallyBack", _token];
                ["ALiVE Rally Points: %1 was overrun; back in %2 s", _name, _repair] call ALiVE_fnc_dump;
                ["start", [_token, _repair, "ALiVE_fnc_rallyPoint", ["leaderBack", [_grp, _token, _posATL, _dir, _name]],
                    [str side _grp, _posATL, _label, "back"]]] call ALiVE_fnc_siteClock;
            };
        };
    };

    // how the sites' shared notifications and down marker name a squad's point: "Rally point Zulu", or its
    // own name when it is still the squad's "Alpha 1-3 rally point". [name, group] -> text
    case "siteLabel": {
        _args params [["_name", "", [""]], ["_grp", grpNull, [grpNull]]];
        if (_name == "" && {!isNull _grp}) then { _name = format [localize "STR_ALIVE_RALLY_LEADER_NAME", groupId _grp] };
        _result = if (!isNull _grp && {_name == format [localize "STR_ALIVE_RALLY_LEADER_NAME", groupId _grp]}) then { _name } else { format [localize "STR_ALIVE_SITE_RALLY", _name] };
    };

    // server, from the sites' shared clock: a squad's overrun rally point back where it stood after Overrun Repair
    // Time, unless the squad has put another one down or is gone. [group, token, posATL, dir, name]
    case "leaderBack": {
        if (!isServer) exitWith {};
        _args params [["_grp", grpNull, [grpNull]], ["_token", ""], ["_posATL", [], [[]]], ["_dir", 0, [0]], ["_name", "", [""]]];
        if (isNull _grp || {({ alive _x } count units _grp) == 0} || {!isNull (_grp getVariable ["ALiVE_rallyDeployed", objNull])}
            || {!((_grp getVariable ["ALiVE_rallyBack", []]) isEqualTo _token)}) exitWith {};
        private _o = ["plant", [_grp, _posATL, _dir, _name]] call ALiVE_fnc_rallyPoint;
        if (_o isEqualType objNull && {!isNull _o}) then {
            ["ALiVE Rally Points: %1 is back", _name] call ALiVE_fnc_dump;
            ["notify", ["back", units _grp, ["siteLabel", [_name, _grp]] call ALiVE_fnc_rallyPoint]] call ALiVE_fnc_siteClock;
        };
    };

    // server: a placed rally point overrun earlier back on the list after Overrun Repair Time (the module's watch,
    // ALiVE_fnc_rallyInit), if its object still stands and nothing removed it meanwhile. [row, token] -> true when back
    case "restore": {
        if (!isServer) exitWith { _result = false };
        _args params [["_row", [], [[]]], ["_token", []]];
        private _o = _row param [0, objNull];
        _result = false;
        if (isNull _o || {!alive _o} || {!((_o getVariable ["ALiVE_rallyBack", []]) isEqualTo _token)}) exitWith {};
        _o setVariable ["ALiVE_rallyBack", nil];
        _o setVariable ["ALiVE_rallyHeld", 0];
        ALiVE_rallyRemoved = (missionNamespace getVariable ["ALiVE_rallyRemoved", []]) select { !isNull _x && {_x != _o} };
        private _list = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_x select 0) != _o} };
        _row params ["", "_name", "_who"];
        private _label = format [localize "STR_ALIVE_SITE_RALLY", _name];
        // Taken When Held (Jman, 4 Nov): the enemy holding its ground now, with none of its side there, has it back as theirs,
        // for anyone of that side
        private _taker = "";
        if (["pointCapture", false] call _set) then {
            _taker = ["holder", [getPosATL _o, _who, (["enemyRadius", 100] call _set) max 50]] call ALiVE_fnc_siteClock;
        };
        if (_taker != "") then {
            _row = +_row;
            _row set [2, _taker];
            _row set [4, grpNull];
        };
        _list pushBack _row;
        ALiVE_rallyPoints = _list;
        publicVariable "ALiVE_rallyPoints";
        _result = true;
        if (_taker != "") exitWith {
            ["ALiVE Rally Points: %1 was taken by %2 from %3", _name, _taker, _who] call ALiVE_fnc_dump;
            ["notify", ["lost", _who, _label]] call ALiVE_fnc_siteClock;
            ["notify", ["taken", _taker, _label]] call ALiVE_fnc_siteClock;
            if ((_row select 3) in ["zeus", "zeusObj"]) then { ["storeQueue"] call ALiVE_fnc_rallyPoint };
        };
        ["ALiVE Rally Points: %1 (%2) is back", _name, _who] call ALiVE_fnc_dump;
        ["notify", ["back", _who, _label]] call ALiVE_fnc_siteClock;
    };

    // a rally point renamed by someone standing at it who may manage it (Who Can Manage). The name is
    // cleaned here: no control characters, no < > & (it is shown as structured text), 32 characters at most
    case "rename": {
        _args params [["_unit", objNull, [objNull]], ["_name", "", [""]], ["_obj", objNull, [objNull]]];
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        // from a player's machine, only for that player's own unit
        if (isNull _unit || {isRemoteExecuted && {remoteExecutedOwner != owner _unit}}) exitWith { _result = false };
        if (isNull _obj) then { _obj = (group _unit) getVariable ["ALiVE_rallyDeployed", objNull] };
        private _list = missionNamespace getVariable ["ALiVE_rallyPoints", []];
        private _i = if (isNull _obj) then { -1 } else { _list findIf { (_x select 0) == _obj } };
        if (_i < 0 || {_unit distance _obj >= 5} || {!(["mayManage", [_unit, _list select _i, "RENAME"]] call ALiVE_fnc_rallyPoint)}) exitWith { _result = false };
        private _tell = { [localize "STR_ALIVE_RALLY", _this] remoteExecCall ["ALIVE_fnc_sendHint", _unit] };
        _name = ["cleanName", [_name, 32]] call ALiVE_fnc_siteWho;
        if (_name == "") exitWith { format [localize "STR_ALIVE_RALLY_UI_RENAME_EMPTY", 32] call _tell; _result = false };
        (_list select _i) set [1, _name];
        ALiVE_rallyPoints = _list;
        publicVariable "ALiVE_rallyPoints";
        format [localize "STR_ALIVE_RALLY_UI_RENAMED", _name] call _tell;
        ["storeQueue"] call ALiVE_fnc_rallyPoint;
    };

    case "pickup": {
        _args params [["_unit", objNull, [objNull]], ["_obj", objNull, [objNull]]];
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        if (isNull _obj) then { _obj = (group _unit) getVariable ["ALiVE_rallyDeployed", objNull] };
        private _row = if (isNull _obj) then { [] } else { (missionNamespace getVariable ["ALiVE_rallyPoints", []]) param [(missionNamespace getVariable ["ALiVE_rallyPoints", []]) findIf { (_x select 0) == _obj }, []] };
        if (_row isEqualTo [] || {_unit distance _obj >= 5} || {!(["mayManage", [_unit, _row, "PICKUP"]] call ALiVE_fnc_rallyPoint)}) exitWith { _result = false };
        // the squad that put it down, which may not be the one picking it up
        private _grp = _row param [6, grpNull];
        if (isNull _grp) then { _grp = _row param [4, grpNull] };
        ["remove", [_obj]] call ALiVE_fnc_rallyPoint;
        deleteVehicle _obj;
        if (!isNull _grp && {(_grp getVariable ["ALiVE_rallyDeployed", objNull]) isEqualTo _obj}) then { _grp setVariable ["ALiVE_rallyDeployed", nil, true] };
    };

    // Who Can Manage: a squad leader's point renamed or picked up, a synced point renamed. Works on any machine.
    case "mayManage": {
        _args params [["_unit", objNull, [objNull]], ["_row", [], [[]]], ["_what", "RENAME", [""]]];
        _result = false;
        if (isNull _unit || {_row isEqualTo []}) exitWith {};
        _row params [["_obj", objNull], "", ["_who", "ANY"], ["_kind", ""], ["_owner", grpNull]];
        if (isNull _obj || {!alive _obj}) exitWith {};
        // what can be managed at all: a leader's point both ways, a synced one only renamed
        if !(_kind == "leader" || {_kind == "synced" && {_what == "RENAME"}}) exitWith {};
        if (["isAdmin", [_unit]] call ALiVE_fnc_siteWho) exitWith { _result = true };
        // only a point the unit could use: its side's, and its squad's when the point is kept to one squad
        if !(_who in ["ANY", str side group _unit]) exitWith {};
        if (!isNull _owner && {_owner != group _unit}) exitWith {};
        // an admin's change from the Permissions window, else the module's own
        private _perm = (missionNamespace getVariable ["ALiVE_rallyLogic", objNull]) getVariable ["ALiVE_rally_perm", []];
        if !(_perm isEqualTypeArray ["", ""]) then { _perm = [["rallyManageWho", "OWNER"] call _set, ["rallyManageList", ""] call _set] };
        private _rules = ["filter", [_perm select 0, ["SIDE", "LEADER", "OWNER", "ITEM", "LIST"]]] call ALiVE_fnc_siteWho;
        private _names = _perm select 1;
        private _rest = (_rules splitString ",") select { _x != "OWNER" };
        // Owner: the leader of the squad that put the point down, as before the setting was added; a synced
        // point has none, so no one
        private _squad = _row param [6, grpNull];
        if (isNull _squad) then { _squad = _owner };
        _result = ("OWNER" in (_rules splitString ",") && {_kind == "leader"} && {!isNull _squad} && {leader _squad isEqualTo _unit})
            || {_rest isNotEqualTo [] && {["mayWho", [_unit, _rest joinString ",", _names, ""]] call ALiVE_fnc_siteWho}};
    };

    // the rally point within 5 m the unit may manage that way, nearest first
    case "manageable": {
        _args params [["_unit", objNull, [objNull]], ["_what", "RENAME", [""]]];
        _result = [];
        if (isNull _unit) exitWith {};
        private _rows = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_unit distance (_x select 0)) < 5} };
        _rows = [_rows, [], { _unit distance (_x select 0) }, "ASCEND"] call BIS_fnc_sortBy;
        private _i = _rows findIf { ["mayManage", [_unit, _x, _what]] call ALiVE_fnc_rallyPoint };
        if (_i > -1) then { _result = _rows select _i };
    };

    // An admin's Who Can Manage from the Permissions window, for every rally point; "permReset" drops it.
    // A player's machine asks only for its own unit (the check at the top), and the unit must be an admin.
    // Kept over a restart when the mission saves (permCanSave), as the Logistics Hub's are.
    case "permReset";
    case "permissions": {
        _args params [["_unit", objNull, [objNull]], ["_rules", "", [""]], ["_names", "", [""]]];
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        _result = false;
        private _logic = missionNamespace getVariable ["ALiVE_rallyLogic", objNull];
        if (isNull _unit || {isNull _logic}) exitWith {};
        private _tell = { [localize "STR_ALIVE_RALLY", localize _this] remoteExecCall ["ALIVE_fnc_sendHint", _unit] };
        // no faster than one every 2 s per player
        private _key = "ALiVE_rallyPermAt_" + ([str _unit, getPlayerUID _unit] select (isPlayer _unit));
        if (time - (missionNamespace getVariable [_key, -10]) < 2) exitWith {};
        missionNamespace setVariable [_key, time];
        if !(["isAdmin", [_unit]] call ALiVE_fnc_siteWho) exitWith {
            ["ALiVE Rally Points - %1 asked to change who can manage rally points, but is no admin", name _unit] call ALiVE_fnc_dump;
            "STR_ALIVE_RALLY_PERM_REFUSED" call _tell;
        };
        if (_op == "permReset") then {
            _logic setVariable ["ALiVE_rally_perm", nil, true];
            ["ALiVE Rally Points - %1 put who can manage rally points back to the module's settings", name _unit] call ALiVE_fnc_dump;
            "STR_ALIVE_RALLY_PERM_RESET" call _tell;
        } else {
            _rules = ["filter", [_rules, ["SIDE", "LEADER", "OWNER", "ITEM", "LIST"]]] call ALiVE_fnc_siteWho;
            _names = ["cleanNames", [_names]] call ALiVE_fnc_siteWho;
            _logic setVariable ["ALiVE_rally_perm", [_rules, _names], true];
            ["ALiVE Rally Points - %1 set who can manage rally points to [%2], list [%3]", name _unit, _rules, _names] call ALiVE_fnc_dump;
            "STR_ALIVE_RALLY_PERM_SET" call _tell;
        };
        // a change made before the saved one is read keeps winning over it
        _logic setVariable ["ALiVE_rally_permChanged", true];
        ["permSave"] call ALiVE_fnc_rallyPoint;
        _result = true;
    };

    // the mission saves: with ALiVE Data, or with Player FOBs set to Persistent
    case "permCanSave": {
        private _fob = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
        _result = (!isNil "ALIVE_sys_data" && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", true])})
            || {!isNull _fob && {[_fob, "attribute", ["fob_persistent"]] call ALiVE_fnc_FOB}};
    };

    case "permStoreKey": {
        _result = if (isNil "ALIVE_sys_data_GROUP_ID") then {
            format ["ALiVE_RALLY_%1:%2", [missionName, "%20", "-"] call CBA_fnc_replace, worldName]
        } else {
            (["_RALLY"] call ALiVE_fnc_storeKeys) select 0
        };
    };

    // server, once from the module, after ALiVE Data has started: the saved change to Who Can Manage, and the squad
    // leaders' and Zeus' rally points. Stored as ["v1", [rules, names] or [], points], a point being
    // [kind, who, name, posATL, dir, extra]: extra is [side, callsign] of a leader's squad, a Zeus point's object class.
    // A Zeus backpack is put back down; a Zeus point on an object is put back on that object when the mission has it
    // again. Groups are new after a restart, so a leader's point waits until a squad with its callsign is on its side
    // ("pending"), and goes down for that squad then.
    case "permLoad": {
        if (!isServer || {!isNil "ALiVE_rallyPermLoading"}) exitWith {};
        ALiVE_rallyPermLoading = true;
        [] spawn {
            private _ALiVE_rallyInner = true;
            private _t0 = diag_tickTime;
            if (["ALiVE_sys_data"] call ALiVE_fnc_isModuleAvailable) then {
                waitUntil { sleep 1; (!isNil "ALIVE_sys_data" && {!isNil "ALIVE_sys_data_DISABLED"} && {ALIVE_sys_data getVariable ["startupComplete", false]}) || {diag_tickTime - _t0 > 300} };
            };
            private _logic = missionNamespace getVariable ["ALiVE_rallyLogic", objNull];
            if (isNull _logic || {!(["permCanSave"] call ALiVE_fnc_rallyPoint)}) exitWith {};
            private _key = ["permStoreKey"] call ALiVE_fnc_rallyPoint;
            private _plain = [];
            if (!isNil "ALIVE_sys_data" && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", true])}) then {
                if (isNil "ALiVE_rally_dataHandler") then {
                    ALiVE_rally_dataHandler = [nil, "create"] call ALIVE_fnc_Data;
                    [ALiVE_rally_dataHandler, "storeType", true] call ALIVE_fnc_Data;
                };
                private _doc = [ALiVE_rally_dataHandler, "read", ["sup_fob", [], _key]] call ALIVE_fnc_Data;
                if (_doc isEqualType [] && {count _doc > 0}) then {
                    private _d = [_doc, "data"] call CBA_fnc_hashGet;
                    if (!isNil "_d") then { _plain = _d };
                };
            } else {
                _plain = profileNamespace getVariable [_key, []];
            };
            // the read is done: saving may write from here on, without losing what was there
            ALiVE_rallyStoreRead = true;
            if !(_plain isEqualType [] && {(_plain param [0, ""]) isEqualTo "v1"}) exitWith {};
            private _perm = _plain param [1, []];
            if ((_perm isEqualTypeArray ["", ""]) && {!(_logic getVariable ["ALiVE_rally_permChanged", false])}) then {
                _logic setVariable ["ALiVE_rally_perm", [["filter", [_perm select 0, ["SIDE", "LEADER", "OWNER", "ITEM", "LIST"]]] call ALiVE_fnc_siteWho, ["cleanNames", [_perm select 1]] call ALiVE_fnc_siteWho], true];
                ["ALiVE Rally Points - who can manage is [%1], list [%2], as an admin set it before the restart (%3)", (_logic getVariable "ALiVE_rally_perm") select 0, (_logic getVariable "ALiVE_rally_perm") select 1, _key] call ALiVE_fnc_dump;
            };
            private _points = _plain param [2, []];
            if !(_points isEqualType []) then { _points = [] };
            private _n = [0, 0, 0];
            {
                if (_x isEqualTypeParams ["", "", "", [], 0]) then {
                    _x params ["_kind", "_who", "_name", "_pos", "_dir", ["_extra", ""]];
                    switch (_kind) do {
                        case "zeus": {
                            private _o = createSimpleObject ["B_Carryall_oli", AGLToASL _pos];
                            _o setDir _dir;
                            _o setVectorUp (surfaceNormal _pos);
                            ["add", [_o, _name, _who, "zeus", grpNull]] call ALiVE_fnc_rallyPoint;
                            _n set [0, (_n select 0) + 1];
                        };
                        case "zeusObj": {
                            private _near = if (_extra isEqualType "" && {_extra != ""}) then { (nearestObjects [_pos, [_extra], 3]) select { alive _x } } else { [] };
                            if (_near isEqualTo []) then {
                                ["ALiVE Rally Points - %1 was on a %2 at %3, which the mission doesn't have now, so it is left out", _name, _extra, mapGridPosition _pos] call ALiVE_fnc_dump;
                            } else {
                                ["add", [_near select 0, _name, _who, "zeusObj", grpNull]] call ALiVE_fnc_rallyPoint;
                                _n set [1, (_n select 1) + 1];
                            };
                        };
                        case "leader": {
                            if (_extra isEqualTypeArray ["", ""]) then {
                                if (isNil "ALiVE_rallyPending") then { ALiVE_rallyPending = [] };
                                ALiVE_rallyPending pushBack [_extra select 0, _extra select 1, _pos, _dir, _name];
                                _n set [2, (_n select 2) + 1];
                            };
                        };
                    };
                };
            } forEach _points;
            if (_n isNotEqualTo [0, 0, 0]) then {
                ["ALiVE Rally Points - from before the restart: %1 Zeus backpack(s) and %2 Zeus point(s) on objects back, %3 squad leader point(s) waiting for their squads", _n select 0, _n select 1, _n select 2] call ALiVE_fnc_dump;
            };
            if ((_n select 2) > 0) then { ["pendingWatch"] call ALiVE_fnc_rallyPoint };
        };
    };

    // server: a squad leader's point from before the restart goes down once a squad with its callsign is on its side,
    // alive and with no point of its own. Looked for every 10 s while any wait.
    case "pendingWatch": {
        if (!isServer || {!isNil "ALiVE_rallyPendingWatch"}) exitWith {};
        ALiVE_rallyPendingWatch = true;
        [] spawn {
            private _ALiVE_rallyInner = true;
            while { (missionNamespace getVariable ["ALiVE_rallyPending", []]) isNotEqualTo [] } do {
                {
                    _x params ["_side", "_callsign", "_pos", "_dir", "_name"];
                    private _i = allGroups findIf { str side _x == _side && {groupId _x == _callsign} && {({ alive _x } count units _x) > 0} && {isNull (_x getVariable ["ALiVE_rallyDeployed", objNull])} };
                    if (_i > -1) then {
                        private _o = ["plant", [allGroups select _i, _pos, _dir, _name]] call ALiVE_fnc_rallyPoint;
                        if (_o isEqualType objNull && {!isNull _o}) then { ["ALiVE Rally Points - %1 is back down for %2 (%3)", _name, _callsign, _side] call ALiVE_fnc_dump };
                    };
                } forEach +(missionNamespace getVariable ["ALiVE_rallyPending", []]);
                sleep 10;
            };
            ALiVE_rallyPendingWatch = nil;
        };
    };

    // server: a save a few seconds after a rally point is added, removed or renamed, one for several at once
    case "storeQueue": {
        if (!isServer || {!isNil "ALiVE_rallySaveQueued"}) exitWith {};
        ALiVE_rallySaveQueued = true;
        [] spawn {
            private _ALiVE_rallyInner = true;
            sleep 5;
            ALiVE_rallySaveQueued = nil;
            ["permSave"] call ALiVE_fnc_rallyPoint;
        };
    };

    case "permSave": {
        if (!isServer || {!(["permCanSave"] call ALiVE_fnc_rallyPoint)}) exitWith {};
        // not before the saved one is read, or the points not yet back would be written over
        if (isNil "ALiVE_rallyStoreRead") exitWith {
            [] spawn { private _ALiVE_rallyInner = true; waitUntil { sleep 1; !isNil "ALiVE_rallyStoreRead" }; ["permSave"] call ALiVE_fnc_rallyPoint };
        };
        private _perm = (missionNamespace getVariable ["ALiVE_rallyLogic", objNull]) getVariable ["ALiVE_rally_perm", []];
        if !(_perm isEqualTypeArray ["", ""]) then { _perm = [] };
        private _points = [];
        {
            _x params ["_o", "_name", "_who", "_kind", "", "", ["_squad", grpNull]];
            if (!isNull _o && {alive _o}) then {
                switch (_kind) do {
                    case "zeus": { _points pushBack ["zeus", _who, _name, getPosATL _o, getDir _o, ""] };
                    case "zeusObj": { _points pushBack ["zeusObj", _who, _name, getPosATL _o, getDir _o, typeOf _o] };
                    case "leader": { if (!isNull _squad) then { _points pushBack ["leader", _who, _name, getPosATL _o, getDir _o, [str side _squad, groupId _squad]] } };
                };
            };
        } forEach (missionNamespace getVariable ["ALiVE_rallyPoints", []]);
        // those still waiting for their squads
        { _x params ["_side", "_callsign", "_pos", "_dir", "_name"]; _points pushBack ["leader", _side, _name, _pos, _dir, [_side, _callsign]] } forEach (missionNamespace getVariable ["ALiVE_rallyPending", []]);
        private _key = ["permStoreKey"] call ALiVE_fnc_rallyPoint;
        private _plain = ["v1", _perm, _points];
        if (!isNil "ALIVE_sys_data" && {!(missionNamespace getVariable ["ALIVE_sys_data_DISABLED", true])}) then {
            if (isNil "ALiVE_rally_dataHandler") then {
                ALiVE_rally_dataHandler = [nil, "create"] call ALIVE_fnc_Data;
                [ALiVE_rally_dataHandler, "storeType", true] call ALIVE_fnc_Data;
            };
            private _doc = [[["data", _plain]]] call CBA_fnc_hashCreate;
            // the War Room backend updates a document by its revision, as for the FOBs and hubs
            private _prev = [ALiVE_rally_dataHandler, "read", ["sup_fob", [], _key]] call ALIVE_fnc_Data;
            if (_prev isEqualType [] && {count _prev > 0}) then {
                private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;
                if (!isNil "_rev") then { [_doc, "_rev", _rev] call CBA_fnc_hashSet };
            };
            [ALiVE_rally_dataHandler, "write", ["sup_fob", _doc, false, _key]] call ALIVE_fnc_Data;
        } else {
            profileNamespace setVariable [_key, _plain];
            saveProfileNamespace;
        };
        ["ALiVE Rally Points - saved to %1: who can manage %2, %3 rally point(s)", _key, ["the module's settings", "an admin's change"] select (_perm isNotEqualTo []), count _points] call ALiVE_fnc_dump;
    };


    case "list": {
        _args params [["_unit", objNull, [objNull]]];
        private _side = str side group _unit;
        _result = [];
        {
            _x params ["_obj", "_name", "_who", "", ["_owner", grpNull]];
            if (alive _obj && {_who in ["ANY", _side]} && {isNull _owner || {_owner == group _unit}}) then { _result pushBack [_name, getPosASL _obj, _obj, ""] };
        } forEach (missionNamespace getVariable ["ALiVE_rallyPoints", []]);
        // Player FOBs of the unit's side from the tier the module asks for; 0 is off
        private _minTier = ["rallyFOBs", 2] call _set;
        if (_minTier > 0 && {!isNil "ALiVE_FOB_registryMirror"}) then {
            {
                _x params ["_id", "_fside", "_fname", "_fpos", "_status", "_tier"];
                if (_fside == _side && {_status == "active"} && {_tier >= _minTier}) then {
                    _result pushBack [_fname, AGLToASL [_fpos select 0, _fpos select 1, 0], objNull, _id];
                };
            } forEach ALiVE_FOB_registryMirror;
        };
    };

    case "near": {
        _args params [["_unit", objNull, [objNull]]];
        private _p = getPosASL _unit;
        private _rows = ["list", [_unit]] call ALiVE_fnc_rallyPoint;
        private _i = _rows findIf {
            private _o = _x select 2;
            private _reach = if (isNull _o) then { 15 } else { 6 + ((boundingBoxReal _o) select 2) min 30 };
            (_p distance2D (_x select 1)) < _reach && {abs ((_p select 2) - ((_x select 1) select 2)) < 6}
        };
        _result = if (_i < 0) then { [] } else { _rows select _i };
    };

    case "travel": {
        _args params [["_unit", objNull, [objNull]], ["_dest", [], [[], objNull]], ["_force", false, [false]]];
        if (isNull _unit) exitWith { _result = false };
        // where the unit is local: its group's AI usually are too, and the fade and hints are its player's
        if (!local _unit) exitWith { [_op, _args] remoteExec ["ALiVE_fnc_rallyPoint", _unit] };
        // a row from "list", an object or a position
        private _row = switch (true) do {
            case (_dest isEqualType objNull): { [_dest getVariable ["ALiVE_rallyName", [getPosATL _dest] call _autoName], getPosASL _dest, _dest, ""] };
            case (count _dest == 4 && {(_dest select 0) isEqualType ""}): { _dest };
            default { [[_dest] call _autoName, if (count _dest > 2) then { AGLToASL _dest } else { AGLToASL (_dest + [0]) }, objNull, ""] };
        };
        private _say = { if (isPlayer _unit && {_unit == player}) then { [localize "STR_ALIVE_RALLY", _this] call ALIVE_fnc_sendHint } };
        if !(lifeState _unit in ["HEALTHY", "INJURED"]) exitWith { localize "STR_ALIVE_RALLY_UI_NOT_FIT" call _say; _result = false };
        if (vehicle _unit != _unit) exitWith { localize "STR_ALIVE_RALLY_UI_ON_FOOT" call _say; _result = false };
        private _key = "ALiVE_rallyNext_" + ([str _unit, getPlayerUID _unit] select (isPlayer _unit));
        private _wait = (missionNamespace getVariable [_key, 0]) - time;
        if (!_force && {_wait > 0}) exitWith { format [localize "STR_ALIVE_RALLY_UI_WAIT", ceil _wait] call _say; _result = false };
        if (_force) exitWith { ["move", [_unit, _row]] call ALiVE_fnc_rallyPoint };
        missionNamespace setVariable [_key, time + 15];   // waiting on the server's answer
        ["check", [_unit, _row]] remoteExecCall ["ALiVE_fnc_rallyPoint", 2];
    };

    // server: enemies near the unit or the destination, ALiVE's virtual groups counted
    case "check": {
        if (!isServer) exitWith {};
        _args params ["_unit", "_row"];
        // a rally point that moves (a vehicle): where it is now, not where it was when the list was made
        if (!isNull (_row select 2)) then { _row set [1, getPosASL (_row select 2)] };
        private _r = ["enemyRadius", 100] call _set;
        private _side = str side group _unit;
        private _profiles = !isNil "ALIVE_profileHandler";
        private _why = "";
        // which ends are checked: both, only where they're going, only where they are, or neither
        private _ends = toUpper (["enemyCheck", "BOTH"] call _set);
        if (_r > 0) then {
            if (_ends in ["BOTH", "HERE"] && {[getPosATL _unit, _side, _r, _profiles] call ALIVE_fnc_isEnemyNear}) then { _why = "STR_ALIVE_RALLY_UI_ENEMY_HERE" };
            if (_why == "" && {_ends in ["BOTH", "DEST"]} && {[ASLToAGL (_row select 1), _side, _r, _profiles] call ALIVE_fnc_isEnemyNear}) then { _why = "STR_ALIVE_RALLY_UI_ENEMY_THERE" };
        };
        // a FOB that has gone since the list was sent, or a rally object that was destroyed
        if (_why == "" && {(_row select 3) != ""} && {!isNil "ALiVE_FOB_registry"}) then {
            private _e = [ALiVE_FOB_registry, _row select 3] call ALIVE_fnc_hashGet;
            if (isNil "_e" || {([_e, "status", ""] call ALIVE_fnc_hashGet) != "active"} || {([_e, "tier", 1] call ALIVE_fnc_hashGet) < ((["rallyFOBs", 2] call _set) max 1)}) then { _why = "STR_ALIVE_RALLY_UI_GONE" };
        };
        if (_why == "" && {!isNull (_row select 2)} && {!alive (_row select 2)}) then { _why = "STR_ALIVE_RALLY_UI_GONE" };
        if (_why == "") then {
            ["move", [_unit, _row]] remoteExec ["ALiVE_fnc_rallyPoint", _unit];
        } else {
            ["refused", [_unit, _why]] remoteExec ["ALiVE_fnc_rallyPoint", _unit];
        };
    };

    case "refused": {
        _args params ["_unit", "_why"];
        missionNamespace setVariable ["ALiVE_rallyNext_" + ([str _unit, getPlayerUID _unit] select (isPlayer _unit)), 0];
        if (_unit == player) then { [localize "STR_ALIVE_RALLY", localize _why] call ALIVE_fnc_sendHint };
    };

    // the move itself, where the unit is local
    case "move": {
        _args params ["_unit", "_row"];
        if (!isNull (_row select 2)) then { _row set [1, getPosASL (_row select 2)] };
        _row params ["_name", "_posASL", "_obj"];
        // a group leader brings the AI of the group that are near, on foot and fit; anyone else goes alone
        private _who = [_unit];
        if (leader group _unit == _unit) then {
            private _r = ["squadRadius", 150] call _set;
            _who append ((units group _unit) select {
                !isPlayer _x && {alive _x} && {vehicle _x == _x} && {(_x distance _unit) < _r} && {lifeState _x in ["HEALTHY", "INJURED"]}
            });
        };
        // somewhere to stand for each: on a raised rally point (a roof, a deck) at its own height,
        // otherwise free ground round it
        private _raised = !isNull _obj && {((getPosATL _obj) select 2) > 1.5 || {surfaceIsWater (getPosATL _obj)}};
        private _spots = [];
        {
            private _s = [];
            if (_raised) then {
                for "_try" from 0 to 11 do {
                    if (_s isEqualTo []) then {
                        private _c = _posASL getPos [1.5 + (_forEachIndex mod 4) * 0.8, (_forEachIndex * 47 + _try * 30) mod 360];
                        _c set [2, (_posASL select 2) + 2];
                        private _hit = lineIntersectsSurfaces [_c, _c vectorAdd [0, 0, -5], _x, objNull, true, 1, "GEOM", "NONE"];
                        if (_hit isNotEqualTo [] && {abs (((_hit select 0) select 0 select 2) - (_posASL select 2)) < 3}) then { _s = (_hit select 0) select 0 };
                    };
                };
                // the traveller with nowhere to stand up there gets free ground round it instead
                if (_s isEqualTo [] && {_x == _unit}) then {
                    private _free = (ASLToAGL _posASL) findEmptyPosition [3, 40, "B_Soldier_F"];
                    if (_free isNotEqualTo []) then { _s = AGLToASL _free };
                };
            } else {
                private _c = (ASLToAGL _posASL) getPos [4 + random 5, _forEachIndex * (360 / count _who)];
                private _free = _c findEmptyPosition [0, 15, "B_Soldier_F"];
                if (_free isEqualTo []) then { _free = (ASLToAGL _posASL) findEmptyPosition [3, 60, "B_Soldier_F"] };
                if (_free isNotEqualTo []) then { _s = AGLToASL _free };
            };
            _spots pushBack _s;
        } forEach _who;
        if ((_spots select 0) isEqualTo []) exitWith { [_unit, "STR_ALIVE_RALLY_UI_NO_ROOM"] call { params ["_u", "_k"]; if (_u == player) then { [localize "STR_ALIVE_RALLY", localize _k] call ALIVE_fnc_sendHint } } };
        missionNamespace setVariable ["ALiVE_rallyNext_" + ([str _unit, getPlayerUID _unit] select (isPlayer _unit)), time + (["cooldown", 60] call _set)];
        [_unit, _who, _spots, _posASL, _name] spawn {
            params ["_unit", "_who", "_spots", "_posASL", "_name"];
            private _fade = _unit == player;
            if (_fade) then { cutText ["", "BLACK OUT", 0.6]; sleep 0.7 };
            private _moved = 0;
            {
                private _s = _spots select _forEachIndex;
                if (_s isNotEqualTo [] && {alive _x}) then {
                    _x setPosASL _s;
                    _x setVelocity [0, 0, 0];
                    _x setDir ((_posASL getDir _s));
                    if (_x != _unit) then { _moved = _moved + 1; if (local _x) then { _x doFollow _unit } };
                };
            } forEach _who;
            if (_fade) then {
                sleep 0.4;
                cutText ["", "BLACK IN", 0.8];
                [localize "STR_ALIVE_RALLY", if (_moved > 0) then { format [localize "STR_ALIVE_RALLY_UI_ARRIVED_WITH", _name, _moved] } else { format [localize "STR_ALIVE_RALLY_UI_ARRIVED", _name] }] call ALIVE_fnc_sendHint;
            };
        };
    };
};

_result
