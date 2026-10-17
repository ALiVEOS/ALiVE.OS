#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileActivatorAirDefence);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileActivatorAirDefence

Description:
Air defence activator. Anti-air left virtual can't touch an aircraft that is
flying for real, and nothing spawned it for an AI Commander's aircraft (MACC)
with no player near (A. Ares on Discord, 17 Oct). While any MACC aircraft is
airborne, this spawns the enemy anti-air vehicles within the wake radius of it,
with their crews, so they can engage it; nothing else round the aircraft is
spawned. Once no enemy aircraft is near they are let go and despawn the usual
way.

The aircraft come from ALiVE_ATO_airborne, which each MACC kernel fills on its
roster tick (hashmap of commander -> [[object, side text], ...]) and empties
when it pauses or stops. Claims are worked out every 2 seconds, and a site
stays up for 90 seconds after the last aircraft leaves its reach, so a jet
circling at the edge doesn't spawn and despawn it on every pass. The list of
anti-air vehicle profiles is rebuilt every minute. Like anything else that is
spawned, it waits for room under the Active Limiter.

Parameters:
HashMap - Activator instance, or nil for create
String - Operation
Any - Operation arguments

Returns:
Any

Author:
Jman
---------------------------------------------------------------------------- */

#define MAINCLASS ALiVE_fnc_profileActivatorAirDefence

#define AIR_DEFENCE_DEFAULT_RADIUS 4000
#define AIR_DEFENCE_HOLD_FACTOR 1.25
#define AIR_DEFENCE_CLAIM_INTERVAL 2
#define AIR_DEFENCE_LIST_INTERVAL 60
#define AIR_DEFENCE_GRACE 90

params [
    "_logic",
    ["_operation", ""],
    ["_args", []]
];
private _result = nil;

switch (_operation) do {
    case "create": {
        _args params [["_radius", AIR_DEFENCE_DEFAULT_RADIUS]];

        _result = createHashMapFromArray [
            ["id", "airDefence"],
            ["implementation", MAINCLASS],
            ["iteration", 0],
            ["radius", _radius max 0],
            ["wasActive", false],
            ["claims", []],
            ["claimsAt", -1e9],
            ["candidates", []],
            ["candidatesAt", -1e9],
            ["lastSeen", createHashMap]
        ];
    };

    case "tick": {
        private _iteration = _logic get "iteration";
        private _now = time;

        // between claim passes, hold the last set without looking at anything
        if ((_logic get "wasActive") && {_now - (_logic get "claimsAt") < AIR_DEFENCE_CLAIM_INTERVAL}) exitWith {
            _result = [_logic get "id", _iteration, true, _logic get "claims", false];
        };

        // the enemy's eyes in the sky: every live MACC aircraft that is airborne
        private _sources = [];
        {
            {
                _x params ["_object", "_side"];
                if (!isNull _object && {alive _object}) then { _sources pushBack [getPosATL _object, _side] };
            } forEach _y;
        } forEach (missionNamespace getVariable ["ALiVE_ATO_airborne", createHashMap]);

        // idle once no aircraft is up and no site is still in its grace
        if ((_sources isEqualTo [] && {count (_logic get "lastSeen") == 0}) || {(_logic get "radius") <= 0}) exitWith {
            // idle: still complete every tick, or no profile on the map could ever despawn
            private _wasActive = _logic get "wasActive";
            _iteration = _iteration + 1;
            _logic set ["iteration", _iteration];
            if (_wasActive) then {
                _logic set ["wasActive", false];
                _logic set ["claims", []];
                _logic set ["lastSeen", createHashMap];
            };
            _result = [_logic get "id", _iteration, true, [], _wasActive];
        };

        private _profilesById = [MOD(profileHandler),"profilesById"] call ALiVE_fnc_hashGet;

        // the anti-air vehicle profiles, rebuilt every minute (the anti-air test is cached per class)
        if (_now - (_logic get "candidatesAt") >= AIR_DEFENCE_LIST_INTERVAL) then {
            private _profilesByType = [MOD(profileHandler),"profilesByType"] call ALIVE_fnc_hashGet;
            private _candidates = ([_profilesByType,"vehicle", []] call ALiVE_fnc_hashGet) select {
                private _profile = _profilesById get _x;
                !isNil "_profile" && {
                    private _data = _profile select 2;
                    !((toLower (_data select 6)) in ["plane","helicopter"])
                    && {[_data select 11] call ALiVE_fnc_isAntiAirCapable}
                }
            };
            _logic set ["candidates", _candidates];
            _logic set ["candidatesAt", _now];
        };

        private _radius = _logic get "radius";
        private _claimed = createHashMap;
        private _lastSeen = _logic get "lastSeen";
        {
            private _profile = _profilesById get _x;
            if (!isNil "_profile") then {
                private _data = _profile select 2;
                private _active = _data select 1;
                private _vehicle = _data select 10;
                private _canFire = _data select 18;
                private _side = _data select 3;
                private _pos = _data select 2;
                // one that's up already keeps its claim a little further out, so it doesn't flicker at the edge
                private _reach = if (_active) then { _radius * AIR_DEFENCE_HOLD_FACTOR } else { _radius };
                private _able = _canFire isEqualType true && {_canFire} && {!_active || {alive _vehicle && {canFire _vehicle}}};
                if (_able && {_pos isEqualType []} && {count _pos > 1} && {_sources findIf {
                    (_pos distance2D (_x select 0)) < _reach
                    && {[[_side] call ALIVE_fnc_sideTextToObject, [_x select 1] call ALIVE_fnc_sideTextToObject] call BIS_fnc_sideIsEnemy}
                } > -1}) then {
                    _lastSeen set [_x, _now];
                };
                if (_able && {_now - (_lastSeen getOrDefault [_x, -1e9]) < AIR_DEFENCE_GRACE}) then {
                    _claimed set [_x, true];
                    // its crew: claiming the vehicle alone spawns nothing, a crewed vehicle comes with its group
                    {
                        private _entity = _profilesById get _x;
                        if (!isNil "_entity" && {((_entity select 2) select 5) isEqualTo "entity"} && {!((_entity select 2) select 30)}) then {
                            _claimed set [_x, true];
                        };
                    } forEach ((_data select 8) select { _x isEqualType "" });
                };
            };
        } forEach (_logic get "candidates");

        { if (_now - (_lastSeen get _x) >= AIR_DEFENCE_GRACE) then { _lastSeen deleteAt _x } } forEach (keys _lastSeen);
        private _claims = keys _claimed;
        _iteration = _iteration + 1;
        _logic set ["iteration", _iteration];
        _logic set ["claims", _claims];
        _logic set ["claimsAt", _now];
        _logic set ["wasActive", true];

        _result = [_logic get "id", _iteration, true, _claims, true];
    };

    case "reset": {
        _logic set ["iteration", 0];
        _logic set ["wasActive", false];
        _logic set ["claims", []];
        _logic set ["claimsAt", -1e9];
        _logic set ["candidates", []];
        _logic set ["candidatesAt", -1e9];
        _logic set ["lastSeen", createHashMap];
        _result = true;
    };

    case "destroy": {
        [_logic,"reset"] call MAINCLASS;
        _result = true;
    };
};

[nil, _result] select (!isNil "_result")
