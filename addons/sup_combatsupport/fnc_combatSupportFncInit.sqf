//----------------------
//Misc
//----------------------
// A support asset's own respawn time and limit (#1079), set on its CAS, Transport, Artillery or Ground
// Transport module and kept in ALiVE_CS_respawnReg by kind and callsign; the Combat Support module's
// values for an asset that sets none. _kind is "CAS", "TRANS", "ARTY" or "GROUND".
NEO_fnc_respawnTime = {
    params ["_kind", "_callsign", "_default"];
    private _e = (missionNamespace getVariable ["ALiVE_CS_respawnReg", createHashMap]) getOrDefault [_kind + "|" + toUpper _callsign, [-1, -1]];
    [_default, _e select 0] select ((_e select 0) >= 0)
};
// replacements left for it: its own count, or the shared one for its kind (below 0: no limit)
NEO_fnc_respawnLeft = {
    params ["_kind", "_callsign", "_global"];
    private _e = (missionNamespace getVariable ["ALiVE_CS_respawnReg", createHashMap]) getOrDefault [_kind + "|" + toUpper _callsign, [-1, -1]];
    if ((_e select 1) >= 0) then { _e select 1 } else { missionNamespace getVariable [_global, -1] }
};
// takes one replacement; false when none is left. Call unscheduled (inside isNil) so 2 losses close
// together can't both take the last one
NEO_fnc_respawnTake = {
    params ["_kind", "_callsign", "_global"];
    private _reg = missionNamespace getVariable ["ALiVE_CS_respawnReg", createHashMap];
    private _key = _kind + "|" + toUpper _callsign;
    private _e = _reg getOrDefault [_key, [-1, -1]];
    if ((_e select 1) >= 0) exitWith {
        if ((_e select 1) == 0) then { false } else { _reg set [_key, [_e select 0, (_e select 1) - 1]]; true }
    };
    private _left = missionNamespace getVariable [_global, -1];
    if (_left == 0) then { false } else { missionNamespace setVariable [_global, _left - 1]; true }
};
NEO_fnc_smokeColor = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_smokeColor.sqf";
NEO_fnc_messageBroadcast = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_messageBroadcast.sqf";
NEO_fnc_callsignFix = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_callsignFix.sqf";
NEO_fnc_artyUnitAvailableRounds = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitAvailableRounds.sqf";
NEO_fnc_artyUnitFiringDistance = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyUnitFiringDistance.sqf";
// Whether a battery is a missile launcher with no artillery computer, such as the MK41 VLS (The Horny Latino on
// Discord, 23 Oct): the engine won't aim it at a map position, so it fires its guided missiles at a laser target
// instead. Takes a classname, a gun or a crewman, or a list of them (the first vehicle in it). Kept per class.
// Shared with the AI Commander's artillery, in x_lib.
NEO_fnc_artyIsMissileLauncher = { [_this, "isLauncher"] call ALIVE_fnc_missileArtillery };
// [probe (a gun or class), the battery's guns, its rounds] -> its rounds. For a missile launcher battery: no more rounds
// than the missiles its launchers carry, and the launchers locked against UAV terminals for every player (it's a UAV
// to the game, and one taken over can't be fired by the radio), now, after the player respawns and for anyone joining
// later. Called wherever a battery is built: at the start, on a respawn, and when one is added during the mission.
NEO_fnc_artyLauncherSetup = { [_this, "setup"] call ALIVE_fnc_missileArtillery };
NEO_fnc_supportDrawRing = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportDrawRing.sqf";
NEO_fnc_supportFocusMap = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportFocusMap.sqf";
NEO_fnc_supportSetTargetPos = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportSetTargetPos.sqf";
NEO_fnc_radioGridToPos = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioGridToPos.sqf";
NEO_fnc_radioPosToGrid = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioPosToGrid.sqf";
NEO_fnc_transportGunnerDefend = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportGunnerDefend.sqf";
NEO_fnc_transportInsertionHold = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportInsertionHold.sqf";
NEO_fnc_transportMedevac = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportMedevac.sqf";
NEO_fnc_transportParadrop = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportParadrop.sqf";
NEO_fnc_transportParadropUnit = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportParadropUnit.sqf";
NEO_fnc_radioCreateMarker = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_createMarker.sqf";
NEO_fnc_radioHint = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_radioHint.sqf";
NEO_fnc_radioSupportAdd = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportAdd.sqf";
NEO_fnc_radioSupportRemove = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportRemove.sqf";
fnc_setGroupID = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setGroupID.sqf";
fnc_addAction = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_addAction.sqf";
fnc_setFlyInHeight = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setFlyInHeight.sqf";
fnc_setSpeed = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setSpeed.sqf";
fnc_setROE = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_setROE.sqf";
fnc_getSitrep = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_getSitrep.sqf";
ALIVE_fnc_RespawnArtyAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnArtyAsset.sqf";
ALIVE_fnc_RespawnTransportAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnTransportAsset.sqf";
NEO_fnc_supportOrderMarkers = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_supportOrderMarkers.sqf";
// Route round known enemy for helicopters (A. Ares on Discord, 4 Nov)
NEO_fnc_transportAvoidLegs = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportAvoidLegs.sqf";
NEO_fnc_transportAvoidFly = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportAvoidFly.sqf";
// Escorts for transport (Eric on Discord, 22 Oct)
NEO_fnc_transportEscortList = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportEscortList.sqf";
NEO_fnc_transportEscort = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_transportEscort.sqf";
// Ground transport (#690)
NEO_fnc_groundPanel = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\ground\fn_groundPanel.sqf";
ALIVE_fnc_RespawnGroundAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnGroundAsset.sqf";
NEO_fnc_groundSpawn = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundSpawn.sqf";
NEO_fnc_groundBrain = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundBrain.sqf";
NEO_fnc_groundStop = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundStop.sqf";
NEO_fnc_groundDrive = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundDrive.sqf";
NEO_fnc_groundRoadPatrol = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundRoadPatrol.sqf";
NEO_fnc_groundMineCheck = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_groundMineCheck.sqf";

ALIVE_fnc_RespawnCASAsset = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_RespawnCASAsset.sqf";
// A two-seat jet's back seat can own pylons, the S.O.G. F-4C's bombs among them, and the CAS menu and the
// attack only use the pilot's weapons: hand every pylon to the pilot, with the rounds it carries. Planes only:
// an attack helicopter's gunner owns its missile pylons and fires them.
NEO_fnc_casPylonsToPilot = {
    params ["_veh"];
    if !(_veh isKindOf "Plane") exitWith {};
    {
        _x params ["_index", "", "_turret", "_magazine", "_rounds"];
        if (_turret isNotEqualTo [-1] && {_magazine != ""}) then {
            _veh setPylonLoadout [_index, _magazine, true, [-1]];
            _veh setAmmoOnPylon [_index, _rounds];
        };
    } forEach getAllPylonsInfo _veh;
};
// A support aircraft's home stand never sits on an airfield's taxi route or at the start of its runway. A CAS plane
// whose stand was on the first taxi leg of Takistan's main field (RSS7's A-10) started up by itself, was put back on
// that stand by the hold above and held there, and the air commander's drone taxiing out stopped 18 m behind it for
// good (19 Nov). The taxi lines are the ones the air commander taxis along (fnc_ATOEffect, "taxiOut"): each airport's
// ilsTaxiIn and ilsTaxiOff from the terrain's config, or the runway found on the ground where the config has none.
// [position] -> [[airport index, [a, b]], ...], the main airport 0 and its secondary airports from 1
NEO_fnc_csTaxiLines = {
    params ["_pos"];
    private _w = configFile >> "CfgWorlds" >> worldName;
    private _fields = [_w];
    private _sec = _w >> "SecondaryAirports";
    for "_i" from 0 to ((count _sec) - 1) do { _fields pushBack (_sec select _i) };
    private _lines = [];
    {
        private _field = _x;
        private _id = _forEachIndex;
        {
            private _pts = getArray (_field >> _x);
            for "_i" from 0 to ((count _pts) - 4) step 2 do {
                _lines pushBack [_id, [[_pts select _i, _pts select (_i + 1), 0], [_pts select (_i + 2), _pts select (_i + 3), 0]]];
            };
        } forEach ["ilsTaxiIn", "ilsTaxiOff"];
    } forEach _fields;
    if (_lines isEqualTo [] && {!isNil "ALiVE_fnc_getRunwayCentreline"}) then {
        private _cl = [_pos, 1500] call ALiVE_fnc_getRunwayCentreline;
        if (count _cl > 1) then {
            _lines pushBack [0, [[(_cl select 0) select 0, (_cl select 0) select 1, 0], [(_cl select 1) select 0, (_cl select 1) select 1, 0]]];
        };
    };
    _lines
};
// Each airport's runway, from its ilsPosition and ilsDirection: it starts 100 m short of the threshold and runs along
// the take-off heading as far as that airport's taxi points reach, plus 100 m (800 m at least, 4 km at most).
// [] -> [[airport index, [a, b]], ...]
NEO_fnc_csRunwayLines = {
    private _w = configFile >> "CfgWorlds" >> worldName;
    private _fields = [_w];
    private _sec = _w >> "SecondaryAirports";
    for "_i" from 0 to ((count _sec) - 1) do { _fields pushBack (_sec select _i) };
    private _lines = [];
    {
        private _id = _forEachIndex;
        private _ils = getArray (_x >> "ilsPosition");
        private _dirV = getArray (_x >> "ilsDirection");
        if (count _ils >= 2 && {count _dirV >= 3} && {(_ils select 0) != 0 || {(_ils select 1) != 0}}) then {
            private _a = [_ils select 0, _ils select 1, 0];
            // ilsDirection points back out along the approach, so the take-off run is the other way
            private _u = vectorNormalized [-(_dirV select 0), -(_dirV select 2), 0];
            private _far = 0;
            private _field = _x;
            {
                private _pts = getArray (_field >> _x);
                for "_i" from 0 to ((count _pts) - 2) step 2 do {
                    _far = _far max (([_pts select _i, _pts select (_i + 1), 0] vectorDiff _a) vectorDotProduct _u);
                };
            } forEach ["ilsTaxiIn", "ilsTaxiOff"];
            private _len = ((_far + 100) max 800) min 4000;
            _lines pushBack [_id, [_a vectorDiff (_u vectorMultiply 100), _a vectorAdd (_u vectorMultiply _len)]];
        };
    } forEach _fields;
    _lines
};
// [point, a, b] -> metres from the point to the line from a to b, on the ground
NEO_fnc_csDistToLine = {
    params ["_p", "_a", "_b"];
    private _q = [_p select 0, _p select 1, 0];
    private _ab = _b vectorDiff _a;
    private _l2 = _ab vectorDotProduct _ab;
    if (_l2 < 1) exitWith { _q distance2D _a };
    private _t = ((((_q vectorDiff _a) vectorDotProduct _ab) / _l2) max 0) min 1;
    (_a vectorAdd (_ab vectorMultiply _t)) distance2D _q
};
// [lines, point, reach] -> [airport index, metres] of the nearest line closer than the reach, or [] when it is clear
NEO_fnc_csOnTaxiLine = {
    params ["_lines", "_p", "_reach"];
    private _hit = [];
    private _best = _reach;
    {
        _x params ["_id", "_ab"];
        private _d = [_p, _ab select 0, _ab select 1] call NEO_fnc_csDistToLine;
        if (_d < _best) then { _best = _d; _hit = [_id, round _d] };
    } forEach _lines;
    _hit
};
// [lines, point] -> the nearest point to it on any of the lines, or [] when there are none
NEO_fnc_csNearestOnLines = {
    params ["_lines", "_p"];
    private _q = [_p select 0, _p select 1, 0];
    private _best = 1e9;
    private _at = [];
    {
        (_x select 1) params ["_a", "_b"];
        private _ab = _b vectorDiff _a;
        private _l2 = _ab vectorDotProduct _ab;
        private _t = if (_l2 < 1) then { 0 } else { ((((_q vectorDiff _a) vectorDotProduct _ab) / _l2) max 0) min 1 };
        private _c = _a vectorAdd (_ab vectorMultiply _t);
        private _d = _c distance2D _q;
        if (_d < _best) then { _best = _d; _at = _c };
    } forEach _lines;
    _at
};
// [vehicle, stand, callsign] -> the stand to use: the one given when it is clear, else the nearest spot off every taxi
// line within 180 m that is flat open ground, away from other support stands, the air commander's stands and anything
// standing there. A stand on a deck or roof, or with no taxi line near it, is left as it is. Each stand chosen is kept
// in NEO_csStands by callsign, so 2 support aircraft never stand on the same spot. A stand that is moved also needs a
// clear way from it to the nearest taxi line, and the aircraft faces down that way: the heading set in the mission is
// for the spot it was placed on, and on RSS7 an A-10 moved 141 m to a spot by the hangars faced a hangar wall and could
// not taxi out (19 Nov). That heading is left on the aircraft as NEO_csStandDir for the caller to use.
// A stand under a roof (a hangar or a helicopter stall) is left as it is: the mission maker put the aircraft there, and
// the search could only move it out into the open. A helicopter lifts straight off, so it only moves when it stands on
// the runway itself, never for a taxi line or the strip beside the runway. No new spot is on a road: aircraft moved out of their stalls were parked on the access roads.
NEO_fnc_csClearStand = {
    params ["_veh", "_stand", ["_callsign", ""]];
    _veh setVariable ["NEO_csStandDir", nil];
    if (!(_stand isEqualType []) || {count _stand < 2}) exitWith { _stand };
    if (count _stand > 2 && {(_stand select 2) >= 1.5}) exitWith { _stand };
    // a roof straight above the stand, up to 25 m
    private _base = AGLToASL [_stand select 0, _stand select 1, 1];
    private _roofed = (lineIntersectsSurfaces [_base, _base vectorAdd [0, 0, 25], _veh, objNull, true, 4, "GEOM", "NONE"]) findIf {
        ((_x select [2, 2]) findIf { !isNull _x && {_x isKindOf "Building"} }) >= 0
    };
    private _heli = _veh isKindOf "Helicopter";
    private _halfOf = {
        (boundingBoxReal _this) params ["_lo", "_hi"];
        ((abs ((_hi select 0) - (_lo select 0))) max (abs ((_hi select 1) - (_lo select 1)))) / 2
    };
    private _half = _veh call _halfOf;
    // room either side of a taxi line for the aircraft that use it to pass, wingtip to wingtip
    private _reach = _half + 20;
    private _lines = if (_heli) then { [] } else { [_stand] call NEO_fnc_csTaxiLines };
    private _taken = missionNamespace getVariable ["NEO_csStands", []];
    _taken = _taken select { !((_x select 2) isEqualTo toUpper _callsign) };
    private _fnc_record = {
        _taken pushBack [_this, _half, toUpper _callsign];
        missionNamespace setVariable ["NEO_csStands", _taken];
        _this
    };
    // and room either side of a runway: the strip kept clear for aircraft taking off and landing, 75 m from the
    // centreline. RSS7's A-10, moved off the taxi route, stood 81 m from Takistan's main runway centreline (19 Nov).
    private _runways = [] call NEO_fnc_csRunwayLines;
    // a helicopter is only in the way standing on the runway itself: Khe Sanh's helicopter revetments sit 48-55 m from
    // the centreline, and every helicopter there was moved out of them (20 Nov)
    private _rwReach = if (_heli) then { _half + 10 } else { _half + 75 };
    private _on = [_lines, _stand, _reach] call NEO_fnc_csOnTaxiLine;
    private _onRw = [_runways, _stand, _rwReach] call NEO_fnc_csOnTaxiLine;
    if (_on isEqualTo [] && {_onRw isEqualTo []}) exitWith { +_stand call _fnc_record };
    if (_roofed >= 0) exitWith {
        ["COMBAT SUPPORT - %1 (%2): its stand at %3 is under a roof, so it stays there", _callsign, typeOf _veh, mapGridPosition _stand] call ALiVE_fnc_dump;
        +_stand call _fnc_record
    };
    private _why = if (_on isEqualTo []) then {
        format ["%1 m from the runway centreline of airport %2", _onRw select 1, _onRw select 0]
    } else {
        format ["%1 m from a taxi route of airport %2", _on select 1, _on select 0]
    };

    // the air commander's stands, from its ledger, when it has placed them by now
    private _ato = [];
    if (!isNil "ALIVE_ATOGlobalRegistry") then {
        private _mods = [ALIVE_ATOGlobalRegistry, "getModules"] call ALIVE_fnc_ATOGlobalRegistry;
        if (!isNil "_mods" && {[_mods] call ALIVE_fnc_isHash}) then {
            {
                private _k = _x getVariable ["ALiVE_mil_ato_kernel", []];
                if ([_k] call ALIVE_fnc_isHash) then {
                    private _ledger = [_k, "ledger", []] call ALIVE_fnc_hashGet;
                    if ([_ledger] call ALIVE_fnc_isHash) then {
                        private _proj = [_ledger, "projection"] call ALIVE_fnc_ATOLedger;
                        if (_proj isEqualType []) then {
                            { private _h = _x param [3, []]; if (_h isEqualType [] && {count _h >= 2} && {(_h distance2D [0, 0]) > 1}) then { _ato pushBack _h } } forEach _proj;
                        };
                    };
                };
            } forEach (_mods select 2);
        };
    };
    private _blockers = ["BUILDING", "HOUSE", "TREE", "SMALL TREE", "WALL", "FENCE", "ROCK", "ROCKS", "BUNKER", "FORTRESS", "FUELSTATION", "TRANSMITTER", "POWER LINES", "CHURCH", "CHAPEL", "LIGHTHOUSE", "VIEW-TOWER"];
    // the way out leads to the nearest taxi line, or the runway at a field with none
    private _wayLines = if (_lines isEqualTo []) then { _runways } else { _lines };
    private _needWay = true;
    private _fnc_clear = {
        params ["_p"];
        if (surfaceIsWater _p) exitWith { false };
        // a road: by its type, since on some maps the airfield's own tarmac is laid as road pieces too
        if (((_p nearRoads (_half max 6)) findIf { ((getRoadInfo _x) select 0) in ["ROAD", "MAIN ROAD", "TRACK"] }) >= 0) exitWith { false };
        if (((surfaceNormal _p) select 2) < 0.985) exitWith { false };
        if !(([_lines, _p, _reach] call NEO_fnc_csOnTaxiLine) isEqualTo []) exitWith { false };
        if !(([_runways, _p, _rwReach] call NEO_fnc_csOnTaxiLine) isEqualTo []) exitWith { false };
        if ((_taken findIf { ((_x select 0) distance2D _p) < (_half + (_x select 1) + 5) }) >= 0) exitWith { false };
        if ((_ato findIf { (_x distance2D _p) < (_half + 20) }) >= 0) exitWith { false };
        if ((vehicles findIf { (_x isKindOf "Air" || {_x isKindOf "LandVehicle"}) && {!(_x isEqualTo _veh)} && {((getPosATL _x) select 2) < 5} && {(_x distance2D _p) < (_half + (_x call _halfOf) + 3)} }) >= 0) exitWith { false };
        if !((nearestTerrainObjects [_p, _blockers, _half, false, true]) isEqualTo []) exitWith { false };
        private _wayOk = true;
        if !((nearestObjects [_p, ["House", "Wall"], _half]) isEqualTo []) exitWith { false };
        // a clear way out: nothing built or grown across the strip a wingspan wide from the nose to the taxi line
        if (_needWay) then {
            private _q = [_wayLines, _p] call NEO_fnc_csNearestOnLines;
            if (_q isEqualTo []) exitWith {};
            private _len = _p distance2D _q;
            private _h = _p getDir _q;
            private _d = _half;
            while { _d < _len && {_wayOk} } do {
                private _s = _p getPos [_d, _h];
                if (!((nearestTerrainObjects [_s, _blockers, _half, false, true]) isEqualTo [])
                    || {!((nearestObjects [_s, ["House", "Wall"], _half]) isEqualTo [])}) then { _wayOk = false };
                _d = _d + 8;
            };
        };
        _wayOk
    };
    private _spot = [];
    // first a spot with a clear way out, then any clear spot
    {
        _needWay = _x;
        private _r = 15;
        while { _spot isEqualTo [] && {_r <= 180} } do {
            private _n = 8 max (ceil ((2 * pi * _r) / 15));
            for "_i" from 0 to (_n - 1) do {
                private _p = _stand getPos [_r, (360 / _n) * _i];
                _p set [2, 0];
                if ([_p] call _fnc_clear) exitWith { _spot = _p };
            };
            _r = _r + 15;
        };
        if (_spot isNotEqualTo []) exitWith {};
    } forEach ([[true, false], [false]] select _heli);
    if (_spot isEqualTo []) exitWith {
        ["COMBAT SUPPORT - %1 (%2): its stand at %3 is %4, and no clear spot was found within 180 m, so it stays there and may be in the way of other aircraft",
            _callsign, typeOf _veh, mapGridPosition _stand, _why] call ALiVE_fnc_dump;
        +_stand call _fnc_record
    };
    private _q = [_wayLines, _spot] call NEO_fnc_csNearestOnLines;
    // a helicopter keeps its heading: it needs no way out
    private _hdg = if (_heli || {_q isEqualTo []}) then { getDir _veh } else { _spot getDir _q };
    _veh setVariable ["NEO_csStandDir", _hdg];
    ["COMBAT SUPPORT - %1 (%2): its stand at %3 was %4, where it would be in the way of other aircraft, so its stand is now %5 m away at %6 (%7), facing %8 towards the taxi route%9",
        _callsign, typeOf _veh, mapGridPosition _stand, _why, round (_spot distance2D _stand), mapGridPosition _spot, [round (_spot select 0), round (_spot select 1)],
        round _hdg, if (_needWay) then { "" } else { " (no spot nearby had a clear way to it)" }] call ALiVE_fnc_dump;
    _spot call _fnc_record
};
// [vehicle, stand, direction] puts an aircraft standing on the ground somewhere else onto its stand: after a load it
// stands where it was saved, and that can be on the taxi route too
NEO_fnc_csToStand = {
    params ["_veh", "_stand", "_dir"];
    if (!alive _veh || {((getPosATL _veh) select 2) > 2} || {(_veh distance2D _stand) <= 3}) exitWith {};
    if (((crew _veh) findIf { isPlayer _x }) >= 0) exitWith {};
    _veh allowDamage false;
    _veh setVelocity [0, 0, 0];
    private _fnc_put = {
        // moved first and turned after, as the hold does: turned first, a crewed RHS A-10 ignored the move and
        // stayed where it was (19 Nov)
        _veh setPosATL [_stand select 0, _stand select 1, 0];
        _veh setDir _dir;
        _veh setVectorUp [0, 0, 1];
        _veh setVelocity [0, 0, 0];
    };
    call _fnc_put;
    // In its first seconds a freshly crewed aircraft can be set back where it stood, once, after a move: RSS7's
    // A-10 was back on its old spot 2 s after each early move, and every later move held. Watched for 30 s and put
    // back on its stand while it is untasked, on the ground and has no player aboard.
    [_veh, _stand, _dir, _fnc_put] spawn {
        params ["_veh", "_stand", "_dir", "_fnc_put"];
        private _said = false;
        private _until = time + 30;
        while { time < _until && {alive _veh} } do {
            sleep 0.5;
            private _off = _veh distance2D _stand;
            if (_off > 3 && {((getPosATL _veh) select 2) < 2} && {((crew _veh) findIf { isPlayer _x }) < 0}
                && {(_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo []}) then {
                call _fnc_put;
                if (!_said) then {
                    _said = true;
                    ["COMBAT SUPPORT - %1 was set back %2 m from its stand just after it was moved there, so it was put on it again", typeOf _veh, round _off] call ALiVE_fnc_dump;
                };
            };
        };
        _veh allowDamage true;
    };
};
// A CAS plane parked where the game's own AI treats it as lined up for take-off (the start of a runway, facing down it)
// starts up and takes off by itself before it has been given anything to do: two F-100Ds parked at the start of the
// Khe Sanh SF strip were airborne 15 s into the mission, and side by side they met on the runway. Combat Support had not
// tasked them, so it showed them waiting at home and offered no RTB. This watches a plane while it has no task: the
// moment it starts its engine or rolls on the ground, it is put back on its stand and held there with an empty tank, the
// one thing that keeps a crewed jet still (the air commander holds its parked jets the same way). What was in the tank is
// kept on the plane (NEO_casHeldFuel) and the next task gives it back (cas.fsm, state "_"); the crew stays aboard.
NEO_fnc_casHoldWhenParked = {
    params ["_veh", "_callsign", "_dir"];
    if (!(_veh isKindOf "Plane") || {unitIsUAV _veh}) exitWith {};
    private _said = false;
    while { alive _veh } do {
        sleep 1;
        if ((_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo []) then {
            private _kept = _veh getVariable ["NEO_casHeldFuel", -1];
            if (_kept >= 0) then {
                // refuelled while held (a resupply truck): keep the larger figure and empty it again
                if (fuel _veh > 0) then {
                    _veh setVariable ["NEO_casHeldFuel", _kept max (fuel _veh), true];
                    _veh setFuel 0;
                };
            } else {
                if (isTouchingGround _veh && {((getPos _veh) select 2) < 2} && {isEngineOn _veh || {(abs speed _veh) > 2}}) then {
                    _veh setVariable ["NEO_casHeldFuel", fuel _veh, true];
                    _veh allowCrewInImmobile true;
                    _veh setFuel 0;
                    _veh engineOn false;
                    _veh setVelocity [0, 0, 0];
                    private _stand = _veh getVariable ["ALIVE_CombatSupport_Base", []];
                    if (_stand isEqualType [] && {count _stand >= 2} && {(_veh distance2D _stand) > 3}) then {
                        _veh allowDamage false;
                        _veh setPosATL [_stand select 0, _stand select 1, 0];
                        _veh setDir _dir;
                        _veh setVectorUp [0, 0, 1];
                        _veh setVelocity [0, 0, 0];
                        [_veh] spawn { sleep 3; (_this select 0) allowDamage true; };
                    };
                    if (!_said) then {
                        _said = true;
                        ["COMBAT SUPPORT - %1 (%2) started up by itself where it is parked, most likely at the start of a runway, where the game treats it as lined up for take-off. It is held on its stand until it is given a task. Parking it away from the start of the runway avoids this.",
                            _callsign, typeOf _veh] call ALiVE_fnc_dump;
                    };
                };
            };
        };
    };
};

// A CAS plane tasked while on the ground taxis out by itself, but only from a spot the game's AI can join the
// airfield's take-off route from: one parked in a row on an apron (RSS7's A-10 between two other airframes) sat with its
// engine running and never moved. Watched from the task: no 40 m of movement in 75 s, or not airborne in 4 min, and it is
// put at the start of the nearest runway lined up for take-off. With anything on the take-off roll (a vehicle, a wreck)
// it is put in the air over the far end of the runway instead. Either way it then carries on with its task (Jman, 17 Nov:
// "If it cannot taxi then teleport it").
NEO_fnc_casTakeoffWatch = {
    params ["_veh", "_callsign"];
    // A drone gets the watch too: one tasked behind a parked plane had no way out at all (19 Nov). One a player is
    // flying from a UAV terminal is left to that player. The server sees that through UAVControl only: isUAVConnected
    // stays false there for a remote player's terminal, and a terminal merely connected shows nothing at all.
    private _flown = { unitIsUAV _veh && {!isNull ((UAVControl _veh) param [0, objNull])} };
    if (!(_veh isKindOf "Plane") || {call _flown} || {_veh getVariable ["NEO_casTakeoffWatch", false]}) exitWith {};
    _veh setVariable ["NEO_casTakeoffWatch", true];
    private _from = getPosATL _veh;
    private _task = _veh getVariable ["NEO_radioCurrentTask", []];
    private _t0 = time;
    private _same = { (_veh getVariable ["NEO_radioCurrentTask", []]) isEqualTo _task };
    private _up = { ((getPosATL _veh) select 2) > 10 && {!isTouchingGround _veh} };
    waitUntil {
        sleep 2;
        !alive _veh || {call _up} || {!(call _same)} || {call _flown}
            || {(time - _t0) > 75 && {(_veh distance2D _from) < 40}} || {(time - _t0) > 240}
    };
    _veh setVariable ["NEO_casTakeoffWatch", nil];
    if (!alive _veh || {call _up} || {!(call _same)} || {call _flown} || {_task isEqualTo []} || {(_task param [0, ""]) == "RTB"}) exitWith {};

    // the nearest runway: the world's main airfield or one of its secondary ones
    private _cfg = configFile >> "CfgWorlds" >> worldName;
    private _best = configNull;
    private _bestD = 1e10;
    {
        private _p = getArray (_x >> "ilsPosition");
        if (count _p >= 2 && {count getArray (_x >> "ilsDirection") >= 3}) then {
            private _d = _veh distance2D [_p select 0, _p select 1];
            if (_d < _bestD) then { _bestD = _d; _best = _x };
        };
    } forEach ([_cfg] + configProperties [_cfg >> "SecondaryAirports", "isClass _x", true]);
    if (isNull _best || {_bestD > 3000}) exitWith {
        ["COMBAT SUPPORT - %1 (%2) has not taken off %3 s after its task and there is no runway within 3 km to put it on", _callsign, typeOf _veh, round (time - _t0)] call ALiVE_fnc_dump;
    };
    private _ils = getArray (_best >> "ilsPosition");
    private _dirV = getArray (_best >> "ilsDirection");
    // ilsDirection points back out along the approach, so the take-off run is the other way
    private _hdg = (-(_dirV select 0)) atan2 (-(_dirV select 2));
    private _start = [_ils select 0, _ils select 1, 0];

    // the take-off roll, 800 m from the threshold: anything on it, a wreck included, and the ground start is no good
    private _blocker = objNull;
    for "_m" from 0 to 800 step 40 do {
        private _pt = _start getPos [_m, _hdg];
        private _near = (nearestObjects [_pt, ["Air", "LandVehicle", "Ship", "Wreck_base", "Wreck_base_F"], 25]) - [_veh];
        if (count _near > 0) exitWith { _blocker = _near select 0 };
    };

    private _moved = round (_veh distance2D _from);
    private _waited = round (time - _t0);
    _veh allowDamage false;
    _veh setVelocity [0, 0, 0];
    if (isNull _blocker) then {
        _veh setDir _hdg;
        _veh setPosATL _start;
        _veh setVectorUp (surfaceNormal _start);
        _veh setVelocity [0, 0, 0];
        _veh engineOn true;
        ["COMBAT SUPPORT - %1 (%2) did not get airborne (%3 s, %4 m moved), so it was put at the start of the runway at %5, lined up for take-off",
            _callsign, typeOf _veh, _waited, _moved, mapGridPosition _start] call ALiVE_fnc_dump;
    } else {
        private _air = _start getPos [2000, _hdg];
        _air set [2, 300];
        private _speed = ((getNumber (configFile >> "CfgVehicles" >> typeOf _veh >> "maxSpeed")) / 3.6 * 0.5) max 70;
        _veh setDir _hdg;
        _veh setPosATL _air;
        _veh engineOn true;
        _veh setVelocityModelSpace [0, _speed, 0];
        ["COMBAT SUPPORT - %1 (%2) did not get airborne (%3 s, %4 m moved) and the runway's take-off roll is blocked by %5 at %6, so it was put in the air over the far end of the runway",
            _callsign, typeOf _veh, _waited, _moved, typeOf _blocker, mapGridPosition _blocker] call ALiVE_fnc_dump;
    };
    [_veh] spawn { sleep 5; (_this select 0) allowDamage true };
};

//----------------------
//UI
//----------------------
NEO_fnc_radioOnLoad = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnLoad.sqf";
NEO_fnc_radioOnUnload = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioOnUnload.sqf";
NEO_fnc_radioLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioLbSelChanged.sqf";
NEO_fnc_radioMapEvent = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioMapEvent.sqf";
NEO_fnc_radioGridSetButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioGridSetButton.sqf";
NEO_fnc_radioRefreshUi = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioRefreshUi.sqf";
NEO_fnc_mapRestoreView = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_mapRestoreView.sqf";
NEO_fnc_mapControlSwap = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_mapControlSwap.sqf";
NEO_fnc_radioSetTerrainMode = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\fn_radioSetTerrainMode.sqf";

//Transport
NEO_fnc_transportUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportUnitLbSelChanged.sqf";
NEO_fnc_transportTaskLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportTaskLbSelChanged.sqf";
NEO_fnc_transportConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportConfirmButton.sqf";
NEO_fnc_transportConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportConfirmButtonEnable.sqf";
NEO_fnc_transportBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportBaseButton.sqf";
NEO_fnc_transportSmokeFoundButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportSmokeFoundButton.sqf";
NEO_fnc_transportSmokeNotFoundButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportSmokeNotFoundButton.sqf";
NEO_fnc_radioTransportOnComboCurSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\transport\fn_transportOnComboCurSelChanged.sqf";

//CAS
NEO_fnc_casUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casUnitLbSelChanged.sqf";
NEO_fnc_casTaskLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casTaskLbSelChanged.sqf";
NEO_fnc_casConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casConfirmButton.sqf";
NEO_fnc_casBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casBaseButton.sqf";
NEO_fnc_casConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\cas\fn_casConfirmButtonEnable.sqf";
NEO_fnc_pickCasTarget = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_pickCasTarget.sqf";
NEO_fnc_casScriptedAttack = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casScriptedAttack.sqf";
NEO_fnc_casRearmService = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casRearmService.sqf";
NEO_fnc_disableOtherWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_disableOtherWeapons.sqf";
NEO_fnc_reenableWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_reenableWeapons.sqf";
NEO_fnc_casWeaponFamily = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casWeaponFamily.sqf";
NEO_fnc_casUsableWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casUsableWeapons.sqf";
NEO_fnc_casNextWeapon = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casNextWeapon.sqf";
NEO_fnc_casWeaponAmmo = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casWeaponAmmo.sqf";
NEO_fnc_casPrepareWeapons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_casPrepareWeapons.sqf";

//ARTY
NEO_fnc_artyUnitLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyUnitLbSelChanged.sqf";
NEO_fnc_artyConfirmButtonEnable = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyConfirmButtonEnable.sqf";
NEO_fnc_artyConfirmButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyConfirmButton.sqf";
NEO_fnc_artyMoveButtons = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyMoveButtons.sqf";
NEO_fnc_artyBaseButton = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyBaseButton.sqf";
NEO_fnc_artyOrdLbSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyOrdLbSelChanged.sqf";
NEO_fnc_artyDispersionOnSliderPosChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyDispersionOnSliderPosChanged.sqf";
NEO_fnc_artyRateDelayOnSliderPosChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyRateDelayOnSliderPosChanged.sqf";
NEO_fnc_artyRateOfFireLbOnSelChanged = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyRateOfFireLbOnSelChanged.sqf";
// Commander's guns (F509): the AI Commander's batteries on the tablet's Artillery list
NEO_fnc_artyCmdrBoard = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_artyCmdrBoard.sqf";
NEO_fnc_artyCmdrUnitSelected = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyCmdrUnitSelected.sqf";
NEO_fnc_artyCmdrConfirm = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\ui\arty\fn_artyCmdrConfirm.sqf";
ALIVE_fnc_ExecuteMission = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_ExecuteMission.sqf";
ALIVE_fnc_GetMagazineType = compile preprocessFileLineNumbers "x\alive\addons\sup_combatsupport\scripts\NEO_radio\functions\misc\fn_GetMagazineType.sqf";
