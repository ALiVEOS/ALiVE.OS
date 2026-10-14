#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(rallyPoint);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_rallyPoint

Description:
Rally points: places a player (and, for a group leader, the AI of their group) can travel
between. The Rally Points module uses this, and missions can call it themselves.

The list of rally points is kept by the server and sent to everybody (ALiVE_rallyPoints):
adding or removing one from a client is passed to the server. Travel runs on the machine
where the travelling unit is local; the server checks for enemies at both ends first, ALiVE's
virtual groups included.

Parameters:
_this select 0: STRING - operation
_this select 1: ARRAY - arguments

Operations:
"add"     [object, name, side]  a rally point. Name "" uses the object's ALiVE_rallyName
                                variable, else the nearest place's name. Side "ANY" (default),
                                "WEST", "EAST" or "GUER": who may use it.
"remove"  [object]
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

switch (_op) do {

    case "add": {
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        _args params [["_obj", objNull, [objNull]], ["_name", "", [""]], ["_side", "ANY", [""]], ["_kind", "script", [""]], ["_owner", grpNull, [grpNull]]];
        if (isNull _obj) exitWith { _result = false };
        if (_name == "") then { _name = _obj getVariable ["ALiVE_rallyName", ""] };
        if (_name == "") then { _name = [getPosATL _obj] call _autoName };
        private _list = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_x select 0) != _obj} };
        _list pushBack [_obj, _name, toUpper _side, _kind, _owner];
        ALiVE_rallyPoints = _list;
        publicVariable "ALiVE_rallyPoints";
    };

    case "remove": {
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        _args params [["_obj", objNull, [objNull]]];
        ALiVE_rallyPoints = (missionNamespace getVariable ["ALiVE_rallyPoints", []]) select { !isNull (_x select 0) && {(_x select 0) != _obj} };
        publicVariable "ALiVE_rallyPoints";
        // so the module's class scan doesn't bring it back
        ALiVE_rallyRemoved = ((missionNamespace getVariable ["ALiVE_rallyRemoved", []]) select { !isNull _x }) + [_obj];
    };

    // server, from the module's class scan: the objects of the listed classes now on the map. Objects
    // already listed (synced, added by a script) keep their own name and side; one broadcast per change
    case "sync": {
        if (!isServer) exitWith {};
        _args params ["_now", "_side"];
        private _removed = missionNamespace getVariable ["ALiVE_rallyRemoved", []];
        _now = _now select { alive _x && {!(_x in _removed)} };
        private _list = missionNamespace getVariable ["ALiVE_rallyPoints", []];
        private _keep = _list select { !isNull (_x select 0) && {alive (_x select 0)} && {(_x select 3) != "class" || {(_x select 0) in _now}} };
        private _known = _keep apply { _x select 0 };
        private _new = _now select { !(_x in _known) };
        { _keep pushBack [_x, (_x getVariable ["ALiVE_rallyName", ""]) call { if (_this != "") then { _this } else { [getPosATL _x] call _autoName } }, toUpper _side, "class"] } forEach _new;
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
        // a ground holder carrying the backpack is the rally point: a backpack made with createVehicle
        // sits inside a holder of its own and reports a position kilometres away, so the marker went
        // there and deleting it left the holder behind (The Horny Latino on Discord, 14 Oct)
        private _obj = createVehicle ["GroundWeaponHolder", _unit modelToWorld [0, 1.2, 0], [], 0, "CAN_COLLIDE"];
        _obj setDir getDir _unit;
        _obj addBackpackCargoGlobal ["B_Carryall_oli", 1];
        _grp setVariable ["ALiVE_rallyDeployed", _obj, true];
        missionNamespace setVariable [_key, time + (["leaderCooldown", 120] call _set)];
        ["add", [_obj, format [localize "STR_ALIVE_RALLY_LEADER_NAME", groupId _grp], str side _grp, "leader", [_grp, grpNull] select (_mode == "SIDE")]] call ALiVE_fnc_rallyPoint;
        localize "STR_ALIVE_RALLY_UI_DEPLOYED" call _tell;
        [_obj, _grp, _r, ["leaderOverrun", 30] call _set] spawn {
            params ["_obj", "_grp", "_r", "_overrun"];
            private _held = 0;
            while { alive _obj && {!isNull _grp} && {({ alive _x } count units _grp) > 0} && {_held < _overrun} } do {
                sleep 5;
                _held = if ([getPosATL _obj, str side _grp, _r, !isNil "ALIVE_profileHandler"] call ALIVE_fnc_isEnemyNear) then { _held + 5 } else { 0 };
            };
            if (_held >= _overrun && {!isNull _grp}) then {
                [localize "STR_ALIVE_RALLY", localize "STR_ALIVE_RALLY_UI_OVERRUN"] remoteExecCall ["ALIVE_fnc_sendHint", units _grp select { isPlayer _x }];
            };
            ["remove", [_obj]] call ALiVE_fnc_rallyPoint;
            if (!isNull _obj) then { deleteVehicle _obj };
            if (!isNull _grp) then { _grp setVariable ["ALiVE_rallyDeployed", nil, true] };
        };
    };

    case "pickup": {
        _args params [["_unit", objNull, [objNull]]];
        if (!isServer) exitWith { [_op, _args] remoteExecCall ["ALiVE_fnc_rallyPoint", 2] };
        private _grp = group _unit;
        private _obj = _grp getVariable ["ALiVE_rallyDeployed", objNull];
        if (isNull _obj || {leader _grp != _unit}) exitWith { _result = false };
        ["remove", [_obj]] call ALiVE_fnc_rallyPoint;
        deleteVehicle _obj;
        _grp setVariable ["ALiVE_rallyDeployed", nil, true];
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
