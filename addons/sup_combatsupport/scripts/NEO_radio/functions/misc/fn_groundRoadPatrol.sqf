/*
    NEO_fnc_groundRoadPatrol
    #690: drive a Combat Support ground vehicle back and forth between two points along the
    roads, stopping at each end, until it is given another order (its run number moves on)
    or is lost.
    #1146: each stop lasts the Ground Transport module's Patrol Stop Time (30 s by default), and
    longer while someone is still getting in or out, up to 2 minutes in all (or the stop time,
    when that is longer).
    Params: [vehicle, point A, point B, run number, round known enemy (default: the module setting)]
    Author: Jman
*/
params ["_veh", "_posA", "_posB", "_run", ["_avoid", NEO_radioLogic getVariable ["combatsupport_groundavoid", false]]];
private _mine = { alive _veh && {(_veh getVariable ["NEO_radioGroundRun", -1]) == _run} };

// at a stop: until the stop time is up and nobody is getting in or out, or the cap is reached
private _fnc_stop = {
    private _wait = _veh getVariable ["NEO_groundPatrolWait", 30];
    private _cap = _wait max 120;
    private _side = _veh getVariable ["NEO_groundSide", side group _veh];
    private _start = time;
    private _aboard = count crew _veh;
    private _changed = -100;
    private _why = "time";
    while { call _mine } do {
        // someone got in or out in the last 5 s, or a friendly on foot within 10 m is heading for it: a player
        // close by, or an AI told to board it (its own crew, out to retake a seat, among them)
        private _n = count crew _veh;
        if (_n != _aboard) then { _aboard = _n; _changed = time };
        private _boarding = (time - _changed < 5) || {((_veh nearEntities ["CAManBase", 10]) findIf {
            alive _x && {vehicle _x == _x} && {((side group _x) getFriend _side) >= 0.6}
            && {isPlayer _x || {(assignedVehicle _x) isEqualTo _veh}}
        }) >= 0};
        if (time - _start >= _cap) exitWith { _why = "cap" };
        if (time - _start >= _wait && {!_boarding}) exitWith {};
        sleep 1;
    };
    if (missionNamespace getVariable ["ALiVE_sup_combatsupport_debug", false]) then {
        ["ALiVE Combat Support - ground transport %1: patrol stop over after %2 s (stop time %3 s, ended by %4)",
            _veh getVariable ["NEO_groundCallsign", ""], round (time - _start), _wait, _why] call ALiVE_fnc_dump;
    };
};

private _legs = 0;
while { call _mine } do {
    private _to = [_posA, _posB] select (_legs mod 2 == 0);
    private _ok = [_veh, _to, _run, true, 0, _avoid] call NEO_fnc_groundDrive;
    if !(call _mine) exitWith {};
    // an immobile vehicle waits (the order loop holds it); try the leg again once it can move
    if (_ok) then {
        _legs = _legs + 1;
        _veh setVariable ["NEO_groundPatrolLegs", _legs, true];
        call _fnc_stop;
    } else {
        waitUntil { sleep 2; (canMove _veh && {fuel _veh >= 0.02}) || {!(call _mine)} };
    };
};
