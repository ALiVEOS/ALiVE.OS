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
        if (_v isEqualType "" && {_default isEqualType true}) then { _v = toLower _v == "true" };
        _result = _v;
    };

    // the group's orders as the tick compares them: how many waypoints, and where the last one is
    case "orders": {
        _args params ["_group"];
        private _n = count waypoints _group;
        _result = [_n, if (_n > 0) then { waypointPosition [_group, _n - 1] } else { [] }];
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
                _x setVariable ["ALiVE_AIB_snapshot", [_x checkAIFeature "PATH", unitPos _x]];
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
        {
            private _snap = _x getVariable ["ALiVE_AIB_snapshot", []];
            // only what this code changed goes back; another system's hold (a garrison) is left alone
            private _changed = _x getVariable ["ALiVE_AIB_changed", []];
            if (!isNull _x && {_snap isNotEqualTo []}) then {
                _snap params ["_path", "_pos"];
                if ("PATH" in _changed && {_path} && {!(_x checkAIFeature "PATH")}) then { _x enableAI "PATH" };
                if ("POS" in _changed && {unitPos _x != _pos}) then { _x setUnitPos _pos };
                _x setVariable ["ALiVE_AIB_changed", []];
            };
        } forEach (_group getVariable ["ALiVE_AIB_men", []]);
        _group setVariable ["ALiVE_AIB_orders", (["orders", [_group]] call ALiVE_fnc_AIBehaviour)];
        _group setVariable ["ALiVE_AIB_since", time];
        if ((["setting", ["debug", false]] call ALiVE_fnc_AIBehaviour) in [true, 1, "1", "true"]) then {
            ["ALiVE Military AI - soldier behaviour: %1 handed back (%2)", _group, _reason] call ALiVE_fnc_dump;
        };
    };

    case "release": {
        _args params [["_group", grpNull, [grpNull]], ["_reason", ""]];
        if (!isNull _group) then {
            ["restore", [_group, _reason]] call ALiVE_fnc_AIBehaviour;
            {
                if (!isNull _x) then {
                    (_x getVariable ["ALiVE_AIB_ehs", [-1, -1, -1]]) params ["_e1", "_e2", "_e3"];
                    if (_e1 >= 0) then { _x removeEventHandler ["Suppressed", _e1] };
                    if (_e2 >= 0) then { _x removeEventHandler ["Hit", _e2] };
                    if (_e3 >= 0) then { _x removeEventHandler ["FiredNear", _e3] };
                    _x setVariable ["ALiVE_AIB_snapshot", nil]; _x setVariable ["ALiVE_AIB_changed", nil];
                    _x setVariable ["ALiVE_AIB_ehs", nil]; _x setVariable ["ALiVE_AIB_threat", nil];
                };
            } forEach (_group getVariable ["ALiVE_AIB_men", []]);
            _group setVariable ["ALiVE_AIB_attached", nil];
            _group setVariable ["ALiVE_AIB_men", nil];
        };
        ALiVE_AIB_groups = ALiVE_AIB_groups - [_group];
    };

    case "tick": {
        if (isNil "ALiVE_AIB_groups") exitWith {};
        {
            private _group = _x;
            // a soldier another system has taken hold of since (a garrison turns pathing off) is dropped
            private _men = (_group getVariable ["ALiVE_AIB_men", []]) select {
                !isNull _x && {alive _x} && {local _x} && {!(_x getVariable ["ALiVE_garrisonHeld", false])}
                && {(_x checkAIFeature "PATH") || {"PATH" in (_x getVariable ["ALiVE_AIB_changed", []])}}
            };
            switch (true) do {
                // gone (despawned, all dead) or moved to another machine
                case (isNull _group || {_men isEqualTo []}): {
                    ALiVE_AIB_groups deleteAt (ALiVE_AIB_groups find _group);
                };
                case ((units _group) findIf { isPlayer _x } > -1): {
                    ["release", [_group, "a player joined"]] call ALiVE_fnc_AIBehaviour;
                };
                default {
                    _group setVariable ["ALiVE_AIB_men", _men];
                    // new orders: hand every soldier back, then carry on from them
                    private _orders = (["orders", [_group]] call ALiVE_fnc_AIBehaviour);
                    if (_orders isNotEqualTo (_group getVariable ["ALiVE_AIB_orders", []])) then {
                        ["restore", [_group, "new orders"]] call ALiVE_fnc_AIBehaviour;
                    };
                };
            };
        } forEach +ALiVE_AIB_groups;
    };
};

if (!isNil "_result") then { _result } else { nil }
