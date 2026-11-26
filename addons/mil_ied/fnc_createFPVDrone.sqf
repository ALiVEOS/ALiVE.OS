#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(createFPVDrone);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_createFPVDrone
Description:
An FPV suicide drone sent at a player by the bomber and drone dispatcher (fnc_IED "bomberDispatch").

The drone is the side's vanilla quadcopter (or Drone Class) with a dummy of its warhead under it. It flies to the
player 40 m over the ground at 15 m/s; within 150 m it makes its attack run, swinging in from a random side and
weaving as it closes (the warning is its rotors), then dives. When it reaches him it is
removed and the real warhead is made and set off there (measured on the NUC, DRN46 to DRN51: a warhead carried on
the drone does not hurt a vehicle; one made at the moment of the hit does, if it comes in 45 degrees down from in
front of the vehicle). Downed (shot down in any phase, crashed or stuck, or out of battery after Drone Battery
minutes), it explodes where it hits the ground with the Chance To Explode When Downed, otherwise it drops. Jammed
(another mod's jammer that kills its AI pilot or drains its fuel counts), taken over by a UAV terminal or no longer
run by the server, it always drops without exploding.

A dropper (Dropper Drones, the chance a launch is one) flies to its target the same way, but makes no attack run:
from 150 m it closes to about 30 m over him and drops 2 or 3 hand grenades, one every 2.5 s, each made under the
drone as it is let go and set off when it strikes something on the way down (or after 6 s), credited to the drone
and its pilot. It aims where he will be when a grenade lands (his ground speed over the fall time), and waits while
he moves faster than 12 m/s. A drop is held while anyone friendly to the drone's side is within 15 m of where it
would land, while he is under a roof, or while a jammer is in reach; after its drops, or 40 s over him whatever has
dropped, it climbs away for 25 s and is removed. Jammed (the same checks as an FPV drone, below), it falls with its
grenades still on it: nothing is released once a jam is found, and none is released while a soft jam holds it.

A roaming drone (Roaming Drones) is launched from an objective its side holds with no player in mind: it flies a
loose box 300 to 500 m round the site, then round where its side last knew a player to be, until it sees a player
of a hostile side within 300 m; from then on it flies at him like any other drone.

Everything runs on the server. The drone has no profile and is never saved. Each drone carries a server-local
ALiVE_IED_droneInfo, [phase, target, from, launched, battery end], for the War Room's live map.

Parameters:
0: OBJECT - the player (objNull for a roaming drone)
1: GROUP - the AI Commander's group that spotted him and launches it (grpNull for a roaming drone)
2: ARRAY - a roaming drone: the position of the objective it is launched from
3: SIDE - a roaming drone: its side
4: STRING - (optional) the kind: "dropper" or "fpv" for that kind, "" (default) rolls Dropper Drones

or a mode: ["eyes", [players]] (where they watch from: each body, and a Zeus's camera), ["nolink", [drone]] (every client: its UAV terminal can't connect to the drone),
["roofed", [unit or vehicle]] (is there a roof within 3 m over him), ["height", [object]] (its height over the
ground, or over the sea where it is over water), ["blow", [state, position ASL, fuse, on target]],
["downed", [state, reason]], ["info", [state]] and ["end", [state, reason, drop]] (server).

Returns:
OBJECT - the drone, or objNull when none was launched (create); BOOL (roofed); NUMBER (height)

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

        case "eyes": {
            // where the players are watching from: each player's body, and a Zeus's camera too (fnc_ZEUSinit moves
            // his Zeus module to it every second and parks it at [-5000,-5000] when he is out of the Zeus interface;
            // the camera itself exists only on his own machine). Positions ATL
            _args params [["_players", [], [[]]]];
            private _eyes = [];
            {
                _eyes pushBack (getPosATL _x);
                private _c = getAssignedCuratorLogic _x;
                if (!isNull _c && {((getPosATL _c) distance2D [-5000, -5000]) > 100}) then { _eyes pushBack (getPosATL _c) };
            } forEach _players;
            _eyes
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

        case "height": {
            // how high it is over what is under it: the ground, or the sea over water (getPosATL there is measured
            // from the sea bed, so a boat on deep water read as far up in the air)
            _args params [["_o", objNull, [objNull]]];
            private _p = getPosASL _o;
            if (surfaceIsWater _p) then { _p select 2 } else { (getPosATL _o) select 2 }
        };

        case "blow": {
            // the warhead goes off: the drone and its dummy are removed and the real warhead is made and set off.
            // On target (a hit, or a crash within 8 m of him): for a vehicle from above, just off the armour over
            // its engine; for a man 0.5 m back along the line to his chest. Elsewhere, where the drone was
            _args params ["_d", "_pos", ["_fuse", ""], ["_onTarget", false]];
            if (_d getOrDefault ["gone", false]) exitWith {};
            _d set ["gone", true];
            private _eh = _d getOrDefault ["eh", -1];
            if (_eh >= 0) then { removeMissionEventHandler ["EachFrame", _eh]; _d set ["eh", -1] };
            private _uav = _d get "uav";
            private _dummy = _d get "dummy";
            private _tgt = vehicle (_d get "target");
            if (!isNull _dummy) then { deleteVehicle _dummy };
            // the drone's body must not take the blast: moved well away this frame, hidden, and deleted 5 minutes
            // later. It is kept because the blast is credited to it and its pilot, and with ACE a man it hurts can die
            // well after the blast (one bled out 17 s later): a kill whose shooter no longer exists was put down to the
            // dead man's own vehicle ("Run over (GAZ-233114)", friendly fire)
            private _pilot = objNull;
            if (!isNull _uav) then {
                _pilot = (crew _uav) param [0, objNull];
                _uav setVariable ["ALiVE_IED_fpvStrike", true, true];
                _uav setPosASL (_pos vectorAdd [0, 0, 400]);
                _uav allowDamage false;
                { _x allowDamage false } forEach (crew _uav);
                _uav hideObjectGlobal true;
                _uav enableSimulationGlobal false;
                [_uav] spawn {
                    params ["_uav"];
                    sleep 300;
                    if (!isNull _uav) then { { deleteVehicle _x } forEach (crew _uav); deleteVehicle _uav };
                };
            };
            private _dir = [0, 0, -1];
            private _pp = _pos;
            if (_onTarget && {!isNull _tgt}) then {
                if (_tgt isKindOf "Man") then {
                    private _v = ((getPosASL _tgt) vectorAdd [0, 0, 1]) vectorDiff _pos;
                    if ((vectorMagnitude _v) > 0.01) then { _dir = vectorNormalized _v };
                    _pp = _pos vectorAdd (_dir vectorMultiply -0.5);
                } else {
                    // from above, onto the engine (the roof is a tank's thinnest armour, and the engine under it
                    // is what stops it), or the centre when the model names no engine
                    _dir = vectorNormalized (((vectorDir _tgt) vectorMultiply 0.2) vectorAdd [0, 0, -1]);
                    private _hp = getAllHitPointsDamage _tgt;
                    private _ei = if (_hp isEqualTo []) then { -1 } else { (_hp select 0) findIf { _x == "HitEngine" } };
                    private _mp = [0, 0, 0];
                    if (_ei >= 0) then {
                        private _sp = _tgt selectionPosition [(_hp select 1) select _ei, "HitPoints"];
                        if (_sp isNotEqualTo [0, 0, 0]) then { _mp = _sp };
                    };
                    private _c = _tgt modelToWorldWorld _mp;
                    _pp = _c vectorAdd (_dir vectorMultiply -2.5);
                    // a fixed 2.5 m can be inside a big hull, or short of it: the charge goes 0.5 m out from the
                    // armour, found along the same line from 10 m out
                    private _far = _c vectorAdd (_dir vectorMultiply -10);
                    private _s = (lineIntersectsSurfaces [_far, _c, objNull, objNull, true, 1, "FIRE", "GEOM"]) select { (_x select 2) isEqualTo _tgt || {(_x select 3) isEqualTo _tgt} };
                    if (_s isNotEqualTo []) then { _pp = ((_s select 0) select 0) vectorAdd (_dir vectorMultiply -0.5) };
                };
            };
            // the target and everyone in it are marked as struck by this drone: a man it hurts often dies later of
            // his wrecked vehicle burning or blowing up, which the game credits to nobody, or to the vehicle itself,
            // and the statistics kill record then credits the drone (it is kept 5 minutes, below)
            if (_onTarget && {!isNull _tgt} && {!isNull _uav}) then {
                { _x setVariable ["ALiVE_IED_fpvHit", [_uav, serverTime], true] } forEach ([_tgt] + crew _tgt);
            };
            private _ch = createVehicle [_d get "ammo", ASLToAGL _pp, [], 0, "CAN_COLLIDE"];
            _ch setPosASL _pp;
            // straight down has no "up" from the world's vertical
            private _up = (_dir vectorCrossProduct [0, 0, 1]) vectorCrossProduct _dir;
            if ((vectorMagnitude _up) < 0.1) then { _up = [0, 1, 0] };
            _ch setVectorDirAndUp [_dir, vectorNormalized _up];
            _ch setVelocity (_dir vectorMultiply 22);
            // credited to the drone and its pilot, so a kill reads as the drone's and its side's; the launching
            // group's leader when the drone is gone
            private _lead = _d get "lead";
            private _parents = if (!isNull _uav && {!isNull _pilot}) then { [_uav, _pilot] } else { if (alive _lead) then { [_lead, _lead] } else { [] } };
            if (_parents isNotEqualTo []) then { _ch setShotParents _parents };
            triggerAmmo _ch;
            // a Large charge is a tandem: the anti-tank warhead with a rocket warhead behind it, so a tank it reaches
            // is not left with only a scratch when the first one finds no weak spot
            if ((_d get "ammo") == "M_Titan_AT" && {isClass (configFile >> "CfgAmmo" >> "R_PG32V_F")}) then {
                private _ch2 = createVehicle ["R_PG32V_F", ASLToAGL _pp, [], 0, "CAN_COLLIDE"];
                _ch2 setPosASL (_pp vectorAdd (_dir vectorMultiply -0.3));
                _ch2 setVectorDirAndUp [_dir, vectorNormalized _up];
                _ch2 setVelocity (_dir vectorMultiply 22);
                if (_parents isNotEqualTo []) then { _ch2 setShotParents _parents };
                triggerAmmo _ch2;
            };
            ["end", [_d, format ["exploded (%1)", _fuse], false]] call ALiVE_fnc_createFPVDrone;
        };

        case "release": {
            // a dropper lets one grenade go: made half a metre under the drone, falling straight down at 1 m/s (it does
            // not take the drone's speed; the aim allows for that), credited to the drone and its pilot (the launching
            // group's leader when the pilot is gone), and set off in the frame it would strike something below it, the
            // ground, a roof or a vehicle, or 6 s after it is let go. The target and everyone in it are marked as struck
            // by this drone, as for an FPV hit, for a death that comes later
            _args params ["_d"];
            private _uav = _d get "uav";
            if (isNull _uav || {!alive _uav}) exitWith {};
            private _pilot = (crew _uav) param [0, objNull];
            private _p = (getPosASL _uav) vectorAdd [0, 0, -0.5];
            private _g = createVehicle [_d get "ammo", ASLToAGL _p, [], 0, "CAN_COLLIDE"];
            if (isNull _g) exitWith {};
            _g setPosASL _p;
            _g setVelocity [0, 0, -1];
            private _lead = _d get "lead";
            private _parents = if (!isNull _pilot) then { [_uav, _pilot] } else { if (alive _lead) then { [_lead, _lead] } else { [] } };
            if (_parents isNotEqualTo []) then { _g setShotParents _parents };
            private _tgt = vehicle (_d get "target");
            if (!isNull _tgt) then { { _x setVariable ["ALiVE_IED_fpvHit", [_uav, serverTime], true] } forEach ([_tgt] + crew _tgt) };
            addMissionEventHandler ["EachFrame", {
                _thisArgs params ["_g", "_t0", "_tgt", "_d"];
                if (isNull _g) exitWith { removeMissionEventHandler ["EachFrame", _thisEventHandler] };
                private _gp = getPosASL _g;
                if (diag_tickTime - _t0 > 6 || {(lineIntersectsSurfaces [_gp, _gp vectorAdd ((velocity _g) vectorMultiply 0.05) vectorAdd [0, 0, -0.3], _g, objNull, true, 1]) isNotEqualTo []}) then {
                    removeMissionEventHandler ["EachFrame", _thisEventHandler];
                    // how far from its target each went off, kept on the drone's state for the debug line and for tests
                    private _miss = if (isNull _tgt) then { -1 } else { (ASLToAGL _gp) distance2D _tgt };
                    (_d get "bursts") pushBack _miss;
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: a dropped grenade went off %2 m from its target", time, [round _miss, "-"] select (_miss < 0)] call ALiVE_fnc_dump };
                    triggerAmmo _g;
                };
            }, [_g, diag_tickTime, _tgt, _d]];
            _d set ["dropped", (_d get "dropped") + 1];
            if (_d get "debug") then {
                ["ALIVE-%1 FPV drone: the dropper let grenade %2 of %3 go at %4, %5 m up, %6 m from %7", time, _d get "dropped", _d get "drops", mapGridPosition _uav,
                    round ((_p select 2) - ((getPosASL _tgt) select 2)), round (_uav distance2D _tgt), if (isNull _tgt) then { "nobody" } else { [typeOf _tgt, name _tgt] select (_tgt isKindOf "Man") }] call ALiVE_fnc_dump;
            };
        };

        case "downed": {
            // shot down, crashed, stuck or out of battery: one roll of Chance To Explode When Downed (0 to 100; the
            // old Yes and No read as 100 and 0). Yes: no more steering, it falls, and its warhead goes off where it
            // hits the ground (or after 6 s). No: it drops without exploding
            _args params ["_d", ["_why", ""]];
            if (_d getOrDefault ["gone", false] || {_d getOrDefault ["falling", false]}) exitWith {};
            private _c = ADDON getVariable ["Drone_ShotDown", 50];
            if (_c isEqualType true) then { _c = [0, 100] select _c };
            if !(_c isEqualType 0) then { _c = 50 };
            if ((random 100) >= _c) exitWith { ["end", [_d, _why + ", did not go off", true]] call ALiVE_fnc_createFPVDrone };
            _d set ["falling", true];
            _d set ["phase", "drop"];
            ["info", [_d]] call ALiVE_fnc_createFPVDrone;
            private _eh = _d getOrDefault ["eh", -1];
            if (_eh >= 0) then { removeMissionEventHandler ["EachFrame", _eh]; _d set ["eh", -1] };
            private _uav = _d get "uav";
            if (alive _uav) then { _uav setFuel 0 };
            [_d, _why] spawn {
                params ["_d", "_why"];
                private _uav = _d get "uav";
                private _t = time;
                waitUntil {
                    sleep 0.05;
                    isNull _uav || {_d get "gone"} || {time - _t > 6} || {((getPosATL _uav) select 2) < 1.2}
                        || {time - _t > 1 && {(vectorMagnitude (velocity _uav)) < 0.5}}
                };
                private _pos = if (isNull _uav) then { _d get "lastPos" } else { getPosASL _uav };
                ["blow", [_d, _pos, _why, false]] call ALiVE_fnc_createFPVDrone;
            };
        };

        case "info": {
            // ALiVE_IED_droneInfo on the drone, server-local, for the War Room's live map: [phase ("search", "cruise",
            // "attack", "hover" (waiting over a player under a roof), "dive" or "drop"), target or objNull, the launching group or the objective position it roams
            // from, launch time, battery end time]; updated when the phase or the target changes
            _args params ["_d"];
            private _uav = _d get "uav";
            if (isNull _uav) exitWith {};
            private _phase = switch (_d get "phase") do {
                case "terminal": { ["attack", "dive"] select ((_d getOrDefault ["diveAt", -1]) >= 0) };
                case "roof": { "hover" };
                // a dropper over its target, and flying off after its drops
                case "bomb": { "attack" };
                case "leave": { "cruise" };
                default { _d get "phase" };
            };
            _uav setVariable ["ALiVE_IED_droneInfo", [_phase, _d get "target", _d get "from", _d get "t0", _d get "batteryEnd"]];
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
            if (_drop) then { _d set ["phase", "drop"]; ["info", [_d]] call ALiVE_fnc_createFPVDrone };
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
                    // a dropper that has let grenades go is kept the same way, hidden, for 5 minutes
                    if ((_d get "dropper") && {(_d get "dropped") > 0} && {!(_uav getVariable ["ALiVE_IED_fpvStrike", false])}) then {
                        _uav setVariable ["ALiVE_IED_fpvStrike", true, true];
                        _uav allowDamage false;
                        { _x allowDamage false } forEach (crew _uav);
                        _uav hideObjectGlobal true;
                        _uav enableSimulationGlobal false;
                        [_uav] spawn {
                            params ["_uav"];
                            sleep 300;
                            if (!isNull _uav) then { { deleteVehicle _x } forEach (crew _uav); deleteVehicle _uav };
                        };
                    };
                    // a drone that has just struck is kept, hidden, until its blast has been credited (see "blow")
                    if !(_uav getVariable ["ALiVE_IED_fpvStrike", false]) then {
                        { deleteVehicle _x } forEach (crew _uav);
                        deleteVehicle _uav;
                    };
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
                    [(_d get "min") toFixed 1, "-"] select ((_d get "min") > 1e8), if (isNull _target) then { "nobody" } else { [typeOf _target, name _target] select (_target isKindOf "Man") }] call ALiVE_fnc_dump;
            };
        };
    };
};

// ---- create --------------------------------------------------------------------------------------------------------

params [["_target", objNull, [objNull]], ["_grp", grpNull, [grpNull]], ["_site", [], [[]]], ["_roamSide", sideUnknown, [west]], ["_kind", "", [""]]];
private _roam = isNull _target && {isNull _grp} && {count _site >= 2} && {_roamSide in [west, east, independent]};
if (!isServer || {!_roam && {isNull _target || {isNull _grp}}}) exitWith { objNull };

private _debug = ADDON getVariable ["debug", false];
private _side = [side _grp, _roamSide] select _roam;
private _lead = leader _grp;

// the class: Drone Class, or the launching group's side's own: a Crocus FPV drone with that mod loaded (AP for a
// Small charge, AT for Medium), otherwise the vanilla quadcopter
private _fallback = switch (_side) do { case west: { "B_UAV_01_F" }; case independent: { "I_UAV_01_F" }; default { "O_UAV_01_F" } };
if (isClass (configFile >> "CfgVehicles" >> "ARMAFPV_Crocus_AT_Base")) then {
    private _crocus = format ["%1_Crocus_%2", ["O", "B", "I"] select (([east, west, independent] find _side) max 0),
        ["AT", "AP"] select ((ADDON getVariable ["Drone_Charge", "MEDIUM"]) == "SMALL")];
    if (isClass (configFile >> "CfgVehicles" >> _crocus)) then { _fallback = _crocus };
};
private _class = ADDON getVariable ["Drone_Class", ""];
if (_class != "" && {!isClass (configFile >> "CfgVehicles" >> _class) || {getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") != 1}}) then {
    if (_debug) then { ["ALIVE-%1 FPV drone: Drone Class %2 is not a drone, using %3", time, _class, _fallback] call ALiVE_fnc_dump };
    _class = "";
};
if (_class == "") then { _class = _fallback };

// the warhead: Large the Titan's top-attack anti-tank warhead, Medium a rocket warhead, Small a grenade; a missing
// class falls back to the next one that exists
private _sizes = ["M_Titan_AT", "R_PG32V_F", "mini_Grenade"];
private _ammo = _sizes select ((["LARGE", "MEDIUM", "SMALL"] find (ADDON getVariable ["Drone_Charge", "MEDIUM"])) max 0);
if !(isClass (configFile >> "CfgAmmo" >> _ammo)) then { _ammo = (_sizes select { isClass (configFile >> "CfgAmmo" >> _x) }) param [0, ""] };
if (_ammo == "") then { _ammo = "mini_Grenade" };
if !(isClass (configFile >> "CfgAmmo" >> _ammo)) exitWith {
    if (_debug) then { ["ALIVE-%1 FPV drone: no warhead class found, no drone launched", time] call ALiVE_fnc_dump };
    objNull
};
// Dropper Drones: the chance this one is a dropper, which carries hand grenades instead of a warhead (its dummy, and
// what goes off if it is downed, is one of them). An AI Commander's Drone Support asks for the kind it wants
private _dropper = switch (_kind) do {
    case "dropper": { true };
    case "fpv": { false };
    default { (random 100) < (ADDON getVariable ["Drone_Dropper", 0]) };
};
if (_dropper) then {
    private _g = (["GrenadeHand", "mini_Grenade"] select { isClass (configFile >> "CfgAmmo" >> _x) }) param [0, ""];
    if (_g == "") then { _dropper = false } else { _ammo = _g };
};

// launched 20 m up, 15 to 25 m behind the group's leader, away from the player; a roaming drone within 50 m of
// its objective
private _p = if (_roam) then { _site getPos [random 50, random 360] } else { (getPosATL _lead) getPos [15 + random 10, _target getDir _lead] };
_p set [2, 20];
private _uav = createVehicle [_class, _p, [], 0, "FLY"];
if (isNull _uav) exitWith { objNull };
_uav setPosATL _p;
createVehicleCrew _uav;
private _crew = crew _uav;
if (_crew isEqualTo []) exitWith { deleteVehicle _uav; objNull };
if ((side group (_crew select 0)) != _side) then {
    private _g = createGroup [_side, true];
    if (!isNull _g) then {
        // the crew's own group, of the class's side, is left empty: gone too
        private _old = group (_crew select 0);
        _crew joinSilent _g;
        if (!isNull _old && {(units _old) isEqualTo []}) then { deleteGroup _old };
    };
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

// the dummy of the warhead it carries (a model only; nothing in it can go off; a Large one shows the rocket
// warhead, the Titan's own model being a whole missile)
private _model = getText (configFile >> "CfgAmmo" >> (["R_PG32V_F", _ammo] select (_ammo != "M_Titan_AT")) >> "model");
if ((_model select [0, 1]) == "\") then { _model = _model select [1] };
if ((_model find ".") < 0) then { _model = _model + ".p3d" };
// (a Crocus carries its own on the model)
private _isCrocus = _class isKindOf "ARMAFPV_Crocus_AT_Base";
// a Crocus sets its own warhead off at any hit (a branch on the way in will do), unless told it is already going
// off: told so from the start, so the warhead goes off only when this flight sets it off, as with any other drone
if (_isCrocus) then {
    _uav setVariable ["DB_fpv_isDetonating", true, true];
    // the mod launches its drone captive, and nobody shoots at a captive: this one can be shot at like any other
    _uav setCaptive false;
    { _x setCaptive false } forEach crew _uav;
    // and it is built to break at a light knock (armour 0.5, five times the impact damage): a bump on the scripted
    // flight is ignored, while bullets and blasts still bring it down
    _uav addEventHandler ["HandleDamage", {
        params ["_u", "", "_dmg", "_src", "_proj", "_idx"];
        if (_proj isEqualTo "" && {isNull _src || {_src isEqualTo _u}}) exitWith {
            if (ADDON getVariable ["debug", false] && {_dmg > 0.05}) then { ["ALIVE-%1 FPV drone: a bump on the Crocus ignored (%2)", time, _dmg toFixed 2] call ALiVE_fnc_dump };
            if (_idx < 0) then { damage _u } else { _u getHitIndex _idx }
        };
        _dmg
    }];
};
private _dummy = objNull;
if (_model != ".p3d" && {!_isCrocus}) then {
    _dummy = createSimpleObject [_model, getPosASL _uav];
    if (!isNull _dummy) then { _dummy attachTo [_uav, [0, 0.1, -0.12]] };
};

// Drone Battery, in minutes (blank or under 1 keeps 10)
private _battery = ADDON getVariable ["Drone_Battery", 10];
if (!(_battery isEqualType 0) || {_battery < 1}) then { _battery = 10 };
private _d = createHashMapFromArray [
    ["uav", _uav], ["target", _target], ["ammo", _ammo], ["dummy", _dummy], ["lead", _lead], ["jip", _jip],
    ["t0", time], ["phase", ["cruise", "search"] select _roam], ["gone", false], ["eh", -1], ["debug", _debug], ["marker", ""],
    ["min", 1e9], ["minBox", 1e9], ["lastDist", 1e9], ["lastPos", getPosASL _uav],
    ["side", _side], ["from", [_grp, _site] select _roam], ["batteryEnd", time + 60 * _battery],
    // a player further than this from the drone: it is called back
    ["recall", [1500, 2500] select _roam],
    // Medium and Large charges go after crewed vehicles too, AI-crewed ones included
    ["vehicles", (ADDON getVariable ["Drone_Charge", "MEDIUM"]) != "SMALL"],
    // Drone Targets Players and AI: a searching drone also takes hostile AI on foot
    ["ai", (ADDON getVariable ["Drone_Targets", "PLAYERS"]) == "ALL"],
    // Drones Also Hit Abandoned Vehicles (Medium and Large only): empty, knocked-out hostile vehicles too
    ["abandoned", (ADDON getVariable ["Drone_Abandoned", false]) && {(ADDON getVariable ["Drone_Charge", "MEDIUM"]) != "SMALL"}],
    // Drones Also Hit Boats (Medium and Large only): a player in a boat, and crewed boats of a hostile side
    ["boats", (ADDON getVariable ["Drone_Boats", false]) && {(ADDON getVariable ["Drone_Charge", "MEDIUM"]) != "SMALL"}],
    // a dropper: how many grenades it carries, how many it has let go, and when the next may go
    ["dropper", _dropper], ["drops", 2 + floor random 2], ["dropped", 0], ["nextDrop", -1], ["dropCheck", -1], ["bursts", []]
];
if (_roam) then {
    // the search: a loose box of four legs 300 to 500 m round a centre, flown at cruise height
    private _r = 300 + random 200;
    private _a = random 360;
    _d set ["legs", [0, 90, 180, 270] apply { _site getPos [_r * (0.85 + random 0.3), _a + _x + (random 20) - 10] }];
    _d set ["leg", 0];
    _d set ["wp", (_d get "legs") select 0];
} else {
    _target setVariable ["ALiVE_IED_droneOn", _uav];
};
["info", [_d]] call ALiVE_fnc_createFPVDrone;
if (isNil "ALiVE_IED_drones") then { ALiVE_IED_drones = [] };
ALiVE_IED_drones pushBack _d;
if (_roam) then {
    ["ALIVE-%1 FPV drone: a roaming %2 drone (%3) launched from the objective at %4", time, _side, _class, mapGridPosition _site] call ALiVE_fnc_dump;
};
if (_debug) then {
    private _m = createMarker [format ["ALiVE_IED_drone_%1", netId _uav], getPosATL _uav];
    _m setMarkerType "mil_dot";
    _m setMarkerColor "ColorRed";
    _m setMarkerText (["FPV", "Dropper"] select _dropper);
    _d set ["marker", _m];
    if (!_roam) then {
        ["ALIVE-%1 FPV drone: %2 (%3, %4 %5) launched at %6 from %7, %8 m away", time, _class, _side, _ammo, ["warhead", format ["dropper, %1 grenades", _d get "drops"]] select _dropper, ([typeOf _target, name _target] select (_target isKindOf "Man")), mapGridPosition _p, round (_p distance _target)] call ALiVE_fnc_dump;
    };
};

// ---- the flight: checks once a second; the steering runs in one frame handler ----------------------------------------

// the steering, every frame: cruise, then (from the final run) the warning hover and the dive
_d set ["lastTurn", 0];
_d set ["eh", addMissionEventHandler ["EachFrame", {
    private _d = _thisArgs select 0;
    if (_d get "gone") exitWith { removeMissionEventHandler ["EachFrame", _thisEventHandler] };
    private _uav = _d get "uav";
    if (isNull _uav) exitWith { ["end", [_d, "deleted", false]] call ALiVE_fnc_createFPVDrone };
    // held while the server is paused (the once-a-second loop below): no steering
    if ((_d getOrDefault ["heldAt", -1]) >= 0) exitWith {};
    // held still by a soft jam (Military Container Systems, the once-a-second loop below)
    if (alive _uav && {(_d getOrDefault ["jamTick", -1]) >= 0}) exitWith { _uav setVelocity [0, 0, 0] };
    private _now = diag_tickTime;
    if (!alive _uav) exitWith {
        // a crash within 8 m of him is a hit; shot down anywhere else, Chance To Explode When Downed decides
        if ((_d get "lastDist") < 8) exitWith { ["blow", [_d, _d get "lastPos", "crash", true]] call ALiVE_fnc_createFPVDrone };
        ["downed", [_d, "shot down"]] call ALiVE_fnc_createFPVDrone;
    };
    // a roaming drone still searching flies to its next leg of the box the same way as the cruise
    private _search = (_d get "phase") == "search";
    private _target = _d get "target";
    private _tv = vehicle _target;
    private _man = _tv isKindOf "Man";
    private _pos = getPosASL _uav;
    private _cpos = switch (true) do {
        case _search: { _d get "wp" };
        case _man: { (getPosASL _tv) vectorAdd [0, 0, 1] };
        default { _tv modelToWorldWorld [0, 0, 0] };
    };
    private _dist = _pos vectorDistance _cpos;
    _d set ["lastPos", _pos];
    _d set ["lastDist", [_dist, 1e9] select _search];
    private _fnc_turn = {
        if (_now - (_d get "lastTurn") >= 0.25) then {
            _d set ["lastTurn", _now];
            private _up = (_this vectorCrossProduct [0, 0, 1]) vectorCrossProduct _this;
            if ((vectorMagnitude _up) < 0.1) then { _up = [0, 1, 0] };
            _uav setVectorDirAndUp [_this, vectorNormalized _up];
        };
    };

    // a dropper flying off after its drops: away from where its target was at 15 m/s, climbing to 70 m
    if ((_d get "phase") == "leave") exitWith {
        private _hd = _d get "leaveDir";
        private _vz = (((((getTerrainHeightASL _pos) max 0) + 70) - (_pos select 2)) * 0.8) max -6 min 8;
        _uav setVelocity ((_hd vectorMultiply 15) vectorAdd [0, 0, _vz]);
        _hd call _fnc_turn;
    };
    // a dropper over its target: it holds 30 m over where he will be when a grenade let go now lands (his ground speed
    // over the fall time from the height it is at), moving with him, and lets one go when it is within 2.5 m of that
    // point, 15 to 45 m up, he moves no faster than 12 m/s, and 2.5 s have passed since the last. Each candidate drop
    // (at most 4 a second) is held while anyone friendly to its side is within 15 m of where it would land (a vehicle
    // counts while anyone alive is in it), while he is under a roof, or while a jammer is in reach of the drone
    // (the once-a-second loop then ends the flight: a jammed dropper releases nothing). The once-a-second loop sends
    // it off after its drops or 40 s
    if ((_d get "phase") == "bomb") exitWith {
        private _tp = getPosASL _tv;
        private _tvel = velocity _tv;
        _tvel set [2, 0];
        private _h = ((_pos select 2) - (_tp select 2)) max 1;
        private _fall = ((sqrt (1 + 19.62 * _h)) - 1) / 9.81;
        private _aim = _tp vectorAdd (_tvel vectorMultiply _fall);
        private _want = +_aim;
        _want set [2, ((_tp select 2) + 30) max (((getTerrainHeightASL _aim) max 0) + 25)];
        private _v = (_want vectorDiff _pos) vectorMultiply 1.2;
        if ((vectorMagnitude _v) > 18) then { _v = (vectorNormalized _v) vectorMultiply 18 };
        _uav setVelocity (_v vectorAdd _tvel);
        private _flat = _aim vectorDiff _pos;
        _flat set [2, 0];
        if ((vectorMagnitude _flat) > 1) then { (vectorNormalized _flat) call _fnc_turn };
        if ((_pos distance2D _aim) < 2.5 && {_h > 15} && {_h < 45} && {(vectorMagnitude _tvel) <= 12}
            && {_now >= (_d get "nextDrop")} && {_now >= (_d get "dropCheck")} && {(_d get "dropped") < (_d get "drops")}) then {
            _d set ["dropCheck", _now + 0.25];
            private _side = _d get "side";
            private _at = ASLToAGL [_aim select 0, _aim select 1, _tp select 2];
            private _tcrew = crew _tv;
            private _friend = (_at nearEntities [["CAManBase", "LandVehicle", "Ship", "StaticWeapon"], 15]) findIf {
                alive _x && {_x != _tv} && {!(_x in _tcrew)}
                && {(_x isKindOf "CAManBase") || {((crew _x) findIf { alive _x }) >= 0}}
                && {(_side getFriend ([side _x, side group _x] select (_x isKindOf "CAManBase"))) >= 0.6}
            };
            private _why = switch (true) do {
                case ((ADDON getVariable ["Drone_Jammed", true]) && {[_uav, -1, true] call ALiVE_fnc_iedJammerNear}): { "a jammer is in reach" };
                case ((_uav getVariable ["mcs_jamState", ""]) != ""): { "jammed by Military Container Systems" };
                case (_friend >= 0): { "a friendly is within 15 m" };
                case (["roofed", [_tv]] call ALiVE_fnc_createFPVDrone): { "the target is under a roof" };
                default { "" };
            };
            if (_why == "") then {
                ["release", [_d]] call ALiVE_fnc_createFPVDrone;
                _d set ["nextDrop", _now + 2.5];
                _d set ["held", ""];
            } else {
                if ((_d get "debug") && {(_d getOrDefault ["held", ""]) != _why}) then { ["ALIVE-%1 FPV drone: the dropper holds its drop: %2", time, _why] call ALiVE_fnc_dump };
                _d set ["held", _why];
            };
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

    // the attack run, no hover over him: after a short pause at most (none half the time, otherwise up to 1 s) it
    // swings in from a random side, weaving 10 to 25 m left or right and 12 to 25 m up every 1 to 2 s at 20 m/s,
    // aimed where he will be; once it is at least as high over him as it is out from him (a dive 45 degrees or
    // steeper, so it does not fly into the ground short of him), or after 20 s, it dives
    if ((_d getOrDefault ["diveAt", -1]) < 0) exitWith {
        if (_now < (_d get "pauseUntil")) exitWith { _uav setVelocity [0, 0, 0] };
        if (_now >= (_d get "weaveAt")) then {
            _d set ["weaveAt", _now + 1 + random 1];
            _d set ["weaveW", (10 + random 15) * (selectRandom [-1, 1])];
            _d set ["weaveH", 12 + random 13];
        };
        private _aim = (getPosASL _tv) vectorAdd ((velocity _tv) vectorMultiply ((_dist / 20) min 3));
        private _hz = _pos distance2D _aim;
        if (_hz < (((_pos select 2) - ((getPosASL _tv) select 2)) max 8) || {_now > (_d get "hoverLimit")}) exitWith {
            _d set ["diveAt", _now];
            _d set ["prev", _pos];
            ["info", [_d]] call ALiVE_fnc_createFPVDrone;
        };
        // a point 70 % of the way out from him along the approach bearing, pushed sideways by the weave (less as
        // it closes) and up by the weave height: chasing it curves the drone round onto that bearing as it closes
        private _b = _d get "attackB";
        private _out = [sin _b, cos _b, 0];
        private _across = [cos _b, -(sin _b), 0];
        private _want = _aim vectorAdd (_out vectorMultiply ((_hz * 0.7) min 120))
            vectorAdd (_across vectorMultiply ((_d get "weaveW") * ((_hz / 60) min 1))) vectorAdd [0, 0, _d get "weaveH"];
        _want set [2, (_want select 2) max (((getTerrainHeightASL _want) max 0) + 8)];
        private _v = (vectorNormalized (_want vectorDiff _pos)) vectorMultiply 20;
        _uav setVelocity _v;
        private _flat = [_v select 0, _v select 1, 0];
        if ((vectorMagnitude _flat) > 1) then { (vectorNormalized _flat) call _fnc_turn };
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
    if ((["height", [_uav]] call ALiVE_fnc_createFPVDrone) < 1.5 && {_dist > 4}) exitWith { ["blow", [_d, _pos, "ground", false]] call ALiVE_fnc_createFPVDrone };
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
    // a boat being chased: when the chase was last measured and how far off it was then
    private _chaseAt = -1;
    private _chaseDist = 0;
    private _jamOn = ADDON getVariable ["Drone_Jammed", true];
    private _fnc_end = { ["end", [_d, _this select 0, _this select 1]] call ALiVE_fnc_createFPVDrone };

    private _fnc_downed = { ["downed", [_d, _this]] call ALiVE_fnc_createFPVDrone };
    // the target: alive, on the ground, not in an aircraft; a vehicle (Medium and Large charges) with someone alive in it,
    // or with Drones Also Hit Abandoned Vehicles an empty, knocked-out one (ALiVE_fnc_vehicleAbandoned)
    private _fit = { alive _this && {!((vehicle _this) isKindOf "Air")} && {(["height", [vehicle _this]] call ALiVE_fnc_createFPVDrone) < 25}
        && {(_d get "boats") || {!((vehicle _this) isKindOf "Ship")}}
        && {_this isKindOf "Man" || {((crew _this) findIf { alive _x }) > -1} || {(_d get "abandoned") && {[_this] call ALiVE_fnc_vehicleAbandoned}}} };
    // whose side a target is on: a man's group, a crewed vehicle's crew, an empty vehicle's own side in its config
    private _fnc_tside = {
        if (_this isKindOf "Man") exitWith { side group _this };
        if (((crew _this) findIf { alive _x }) >= 0) exitWith { side _this };
        [east, west, independent, civilian] param [getNumber (configOf _this >> "side"), civilian]
    };

    // its target gone or no longer one it may go after: it searches round where it is
    private _fnc_research = {
        private _t = _d get "target";
        if (!isNull _t && {(_t getVariable ["ALiVE_IED_droneOn", objNull]) isEqualTo _uav}) then { _t setVariable ["ALiVE_IED_droneOn", objNull] };
        private _c = getPosATL _uav;
        private _r = 300 + random 200;
        private _a = random 360;
        _d set ["legs", [0, 90, 180, 270] apply { _c getPos [_r * (0.85 + random 0.3), _a + _x + (random 20) - 10] }];
        _d set ["leg", 0];
        _d set ["wp", (_d get "legs") select 0];
        _d set ["target", objNull];
        _d set ["phase", "search"];
        _d set ["recall", 2500];
        _d set ["diveAt", -1];
        _roofSince = -1;
    };

    // a dropper is done over its target: it flies off, away from it, for 25 s and is then removed
    private _fnc_leave = {
        private _t = _d get "target";
        private _b = if (isNull _t) then { random 360 } else { (_t getDir _uav) + (random 60) - 30 };
        _d set ["leaveDir", [sin _b, cos _b, 0]];
        _d set ["leaveEnd", time + 25];
        _d set ["phase", "leave"];
        ["info", [_d]] call ALiVE_fnc_createFPVDrone;
        if (_d get "debug") then { ["ALIVE-%1 FPV drone: the dropper flies off after %2 of %3 grenades (%4)", time, _d get "dropped", _d get "drops", _this] call ALiVE_fnc_dump };
    };

    while { !(_d get "gone") } do {
        sleep 1;
        if (_d get "gone") exitWith {};
        // falling with its warhead armed ("downed"): that spawn sets it off
        if (_d getOrDefault ["falling", false]) then { continue };
        if (isNull ADDON) exitWith { ["the IED module is gone", false] call _fnc_end };
        if (isNull _uav) exitWith { ["deleted", false] call _fnc_end };
        // in the dive the frame handler decides what a death means
        if (!alive _uav && {(_d get "phase") != "terminal"}) exitWith { "shot down" call _fnc_downed };
        if (!alive _uav) then { continue };
        // the Crocus mod makes its drones captive a frame after they are made, and again whenever its settings are
        // applied: a captive drone counts as civilian (Zeus showed it so, beside its crew's group of its real side) and
        // nobody shoots at it. One flown here is never captive (Will501 on Discord, 25 Nov)
        if (captive _uav || {((crew _uav) findIf { captive _x }) >= 0}) then {
            _uav setCaptive false;
            { _x setCaptive false } forEach (crew _uav);
        };
        // Pause Modules (Required module): while the server is paused with no players, or about to be (on, and nobody
        // connected), the drone is held where it is, frozen, with its battery stopped; it carries on from the same
        // phase when a player is back. A drone whose player has gone searches round where it is instead
        private _hold = !isNil "ALiVE_main_PAUSEMODULES_PAUSED"
            || {!isNil "ALiVE_PAUSEMODULES_EH_DISCONNECTED" && {((allPlayers - entities "HeadlessClient_F") findIf { true }) < 0}};
        if (_hold) then {
            if ((_d getOrDefault ["heldAt", -1]) < 0) then {
                _d set ["heldAt", time];
                _d set ["heldTick", diag_tickTime];
                _uav enableSimulationGlobal false;
                if (_d get "debug") then { ["ALIVE-%1 FPV drone: held while the server is paused, at %2", time, mapGridPosition _uav] call ALiVE_fnc_dump };
            };
            sleep 4;
            continue;
        };
        if ((_d getOrDefault ["heldAt", -1]) >= 0) then {
            private _dt = time - (_d get "heldAt");
            private _dtk = diag_tickTime - (_d get "heldTick");
            _d set ["heldAt", -1];
            _d set ["batteryEnd", (_d get "batteryEnd") + _dt];
            { if ((_d getOrDefault [_x, -1]) >= 0) then { _d set [_x, (_d get _x) + _dt] } } forEach ["bombEnd", "leaveEnd"];
            { if ((_d getOrDefault [_x, -1]) >= 0) then { _d set [_x, (_d get _x) + _dtk] } } forEach ["hoverLimit", "diveAt", "pauseUntil", "weaveAt", "jamTick", "nextDrop", "dropCheck"];
            if (_roofSince >= 0) then { _roofSince = _roofSince + _dt };
            _stuckPos = getPosATL _uav;
            _stuckAt = time;
            _uav enableSimulationGlobal true;
            if ((_d get "phase") != "search" && {!((_d get "target") call _fit)}) then { call _fnc_research };
            ["info", [_d]] call ALiVE_fnc_createFPVDrone;
            if (_d get "debug") then { ["ALIVE-%1 FPV drone: carries on after %2 s held (%3)", time, round _dt, _d get "phase"] call ALiVE_fnc_dump };
        };
        if (!local _uav) exitWith { ["no longer run by the server", true] call _fnc_end };
        // AI-crewed vehicles of a side hostile to the drone's, within 400 m, with a gunner that can fire: every 2 s
        // shown the drone and told to fire at it (their own aim decides whether they hit); within 30 m of one,
        // its gunner is told to let it go, so he does not fire into his own vehicle
        if (time >= (_d getOrDefault ["engageAt", 0])) then {
            _d set ["engageAt", time + 2];
            private _side = _d get "side";
            {
                private _gn = gunner _x;
                if (alive _gn && {!isPlayer _gn} && {((side group _gn) getFriend _side) < 0.6}) then {
                    if ((_x distance _uav) < 30) exitWith { if ((assignedTarget _gn) isEqualTo _uav) then { _gn doTarget objNull } };
                    if (canFire _x) then {
                        (group _gn) reveal [_uav, 4];
                        if !((assignedTarget _gn) isEqualTo _uav) then { _gn doTarget _uav; _gn doFire _uav };
                    };
                };
            } forEach (_uav nearEntities [["LandVehicle", "Ship"], 400]);
        };
        // a player's UAV terminal has it (a server sees that through UAVControl only)
        if (!isNull ((UAVControl _uav) param [0, objNull])) exitWith { ["taken over by a UAV terminal", true] call _fnc_end };
        if (_jamOn && {[_uav, -1, true] call ALiVE_fnc_iedJammerNear}) exitWith { ["jammed", true] call _fnc_end };
        // Military Container Systems, read from its public jam state: a hard kill ends the flight and it drops; a soft
        // kill holds it where it is, picking and chasing nothing, while its battery runs on; once the jam is lifted it
        // carries on from the same phase (a new search if its target is gone)
        private _mcs = _uav getVariable ["mcs_jamState", ""];
        if (_mcs isEqualTo "hard") exitWith { ["jammed by Military Container Systems (hard)", true] call _fnc_end };
        if (_mcs isEqualTo "soft") then {
            if ((_d getOrDefault ["jamTick", -1]) < 0) then {
                _d set ["jamTick", diag_tickTime];
                if (_d get "debug") then { ["ALIVE-%1 FPV drone: jammed by Military Container Systems (soft), holding at %2", time, mapGridPosition _uav] call ALiVE_fnc_dump };
            };
        } else {
            if ((_d getOrDefault ["jamTick", -1]) >= 0) then {
                private _dtk = diag_tickTime - (_d get "jamTick");
                _d set ["jamTick", -1];
                { if ((_d getOrDefault [_x, -1]) >= 0) then { _d set [_x, (_d get _x) + _dtk] } } forEach ["hoverLimit", "diveAt", "pauseUntil", "weaveAt", "nextDrop", "dropCheck"];
                if (_roofSince >= 0) then { _roofSince = _roofSince + _dtk };
                _stuckPos = getPosATL _uav;
                _stuckAt = time;
                if ((_d get "phase") != "search" && {!((_d get "target") call _fit)}) then { call _fnc_research };
                ["info", [_d]] call ALiVE_fnc_createFPVDrone;
                if (_d get "debug") then { ["ALIVE-%1 FPV drone: jam released after %2 s, resuming (%3)", time, round _dtk, _d get "phase"] call ALiVE_fnc_dump };
            };
        };
        // another mod's jammer that kills its AI pilot or drains its fuel: nothing flies it any more, whatever
        // Jammers Stop Drones says (that setting covers ALiVE's own jammer checks above)
        if (((crew _uav) findIf { alive _x }) < 0) exitWith { ["no pilot (jammed by another mod?)", true] call _fnc_end };
        if ((fuel _uav) <= 0) exitWith { ["no fuel (jammed by another mod?)", true] call _fnc_end };
        if (time > (_d get "batteryEnd")) exitWith { "out of battery" call _fnc_downed };
        private _players = allPlayers - entities "HeadlessClient_F";
        // a Zeus's camera counts as a player here, so a drone sent at AI he is watching is not called back
        if (((["eyes", [_players]] call ALiVE_fnc_createFPVDrone) findIf { (_x distance _uav) < (_d get "recall") }) < 0) exitWith { [format ["no player within %1 m", _d get "recall"], false] call _fnc_end };
        if ((_d get "marker") != "") then { (_d get "marker") setMarkerPos getPosATL _uav };
        // held by a soft jam: nothing more this second
        if ((_d getOrDefault ["jamTick", -1]) >= 0) then { continue };

        // a roaming drone searching: a player of a hostile side within 300 m that it can see becomes its target
        // (its own look, once a second; never a player Zeus or one another drone is after). Until then it flies
        // its box; after the four legs, a new box round where its side last knew a player to be (a group of its
        // side that knows about him, at the position that group has for him, never where he really is), or else
        // round the objective again
        if ((_d get "phase") == "search") then {
            private _side = _d get "side";
            private _eye = getPosASL _uav;
            private _cands = +_players;
            if (_d get "vehicles") then {
                _cands append ((_uav nearEntities [["LandVehicle"] + (["Ship"] select [0, [0, 1] select (_d get "boats")]), 300]) select { ((crew _x) findIf { isPlayer _x }) < 0 && {time > (_x getVariable ["ALiVE_IED_droneNext", 0])} });
            };
            // Players and AI: AI men on foot (a man in a vehicle is reached through the vehicle, Medium and Large only)
            if (_d get "ai") then {
                _cands append ((_uav nearEntities [["CAManBase"], 300]) select { !isPlayer _x && {(vehicle _x) isEqualTo _x} });
            };
            private _seen = _cands select {
                _x call _fit && {(_x distance _uav) < 300} && {(_side getFriend (_x call _fnc_tside)) < 0.6}
                && {isNull (_x getVariable ["ALiVE_IED_droneOn", objNull])}
                // an empty vehicle has no crew side for the bomber check; its config side decided it above
                && {(!(_x isKindOf "Man") && {((crew _x) findIf { alive _x }) < 0}) || {!(_x call ALiVE_fnc_iedBomberSpares)}}
                && {isNull (getAssignedCuratorLogic _x) || {missionNamespace getVariable ["ALiVE_zeusSoloTest", false]}}
                && {([_uav, "VIEW", vehicle _x] checkVisibility [_eye, (getPosASL (vehicle _x)) vectorAdd [0, 0, 1.5]]) > 0.3}
            };
            if (_seen isNotEqualTo []) exitWith {
                _seen = _seen apply { [_x distance _uav, _x] };
                _seen sort true;
                private _p = (_seen select 0) select 1;
                _d set ["target", _p];
                _d set ["phase", "cruise"];
                _p setVariable ["ALiVE_IED_droneOn", _uav];
                // Drone Wait for him and the players around him, as for a launched drone
                private _until = time + 60 * (ADDON getVariable ["Drone_Wait", 10]);
                private _share = ADDON getVariable ["Bomber_Dispatch_Share", 150];
                { if (_x == _p || {(_x distance _p) < _share}) then { _x setVariable ["ALiVE_IED_droneNext", _until max (_x getVariable ["ALiVE_IED_droneNext", 0])] } } forEach _players;
                _stuckPos = getPosATL _uav;
                _stuckAt = time;
                ["info", [_d]] call ALiVE_fnc_createFPVDrone;
                if (_d get "debug") then { ["ALIVE-%1 FPV drone: the roaming %2 drone spotted %3 %4 m away", time, _side, ([typeOf _p, name _p] select (_p isKindOf "Man")), round (_p distance _uav)] call ALiVE_fnc_dump };
            };
            if ((_eye distance2D (_d get "wp")) < 30) then {
                private _leg = (_d get "leg") + 1;
                if (_leg > 3) then {
                    _leg = 0;
                    private _known = [];
                    // (its own crew's knowledge is the drone's own look, not its side's)
                    private _own = group ((crew _uav) param [0, objNull]);
                    {
                        private _pv = vehicle _x;
                        if ((_pv distance _uav) < 2500 && {(_side getFriend (side group _x)) < 0.6}) then {
                            {
                                if (side _x == _side && {_x != _own} && {(_x knowsAbout _pv) > 1}) exitWith { _known pushBack (((leader _x) targetKnowledge _pv) select 6) };
                            } forEach allGroups;
                        };
                    } forEach _players;
                    private _c = _d get "from";
                    if (_known isNotEqualTo []) then {
                        _known = _known apply { [_x distance2D _uav, _x] };
                        _known sort true;
                        _c = (_known select 0) select 1;
                    };
                    private _r = 300 + random 200;
                    private _a = random 360;
                    _d set ["legs", [0, 90, 180, 270] apply { _c getPos [_r * (0.85 + random 0.3), _a + _x + (random 20) - 10] }];
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: the roaming %2 drone searches round %3 (%4)", time, _side, mapGridPosition _c, ["its objective", "where its side last knew a player to be"] select (_known isNotEqualTo [])] call ALiVE_fnc_dump };
                };
                _d set ["leg", _leg];
                _d set ["wp", (_d get "legs") select _leg];
            };
            // flown into something while searching
            if (time - _stuckAt >= 10) then {
                if ((_stuckPos distance (getPosATL _uav)) < 5) exitWith { "crashed or stuck" call _fnc_downed };
                _stuckPos = getPosATL _uav;
                _stuckAt = time;
            };
        };
        if ((_d get "phase") == "search" || {_d get "gone"} || {_d getOrDefault ["falling", false]}) then { continue };

        // a dropper flying off: removed after 25 s. Over its target (the frame handler aims and drops): it flies off
        // once its grenades are gone, after 40 s, or when its target is dead or no longer one it may go after
        if ((_d get "phase") == "leave") then {
            if (time > (_d get "leaveEnd")) then { ["flew off after its drops", false] call _fnc_end };
            continue;
        };
        if ((_d get "phase") == "bomb") then {
            switch (true) do {
                case ((_d get "dropped") >= (_d get "drops")): { "all dropped" call _fnc_leave };
                case (time > (_d get "bombEnd")): { "40 s over the target" call _fnc_leave };
                case (!((_d get "target") call _fit)): { "the target is gone or dead" call _fnc_leave };
            };
            continue;
        };

        // the player; once, the nearest other player within 200 m instead
        private _target = _d get "target";
        private _tv = vehicle _target;
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
            ["info", [_d]] call ALiVE_fnc_createFPVDrone;
            if (_d get "debug") then { ["ALIVE-%1 FPV drone: target lost, now after %2", time, ([typeOf _next, name _next] select (_next isKindOf "Man"))] call ALiVE_fnc_dump };
        };
        _target = _d get "target";
        if !(_target call _fit) exitWith { ["the player is gone, dead or in the air", false] call _fnc_end };
        _tv = vehicle _target;

        if ((_d get "phase") == "terminal") then { continue };

        // cruise: flown into something
        if (time - _stuckAt >= 10) then {
            if ((_stuckPos distance (getPosATL _uav)) < 5 && {(_d get "phase") == "cruise"}) exitWith { "crashed or stuck" call _fnc_downed };
            _stuckPos = getPosATL _uav;
            _stuckAt = time;
        };
        if (_d get "gone" || {_d getOrDefault ["falling", false]}) then { continue };

        // a boat it can't catch (it cruises at 15 m/s, a fast boat goes twice that): no 100 m closed in a minute and
        // it gives up and drops, instead of chasing it until the battery runs out
        if (_tv isKindOf "Ship") then {
            private _dist = _uav distance2D _tv;
            if (_chaseAt < 0) then { _chaseAt = time; _chaseDist = _dist };
            if (time - _chaseAt >= 60) then {
                if (_dist > _chaseDist - 100) exitWith {
                    ["ALIVE-%1 FPV drone: gave up on a %2 it could not catch (%3 m away, %4 m a minute before)", time, typeOf _tv, round _dist, round _chaseDist] call ALiVE_fnc_dump;
                    ["the boat outran it", true] call _fnc_end;
                };
                _chaseAt = time;
                _chaseDist = _dist;
            };
        } else {
            _chaseAt = -1;
        };
        if (_d get "gone") then { continue };

        // the final run: under 150 m away with a line of sight; never at a player under a roof
        if ((_uav distance2D _tv) < 150 && {([_uav, "VIEW", _tv] checkVisibility [getPosASL _uav, (getPosASL _tv) vectorAdd [0, 0, 1.5]]) > 0.3}) then {
            if (["roofed", [_tv]] call ALiVE_fnc_createFPVDrone) then {
                if (_roofSince < 0) then {
                    _roofSince = time;
                    _d set ["phase", "roof"];
                    ["info", [_d]] call ALiVE_fnc_createFPVDrone;
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: %2 is under a roof, waiting", time, ([typeOf _target, name _target] select (_target isKindOf "Man"))] call ALiVE_fnc_dump };
                };
            } else {
                _roofSince = -1;
                if (_d get "dropper") then {
                    // a dropper: over him to drop its grenades (frame handler), for 40 s at most
                    _d set ["bombEnd", time + 40];
                    _d set ["phase", "bomb"];
                    ["info", [_d]] call ALiVE_fnc_createFPVDrone;
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: the dropper closes on %2, %3 m away, %4 m up", time, ([typeOf _target, name _target] select (_target isKindOf "Man")), round (_uav distance _tv), round ((getPosATL _uav) select 2)] call ALiVE_fnc_dump };
                } else {
                    // the attack run (frame handler): a pause of up to 1 s or none, a random side to come in from
                    _d set ["hoverLimit", diag_tickTime + 20];
                    _d set ["pauseUntil", diag_tickTime + ([0, random 1] select (random 1 < 0.5))];
                    _d set ["weaveAt", 0];
                    _d set ["attackB", (_tv getDir _uav) + (selectRandom [-1, 1]) * (40 + random 50)];
                    _d set ["prev", getPosASL _uav];
                    _d set ["phase", "terminal"];
                    ["info", [_d]] call ALiVE_fnc_createFPVDrone;
                    if (_d get "debug") then { ["ALIVE-%1 FPV drone: final run at %2, %3 m away, %4 m up", time, ([typeOf _target, name _target] select (_target isKindOf "Man")), round (_uav distance _tv), round ((getPosATL _uav) select 2)] call ALiVE_fnc_dump };
                };
            };
        } else {
            if ((_d get "phase") == "roof") then { _d set ["phase", "cruise"]; _roofSince = -1; ["info", [_d]] call ALiVE_fnc_createFPVDrone };
        };
        // under a roof for 20 s: it gives up
        if (_roofSince >= 0 && {time - _roofSince > 20}) exitWith { ["the player stayed under a roof", false] call _fnc_end };
    };
    ALiVE_IED_drones = ALiVE_IED_drones - [_d];
};

_uav
