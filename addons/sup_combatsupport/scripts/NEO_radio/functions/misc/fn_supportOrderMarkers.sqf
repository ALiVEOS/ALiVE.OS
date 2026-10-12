/*
    NEO_fnc_supportOrderMarkers
    Keeps an order's points on the ordering player's map while the order runs: a transport
    helicopter's destination, a ground transport's destination, or both ends of its road
    patrol. The markers go when the vehicle takes another order, finishes (status NONE),
    is lost, or the order is cleared. A new order from this player replaces the old markers.
    Local to the player who gave the order, like the tablet's other markers. Scheduled.
    Params: [vehicle, order as posted, status variable name, [[position, text], ...]]
    Author: Jman
*/
params ["_veh", "_task", "_statusVar", "_points"];
if (!hasInterface || {isNull _veh}) exitWith {};
// the Combat Support module's Keep Order Markers setting
if !(NEO_radioLogic getVariable ["combatsupport_ordermarkers", true]) exitWith {};
{ deleteMarkerLocal _x } forEach (_veh getVariable ["NEO_orderMarkers", []]);
private _made = [];
{
    _x params ["_pos", "_text"];
    NEO_orderMarkerCount = (missionNamespace getVariable ["NEO_orderMarkerCount", 0]) + 1;
    private _m = createMarkerLocal [format ["NEO_orderMk_%1", NEO_orderMarkerCount], _pos];
    _m setMarkerTypeLocal "hd_Pickup_noShadow";
    _m setMarkerColorLocal "ColorBlue";
    _m setMarkerTextLocal _text;
    _made pushBack _m;
} forEach _points;
_veh setVariable ["NEO_orderMarkers", _made];
[_veh, _task, _statusVar, _made] spawn {
    params ["_veh", "_task", "_statusVar", "_made"];
    // the vehicle picks the order up within a few seconds
    private _t = time;
    waitUntil { sleep 1; ((_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task) || {time - _t > 20} || {!alive _veh} };
    if ((_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task) then {
        waitUntil {
            sleep 2;
            !alive _veh
            || {!((_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task)}
            || {(_veh getVariable [_statusVar, ""]) in ["NONE", "KILLED"]}
        };
    };
    { deleteMarkerLocal _x } forEach _made;
    if ((_veh getVariable ["NEO_orderMarkers", []]) isEqualTo _made) then { _veh setVariable ["NEO_orderMarkers", []] };
};
