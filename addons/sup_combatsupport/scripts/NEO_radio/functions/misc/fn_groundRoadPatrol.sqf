/*
    NEO_fnc_groundRoadPatrol
    #690: drive a Combat Support ground vehicle back and forth between two points along the
    roads, pausing 10 s at each end, until it is given another order (its run number moves
    on) or is lost.
    Params: [vehicle, point A, point B, run number]
    Author: Jman
*/
params ["_veh", "_posA", "_posB", "_run"];
private _mine = { alive _veh && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run} };
private _legs = 0;
while { call _mine } do {
    private _to = [_posA, _posB] select (_legs mod 2 == 0);
    private _ok = [_veh, _to, _run] call NEO_fnc_groundDrive;
    if !(call _mine) exitWith {};
    // an immobile vehicle waits (the order loop holds it); try the leg again once it can move
    if (_ok) then {
        _legs = _legs + 1;
        _veh setVariable ["NEO_groundPatrolLegs", _legs, true];
        sleep 10;
    } else {
        waitUntil { sleep 2; (canMove _veh && {fuel _veh >= 0.02}) || {!(call _mine)} };
    };
};
