// #530: the transport ROE combo is the master on/off for the scripted door-gunner defence
// (NEO_fnc_transportGunnerDefend). Engage -> the crew's combat mode is YELLOW and the defend
// loop shows the gunners their targets; Hold -> BLUE, so nobody fires, and the loop skips
// firing. The crew stays CARELESS either way, so the aircraft keeps flying. Runs server-side
// (dispatched via BIS_fnc_MP with target false).
// Author: Jman
params ["_chopper", "_engage"];
if (isNull _chopper) exitWith {};

_chopper setVariable ["NEO_radioGunnerDefendOn", _engage, true];

// only an aircraft whose defence started: one with no gunners keeps the FSM's BLUE
private _grp = group driver _chopper;
if (!isNull _grp && {_chopper getVariable ["NEO_radioGunnerDefendArmed", false]}) then {
    _grp setCombatMode (["BLUE", "YELLOW"] select _engage);
};
