#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(registerForceUpright);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_registerForceUpright

Description:
    Tags an entity for force-upright orientation and records its
    position-grid key in a global registry so that re-activation
    after ALiVE virtualisation reapplies setVectorUp [0,0,1] + setDir.

    The validator's "field" / "ato" modes allow ~4 deg slope which is
    enough to tilt static AA pods (crew ejected on engine physics
    check) and visually tilt scenery (radars / antennas leaning on
    hillsides). Setting world-up vector after spawn keeps them upright
    regardless of terrain slope.

    Persistence approach: ALiVE's profile schema stores position +
    direction but NOT vectorUp. When a virtualised profile re-activates
    (player approaches a previously-quiet area) the engine spawns a
    fresh entity at the stored pos+dir but terrain-aligned by default.
    Tilt is back.

    To survive virtualisation cycles:
      - Each registered entity's (classname + position-grid 3m) key is
        stored in `ALIVE_forceUprightKeys` (HashMap, key=string,
        value=desired direction).
      - First call for each unique class also wires a CBA class init
        event handler. The handler fires on every entity init (initial
        spawn AND re-activation respawn) for that class. It looks up
        the position-grid key; on match, reapplies vectorUp + setDir.

    The position-grid (3m granularity) is robust against minor physics
    drift between original spawn and re-spawn. Classname narrows the
    match to avoid cross-class collisions.

Parameters:
    [_obj, _dir, _classOverride, _posOverride]

    _obj           : OBJECT - the spawned entity, or objNull when the
                              entity doesn't yet exist (createProfileVehicle
                              returns slot 10 = objNull until the profile
                              is later activated by player proximity).
    _dir           : NUMBER - desired heading (yaw degrees)
    _classOverride : STRING - classname to register when _obj is null
                              (required for the createProfileVehicle path
                              since typeOf objNull == ""). Optional when
                              _obj is non-null.
    _posOverride   : ARRAY  - [x,y,z] position to register when _obj is
                              null. Required alongside _classOverride.

Author:
    Jman
---------------------------------------------------------------------------- */

params [
    ["_obj", objNull, [objNull]],
    ["_dir", 0, [0]],
    ["_classOverride", "", [""]],
    ["_posOverride", [], [[]], [2,3]]
];

private _cls = "";
private _pos = [];
if (!isNull _obj) then {
    _cls = typeOf _obj;
    _pos = getPos _obj;
} else {
    // Profile-spawn path: entity not yet physical. Caller passes the
    // classname + intended position so we can register the grid key
    // and wire the class init EH; the EH fires when the engine later
    // creates the entity (on profile activation) and applies upright.
    if (_classOverride == "" || {count _posOverride < 2}) exitWith {};
    _cls = _classOverride;
    _pos = _posOverride;
};
if (_cls == "" || {count _pos < 2}) exitWith {};

if (isNil "ALIVE_forceUprightKeys") then { ALIVE_forceUprightKeys = createHashMap };
if (isNil "ALIVE_forceUprightRegisteredClasses") then { ALIVE_forceUprightRegisteredClasses = []; };

// Build the position-grid key (3m grid + classname). Same formula
// must run in the class init EH below for re-activation matching.
private _key = format ["%1|%2|%3", _cls, round ((_pos select 0) / 3), round ((_pos select 1) / 3)];
ALIVE_forceUprightKeys set [_key, _dir];
// Opt-in diag: set `ALIVE_forceUpright_debug = true` in console / init.sqf
// to surface REGISTER + EH-FIRE lines for tilt investigation.
if (!isNil "ALIVE_forceUpright_debug" && {ALIVE_forceUpright_debug}) then {
    ["[ALiVE forceUpright] REGISTER cls=%1 pos=%2 key=%3 dir=%4 hadObj=%5", _cls, _pos, _key, _dir, !isNull _obj] call ALiVE_fnc_dump;
};

// Apply at t=0, then re-apply at t=0.5s and t=1.5s. Single immediate
// setVectorUp doesn't stick reliably for static weapons on uneven
// terrain - the engine's physics-settle pass after createVehicle can
// tip the entity 90 degrees if a corner of its bbox sits on a rock /
// micro-terrain bump. Deferred re-applies catch the post-settle tip
// and any late micro-correction. Three passes is empirically
// sufficient; static weapon AI / firing isn't disturbed by setVectorUp.
// Immediate + deferred re-apply only when the entity already exists.
// Profile-spawn path skips this block - upright is applied via the
// class init EH below when the engine later creates the entity.
if (!isNull _obj) then {
    // Plant + orient atomically. setPosATL [x,y,0] forces the entity
    // onto the terrain (counters the engine's createVehicle physics-
    // bump that lifts static weapons off the ground based on their
    // model bbox). setVectorUp [0,0,1] forces world-up orientation.
    // Combined, these prevent the "spawn 10ft up, fall, tip on slope"
    // pattern observed on Stratis hillsides.
    private _applyUprightFn = {
        params ["_o", "_d"];
        if (isNull _o) exitWith {};
        private _p = getPosATL _o;
        _o setPosATL [_p select 0, _p select 1, 0];
        _o setVectorUp [0, 0, 1];
        _o setDir _d;
    };
    [_obj, _dir] call _applyUprightFn;
    [_obj, _dir] spawn {
        params ["_o", "_d"];
        // Five passes: 0.5, 1.5, 3, 6, 10s. Steep-slope spawns can
        // continue tipping for several seconds after the engine's
        // initial physics-settle - the original two-pass (0.5, 1.5)
        // was insufficient on >15-deg slopes. Each pass re-plants
        // (setPosATL z=0) AND re-orients (setVectorUp + setDir).
        private _replant = {
            params ["_o", "_d"];
            if (isNull _o) exitWith {};
            private _p = getPosATL _o;
            _o setPosATL [_p select 0, _p select 1, 0];
            _o setVectorUp [0, 0, 1];
            _o setDir _d;
        };
        sleep 0.5;  [_o, _d] call _replant;
        sleep 1;    [_o, _d] call _replant;
        sleep 1.5;  [_o, _d] call _replant;
        sleep 3;    [_o, _d] call _replant;
        sleep 4;    [_o, _d] call _replant;
    };
};

// Class init EH registration - one-time per class. CBA's
// addClassEventHandler attaches to every present + future entity of
// the class globally; subsequent calls for the same class are no-ops
// because we gate on ALIVE_forceUprightRegisteredClasses.
if !(_cls in ALIVE_forceUprightRegisteredClasses) then {
    ALIVE_forceUprightRegisteredClasses pushBack _cls;
    [_cls, "init", {
        params ["_e"];
        if (isNull _e || {isNil "ALIVE_forceUprightKeys"}) exitWith {};
        private _ePos = getPos _e;
        private _eKey = format ["%1|%2|%3", typeOf _e, round ((_ePos select 0) / 3), round ((_ePos select 1) / 3)];
        private _matched = _eKey in ALIVE_forceUprightKeys;
        if (!isNil "ALIVE_forceUpright_debug" && {ALIVE_forceUpright_debug}) then {
            ["[ALiVE forceUpright] EH-FIRE cls=%1 pos=%2 key=%3 matched=%4", typeOf _e, _ePos, _eKey, _matched] call ALiVE_fnc_dump;
        };
        if (_matched) then {
            private _eDir = ALIVE_forceUprightKeys get _eKey;
            // Plant + orient. Same 5-pass pattern as the entity-exists
            // path - catches engine physics-settle tipping after the
            // init event fires AND counters the createVehicle bump-up
            // that lifts static weapons above terrain.
            private _ep = getPosATL _e;
            _e setPosATL [_ep select 0, _ep select 1, 0];
            _e setVectorUp [0, 0, 1];
            _e setDir _eDir;
            [_e, _eDir] spawn {
                params ["_o", "_d"];
                private _replant = {
                    params ["_o", "_d"];
                    if (isNull _o) exitWith {};
                    private _p = getPosATL _o;
                    _o setPosATL [_p select 0, _p select 1, 0];
                    _o setVectorUp [0, 0, 1];
                    _o setDir _d;
                };
                sleep 0.5;  [_o, _d] call _replant;
                sleep 1;    [_o, _d] call _replant;
                sleep 1.5;  [_o, _d] call _replant;
                sleep 3;    [_o, _d] call _replant;
                sleep 4;    [_o, _d] call _replant;
            };
        };
    }, false, [], true] call CBA_fnc_addClassEventHandler;
};
