// NEO_fnc_transportAvoidLegs
// ------------------------------------------------------------------
// The turns a Combat Support helicopter flies to keep clear of known enemy on its way to a task
// (A. Ares on Discord, 4 Nov 2026). Asked by transport.fsm each time an order arrives. When the
// order's Route is set to avoid known enemy (the Route box on the tablet; an order without one
// takes the module's Air Transport Avoids Known Enemy), it gathers the places its side's AI
// Commander has seen the enemy in the last 30 minutes near the way there, and returns 2D points
// that take the straight line round each of them, nearest first. Returns [] when there is nothing
// to go round, no AI Commander for the side, or the task is under 1.5 km away.
//
// Unscheduled-safe: no suspension.
//
// Params: [_chopper, _order, _pos, _base]
//   _order  the order array: [task, pos, amount, player, round known enemy]
//   _pos    where the order sends it; _base is used instead for RTB
//
// Author: Jman
// ------------------------------------------------------------------
params ["_chopper", ["_order", []], ["_pos", []], ["_base", []]];

// an order the server posts itself (a Medevac or escort heading home) keeps the last Route chosen
private _roundEnemy = _order param [4, _chopper getVariable ["NEO_transportRoute", NEO_radioLogic getVariable ["combatsupport_airavoid", false]]];
if !(_roundEnemy isEqualTo true) exitWith { [] };
if (isNull _chopper || {isNil "ALiVE_fnc_OPCOM"}) exitWith { [] };

private _task = toUpper (_order param [0, ""]);
private _to = [_pos, _base] select (_task == "RTB");
if !(_to isEqualType [] && {count _to > 1}) exitWith { [] };
_to = [_to select 0, _to select 1, 0];
private _from = getPosATL _chopper;
_from = [_from select 0, _from select 1, 0];
if ((_from distance2D _to) < 1500) exitWith { [] };

// the known enemy near the way there: one place for each within 200 m of none already taken
private _side = str side group driver _chopper;
private _mid = [((_from select 0) + (_to select 0)) / 2, ((_from select 1) + (_to select 1)) / 2, 0];
private _far = (_from distance2D _to) / 2 + 1500;
private _places = [];
{
    if (([_x, "side", ""] call ALiVE_fnc_hashGet) == _side) then {
        ([_x, "knownEnemy"] call ALiVE_fnc_OPCOM) params [["_ids", []], ["_poss", []]];
        {
            private _p = _poss param [_forEachIndex, []];
            // a report with no position comes through as 0,0
            if (_p isEqualType [] && {count _p > 1} && {(_p select 0) != 0 || {(_p select 1) != 0}} && {(_p distance2D _mid) < _far} && {(_places findIf { (_x distance2D _p) < 200 }) < 0}) then {
                _places pushBack [_p select 0, _p select 1, 0];
            };
        } forEach _ids;
    };
} forEach (missionNamespace getVariable ["OPCOM_instances", []]);
if (_places isEqualTo []) exitWith { [] };

// circles to keep out of: 700 m round each place (small arms and launchers reach a low helicopter
// further than a vehicle on the road), plus 200 m to spare
private _clear = 900;
private _circles = _places apply { [_x, _clear] };
// places close together become one circle round both, up to 2.5 km across the middle
private _merged = true;
private _pass = 0;
while { _merged && {_pass < 20} } do {
    _merged = false;
    _pass = _pass + 1;
    scopeName "merge";
    for "_i" from 0 to (count _circles - 2) do {
        for "_j" from (_i + 1) to (count _circles - 1) do {
            (_circles select _i) params ["_c1", "_r1"];
            (_circles select _j) params ["_c2", "_r2"];
            private _d = _c1 distance2D _c2;
            if (_d < (_r1 + _r2)) then {
                private _new = call {
                    if (_d + _r2 <= _r1) exitWith { [_c1, _r1] };
                    if (_d + _r1 <= _r2) exitWith { [_c2, _r2] };
                    private _r = (_d + _r1 + _r2) / 2;
                    private _k = (_r - _r1) / (_d max 1);
                    [[(_c1 select 0) + ((_c2 select 0) - (_c1 select 0)) * _k, (_c1 select 1) + ((_c2 select 1) - (_c1 select 1)) * _k, 0], _r min 2500]
                };
                _circles deleteAt _j;
                _circles set [_i, _new];
                _merged = true;
                breakTo "merge";
            };
        };
    };
};
// nothing can be done about a circle it starts in or has to land in: the order goes there anyway
_circles = _circles select { ((_x select 0) distance2D _from) > (_x select 1) && {((_x select 0) distance2D _to) > (_x select 1)} };
private _avoided = count _circles;
if (_circles isEqualTo []) exitWith { [] };

// the turns: wherever a stretch of the way passes through a circle, a turn beside the circle that
// makes both stretches either side of it just touch the circle, on the side the line already passes
private _edge = 300;
private _inMap = { params ["_p"]; (_p select 0) > _edge && {(_p select 1) > _edge} && {(_p select 0) < (worldSize - _edge)} && {(_p select 1) < (worldSize - _edge)} };
private _path = [_from, _to];
private _done = [];
for "_n" from 1 to 12 do {
    private _hit = [];
    {
        private _ci = _forEachIndex;
        if !(_ci in _done) then {
            _x params ["_c", "_R"];
            for "_k" from 0 to (count _path - 2) do {
                private _a = _path select _k;
                private _b = _path select (_k + 1);
                private _len = _a distance2D _b;
                if (_len > 1) then {
                    private _u = [((_b select 0) - (_a select 0)) / _len, ((_b select 1) - (_a select 1)) / _len];
                    private _t = ((_c select 0) - (_a select 0)) * (_u select 0) + ((_c select 1) - (_a select 1)) * (_u select 1);
                    if (_t > 0 && {_t < _len}) then {
                        private _nv = [-(_u select 1), _u select 0];
                        private _side = ((_c select 0) - (_a select 0)) * (_nv select 0) + ((_c select 1) - (_a select 1)) * (_nv select 1);
                        if (abs _side < _R) exitWith { _hit = [_ci, _k, _t, _len, _u, _nv, _side] };
                    };
                };
            };
        };
        if (_hit isNotEqualTo []) exitWith {};
    } forEach _circles;
    if (_hit isEqualTo []) exitWith {};
    _hit params ["_ci", "_k", "_t", "_len", "_u", "_nv", "_side"];
    (_circles select _ci) params ["_c", "_R"];
    _done pushBack _ci;
    private _a = _path select _k;
    private _s = [1, -1] select (_side < 0);
    private _d = abs _side;
    private _p = [(_a select 0) + (_u select 0) * _t, (_a select 1) + (_u select 1) * _t, 0];
    private _L = _t min (_len - _t);
    // how far from the line, on the line's side of the circle, the turn sits
    private _D = if (_L > _R) then {
        (_L * _R * sqrt ((_L ^ 2) + (_d ^ 2) - (_R ^ 2)) - (_L ^ 2) * _d) / ((_L ^ 2) - (_R ^ 2))
    } else {
        _R + 100 - _d
    };
    private _w = [(_p select 0) - _s * (_nv select 0) * _D, (_p select 1) - _s * (_nv select 1) * _D, 0];
    // off the map that way: round the other side of the circle instead
    if !([_w] call _inMap) then {
        private _D2 = _R + 100 + _d;
        _w = [(_p select 0) + _s * (_nv select 0) * _D2, (_p select 1) + _s * (_nv select 1) * _D2, 0];
    };
    if ([_w] call _inMap) then { _path insert [_k + 1, [_w]] };
};

// the turns alone, none within 500 m of the one before or of the task, six at most
private _legs = [];
private _last = _from;
{
    if ((_x distance2D _last) >= 500 && {(_x distance2D _to) >= 500}) then { _legs pushBack _x; _last = _x };
} forEach (_path select [1, count _path - 2]);
_legs resize ((count _legs) min 6);

if (_legs isNotEqualTo []) then {
    ["ALiVE Combat Support - %1 flies round %2 known enemy place(s) to %3, by %4 turn(s)", groupId group driver _chopper, _avoided, mapGridPosition _to, count _legs] call ALiVE_fnc_dump;
};
_legs
