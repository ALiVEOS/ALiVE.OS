#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(effect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOEffect
Description:
Does things to an aircraft. The only piece that changes the world.

Every effect has a name from a closed list, and applying one twice leaves the
world exactly as it was and says so. Nothing here decides anything: the state
table decides, this carries it out, and if it cannot it refuses out loud rather
than half-doing it quietly. Guards that refused correctly and silently for four
days are why the refusal is spoken.

Three refusals are absolute and are checked here rather than trusted to callers,
so no caller can forget one:

  A player in the aircraft. Nothing that moves it, and nothing that removes its
  crew. A player being carried somewhere is the whole reason the aircraft is
  worth having, and teleporting it out from under them is the complaint this
  module exists to stop.

  A hull owned by another machine. Anything that only works locally is refused
  and reported, never applied and silently lost, which is what made the same
  fault look intermittent.

  Orders for an aircraft in the air that do not end in a hold. An order chain
  that simply runs out is an aircraft with nothing to do, and that is four
  seconds from the ground.

apply(effect, obj, home, extra) -> [status, alreadyMatched, detail]

Parameters:
Nil or Array - If Nil, return a new instance. If a hash, reference an existing one.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function

Examples:
(begin example)
_r = [_e, "apply", ["engineOn", _veh, _home, []]] call ALIVE_fnc_ATOEffect;
_r params ["_status", "_alreadyMatched", "_detail"];

(end)

See Also:
<ALIVE_fnc_ATOMachine>, <ALIVE_fnc_ATOSurface>, <ALIVE_fnc_ATOObserve>

Author:
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_ATOEffect

// Anything that moves the aircraft, plus taking its crew away. Refused outright
// while a player is in it, from any state, by any path.
#define PLAYER_UNSAFE ["airborneStart","forceLaunch","placeOnSlot","forceLanded","spawnAtHome","standDownCrew","takeOwnership"]

// Effects that only work where the object lives. On a hull owned elsewhere these
// do nothing at all, so they are refused and reported instead.
#define LOCAL_ONLY ["engineOn","engineOff","airborneStart","forceLaunch","placeOnSlot","forceLanded","spawnAtHome","seatCrew","recrewInPlace","standDownCrew","issueOrders","clearOrders","land","taxiTo"]

// Not built in this pass. Named so a caller reaching one is told, rather than
// finding that nothing happened.
#define NOT_BUILT ["catapult","tailhook","deckLaunch","deckRecover","decoyLasers","addThreatHandlers","revealTargets","holdTargets","releaseTargets","unquiesce","sweepTaxiPath","siren","deleteWreckNear","rehome","unshield"]

private ["_result"];

TRACE_1("ATO Effect - input",_this);

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

    case "vocabulary": {
        _result = ["spawnAtHome","airborneStart","mintCrew","mintDroneCrew","seatCrew","recrewInPlace",
                   "standDownCrew","takeOwnership","engineOn","engineOff","issueOrders","clearOrders",
                   "taxiTo","land","forceLaunch","forceLanded","placeOnSlot","shield","broadcast"];
    };

    case "apply": {
        _args params [
            ["_effect", "", [""]],
            ["_obj", objNull, [objNull]],
            ["_home", [], [[]]],
            ["_extra", [], [[],"",0,true]]
        ];

        private _status = "ok";
        private _matched = false;
        private _detail = "";

        // ---- the three absolute refusals ----------------------------------
        // Checked before anything looks at what the effect is, so a new effect
        // added later inherits them rather than having to remember them.

        if (isNull _obj && {!(_effect isEqualTo "broadcast")}) exitWith {
            _result = ["refused", false, "no object"];
        };

        if (!isNull _obj && {(_effect in PLAYER_UNSAFE)} && {({alive _x && {isPlayer _x}} count (crew _obj)) > 0}) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 refused on %2: a player is aboard", _effect, typeOf _obj] call ALiVE_fnc_dump;
            _result = ["refused", false, "player aboard"];
        };

        if (!isNull _obj && {(_effect in LOCAL_ONLY)} && {!local _obj}) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 refused on %2: the hull is owned elsewhere", _effect, typeOf _obj] call ALiVE_fnc_dump;
            _result = ["refused", false, "remote"];
        };

        if (_effect in NOT_BUILT) exitWith {
            ["ALIVE_fnc_ATOEffect - %1 is not built yet, refusing rather than doing nothing quietly", _effect] call ALiVE_fnc_dump;
            _result = ["refused", false, "not built"];
        };

        switch (_effect) do {

            // ---- engine ---------------------------------------------------
            case "engineOn": {
                if (isEngineOn _obj) then { _matched = true } else { _obj engineOn true };
            };
            case "engineOff": {
                if (!isEngineOn _obj) then { _matched = true } else { _obj engineOn false };
            };

            // ---- ownership ------------------------------------------------
            // Only ever moved to the server, and only when empty: taking a hull
            // with somebody in it away from the machine they are on is not a
            // thing to do to a person.
            case "takeOwnership": {
                if (local _obj) then {
                    _matched = true;
                } else {
                    if (count (crew _obj) > 0) then {
                        _status = "refused"; _detail = "crew aboard";
                    } else {
                        _obj setOwner 2;
                    };
                };
            };

            // ---- crew ------------------------------------------------------
            case "mintCrew": {
                if (count (crew _obj) > 0) then {
                    _matched = true;
                } else {
                    private _grp = createVehicleCrew _obj;
                    if (isNull _grp) then {
                        _status = "refused"; _detail = "crew could not be created";
                    } else {
                        // Marked so nothing else adopts them, and so they are
                        // recognisable as ours when they are stood down.
                        { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (units _grp);
                        _detail = str (count (units _grp));
                    };
                };
            };

            case "mintDroneCrew": {
                if (count (crew _obj) > 0) then {
                    _matched = true;
                } else {
                    createVehicleCrew _obj;
                    // A drone flown by nobody is still meant to be operable from
                    // a terminal, so the crew must not be treated as pilots.
                    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _obj);
                };
            };

            case "recrewInPlace": {
                if (({alive _x} count (crew _obj)) > 0) then {
                    _matched = true;
                } else {
                    // The dead have to be taken out of the seats first. Crew
                    // creation only fills seats it finds EMPTY, and a body still
                    // occupies one, so an aircraft whose pilot was killed would
                    // be handed no replacement at all and fly on with nobody in
                    // it. That is the exact failure this effect exists to undo.
                    { deleteVehicle _x } forEach (crew _obj);
                    createVehicleCrew _obj;
                    { _x setVariable ["ALiVE_mil_ato_crew", true, true] } forEach (crew _obj);
                    _detail = "recrewed";
                };
            };

            case "seatCrew": {
                _matched = ({alive _x} count (crew _obj)) > 0;
            };

            case "standDownCrew": {
                private _ours = (crew _obj) select { _x getVariable ["ALiVE_mil_ato_crew", false] };
                if (count _ours == 0) then {
                    _matched = true;
                } else {
                    // Deleted outright only when nobody is close enough to see
                    // it happen. Otherwise they get out and are removed once
                    // they have walked off, because people vanishing in front of
                    // you is worse than a few extra men standing about.
                    private _watched = (allPlayers select { alive _x && {(_x distance2D _obj) < 300} });
                    if (count _watched == 0) then {
                        { deleteVehicle _x } forEach _ours;
                        _detail = "deleted";
                    } else {
                        { moveOut _x; [_x] orderGetIn false } forEach _ours;
                        [_ours] spawn {
                            params ["_units"];
                            sleep 120;
                            { if (!isNull _x && {alive _x}) then { deleteVehicle _x } } forEach _units;
                        };
                        _detail = "dismissed";
                    };
                };
            };

            // ---- orders ------------------------------------------------------
            // Orders arrive already resolved to places: [[type, position], ...].
            // Turning a name like "go to the target" into a position needs to
            // know what the sortie is, and that is not this piece's business.
            case "issueOrders": {
                private _chain = _extra param [0, []];
                private _airborne = ((getPosATL _obj) select 2) > 50;

                if (count _chain == 0) exitWith { _status = "refused"; _detail = "empty chain" };

                // An order list for an aircraft in the air that does not end in
                // a hold is an aircraft that runs out of things to do, and that
                // was four seconds from the ground.
                private _lastType = (_chain select (count _chain - 1)) param [0, ""];
                if (_airborne && {!(_lastType isEqualTo "LOITER")}) exitWith {
                    ["ALIVE_fnc_ATOEffect - orders refused for %1: an airborne chain must end in a hold", typeOf _obj] call ALiVE_fnc_dump;
                    _status = "refused"; _detail = "no terminal hold";
                };

                private _grp = group (driver _obj);
                if (isNull _grp) exitWith { _status = "refused"; _detail = "no group" };

                // Already flying exactly this? Leave it alone. Re-issuing the
                // same chain every tick restarts the aircraft's plan each time.
                private _signature = str _chain;
                if ((_grp getVariable ["ALiVE_mil_ato_orders", ""]) isEqualTo _signature) exitWith {
                    _matched = true; _detail = "unchanged";
                };

                private _wps = waypoints _grp;
                for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                {
                    _x params [["_type","MOVE",[""]], ["_pos",[0,0,0],[[]]]];
                    private _wp = _grp addWaypoint [_pos, 0];
                    _wp setWaypointType _type;
                } forEach _chain;
                _grp setVariable ["ALiVE_mil_ato_orders", _signature, false];
                _detail = str (count _chain);
            };

            case "clearOrders": {
                private _grp = group (driver _obj);
                if (isNull _grp) then {
                    _matched = true;
                } else {
                    private _wps = waypoints _grp;
                    if (count _wps == 0) then {
                        _matched = true;
                    } else {
                        for "_i" from (count _wps - 1) to 0 step -1 do { deleteWaypoint [_grp, _i] };
                    };
                };
            };

            // ---- putting it places -------------------------------------------
            case "placeOnSlot": {
                private _surface = _extra param [0, []];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                if ([_surface, "atHome", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                    _matched = true;
                } else {
                    if !([_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                        _status = "refused"; _detail = "surface refused the placement";
                    };
                };
            };

            case "forceLanded": {
                private _surface = _extra param [0, []];
                if (_surface isEqualTo []) exitWith { _status = "refused"; _detail = "no surface" };
                if ([_surface, "atHome", [_obj, _home]] call ALIVE_fnc_ATOSurface) then {
                    _matched = true;
                } else {
                    ["ALIVE_fnc_ATOEffect - %1 put down at its home rather than left flying", typeOf _obj] call ALiVE_fnc_dump;
                    [_surface, "place", [_obj, _home]] call ALIVE_fnc_ATOSurface;
                };
            };

            case "airborneStart": {
                if (((getPosATL _obj) select 2) > 50) then {
                    _matched = true;
                } else {
                    private _alt = _extra param [0, 300];
                    private _p = getPosATL _obj;
                    _obj setPosATL [_p select 0, _p select 1, _alt];
                    _obj engineOn true;
                    _obj setVelocity [(sin (getDir _obj)) * 90, (cos (getDir _obj)) * 90, 0];
                };
            };

            case "forceLaunch": {
                if (((getPosATL _obj) select 2) > 50) then {
                    _matched = true;
                } else {
                    private _p = getPosATL _obj;
                    _obj setPosATL [_p select 0, _p select 1, 600];
                    _obj engineOn true;
                    _obj setVelocity [(sin (getDir _obj)) * 120, (cos (getDir _obj)) * 120, 0];
                };
            };

            case "land": {
                private _mode = _extra param [0, "LAND"];
                private _grp = group (driver _obj);
                if (isNull _grp) then { _status = "refused"; _detail = "no group" }
                else { _obj land _mode };
            };

            case "taxiTo": { _detail = "taxi not modelled in this pass"; };

            // ---- protecting it -----------------------------------------------
            // An aircraft this module owns carries no profile, so nothing that
            // removes profiles can reach it. Clearing a leftover stamp is the
            // whole of the protection.
            case "shield": {
                private _tail = _extra param [0, ""];
                if ((_obj getVariable ["ALiVE_mil_ato_tail", ""]) isEqualTo _tail && {_tail != ""}) then {
                    _matched = true;
                } else {
                    _obj setVariable ["ALiVE_mil_ato_tail", _tail, true];
                    _obj setVariable ["ALIVE_profileIgnore", true, true];
                    _obj setVariable ["profileID", nil, true];
                    _obj setVariable ["profileIndex", nil, true];
                    _obj setVariable ["runtimeProfiled", nil, true];
                };
            };

            case "spawnAtHome": {
                _status = "refused"; _detail = "creation belongs to placement";
            };

            case "broadcast": {
                private _key = _extra param [0, ""];
                if (_key isEqualTo "") then { _status = "refused"; _detail = "no key" }
                else { _detail = _key };
            };

            default {
                ["ALIVE_fnc_ATOEffect - %1 is not an effect this knows", _effect] call ALiVE_fnc_dump;
                _status = "refused"; _detail = "unknown effect";
            };
        };

        _result = [_status, _matched, _detail];
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("ATO Effect - output",_result);

_result;
