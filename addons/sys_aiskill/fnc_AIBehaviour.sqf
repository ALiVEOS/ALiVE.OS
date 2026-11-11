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
profile - [feet ASL, from, ignore, ignore] the stance that hides a man standing there from the fire and
    the one he can fire from over it: [down, up], up "" if nothing clears the cover, [] if nothing hides him
cover - [unit, from, source] the best spot behind something solid on the far side from the fire:
    [spot, kind, step-out spot, down, up] or []. Kind "over": he can fire over it (a wall, a sill, a rock,
    sandbags); "around": a step to one side clears it (a corner, the end of a wall, a tree); "full": it
    only hides him
nerve - [unit] his tier's timings from the faction lists already picked in the module:
    [take cover above, seconds down before the first peek, quiet seconds before handing back,
    seconds between peeks from, to]
toPost, toMove - [unit] a garrison has put him on a post, or let him off one
forget - [unit] hand one soldier back and take this code's handlers and records off him
man - [unit] one soldier's step: idle, to cover, in cover, peeking to fire, recovering
setting - [name, default] a module setting, read from the AI Skill module
share - [group] pass the enemies its leader has a good fix on to friendly groups near it, at a capped
    knowledge: each gets min(1, what the sender knows) * (1 - what it knows / 1.5), never above 1.5

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
            // a man held at a garrison post is taken on too, for his stance only
            private _held = _x getVariable ["ALiVE_garrisonHeld", false];
            if (_x != _leader && {alive _x} && {vehicle _x == _x} && {!captive _x} && {_held || {_x checkAIFeature "PATH"}}) then {
                _x setVariable ["ALiVE_AIB_kind", ["move", "post"] select _held];
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
        // a post soldier the garrison has since let go: the garrison put his stance back itself
        if ((_unit getVariable ["ALiVE_AIB_kind", "move"]) == "post" && {!(_unit getVariable ["ALiVE_garrisonHeld", false])}) then { _snap = [] };
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
        { _unit setVariable [_x, nil] } forEach ["ALiVE_AIB_cover", "ALiVE_AIB_tries", "ALiVE_AIB_stepBack", "ALiVE_AIB_nudges"];
        _unit setVariable ["ALiVE_AIB_changed", []];
        _unit setVariable ["ALiVE_AIB_state", ["IDLE", time]];
        _unit setVariable ["ALiVE_AIB_engaged", nil];
    };

    case "profile": {
        _args params ["_feet", "_from", ["_ign1", objNull], ["_ign2", objNull]];
        private _eye = (ATLToASL _from) vectorAdd [0, 0, 1.5];
        private _hid = { (lineIntersectsSurfaces [_eye, _feet vectorAdd [0, 0, _this], _ign1, _ign2, true, 1, "FIRE", "GEOM"]) isNotEqualTo [] };
        // a standing, kneeling and prone man's head
        // (something overhead can block the standing line and miss the kneeling one: hidden kneeling
        // needs the kneeling line blocked)
        _result = switch (true) do {
            case (1.1 call _hid): { [["MIDDLE", "UP"], ["MIDDLE", ""]] select (1.6 call _hid) };
            case (0.4 call _hid): { ["DOWN", "MIDDLE"] };
            default { [] };
        };
    };

    case "cover": {
        _args params ["_unit", "_from", ["_src", objNull]];
        _result = [];
        private _pos = getPosATL _unit;
        private _radius = 25;
        private _ign = vehicle _src;
        private _eye = (ATLToASL _from) vectorAdd [0, 0, 1.5];
        private _best = 1e9;
        private _cands = [];
        private _taken = ((units group _unit) - [_unit]) apply { (_x getVariable ["ALiVE_AIB_cover", [[-1e5, -1e5, 0]]]) select 0 };
        // the map's own walls, rocks, trees and buildings, and anything placed since (sandbags, a FOB's
        // walls, a mission's compositions); the nearest 16
        private _near = nearestTerrainObjects [_pos, ["WALL", "ROCK", "ROCKS", "BUILDING", "HOUSE", "FENCE", "BUNKER", "FORTRESS", "TREE"], _radius, false, true];
        _near append ((nearestObjects [_pos, ["Static"], _radius, true]) - _near);
        _near = _near apply { [_pos distance2D _x, _x] };
        _near sort true;
        _near = (_near select [0, 16]) apply { _x select 1 };
        {
            private _o = _x;
            private _bb = boundingBoxReal _o;
            private _d = (_bb select 1) vectorDiff (_bb select 0);
            private _wide = (_d select 0) max (_d select 1);
            if ((_d select 2) > 0.35 && {_wide >= 0.6}) then {
                // just behind it, on the line from the fire through it; for something tall and wide, its two
                // ends as well, where a man can step out past it
                // (its size is in its own axes: a wall end-on to the fire is long, not thin, to get behind)
                private _op = getPosATL _o;
                private _dir = _from getDir _op;
                private _m = _o vectorWorldToModel [sin _dir, cos _dir, 0];
                private _back = ((abs (_m select 0)) * (_d select 0) / 2 + (abs (_m select 1)) * (_d select 1) / 2 + 0.8) min 6;
                private _ax = _o vectorModelToWorld ([[0, 1, 0], [1, 0, 0]] select ((_d select 0) >= (_d select 1)));
                private _along = (_ax select 0) atan2 (_ax select 1);
                private _mid = _op getPos [_back, _dir];
                private _spots = [_mid];
                if ((_d select 2) > 1.6 && {_wide >= 2}) then {
                    _spots pushBack (_mid getPos [(_wide / 2 - 0.6) max 0.5, _along]);
                    _spots pushBack (_mid getPos [(_wide / 2 - 0.6) max 0.5, _along + 180]);
                };
                {
                    private _spot = _x;
                    // a mate already has that spot: try along the cover, a metre and a half either side
                    {
                        private _try = _spot getPos [_x, _along];
                        if ((_taken findIf { (_x distance2D _try) < 1.4 }) < 0) exitWith { _spot = _try };
                    } forEach [0, 1.5, -1.5, 3, -3];
                    _spot set [2, 0];
                    if (!surfaceIsWater _spot) then { _cands pushBack [_unit distance2D _spot, count _cands, _spot, _dir] };
                } forEach _spots;
            };
        } forEach _near;
        // nearest first, and done once no spot left can beat the best (a score is never under its distance)
        _cands sort true;
        {
            _x params ["_dist", "", "_spot", "_dir"];
            if (_dist >= _best) exitWith {};
            private _prof = ["profile", [AGLToASL _spot, _from, _unit, _ign]] call ALiVE_fnc_AIBehaviour;
            if (_prof isNotEqualTo []) then {
                _prof params ["_down", "_up"];
                private _kind = ["over", "full"] select (_up == "");
                private _step = [];
                if (_kind == "full") then {
                    {
                        private _try = _spot getPos [1.6, _dir + _x];
                        if (!surfaceIsWater _try && {(lineIntersectsSurfaces [_eye, (AGLToASL _try) vectorAdd [0, 0, 1.1], _unit, _ign, true, 1, "FIRE", "GEOM"]) isEqualTo []})
                            exitWith {
                                _kind = "around"; _step = _try; _up = "MIDDLE";
                                // a little further in: a man stops short of where he's sent, and
                                // short of a corner spot is out in the open
                                _spot = _spot getPos [0.4, _try getDir _spot];
                            };
                    } forEach [90, -90];
                };
                // a spot he can fire from is worth a few metres more running; over a wall standing,
                // then over it kneeling, then around it, then only hiding
                private _score = _dist + ([[0, 2] select (_down == "DOWN"), 4, 8] select (["over", "around", "full"] find _kind));
                if (_score < _best) then { _best = _score; _result = [_spot, _kind, _step, _down, _up] };
            };
        } forEach _cands;
    };

    case "nerve": {
        _args params ["_unit"];
        if (isNil "ALiVE_AIB_nerveCache") then { ALiVE_AIB_nerveCache = createHashMap };
        private _faction = faction _unit;
        _result = ALiVE_AIB_nerveCache getOrDefault [_faction, []];
        if (_result isEqualTo []) then {
            // recruits go to ground sooner, stay down longer, peek less and take longer to settle;
            // experts the other way
            private _tiers = [
                ["skillFactionsRecruit", [0.45, 6, 30, 10, 14]],
                ["skillFactionsVeteran", [0.65, 2.5, 18, 4, 8]],
                ["skillFactionsExpert", [0.7, 2, 15, 3, 6]]
            ];
            _result = [0.6, 3, 20, 6, 10];
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

    case "toPost": {
        _args params ["_unit"];
        // whatever he was doing is the garrison's business now: nothing of ours is put back over it
        if ((_unit getVariable ["ALiVE_AIB_changed", []]) isNotEqualTo []) then { _unit setVariable ["ALiVE_AIB_carried", [], true] };
        private _now = [_unit checkAIFeature "PATH", unitPos _unit];
        _unit setVariable ["ALiVE_AIB_base", _now, true];
        _unit setVariable ["ALiVE_AIB_snapshot", _now];
        _unit setVariable ["ALiVE_AIB_changed", []];
        _unit setVariable ["ALiVE_AIB_kind", "post"];
        { _unit setVariable [_x, nil] } forEach ["ALiVE_AIB_cover", "ALiVE_AIB_engaged", "ALiVE_AIB_tries", "ALiVE_AIB_stepBack", "ALiVE_AIB_nudges", "ALiVE_AIB_nextPeek", "ALiVE_AIB_peekFor"];
        _unit setVariable ["ALiVE_AIB_state", ["IDLE", time]];
    };

    case "toMove": {
        _args params ["_unit"];
        // let off his post (the garrison stood him back up itself): a soldier on his feet from here
        if ((_unit getVariable ["ALiVE_AIB_changed", []]) isNotEqualTo []) then { _unit setVariable ["ALiVE_AIB_carried", [], true] };
        private _now = [_unit checkAIFeature "PATH", unitPos _unit];
        _unit setVariable ["ALiVE_AIB_base", _now, true];
        _unit setVariable ["ALiVE_AIB_snapshot", _now];
        _unit setVariable ["ALiVE_AIB_changed", []];
        _unit setVariable ["ALiVE_AIB_kind", "move"];
        { _unit setVariable [_x, nil] } forEach ["ALiVE_AIB_cover", "ALiVE_AIB_engaged", "ALiVE_AIB_tries", "ALiVE_AIB_stepBack", "ALiVE_AIB_nudges", "ALiVE_AIB_nextPeek", "ALiVE_AIB_peekFor"];
        _unit setVariable ["ALiVE_AIB_state", ["IDLE", time]];
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
        (["nerve", [_unit]] call ALiVE_fnc_AIBehaviour) params ["_seekAt", "_downFor", "_quietFor", "_coolMin", "_coolMax"];
        private _post = (_unit getVariable ["ALiVE_AIB_kind", "move"]) == "post";
        private _rank = { ["DOWN", "MIDDLE", "UP"] find (toUpper _this) };
        // the longest a soldier keeps reacting on his own, and 90 s in any one step
        if (_state != "IDLE" && {(time - _engaged > ALiVE_AIB_maxEngaged) || {time - _at > 90}}) exitWith {
            // and then he stays with his group a while, not straight back down
            _unit setVariable ["ALiVE_AIB_restUntil", time + _quietFor];
            ["handBack", [_unit]] call ALiVE_fnc_AIBehaviour;
        };
        switch (_state) do {
            case "IDLE": {
                if (_threat > _seekAt && {_from isNotEqualTo [0, 0, 0]} && {time > (_unit getVariable ["ALiVE_AIB_restUntil", 0])}) then {
                    if (_post) then {
                        // held at a post: he only gets his head down, if a lower stance than the garrison's
                        // hides him there, and comes back up to the garrison's stance to fire
                        private _base = (_unit getVariable ["ALiVE_AIB_snapshot", [false, "UP"]]) select 1;
                        if ((_base call _rank) < 0) then { _base = "UP" };
                        private _prof = ["profile", [getPosASL _unit, _from, _unit, vehicle _src]] call ALiVE_fnc_AIBehaviour;
                        // only if the fire can reach him as the garrison stood him, and something lower hides him
                        if (_prof isEqualTo [] || {(_prof select 1) == ""} || {((_prof select 1) call _rank) > (_base call _rank)}) exitWith {
                            _unit setVariable ["ALiVE_AIB_restUntil", time + 10];
                        };
                        _unit setVariable ["ALiVE_AIB_engaged", time];
                        _unit setUnitPos (_prof select 0);
                        "POS" call _mark;
                        _unit setVariable ["ALiVE_AIB_cover", [getPosATL _unit, "over", [], _prof select 0, _base]];
                        "IN_COVER" call _set;
                    } else {
                        // a cover search costs about a millisecond: one a tick, a second only if the tick is
                        // still under a millisecond, and the rest wait half a second
                        if (ALiVE_AIB_searches >= 2 || {ALiVE_AIB_searches == 1 && {diag_tickTime - ALiVE_AIB_t0 > 0.001}}) exitWith {};
                        ALiVE_AIB_searches = ALiVE_AIB_searches + 1;
                        private _c = ["cover", [_unit, _from, _src]] call ALiVE_fnc_AIBehaviour;
                        _unit setVariable ["ALiVE_AIB_engaged", time];
                        if (_c isNotEqualTo []) then {
                            _unit doMove (_c select 0);
                            "MOVE" call _mark;
                            _unit setVariable ["ALiVE_AIB_cover", _c];
                            "SEEK_COVER" call _set;
                        } else {
                            // nothing to get behind: get down where he is
                            _unit setUnitPos "DOWN";
                            "POS" call _mark;
                            _unit setVariable ["ALiVE_AIB_cover", [getPosATL _unit, "none", [], "DOWN", ""]];
                            "IN_COVER" call _set;
                        };
                    };
                };
            };
            case "SEEK_COVER": {
                private _c = _unit getVariable ["ALiVE_AIB_cover", [getPosATL _unit, "none", [], "DOWN", ""]];
                private _far = _unit distance2D (_c select 0);
                // the game reports a move done almost as soon as it's given, so only being there counts; one
                // who has stopped short is sent again, twice, and then gets down where he is; so does one
                // still not there after 15 s, whatever the game says about his move
                if (_far >= 1.5 && {time - _at > 3} && {unitReady _unit || {time - _at > 15}}) then {
                    private _tries = [_unit getVariable ["ALiVE_AIB_tries", 0], 2] select (time - _at > 15);
                    if (_tries < 2) then {
                        _unit setVariable ["ALiVE_AIB_tries", _tries + 1];
                        _unit doMove (_c select 0);
                    } else {
                        _c set [0, getPosATL _unit];
                        _c set [1, "none"];
                        _far = 0;
                    };
                };
                if (_far < 1.5) then {
                    _unit setVariable ["ALiVE_AIB_tries", nil];
                    // he stays there until handed back: stopped, and with his pathing off, or the game's own
                    // combat moves walk him off after his leader (the garrison holds its men the same way)
                    doStop _unit;
                    _unit disableAI "PATH";
                    "PATH" call _mark;
                    // where he has actually stopped decides how low he gets and what he can fire from
                    private _prof = ["profile", [getPosASL _unit, _from, _unit, vehicle _src]] call ALiVE_fnc_AIBehaviour;
                    if (_prof isEqualTo []) then { _prof = ["DOWN", ""] };
                    if ((_c select 1) == "around") then {
                        _c set [3, _prof select 0];
                        // stopped up to a metre and a half off a corner spot can be the open side of it
                        _unit setVariable ["ALiVE_AIB_stepBack", true];
                    } else {
                        _c set [1, ["over", "full"] select ((_prof select 1) == "")];
                        _c set [3, _prof select 0];
                        _c set [4, _prof select 1];
                    };
                    _unit setUnitPos (_c select 3);
                    "POS" call _mark;
                    "IN_COVER" call _set;
                };
            };
            case "IN_COVER": {
                // back from a step out past a corner: hold there again
                // (being there is what counts: the game calls a move done before he's taken a step)
                if (!_post && {_unit getVariable ["ALiVE_AIB_stepBack", false]} && {time - _at > 4 || {(_unit distance2D ((_unit getVariable ["ALiVE_AIB_cover", [getPosATL _unit]]) select 0)) < 0.8}}) then {
                    _unit setVariable ["ALiVE_AIB_stepBack", nil];
                    doStop _unit;
                    _unit disableAI "PATH";
                    "PATH" call _mark;
                    // still in sight where he stopped: a metre further in, twice at most, then down flat
                    private _crec = _unit getVariable ["ALiVE_AIB_cover", [getPosATL _unit, "around", [], "MIDDLE", "MIDDLE"]];
                    _crec params ["_cs", "", "_cstep", "_clow"];
                    private _prof = ["profile", [getPosASL _unit, _from, _unit, vehicle _src]] call ALiVE_fnc_AIBehaviour;
                    if (_prof isEqualTo [] || {((_prof select 0) call _rank) < (_clow call _rank)}) then {
                        private _n = _unit getVariable ["ALiVE_AIB_nudges", 0];
                        if (_n < 2 && {_cstep isNotEqualTo []}) then {
                            _unit setVariable ["ALiVE_AIB_nudges", _n + 1];
                            _unit enableAI "PATH";
                            private _to = (getPosATL _unit) getPos [1.5, _cstep getDir _cs];
                            _unit doMove _to;
                            _unit setVariable ["ALiVE_AIB_stepBack", true];
                            "IN_COVER" call _set;
                        } else {
                            _unit setUnitPos "DOWN";
                            _crec set [3, "DOWN"];
                        };
                    } else {
                        _unit setVariable ["ALiVE_AIB_nudges", nil];
                    };
                };
                // quiet long enough: he's done
                if (_threat < 0.05 && {time - _lastFire > _quietFor}) exitWith { "RECOVER" call _set };
                (_unit getVariable ["ALiVE_AIB_cover", [[], "none", [], "DOWN", ""]]) params ["_spot", "_kind", "_step", "_low", "_up"];
                // the fire has eased and his time is up: a look and a few shots, over or around his cover
                if (_kind in ["over", "around"] && {_threat < _seekAt} && {time - _at > _downFor}
                    && {time > (_unit getVariable ["ALiVE_AIB_nextPeek", 0])} && {!(_unit getVariable ["ALiVE_AIB_stepBack", false])}) then {
                    // a soldier told to move a metre stops half a metre short, so the step out is ordered a
                    // couple of metres to the side of where he actually is
                    if (_kind == "around") then { _unit enableAI "PATH"; _unit doMove ((getPosATL _unit) getPos [2.6, _spot getDir _step]); "MOVE" call _mark } else { _unit setUnitPos _up; "POS" call _mark };
                    _unit setVariable ["ALiVE_AIB_peekFor", 2 + random 3];
                    "PEEK" call _set;
                };
            };
            case "PEEK": {
                // back down when his look is over, or at once if the fire picks up
                if (_threat > _seekAt || {time - _at > (_unit getVariable ["ALiVE_AIB_peekFor", 3])}) then {
                    (_unit getVariable ["ALiVE_AIB_cover", [getPosATL _unit, "over", [], "MIDDLE", "UP"]]) params ["_spot", "_kind", "_step", "_low"];
                    // back past a corner: sent a little beyond his spot, so stopping short still leaves him behind it
                    if (_kind == "around") then { _unit doMove (_spot getPos [0.7, _step getDir _spot]); _unit setVariable ["ALiVE_AIB_stepBack", true] } else { _unit setUnitPos _low };
                    _unit setVariable ["ALiVE_AIB_nextPeek", time + _coolMin + random (_coolMax - _coolMin)];
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
            "ALiVE_AIB_state", "ALiVE_AIB_from", "ALiVE_AIB_cover", "ALiVE_AIB_engaged", "ALiVE_AIB_restUntil",
            "ALiVE_AIB_kind", "ALiVE_AIB_peekFor", "ALiVE_AIB_nextPeek", "ALiVE_AIB_tries", "ALiVE_AIB_stepBack", "ALiVE_AIB_nudges"];
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

    case "share": {
        _args params ["_group"];
        private _range = ALiVE_AIB_shareRange;
        private _leader = leader _group;
        if (_range <= 0 || {isNull _leader} || {!alive _leader}) exitWith {};
        private _side = side _group;
        private _known = (_leader targets [true, 1000]) select { (_leader knowsAbout _x) >= 1.5 };
        if (_known isEqualTo []) exitWith {};
        private _near = ALiVE_AIB_groups select {
            _x != _group && {!isNull _x} && {side _x == _side} && {!isNull leader _x} && {((leader _x) distance _leader) < _range}
        };
        private _given = 0;
        {
            private _rg = _x;
            private _rl = leader _rg;
            {
                private _has = _rl knowsAbout _x;
                private _give = (1 min (_leader knowsAbout _x)) * (1 - (_has / 1.5));
                if (_give > 0.05) then {
                    _rg reveal [_x, 1.5 min (_has + _give)];
                    _given = _given + 1;
                };
            } forEach _known;
        } forEach _near;
        if (_given > 0 && {(["setting", ["debug", false]] call ALiVE_fnc_AIBehaviour) in [true, 1, "1", "true"]}) then {
            ["ALiVE Military AI - soldier behaviour: %1 passed %2 enemies to %3 groups (%4 in all)", _group, count _known, count _near, _given] call ALiVE_fnc_dump;
        };
    };

    case "tick": {
        if (isNil "ALiVE_AIB_groups") exitWith {};
        private _t0 = diag_tickTime;
        ALiVE_AIB_maxEngaged = ["setting", ["behaviourMaxEngaged", 180]] call ALiVE_fnc_AIBehaviour;
        ALiVE_AIB_searches = 0;
        ALiVE_AIB_t0 = _t0;
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
                    // dropped: dead, moved, in a vehicle, now the leader (who keeps the group on its orders), or
                    // held by some other system that turned his pathing off. A garrison post is followed instead:
                    // put on one, he keeps only his stance moves; let off one, he's a soldier on his feet again
                    private _all = _group getVariable ["ALiVE_AIB_men", []];
                    private _lead = leader _group;
                    private _men = [];
                    {
                        private _u = _x;
                        if (!isNull _u && {alive _u} && {local _u} && {_u != _lead} && {vehicle _u == _u}) then {
                            private _held = _u getVariable ["ALiVE_garrisonHeld", false];
                            private _post = (_u getVariable ["ALiVE_AIB_kind", "move"]) == "post";
                            private _path = _u checkAIFeature "PATH";
                            switch (true) do {
                                case (_held && {!_post}): { ["toPost", [_u]] call ALiVE_fnc_AIBehaviour; _men pushBack _u };
                                case (!_held && {_post}): { if (_path) then { ["toMove", [_u]] call ALiVE_fnc_AIBehaviour }; _men pushBack _u };
                                case (_post || {_path} || {"PATH" in (_u getVariable ["ALiVE_AIB_changed", []])}): { _men pushBack _u };
                            };
                        };
                    } forEach _all;
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
        // Groups pass what they know about the enemy to friendly groups near them: two groups a tick, and each at
        // most once every 20 seconds, so a large fight costs the same as a small one
        ALiVE_AIB_shareRange = ["setting", ["behaviourShareRange", 300]] call ALiVE_fnc_AIBehaviour;
        if (ALiVE_AIB_shareRange > 0) then {
            private _count = count ALiVE_AIB_groups;
            if (isNil "ALiVE_AIB_shareNext") then { ALiVE_AIB_shareNext = 0 };
            for "_i" from 1 to (2 min _count) do {
                if (ALiVE_AIB_shareNext >= _count) then { ALiVE_AIB_shareNext = 0 };
                private _g = ALiVE_AIB_groups select ALiVE_AIB_shareNext;
                ALiVE_AIB_shareNext = ALiVE_AIB_shareNext + 1;
                if (!isNull _g && {local _g} && {time >= (_g getVariable ["ALiVE_AIB_sharedAt", -20]) + 20}) then {
                    _g setVariable ["ALiVE_AIB_sharedAt", time];
                    ["share", [_g]] call ALiVE_fnc_AIBehaviour;
                };
            };
        };
        // [ticks, total ms, worst ms] for the debug line and tests
        private _ms = (diag_tickTime - _t0) * 1000;
        if (isNil "ALiVE_AIB_perf") then { ALiVE_AIB_perf = [0, 0, 0] };
        ALiVE_AIB_perf set [0, (ALiVE_AIB_perf select 0) + 1];
        ALiVE_AIB_perf set [1, (ALiVE_AIB_perf select 1) + _ms];
        ALiVE_AIB_perf set [2, (ALiVE_AIB_perf select 2) max _ms];
    };
};

if (!isNil "_result") then { _result } else { nil }
