/* ----------------------------------------------------------------------------
Function: NEO_fnc_transportInsertionHold
Description:
    Holds a Combat Support transport helicopter at the height the player asked
    for on the insertion panel, over the insertion point, until the task ends.

    flyInHeight is advisory. The AI drops below it on its approach and will not
    climb back once committed, so setting it once has no lasting effect. It has
    to be re-issued, and it only bites while the aircraft has a live move order
    to shape. Same shape as the slingload descent hold in mil_logistics
    (fnc_ML.sqf), which holds twelve metres reliably by pairing the two.

    The move order is dropped once the aircraft is on station. This is
    deliberate: the calling FSM advances from "Prepare for Insertion" to
    "Go! Go! Go!" on unitReady, and unitReady stays false while a move order is
    outstanding. Re-issuing it every tick would hold the height perfectly and
    silently stop the insertion ever being called. It comes back if the
    aircraft drifts out of the band.

Parameters:
    _this select 0: OBJECT - the transport helicopter.
    _this select 1: NUMBER - requested height above ground, metres.
    _this select 2: ARRAY  - insertion position to hold over.

Returns:
    Nothing. Runs until the task changes, the aircraft dies, or the timeout.

Examples:
    (begin example)
    [_chopper, 40, _pos] spawn NEO_fnc_transportInsertionHold;
    (end)

See Also:
    ALiVE_fnc_doMoveRemote
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_chopper", objNull, [objNull]],
    ["_alt", 25, [0]],
    ["_pos", [0,0,0], [[]]]
];

if (isNull _chopper) exitWith {};

// The panel offers 2 to 50. Round so the aircraft flies the number the player
// read off the slider rather than a fraction of it.
_alt = (round _alt) max 2;

private _grp = group (driver _chopper);
private _endTime = time + 600;

// Native waypoints outrank a move order. If one is left over from an earlier
// task the aircraft works to that instead and sinks toward it.
while {(count (waypoints _grp)) > 1} do {
    deleteWaypoint ((waypoints _grp) select 1);
};

private _debug = !isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug};

while {
    alive _chopper
    && {time < _endTime}
    && {(_chopper getVariable ["NEO_radioTrasportUnitStatus", ""]) == "MISSION"}
    && {isNil {_chopper getVariable "NEO_radioTransportNewTask"}}
} do {
    private _agl = (getPosATL _chopper) select 2;
    private _dist = _chopper distance2D _pos;
    private _inBand = (_dist < 30) && {abs (_agl - _alt) < 4};

    _chopper flyInHeight _alt;

    if (!_inBand) then {
        // Pin it over the insertion point while it settles. If this is ever seen
        // to make the aircraft porpoise, drop the height out of the target and
        // let flyInHeight own the altitude on its own.
        [_chopper, [_pos select 0, _pos select 1, _alt]] call ALiVE_fnc_doMoveRemote;
    };

    if (_debug) then {
        ["CS TRANSPORT INSERTION HOLD: %1 want=%2m AGL=%3m dist=%4m inBand=%5 waypoints=%6",
            _chopper, _alt, round _agl, round _dist, _inBand, count (waypoints _grp)] call ALiVE_fnc_dump;
    };

    sleep 2;
};

if (_debug) then {
    ["CS TRANSPORT INSERTION HOLD: %1 released after %2s", _chopper, round (600 - (_endTime - time))] call ALiVE_fnc_dump;
};
