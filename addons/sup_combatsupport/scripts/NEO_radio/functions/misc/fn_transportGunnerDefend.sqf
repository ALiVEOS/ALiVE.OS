/*
    NEO_fnc_transportGunnerDefend
    #530: let a transport's turret door gunners return fire while the AI pilot keeps flying
    its route uninterrupted.

    Behaviour is group-wide (Biki), so a gunner cannot be AWARE while the pilot stays CARELESS
    inside one group - that was the failed first attempt (setBehaviour on the gunner flipped the
    whole crew, the pilot reacted and hovered). This instead moves the real turret gunners into
    their OWN AWARE group, decoupled from the pilot's CARELESS group, and runs a light loop that
    nudges each gunner onto the nearest visible hostile and forces the shot (passive heli
    door-gun AI is too sluggish to rely on). The pilot / vehicle group is never touched, so the
    aircraft keeps flying its doMove and lands normally.

    Params: 0: _chopper <OBJECT> - the transport
    Server-side only (the Combat Support transport crew is server-local).
    Author: Jman
*/

params ["_chopper"];
if (!isServer) exitWith {};
if (isNull _chopper) exitWith {};

private _side = side _chopper;
private _gunGrp = createGroup [_side, true]; // deleteWhenEmpty - tidies itself if the gunners die
_chopper setVariable ["NEO_radioGunnerGroup", _gunGrp, true];

// move real turret gunners (never the pilot, never a player) into the defend group and undo the
// react-init targeting leash on them
private _gunners = [];
{
    private _g = _chopper turretUnit _x;
    if (!isNull _g && {_g != driver _chopper} && {!isPlayer _g}) then {
        [_g] joinSilent _gunGrp;
        _g enableAi "TARGET";
        _g enableAi "AUTOTARGET";
        _gunners pushBack _g;
    };
} forEach allTurrets _chopper;

if (_gunners isEqualTo []) exitWith {
    // unarmed transport - nothing to do
    deleteGroup _gunGrp;
    _chopper setVariable ["NEO_radioGunnerGroup", grpNull, true];
};

_gunGrp setBehaviour "AWARE";
_gunGrp setCombatMode "YELLOW";
// default the master switch on; the tablet ROE combo (fn_setROE) flips it to hold
_chopper setVariable ["NEO_radioGunnerDefendOn", true, true];
// keep the pilot from auto-escalating to COMBAT behaviour (that switch is what makes an AI heli
// hover / break off); per-unit, does not touch the gunners
{ _x disableAi "AUTOCOMBAT" } forEach (crew _chopper select {!(_x in _gunners)});

// engagement loop: pick the nearest hostile with line of sight and force the gunners onto it
[_chopper, _gunGrp] spawn {
    params ["_chopper", "_gunGrp"];
    private _gside = side _gunGrp;
    while { alive _chopper && {({alive _x} count units _gunGrp) > 0} } do {
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
            // reveal to the GUNNER group (not the vehicle/pilot group) - doFire is dropped unless
            // the firing unit's own group knows the target
            _gunGrp reveal [_t, 4];
            { _x doTarget _t; _x doFire _t } forEach (units _gunGrp select {alive _x});
        };
        sleep 2.5;
    };
    // group is deleteWhenEmpty and RespawnTransportAsset recycles it on death - no explicit
    // deleteGroup here (it would warn on a not-yet-GC'd non-empty group)
};
