#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(observe);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOObserve
Description:
What an airframe actually is, right now. The only piece that looks at the world.

It reads and never writes. Everything it reports is measured this tick from the
object itself, so nothing downstream has to trust a flag somebody set earlier
and forgot to clear. That mattered: despawn protection was sampled false at
every point of a whole mission while three separate places believed they had
turned it on.

It answers for a hull that has been deleted without throwing, because "the
aircraft is gone" is the single most important thing it has to be able to say,
and an observer that errors on a null object cannot say it.

It reports in the vocabulary the state table reads. Raw facts are reported too,
for anything that wants them, but the flags the table consumes are derived here
rather than at each reader, so two readers cannot disagree about what "the crew
is gone" means.

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_obs = [_o, "observe", [_obj, _home, _lockHeld, _sortie, _now]] call ALIVE_fnc_ATOObserve;

(end)

See Also:
<ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOSurface>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOObserve

// Above this off the ground the aircraft is flying, not parked or rolling.
#define AIRBORNE_AGL 50

private ["_result"];

TRACE_1("ATO Observe - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {

    case "create": {
        _result = [[["class", MAINCLASS]]] call ALIVE_fnc_hashCreate;
    };

    case "observe": {
        _args params [
            ["_obj", objNull, [objNull]],
            ["_home", [], [[]]],
            ["_lockHeld", false, [false]],
            ["_sortie", [], [[]]],
            ["_now", 0, [0]]
        ];

        private _o = [] call ALIVE_fnc_hashCreate;
        private _fnc_set = { [_o, _this select 0, _this select 1] call ALIVE_fnc_hashSet };

        // ---- is it there at all -------------------------------------------
        // Asked first and answered for a null object, because everything below
        // this line would throw on one.
        private _live = !isNull _obj && {alive _obj};
        ["objectLive", _live] call _fnc_set;
        ["objectLost", !_live] call _fnc_set;

        if (!_live) exitWith {
            // A dead hull still has to answer every question the table asks, or
            // the table cannot decide anything about it.
            {
                [_o, _x, false] call ALIVE_fnc_hashSet;
            } forEach ["local","remote","airborne","atHome","nearHome","landed","touchingGround",
                       "crewGroupLive","driverPresent","crewSeated","playerControl","playerPassenger",
                       "anyPlayerAboard","uavControlled","onStation","targetsGone","lockHeld"];
            {
                [_o, _x, 0] call ALIVE_fnc_hashSet;
            } forEach ["altAGL","altASL","speed","fuel","ammo","damage","wpRemaining","aliveCrew",
                       "playersWithin300","playersWithin1000Hull","playersWithin1000Home",
                       "playersWithin1500Home"];
            // Nobody is aboard a hull that is gone, so nothing is holding it.
            ["crewLoss", true] call _fnc_set;
            _result = _o;
        };

        // ---- where and how fast -------------------------------------------
        private _pos = getPosATL _obj;
        private _agl = _pos select 2;
        ["pos", + _pos] call _fnc_set;
        ["altAGL", _agl] call _fnc_set;
        ["altASL", (getPosASL _obj) select 2] call _fnc_set;
        ["speed", speed _obj] call _fnc_set;
        ["airborne", _agl > AIRBORNE_AGL] call _fnc_set;
        ["touchingGround", isTouchingGround _obj] call _fnc_set;

        // Landed is not simply "on the ground": an aircraft rolling out at
        // 140 km/h is touching the ground and is not down yet.
        // Two metres, not five, and all three tests. The old module recorded why:
        // being low is not being down, and counting a helicopter as landed while
        // the engine was still flying it through the last of its descent meant
        // everything that follows a landing ran early, and the airframe was put
        // back where it launched from. Anyone watching the pad saw it jump
        // sideways out of its own approach.
        ["landed", (isTouchingGround _obj) && {(speed _obj) < 5} && {_agl < 2}] call _fnc_set;

        // ---- whose is it --------------------------------------------------
        // A hull this machine does not own cannot be told anything local, so
        // the table has to know before it tries.
        private _isLocal = local _obj;
        ["local", _isLocal] call _fnc_set;
        ["remote", !_isLocal] call _fnc_set;

        // ---- who is in it -------------------------------------------------
        // Measured from the crew every tick. A handler added when the aircraft
        // was adopted is a shortcut, not the truth: it does not fire when a
        // player dies in the seat, and a corpse is not a pilot.
        private _crew = crew _obj;
        private _aliveCrew = _crew select { alive _x };
        private _players  = _aliveCrew select { isPlayer _x };
        private _driver   = driver _obj;

        ["aliveCrew", count _aliveCrew] call _fnc_set;
        ["crewGroupLive", count _aliveCrew > 0] call _fnc_set;
        ["driverPresent", !isNull _driver && {alive _driver}] call _fnc_set;
        // Ready to fly: somebody alive is actually at the controls. The state
        // table waits on this before it will launch, so an aircraft with a crew
        // standing beside it rather than sitting in it is not ready.
        ["crewSeated", !isNull _driver && {alive _driver}] call _fnc_set;
        ["crewLoss", count _aliveCrew == 0] call _fnc_set;
        ["anyPlayerAboard", count _players > 0] call _fnc_set;

        // A drone is flown from somewhere else entirely, so being empty is not
        // the same as being unattended.
        // param rather than select, matching how the rest of the mod reads this:
        // the array is not always the length you expect.
        private _controller = (UAVControl _obj) param [0, objNull];
        private _uav = !isNull _controller && {alive _controller} && {isPlayer _controller};
        ["uavControlled", _uav] call _fnc_set;

        // In control means flying it: at the stick, or operating it remotely.
        // Merely being aboard is a different thing with different consequences.
        private _control = (!isNull _driver && {alive _driver} && {isPlayer _driver}) || _uav;
        ["playerControl", _control] call _fnc_set;
        ["playerPassenger", (count _players > 0) && {!_control}] call _fnc_set;

        // ---- condition -----------------------------------------------------
        ["fuel", fuel _obj] call _fnc_set;
        ["damage", damage _obj] call _fnc_set;

        private _ammo = 1;
        private _mags = magazinesAmmo _obj;
        if (count _mags > 0) then {
            private _total = 0;
            { _total = _total + (_x select 1) } forEach _mags;
            _ammo = if (_total > 0) then { 1 } else { 0 };
        };
        ["ammo", _ammo] call _fnc_set;

        private _grp = group _driver;
        private _wp = 0;
        if (!isNull _grp) then { _wp = (count (waypoints _grp)) - (currentWaypoint _grp) };
        ["wpRemaining", _wp max 0] call _fnc_set;

        // ---- where it is relative to home ----------------------------------
        private _homePos = if (count _home > 0) then { _home select 0 } else { [0,0,0] };
        private _dHome = _obj distance2D _homePos;
        ["atHome", _dHome < (if (_obj isKindOf "Plane") then {15} else {30})] call _fnc_set;
        ["nearHome", _dHome < 2000] call _fnc_set;

        // ---- who is watching ------------------------------------------------
        // Counted separately around the aircraft and around its home, because
        // one decides whether it may be moved and the other whether it may skip
        // an approach.
        private _fnc_players = {
            params ["_p", "_r"];
            count (allPlayers select { alive _x && {(_x distance2D _p) < _r} })
        };
        ["playersWithin300",      [_pos, 300] call _fnc_players] call _fnc_set;
        ["playersWithin1000Hull", [_pos, 1000] call _fnc_players] call _fnc_set;
        ["playersWithin1000Home", [_homePos, 1000] call _fnc_players] call _fnc_set;
        ["playersWithin1500Home", [_homePos, 1500] call _fnc_players] call _fnc_set;

        // ---- the sortie ------------------------------------------------------
        private _onStation = false;
        private _targetsGone = false;
        if (count _sortie > 1) then {
            private _target = _sortie select 1;
            private _range = if (count _sortie > 3) then { _sortie select 3 } else { 500 };
            private _d = _obj distance2D _target;
            _onStation = _d < (_range * 1.2) && {_agl > AIRBORNE_AGL};
        };
        ["onStation", _onStation] call _fnc_set;
        ["targetsGone", _targetsGone] call _fnc_set;

        ["lockHeld", _lockHeld] call _fnc_set;

        _result = _o;
    };

    // Can this hull be taken away from us? Under the current design an airframe
    // the module owns has no profile at all, so nothing that removes profiles
    // can reach it. A leftover profile id is the thing to look for.
    case "isProtected": {
        private _obj = _args;
        private _reasons = [];

        if (isNull _obj) exitWith { _result = [false, ["object is null"]] };
        if (!alive _obj) exitWith { _result = [false, ["object is not alive"]] };

        if !(local _obj) then { _reasons pushBack "not local" };

        private _pid = _obj getVariable ["profileID", ""];
        if !(_pid isEqualTo "") then {
            // A stamp with nothing behind it is a leftover, not an owner. Worth
            // saying out loud, because it means something stamped this hull and
            // did not clean up, but it does not put the aircraft at risk.
            private _profile = objNull;
            if (!isNil "ALiVE_ProfileHandler") then {
                _profile = [ALiVE_ProfileHandler, "getProfile", _pid] call ALiVE_fnc_profileHandler;
            };
            if (isNil "_profile" || {isNull _profile}) then {
                ["ALIVE_fnc_ATOObserve - %1 carries a stale profile id %2 with no profile behind it", typeOf _obj, _pid] call ALiVE_fnc_dump;
            } else {
                _reasons pushBack "profileID";
            };
        };

        _result = [count _reasons == 0, _reasons];
    };

    // Enemy aircraft worth intercepting: high enough to be flying somewhere
    // rather than sitting on a pad.
    case "scanAir": {
        _args params [["_zones",[],[[]]], ["_side",sideUnknown,[sideUnknown]]];
        private _found = [];
        {
            private _zone = _x;
            private _centre = _zone select 0;
            private _radius = _zone select 1;
            {
                if (alive _x
                    && {(getPosATL _x) select 2 > 105}
                    && {(side _x) getFriend _side < 0.6}
                    && {(_x distance2D _centre) < _radius}) then {
                    _found pushBackUnique _x;
                };
            // Parenthesised on purpose rather than leaning on precedence, and
            // aircraft are vehicles, so there is nothing for allUnits to add.
            } forEach (vehicles select { _x isKindOf "Air" });
        } forEach _zones;
        _result = _found;
    };

    case "scanAirDefences": {
        _args params [["_zones",[],[[]]], ["_side",sideUnknown,[sideUnknown]]];
        private _found = [];
        {
            private _centre = _x select 0;
            private _radius = _x select 1;
            {
                private _v = _x;
                if (alive _v && {(side _v) getFriend _side < 0.6} && {(_v distance2D _centre) < _radius}) then {
                    private _isAA = false;
                    if (!isNil "ALiVE_fnc_isAntiAir") then { _isAA = [typeOf _v] call ALiVE_fnc_isAntiAir };
                    if (_isAA) then { _found pushBackUnique _v };
                };
            } forEach (vehicles select { (_x isKindOf "StaticWeapon") || {_x isKindOf "LandVehicle"} });
        } forEach _zones;
        _result = _found;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Observe - output",_result);

_result;
