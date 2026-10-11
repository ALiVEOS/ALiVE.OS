/*
    NEO_fnc_transportGunnerDefend
    #530: let a transport's turret door gunners return fire while the AI pilot keeps flying
    its route uninterrupted.

    Measured on the rig (a Ghost Hawk past 8 riflemen 300 m off its track, 11 Oct): door
    gunners only fire while they are in the PILOT's group. Moved into a group of their own
    (the first version of this) they never fired once, even at COMBAT/RED with the enemy
    known. They are also silenced by combat mode BLUE, and by TARGET switched off on the
    pilot, who leads the group. What works and keeps the pilot calm: the crew stays one
    CARELESS group with combat mode YELLOW, only the pilot's AUTOCOMBAT is off, and a light
    loop shows the gunners the nearest hostile and orders the shot (unaided, a helicopter
    crew barely spots infantry: nothing known after 30 s hovering 300 m away). Run as the
    FSM sets the crew up, that fired 48 rounds and hit 4 of 8 men on a fly-past with the
    route unchanged, and the pilot stayed CARELESS hovering under fire. Only men in armed
    turrets count as gunners: a copilot's seat is a turret too.

    Params: 0: _chopper <OBJECT> - the transport
    Server-side only (the Combat Support transport crew is server-local).
    Author: Jman
*/

params ["_chopper"];
if (!isServer) exitWith {};
if (isNull _chopper) exitWith {};

private _grp = group driver _chopper;
private _gunners = ((allTurrets _chopper) select { (_chopper weaponsTurret _x) isNotEqualTo [] }) apply { _chopper turretUnit _x } select {
    !isNull _x && {_x != driver _chopper} && {!isPlayer _x}
};
if (_gunners isEqualTo []) exitWith {}; // unarmed transport - nothing to do
_chopper setVariable ["NEO_radioGunnerDefendArmed", true, true];

// targeting back on for the whole crew (the FSM's init switches it off), the pilot kept from
// escalating to COMBAT (that is what makes an AI helicopter hover or break off)
{ _x enableAI "TARGET"; _x enableAI "AUTOTARGET" } forEach (crew _chopper select {!isPlayer _x});
(driver _chopper) disableAI "AUTOCOMBAT";
// default the master switch on; the tablet ROE combo (fn_setROE) flips it to hold
_chopper setVariable ["NEO_radioGunnerDefendOn", true, true];
_grp setCombatMode "YELLOW";

// engagement loop: pick the nearest hostile with line of sight and put the gunners onto it
[_chopper] spawn {
    params ["_chopper"];
    while { alive _chopper && {alive driver _chopper} } do {
        private _grp = group driver _chopper;
        private _gside = side _grp;
        private _gunners = ((allTurrets _chopper) select { (_chopper weaponsTurret _x) isNotEqualTo [] }) apply { _chopper turretUnit _x } select {
            alive _x && {_x != driver _chopper} && {!isPlayer _x}
        };
        if (_gunners isEqualTo []) exitWith {};
        private _t = objNull;
        private _td = 1e9;
        {
            if (alive _x && {side _x != _gside} && {side _x != civilian}
                && {(_gside getFriend (side _x)) < 0.6} && {(_x distance _chopper) < _td}
                && {lineIntersectsSurfaces [eyePos _chopper, aimPos _x, _chopper, _x] isEqualTo []}) then {
                _td = _x distance _chopper;
                _t = _x;
            };
        } forEach (_chopper nearEntities [["Man","Car","Tank","Air","Ship"], 800]);

        if (!isNull _t && {_chopper getVariable ["NEO_radioGunnerDefendOn", true]}) then {
            _grp reveal [_t, 4];
            { _x doTarget _t; _x doFire _t } forEach _gunners;
        };
        sleep 2.5;
    };
};
