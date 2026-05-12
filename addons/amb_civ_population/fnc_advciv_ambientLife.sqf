/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_ambientLife
Description:
    Drives time-of-day ambient behaviour for a single AdvCiv civilian unit.
    Called each brain tick when the unit is in the CALM state and on foot.
    Selects an appropriate action from a weighted pool based on the current
    hour (morning, day, evening, night) and whether the unit is indoors,
    then executes that action: walking, sitting, gathering with nearby
    civilians, watching passing vehicles, going home, or sleeping.
Parameters:
    _this select 0: OBJECT - The civilian unit to process
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_brainTick, ALIVE_fnc_advciv_findHouse,
    ALIVE_fnc_advciv_getSafePositions
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull, [objNull]]];

if (isNull _unit || !alive _unit) exitWith {};
if (isPlayer _unit) exitWith {};
if (vehicle _unit != _unit) exitWith {};   // Skip units already in a vehicle

private _lastAction = _unit getVariable ["ALiVE_advciv_lastAction", 0];
private _homePos    = _unit getVariable ["ALiVE_advciv_homePos", getPos _unit];

// Throttle: don't tick until the previous action's timer has expired
if (time < _lastAction) exitWith {};


// -----------------------------------------------------------------------
// Determine whether the unit is currently inside a building by casting a
// vertical ray upward. If a surface is found overhead the unit is indoors.
// -----------------------------------------------------------------------
private _isIndoors = false;
private _currentBuilding = objNull;
private _unitFloorZ = (getPosATL _unit) select 2;
{
    if (_unit distance2D _x < 15) then {
        private _above = getPos _unit vectorAdd [0, 0, 0.5];
        private _high  = getPos _unit vectorAdd [0, 0, 15];
        private _surfaces = lineIntersectsSurfaces [
            AGLToASL _above,
            AGLToASL _high,
            _unit,
            objNull,
            true,
            1,
            "GEOM",
            "NONE"
        ];
        if (count _surfaces > 0) then {
            _isIndoors       = true;
            _currentBuilding = _x;
        };
    };
} forEach (nearestObjects [_unit, ["House","Building"], 15]);

// Classify time of day into four bands used to weight action pools below
private _hour      = daytime;
private _isNight   = (_hour < 6 || _hour > 22);
private _isMorning = (_hour >= 6  && _hour < 10);
private _isDay     = (_hour >= 10 && _hour < 18);
private _isEvening = (_hour >= 18 && _hour <= 22);

// Wake-up: if the unit was sleeping last tick and it's no longer night,
// clear the locked sleep animation so the normal action selection below
// can take over. switchMove "" releases any prior locked animation; the
// engine then resumes natural stance based on setUnitPos preferences.
// Threat-driven wake (gunfire / explosion / killed civ nearby) is already
// covered: those handlers transition the civ out of CALM, and the
// brainTick CALM/ALERT entry block (commit 3b25d99e) clears switchMove
// when the unit returns to CALM via the autonomous state machine.
private _previousAction = _unit getVariable ["ALiVE_advciv_actionType", ""];
if (_previousAction == "SLEEPING" && {!_isNight}) then {
    [_unit, ""] remoteExec ["switchMove", 0];
    // Restore stance so the civ stands up rather than staying prone -
    // setUnitPos "DOWN" was set on sleep entry and persists across the
    // anim clear. Use "UP" rather than "AUTO" since the civ should
    // visibly stand up at sunrise, not stay crouched.
    _unit setUnitPos "UP";
    _unit setVariable ["ALiVE_advciv_actionType", "WAKING", true];
    if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Sleep DEBUG] civ=%1 waking up (daytime=%2)", name _unit, _hour]; };
};


// -----------------------------------------------------------------------
// Night: civilians sleep. If already indoors, settle into the sleep
// animation in place; otherwise find a nearby building and move to an
// interior position - the next tick (after _lastAction expiry) will see
// the unit indoors and play the sleep anim. Uses findHouseProgressive
// to handle civs stranded in genuinely open terrain at night fall.
//
// Animation: AmovPpneMstpSnonWnonDnon is the vanilla A3 base-game prone
// static for an unarmed unit (PpneM = prone, Snon = no weapon, Dnon =
// no direction). Always present, guaranteed valid switchMove target.
// Pair with setUnitPos "DOWN" so the engine commits to the prone state
// rather than treating the switchMove as a momentary pose. Visually flat
// lying-down - not a curled-up pillow-sleep, but unambiguously asleep.
// First attempt used Acts_LyingDown_loop based on training knowledge;
// the engine no-op'd it (presumably the classname is wrong or
// campaign-only) so civs stayed in their previous daytime animation.
// AmovPpne is the reliable fallback.
if (_isNight) exitWith {
    if (_isIndoors) then {
        doStop _unit;
        if (ALiVE_advciv_nightSleepAnim) then {
            _unit setUnitPos "DOWN";
            [_unit, "AmovPpneMstpSnonWnonDnon"] remoteExec ["switchMove", 0];
            if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Sleep DEBUG] civ=%1 sleeping (indoors at %2)", name _unit, getPos _unit]; };
        };
        _unit setVariable ["ALiVE_advciv_actionType", "SLEEPING", true];
        _unit setVariable ["ALiVE_advciv_lastAction", time + 120];
    } else {
        private _houseData = [_unit] call ALiVE_fnc_advciv_findHouseProgressive;
        _houseData params [["_building", objNull], ["_positions", []]];
        if (!isNull _building && count _positions > 0) then {
            _unit doMove (selectRandom _positions);
            // SLEEPING_ENROUTE marks "heading home but not yet sleeping" so
            // the wake-up branch above doesn't false-fire on a daylight tick
            // that sees actionType SLEEPING without the unit being asleep.
            _unit setVariable ["ALiVE_advciv_actionType", "SLEEPING_ENROUTE", true];
            _unit setVariable ["ALiVE_advciv_lastAction", time + 120];
            if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Sleep DEBUG] civ=%1 heading home to sleep (dist to building=%2)", name _unit, _unit distance _building]; };
        } else {
            // No building reachable even at 3x fleeRadius - civ stays
            // outdoors at night with no special action. Rare edge case
            // (genuinely open terrain at night fall).
            if (ALiVE_advciv_debug) then { diag_log format ["[ALiVE Sleep DEBUG] civ=%1 no shelter found for night - staying outdoors", name _unit]; };
            _unit setVariable ["ALiVE_advciv_lastAction", time + 60];
        };
    };
};


// -----------------------------------------------------------------------
// Build a weighted action pool appropriate to the location and time of day.
// Repetition within the array raises the probability of that action being
// selected. Falls back to STAND if no time band matched (shouldn't happen).
// -----------------------------------------------------------------------
private _actions = [];

if (_isIndoors) then {
    if (_isMorning) then { _actions = ["STAND_INDOOR","STAND_INDOOR","SIT","WALK_INDOOR"]; };
    if (_isDay)     then { _actions = ["STAND_INDOOR","SIT","SIT","WALK_INDOOR","WALK_INDOOR"]; };
    if (_isEvening) then { _actions = ["STAND_INDOOR","SIT","STAND_INDOOR"]; };
} else {
    if (_isMorning) then { _actions = ["WALK","WALK","STAND","WATCH"]; };
    if (_isDay)     then { _actions = ["WALK","WALK","WALK","STAND","SIT","GATHER","WATCH","WORK"]; };
    if (_isEvening) then { _actions = ["WALK","STAND","GOHOME","GOHOME","GATHER"]; };
};

if (count _actions == 0) then { _actions = ["STAND"]; };

private _action = selectRandom _actions;
_unit setVariable ["ALiVE_advciv_actionType", _action, true];

switch (_action) do {

    // Walk to a random position on the same floor of the current building.
    // Falls back to all ground positions if same-floor detection returns nothing,
    // and stops in place if no valid positions exist at all.
    case "WALK_INDOOR": {
        if (!isNull _currentBuilding) then {
            // Request all positions with an unrestricted height cap, then filter
            // to those on the same floor as the unit (within 2 m vertically).
            private _allSafe = [_currentBuilding, 999, _unit] call ALiVE_fnc_advciv_getSafePositions;
            private _sameFloor = _allSafe select {
                abs ((_x select 2) - _unitFloorZ) < 2
            };
            // Fallback: use getSafePositions with standard ground-floor cap
            if (count _sameFloor == 0) then {
                _sameFloor = [_currentBuilding, 3.5, _unit] call ALiVE_fnc_advciv_getSafePositions;
            };

            if (count _sameFloor > 0) then {
                _unit setUnitPos "UP";
                _unit setSpeedMode "LIMITED";
                _unit setBehaviour "CARELESS";
                _unit doMove (selectRandom _sameFloor);
                // Long timer: indoor movement is slow; retick too soon causes jitter
                _unit setVariable ["ALiVE_advciv_lastAction", time + 40 + random 60];
            } else {
                doStop _unit;
                _unit setVariable ["ALiVE_advciv_lastAction", time + 30];
            };
        } else {
            doStop _unit;
            _unit setVariable ["ALiVE_advciv_lastAction", time + 20];
        };
    };

    // Stand idle indoors with an optional ambient talking animation
    case "STAND_INDOOR": {
        _unit setUnitPos "UP";
        _unit setSpeedMode "LIMITED";
        doStop _unit;
        // Empty string in pool gives a chance of no animation (natural idle)
        private _anim = selectRandom ["Acts_CivilTalking_1", "Acts_StandingSpeakingRU", ""];
        if (_anim != "") then { [_unit, _anim] remoteExec ["playMove", 0]; };
        _unit setVariable ["ALiVE_advciv_lastAction", time + 40 + random 60];
    };

    // Walk to a random road-snapped position within the home radius
    case "WALK": {
        _unit setUnitPos "UP";
        _unit setSpeedMode "LIMITED";
        _unit setBehaviour "CARELESS";
        private _radius = 20 + random (ALiVE_advciv_homeRadius * 0.6);
        private _target = _homePos getPos [_radius, random 360];
        // Snap destination to nearest road piece to make movement look natural
        private _roads = _target nearRoads 30;
        if (count _roads > 0) then { _target = getPos (selectRandom _roads); };
        _unit doMove _target;
        _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
    };

    // Stand still outdoors, watching a random distant point with occasional animation
    case "STAND": {
        _unit setUnitPos "UP";
        _unit setSpeedMode "LIMITED";
        doStop _unit;
        _unit doWatch (getPos _unit getPos [50 + random 100, random 360]);
        private _anim = selectRandom ["Acts_CivilTalking_1", "Acts_StandingSpeakingRU", ""];
        if (_anim != "") then { [_unit, _anim] remoteExec ["playMove", 0]; };
        _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
    };

    // Find a chair on the same floor and sit in it. Falls back to STAND if
    // no chair is found. Uses CBA_fnc_waitUntilAndExecute to apply the
    // sitting animation only once the unit has actually arrived at the chair.
    case "SIT": {
        private _chairTypes = [
            "Land_ChairPlastic_F","Land_ChairWood_F","Land_RattanChair_01_F",
            "Land_CampingChair_V1_F","Land_CampingChair_V2_F","Land_OfficeChair_01_F",
            "Land_ArmChair_01_F","Land_Bench_01_F","Land_Bench_F","Land_BenchIndoor_01_F",
            "Land_Bench_03_F","Land_Bench_04_F","Land_ChairPlastic_V1_F","Land_ChairPlastic_V2_F"
        ];
        private _chairs = nearestObjects [_unit, _chairTypes, 25];

        // Restrict to chairs on the same floor to avoid units running upstairs
        _chairs = _chairs select {
            abs ((getPosATL _x select 2) - _unitFloorZ) < 2
        };

        if (count _chairs > 0) then {
            private _chair = _chairs select 0;
            _unit doMove (getPos _chair);

            // Wait until close enough to the chair, then apply sit animation.
            // Timeout prevents getting stuck waiting if the unit is redirected.
            [{
                params ["_u", "_c"];
                !alive _u || _u distance _c < 1.8 || time > (_this select 2)
            }, {
                params ["_u", "_c", "_timeout"];
                if (alive _u && {_u distance _c < 1.8} && {vehicle _u == _u}) then {
                    doStop _u;
                    _u setDir (getDir _c);
                    [_u, "HubSittingChairUA_idle1"] remoteExec ["switchMove", 0];
                    _u setVariable ["ALiVE_advciv_lastAction", time + 60 + random 60];
                };
            }, [_unit, _chair, time + 20]] call CBA_fnc_waitUntilAndExecute;

            _unit setVariable ["ALiVE_advciv_lastAction", time + 25];
        } else {
            // No chair found — degrade to STAND so the unit still does something
            doStop _unit;
            _unit setVariable ["ALiVE_advciv_actionType", "STAND", true];
            _unit setVariable ["ALiVE_advciv_lastAction", time + 20];
        };
    };

    // Walk toward a random nearby civilian and play a talking animation on arrival
    case "GATHER": {
        _unit setUnitPos "UP";
        // Note: allUnits does not include createAgent crowd civilians, but that
        // is acceptable here — GATHER is a bonus behaviour, not a critical one
        private _nearbyCiv = allUnits select {
            side _x == civilian && alive _x && !isPlayer _x && _x != _unit
            && _x distance _unit < 80 && {vehicle _x == _x}
        };

        if (count _nearbyCiv > 0) then {
            private _target = selectRandom _nearbyCiv;
            _unit doMove ((getPos _target) getPos [2 + random 3, random 360]);

            // Play talking animation after a short walk delay, only if still calm
            [{
                params ["_unit"];
                if (alive _unit && {_unit getVariable ["ALiVE_advciv_state", "CALM"] == "CALM"} && {vehicle _unit == _unit}) then {
                    [_unit, "Acts_CivilTalking_2"] remoteExec ["playMove", 0];
                };
            }, [_unit], 10 + random 5] call CBA_fnc_waitAndExecute;
        } else {
            doStop _unit;
        };
        _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
    };

    // Watch a nearby moving vehicle (curiosity behaviour). Short timer so the
    // unit re-evaluates quickly in case the vehicle moves out of range.
    case "WATCH": {
        _unit setUnitPos "UP";
        private _vehicles = nearestObjects [_unit, ["LandVehicle", "Air"], ALiVE_advciv_curiosityRange];
        _vehicles = _vehicles select {alive _x && speed _x > 5};
        if (count _vehicles > 0) then {
            _unit doWatch (_vehicles select 0);
            _unit setVariable ["ALiVE_advciv_lastAction", time + 8];
        } else {
            _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
        };
    };

    // Move to the exterior of a nearby building to simulate working/activity
    case "WORK": {
        _unit setUnitPos "UP";
        private _buildings = nearestObjects [_unit, ["House"], 50];
        if (count _buildings > 0) then {
            _unit doMove (getPos (selectRandom _buildings) getPos [3, random 360]);
            _unit setVariable ["ALiVE_advciv_lastAction", time + 40];
        } else {
            _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
        };
    };

    // Walk directly home; used in the evening to gradually clear streets
    case "GOHOME": {
        _unit setUnitPos "UP";
        _unit doMove _homePos;
        _unit setVariable ["ALiVE_advciv_lastAction", time + 15];
    };
};
