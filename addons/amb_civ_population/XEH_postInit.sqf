#include "script_component.hpp"

// Safety check: if ALiVE_advciv_enabled doesn't exist yet, exit gracefully
// This can happen if XEH_postInit runs before the Civilian Population module initializes
if (isNil "ALiVE_advciv_enabled") exitWith {
    ["ALiVE Advanced Civilians - ALiVE_advciv_enabled not yet initialized, skipping postInit"] call ALIVE_fnc_dump;
};

["ALiVE Advanced Civilians - postInit starting | ALiVE_advciv_enabled = %1", ALiVE_advciv_enabled] call ALIVE_fnc_dump;

// Exit if AdvCiv is disabled
if (!ALiVE_advciv_enabled) exitWith {
    ["ALiVE Advanced Civilians - postInit EXITED (disabled)"] call ALIVE_fnc_dump;
};

// ==============================================
//  SERVER INITIALIZATION
// ==============================================
if (isServer) then {
    ["ALiVE Advanced Civilians - Server postInit starting..."] call ALIVE_fnc_dump;

    // Call the main AdvCiv initialization
    call ALiVE_fnc_advciv_init;

    // Decay nearShots value over time (per-frame handler)
    [{
        if (!ALiVE_advciv_enabled) exitWith {};
        private _units = +ALiVE_advciv_activeUnits;
        {
            if (!isNull _x && {alive _x}) then {
                private _ns = _x getVariable ["ALiVE_advciv_nearShots", 0];
                if (_ns > 0) then {
                    _x setVariable ["ALiVE_advciv_nearShots", (_ns - 0.5) max 0];
                };
            };
        } forEach _units;
    }, 1, []] call CBA_fnc_addPerFrameHandler;

    // Civilian killed event - spread panic
    addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        if (side _killed != civilian) exitWith {};
        private _attackerUnit = if (!isNull _instigator) then {_instigator} else {_killer};
        if (isNull _attackerUnit) exitWith {};
        if (_attackerUnit == _killed) exitWith {};
        if (side _attackerUnit == civilian) exitWith {};
        _attackerUnit setVariable ["ALiVE_advciv_firedAtCiv", true, true];
        {
            if (alive _x && {side _x == civilian} && {!isPlayer _x} && {_x != _killed} && {_x getVariable ["ALiVE_advciv_active", false]}) then {
                _x setVariable ["ALiVE_advciv_state", "PANIC", true];
                _x setVariable ["ALiVE_advciv_panicSource", getPos _killed, true];
                _x setVariable ["ALiVE_advciv_hidingPos", [], true];
                _x setVariable ["ALiVE_advciv_nearShots", 10];
                _x setVariable ["ALiVE_advciv_lastShotTime", time];
            };
        } forEach (_killed nearEntities ["CAManBase", 50]);
    }];

    // Vehicle killed event - treat as explosion
    addMissionEventHandler ["EntityKilled", {
        params ["_killed", "_killer", "_instigator"];
        if (!(_killed isKindOf "LandVehicle") && !(_killed isKindOf "Air") && !(_killed isKindOf "Ship")) exitWith {};
        private _src = if (!isNull _instigator) then {_instigator} else {_killer};
        [getPos _killed, _src] call ALiVE_fnc_advciv_handleExplosion;
    }];

    // Track player-used vehicles
    private _fnc_addGetInEH = {
        params ["_veh"];
        if (isNil {_veh getVariable "ALiVE_advciv_getInEH"}) then {
            _veh setVariable ["ALiVE_advciv_getInEH", true];
            _veh addEventHandler ["GetIn", {
                params ["_vehicle", "_role", "_unit"];
                if (isPlayer _unit) then {
                    _vehicle setVariable ["ALiVE_advciv_wasUsedByPlayer", true, true];
                };
            }];
        };
    };

    { [_x] call _fnc_addGetInEH; } forEach vehicles;

    ["LandVehicle", "initPost", {
        params ["_veh"];
        if (isNil {_veh getVariable "ALiVE_advciv_getInEH"}) then {
            _veh setVariable ["ALiVE_advciv_getInEH", true];
            _veh addEventHandler ["GetIn", {
                params ["_vehicle", "_role", "_unit"];
                if (isPlayer _unit) then {
                    _vehicle setVariable ["ALiVE_advciv_wasUsedByPlayer", true, true];
                };
            }];
        };
    }, true] call CBA_fnc_addClassEventHandler;

    ["Air", "initPost", {
        params ["_veh"];
        if (isNil {_veh getVariable "ALiVE_advciv_getInEH"}) then {
            _veh setVariable ["ALiVE_advciv_getInEH", true];
            _veh addEventHandler ["GetIn", {
                params ["_vehicle", "_role", "_unit"];
                if (isPlayer _unit) then {
                    _vehicle setVariable ["ALiVE_advciv_wasUsedByPlayer", true, true];
                };
            }];
        };
    }, true] call CBA_fnc_addClassEventHandler;

    // Initialize existing units
    { [_x] call ALiVE_fnc_advciv_initUnit; } forEach allUnits;

    // Auto-initialize new units
    ["CAManBase", "initPost", {
        params ["_unit"];
        [{ [_this select 0] call ALiVE_fnc_advciv_initUnit; }, [_unit], 1] call CBA_fnc_waitAndExecute;
    }, true] call CBA_fnc_addClassEventHandler;

    ["LandVehicle", "initPost", {
        params ["_veh"];
        [{
            { if (alive _x && {!isPlayer _x} && {side _x != civilian}) then { [_x] call ALiVE_fnc_advciv_initUnit; }; } forEach crew (_this select 0);
        }, [_veh], 2] call CBA_fnc_waitAndExecute;
    }, true] call CBA_fnc_addClassEventHandler;

    // Main brain tick loop
    [{
        params ["_args", "_handle"];
        if (!ALiVE_advciv_enabled) exitWith {};

        ALiVE_advciv_activeUnits = ALiVE_advciv_activeUnits select {
            !isNull _x && {alive _x} && {!isPlayer _x} && {_x getVariable ["ALiVE_advciv_active", false]}
        };

        private _units = +ALiVE_advciv_activeUnits;
        private _batchSize = ALiVE_advciv_batchSize;

        if (_batchSize > 0 && {count _units > _batchSize}) then {
            private _offset = missionNamespace getVariable ["ALiVE_advciv_batchOffset", 0];
            _units = _units select [_offset, _batchSize];
            missionNamespace setVariable ["ALiVE_advciv_batchOffset", (_offset + _batchSize) mod (count ALiVE_advciv_activeUnits)];
        };

        { [_x] call ALiVE_fnc_advciv_brainTick; } forEach _units;
    }, ALiVE_advciv_tickRate, []] call CBA_fnc_addPerFrameHandler;

    // Initialize player fired event handlers
    {
        if (isPlayer _x && {side _x != civilian} && {!(_x getVariable ["ALiVE_advciv_firedEH", false])}) then {
            [_x] call ALiVE_fnc_advciv_initUnit;
        };
    } forEach allPlayers;

    addMissionEventHandler ["PlayerConnected", {
        [{
            {
                if (isPlayer _x && {side _x != civilian} && {!(_x getVariable ["ALiVE_advciv_firedEH", false])}) then {
                    [_x] call ALiVE_fnc_advciv_initUnit;
                };
            } forEach allPlayers;
        }, [], 3] call CBA_fnc_waitAndExecute;
    }];

    // Catch-all initialization loop for late-spawning units
    [{
        if (!ALiVE_advciv_enabled) exitWith {};
        {
            if (alive _x && {!isPlayer _x}) then {
                if (side _x == civilian) then {
                    if (!(_x getVariable ["ALiVE_advciv_active", false])) then {
                        [_x] call ALiVE_fnc_advciv_initUnit;
                    };
                } else {
                    if (!(_x getVariable ["ALiVE_advciv_firedEH", false])) then {
                        [_x] call ALiVE_fnc_advciv_initUnit;
                    };
                };
            };
        } forEach allUnits;
    }, 15, []] call CBA_fnc_addPerFrameHandler;

    ["ALiVE Advanced Civilians - Server postInit complete."] call ALIVE_fnc_dump;
};

// ==============================================
//  CLIENT INITIALIZATION
// ==============================================
if (hasInterface) then {
    // Stop-on-approach: freeze any nearby civilian and wave once when the
    // local player closes within 2 m, so the scroll-wheel / ACE interact
    // menu can lock on without the civ drifting out of range. Release
    // when the player backs off beyond 3 m. Runs for ALL civilians (not
    // only AdvCiv-active) because even vanilla-AI civilians can wander
    // out of interaction range during menu use. Skipped in CLASSIC mode
    // to preserve legacy UX.
    //
    // Per-frame rate 0.5 s is cheap - only scans a 5 m sphere around the
    // local player. Config-side check (side == 3) gates to civilians.
    // disableAI / enableAI / doWatch / doStop / setDir run on the unit's
    // owner via remoteExec; the wave gesture broadcasts so every client
    // renders it.
    //
    // setDir snaps the civ to face the player at the moment of freeze.
    // Without it, civs approached from behind get the doWatch (which
    // orients the gun-aim vector) but their body stays aimed in the
    // walking direction - the player ends up talking to the civ's back.
    // doStop halts any in-flight pathing animation that disableAI "MOVE"
    // alone leaves running until the next AI tick.
    [{
        if (isNull player || {!alive player}) exitWith {};
        if ((missionNamespace getVariable ["ALiVE_amb_civ_population_UIMode", "AUTO"]) == "CLASSIC") exitWith {};

        private _nearby = nearestObjects [player, ["CAManBase"], 5];
        {
            private _civ = _x;
            if (
                alive _civ &&
                {_civ != player} &&
                {!isPlayer _civ} &&
                {(getNumber (configFile >> "CfgVehicles" >> typeOf _civ >> "side")) == 3} &&
                {!(_civ getVariable ["ALiVE_advciv_blacklist", false])}
            ) then {
                // Skip if advciv is active and the civilian is in a non-CALM
                // reactive / ordered state - their brain already owns movement.
                private _advState = _civ getVariable ["ALiVE_advciv_state", "CALM"];
                if (_advState == "CALM") then {
                    private _d = _civ distance player;
                    private _frozen = _civ getVariable ["ALiVE_civ_approachFreeze", false];

                    if (_d < 2 && {!_frozen}) then {
                        // Pick the approach gesture by the civ's effective
                        // hostility - per-civ ALiVE_CivPop_Hostility floored
                        // by the module's per-side campaign baseline (the
                        // same combined value the dialog hostility indicator
                        // displays). Fires regardless of indicator mode so
                        // even indicator-off missions get a discoverable
                        // disposition cue from the wave / head-shake choice.
                        private _civHostility = _civ getVariable ["ALiVE_CivPop_Hostility", 30];
                        private _playerSide = str (side (group player));
                        private _sideBaseline = if (!isNil "ALIVE_civilianHostility") then {
                            [ALIVE_civilianHostility, _playerSide, 0] call ALiVE_fnc_hashGet
                        } else { 0 };
                        private _hostility = (_civHostility max _sideBaseline) max 0 min 100;
                        private _gesture = switch (true) do {
                            case (_hostility < 20):  { "GestureHi" };       // Friendly - wave
                            case (_hostility < 40):  { "GestureHi" };       // Neutral  - wave (baseline cue)
                            case (_hostility < 60):  { "Gesture_No" };      // Wary     - short head shake
                            case (_hostility < 80):  { "Gesture_NoLong" };  // Defiant  - emphatic refusal
                            default                  { "Gesture_NoLong" };  // Hostile  - emphatic refusal
                        };

                        private _bearing = _civ getDir player;
                        [_civ, "MOVE"] remoteExec ["disableAI", _civ];
                        [_civ] remoteExec ["doStop", _civ];
                        [_civ, _bearing] remoteExec ["setDir", _civ];
                        [_civ, player] remoteExec ["doWatch", _civ];
                        [_civ, _gesture] remoteExec ["playAction", 0];
                        _civ setVariable ["ALiVE_civ_approachFreeze", true, true];
                    };
                    if (_d > 3 && {_frozen}) then {
                        [_civ, "MOVE"] remoteExec ["enableAI", _civ];
                        [_civ, objNull] remoteExec ["doWatch", _civ];
                        _civ setVariable ["ALiVE_civ_approachFreeze", false, true];
                    };
                };
            };
        } forEach _nearby;
    }, 0.5, []] call CBA_fnc_addPerFrameHandler;

    // Weapon-aim civ-pressure handler. Runs alongside the approach-
    // freeze handler. Per-frame at 0.25 s for finer 2 s sustained-aim
    // detection than approach-freeze's 0.5 s tick.
    //
    // Trigger gates, cheap-to-expensive:
    //   1. Module attribute civWeaponAimRange > 0 (0 disables system).
    //   2. Player on foot (vehicle weapons are out of scope here).
    //   3. Player has a raised weapon.
    //   4. Civilian within civWeaponAimRange (sphere).
    //   5. Civilian under the player's cursor (cursorObject).
    //   6. Civilian has line-of-sight to the player (eye-to-eye, civ
    //      side - the civ has to actually see the threat).
    //   7. All conditions sustained for 2 s before reaction fires.
    //
    // Hysteresis on the hold-time clear: brief cursor flicker (one or
    // a few ticks of cursorObject momentarily missing the civ during
    // their walk animation) is forgiven for up to 1 s. Without it the
    // accumulated hold timer would reset constantly on a moving civ.
    //
    // Reaction dispatch lives in ALIVE_fnc_advciv_civAimReact (server-
    // authoritative). Bucket varies by the civ's hostility: Friendly
    // shrugs, Neutral / Wary surrender, Defiant / Hostile flee.
    [{
        if (isNull player || {!alive player}) exitWith {};

        private _aimRange = missionNamespace getVariable ["ALiVE_amb_civ_population_WeaponAimRange", 15];
        if (_aimRange <= 0) exitWith {};
        if (vehicle player != player) exitWith {};
        if (currentWeapon player == "") exitWith {};
        if (weaponLowered player) exitWith {};

        private _nearby = nearestObjects [player, ["CAManBase"], _aimRange];
        private _civsInRange = _nearby select {
            alive _x &&
            {_x != player} &&
            {!isPlayer _x} &&
            {(getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "side")) == 3} &&
            {!(_x getVariable ["ALiVE_advciv_blacklist", false])}
        };

        {
            private _civ = _x;
            private _state = _civ getVariable ["ALiVE_advciv_state", "CALM"];
            private _order = _civ getVariable ["ALiVE_advciv_order", "NONE"];
            if ((_state in ["PANIC", "HIDING"]) || {_order == "HANDSUP"}) then {
                // Skip - civ already in a target state.
            } else {
                private _aimingAt = (cursorObject == _civ);
                private _civCanSeePlayer = false;
                if (_aimingAt) then {
                    _civCanSeePlayer = !(lineIntersects [eyePos _civ, eyePos player, _civ, player]);
                };

                if (_aimingAt && _civCanSeePlayer) then {
                    _civ setVariable ["ALiVE_advciv_lastAimTick", time, true];

                    private _sinceVar = _civ getVariable ["ALiVE_advciv_aimedAtSince", -1];
                    if (_sinceVar < 0) then {
                        _civ setVariable ["ALiVE_advciv_aimedAtSince", time, true];
                    };
                    private _heldFor = time - (_civ getVariable ["ALiVE_advciv_aimedAtSince", time]);
                    if (_heldFor >= 2 && {isNil {_civ getVariable "ALiVE_advciv_aimReactFired"}}) then {
                        private _hostility = _civ getVariable ["ALiVE_CivPop_Hostility", 30];
                        private _bucket = switch (true) do {
                            case (_hostility < 20):  { "Friendly" };
                            case (_hostility < 40):  { "Neutral" };
                            case (_hostility < 60):  { "Wary" };
                            case (_hostility < 80):  { "Defiant" };
                            default                  { "Hostile" };
                        };
                        _civ setVariable ["ALiVE_advciv_aimReactFired", true, true];
                        [_civ, _bucket, player] remoteExec ["ALIVE_fnc_advciv_civAimReact", 2];
                    };
                } else {
                    private _lastSeen = _civ getVariable ["ALiVE_advciv_lastAimTick", -10];
                    if (time - _lastSeen > 1) then {
                        if !(isNil {_civ getVariable "ALiVE_advciv_aimedAtSince"}) then {
                            _civ setVariable ["ALiVE_advciv_aimedAtSince", nil, true];
                            _civ setVariable ["ALiVE_advciv_aimReactFired", nil, true];
                            _civ setVariable ["ALiVE_advciv_lastAimTick", nil, true];
                        };
                    };
                };
            };
        } forEach _civsInRange;
    }, 0.25, []] call CBA_fnc_addPerFrameHandler;

    // Civilian vehicle stop on player weapon-aim or stop gesture. When
    // the local player aims a raised weapon at a civ-driven vehicle OR
    // plays a stop / cease-fire / freeze gesture while looking at one,
    // the driver is signalled to stop and dismount. Two triggers cover
    // two play styles:
    //   - Weapon-aim: "pull over or I shoot". Range 50 m.
    //   - Gesture:    non-threatening hand signal, COIN-friendly.
    //                 Range 30 m (tighter - it's a hand-signal, not an
    //                 optic-range threat).
    // Both share the same dispatch endpoint and refusal gates.
    //
    // Once-per-driver debounce via the ALiVE_CivPop_VehicleStopTriggered
    // flag.
    //
    // Trigger gates, cheap-to-expensive:
    //   1. Module attribute civVehicleStopOnAim = true.
    //   2. Player on foot.
    //   3. EITHER (a) raised weapon, OR (b) stop / cease-fire / freeze
    //      gesture currently playing on the player.
    //   4. Civ-driven vehicle within range (50 m weapon / 30 m gesture).
    //   5. Aim cone <= 10 degrees between camera view direction and
    //      bearing-to-vehicle.
    //   6. Driver state allows compliance (not already triggered) and
    //      effective hostility < 60.
    //
    // Per-frame at 0.5 s - vehicles move slower than pedestrians so the
    // tighter 0.25 s tick of the aim-pressure handler is unnecessary.
    [{
        if (isNull player || {!alive player}) exitWith {};

        if (!(missionNamespace getVariable ["ALiVE_amb_civ_population_VehicleStopOnAim", true])) exitWith {};
        if (vehicle player != player) exitWith {};

        // Resolve trigger source. Weapon-aim has priority - if both are
        // active, range stays at the weapon-aim 50 m.
        private _weaponAim = (currentWeapon player != "") && {!weaponLowered player};
        private _animLower = toLower (animationState player);
        private _gestureStop = (_animLower find "ceasefire" >= 0) ||
                               {_animLower find "stop" >= 0} ||
                               {_animLower find "freeze" >= 0};

        if (!_weaponAim && {!_gestureStop}) exitWith {};

        private _range = if (_weaponAim) then { 50 } else { 30 };
        private _trigger = if (_weaponAim) then { "WEAPON" } else { "GESTURE" };

        private _vehicles = nearestObjects [player, ["LandVehicle", "Air", "Ship"], _range];
        if (count _vehicles == 0) exitWith {};

        // Use the camera's actual view direction as the source-of-truth
        // for "what the player is aiming at". eyeDirection / weaponDirection
        // both follow the character model, which in 3rd person is locked
        // to the body forward direction even when the camera (and the
        // player's perception of aim) is rotated elsewhere. Camera view
        // direction always matches what the player sees on screen,
        // regardless of 1st / 3rd person / freelook.
        private _camPos = positionCameraToWorld [0, 0, 0];
        private _camForward = positionCameraToWorld [0, 0, 1];
        private _playerEye = _camPos;  // anchor the angle math at the camera, not the head
        private _aimDir = vectorNormalized (_camForward vectorDiff _camPos);

        {
            private _veh = _x;
            if (alive _veh) then {
                private _drv = driver _veh;
                if (
                    !isNull _drv &&
                    {alive _drv} &&
                    {!isPlayer _drv}
                ) then {
                    private _drvSide = getNumber (configFile >> "CfgVehicles" >> typeOf _drv >> "side");
                    if (_drvSide == 3) then {
                        if (
                            !(_drv getVariable ["ALiVE_advciv_blacklist", false]) &&
                            {!(_drv getVariable ["ALiVE_CivPop_VehicleStopTriggered", false])}
                        ) then {
                            private _state = _drv getVariable ["ALiVE_advciv_state", "CALM"];
                            private _order = _drv getVariable ["ALiVE_advciv_order", "NONE"];

                            // Use aimPos so the angle math uses the vehicle's
                            // natural aim-target point (chest / centre height),
                            // not the ground-level position. With eyePos at
                            // ~1.7 m and position at 0 m the angle is wildly
                            // off at close range.
                            private _aimPt = aimPos _veh;
                            private _toVeh = vectorNormalized (_aimPt vectorDiff _playerEye);
                            private _dot = (_aimDir vectorDotProduct _toVeh) max -1 min 1;
                            private _angle = acos _dot;
                            private _dist = round (player distance _veh);

                            // Skip only already-triggered drivers. State is
                            // not gated - the player aiming a weapon is a
                            // stronger immediate threat than whatever the
                            // civ's brain-tick state was, and the gameplay
                            // intent is "all drivers comply" so the
                            // feature works in tense fleeing-driver
                            // scenarios as well as calm ones.
                            if !(_order == "STOP_VEHICLE") then {
                                if (_angle < 10) then {
                                    private _civHostility = _drv getVariable ["ALiVE_CivPop_Hostility", 30];
                                    private _playerSide = str (side (group player));
                                    private _sideBaseline = if (!isNil "ALIVE_civilianHostility") then {
                                        [ALIVE_civilianHostility, _playerSide, 0] call ALiVE_fnc_hashGet
                                    } else { 0 };
                                    private _h = (_civHostility max _sideBaseline) max 0 min 100;

                                    if (_h < 60) then {
                                        _drv setVariable ["ALiVE_CivPop_VehicleStopTriggered", true, true];
                                        [_drv, "STOP_VEHICLE", _veh] remoteExec ["ALIVE_fnc_advciv_react", _drv];
                                    };
                                };
                            };
                        };
                    };
                };
            };
        } forEach _vehicles;
    }, 0.5, []] call CBA_fnc_addPerFrameHandler;

    // Use CBA_fnc_waitUntilAndExecute instead of waitUntil to avoid suspending errors.
    // Guard on both isValidCiv (published by SystemInit) and ALiVE_advciv_enabled to
    // ensure the system actually completed initialisation before adding order menus.
    [{
        !isNil "ALiVE_fnc_advciv_isValidCiv" && { !isNil "ALiVE_advciv_enabled" } && { ALiVE_advciv_enabled } && { !isNil "ALiVE_advciv_enabled" && { ALiVE_advciv_enabled } }
    }, {
        // Add order menus to existing civilians
        {
            if ([_x] call ALiVE_fnc_advciv_isValidCiv) then {
                [_x] call ALiVE_fnc_advciv_orderMenu;
            };
        } forEach allUnits;

        // Auto-add order menus to new civilians
        ["CAManBase", "initPost", {
            params ["_unit"];
            [{
                if ([_this select 0] call ALiVE_fnc_advciv_isValidCiv) then {
                    [_this select 0] call ALiVE_fnc_advciv_orderMenu;
                };
            }, [_unit], 1.5] call CBA_fnc_waitAndExecute;
        }, true] call CBA_fnc_addClassEventHandler;
    }, []] call CBA_fnc_waitUntilAndExecute;

    // Debug 3D labels
    if (ALiVE_advciv_debug) then {
        addMissionEventHandler ["Draw3D", {
            if (!ALiVE_advciv_debug) exitWith {};

            private _playerPos = getPosATL player;
            private _cameraPos = positionCameraToWorld [0,0,0];
            private _checkPos = if (_playerPos distance _cameraPos < 10) then {_playerPos} else {_cameraPos};

            {
                if (alive _x && {side _x == civilian} && {!isPlayer _x} && {_x getVariable ["ALiVE_advciv_active", false]}) then {
                    private _distCheck = (_x distance player < 100) || {_x distance _cameraPos < 100};
                    if (_distCheck) then {
                        private _label = _x getVariable ["ALiVE_advciv_dbgState", ""];
                        if (_label != "") then {
                            private _state = _x getVariable ["ALiVE_advciv_state", "CALM"];
                            private _color = switch (_state) do {
                                case "CALM":     { [0,1,0,0.8] };
                                case "ALERT":    { [1,1,0,0.8] };
                                case "PANIC":    { [1,0.5,0,0.8] };
                                case "HIDING":   { [0.5,0,1,0.8] };
                                case "HIT_REACT":{ [1,0,0,0.8] };
                                case "ORDERED":  { [0,0.5,1,0.8] };
                                default          { [1,1,1,0.8] };
                            };
                            drawIcon3D ["", _color, ASLToAGL (getPosASL _x) vectorAdd [0,0,2.2], 0, 0, 0, _label, 2, 0.04, "PuristaMedium"];
                        };
                    };
                };
            } forEach (_checkPos nearEntities [["CAManBase"], 150]);
        }];
    };

    // Debug console helper function
    ALiVE_fnc_advciv_debugInfo = {
        params [["_unit", objNull]];

        if (isNull _unit) then {
            private _allCivs = allUnits select {side _x == civilian && !isPlayer _x};
            private _advCivs = _allCivs select {_x getVariable ["ALiVE_advciv_active", false]};

            systemChat "=== AdvCiv System Info ===";
            systemChat format ["Total civilians: %1", count _allCivs];
            systemChat format ["AdvCiv active: %1", count _advCivs];
            systemChat format ["ActiveUnits array: %1", count ALiVE_advciv_activeUnits];
            systemChat format ["Settings: Debug=%1, TickRate=%2s, Range=%3m",
                ALiVE_advciv_debug, ALiVE_advciv_tickRate, ALiVE_advciv_orderMenuRange];

            private _calm     = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "CALM"};
            private _alert    = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "ALERT"};
            private _panic    = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "PANIC"};
            private _hiding   = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "HIDING"};
            private _hitReact = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "HIT_REACT"};
            private _ordered  = _advCivs select {(_x getVariable ["ALiVE_advciv_state", ""]) == "ORDERED"};

            systemChat format ["CALM=%1, ALERT=%2, PANIC=%3, HIDING=%4, HIT_REACT=%5, ORDERED=%6",
                count _calm, count _alert, count _panic, count _hiding, count _hitReact, count _ordered];
            systemChat "======================";
        } else {
            systemChat "=== AdvCiv Unit Info ===";
            systemChat format ["Unit: %1", _unit];
            systemChat format ["Active: %1", _unit getVariable ["ALiVE_advciv_active", false]];
            systemChat format ["State: %1", _unit getVariable ["ALiVE_advciv_state", "undefined"]];
            systemChat format ["Order: %1", _unit getVariable ["ALiVE_advciv_order", "NONE"]];
            systemChat format ["NearShots: %1", _unit getVariable ["ALiVE_advciv_nearShots", 0]];
            systemChat format ["HomePos: %1", _unit getVariable ["ALiVE_advciv_homePos", []]];
            systemChat format ["PanicSource: %1", _unit getVariable ["ALiVE_advciv_panicSource", [0,0,0]]];
            systemChat format ["In activeUnits: %1", _unit in ALiVE_advciv_activeUnits];
            systemChat "======================";
        };
    };

    systemChat "[AdvCiv] Debug helper loaded. Use: call ALiVE_fnc_advciv_debugInfo";
};
