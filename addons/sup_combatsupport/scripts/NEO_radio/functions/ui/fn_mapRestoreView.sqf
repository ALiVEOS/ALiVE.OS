/*
    NEO_fnc_mapRestoreView
    #698: drive a map control's view to a captured [scale, centre] with a short feedback loop.
    ctrlMapAnimAdd centres on a point OFFSET from the control's geometric centre, so a plain
    "set the anim target to the captured centre" lands off by a fixed screen offset and each
    terrain toggle drifts (RPT-confirmed). Here the target is the value read by
    ctrlMapScreenToWorld[geometric centre]; each draw we measure where the previous anim actually
    landed with that SAME reading and nudge the aim so the measured centre converges onto the
    captured one - the offset cancels because capture and measurement use the same reading.

    Params: 0: _map <CONTROL>  1: _scale <NUMBER>  2: _targetCentre <ARRAY> (captured reading)
    Author: Jman
*/
params ["_map", "_scale", "_targetCentre"];
if (isNull _map) exitWith {};

_map setVariable ["NEO_mapRestoreView", [_scale, _targetCentre]];
_map setVariable ["NEO_mapAim", _targetCentre];
_map setVariable ["NEO_mapRestorePrimed", false];
_map setVariable ["NEO_mapRestoreTicks", 10];
_map ctrlAddEventHandler ["Draw", {
    params ["_ctrl"];
    private _ticks = _ctrl getVariable ["NEO_mapRestoreTicks", 0];
    if (_ticks > 0) then {
        _ctrl setVariable ["NEO_mapRestoreTicks", _ticks - 1];
        (_ctrl getVariable ["NEO_mapRestoreView", [0.16, [0,0,0]]]) params ["_s", "_target"];
        private _aim = _ctrl getVariable ["NEO_mapAim", _target];
        if (_ctrl getVariable ["NEO_mapRestorePrimed", false]) then {
            // measure where the previous anim landed (same reading as capture) and correct the aim
            private _cp = ctrlPosition _ctrl;
            private _actual = _ctrl ctrlMapScreenToWorld [(_cp select 0) + (_cp select 2) / 2, (_cp select 1) + (_cp select 3) / 2];
            _aim = [(_aim select 0) - ((_actual select 0) - (_target select 0)), (_aim select 1) - ((_actual select 1) - (_target select 1))];
            _ctrl setVariable ["NEO_mapAim", _aim];
        } else {
            // first pass just aims at the target so there is a baseline anim to measure next draw
            _ctrl setVariable ["NEO_mapRestorePrimed", true];
        };
        ctrlMapAnimClear _ctrl;
        _ctrl ctrlMapAnimAdd [0, _s, _aim];
        ctrlMapAnimCommit _ctrl;
    };
}];
