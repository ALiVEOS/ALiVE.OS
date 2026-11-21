#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(createFPVDrone);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_createFPVDrone
Description:
An FPV suicide drone sent at a player by the bomber and drone dispatcher (fnc_IED "bomberDispatch").

The drone is the side's vanilla quadcopter (or Drone Class) with a dummy of its warhead under it. It flies to the
player 40 m over the ground at 15 m/s, holds about 25 m over him for 4 s (the warning: its rotors overhead), then dives. When it reaches him it is
removed and the real warhead is made and set off there (measured on the NUC, DRN46 to DRN51: a warhead carried on
the drone does not hurt a vehicle; one made at the moment of the hit does, if it comes in 45 degrees down from in
front of the vehicle). Shot down, jammed (another mod's jammer that kills its AI pilot or drains its fuel counts),
taken over by a UAV terminal, out of battery (240 s) or no longer run by the
server, it drops without exploding; with Explodes When Shot Down on, one shot down in its final dive explodes.

Everything runs on the server. The drone has no profile and is never saved.

Parameters:
0: OBJECT - the player
1: GROUP - the AI Commander's group that spotted him and launches it

or a mode: ["nolink", [drone]] (every client: its UAV terminal can't connect to the drone),
["roofed", [unit or vehicle]] (is there a roof within 3 m over him), ["blow", [state, position ASL, fuse, on target]]
and ["end", [state, reason, drop]] (server).

Returns:
OBJECT - the drone, or objNull when none was launched (create); BOOL (roofed)

Author:
Jman
---------------------------------------------------------------------------- */

if (_this isEqualType [] && {(_this param [0, objNull]) isEqualType ""}) exitWith {
    params ["_mode", ["_args", []]];
    switch (_mode) do {

        case "nolink": {
            if (!hasInterface) exitWith {};
            _args params [["_uav", objNull, [objNull]]];
            if (!isNull _uav && {!isNull player}) then { player disableUAVConnectability [_uav, true] };
        };

        case "roofed": {
            // a roof within 3 m over a man's head, or over a vehicle's top; the vehicle itself doesn't count
            _args params [["_tgt", objNull, [objNull]]];
            if (isNull _tgt) exitWith { false };
            private _from = if (_tgt isKindOf "Man") then { (getPosASL _tgt) vectorAdd [0, 0, 1.9] } else {
                (boundingBoxReal _tgt) params ["_lo", "_hi"];
                _tgt modelToWorldWorld [0, 0, (_hi select 2) + 0.2]
            };
            (lineIntersectsSurfaces [_from, _from vectorAdd [0, 0, 3], _tgt, objNull, true, 1]) isNotEqualTo []
        };

        case "blow": {
            // the warhead goes off: the drone and its dummy are removed and the real warhead is made and set off.
            // On target (a hit, or a crash within 8 m of him): for a vehicle 45 degrees down from in front of it,
            // 2.5 m off its centre; for a man 0.5 m back along the line to his chest. Elsewhere, where the drone was
            _args params ["_d", "_pos", ["_fuse", ""], ["_onTarget", false]];
            if (_d getOrDefault ["gone", false]) exitWith {};
            _d set ["gone", true];
            private _eh = _d getOrDefault ["eh", -1];
            if (_eh >= 0) then { removeMissionEventHandler ["EachFrame", _eh]; _d set ["eh", -1] };
            private _uav = _d get "uav";
            private _dummy = _d get "dummy";
            private _tgt = vehicle (_d get "target");
            if (!isNull _dummy) then { deleteVehicle _dummy };
            // the drone's body must not take the blast: moved well away this frame, deleted at the end of it
            if (!isNull _uav) then {
                _uav setPosASL (_pos vectorAdd [0, 0, 400]);
                { deleteVehicle _x } forEach (crew _uav);
                deleteVehicle _uav;
            };
            private _dir = [0, 0, -1];
            private _pp = _pos;
            if (_onTarget && {!isNull _tgt}) then {
                if (_tgt isKindOf "Man") then {
                    private _v = ((getPosASL _tgt) vectorAdd [0, 0, 1]) vectorDiff _pos;
                    if ((vectorMagnitude _v) > 0.01) then { _dir = vectorNormalized _v };
                    _pp = _pos vectorAdd (_dir vectorMultiply -0.5);
                } else {
                    _dir = vectorNormalized ((vectorDir _tgt) vectorAdd [0, 0, -1]);
                    _pp = (_tgt modelToWorldWorld [0, 0, 0]) vectorAdd (_dir vectorMultiply -2.5);
                };
            };
            private _ch = createVehicle [_d get "ammo", ASLToAGL _pp, [], 0, "CAN_COLLIDE"];
            _ch setPosASL _pp;
            // straight down has no "up" from the world's vertical
            private _up = (_dir vectorCrossProduct [0, 0, 1]) vectorCrossProduct _dir;
            if ((vectorMagnitude _up) < 0.1) then { _up = [0, 1, 0] };
            _ch setVectorDirAndUp [_dir, vectorNormalized _up];
            _ch setVelocity (_dir vectorMultiply 22);
            private _lead = _d get "lead";
            if (alive _lead) then { _ch setShotParents [_lead, _lead] };
            triggerAmmo _ch;
            ["end", [_d, format ["exploded (%1)", _fuse], false]] call ALiVE_fnc_createFPVDrone;
        };

        case "end": {
            // the flight is over: with drop the drone falls without exploding and its wreck goes after 60 s;
            // otherwise it is removed now. The slot and the player's flag are freed
            _args params ["_d", ["_why", ""], ["_drop", false]];
            if (_d getOrDefault ["ended", false]) exitWith {};
            _d set ["ended", true];
            _d set ["gone", true];
            private _eh = _d getOrDefault ["eh", -1];
            if (_eh >= 0) then { removeMissionEventHandler ["EachFrame", _eh]; _d set ["eh", -1] };
            private _uav = _d get "uav";
            private _dummy = _d get "dummy";
            if (!isNull _uav) then {
                if (_drop) then {
                    if (alive _uav) then { _uav setFuel 0 };
                    [_uav, _dummy] spawn {
                        params ["_uav", "_dummy"];
                        sleep 60;
                        if (!isNull _dummy) then { deleteVehicle _dummy };
                        if (!isNull _uav) then { { deleteVehicle _x } forEach (crew _uav); deleteVehicle _uav };
                    };
                } else {
                    if (!isNull _dummy) then { deleteVehicle _dummy };
                    { deleteVehicle _x } forEach (crew _uav);
                    deleteVehicle _uav;
                };
            } else {
                if (!isNull _dummy) then { deleteVehicle _dummy };
            };
            private _target = _d get "target";
            if (!isNull _target && {(_target getVariable ["ALiVE_IED_droneOn", objNull]) isEqualTo _uav}) then { _target setVariable ["ALiVE_IED_droneOn", objNull] };
            remoteExec ["", _d get "jip"];
            if ((_d getOrDefault ["marker", ""]) != "") then { deleteMarker (_d get "marker") };
            if (_d get "debug") then {
                ["ALIVE-%1 FPV drone: flight over after %2 s: %3; closest %4 m to %5", time, round (time - (_d get "t0")), _why,
                    [(_d get "min") toFixed 1, "-"] select ((_d get "min") > 1e8), if (isNull _target) then { "nobody" } else { name _target }] call ALiVE_fnc_dump;
            };
        };
    };
};

// ---- create --------------------------------------------------------------------------------------------------------

params [["_target", objNull, [objNull]], ["_grp", grpNull, [grpNull]]];
if (!isServer || {isNull _target} || {isNull _grp}) exitWith { objNull };

private _debug = ADDON getVariable ["debug", false];
private _side = side _grp;
private _lead = leader _grp;

// the class: Drone Class, or the vanilla quadcopter of the launching group's side
private _fallback = switch (_side) do { case west: { "B_UAV_01_F" }; case independent: { "I_UAV_01_F" }; default { "O_UAV_01_F" } };
private _class = ADDON getVariable ["Drone_Class", ""];
if (_class != "" && {!isClass (configFile >> "CfgVehicles" >> _class) || {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") != 1}}) then {
    if (_debug) then { ["ALIVE-%1 FPV drone: Drone Class %2 is not a drone, using %3", time, _class, _fallback] call ALiVE_fnc_dump };
    _class = "";
};
if (_class == "") then { _class = _fallback };

// the warhead: Medium is a rocket warhead, Small a grenade; a missing class falls back to the other
private _sizes = ["R_PG32V_F", "mini_Grenade"];
private _ammo = _sizes select ((ADDON getVariable ["Drone_Charge", "MEDIUM"]) == "SMALL");
if !(isClass (configFile >> "CfgAmmo" >> _ammo)) then { _ammo = (_sizes - [_ammo]) select 0 };
if !(isClass (configFile >> "CfgAmmo" >> _ammo)) exitWith {
    if (_debug) then { ["ALIVE-%1 FPV drone: no warhead class found, no drone launched", time] call ALiVE_fnc_dump };
    objNull
};

// launched 20 m up, 15 to 25 m behind the group's leader, away from the player
private _p = (getPosATL _lead) getPos [15 + random 10, _target getDir _lead];
_p set [2, 20];
private _uav = createVehicle [_class, _p, [], 0, "FLY"];
if (isNull _uav) exitWith { objNull };
_uav setPosATL _p;
createVehicleCrew _uav;
private _crew = crew _uav;
if (_crew isEqualTo []) exitWith { deleteVehicle _uav; objNull };
if ((side group (_crew select 0)) != _side) then {
    private _g = createGroup [_side, true];
    if (!isNull _g) then { _crew joinSilent _g };
};
private _dg = group (_crew select 0);
// kept on the server: off the AI distributor and ACE's headless client, and out of advanced civilians
{
    _x setVariable ["ALiVE_ignore_HC", true, true];
    _x setVariable ["acex_headless_blacklist", true, true];
    _x setVariable ["ALiVE_advciv_blacklist", true, true];
} forEach ([_uav, _dg] + _crew);
// Crows Electronic Warfare: a drone signal its Spectrum Device can find and its drone jammers can jam. The mod gives one
// to the classes in its own drone list (the vanilla quadcopter is in it); a Drone Class outside that list gets one here.
if (!isNil "crowsEW_spectrum_fnc_initDroneSignals"
    && {((((missionNamespace getVariable ["crowsEW_spectrum_defaultClassForJammingSignal", ""]) splitString ",") apply { trim _x }) findIf { _x != "" && {_uav isKindOf _x} }) < 0}) then {
    [_uav] call crowsEW_spectrum_fnc_initDroneSignals;
};
_dg setBehaviour "CARELESS";
_dg setCombatMode "BLUE";
_dg setSpeedMode "FULL";
_dg allowFleeing 0;
// the pilot only gives the drone a crew; the flight is scripted (the AI pilot climbed away from its move orders)
{ _x disableAI "MOVE"; _x disableAI "PATH" } forEach _crew;
_uav lockDriver true;
// the FPV AI Drones mod leaves a drone alone that another script flies
_uav setVariable ["FPV_AI_Drones_managed", true, true];

// no player's UAV terminal can connect to it, joining in progress too
private _jip = format ["ALiVE_IED_droneLink_%1", netId _uav];
["nolink", [_uav]] remoteExecCall ["ALiVE_fnc_createFPVDrone", 0, _jip];

// the dummy of the warhead it carries (a model only; nothing in it can go off)
private _model = getText (configFile >> "CfgAmmo" >> _ammo >> "model");
if ((_model select [0, 1]) == "\") then { _model = _model select [1] };
if ((_model find ".") < 0) then { _model = _model + ".p3d" };
private _dummy = objNull;
if (_model != ".p3d") then {
    _dummy = createSimpleObject [_model, getPosASL _uav];
    if (!isNull _dummy) then { _dummy attachTo [_uav, [0, 0.1, -0.12]] };
};

private _d = createHashMapFromArray [
    ["uav", _uav], ["target", _target], ["ammo", _ammo], ["dummy", _dummy], ["lead", _lead], ["jip", _jip],
    ["t0", time], ["phase", "cruise"], ["gone", false], ["eh", -1], ["debug", _debug], ["marker", ""],
    ["min", 1e9], ["minBox", 1e9], ["lastDist", 1e9], ["lastPos", getPosASL _uav]
];
_target setVariable ["ALiVE_IED_droneOn", _uav];
if (isNil "ALiVE_IED_drones") then { ALiVE_IED_drones = [] };
ALiVE_IED_drones pushBack _d;
if (_debug) then {
    private _m = createMarker [format ["ALiVE_IED_drone_%1", netId _uav], getPosATL _uav];
    _m setMarkerType "mil_dot";
    _m setMarkerColor "ColorRed";
    _m setMarkerText "FPV";
    _d set ["marker", _m];
    ["ALIVE-%1 FPV drone: %2 (%3, %4 warhead) launched at %5 from %6, %7 m away", time, _class, _side, _ammo, name _target, mapGridPosition _p, round (_p distance _target)] call ALiVE_fnc_dump;
};

// ---- the flight: checks once a second; the steering runs in one frame handler ----------------------------------------

// the steering, every frame: cruise, then (from the final run) the warning hover and the dive
_d set ["lastTurn", 0];
_d set ["eh", addMissionEventHandler ["EachFrame", {
    private _d = _thisArgs select 0;
    if (_d get "gone") exitWith { removeMissionEventHandler ["EachFrame", _thisEventHandler] };
    private _uav = _d get "uav";
    if (isNull _uav) exitWith { ["end", [_d, "deleted", false]] call ALiVE_fnc_createFPVDrone };
    private _now = diag_tickTime;
    if (!alive _uav) exitWith {
        // a crash within 8 m of him is a hit; shot down in the dive it explodes only with the setting on
        if ((_d get "lastDist") < 8) exitWith { ["blow", [_d, _d get "lastPos", "crash", true]] call ALiVE_fnc_createFPVDrone };
        if ((_d getOrDefault ["diveAt", -1]) >= 0 && {ADDON getVariable ["Drone_ShotDown", false]}) exitWith {
            ["blow", [_d, _d get "lastPos", "shot down", false]] call ALiVE_fnc_createFPVDrone
        };
        ["end", [_d, "shot down", true]] call ALiVE_fnc_createFPVDrone;
    };
    private _target = _d get "target";
    private _tv = vehicle _target;
    private _man = _tv isKindOf "Man";
    private _pos = getPosASL _uav;
    private _cpos = if (_man) then { (getPosASL _tv) vectorAdd [0, 0, 1] } else { _tv modelToWorldWorld [0, 0, 0] };
    private _dist = _pos vectorDistance _cpos;
    _d set ["lastPos", _pos];
    _d set ["lastDist", _dist];
    private _fnc_turn = {
        if (_now - (_d get "lastTurn") >= 0.25) then {
            _d set ["lastTurn", _now];
            private _up = (_this vectorCrossProduct [0, 0, 1]) vectorCrossProduct _this;
            if ((vectorMagnitude _up) < 0.1) then { _up = [0, 1, 0] };
            _uav setVectorDirAndUp [_this, vectorNormalized _up];
        };
    };

    // cruise: 40 m over the ground under it or 60 m ahead (whichever is higher; the sea counts as 0) at 15 m/s
    // towards him; held where it is while he is under a roof. The once-a-second loop starts the final run
    if ((_d get "phase") != "terminal") exitWith {
        private _flat = [(_cpos select 0) - (_pos select 0), (_cpos select 1) - (_pos select 1), 0];
        private _hd = if ((vectorMagnitude _flat) > 1) then { vectorNormalized _flat } else { [0, 0, 0] };
        private _ahead = _pos vectorAdd (_hd vectorMultiply 60);
        private _ground = ((getTerrainHeightASL _pos) max (getTerrainHeightASL _ahead)) max 0;
        private _vz = ((((_ground + 40) - (_pos select 2)) * 0.8) max -6) min 8;
        private _sp = [15, 0] select ((_d get "phase") == "roof");
        _uav setVelocity ((_hd vectorMultiply _sp) vectorAdd [0, 0, _vz]);
        if (_hd isNotEqualTo [0, 0, 0]) then { _hd call _fnc_turn };
    };
    if (!alive _target) exitWith { ["end", [_d, "the player died", true]] call ALiVE_fnc_createFPVDrone };

    // the warning: about 25 m over him for 4 s (reached at up to 22 m/s, at most 15 s), following him
    if ((_d getOrDefault ["diveAt", -1]) < 0) exitWith {
        private _want = (getPosASL _tv) vectorAdd [0, 0, 25];
        private _v = (velocity _tv) vectorAdd ((_want vectorDiff _pos) vectorMultiply 1.5);
        if ((vectorMagnitude _v) > 22) then { _v = (vectorNormalized _v) vectorMultiply 22 };
        _uav setVelocity _v;
        private _flat = [(_want select 0) - (_pos select 0), (_want select 1) - (_pos select 1), 0];
        if ((vectorMagnitude _flat) > 1) then { (vectorNormalized _flat) call _fnc_turn };
        if ((_d get "hoverAt") < 0 && {(_pos vectorDistance _want) < 10}) then { _d set ["hoverAt", _now] };
        if (((_d get "hoverAt") >= 0 && {_now - (_d get "hoverAt") >= 4}) || {_now > (_d get "hoverLimit")}) then {
            _d set ["diveAt", _now];
            _d set ["prev", _pos];
        };
    };

    // the dive: closest approach measured between this frame and the last, so a low frame rate can't
    // skip past him
    private _a = _d get "prev";
    private _ab = _pos vectorDiff _a;
    private _l2 = _ab vectorDotProduct _ab;
    private _u = if (_l2 > 0) then { (((_cpos vectorDiff _a) vectorDotProduct _ab) / _l2) max 0 min 1 } else { 0 };
    private _cp = _a vectorAdd (_ab vectorMultiply _u);
    private _dc = _cp vectorDistance _cpos;
    if (_dc < (_d get "min")) then {
        _d set ["min", _dc];
        private _mp = _tv worldToModel (ASLToAGL _cp);
        (boundingBoxReal _tv) params ["_lo", "_hi"];
        private _q = [0, 1, 2] apply { 0 max (((_lo select _x) - (_mp select _x)) max ((_mp select _x) - (_hi select _x))) };
        _d set ["minBox", vectorMagnitude _q];
    };
    _d set ["prev", _pos];
    private _fuse = switch (true) do {
        case (!_man && {(_d get "minBox") < 1}): { "hit" };
        case (_man && {_dist < 2.5}): { "hit" };
        case ((_d get "min") < 8 && {_dist > (_d get "min") + 1}): { "passing" };
        default { "" };
    };
    if (_fuse != "") exitWith { ["blow", [_d, _pos, _fuse, true]] call ALiVE_fnc_createFPVDrone };
    if (_now - (_d get "diveAt") > 15) exitWith { ["blow", [_d, _pos, "15 s in the dive", false]] call ALiVE_fnc_createFPVDrone };
    if (((getPosATL _uav) select 2) < 1.5 && {_dist > 4}) exitWith { ["blow", [_d, _pos, "ground", false]] call ALiVE_fnc_createFPVDrone };
    private _dir = vectorNormalized (_cpos vectorAdd ((velocity _tv) vectorMultiply ((_dist / 22) min 3)) vectorDiff _pos);
    _dir call _fnc_turn;
    _uav setVelocity (_dir vectorMultiply 22);
}, [_d]]];


[_d] spawn {
    params ["_d"];
    private _uav = _d get "uav";
    private _stuckPos = getPosATL _uav;
    private _stuckAt = time;
    private _roofSince = -1;
    private _retargeted = false;
    private _jamOn = ADDON getVariable ["Drone_Jammed", true];
    private _fnc_end = { ["end", [_d, _this select 0, _this select 1]] call ALiVE_fnc_createFPVDrone };

    while { !(_d get "gone") } do {
        sleep 1;
        if (_d get "gone") exitWith {};
        if (isNull ADDON) exitWith { ["the IED module is gone", false] call _fnc_end };
        if (isNull _uav) exitWith { ["deleted", false] call _fnc_end };
        // in the dive the frame handler decides what a death means
        if (!alive _uav && {(_d get "phase") != "terminal"}) exitWith { ["shot down", true] call _fnc_end };
        if (!alive _uav) then { continue };
        if (!local _uav) exitWith { ["no longer run by the server", true] call _fnc_end };
        // a player's UAV terminal has it (a server sees that through UAVControl only)
        if (!isNull ((UAVControl _uav) param [0, objNull])) exitWith { ["taken over by a UAV terminal", true] call _fnc_end };
        if (_jamOn && {[_uav, -1, true] call ALiVE_fnc_iedJammerNear}) exitWith { ["jammed", true] call _fnc_end };
        // another mod's jammer that kills its AI pilot or drains its fuel: nothing flies it any more, whatever
        // Jammers Stop Drones says (that setting covers ALiVE's own jammer checks above)
        if (((crew _uav) findIf { alive _x }) < 0) exitWith { ["no pilot (jammed by another mod?)", true] call _fnc_end };
        if ((fuel _uav) <= 0) exitWith { ["no fuel (jammed by another mod?)", true] call _fnc_end };
        if (time - (_d get "t0") > 240) exitWith { ["out of battery", true] call _fnc_end };
        private _players = allPlayers - entities "HeadlessClient_F";
        if ((_players findIf { (_x distance _uav) < 1500 }) < 0) exitWith { ["no player within 1500 m", false] call _fnc_end };
        if ((_d get "marker") != "") then { (_d get "marker") setMarkerPos getPosATL _uav };

        // the player: alive, on the ground, not in an aircraft; once, the nearest other player within 200 m instead
        private _target = _d get "target";
        private _tv = vehicle _target;
        private _fit = { alive _this && {!((vehicle _this) isKindOf "Air")} && {((getPosATL (vehicle _this)) select 2) < 25} };
        if !(_target call _fit) then {
            private _next = objNull;
            if (!_retargeted) then {
                _retargeted = true;
                private _near = _players select { _x != _target && {_x call _fit} && {(_x distance _uav) < 200} && {!(_x call ALiVE_fnc_iedBomberSpares)}
                    && {isNull (_x getVariable ["ALiVE_IED_droneOn", objNull])} };
                if (_near isNotEqualTo []) then {
                    _near = _near apply { [_x distance _uav, _x] };
                    _near sort true;
                    _next = (_near select 0) select 1;
                };
            };
            if (isNull _next) exitWith {};
            if (!isNull _target && {(_target getVariable ["ALiVE_IED_droneOn", objNull]) isEqualTo _uav}) then { _target setVariable ["ALiVE_IED_droneOn", objNull] };
            _next setVariable ["ALiVE_IED_droneOn", _uav];
            _d set ["target", _next];
            if (_d get "debug") then { ["ALIVE-%1 FPV drone: target lost, now after %2", time, name _next] call ALiVE_fnc_dump };
        };
        _target = _d get "target";
        if !(_target call _fit) exitWith { ["the player is gone, dead or in the air", false] call _fnc_end };
        _tv = vehicle _target;

        if ((_d get "phase") == "terminal") then { continue };

        // cruise: flown into something
        if (time - _stuckAt >= 10) then {
            if ((_stuckPos distance (getPosATL _uav)) < 5 && {(_d get "phase") == "cruise"}) exitWith { ["crashed or stuck", true] call _fnc_end };
            _stuckPos = getPosATL _uav;
            _stuckAt = time;
        };
        if (_d get "gone") exitWith {};

        // the final run: under 150 m away with a line of sight; never at a player under a roof
        if ((_uav distance2D _tv) < 150 && {([_uav, "VIEW", _tv] checkVisibility [getPosASL _uav, (getPosASL _tv) vectorAdd [0, 0, 1.5]]) > 0.3}) then {
            if (["roofed", [_tv]] call ALiVE_fnc_createFPVDrone) then {
                if (_roofSince < 0) then {
                    _roofSince = time;
                    _d set ["phase", "roof"];
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: %2 is under a roof, waiting", time, name _target] call ALiVE_fnc_dump };
                };
            } else {
                _roofSince = -1;
                _d set ["hoverAt", -1];
                _d set ["hoverLimit", diag_tickTime + 15];
                _d set ["prev", getPosASL _uav];
                _d set ["phase", "terminal"];
                if (_d get "debug") then { ["ALIVE-%1 FPV drone: final run at %2, %3 m away, %4 m up", time, name _target, round (_uav distance _tv), round ((getPosATL _uav) select 2)] call ALiVE_fnc_dump };
            };
        } else {
            if ((_d get "phase") == "roof") then { _d set ["phase", "cruise"]; _roofSince = -1 };
        };
        // under a roof for 20 s: it gives up
        if (_roofSince >= 0 && {time - _roofSince > 20}) exitWith { ["the player stayed under a roof", false] call _fnc_end };
    };
    ALiVE_IED_drones = ALiVE_IED_drones - [_d];
};

_uav
