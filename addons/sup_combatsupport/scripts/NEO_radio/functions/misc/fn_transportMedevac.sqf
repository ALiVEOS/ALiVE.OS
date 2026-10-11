// NEO_fnc_transportMedevac
// ------------------------------------------------------------------
// The MEDEVAC transport task (#694). The helicopter lands at the point marked on the
// tablet and waits; players load their wounded with Load Wounded and send it off with
// Clear To Leave. It flies to its base, where everyone aboard who isn't its own crew is
// healed (ACE's full heal when ACE medical is loaded), waits a minute, flies them back to
// the landing zone, lets them out, and then goes home as on any RTB order.
//
// Started by transport.fsm's MEDEVAC link, which then waits in the Pickup holding state:
// any new tablet order still takes over, and this script notices (the status leaves
// MEDEVAC) and stops.
//
// Params: [_chopper, _callsign, _pos, _base, _player, _audio, _run]
//
// Author: Jman
// ------------------------------------------------------------------
params ["_chopper", "_callsign", "_pos", "_base", "_player", ["_audio", false], ["_run", 0]];

if (!isServer) exitWith {};

private _say = {
    params ["_text"];
    [[_chopper, format ["%1, %2", _callsign, _text], "side"], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};
// Still this run's to fly: a second MEDEVAC order keeps the status at MEDEVAC, so the run
// number the FSM gives each order is what tells an old run it has been replaced.
private _mine = { alive _chopper && {alive driver _chopper} && {(_chopper getVariable ["NEO_radioTrasportUnitStatus", ""]) == "MEDEVAC"} && {(_chopper getVariable ["NEO_radioMedevacRun", 0]) == _run} };
private _cleanup = {
    if ((_chopper getVariable ["NEO_radioMedevacRun", 0]) == _run) then {
        _chopper setVariable ["NEO_radioMedevacState", nil, true];
        _chopper setVariable ["NEO_radioMedevacClear", nil, true];
    };
    { deleteVehicle _x } forEach _pads;
};
private _pads = [];
// Stopped without a new order (a landing that never happened): home, rather than hang in the medevac.
private _bail = {
    if (call _mine) then {
        // Nobody left sitting in it: on the ground they get out here; in the air the radio says so.
        if ((call _passengers) isNotEqualTo []) then {
            if (isTouchingGround _chopper) then {
                { [_x] remoteExecCall ["unassignVehicle", _x]; [_x] remoteExecCall ["moveOut", _x] } forEach (call _passengers);
            } else {
                [format ["couldn't set down with %1 aboard; they're coming back to base with me.", count (call _passengers)]] call _say;
            };
        };
        ["couldn't set down, returning to base."] call _say;
        _chopper setVariable ["NEO_radioTransportNewTask", ["RTB", _base, 0, _player], true];
    };
    call _cleanup;
};
// The men in its cargo seats, by seat: counting "not the pilot's group" once caught the door
// gunners too (they had a group of their own then, #530) and put them out at the landing zone.
private _passengers = { (fullCrew [_chopper, "cargo"]) apply { _x select 0 } };

// Fly to a point and set down, the way the FSM's own landings do: a pad to aim at, then
// land once the move is done, waiting for the skids rather than for "ready" (which counts
// within 100 m for aircraft).
private _fnc_setDown = {
    params ["_at", "_mode"];
    private _spot = _at findEmptyPosition [0, 150, typeOf _chopper];
    if (_spot isEqualTo []) then { _spot = +_at };
    _spot set [2, 0];
    private _pad = createVehicle ["Land_HelipadEmpty_F", _spot, [], 0, "CAN_COLLIDE"];
    _pads pushBack _pad;
    _chopper flyInHeight 60;
    [_chopper, _spot] call ALiVE_fnc_doMoveRemote;
    private _t = time;
    waitUntil { sleep 2; !(call _mine) || {(_chopper distance2D _spot) < 150} || {time - _t > 600} };
    if !(call _mine) exitWith { false };
    // A land order isn't always taken: once a pilot hovered at 58 m over the zone for three
    // minutes. So up to three tries a minute apart, back over the pad each time, the later
    // ones with a plain LAND.
    private _down = false;
    {
        if !(call _mine) exitWith {};
        if (_forEachIndex > 0) then {
            [_chopper, _spot] call ALiVE_fnc_doMoveRemote;
            private _t2 = time;
            waitUntil { sleep 2; !(call _mine) || {(_chopper distance2D _spot) < 60} || {time - _t2 > 90} };
        };
        [_chopper, _x] call ALiVE_fnc_landRemote;
        _t = time;
        waitUntil { sleep 1; !(call _mine) || {isTouchingGround _chopper && {speed _chopper < 3}} || {time - _t > 60} };
        if (isTouchingGround _chopper) exitWith { _down = true };
    } forEach [_mode, "LAND", "LAND"];
    (call _mine) && {_down}
};

// Everyone in its cargo seats. ACE's own full heal where ACE
// medical is loaded, run where each patient is local; otherwise the game's damage.
private _fnc_heal = {
    private _ace = isClass (configFile >> "CfgPatches" >> "ace_medical_treatment");
    {
        if (_ace) then {
            [_x] remoteExecCall ["ace_medical_treatment_fnc_fullHealLocal", _x];
        } else {
            [_x, 0] remoteExecCall ["setDamage", _x];
            [_x, false] remoteExecCall ["setUnconscious", _x];
        };
    } forEach (call _passengers);
};

// 1. the landing zone
if (_audio && {!isNull _player}) then {
    leader _chopper kbTell [_player, "ALIVE_SUPP_protocol", "Transport_Acknowledged", "GROUP"];
};
["Medevac inbound to your marked position."] call _say;
// A plain LAND, engine off: landed with GET IN the pilot lifted off by himself as soon as men
// boarded, before anyone had cleared him. The move to base starts the engine again.
if !([_pos, "LAND"] call _fnc_setDown) exitWith { call _bail };
private _lz = getPosATL _chopper;
_chopper setVariable ["NEO_radioMedevacState", "LZ", true];
_chopper setVariable ["NEO_radioMedevacClear", false, true];
["on the ground. Load your wounded and give the word when we're clear to leave."] call _say;

private _t = time;
waitUntil { sleep 1; !(call _mine) || {_chopper getVariable ["NEO_radioMedevacClear", false]} || {time - _t > 900} };
if !(call _mine) exitWith { call _cleanup };
_chopper setVariable ["NEO_radioMedevacState", "AWAY", true];
if ((call _passengers) isEqualTo []) exitWith {
    ["nobody aboard, returning to base."] call _say;
    call _cleanup;
    _chopper setVariable ["NEO_radioTransportNewTask", ["RTB", _base, 0, _player], true];
};

// 2. base, and treatment
[format ["lifting off with %1 aboard, heading for base.", count (call _passengers)]] call _say;
if !([_base, "LAND"] call _fnc_setDown) exitWith { call _bail };
call _fnc_heal;
["at base, the wounded are being treated."] call _say;
_t = time;
waitUntil { sleep 2; !(call _mine) || {time - _t > 60} };
if !(call _mine) exitWith { call _cleanup };
call _fnc_heal;

// 3. back to the landing zone, everyone out
["treatment done, bringing them back to you."] call _say;
if !([_lz, "GET OUT"] call _fnc_setDown) exitWith { call _bail };
{
    [_x] remoteExecCall ["unassignVehicle", _x];
    [_x] remoteExecCall ["moveOut", _x];
} forEach (call _passengers);
_t = time;
waitUntil { sleep 1; ((call _passengers) isEqualTo []) || {time - _t > 30} };
["they're back with you. Returning to base."] call _say;
call _cleanup;
// home as on any RTB order, so the helicopter is serviced and offered again the usual way
_chopper setVariable ["NEO_radioTransportNewTask", ["RTB", _base, 0, _player], true];
