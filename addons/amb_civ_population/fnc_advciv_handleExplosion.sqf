/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_handleExplosion
Description:
    Server-side handler called when an explosion occurs near AdvCiv civilians.
    Scales reaction intensity by distance from the blast and accumulates a shot
    counter on each affected unit. Civilians in restrictive player orders
    (HANDSUP, GETDOWN, KNEEL) only have their hide timer extended; all others
    are pushed into PANIC or ALERT depending on proximity and accumulated
    stress, and are immediately redirected to flee away from the explosion
    origin. Units following the player are unconditionally broken out of FOLLOW
    and sent into PANIC if within 50 m.
Parameters:
    _this select 0: ARRAY  - World position [x,y,z] of the explosion
    _this select 1: OBJECT - The object that caused the explosion (may be objNull)
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_handleFired, ALIVE_fnc_advciv_brainTick
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_pos", [0,0,0], [[]]],
    ["_source", objNull, [objNull]]
];

if (!isServer) exitWith {};

// Defensive: AdvCiv globals are published from
// fnc_civilianPopulationSystemInit. An explosion can fire BEFORE that
// init runs (early mission preview, intro events). Reading globals
// while still nil crashes - `!nil` errors on its own, and a nil _range
// would make nearEntities throw "Type Any, expected Number". Same
// hardening applied to fnc_advciv_handleFired.
if (isNil "ALiVE_advciv_enabled" || {!ALiVE_advciv_enabled}) exitWith {};
if (isNil "ALiVE_advciv_explosionRange") exitWith {};

private _range    = ALiVE_advciv_explosionRange;
private _nearCivs = _pos nearEntities ["CAManBase", _range];

{
    private _civ = _x;

    // Skip any unit that isn't an active AdvCiv civilian
    if (!alive _civ || {side _civ != civilian} || {isPlayer _civ} || {!(_civ getVariable ["ALiVE_advciv_active", false])}) then {
    } else {

        private _dist  = _civ distance _pos;
        private _order = _civ getVariable ["ALiVE_advciv_order", "NONE"];

        // Scale stress intensity linearly: maximum (15) at point-blank, minimum (2) at edge of range
        private _intensity = linearConversion [0, _range, _dist, 15, 2, true];
        private _cur = _civ getVariable ["ALiVE_advciv_nearShots", 0];
        _civ setVariable ["ALiVE_advciv_nearShots", (_cur + _intensity) min 20];
        _civ setVariable ["ALiVE_advciv_lastShotTime", time];

        // Tag the source object as having caused harm near a civilian
        if (!isNull _source) then {
            _source setVariable ["ALiVE_advciv_firedAtCivTime", time, true];
            if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Threat DEBUG] firedAtCivTime SET unit=%1 side=%2 time=%3 origin=Explosion", name _source, side _source, time]; };
        };

        if (_order in ["HANDSUP", "GETDOWN", "KNEEL"]) then {
            // Under a restrictive order — don't break the pose, but extend hiding
            // timer so the unit stays down if it was already hiding
            if (_civ getVariable ["ALiVE_advciv_state", "CALM"] == "HIDING") then {
                _civ setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
            };
        } else {

            private _state = _civ getVariable ["ALiVE_advciv_state", "CALM"];

            if (_state in ["CALM", "ALERT"]) then {
                // Close range or already stressed: immediate PANIC with flee direction
                if (_dist < _range * 0.7 || {_civ getVariable ["ALiVE_advciv_nearShots", 0] > 3}) then {
                    _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                    _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                    _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                    _civ setSpeedMode "FULL";
                    if (vehicle _civ == _civ) then { _civ setUnitPos "UP"; };
                    _civ setBehaviour "AWARE";
                    _civ enableAI "PATH";
                    if (vehicle _civ == _civ) then {
                        private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                        _civ doMove ((getPos _civ) getPos [40 + random 40, _fleeDir]);
                    };
                } else {
                    // Outer range and low stress: move to ALERT only
                    if (_state == "CALM") then {
                        _civ setVariable ["ALiVE_advciv_state", "ALERT", true];
                        _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                        _civ setVariable ["ALiVE_advciv_stateTimer", 0];
                        _civ setBehaviour "AWARE";
                        if (vehicle _civ == _civ) then { _civ setUnitPos "UP"; };
                        _civ doWatch _pos;
                    };
                };
            };

            // Already hiding — refresh the timer to keep them down longer
            if (_state == "HIDING") then {
                _civ setVariable ["ALiVE_advciv_stateTimer", time + ALiVE_advciv_hideTimeMin + random (ALiVE_advciv_hideTimeMax - ALiVE_advciv_hideTimeMin)];
            };

            // Break FOLLOW order if the explosion is close — the civilian
            // shouldn't blindly follow the player into an active blast zone
            if (_state == "ORDERED" && {_order == "FOLLOW"} && {_dist < 50}) then {
                _civ setVariable ["ALiVE_advciv_order", "NONE", true];
                _civ setVariable ["ALiVE_advciv_state", "PANIC", true];
                _civ setVariable ["ALiVE_advciv_panicSource", _pos, true];
                _civ setVariable ["ALiVE_advciv_hidingPos", [], true];
                _civ setSpeedMode "FULL";
                if (vehicle _civ == _civ) then { _civ setUnitPos "UP"; };
                _civ enableAI "PATH";
                if (vehicle _civ == _civ) then {
                    private _fleeDir = (_pos getDir (getPos _civ)) + (-30 + random 60);
                    _civ doMove ((getPos _civ) getPos [40, _fleeDir]);
                };
            };
        };
    };
} forEach _nearCivs;
