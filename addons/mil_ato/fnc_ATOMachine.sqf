#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(machine);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOMachine
Description:
The airframe state table. One aircraft, one row, one step at a time.

PURE. It reads a row, what the world currently looks like, and any command, and
returns a new row plus the orders that row should be flying and the effects
somebody else should apply. It touches no object, reads no profile, and has no
side effects, so it can be exercised completely without a mission running.

Two properties are the point of it.

An aircraft can never end up with no orders. Every state that is not resting
carries a deadline and issues orders, and every input, including one this table
has never heard of, lands on a state that is in the table. Four seconds from
"has no more waypoints" to destroyed is what the old machine did, because an
unhandled transition left an airframe flying with nothing to do.

A player flying an aircraft is not a state the machine can order around. While a
player is aboard and in control the table issues nothing at all: no orders, no
repositions, no crew changes. A player merely riding along is a MODIFIER rather
than a state, so the sortie keeps its deadlines, but every effect that would
teleport the aircraft is refused while they are in it.

step(row, obs, cmd, now) -> [row, orders, effects]

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_m = [nil, "create"] call ALIVE_fnc_ATOMachine;
_out = [_m, "step", [_row, _obs, "", 120]] call ALIVE_fnc_ATOMachine;
_out params ["_row2", "_orders", "_effects"];

(end)

See Also:
<ALIVE_fnc_ATOLedger>, <ALIVE_fnc_ATOSurface>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOMachine

// The three states with no deadline. Everything else must carry one, or an
// aircraft can sit in it for the rest of the mission.
#define REST_STATES ["PARKED","PLAYER_FLOWN","LOST"]

#define ALL_STATES ["PARKED","PLAYER_FLOWN","ASSIGNED","LAUNCHING","ENROUTE","ON_STATION","RTB","LANDING","RECOVERING","LOST"]

// Effects that move an aircraft. None of them may be applied with a player in
// it, whether they are flying it or just aboard.
#define TELEPORTS ["airborneStart","forceLaunch","placeOnSlot","forceLanded","quickPark"]

private ["_result"];

TRACE_1("ATO Machine - input",_this);

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

    // Every attach and every restore starts here. The machine does not assume
    // it knows what an aircraft was doing before it was handed one: it looks.
    case "entryState": { _result = "RECOVERING"; };

    case "states": { _result = + ALL_STATES; };
    case "restStates": { _result = + REST_STATES; };

    // A blank row, so a caller never has to know the field list.
    case "newRow": {
        _args params [["_tail","",[""]], ["_home",[],[[]]]];
        _result = [[
            ["tail", _tail],
            ["state", "RECOVERING"],
            ["home", + _home],
            ["enteredAt", 0],
            ["deadlineAt", 0],
            ["readyAt", 0],
            ["playerFreeSince", -1],
            ["attempts", 0],
            ["sortie", []],
            ["reason", ""]
        ]] call ALIVE_fnc_hashCreate;
    };

    case "step": {
        _args params [
            ["_row",[],[[]]],
            ["_obs",[],[[]]],
            ["_cmd","",[""]],
            ["_now",0,[0]]
        ];

        // Work on a COPY. The caller's row is an input, and a step that edits
        // its input is not something you can replay, reason about, or test by
        // feeding it the same row twice.
        _row = [_row] call ALIVE_fnc_hashCopy;

        private _fnc_o = { [_obs, _this, false] call ALIVE_fnc_hashGet };
        private _fnc_n = { [_obs, _this, 0] call ALIVE_fnc_hashGet };

        private _state = [_row,"state","RECOVERING"] call ALIVE_fnc_hashGet;
        // An unknown state is not a reason to do nothing. Recover from it.
        if !(_state in ALL_STATES) then { _state = "RECOVERING" };

        private _orders = [];
        private _effects = [];
        private _next = _state;
        private _reason = "";

        private _playerPassenger = "playerPassenger" call _fnc_o;
        private _remote = "remote" call _fnc_o;
        private _airborne = "airborne" call _fnc_o;
        private _atHome = "atHome" call _fnc_o;
        private _expired = ([_row,"deadlineAt",0] call ALIVE_fnc_hashGet) > 0
                        && {_now >= ([_row,"deadlineAt",0] call ALIVE_fnc_hashGet)};

        // ---- the priority ladder ------------------------------------------
        // Order matters and is the same for every state. A lost hull is lost
        // whatever else is true of it; a player in control outranks any command
        // the commander wanted to give.

        if ("objectLost" call _fnc_o) then {
            _next = "LOST";
        } else {
            if ("playerControl" call _fnc_o) then {
                _next = "PLAYER_FLOWN";
            } else {
                switch (true) do {

                    // ---- commands ------------------------------------------
                    case (_cmd isEqualTo "RETIRE"): { _next = "LOST"; _reason = "retired"; };
                    case (_cmd isEqualTo "CANCEL" && {!(_state in ["PARKED","LOST"])}): {
                        _next = "RTB"; _reason = "CANCELLED";
                    };
                    case (_cmd isEqualTo "ASSIGN" && {_state isEqualTo "PARKED"}
                          && {_now >= ([_row,"readyAt",0] call ALIVE_fnc_hashGet)}): {
                        _next = "ASSIGNED";
                    };
                    case (_cmd isEqualTo "REROUTE" && {_state isEqualTo "ON_STATION"}): {
                        _next = "ENROUTE";
                    };
                    case (_cmd isEqualTo "RELEASE" && {_state isEqualTo "PLAYER_FLOWN"}): {
                        _next = if (_atHome) then {"PARKED"} else {"RECOVERING"};
                    };

                    // ---- crew lost in the air ------------------------------
                    // The airframe is flying with nobody in it. Recover before
                    // anything else is considered.
                    //
                    // Not while ALREADY recovering: that state is the one that
                    // knows what to do about a crewless hull, and matching here
                    // would send it back to itself every tick and never let its
                    // own rules run, so the aircraft would fly on empty forever.
                    case ("crewLoss" call _fnc_o && {_airborne} && {!(_state isEqualTo "RECOVERING")}): {
                        _next = "RECOVERING";
                    };

                    // ---- the state's own rules -----------------------------
                    default {
                        switch (_state) do {

                            case "PARKED": {
                                if (!_atHome) then { _next = "RECOVERING" };
                            };

                            case "PLAYER_FLOWN": {
                                // Nobody controlling and nobody aboard. In the
                                // air that is immediate: the aircraft is empty
                                // and falling. On the ground a player who got
                                // out is probably coming back, so it waits.
                                if !("anyPlayerAboard" call _fnc_o) then {
                                    if (_airborne) then {
                                        _next = "RECOVERING";
                                    } else {
                                        private _since = [_row,"playerFreeSince",-1] call ALIVE_fnc_hashGet;
                                        private _grace = if (isNil "ALIVE_playerOccupantGrace") then {300} else {ALIVE_playerOccupantGrace};
                                        if (_since < 0) then {
                                            [_row,"playerFreeSince",_now] call ALIVE_fnc_hashSet;
                                        } else {
                                            if (_now - _since >= _grace) then {
                                                _next = if (_atHome) then {"PARKED"} else {"RECOVERING"};
                                            };
                                        };
                                    };
                                } else {
                                    [_row,"playerFreeSince",-1] call ALIVE_fnc_hashSet;
                                };
                            };

                            case "ASSIGNED": {
                                if ("crewSeated" call _fnc_o && {"lockHeld" call _fnc_o}) then {
                                    _next = "LAUNCHING";
                                } else {
                                    if (_expired) then {
                                        // The hull never moved, so it simply
                                        // goes back to being parked and the
                                        // request is handed back to be re-let.
                                        _effects append ["standDownCrew","unlock","assignFailed"];
                                        _next = "PARKED";
                                    };
                                };
                            };

                            case "LAUNCHING": {
                                if (_airborne) then {
                                    _effects pushBack "unlock";
                                    _next = "ENROUTE";
                                } else {
                                    if (_expired) then {
                                        if (([_row,"attempts",0] call ALIVE_fnc_hashGet) < 1 && {!_playerPassenger}) then {
                                            _effects pushBack "forceLaunch";
                                            [_row,"attempts",1] call ALIVE_fnc_hashSet;
                                        } else {
                                            _next = "RECOVERING";
                                        };
                                    };
                                };
                            };

                            case "ENROUTE": {
                                if ("onStation" call _fnc_o) then {
                                    _next = "ON_STATION";
                                } else {
                                    if (("fuel" call _fnc_n) < 0.2) then {
                                        _next = "RTB"; _reason = "RETURN_FUEL";
                                    } else {
                                        if (_expired) then { _next = "RTB"; _reason = "RETURN" };
                                    };
                                };
                            };

                            case "ON_STATION": {
                                switch (true) do {
                                    case (("fuel" call _fnc_n) < 0.2):   { _next = "RTB"; _reason = "RETURN_FUEL"; };
                                    case (("ammo" call _fnc_n) < 0.1):   { _next = "RTB"; _reason = "RETURN_AMMO"; };
                                    case (("damage" call _fnc_n) > 0.5): { _next = "RTB"; _reason = "RETURN_DAMAGE"; };
                                    case ("targetsGone" call _fnc_o):    { _next = "RTB"; _reason = "RETURN"; };
                                    case (_expired):                     { _next = "RTB"; _reason = "RETURN"; };
                                };
                            };

                            case "RTB": {
                                // Nobody near home and nobody riding along, so
                                // there is nothing to see: put it on its slot
                                // and skip the approach entirely. No lock is
                                // taken, because no runway is used.
                                if (("playersWithin1000Home" call _fnc_n) == 0 && {!_playerPassenger}) then {
                                    _effects pushBack "placeOnSlot";
                                    _next = "PARKED";
                                } else {
                                    if ("nearHome" call _fnc_o && {"lockHeld" call _fnc_o}) then {
                                        _next = "LANDING";
                                    } else {
                                        if ("nearHome" call _fnc_o && {("fuel" call _fnc_n) < 0.1}) then {
                                            _effects pushBack "emergencyLanding";
                                            _next = "LANDING";
                                        } else {
                                            if (_expired) then {
                                                [_row,"attempts",([_row,"attempts",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                                                _next = "RECOVERING";
                                            };
                                        };
                                    };
                                };
                            };

                            case "LANDING": {
                                if ("landed" call _fnc_o) then {
                                    _effects append ["turnaround","unlock"];
                                    _next = "PARKED";
                                } else {
                                    if (_expired) then {
                                        private _a = [_row,"attempts",0] call ALIVE_fnc_hashGet;
                                        if (_a < 1) then {
                                            _effects pushBack "retryLanding";
                                            [_row,"attempts",_a + 1] call ALIVE_fnc_hashSet;
                                        } else {
                                            if (_playerPassenger) then {
                                                // Never put a hull on the ground
                                                // with somebody in it. Ask again.
                                                _effects pushBack "retryLanding";
                                            } else {
                                                _effects pushBack "forceLanded";
                                                _next = "PARKED";
                                            };
                                        };
                                    };
                                };
                            };

                            case "RECOVERING": {
                                switch (true) do {
                                    case (_remote): { _effects pushBack "takeOwnership"; };
                                    case (_airborne && {"crewLoss" call _fnc_o}): {
                                        _effects pushBack "recrewInPlace";
                                    };
                                    case (_airborne): {
                                        if (("playersWithin1000Hull" call _fnc_n) == 0 && {!_playerPassenger}) then {
                                            _effects pushBack "placeOnSlot";
                                            _next = "PARKED";
                                        } else {
                                            if (([_row,"attempts",0] call ALIVE_fnc_hashGet) < 2) then {
                                                [_row,"attempts",([_row,"attempts",0] call ALIVE_fnc_hashGet) + 1] call ALIVE_fnc_hashSet;
                                                _next = "RTB"; _reason = "RETURN";
                                            } else {
                                                _effects pushBack "forceLanded";
                                                _next = "PARKED";
                                            };
                                        };
                                    };
                                    case (_atHome): { _next = "PARKED"; };
                                    case (("playersWithin1000Hull" call _fnc_n) == 0): {
                                        _effects pushBack "placeOnSlot";
                                        _next = "PARKED";
                                    };
                                    default {
                                        // On the ground, away from home, with
                                        // people watching. It has to fly back.
                                        if (_expired) then {
                                            _effects pushBack "placeOnSlot";
                                            _next = "PARKED";
                                        };
                                    };
                                };
                            };

                            case "LOST": { };
                        };
                    };
                };
            };
        };

        // ---- entry effects and the new row --------------------------------
        private _changed = !(_next isEqualTo _state);

        if (_changed) then {
            [_row,"state",_next] call ALIVE_fnc_hashSet;
            [_row,"enteredAt",_now] call ALIVE_fnc_hashSet;
            if (!(_reason isEqualTo "")) then { [_row,"reason",_reason] call ALIVE_fnc_hashSet };

            // Attempts belong to the run at a state, not to the aircraft.
            if (_next in ["PARKED","PLAYER_FLOWN","LOST","ENROUTE","ON_STATION"]) then {
                [_row,"attempts",0] call ALIVE_fnc_hashSet;
            };
            if !(_next isEqualTo "PLAYER_FLOWN") then {
                [_row,"playerFreeSince",-1] call ALIVE_fnc_hashSet;
            };

            switch (_next) do {
                case "PARKED": {
                    _effects append ["unlock","engineOff","clearOrders"];
                    if (!_playerPassenger) then { _effects pushBack "standDownCrew" };
                };
                case "PLAYER_FLOWN": { _effects append ["unlock","releaseTargets","sortiePlayerControl"]; };
                case "LOST":         { _effects append ["unlock","releaseTargets","broadcastLost","markLost","onLost"]; };
                case "RECOVERING":   { _effects append ["unlock","clearOrders"]; };
                case "ASSIGNED":     { _effects append ["mintCrew","seatCrew","lock"]; };
                case "LAUNCHING":    { _effects pushBack "broadcastStart"; };
                case "ON_STATION":   { _effects append ["broadcastOnStation","revealTargets","sortieArrived"]; };
                case "RTB":          { _effects append ["broadcastReturn","releaseTargets","sortieReturning"]; };
                case "LANDING":      { _effects pushBack "landingPlan"; };
                case "ENROUTE":      { };
            };
        };

        // A player in the aircraft refuses every effect that would move it. This
        // is the one rule that outranks the table, and it is applied here rather
        // than in each state so no state can forget it.
        if (_playerPassenger || {_next isEqualTo "PLAYER_FLOWN"}) then {
            private _kept = _effects select { !(_x in TELEPORTS) };
            if (!(_kept isEqualTo _effects)) then {
                _effects = _kept;
                _effects pushBack "refusedTeleportPlayerAboard";
            };
        };
        // Nothing local may be done to a hull this machine does not own.
        if (_remote) then {
            _effects = _effects select { _x in ["takeOwnership","unlock"] };
        };

        // ---- deadline and orders ------------------------------------------
        // Every state that is not resting gets a finite deadline. Without one
        // an aircraft can sit in a state forever, which is how a sortie ends
        // with an airframe flying nowhere.
        if (_next in REST_STATES) then {
            [_row,"deadlineAt",0] call ALIVE_fnc_hashSet;
        } else {
            if (_changed || {([_row,"deadlineAt",0] call ALIVE_fnc_hashGet) <= 0}) then {
                private _sortie = [_row,"sortie",[]] call ALIVE_fnc_hashGet;
                private _duration = if (count _sortie > 2) then {_sortie select 2} else {600};
                private _span = switch (_next) do {
                    case "ASSIGNED":   { 120 };
                    case "LAUNCHING":  { (_duration / 3) max 180 };
                    case "ENROUTE":    { (2 * _duration) max 120 };
                    case "ON_STATION": { _duration max 120 };
                    case "RTB":        { (2 * _duration) max 120 };
                    case "LANDING":    { 300 };
                    case "RECOVERING": { 600 };
                    default            { 300 };
                };
                [_row,"deadlineAt", _now + _span] call ALIVE_fnc_hashSet;
            };
        };

        // Standing orders. Every state that is flying has something to fly, and
        // every airborne chain ends holding rather than running out.
        _orders = switch (_next) do {
            case "ENROUTE":    { ["MOVE_STATION","LOITER"] };
            case "ON_STATION": { ["EXECUTE","LOITER"] };
            case "RTB":        { ["MOVE_APPROACH","LOITER"] };
            case "LANDING":    { ["LAND"] };
            case "LAUNCHING":  { ["TAKEOFF"] };
            case "ASSIGNED":   { ["HOLD"] };
            case "RECOVERING": { ["HOLD"] };
            case "PARKED":     { [] };
            case "PLAYER_FLOWN": { [] };
            case "LOST":       { [] };
            default            { ["HOLD"] };
        };
        // A player flying it is given nothing at all.
        if (_next isEqualTo "PLAYER_FLOWN") then { _orders = [] };

        _result = [_row, _orders, _effects];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Machine - output",_result);

_result;
