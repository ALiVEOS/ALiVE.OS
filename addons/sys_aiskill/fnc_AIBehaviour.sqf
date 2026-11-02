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
            { if (!isNull _x) then { _x setVariable ["ALiVE_AIB_snapshot", nil]; _x setVariable ["ALiVE_AIB_changed", nil] } } forEach (_group getVariable ["ALiVE_AIB_men", []]);
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
