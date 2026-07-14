// NEO_fnc_casScriptedAttack
// ------------------------------------------------------------------
// Scripted Close Air Support delivery. Extracted from cas.fsm state __9
// (the old embedded-string spawn body). A fixed-wing gun run can't slew its
// airframe-axis gun onto the point (lockCameraTo won't move a fixed forward
// gun), so instead of puppet-flying the aircraft (which fought the flight
// model - froze the plane, dropped gear, missed) the plane gun case now flies
// a NORMAL AI pass (flyInHeight + doMove, no velocity/orientation writes),
// still fires the real gun for tracers/audio, and delivers guaranteed damage
// by simulating the weapon's own ordnance detonating on the aim point once
// per inbound pass. Guided (laser/IR) and heli-gun deliveries are unchanged.
//
// Spawned by the FSM:
//   _attackRunHandle = [...] spawn NEO_fnc_casScriptedAttack;
// so the FSM completion contract `scriptDone _attackRunHandle` still holds.
//
// Params: [_veh,_callsign,_ammoCount,_grp,_ROE,_oldPos,_restoreAmmo,_weapon,_posCas,_radiusCas,_task]
// Returns: nothing
//
// Author: Neo, Tupolov, Jman
// ------------------------------------------------------------------

private ["_veh","_callsign","_ammoCount","_grp","_ROE","_oldPos","_restoreAmmo","_weapon","_posCas","_radiusCas","_task","_groundAttack","_dummy","_laze","_lazeGrp","_lasedObj","_playerLaze","_casGuideEH","_guideMethod","_aceLaserUuid","_parents","_isBomb","_canLock","_guided","_bareGroundGun","_sleep","_turret","_unit","_muzzle","_firemode","_target","_isPlane","_casStart","_nextMove","_aimPos","_aimASL","_movePos","_dir","_toTgt","_noseOn","_ammoClass","_struckThisLeg","_runBearing","_legToFar","_legStart","_sideCas","_sideTxt","_enemySides","_friendlySides","_enemiesNear","_rtbNeeded","_rtbReason","_passCount","_killableNear"];

_veh         = _this select 0;
_callsign    = _this select 1;
_ammoCount   = _this select 2;
_grp         = _this select 3;
_ROE         = _this select 4;
_oldPos      = _this select 5;
_restoreAmmo = _this select 6;
_weapon      = _this select 7;
_posCas      = _this select 8;
_radiusCas   = _this select 9;
_task        = _this select 10;

// nothing to fly if the asset is already gone - still lets scriptDone fire cleanly
if (isNull _veh) exitWith {};

_groundAttack = _task == "ATTACK GROUND";
_dummy   = objNull;
_laze    = objNull;
_lazeGrp = grpNull;
_casGuideEH = -1;   // Fired EH id for scripted projectile guidance; the guided setup overwrites it, gun path keeps -1
_guideMethod  = "VANILLA";   // tiered guided delivery: ACE | VANILLA (real laser) -> scripted watchdog fallback
_aceLaserUuid = "";          // handle from ace_laser_fnc_laserOn, for laserOff in cleanup ("" = none)

// weapon classification - guided munitions need a laser/IR designation,
// guns & unguided fire scripted down the run
_parents = [ (configFile >> "CfgWeapons" >> _weapon),true] call BIS_fnc_returnParents;
_isBomb  = getText (configFile >> "CfgWeapons" >> _weapon >> "cursorAim") == "bomb";
_canLock = getNumber (configFile >> "CfgWeapons" >> _weapon >> "canLock");
// Guided = launches lockable/steered ordnance that wants a laser/IR designation, so it takes the
// lase-and-fire path instead of the scripted gun run. Detection is by launcher-base NAME because mods
// don't share a clean class tree: RHS's rhs_weap_gbu12 has NO MissileLauncher/BombLauncher parent,
// isBomb=false and canLock=0 - its real base is "weapon_LGBLauncherBase" (+ a "Bomb_04..." parent). So
// we match the BOMB / LGB / MISSILE token anywhere in the (upper-cased) parent chain. Guns and genuinely
// unguided rocket pods carry none of those tokens, so they still gun-run.
private _pu = _parents apply { toUpper _x };
_guided = (_pu findIf { ((_x find "MISSILE") >= 0) || {(_x find "BOMB") >= 0} || {(_x find "LGB") >= 0} } > -1)
          || {_isBomb} || {_canLock > 1};
_bareGroundGun = _groundAttack && !_guided;

// fire cadence per weapon family (governs the guided + heli branches;
// the plane gun puppet uses its own small frame step)
if ("RocketPods" in _parents) then {
    _sleep = 3;
} else {
    if ("MissileLauncher" in _parents) then {
        _sleep = 12;
    } else {
        if ("MGunCore" in _parents) then {
            _sleep = 0.3;
        } else {
            _sleep = 0.5;
        };
    };
};

// resolve the turret holding the chosen weapon and the unit that pulls its
// trigger (single-seat CAS plane: the pilot/driver)
_turret = [];
{
    if (_weapon in (_veh weaponsTurret _x)) exitWith { _turret = _x; };
} forEach ([[]] + allTurrets [_veh, true]);
_unit = _veh turretUnit _turret;
if (isNull _unit) then { _unit = driver _veh; };
(weaponState [_veh, _turret, _weapon]) params ["", ["_muzzle", ""], ["_firemode", ""]];
if (_muzzle isEqualTo "") then { _muzzle = _weapon; };
if (_firemode isEqualTo "") then {
    private _modes = getArray (configFile >> "CfgWeapons" >> _weapon >> _muzzle >> "modes");
    if (_modes isEqualTo []) then { _modes = getArray (configFile >> "CfgWeapons" >> _weapon >> "modes"); };
    _firemode = _modes param [0, "this"];
    if (_firemode isEqualTo "this") then { _firemode = _muzzle; };
};

// target setup
if (_groundAttack) then {
    if (_guided) then {
        // ATTACK GROUND (guided) - create the laser designation; the loop re-attaches it directly onto the
        // nearest enemy vehicle each pass (see the guided branch). _dummy is only the marker-centre fallback
        // holder for when no vehicle is present. NOTE: the old code attached the laser with a random +/-15m
        // offset (a hangover from designating a whole AREA) - that threw the bomb ~15m off ("landed long"),
        // so it's [0,0,1] with no jitter now.
        _lazeGrp = createGroup SideLogic;
        _dummy = _lazeGrp createUnit ["Logic", _posCas, [], 0, "NONE"];

        private _lazor = "LaserTargetE";
        if (side _grp getFriend WEST > 0.6) then {_lazor = "LaserTargetW"};

        _laze = _lazor createVehicle _posCas;
        _laze attachTo [_dummy,[0, 0, 1]];
        _dummy setPos _posCas;

        _grp reveal _laze;
        _target = _laze;
        _lasedObj = objNull;

        // Scripted projectile guidance. ACE replaces vanilla laser tracking (its designations need an owner +
        // code via ace_laser_fnc_laserOn), so our scripted LaserTarget is ignored and a real LGB just drops
        // ballistic and lands long (the observed ~10m-long misses). Instead, catch the RELEASED bomb/missile
        // and steer it onto the lased vehicle ourselves - reliable regardless of ACE / mod / release geometry.
        // The round is a real armed projectile so it detonates on contact. EH is removed in cleanup.
        _veh setVariable ["NEO_casGuideTgt", objNull];
        _veh setVariable ["NEO_casLastFired", objNull];
        _casGuideEH = _veh addEventHandler ["Fired", {
            params ["_shooter", "", "", "", "", "", "_proj"];
            private _t = _shooter getVariable ["NEO_casGuideTgt", objNull];
            // Catch the released round by ORDNANCE TYPE (the Fired EH reports a pylon/muzzle weapon name for
            // aircraft bombs, so a name match was unreliable). SubmunitionBase covers cluster/DAGR-style rounds.
            private _isOrd = !isNull _proj && {(_proj isKindOf "BombCore") || {_proj isKindOf "MissileBase"} || {_proj isKindOf "RocketBase"} || {_proj isKindOf "SubmunitionBase"}};
            if (!_isOrd || {isNull _t}) exitWith {};
            // STEER the REAL round onto the target: it visibly flies from the jet, decelerating on final
            // approach so it converges in ~2s (not a spiral) and ORIENTED along its flight path so it does NOT
            // tumble. The velocity override stops it self-detonating, so on arrival (<12m) bin it + set off a
            // real bomb ON the target + a sure kill. Real self-guidance (IR Maverick) and laser both proved
            // unreliable in testing, so steering is the universal delivery; the loop watchdog is the backstop.
            [_proj, _t] spawn {
                params ["_p", "_t"];
                while { !isNull _p && {alive _p} && {!isNull _t} && {alive _t} } do {
                    private _to = ((getPosASL _t) vectorAdd [0, 0, 0.5]) vectorDiff (getPosASL _p);
                    private _dist = vectorMagnitude _to;
                    if (_dist < 12) exitWith {
                        deleteVehicle _p;
                        "Bomb_04_F" createVehicle (getPosATL _t);
                        _t setDamage 1;
                        if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-GUIDE: STEER hit on %1", _t] call ALiVE_fnc_dump; };
                    };
                    private _dir = vectorNormalized _to;
                    private _spd = ((_dist * 1.5) min 180) max 45;
                    _p setVelocity (_dir vectorMultiply _spd);
                    _p setVectorDirAndUp [_dir, [0, 0, 1]];
                    sleep 0.02;
                };
            };
        }];

        ["Telling %1 (%2) to designate and strike area at %3 (radius %4) with %5",_veh,_callsign,_posCas,_radiusCas,_weapon] call ALiVE_fnc_dump;
    } else {
        // ATTACK GROUND (gun/unguided) - no laser, scripted fire is aimed at the bare ground point
        _target = objNull;

        ["Telling %1 (%2) to saturate area at %3 (radius %4) with %5 (scripted gun run)",_veh,_callsign,_posCas,_radiusCas,_weapon] call ALiVE_fnc_dump;
    };
} else {
    _target = [_veh, _posCas, _radiusCas,_weapon] call NEO_fnc_pickCasTarget;

    ["Telling %1 to target %2 (%3 %4)",_veh,_target, _posCas,_radiusCas] call ALiVE_fnc_dump;
};

_isPlane  = _veh isKindOf "Plane";
_casStart = time;
_nextMove = 0;

// resolve the chosen weapon's own shell/rocket ammo for the simulated on-target
// ordnance (plane gun pass, Path B). Guns often declare magazines per-muzzle, so
// fall back to the muzzle when the weapon root has none. A kinetic-only shell
// (indirectHit 0) is swapped for a known HE cannon shell so the simulated impact
// always craters + area-damages the target regardless of the real round's ballistics.
_ammoClass = "";
private _cvMags = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines");
if (_cvMags isEqualTo []) then { _cvMags = getArray (configFile >> "CfgWeapons" >> _weapon >> _muzzle >> "magazines"); };
_ammoClass = getText (configFile >> "CfgMagazines" >> (_cvMags param [0, ""]) >> "ammo");
if (_ammoClass isEqualTo "" || {getNumber (configFile >> "CfgAmmo" >> _ammoClass >> "indirectHit") <= 0}) then {
    _ammoClass = "G_20mm_HE";
};

// ---- Tiered guided delivery (option B) - pick the best REAL delivery the munition + environment support:
//   ACE     = ACE loaded AND the munition has an ACE SALH seeker -> ace_laser designation, real bomb guides.
//   STEER   = ACE loaded BUT no ACE seeker -> NEITHER laser works (proven: no ACE seeker to home, AND ACE
//             intercepts the vanilla LaserTarget - "doesn't have owner"), so self-steer the REAL bomb onto
//             the target for a connected visual + guaranteed kill. This is the RHS GBU + ACE case.
//   VANILLA = ACE not loaded -> engine LaserTarget, real bomb guides itself.
// A scripted Bomb_04_F on target is the ultimate watchdog if a real-laser bomb (ACE/VANILLA) still misses. ----
if (_guided) then {
    if (_canLock > 0) then {
        // lockable missile (IR/radar, e.g. AGM-65 Maverick) - it locks the vehicle and guides ITSELF. No
        // laser, no steering: steering fought its own seeker and detonated a bomb warhead, which read as a
        // scripted hit. Just fire at the vehicle and let the real missile fly; watchdog covers a miss.
        _guideMethod = "SELF";
    } else {
        // laser bomb (canLock 0, e.g. GBU) - needs a designation: ACE laser if it has an ACE SALH seeker;
        // else self-steer (ACE loaded, no seeker - ACE leaves it to vanilla but AI can't acquire canLock 0);
        // else the vanilla engine LaserTarget (no ACE).
        private _aceLoaded = isClass (configFile >> "CfgPatches" >> "ace_laser");
        private _aceSeeker = "SALH" in (getArray (configFile >> "CfgAmmo" >> _ammoClass >> "ace_missileguidance" >> "seekerTypes"));
        _guideMethod = "VANILLA";
        if (_aceLoaded) then { _guideMethod = if (_aceSeeker) then {"ACE"} else {"STEER"}; };
    };
    _veh setVariable ["NEO_casGuideMethod", _guideMethod];
    if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-GUIDE: weapon=%1 ammo=%2 canLock=%3 method=%4", _weapon, _ammoClass, _canLock, _guideMethod] call ALiVE_fnc_dump; };
};
_struckThisLeg = false;   // guaranteed strike fires once per inbound racetrack leg; re-armed on each leg flip
_runBearing    = -1;      // fixed attack axis (compass bearing plane->target), set on the first plane pass
_legToFar      = true;    // which racetrack end the jet is currently running toward
_legStart      = -1;      // time the current leg began; drives the per-leg flip timeout (set on first plane pass)

// ---- persist-until-clear + RTB state (seeded before the loop; the per-pass scan updates it) ----
_sideCas    = side _grp;                                   // CAS side (the laser pick already reads side _grp)
_sideTxt    = [_sideCas] call ALiVE_fnc_sideToSideText;    // "WEST"/"EAST"/"GUER" for getNearProfiles
_enemySides = ["EAST","WEST","GUER"] - [_sideTxt];
// friendly MILITARY sides for the empty-vehicle allegiance test. CIVILIAN is deliberately never in this
// set, so an enemy-used empty CIVILIAN-faction vehicle sitting in the marked area still counts as a target.
_friendlySides = [WEST,EAST,RESISTANCE] select { _x == _sideCas || {(_sideCas getFriend _x) >= 0.6} };
_enemiesNear = 1;
_killableNear = 1;   // real (killable) objects only - drives loop completion; profiles are advisory       // seed > 0 so the first pass always runs; the scan then reflects the true count
_playerLaze  = objNull;   // a player's own manual laser designation in the area - takes priority when present
_rtbNeeded   = false;
_rtbReason   = "";
_passCount   = 0;

// Keep attack-running the marked area while LIVE enemies remain within 150m (crewed units/vehicles,
// virtualised enemy profiles, and empty hostile/civilian vehicles), breaking off to RTB on low fuel,
// damage, or winchester. Hard time + pass backstops guarantee the loop can never run away.
while {
    (_veh ammo _weapon) > 0
    && !(_veh getVariable ["NEO_radioCasUnitBreakOff", false])
    && (if (_groundAttack) then {_killableNear > 0 || {!isNull _playerLaze}} else {alive _target})
    && !_rtbNeeded
    && _passCount < 1000
    && (time - _casStart) < 300
} do {
    _passCount = _passCount + 1;

    // ---- per-pass enemy scan (once per pass): crewed enemies + virtualised enemy profiles +
    //      empty hostile vehicles within 150m of the marker. Drives persist-until-clear + strike aim. ----
    private _nearUnits = _posCas nearEntities [["Man","Car","Tank"], 150];
    private _crewedEnemies = _nearUnits select { alive _x && {side _x != _sideCas} && {side _x != civilian} && {_x != _veh} };

    private _enemyProfiles = [_posCas, 150, [_enemySides, "entity"], true] call ALIVE_fnc_getNearProfiles;
    _enemyProfiles = _enemyProfiles select {
        ((_x select 2 select 3) != "CIV") && {(_x select 2 select 3) != "CIVILIAN"}
    };

    // empty vehicles: with no crew their `side` reads CIVILIAN, so resolve allegiance from the config
    // faction. Include unless it resolves to a FRIENDLY military side - friendly empties are spared, while
    // hostile-military AND enemy-used civilian empties both count (CIVILIAN is never a friendly-military side).
    private _emptyVeh = (_posCas nearEntities [["Car","Tank"], 150]) select {
        (crew _x isEqualTo []) && {alive _x} && {damage _x < 1} && {_x != _veh} &&
        {!(((faction _x) call ALiVE_fnc_factionSide) in _friendlySides)}
    };

    // player manual designation: a friendly laser in the area (not our own) beats auto-detection - the
    // player lases to choose the target, stops lasing to hand control back to the automatic scan.
    // nearestObjects (not nearEntities) so laser-target objects are found reliably; accept allied sides
    // (e.g. an independent JTAC lasing for a BLUFOR jet).
    _playerLaze = objNull;
    // a manual lase is an explicit order - honour it well beyond the marker circle (the slider radius can
    // be as tight as 250m and the player's target may sit outside it), capped so a stray laser across the
    // map can't hijack the engagement
    private _laseR = (_radiusCas * 1.5) max 1500;
    private _pRaw = nearestObjects [_posCas, ["LaserTargetBase"], _laseR];
    // match friendly lasers by CLASS convention (LaserTargetW = west-friendly, LaserTargetE = east), the
    // same rule the codebase uses when CREATING them - `side` on a laser object is unreliable (a WEST
    // player's LaserTargetW reports side EAST, which is what blinded the earlier side-based filter)
    private _ownLaserClass = if (_sideCas getFriend WEST > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
    private _pLazes = _pRaw select {
        _x != _laze && {_x isKindOf _ownLaserClass}
    };
    // second route: ask each friendly player directly what they are lasing (engine laserTarget command) -
    // robust when the laser object's side reads oddly or the object hunt misses it
    if (_pLazes isEqualTo []) then {
        {
            private _lt = laserTarget _x;
            if (!isNull _lt && {_lt distance2D _posCas <= _laseR} && {!(_lt isEqualTo _laze)}) exitWith { _pLazes = [_lt]; };
        } forEach (allPlayers select { (side _x) == _sideCas || {(_sideCas getFriend (side _x)) >= 0.6} });
    };
    if !(_pLazes isEqualTo []) then { _playerLaze = _pLazes select 0; };

    private _enemyList = _crewedEnemies + _emptyVeh;
    _enemiesNear  = (count _crewedEnemies) + (count _enemyProfiles) + (count _emptyVeh);
    _killableNear = (count _crewedEnemies) + (count _emptyVeh);   // spawned objects the sim strike can actually kill

    // ---- RTB-on-low-resources: flag it here; the while gate (!_rtbNeeded) then breaks the loop cleanly
    //      so cleanup / loiter hand-off / completion contract below still run. ammo==0 exits via its gate. ----
    if (!_rtbNeeded && {(fuel _veh) < 0.2 || {(damage _veh) > 0.5}}) then {
        if ((fuel _veh) < 0.2) then { _rtbReason = "FUEL"; } else { _rtbReason = "DAMAGE"; };
        _rtbNeeded = true;
    };

    if (_guided) then {
        // GUIDED - aim onto the NEAREST live enemy VEHICLE each pass. HOW depends on the seeker:
        //   - lockable missiles (canLock>0, e.g. the IR AGM-65 Maverick) are fired at the VEHICLE itself so
        //     the missile's own seeker locks it directly;
        //   - laser bombs (canLock==0, e.g. GBU-12) can't be locked, so they're fired at a LASER attached to
        //     the vehicle at [0,0,4] (no jitter - the old +/-15m offset is what made the bomb land long).
        // This mirrors fn_pickCasTarget's split (the proven ATTACK RUN path). The laser rides the vehicle
        // either way, so a laser-guided missile also has a valid designation. Re-targets as vehicles die.
        if (_groundAttack) then {
            // the player's own laser designation beats the automatic nearest-vehicle pick: the released
            // round is steered onto the LASER (the player's chosen point) for as long as they hold the lase
            private _laseTargets = if (!isNull _playerLaze) then { [_playerLaze] } else {
                private _lt = _enemyList select { _x isKindOf "Car" || {_x isKindOf "Tank"} };
                if (_lt isEqualTo []) then { _lt = _enemyList; };
                _lt
            };
            if !(_laseTargets isEqualTo []) then {
                private _byDist = _laseTargets apply { [_x distance2D _posCas, _x] };
                _byDist sort true;
                private _pick = (_byDist select 0) select 1;
                if (_pick != _lasedObj) then {
                    if (!isNull _laze) then { _laze attachTo [_pick, [0, 0, 4]]; };
                    // ACE tier: (re)emit an ACE laser designation on the new target with the aircraft's laser
                    // code so an ACE SALH seeker homes on it. laserOff the previous designation first.
                    if (_guideMethod == "ACE") then {
                        if (_aceLaserUuid != "") then { [_aceLaserUuid] call ace_laser_fnc_laserOff; };
                        private _code = if (!isNil "ace_laser_fnc_getLaserCode") then { _veh call ace_laser_fnc_getLaserCode } else { 1111 };
                        _aceLaserUuid = [_pick, _veh, [[0, 0, 2], ""], 1550, _code, 1] call ace_laser_fnc_laserOn;
                    };
                    _target = if (_canLock > 0) then { _pick } else { _laze };
                    _lasedObj = _pick;
                    _veh setVariable ["NEO_casGuideTgt", _pick];   // watchdog / (any) guidance target
                };
            };
        };

        // Run in over the lased target at bombing altitude before releasing. A loitering / banking jet
        // force-fired via fireAtTarget drops the bomb ballistic and it lands long (the observed ~10m-long
        // misses - four GBUs all long as a group = no guidance, poor release, not a laser-position error).
        // Commanding a straight run PAST the target (a point 2.5km beyond it, re-aimed each cadence) makes
        // the jet overfly with its nose tracking the target, so the LGB releases with a valid solution and
        // guides onto the laser; recomputing the bearing each pass racetracks it back over for the next bomb.
        // ATTACK GROUND only - ATTACK RUN keeps the FSM's own approach.
        if (_groundAttack && {!isNull _lasedObj} && {alive _lasedObj} && {time > _nextMove}) then {
            private _brg = _veh getDir _lasedObj;
            _veh flyInHeight 300;
            _veh doMove (_lasedObj getPos [2500, _brg]);
            _nextMove = time + 6;
        };

        _veh doWatch _target;
        _veh doTarget _target;
        // fire ONCE per vehicle for ATTACK GROUND - the scripted detonation (Fired EH) kills it within ~2s,
        // before the next pass, so the loop drops it from the scan and moves to the next target instead of
        // dumping the whole rack at one vehicle. ATTACK RUN fires each pass (its target is a fresh live pick).
        if (alive _target) then {
            if (_groundAttack) then {
                if (!isNull _lasedObj && {_lasedObj != (_veh getVariable ["NEO_casLastFired", objNull])}) then {
                    _veh fireAtTarget [_target, _weapon];
                    _veh setVariable ["NEO_casLastFired", _lasedObj];
                    // Per-shot watchdog: if this vehicle is still alive after the round's flight time, the shot
                    // missed (or the round wasn't caught). First miss -> RE-ARM the once-per-vehicle throttle so
                    // the aircraft comes around and ATTACKS AGAIN (it used to circle forever, never re-firing).
                    // Second miss -> guaranteed scripted kill so the engagement always completes.
                    [_lasedObj, _veh] spawn {
                        params ["_t", "_veh"];
                        private _end = time + 16;
                        waitUntil { sleep 0.5; isNull _t || {!alive _t} || {time > _end} };
                        if (isNull _t || {!alive _t}) exitWith {};
                        private _tries = _t getVariable ["NEO_casShotsAt", 1];
                        if (_tries < 2) then {
                            _t setVariable ["NEO_casShotsAt", _tries + 1];
                            if (!isNull _veh) then { _veh setVariable ["NEO_casLastFired", objNull]; };
                            if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-GUIDE: REATTACK %1 (round missed, pass %2)", _t, _tries + 1] call ALiVE_fnc_dump; };
                        } else {
                            "Bomb_04_F" createVehicle (getPosATL _t);
                            _t setDamage 1;
                            if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-GUIDE: WATCHDOG killed %1 (2 rounds missed)", _t] call ALiVE_fnc_dump; };
                        };
                    };
                };
            } else {
                _veh fireAtTarget [_target, _weapon];
            };
        };
        if (_sleep > 0.5) then { _veh doWatch objNull; };

        sleep _sleep;
    } else {
        // GUN / UNGUIDED - resolve this pass's aim point (a player's laser overrides the random area aim)
        if (_bareGroundGun) then {
            _aimPos  = if (!isNull _playerLaze) then { getPosATL _playerLaze } else { _posCas getPos [random _radiusCas, random 360] };
            _aimASL  = AGLToASL [_aimPos select 0, _aimPos select 1, 0];
            _movePos = if (!isNull _playerLaze) then { getPosATL _playerLaze } else { _posCas };
        } else {
            _aimASL  = getPosASL _target;
            _movePos = getPosATL _target;
        };

        if (_isPlane) then {
            // ---- PLANE GUN: normal AI pass + real fire + simulated on-target ordnance (Path B) ----
            // No puppeting. The AI flies the pass itself (flyInHeight + doMove). The real gun still
            // fires (tracers/audio) on a loose nose-on gate; the guaranteed damage is delivered by
            // weapon-appropriate ordnance detonated on the aim point, once per inbound pass.

            // where the simulated ordnance lands: the commanded point for ATTACK GROUND, the live
            // enemy for ATTACK RUN. Gun walks a short line through it; rockets scatter around it.
            private _strikeCtr = _posCas;
            if (!_bareGroundGun && {!isNull _target}) then {
                _strikeCtr = getPosATL _target;
            } else {
                // bareGroundGun: a player's laser designates the strike point outright; otherwise walk the
                // GUARANTEED-DAMAGE ordnance over the NEAREST detected live enemy so kills accrue and the
                // area clears pass by pass. Fall back to the bare marker when no real object remains.
                if (!isNull _playerLaze) then {
                    _strikeCtr = getPosATL _playerLaze;
                } else {
                    if (count _enemyList > 0) then {
                        private _byDist = _enemyList apply { [_veh distance _x, _x] };
                        _byDist sort true;
                        _strikeCtr = getPosATL ((_byDist select 0) select 1);
                    };
                };
            };
            // ---- RACETRACK ATTACK RUN ----
            // A fixed-wing AI given doMove to the marker just loiters it high and tight (an orbit),
            // rarely closing on the target - so the gun barely fires. Instead drive a racetrack:
            // command a move point WELL BEYOND the strike centre along a fixed attack axis so the jet
            // commits to a straight low run-in, overflies, then flips to the reciprocal end and runs
            // back. Genuine low diving gun runs with wide turns at each end, not a high tight loiter.
            private _runDist   = 1500;   // how far past the target the run-in / run-out ends sit
            private _runHeight = 70;     // low run-in altitude (120 read as "too high" in testing)

            // fix the attack axis on the first pass (bearing plane->target at engagement start), then
            // recompute the two racetrack ends from the CURRENT strike centre each pass so a moving /
            // retargeted enemy stays on the run line without the jet weaving.
            if (_runBearing < 0) then { _runBearing = _veh getDir _strikeCtr; };
            private _pFar  = _strikeCtr getPos [_runDist, _runBearing];
            private _pNear = _strikeCtr getPos [_runDist, _runBearing + 180];

            private _slantToPoint = _veh distance2D _strikeCtr;

            // leg flip on GEOMETRY ALONE (never on whether the strike armed): commit the racetrack turn
            // when the jet reaches the commanded run-out end, or a per-leg timeout elapses. Decoupling the
            // turn from _struckThisLeg is essential - if a single inbound pass misses the 700m strike gate
            // (wide jet turn / off-axis alignment), the jet must STILL turn around and re-arm, else it
            // loiters one end forever (the exact orbit-and-stop failure this redesign exists to kill).
            // _struckThisLeg gates only the once-per-leg ordnance below, never the turn.
            private _dest = _pNear;
            if (_legToFar) then { _dest = _pFar; };

            if (_legStart < 0) then { _legStart = time; };
            if ((_veh distance2D _dest < 500) || {(time - _legStart) > 45}) then {
                _legToFar = !_legToFar;
                _struckThisLeg = false;
                _legStart = time;
                _dest = _pNear;
                if (_legToFar) then { _dest = _pFar; };
            };

            // re-issue the low run-in on a slow cadence
            if (time > _nextMove) then {
                _veh flyInHeight _runHeight;
                _veh doMove _dest;
                _nextMove = time + 4;
            };

            // real gun fire for tracers/audio. The gun is FIXED to the airframe axis (lockCameraTo can't
            // slew it) so it fires straight ahead. A fixed gun on a level pass points ABOVE a ground target
            // (depression angle), so dot>0.95 (within 18 deg) almost never triggers = no visible tracers.
            // dot>0.8 (within ~37 deg) fires the strafing burst across the run-in - tracers walk toward the
            // target instead of the earlier off-to-the-side spray at 0.3. (The sim strike below does the kill.)
            private _aimCtrASL = AGLToASL [_strikeCtr select 0, _strikeCtr select 1, 0];
            _dir    = _veh weaponDirection _weapon;
            _toTgt  = vectorNormalized (_aimCtrASL vectorDiff (getPosASL _veh));
            _noseOn = (_dir vectorDotProduct _toTgt) > 0.8;

            _veh lockCameraTo [_aimCtrASL, _turret, false];
            if (_noseOn && {(getPosASL _veh) distance _aimCtrASL < 2000}) then {
                _veh setWeaponReloadingTime [_unit, _muzzle, 0];
                _unit forceWeaponFire [_muzzle, _firemode];
            };

            // GUARANTEED DAMAGE: applied ONCE per inbound leg (each leg flies THROUGH the target, so the
            // gate below trips every run and the area clears reliably - the old proximity+closing gate
            // starved on the loiter). The KILL is deterministic: spawning the gun's own round and letting
            // it "detonate" does NOT damage anything - most ammo classes (incl. kinetic gun AP rounds like
            // PGU-14) do not explode from a bare createVehicle. ALiVE's own IED code notes only R_60mm_HE /
            // Bomb_03/04_F reliably do. So we setDamage the detected objects directly (as ALiVE's IED/CSAR
            // tasks do) and use R_60mm_HE purely for the visible impacts.
            private _simImpacts = 0;
            if (!_struckThisLeg && {_slantToPoint < 700}) then {
                // deterministic kill on the real objects near the strike centre: infantry drop to a
                // strafing pass; vehicles brew up over ~2 runs (so it reads as being worn down, not
                // instantly gibbed). Virtual profiles aren't real objects, so _enemyList (crewed + empty
                // vehicles) is the set we can actually damage - matching _killableNear that drives the loop.
                {
                    if (_x distance2D _strikeCtr < 30) then {
                        if (_x isKindOf "Man") then {
                            _x setDamage 1;
                        } else {
                            _x setDamage ((damage _x) + 0.6);
                        };
                    };
                } forEach _enemyList;

                // visible walking impacts through the strike centre along the run-in axis. R_60mm_HE is
                // confirmed (ALiVE IED in-game test) to explode on createVehicle, unlike the gun's round.
                for "_i" from 0 to 4 do {
                    private _along = ((_i - 2) * 12);
                    private _ip = _strikeCtr getPos [_along, _runBearing];
                    "R_60mm_HE" createVehicle [_ip select 0, _ip select 1, 0];
                    _simImpacts = _simImpacts + 1;
                };
                _struckThisLeg = true;
            };

            sleep _sleep;
        } else {
            // ---- HELI GUN: AI orbit-aim (unchanged) - a heli can hover/orbit-aim ----
            // re-issue the run-in on a slow cadence, gate fire on nose-on
            if (time > _nextMove) then { _veh doMove _movePos; _nextMove = time + 5; };

            _dir    = _veh weaponDirection _weapon;
            _toTgt  = vectorNormalized (_aimASL vectorDiff (getPosASL _veh));
            _noseOn = (_dir vectorDotProduct _toTgt) > 0.85;

            _veh lockCameraTo [_aimASL, _turret, false];
            if (_noseOn) then {
                _veh setWeaponReloadingTime [_unit, _muzzle, 0];
                _unit forceWeaponFire [_muzzle, _firemode];
            };


            sleep _sleep;
        };
    };

    // ATTACK RUN - if the tracked target died, pick another (widen the search once).
    // Sits outside the guided/gun branch so it applies to both delivery types.
    if (!_groundAttack && {!alive _target}) then {
        _target = [_veh, _posCas, _radiusCas,_weapon] call NEO_fnc_pickCasTarget;
        if (isNull _target) then {
            _radiusCas = 2 * _radiusCas;
            _target = [_veh, _posCas, _radiusCas,_weapon] call NEO_fnc_pickCasTarget;
        };
        if (!isNull _target) then { ["Telling %1 to target %2 (%3 %4)",_veh,_target, _posCas,_radiusCas] call ALiVE_fnc_dump; };
    };
};

// ---- cleanup (always runs on any loop exit) ----
// ATTACK GROUND laser and its dummy must never outlive this script
if (!isNull _laze)  then {deleteVehicle _laze};
if (!isNull _dummy) then {deleteVehicle _dummy};
if (!isNull _lazeGrp) then {deleteGroup _lazeGrp};
if (_casGuideEH >= 0 && {!isNull _veh}) then { _veh removeEventHandler ["Fired", _casGuideEH]; _veh setVariable ["NEO_casGuideTgt", objNull]; _veh setVariable ["NEO_casLastFired", objNull]; };
if (_aceLaserUuid != "" && {!isNil "ace_laser_fnc_laserOff"}) then { [_aceLaserUuid] call ace_laser_fnc_laserOff; };
// run-mode auto-lased bomb target (fn_pickCasTarget) is tagged - clear it too
if (!isNull _target && {_target getVariable ["NEO_radioAutoLase", false]}) then {deleteVehicle _target};

[_veh,_oldPos] call ALiVE_fnc_doMoveRemote;
// move the loiter point to here
[_grp,0] setWaypointPosition [_oldPos,0];

if (alive _veh) then {
    if (_groundAttack) then {
        if( (_veh ammo _weapon) == 0) then {
            [[_veh,format["%1 is Winchester for %2. Returning to loiter position. Out.",_callsign,[configFile >> "CfgWeapons" >> _weapon] call bis_fnc_displayName],"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
        } else {
            [[_veh, format["%1 has finished engaging the target area, will loiter until further orders. Out.",_callsign], "side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
        };
    } else {
        if( isNull _target) then {
            sleep 8;
            [[_veh,format["%1 cannot engage any targets in the AO. Out.",_callsign],"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
        } else {
            if( (_veh ammo _weapon) == 0) then {
                [[_veh,format["%1 is Winchester for %2. Returning to loiter position. Out.",_callsign,[configFile >> "CfgWeapons" >> _weapon] call bis_fnc_displayName],"side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
            } else {
                [[_veh, format["%1 has completed attack run, will loiter until further orders. Out.",_callsign], "side"],"NEO_fnc_messageBroadcast",true,false] spawn BIS_fnc_MP;
            };
        };
    };

    // restore weapons
    if(_restoreAmmo) then {
        _restoreAmmo = false;
        [_veh,_ammoCount] call NEO_fnc_reenableWeapons;
    };

    _veh doWatch objNull;
    _veh forceSpeed -1;
    _grp setCombatMode "BLUE";
    _grp setBehaviour "CARELESS";
    _grp setSpeedMode "FULL";
    _grp enableAttack false;
};


// ---- RTB hand-off (winchester / low fuel / damage): overrides the loiter hand-off above ----
// ammo==0 breaks the loop via its own gate without a reason set - attribute it here.
if ((_rtbReason isEqualTo "") && {alive _veh} && {(_veh ammo _weapon) == 0}) then { _rtbReason = "AMMO"; };
if (!(_rtbReason isEqualTo "") && {alive _veh}) then {
    // breadcrumb for the resupply watchdog (it self-scans fuel/damage/ammo each cycle and services this
    // asset once it is parked, per the queued rearm-land cycle).
    _veh setVariable ["ALIVE_resupply_needsService", true, true];

    // route the airframe home: the FSM New_Task link (attack-run state, priority over the loiter hand-off)
    // reads NEO_radioCasNewTask and flies the jet back to base to be serviced. objNull caller is safe
    // server-side (the RTB link only reads the caller for player messaging).
    private _basePos = _veh getVariable ["ALIVE_CombatSupport_Base", _oldPos];
    _veh setVariable ["NEO_radioCasNewTask", ["RTB", _basePos, 0, 0, "", "", objNull], true];

    if (!isNil "ALiVE_sup_combatsupport_debug" && {ALiVE_sup_combatsupport_debug}) then { ["CAS-RTB: %1 reason=%2 fuel=%3 damage=%4 ammo=%5", _callsign, _rtbReason, fuel _veh, damage _veh, _veh ammo _weapon] call ALiVE_fnc_dump; };
};
