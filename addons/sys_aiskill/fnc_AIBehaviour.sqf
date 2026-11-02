#include "\x\alive\addons\sys_aiskill\script_component.hpp"
SCRIPT(AIBehaviour);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_AIBehaviour

Description:
Soldier behaviour for spawned ALiVE groups, run on the machine that owns the group (the
server, or a headless client). A group is attached when its profile spawns: each soldier but
the leader gets a snapshot of what this code may later change (pathing, stance), and a tick
twice a second watches the group. Any change to the group's orders (a new or cleared
waypoint) hands every soldier straight back: the snapshot is put back and the orders are
taken as the new starting point. Nothing here gives a group orders.

Parameters:
String - The operation
Array - Its arguments

Operations:
attach - [group] take the group on, if it qualifies
release - [group, reason] hand every soldier back and stop watching the group
restore - [group, reason] hand every soldier back but keep watching, with the current orders
tick - the per-machine check, from the per-frame handler
orders - [group] how many waypoints the group has and where the last one is
ammoClass - [ammo, magazine] how much a round frightens: 0.15 rifle, 0.3 machine gun, 0.6 explosive
fire - [unit, ammo, magazine, source] a round near or into a soldier raises his threat
threat - [unit] his threat now, 0 to 1, fading 0.05 a second
handBack - [unit] put back what this code changed on one soldier and set him idle
cover - [unit, from] a spot behind something solid on the far side from the fire, or []
nerve - [unit] his tier's timings from the faction lists already picked in the module:
    [take cover above, rise to fire below, seconds down before rising, quiet seconds before handing back]
forget - [unit] hand one soldier back and take this code's handlers and records off him
man - [unit] one soldier's step: idle, to cover, in cover, rising to fire, recovering
setting - [name, default] a module setting, read from the AI Skill module

Returns:
attach - Boolean, whether the group was taken on

Author:
Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], ["_args", [], [[]]]];

private _module = missionNamespace getVariable [QUOTE(ADDON), objNull];
private _result = nil;

switch (_operation) do {

    case "setting": {
        _args params ["_name", "_default"];
        private _v = if (isNull _module) then { _default } else { _module getVariable [_name, _default] };
        if (_v isEqualType "" && {_default isEqualType 0}) then { _v = parseNumber _v };
        if (_v isEqualType "" && {_default isEqualType true}) then { _v = (toLower _v) in ["true", "1"] };
        _result = _v;
    };

    // the group's orders as the tick compares them: how many waypoints, and where the last one is
    case "orders": {
        _args params ["_group"];
        private _n = count waypoints _group;
        // the map position only, rounded: a waypoint on water reports a height that moves with the waves
        _result = [_n, if (_n > 0) then { ((waypointPosition [_group, _n - 1]) select [0, 2]) apply { round _x } } else { [] }];
    };

    case "ammoClass": {
        _args params [["_ammo", "", [""]], ["_mag", "", [""]]];
        if (isNil "ALiVE_AIB_ammoCache") then { ALiVE_AIB_ammoCache = createHashMap };
        private _key = _ammo + "|" + _mag;
        _result = ALiVE_AIB_ammoCache getOrDefault [_key, -1];
        if (_result < 0) then {
            if (_ammo == "" && {_mag != ""}) then { _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo") };
            private _c = configFile >> "CfgAmmo" >> _ammo;
            private _sim = toLower getText (_c >> "simulation");
            private _he = getNumber (_c >> "explosive") > 0.5 || {getNumber (_c >> "indirectHit") > 0} || {_sim in ["shotshell", "shotmissile", "shotrocket", "shotsubmunitions"]};
            private _mg = getNumber (configFile >> "CfgMagazines" >> _mag >> "count") >= 60 || {getNumber (_c >> "caliber") >= 1.4};
            _result = [[0.15, 0.3] select _mg, 0.6] select _he;
            ALiVE_AIB_ammoCache set [_key, _result];
        };
    };

    case "threat": {
        _args params ["_unit"];
        (_unit getVariable ["ALiVE_AIB_threat", [0, time]]) params ["_score", "_at"];
        _result = 0 max (_score - 0.05 * (time - _at));
    };

    case "fire": {
        _args params ["_unit", ["_ammo", ""], ["_mag", ""], ["_source", objNull]];
        if (isNull _unit || {!alive _unit}) exitWith {};
        // fire from his own side doesn't frighten him
        if (!isNull _source && {((side group _unit) getFriend (side group _source)) >= 0.6}) exitWith {};
        private _now = ["threat", [_unit]] call ALiVE_fnc_AIBehaviour;
        private _w = ["ammoClass", [_ammo, _mag]] call ALiVE_fnc_AIBehaviour;
        _unit setVariable ["ALiVE_AIB_threat", [1 min (_now + _w), time]];
        if (!isNull _source) then { _unit setVariable ["ALiVE_AIB_from", [getPosATL _source, _source]] };
    };

    case "attach": {
        _args params [["_group", grpNull, [grpNull]]];
        _result = false;
        if (isNull _group || {!local _group}) exitWith {};
        if !(["setting", ["behaviourEnabled", false]] call ALiVE_fnc_AIBehaviour) exitWith {};
        if (_group getVariable ["ALiVE_AIB_attached", false]) exitWith {};
        if ((units _group) findIf { isPlayer _x } > -1) exitWith {};

        if (isNil "ALiVE_AIB_groups") then { ALiVE_AIB_groups = [] };
        private _cap = ["setting", ["behaviourMaxUnits", 48]] call ALiVE_fnc_AIBehaviour;
        private _have = 0;
        { _have = _have + count (_x getVariable ["ALiVE_AIB_men", []]) } forEach ALiVE_AIB_groups;

        private _leader = leader _group;
        private _men = [];
        {
            if (_have + count _men >= _cap) exitWith {};
            if (_x != _leader && {alive _x} && {vehicle _x == _x} && {!captive _x}
                && {!(_x getVariable ["ALiVE_garrisonHeld", false])} && {_x checkAIFeature "PATH"}) then {
                // he may arrive from another machine still kneeling or moving to cover: put that back
                // from the stance he had before any of it, which travels with him
                private _base = _x getVariable ["ALiVE_AIB_base", []];
                private _carried = _x getVariable ["ALiVE_AIB_carried", []];
                if (_carried isNotEqualTo [] && {_base isNotEqualTo []}) then {
                    _base params ["_path", "_pos"];
                    if ("POS" in _carried) then { _x setUnitPos _pos };
                    if ("MOVE" in _carried) then { _x doFollow _leader };
                    if ("PATH" in _carried && {_path}) then { _x enableAI "PATH" };
                    _x setVariable ["ALiVE_AIB_carried", [], true];
                } else {
                    private _now = [_x checkAIFeature "PATH", unitPos _x];
                    if (_base isNotEqualTo _now) then { _base = _now; _x setVariable ["ALiVE_AIB_base", _now, true] };
                };
                _x setVariable ["ALiVE_AIB_snapshot", _base];
                _x setVariable ["ALiVE_AIB_changed", []];
                _x setVariable ["ALiVE_AIB_threat", [0, time]];
                _x setVariable ["ALiVE_AIB_ehs", [
                    _x addEventHandler ["Suppressed", { params ["_u", "", "_shooter", "", "", "_ammo"]; ["fire", [_u, _ammo, currentMagazine _shooter, _shooter]] call ALiVE_fnc_AIBehaviour }],
                    _x addEventHandler ["Hit", { params ["_u", "_src", "", "_inst"]; private _by = [_src, _inst] select (!isNull _inst); ["fire", [_u, "", currentMagazine _by, _by]] call ALiVE_fnc_AIBehaviour }],
                    _x addEventHandler ["FiredNear", { params ["_u", "_firer", "", "", "", "", "_ammo", "_gunner"]; private _by = [_firer, _gunner] select (!isNull _gunner); ["fire", [_u, _ammo, currentMagazine _by, _by]] call ALiVE_fnc_AIBehaviour }]
                ]];
                _men pushBack _x;
            };
        } forEach (units _group);
        if (_men isEqualTo []) exitWith {};

        _group setVariable ["ALiVE_AIB_attached", true];
        _group setVariable ["ALiVE_AIB_men", _men];
        _group setVariable ["ALiVE_AIB_orders", (["orders", [_group]] call ALiVE_fnc_AIBehaviour)];
        _group setVariable ["ALiVE_AIB_since", time];
        ALiVE_AIB_groups pushBack _group;

        if (isNil "ALiVE_AIB_pfh") then {
            ALiVE_AIB_pfh = [{ ["tick"] call ALiVE_fnc_AIBehaviour }, 0.5] call CBA_fnc_addPerFrameHandler;
        };
        if ((["setting", ["debug", false]] call ALiVE_fnc_AIBehaviour) in [true, 1, "1", "true"]) then {
            ["ALiVE Military AI - soldier behaviour: took on %1 (%2 soldiers, %3 on this machine)", _group, count _men, _have + count _men] call ALiVE_fnc_dump;
        };
        _result = true;
    };

    case "restore": {
        _args params [["_group", grpNull, [grpNull]], ["_reason", ""]];
        { ["handBack", [_x]] call ALiVE_fnc_AIBehaviour } forEach (_group getVariable ["ALiVE_AIB_men", []]);
        _group setVariable ["ALiVE_AIB_orders", (["orders", [_group]] call ALiVE_fnc_AIBehaviour)];
        _group setVariable ["ALiVE_AIB_since", time];
        if ((["setting", ["debug", false]] call ALiVE_fnc_AIBehaviour) in [true, 1, "1", "true"]) then {
            ["ALiVE Military AI - soldier behaviour: %1 handed back (%2)", _group, _reason] call ALiVE_fnc_dump;
        };
    };

    case "handBack": {
        _args params ["_unit"];
        if (isNull _unit) exitWith {};
        private _snap = _unit getVariable ["ALiVE_AIB_snapshot", []];
        // only what this code changed goes back; another system's hold (a garrison) is left alone
        private _changed = _unit getVariable ["ALiVE_AIB_changed", []];
        if (_snap isNotEqualTo []) then {
            _snap params ["_path", "_pos"];
            if (local _unit) then {
                if ("PATH" in _changed && {_path} && {!(_unit checkAIFeature "PATH")}) then { _unit enableAI "PATH" };
                if ("POS" in _changed && {unitPos _unit != _pos}) then { _unit setUnitPos _pos };
                if ("MOVE" in _changed && {alive _unit}) then { _unit doFollow leader _unit };
            } else {
                // he has already moved to another machine: ask that one
                if ("PATH" in _changed && {_path}) then { [_unit, "PATH"] remoteExecCall ["enableAI", _unit] };
                if ("POS" in _changed) then { [_unit, _pos] remoteExecCall ["setUnitPos", _unit] };
                if ("MOVE" in _changed && {alive _unit}) then { [_unit, leader _unit] remoteExecCall ["doFollow", _unit] };
            };
        };
        if (_changed isNotEqualTo []) then { _unit setVariable ["ALiVE_AIB_carried", [], true] };
        _unit setVariable ["ALiVE_AIB_cover", nil];
        _unit setVariable ["ALiVE_AIB_changed", []];
        _unit setVariable ["ALiVE_AIB_state", ["IDLE", time]];
        _unit setVariable ["ALiVE_AIB_engaged", nil];
    };

    case "cover": {
        _args params ["_unit", "_from", ["_src", objNull]];
        _result = [];
        private _pos = getPosATL _unit;
        private _radius = 25;
        private _eye = (ATLToASL _from) vectorAdd [0, 0, 1.5];
        private _best = 1e9;
        {
            private _o = _x;
            private _bb = boundingBoxReal _o;
            private _d = (_bb select 1) vectorDiff (_bb select 0);
            if ((_d select 2) > 0.35 && {((_d select 0) max (_d select 1)) >= 0.6}) then {
                // just behind it, on the line from the fire through it
                private _op = getPosATL _o;
                private _dir = _from getDir _op;
                private _back = (((_d select 0) min (_d select 1)) / 2 + 0.8) min 6;
                private _spot = _op getPos [_back, _dir];
                // a mate already has that spot: try along the cover, a metre and a half either side
                private _taken = ((units group _unit) - [_unit]) apply { _x getVariable ["ALiVE_AIB_cover", [-1e5, -1e5, 0]] };
                {
                    private _try = _spot getPos [_x, _dir + 90];
                    if ((_taken findIf { (_x distance2D _try) < 1.4 }) < 0) exitWith { _spot = _try };
                } forEach [0, 1.5, -1.5, 3, -3];
                _spot set [2, 0];
                private _dist = _unit distance2D _spot;
                if (_dist < _best && {!surfaceIsWater _spot}) then {
                    // something solid between the fire and a kneeling man there
                    private _hits = lineIntersectsSurfaces [_eye, (AGLToASL _spot) vectorAdd [0, 0, 1.0], _unit, vehicle _src, true, 1, "FIRE", "GEOM"];
                    if (_hits isNotEqualTo []) then { _best = _dist; _result = _spot };
                };
            };
        } forEach ((nearestTerrainObjects [_pos, ["WALL", "ROCK", "ROCKS", "BUILDING", "HOUSE", "FENCE", "BUNKER", "FORTRESS", "TREE"], _radius, true, true]) select [0, 16]);
    };

    case "nerve": {
        _args params ["_unit"];
        if (isNil "ALiVE_AIB_nerveCache") then { ALiVE_AIB_nerveCache = createHashMap };
        private _faction = faction _unit;
        _result = ALiVE_AIB_nerveCache getOrDefault [_faction, []];
        if (_result isEqualTo []) then {
            // recruits go to ground sooner, stay down longer and take longer to settle; experts the other way
            private _tiers = [
                ["skillFactionsRecruit", [0.45, 0.15, 6, 30]],
                ["skillFactionsVeteran", [0.65, 0.35, 2.5, 18]],
                ["skillFactionsExpert", [0.7, 0.4, 2, 15]]
            ];
            _result = [0.6, 0.3, 3, 20];
            // the module turns each tier's text into a list when it starts; until then use the middle
            // timings and don't remember them, so the right tier is picked up once it's ready
            private _ready = !isNull _module;
            {
                _x params ["_list", "_nerve"];
                // on a headless client the lists arrive from the server; missing means not yet
                private _in = if (isNull _module) then { "" } else { _module getVariable [_list, ""] };
                if !(_in isEqualType []) then { _ready = false };
                if (_in isEqualType [] && {_faction in _in}) exitWith { _result = _nerve };
            } forEach _tiers;
            if (_ready) then { ALiVE_AIB_nerveCache set [_faction, _result] };
        };
    };

    case "man": {
        _args params ["_unit"];
        (_unit getVariable ["ALiVE_AIB_state", ["IDLE", time]]) params ["_state", "_at"];
        (_unit getVariable ["ALiVE_AIB_threat", [0, time]]) params ["_score", "_lastFire"];
        private _threat = 0 max (_score - 0.05 * (time - _lastFire));
        (_unit getVariable ["ALiVE_AIB_from", [[0, 0, 0], objNull]]) params ["_from", "_src"];
        private _set = { _unit setVariable ["ALiVE_AIB_state", [_this, time]] };
        if (isNil { _unit getVariable "ALiVE_AIB_changed" }) then { _unit setVariable ["ALiVE_AIB_changed", []] };
        private _changed = _unit getVariable "ALiVE_AIB_changed";
        // what he's been changed in travels with him, so another machine can put it back
        private _mark = { if !(_this in _changed) then { _changed pushBack _this; _unit setVariable ["ALiVE_AIB_carried", +_changed, true] } };
        private _engaged = _unit getVariable ["ALiVE_AIB_engaged", -1];
        (["nerve", [_unit]] call ALiVE_fnc_AIBehaviour) params ["_seekAt", "_riseBelow", "_downFor", "_quietFor"];
        // the longest a soldier keeps reacting on his own, and 90 s in any one step
        if (_state != "IDLE" && {(time - _engaged > ALiVE_AIB_maxEngaged) || {time - _at > 90}}) exitWith {
            // and then he stays with his group a while, not straight back down
            _unit setVariable ["ALiVE_AIB_restUntil", time + _quietFor];
            ["handBack", [_unit]] call ALiVE_fnc_AIBehaviour;
        };
        switch (_state) do {
            case "IDLE": {
                // two cover searches a tick at most, the rest wait half a second
                if (_threat > _seekAt && {_from isNotEqualTo [0, 0, 0]} && {ALiVE_AIB_searches < 2} && {time > (_unit getVariable ["ALiVE_AIB_restUntil", 0])}) then {
                    ALiVE_AIB_searches = ALiVE_AIB_searches + 1;
                    private _spot = ["cover", [_unit, _from, _src]] call ALiVE_fnc_AIBehaviour;
                    _unit setVariable ["ALiVE_AIB_engaged", time];
                    if (_spot isNotEqualTo []) then {
                        _unit doMove _spot;
                        "MOVE" call _mark;
                        _unit setVariable ["ALiVE_AIB_cover", _spot];
                        "SEEK_COVER" call _set;
                    } else {
                        // nothing to get behind: get down where he is
                        _unit setUnitPos "DOWN";
                        "POS" call _mark;
                        "IN_COVER" call _set;
                    };
                };
            };
            case "SEEK_COVER": {
                if ((_unit distance2D (_unit getVariable ["ALiVE_AIB_cover", getPosATL _unit])) < 3 || {unitReady _unit}) then {
                    _unit setUnitPos "MIDDLE";
                    "POS" call _mark;
                    "IN_COVER" call _set;
                };
            };
            case "IN_COVER": {
                // quiet long enough: he's done
                if (_threat < 0.05 && {time - _lastFire > _quietFor}) exitWith { "RECOVER" call _set };
                // the fire eases and he knows where it came from: up to shoot back, after a few seconds down
                if (_threat < _riseBelow && {time - _at > _downFor} && {!isNull _src} && {(_unit knowsAbout _src) > 1}) then {
                    _unit setUnitPos "UP";
                    "POS" call _mark;
                    "RISE_FIRE" call _set;
                };
            };
            case "RISE_FIRE": {
                if (_threat > _seekAt || {time - _at > 4}) then {
                    _unit setUnitPos "MIDDLE";
                    "IN_COVER" call _set;
                };
            };
            case "RECOVER": {
                ["handBack", [_unit]] call ALiVE_fnc_AIBehaviour;
            };
        };
        // _changed is the soldier's own list, changed in place: never written back, or a hand-back's
        // clean list would be undone
    };

    case "forget": {
        _args params ["_unit"];
        if (isNull _unit) exitWith {};
        ["handBack", [_unit]] call ALiVE_fnc_AIBehaviour;
        (_unit getVariable ["ALiVE_AIB_ehs", [-1, -1, -1]]) params ["_e1", "_e2", "_e3"];
        if (_e1 >= 0) then { _unit removeEventHandler ["Suppressed", _e1] };
        if (_e2 >= 0) then { _unit removeEventHandler ["Hit", _e2] };
        if (_e3 >= 0) then { _unit removeEventHandler ["FiredNear", _e3] };
        { _unit setVariable [_x, nil] } forEach ["ALiVE_AIB_snapshot", "ALiVE_AIB_changed", "ALiVE_AIB_ehs", "ALiVE_AIB_threat",
            "ALiVE_AIB_state", "ALiVE_AIB_from", "ALiVE_AIB_cover", "ALiVE_AIB_engaged", "ALiVE_AIB_restUntil"];
    };

    case "release": {
        _args params [["_group", grpNull, [grpNull]], ["_reason", ""]];
        if (!isNull _group) then {
            ["restore", [_group, _reason]] call ALiVE_fnc_AIBehaviour;
            { ["forget", [_x]] call ALiVE_fnc_AIBehaviour } forEach (_group getVariable ["ALiVE_AIB_men", []]);
            _group setVariable ["ALiVE_AIB_attached", nil];
            _group setVariable ["ALiVE_AIB_men", nil];
        };
        ALiVE_AIB_groups = ALiVE_AIB_groups - [_group];
    };

    case "tick": {
        if (isNil "ALiVE_AIB_groups") exitWith {};
        private _t0 = diag_tickTime;
        ALiVE_AIB_maxEngaged = ["setting", ["behaviourMaxEngaged", 180]] call ALiVE_fnc_AIBehaviour;
        ALiVE_AIB_searches = 0;
        {
            private _group = _x;
            switch (true) do {
                // gone (despawned)
                case (isNull _group): {
                    ALiVE_AIB_groups deleteAt (ALiVE_AIB_groups find _group);
                };
                // moved to another machine: let go here, the new owner takes it on
                case (!local _group): {
                    ["release", [_group, "moved to another machine"]] call ALiVE_fnc_AIBehaviour;
                };
                case ((units _group) findIf { isPlayer _x } > -1): {
                    ["release", [_group, "a player joined"]] call ALiVE_fnc_AIBehaviour;
                };
                default {
                    // dropped: dead, moved, held by another system (a garrison turns pathing off), or now
                    // the leader, who keeps the group on its orders
                    private _all = _group getVariable ["ALiVE_AIB_men", []];
                    private _lead = leader _group;
                    private _men = _all select {
                        !isNull _x && {alive _x} && {local _x} && {_x != _lead} && {!(_x getVariable ["ALiVE_garrisonHeld", false])}
                        && {(_x checkAIFeature "PATH") || {"PATH" in (_x getVariable ["ALiVE_AIB_changed", []])}}
                    };
                    { ["forget", [_x]] call ALiVE_fnc_AIBehaviour } forEach (_all - _men);
                    _group setVariable ["ALiVE_AIB_men", _men];
                    if (_men isEqualTo []) then {
                        ["release", [_group, "nobody left to look after"]] call ALiVE_fnc_AIBehaviour;
                    } else {
                        // new orders: hand every soldier back, then carry on from them
                        private _orders = (["orders", [_group]] call ALiVE_fnc_AIBehaviour);
                        if (_orders isNotEqualTo (_group getVariable ["ALiVE_AIB_orders", []])) then {
                            ["restore", [_group, "new orders"]] call ALiVE_fnc_AIBehaviour;
                        } else {
                            { ["man", [_x]] call ALiVE_fnc_AIBehaviour } forEach _men;
                        };
                    };
                };
            };
        } forEach +ALiVE_AIB_groups;
        // [ticks, total ms, worst ms] for the debug line and tests
        private _ms = (diag_tickTime - _t0) * 1000;
        if (isNil "ALiVE_AIB_perf") then { ALiVE_AIB_perf = [0, 0, 0] };
        ALiVE_AIB_perf set [0, (ALiVE_AIB_perf select 0) + 1];
        ALiVE_AIB_perf set [1, (ALiVE_AIB_perf select 1) + _ms];
        ALiVE_AIB_perf set [2, (ALiVE_AIB_perf select 2) max _ms];
    };
};

if (!isNil "_result") then { _result } else { nil }
