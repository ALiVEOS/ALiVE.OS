
private ["_battery", "_targetPos", "_missionType", "_ordnanceType", "_rateOfFire",
        "_missionRoundCount", "_missionTimeLength", "_unit", "_ordnance", "_eta","_grp","_dummy","_target","_dispersion","_units"];

_battery = _this select 0;
_targetPos = _this select 1;
_missionType = _this select 2;
_ordnanceType = _this select 3;    //"8Rnd_82mm_Mo_shells";
_rateOfFire = _this select 4; //0
_missionRoundCount = _this select 5;  //6
_missionTimeLength = _this select 5; //6
_unit = _this select 6;
_ordnance = _this select 7;
_dispersion = _this select 8;
_units = _this select 9;


if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["MISSION: %1", _this] call ALiVE_fnc_dump; };

// Arty is on mission
_battery setVariable ["ARTY_SHOTCALLED", false, true];
_battery setVariable ["ARTY_SPLASH", false, true];
_battery setVariable ["ARTY_COMPLETE", false, true];
_battery setVariable ["ARTY_NOSHOTS", false, true];
// counted from this mission only, before anything waits on it
_battery setVariable ["ALiVE_CS_shotsFired", 0];
_battery setVariable ["ARTY_ONMISSION", true, true];

// Ensure that the target position is 3d.
if ((count _targetPos) == 2) then
{
    _targetPos = [_targetPos select 0, _targetPos select 1, 0];
};

sleep 15;

// "firing on target" and "splash" wait for the first round that actually leaves, and the splash is timed
// from it. They used to follow the order on a timer, so a gun that never fired (the 3CB M270's launcher
// ignores the engine's artillery orders) still reported firing, splash and rounds complete.
[_battery,_targetPos,_ordnance] spawn {

    _battery = _this select 0;
    // the shot count below decides whether nothing left the guns (ARTY_NOSHOTS), once every order is out, so a
    // staggered mission's late first round is never called a failure. The guns are the server's own crews, where
    // their Fired handlers run.
    waitUntil { sleep 0.5; (_battery getVariable ["ALiVE_CS_shotsFired", 0]) > 0 || {_battery getVariable ["ARTY_NOSHOTS", false]} };
    if ((_battery getVariable ["ALiVE_CS_shotsFired", 0]) == 0) exitWith {
        // nothing left the guns: the radio says so instead of calling a splash
        _battery setVariable ["ARTY_SHOTCALLED", true, true];
        sleep 2;
        _battery setVariable ["ARTY_SPLASH", true, true];
    };
    _battery setVariable ["ARTY_SHOTCALLED", true, true];
    //Get position for ETA
    _dummy = "Land_HelipadEmpty_F" createVehicleLocal (_this select 1);
    _eta = (vehicle _battery) getArtilleryETA [getPos _dummy, _this select 2];
    deleteVehicle _dummy;
    // rounds launched by script (below) carry their own flight time
    _eta = _battery getVariable ["ALiVE_CS_scriptETA", _eta];
    //["BATTERY: %1 due in %2 seconds", _battery, _eta] call ALiVE_fnc_dump;

    // no answer (the leader's own vehicle can't fire this round): give the rounds a little time anyway
    if (_eta < 0) then { _eta = 10 };
    sleep _eta;

    _battery setVariable ["ARTY_SPLASH", true, true];

};

// Count the shells that actually leave, and take only those off the battery. Its rounds used to come off as
// the order was given, so a mission no gun could fire (out of reach, or a sea point the engine won't aim at)
// still emptied the battery and was reported as fired. Only the mission's own magazine counts, so a
// commander's machine gun doesn't.
private _guns = [];
{
    private _gun = vehicle _x;
    if (!isNull _gun && {!(_gun in _guns)}) then { _guns pushBack _gun };
} forEach (_units + [_battery]);
_battery setVariable ["ALiVE_CS_scriptETA", nil];

// Some launchers ignore the engine's artillery orders: the 3CB M270 has its rocket launcher off the turret the
// AI aims, so its crew never fires. Their rounds are launched from them by script instead, with
// the drag-free launch for the distance, which is how the engine's own artillery flies (within 5 m at 3 km and
// 50 m at 6 km).
// The weapon holding this round on a gun, and where it points: a gun whose AI is aiming turns it within seconds.
private _fnc_aim = {
    params ["_gun"];
    // every turret's weapons: weapons on a vehicle lists only the driver's, and a gun sits on a turret.
    // [] when no weapon is found to take the round, which reads as can't tell, not as stuck
    private _dir = [];
    {
        private _turret = _x;
        { if (_dir isEqualTo [] && {_ordnance in compatibleMagazines _x}) then { _dir = _gun weaponDirection _x } } forEach (_gun weaponsTurret _turret);
    } forEach ([[-1]] + allTurrets [_gun, false]);
    _dir
};
// Whether a gun may have its rounds launched by script: standing, crewed at the gun, holding the round, the
// target on land and in its reach as the engine reckons it, and a round the engine flies as a shell or a
// submunition carrier (a script-made one keeps to the worked-out launch), not a rocket or missile.
private _fnc_canScript = {
    params ["_gun"];
    private _ammo = getText (configFile >> "CfgMagazines" >> _ordnance >> "ammo");
    alive _gun
    && {alive (gunner _gun) || {alive (effectiveCommander _gun)}}
    && {(magazinesAllTurrets _gun) findIf { (_x select 0) == _ordnance && {(_x select 2) > 0} } > -1}
    && {!surfaceIsWater _targetPos}
    && {_targetPos inRangeOfArtillery [[_gun], _ordnance]}
    && {_ammo != ""}
    && {(toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation")) in ["shotshell", "shotsubmunitions"]}
};
// [gun, rounds]; returns the rounds launched
private _fnc_scriptFire = {
    params ["_gun", "_rounds"];
    private _ammo = getText (configFile >> "CfgMagazines" >> _ordnance >> "ammo");
    private _shooter = [gunner _gun, effectiveCommander _gun] select (!alive (gunner _gun));
    private _launched = 0;
    for "_i" from 1 to _rounds do {
        // the magazine to draw from, read each round, so a launcher holding several moves on to the next
        private _mag = (magazinesAllTurrets _gun) select { (_x select 0) == _ordnance && {(_x select 2) > 0} };
        if (!alive _gun || {_mag isEqualTo []}) exitWith {};
        (_mag select 0) params ["", "_path", "_count"];
        // the engine adds its own spread to an aimed round; a launched one gets the same, at least 50 m
        private _at = _targetPos getPos [random (_dispersion max 50), random 360];
        private _from = (getPosASL _gun) vectorAdd [0, 0, 4];
        private _d = _from distance2D _at;
        private _dh = (getTerrainHeightASL _at) - (_from select 2);
        // the lower of 45 and 60 degrees that clears the climb to the target
        private _sol = [];
        { private _den = 2 * ((cos _x) ^ 2) * (_d * (tan _x) - _dh); if (_den > 0 && {_sol isEqualTo []}) then { _sol = [_x, sqrt (9.80665 * _d * _d / _den)] } } forEach [45, 60];
        if (_sol isEqualTo []) exitWith {};
        _sol params ["_a", "_v"];
        private _bearing = _from getDir _at;
        private _dir = [(sin _bearing) * (cos _a), (cos _bearing) * (cos _a), sin _a];
        private _round = createVehicle [_ammo, ASLToAGL _from, [], 0, "CAN_COLLIDE"];
        _round setPosASL _from;
        _round setVectorDirAndUp [_dir, [0, 0, 1]];
        _round setVelocity (_dir vectorMultiply _v);
        // the gun and its gunner fired it, for kills, friendly fire and anything that asks who shot
        _round setShotParents [_gun, _shooter];
        _gun setMagazineTurretAmmo [_ordnance, _count - 1, _path];
        _launched = _launched + 1;
        _battery setVariable ["ALiVE_CS_scriptETA", round (_d / (_v * (cos _a)))];
        _battery setVariable ["ALiVE_CS_shotsFired", (_battery getVariable ["ALiVE_CS_shotsFired", 0]) + 1];
        sleep 1.5;
    };
    _launched
};
// the mission's rounds shared out over the guns that may launch by script; returns [rounds launched, guns used]
private _fnc_scriptMission = {
    params [["_only", objNull]];
    private _holders = (if (_only isEqualType objNull) then { _guns } else { _only }) select { [_x] call _fnc_canScript };
    if (_holders isEqualTo []) exitWith { [0, 0] };
    private _each = ceil (_missionRoundCount / count _holders);
    private _left = _missionRoundCount;
    private _total = 0;
    {
        if (_left <= 0) exitWith {};
        private _n = [_x, _each min _left] call _fnc_scriptFire;
        _left = _left - _n;
        _total = _total + _n;
    } forEach _holders;
    [_total, count _holders]
};
// A missile launcher (the MK41 VLS, The Horny Latino on Discord, 23 Oct): the engine won't aim it at a map position,
// so each round is one guided missile fired at a laser target put on the grid, as its crew would at a lased target.
// The laser sits on a hidden helper so close air support and the laze task take it for a script's, and the side
// knows of it only while the missile flies. Run where the crew is: a gun taken over or moved elsewhere fires nothing.
private _missile = _guns call NEO_fnc_artyIsMissileLauncher;
private _fnc_missileMission = {
    private _holds = { params ["_g"]; alive _g && {alive gunner _g} && {local _g} && {!isUAVConnected _g}
        && {(magazinesAllTurrets _g) findIf { (_x select 0) == _ordnance && {(_x select 2) > 0} } > -1} };
    private _launchers = _guns select { [_x] call _holds };
    if (_launchers isEqualTo []) exitWith { ["ALiVE Combat Support: missile battery %1 has no launcher able to fire %2", typeOf vehicle _battery, _ordnance] call ALiVE_fnc_dump };
    private _side = side group gunner (_launchers select 0);
    private _ltClass = if (_side getFriend WEST > 0.6) then { "LaserTargetW" } else { "LaserTargetE" };
    private _ammo = getText (configFile >> "CfgMagazines" >> _ordnance >> "ammo");
    private _speed = (getNumber (configFile >> "CfgAmmo" >> _ammo >> "maxSpeed")) max 100;
    private _life = ((getNumber (configFile >> "CfgAmmo" >> _ammo >> "timeToLive")) max 60) + 10;
    // each missile as it leaves, so its laser stays only as long as it flies
    private _projEHs = _launchers apply { [_x, _x addEventHandler ["Fired", { (_this select 0) setVariable ["ALiVE_CS_lastMissile", _this select 6] }]] };
    private _next = 0;
    for "_i" from 1 to _missionRoundCount do {
        // the next launcher still able to fire, in turn
        private _gun = objNull;
        for "_k" from 0 to (count _launchers - 1) do {
            private _g = _launchers select ((_next + _k) mod (count _launchers));
            if (isNull _gun && {[_g] call _holds}) then { _gun = _g; _next = _next + _k + 1 };
        };
        if (isNull _gun) exitWith {};
        // the weapon and turret holding the round, with the round loaded
        private _wt = [];
        { private _t = _x; { if (_wt isEqualTo [] && {_ordnance in compatibleMagazines _x}) then { _wt = [_x, _t] } } forEach (_gun weaponsTurret _t) } forEach ([[-1]] + allTurrets [_gun, false]);
        if (_wt isEqualTo []) exitWith {};
        _wt params ["_weapon", "_path"];
        if ((_gun currentMagazineTurret _path) != _ordnance) then { _gun loadMagazine [_path, _weapon, _ordnance]; sleep 1 };
        if ((_gun currentMagazineTurret _path) != _ordnance) exitWith {
            ["ALiVE Combat Support: missile battery %1 couldn't load %2", typeOf _gun, _ordnance] call ALiVE_fnc_dump;
        };
        private _at = if (_dispersion > 50) then { _targetPos getPos [(_dispersion - 50), random 360] } else { +_targetPos };
        _at set [2, 0];
        private _helper = createVehicle ["Land_HelipadEmpty_F", _at, [], 0, "CAN_COLLIDE"];
        private _lt = createVehicle [_ltClass, _at, [], 0, "CAN_COLLIDE"];
        _lt attachTo [_helper, [0, 0, 1]];
        // the flight, for the splash call: straight out at the missile's speed, and a little for the climb and dive
        private _eta = round ((_gun distance2D _at) / _speed + 15);
        _side reportRemoteTarget [_lt, 320];
        _lt confirmSensorTarget [_side, true];
        (gunner _gun) reveal [_lt, 4];
        (gunner _gun) doTarget _lt;
        sleep 1;
        _battery setVariable ["ALiVE_CS_scriptETA", _eta];
        _gun setVariable ["ALiVE_CS_lastMissile", objNull];
        private _before = _battery getVariable ["ALiVE_CS_shotsFired", 0];
        // asked again every 2 s until it fires, for up to 5 minutes: a launcher that has just fired, or changed missile
        // type, is still reloading (the MK41 takes about 3 minutes to change between its HE and cluster missiles, and
        // nothing it reports says when it's ready, so it's simply asked until it fires)
        private _t = time;
        private _asked = -1;
        waitUntil {
            if (time - _asked >= 2) then { _asked = time; _gun fireAtTarget [_lt, _weapon] };
            sleep 0.5;
            (_battery getVariable ["ALiVE_CS_shotsFired", 0]) > _before || {time - _t > 300} || {isNull _battery} || {!([_gun] call _holds)}
        };
        if (time - _t > 10) then { ["ALiVE Combat Support: missile battery %1 fired %2 after %3 s", typeOf _gun, _ordnance, round (time - _t)] call ALiVE_fnc_dump };
        // a missile that doesn't leave ends the mission, so the radio says it couldn't fire rather than waiting on
        // every round in turn
        if ((_battery getVariable ["ALiVE_CS_shotsFired", 0]) == _before) exitWith {
            ["ALiVE Combat Support: missile battery %1 didn't fire at %2", typeOf _gun, mapGridPosition _at] call ALiVE_fnc_dump;
            _side reportRemoteTarget [_lt, 0];
            deleteVehicle _lt; deleteVehicle _helper;
        };
        // away: the missile steers by the side's report of the laser all the way in (withdrawn at launch, it landed
        // 131 m off instead of 2 to 4 m), so the report and the laser are kept until the missile is gone, then dropped
        _side reportRemoteTarget [_lt, _life];
        [_helper, _lt, _gun getVariable ["ALiVE_CS_lastMissile", objNull], _life, _side] spawn {
            params ["_h", "_l", "_p", "_life", "_s"];
            private _t = time;
            waitUntil { sleep 1; isNull _p || {time - _t > _life} };
            sleep 5;
            _s reportRemoteTarget [_l, 0];
            deleteVehicle _l; deleteVehicle _h;
        };
        sleep (_rateOfFire max 2);
    };
    { _x params ["_g", "_eh"]; if (!isNull _g) then { _g removeEventHandler ["Fired", _eh] } } forEach _projEHs;
};
ALiVE_CS_scriptFireClasses = missionNamespace getVariable ["ALiVE_CS_scriptFireClasses", []];
private _scriptFirst = (typeOf vehicle _battery) in ALiVE_CS_scriptFireClasses;
_battery setVariable ["ALiVE_CS_shotsFired", 0];
_battery setVariable ["ALiVE_CS_shotMagazine", _ordnance];
private _firedEHs = _guns apply {
    _x setVariable ["ALiVE_CS_firingFor", _battery];
    [_x, _x addEventHandler ["Fired", {
        params ["_gun", "", "", "", "", "_magazine"];
        private _b = _gun getVariable ["ALiVE_CS_firingFor", objNull];
        if (!isNull _b && {_magazine == (_b getVariable ["ALiVE_CS_shotMagazine", ""])}) then {
            _b setVariable ["ALiVE_CS_shotsFired", (_b getVariable ["ALiVE_CS_shotsFired", 0]) + 1];
        };
    }]]
};

if (_missile) then {
    call _fnc_missileMission;
} else {
if (_scriptFirst) then {
    [] call _fnc_scriptMission;
} else {
if(_missionRoundCount == 1) then {
    _battery DOArtilleryFire [_targetPos, _ordnance, _missionRoundCount];

} else {
    private _roundsOut = _missionRoundCount;
    private _numUnits = (group _battery) getVariable ["supportWeaponCount",3];
    private _roundsOutEach = [];
    _roundsOutEach resize [_numUnits,0];
    private _i = 0;
    while {_roundsOut > 0} do {
        _roundsOutEach set [_i,(_roundsOutEach select _i) + 1];
        _roundsOut = _roundsOut - 1;
        _i = _i + 1;
        if (_i == _numUnits) then {_i = 0;};
    };

    for "_u" from 0 to (_numUnits -1) do { 
        private "_pos";
        if (_dispersion > 50) then {
            _pos = (_targetPos getPos [(_dispersion - 50), (round (random 360))]);
        } else {
            _pos = _targetPos;
        };
        if (_roundsOutEach select _u > 0) then {
            (_units select _u) DOArtilleryFire [_pos, _ordnance, _roundsOutEach select _u];
            sleep _rateOfFire;
        };
    };
};
};
};

private _aimAtOrder = _guns apply { [_x] call _fnc_aim };

// The firing is over once every round asked for has left, nothing has left for 30 s since the last shot,
// nothing has left at all after 90 s (the guns can't reach, or won't aim there), or the mission runs too long.
private _t0 = time;
private _lastShot = time;
private _seen = 0;
waitUntil {
    sleep 1;
    private _n = _battery getVariable ["ALiVE_CS_shotsFired", 0];
    if (_n > _seen) then { _seen = _n; _lastShot = time };
    _n >= _missionRoundCount
    || {_seen == 0 && {time - _t0 > 90}}
    || {_seen > 0 && {time - _lastShot > 30}}
    || {time - _t0 > 120 + 20 * _missionRoundCount}
};
// Nothing left the guns on the AI's orders: launched by script, if the guns stand, are crewed and hold the
// round, and the gun is remembered so its next mission doesn't wait. Only if that launches nothing either does
// the radio say it couldn't fire.
// Only guns whose weapon never moved: a gun that is turning is slow, not stuck, and would fire twice.
if (_seen == 0 && {!_scriptFirst} && {!_missile}) then {
    // counted before the launch, which can empty a gun
    private _eligible = _guns select { [_x] call _fnc_canScript };
    private _stuck = _eligible select {
        private _now = [_x] call _fnc_aim;
        private _then = _aimAtOrder select (_guns find _x);
        _now isNotEqualTo [] && {_then isNotEqualTo []} && {(_now vectorDistance _then) < 0.01}
    };
    (([_stuck] call _fnc_scriptMission)) params ["_launched", "_used"];
    // remembered only when every gun that could have fired was stuck
    if (_launched > 0 && {count _stuck == count _eligible}) then {
        ALiVE_CS_scriptFireClasses pushBackUnique (typeOf vehicle _battery);
        ["ALiVE Combat Support: %1 ignored the artillery order, so its rounds were launched by script, and will be from now on", typeOf vehicle _battery] call ALiVE_fnc_dump;
    };
    _seen = _battery getVariable ["ALiVE_CS_shotsFired", 0];
};
// nothing left at all: the radio says it couldn't fire, not that the rounds landed
if (_seen == 0) then { _battery setVariable ["ARTY_NOSHOTS", true, true] };
{
    _x params ["_gun", "_eh"];
    if (!isNull _gun) then {
        _gun removeEventHandler ["Fired", _eh];
        _gun setVariable ["ALiVE_CS_firingFor", nil];
    };
} forEach _firedEHs;
private _fired = (_battery getVariable ["ALiVE_CS_shotsFired", 0]) min _missionRoundCount;
if (_fired > 0) then {
    private _rounds = +(_battery getVariable ["NEO_radioArtyBatteryRounds", []]);
    {
        _x params ["_round", "_count"];
        if (_round == _ordnanceType) exitWith {
            if (_count - _fired > 0) then { _rounds set [_forEachIndex, [_round, _count - _fired]] } else { _rounds deleteAt _forEachIndex };
        };
    } forEach _rounds;
    _battery setVariable ["NEO_radioArtyBatteryRounds", _rounds, true];
};
if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then {
    ["MISSION: %1 of %2 rounds left the guns and came off the battery", _fired, _missionRoundCount] call ALiVE_fnc_dump;
};

// a missile mission's flight time isn't left for the next battery mission to read
_battery setVariable ["ALiVE_CS_scriptETA", nil];
_battery setVariable ["ARTY_COMPLETE", true, true];

sleep 20;

_battery setVariable ["ARTY_ONMISSION", false, true];
