/*
    NEO_fnc_groundStop
    #690: bring a Combat Support ground vehicle to a halt without a skid: hold the driver,
    bleed off the speed, then let the speed limit go again once it has stopped.
    Params: 0: _veh <OBJECT>
    Author: Jman
*/
params ["_veh"];
if (isNull _veh) exitWith {};
if (!local _veh) exitWith { [_veh] remoteExecCall ["NEO_fnc_groundStop", owner _veh] };
private _grp = group driver _veh;
while { (count (waypoints _grp)) > 1 } do { deleteWaypoint [_grp, (count (waypoints _grp)) - 1] };
doStop (driver _veh);
_veh limitSpeed 0;
_veh setVelocity ((velocity _veh) vectorMultiply 0.15);
[_veh] spawn {
    params ["_veh"];
    private _t = time;
    waitUntil { sleep 0.5; speed _veh < 1 || {time - _t > 10} || {!alive _veh} };
    _veh limitSpeed -1;
};
