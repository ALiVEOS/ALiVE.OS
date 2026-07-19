// #530: the transport ROE combo is the master on/off for the scripted door-gunner defence
// (NEO_fnc_transportGunnerDefend). Engage -> gunners defend (their own group goes AWARE + fires
// and the defend loop is armed); Hold -> gunners stand down (BLUE + the loop skips firing). It
// only ever touches the gunners' own group, never the pilot, so the aircraft keeps flying either
// way. Runs server-side (dispatched via BIS_fnc_MP with target false).
// Author: Jman
params ["_chopper", "_engage"];
if (isNull _chopper) exitWith {};

_chopper setVariable ["NEO_radioGunnerDefendOn", _engage, true];

private _gunGrp = _chopper getVariable ["NEO_radioGunnerGroup", grpNull];
if (!isNull _gunGrp) then {
    if (_engage) then {
        _gunGrp setBehaviour "AWARE";
        _gunGrp setCombatMode "YELLOW";
    } else {
        _gunGrp setCombatMode "BLUE";
    };
};