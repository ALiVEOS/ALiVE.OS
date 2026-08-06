/* ----------------------------------------------------------------------------
Function: NEO_fnc_transportInsertionHold
Description:
    Holds a Combat Support transport still, at the height the player asked for,
    while it hovers over the insertion point.

    Everything here was measured on a live RHS UH-1Y rather than reasoned about,
    because reasoning got it wrong repeatedly. What the aircraft actually does:

      - Asking for a height does nothing once it has stopped. Told to come down
        from 83m to 10m it sat exactly where it was for fifteen seconds.
      - Ordering it to the insertion point does nothing either. It parks short,
        decides it has arrived, and a fresh order to that spot produces no
        command at all - the pilot never registers one.
      - Pushing it down with velocity works cleanly, and works from a dead hover:
        41m to 10m in eight seconds, slowing itself as it closed, dead level.
      - Stop pushing and it climbs back to the height it picked for itself within
        about six seconds, while still being told to fly low. It does not forget
        the height it wants; it restores it. So there is no set-and-forget
        version of this and the hold has to run continuously.
      - Holding the height alone is not enough. Pinned low, the pilot keeps
        applying climb, and the surplus comes out as backwards translation: it
        reverses out of the hover at 10km/h and keeps going, on flat ground as
        well as sloped, until it leaves the area entirely and climbs away.

    That last one took two failed attempts to solve, and the pair of them is why
    the fix looks like this:

      - Damping the sideways drift on its own was appalling. The pilot pitches to
        produce movement, cancelling the result makes him pitch harder, and within
        seconds the aircraft hangs at forty five degrees fighting itself. It did
        cut the drift by the numbers, which is exactly why somebody had to look
        at it.
      - Switching the pilot's movement off on its own held a level attitude and
        roughly held station, but with nothing correcting the residual velocity it
        slowly accelerated away instead.

    Each failure removes the other's cause. With the pilot not trying to move,
    damping has nothing to fight and only has to bleed off what is already there.
    Together: 25 seconds without a single metre of drift, upright the whole time.

    No move orders are issued anywhere here, deliberately. The insertion callout
    the player waits on is gated on the aircraft reporting itself ready, and an
    outstanding move order holds that false, so ordering it about would hold the
    height beautifully and silently kill the radio sequence.

Parameters:
    _this select 0: OBJECT - the transport helicopter.
    _this select 1: NUMBER - height above ground the player asked for.
    _this select 2: ARRAY  - the insertion position.
    _this select 3: NUMBER - dispatch generation, so a stale run stands down.

Returns:
    Nothing. Runs until the task changes, the aircraft dies, or the timeout.

Examples:
    (begin example)
    [_chopper, _alt, _pos, _run] spawn NEO_fnc_transportInsertionHold;
    (end)

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_chopper", objNull, [objNull]],
    ["_alt", 25, [0]],
    ["_pos", [0,0,0], [[]]],
    ["_run", -1, [0]]
];

if (isNull _chopper) exitWith {};

// The panel offers 2 to 50. Round so the aircraft flies the number the player
// read off the slider rather than a fraction of it.
_alt = (round _alt) max 2;

private _grp = group (driver _chopper);

// Native waypoints outrank a move order and drag the aircraft off the mark.
private _guard = 0;
while {(count (waypoints _grp)) > 1 && {_guard < 32}} do {
    deleteWaypoint ((waypoints _grp) select 1);
    _guard = _guard + 1;
};

private _debug = !isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug};

// The task the hold belongs to. Watching for a PENDING task is not enough on its
// own: the FSM reads that variable and clears it in the same step, so a clear
// landing between two frames here would go unseen and leave the pilot holding
// station, movement disabled, unable to fly whatever he was just given. This one
// persists, so comparing against it cannot be missed.
private _task0 = _chopper getVariable ["NEO_radioCurrentTask", []];

// _st: [nextLogTime, warnedNotLocal, lastFrameTime, pilotMovementIsOff]
[{
    params ["_args", "_handle"];
    // Everything the handler reads is passed in. A code block is not a closure,
    // so anything taken from the spawning scope would be undefined on the frame
    // it runs and this would throw before doing anything at all.
    _args params ["_chopper", "_alt", "_pos", "_run", "_endTime", "_debug", "_st", "_task0"];

    private _stop = switch (true) do {
        case (!alive _chopper): {"aircraft lost"};
        case (isNull (driver _chopper)): {"no pilot"};
        case (time > _endTime): {"timed out"};
        case ((_chopper getVariable ["NEO_radioInsertionRun", -1]) != _run): {"superseded"};
        case ((_chopper getVariable ["NEO_radioTrasportUnitStatus", ""]) != "MISSION"): {"task ended"};
        case (!((_chopper getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task0)): {"retasked"};
        case (!isNil {_chopper getVariable "NEO_radioTransportNewTask"}): {"new task"};
        default {""};
    };

    if !(_stop isEqualTo "") exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        // Never walk away leaving a pilot who cannot fly. Every exit goes through
        // here, including the ones where the aircraft is being handed its next
        // job, so this must run before anything else gets to command it.
        if (alive _chopper && {!isNull (driver _chopper)}) then {
            (driver _chopper) enableAI "MOVE";
        };
        if (_debug) then {
            ["CS TRANSPORT INSERTION: %1 height hold released (%2)", _chopper, _stop] call ALiVE_fnc_dump;
        };
    };

    // Real frame time, so the damping behaves the same at 30fps as at 120.
    // Clamped at both ends: a lag spike must not become a violent correction.
    private _dt = ((time - (_st select 2)) max 0.001) min 0.1;
    _st set [2, time];

    private _dist = _chopper distance2D _pos;

    // Only take hold of it in the hover. In transit the aircraft has to be free
    // to fly itself, and writing velocity underneath a moving one fights the
    // flight model for no gain.
    private _hold = _dist < 300 && {(speed _chopper) < 20};

    // Height above whatever is underneath. Clamping the ground to sea level
    // matters: over water the terrain is the SEA BED, so measuring from it would
    // read tens of metres too high and drive the aircraft under the surface on a
    // shoreline insertion.
    private _p = getPosASL _chopper;
    private _ground = (getTerrainHeightASL [_p select 0, _p select 1]) max 0;
    private _above = (_p select 2) - _ground;

    // Outbound leg gets a cruise height so it is not skimming hills across the
    // map; the asked-for height applies once it is on the insertion point.
    _chopper flyInHeight (if (_hold) then {_alt} else {_alt max 100});

    if (_hold) then {

        // setVelocity is discarded where the aircraft is not local. Combat
        // Support transports are AI and the FSM runs server side, so this holds
        // in practice, but say so rather than fail silently if it ever does not.
        if (local _chopper) then {

            if !(_st select 3) then {
                _st set [3, true];
                (driver _chopper) disableAI "MOVE";
            };

            private _v = velocity _chopper;
            private _wz = (((_alt - _above) * 1.0) max -6) min 6;
            // Never push downward once it is at or below the asked-for height.
            // This is a crewed aircraft with no damage protection and the terrain
            // read above must not be able to fly it into the ground or the sea.
            if (_above <= _alt) then { _wz = _wz max 0 };

            private _f = (1 - (3.0 * _dt)) max 0;
            _chopper setVelocity [(_v select 0) * _f, (_v select 1) * _f, _wz];

        } else {
            if (_debug && {!(_st select 1)}) then {
                _st set [1, true];
                ["CS TRANSPORT INSERTION: %1 is not local, height cannot be held here", _chopper] call ALiVE_fnc_dump;
            };
        };

    } else {
        // Left the hover - give the pilot his movement back so he can fly.
        if (_st select 3) then {
            _st set [3, false];
            (driver _chopper) enableAI "MOVE";
        };
    };

    if (_debug && {time >= (_st select 0)}) then {
        _st set [0, time + 2];
        private _lzGround = (getTerrainHeightASL [_pos select 0, _pos select 1]) max 0;
        ["CS TRANSPORT INSERTION: %1 want=%2m above=%3m aboveLZ=%4m dist=%5m spd=%6 upZ=%7 holding=%8",
            _chopper, _alt, round _above,
            round ((_p select 2) - _lzGround),
            round _dist, round (speed _chopper),
            ((vectorUp _chopper) select 2) toFixed 3,
            _hold] call ALiVE_fnc_dump;
    };

}, 0, [_chopper, _alt, _pos, _run, time + 900, _debug, [0, false, time, false], _task0]] call CBA_fnc_addPerFrameHandler;
