#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(buildAirsideCache);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_buildAirsideCache

Description:
    Reduces every airfield on the terrain to cached arithmetic, once, so that
    asking "is this position on airfield surface" later costs no engine query.

    Runs on the server, spreads its work one airfield per frame, and broadcasts
    the result. Everything it produces is consumed by ALiVE_fnc_isAirside,
    ALiVE_fnc_airsideClear and ALiVE_fnc_airsideLegBypass.

    WHAT IT PRODUCES

    ALiVE_airsideBounds    flat, stride 4 per airfield: cx, cy, radius, radius^2
    ALiVE_airsideCapsules  element i is a flat stride 8 array for airfield i:
                           ax, ay, bx, by, radius, radius^2, 1/len^2, kind

    Kinds are 1 runway and its approach strips, 2 taxiway, 3 parking. Callers
    choose which ones apply: a garrison must not sit on a runway but may sit
    beside a taxiway, and a convoy may cross a taxiway but should not drive
    down the runway.

    WHAT IT CANNOT DO

    Nothing in Arma marks an aircraft parking area. Runways and taxiways can be
    found from terrain objects and config; parking has to be inferred, from the
    far end of a taxi route, from hangars and from helipads. On some terrains
    that finds nothing at all. The build logs exactly what each airfield yielded
    so the gaps are visible in the RPT rather than assumed away.

    Missions wanting exact parking can tag objects themselves with
    ALiVE_parking, the same way ALiVE_runway and ALiVE_taxiway already work.
    That is the only source here that is authored rather than guessed.

    A terrain with no airfield leaves both globals empty, and every consumer
    then short-circuits on a single array comparison forever.

Parameters:
    None.

Returns:
    Nothing. Sets and broadcasts ALiVE_airsideBounds and ALiVE_airsideCapsules.

Examples:
    (begin example)
    [] call ALiVE_fnc_buildAirsideCache;
    (end)

See Also:
    ALiVE_fnc_isAirside, ALiVE_fnc_airsideClear, ALiVE_fnc_airsideLegBypass,
    ALiVE_fnc_getAirfieldGeometry, ALiVE_fnc_getRunwayCentreline

Author:
    Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
// Guards against a second call racing the first. It is cleared on both the
// success and the no-candidates paths, but a run that dies partway leaves it
// set, so say so rather than exiting silently.
if (!isNil "ALiVE_airsideCacheBuilding") exitWith {
    diag_log "ALiVE airside: build already in progress or left flagged by a failed run, skipping";
};
ALiVE_airsideCacheBuilding = true;

// Tunables, all named so a mission can override them from init.sqf without a
// rebuild. Every one of these is reasoned rather than measured, so they are
// meant to be adjusted once there is evidence from a real terrain.
if (isNil "ALiVE_airsideThresholdLength") then { ALiVE_airsideThresholdLength = 300 };
if (isNil "ALiVE_airsideRunwayMargin")    then { ALiVE_airsideRunwayMargin = 25 };
if (isNil "ALiVE_airsideMaxCapsules")     then { ALiVE_airsideMaxCapsules = 48 };
if (isNil "ALiVE_airsideSearchRadius")    then { ALiVE_airsideSearchRadius = 1500 };

private _dbg = ["ALiVE_airsideDebug", false] call BIS_fnc_getParamValue;
if (isNil "ALiVE_airsideDebug") then { ALiVE_airsideDebug = false };

// ------------------------------------------------------------------------
// Candidate airfields. All cheap config and location reads, no object sweeps
// yet. Being generous here is fine: a candidate that turns out to have no
// runway simply contributes nothing.
// ------------------------------------------------------------------------
private _candidates = [];

private _fnc_addCandidate = {
    params ["_pos"];
    if (count _pos < 2) exitWith {};
    private _p = [_pos select 0, _pos select 1, 0];
    // 600 m dedupe. Two config entries for the same field are common, and
    // building it twice would double every object sweep.
    if ((_candidates findIf {(_x distance2D _p) < 600}) < 0) then {
        _candidates pushBack _p;
    };
};

private _world = configFile >> "CfgWorlds" >> worldName;

private _fnc_readAirportCfg = {
    params ["_cfg"];
    private _ils = getArray (_cfg >> "ilsPosition");
    if (count _ils >= 2) then { [_ils] call _fnc_addCandidate };
};

[_world] call _fnc_readAirportCfg;
{
    [_x] call _fnc_readAirportCfg;
} forEach ("true" configClasses (_world >> "SecondaryAirports"));

// Named airport locations. The type list is checked against config first,
// because nearestLocations throws a config error popup for a location type that
// does not exist, and which types a game version or a terrain actually declares
// is not something to assume. Anything unrecognised is simply dropped.
private _locTypes = ["Airport", "NameAirportArea"] select {
    isClass (configFile >> "CfgLocationTypes" >> _x)
};
if (count _locTypes > 0) then {
    {
        [position _x] call _fnc_addCandidate;
    } forEach (nearestLocations [[worldSize / 2, worldSize / 2, 0], _locTypes, worldSize]);
};

// Runways a mission author defined on a MACC module, which is the only source
// here that is guaranteed correct for the terrain it was authored on.
{
    private _rw = _x getVariable ["runway", []];
    if (_rw isEqualType [] && {count _rw >= 2}) then {
        [_rw select 0] call _fnc_addCandidate;
    };
} forEach (entities "ALiVE_mil_ATO");

if (count _candidates == 0) exitWith {
    ALiVE_airsideBounds = [];
    ALiVE_airsideCapsules = [];
    publicVariable "ALiVE_airsideBounds";
    publicVariable "ALiVE_airsideCapsules";
    ALiVE_airsideCacheBuilding = nil;
    ["ALiVE airside: no airfield candidates on %1, exclusion disabled", worldName] call ALiVE_fnc_dump;
};

// ------------------------------------------------------------------------
// Build, one airfield per frame.
// ------------------------------------------------------------------------
private _fnc_pushCapsule = {
    params ["_arr", "_a", "_b", "_r", "_kind"];
    private _ax = _a select 0;  private _ay = _a select 1;
    private _bx = _b select 0;  private _by = _b select 1;
    private _vx = _bx - _ax;    private _vy = _by - _ay;
    private _len2 = (_vx * _vx) + (_vy * _vy);
    // Inverse squared length is precomputed so the query side never divides.
    // A degenerate capsule stores 0 and collapses to a disc.
    private _inv = if (_len2 > 0.0001) then { 1 / _len2 } else { 0 };
    _arr append [_ax, _ay, _bx, _by, _r, (_r * _r), _inv, _kind];
};

// Build one airfield and push its capsules onto the shared accumulators. Called
// once per frame from the per-frame handler below, one airfield at a time.
private _fnc_buildOne = {
        params ["_centre", "_bounds", "_allCaps", "_fnc_pushCapsule"];
        private _caps = [];
        private _gotRunway = false;
        private _nTaxi = 0;
        private _nPark = 0;

        // One geometry call per airfield. It is the expensive part, two
        // unfiltered object sweeps plus a location query, and calling
        // getRunwayCentreline as well would silently double that because it
        // calls this same function internally.
        private _geom = [_centre, ALiVE_airsideSearchRadius] call ALiVE_fnc_getAirfieldGeometry;
        _geom params [["_runways", []], ["_taxiways", []]];

        // ----------------------------------------------------------------
        // Runway axis. Best available source wins.
        // ----------------------------------------------------------------
        private _rwA = [];
        private _rwB = [];
        private _rwHalf = 15;

        // An authored or tagged segment with real length is already an axis.
        {
            _x params ["_s", "_e", ["_hw", 12]];
            if ((_s distance2D _e) > 200) exitWith {
                _rwA = _s; _rwB = _e; _rwHalf = _hw;
            };
        } forEach _runways;

        // Otherwise synthesise one from the ILS touchdown point and heading.
        if (_rwA isEqualTo []) then {
            private _bestCfg = configNull;
            private _bestD = 1e9;
            private _world = configFile >> "CfgWorlds" >> worldName;
            {
                private _ils = getArray (_x >> "ilsPosition");
                if (count _ils >= 2) then {
                    private _d = _centre distance2D [_ils select 0, _ils select 1, 0];
                    if (_d < _bestD) then { _bestD = _d; _bestCfg = _x };
                };
            } forEach ([_world] + ("true" configClasses (_world >> "SecondaryAirports")));

            if (!isNull _bestCfg && {_bestD < 1200}) then {
                private _ils = getArray (_bestCfg >> "ilsPosition");
                private _dir = getArray (_bestCfg >> "ilsDirection");
                if (count _dir >= 3) then {
                    private _p = [_ils select 0, _ils select 1, 0];
                    // ilsDirection is a vector along the approach. The touchdown
                    // point sits near one end, so lay the axis out ahead of it.
                    private _ux = _dir select 0;
                    private _uy = _dir select 2;
                    private _ul = sqrt ((_ux * _ux) + (_uy * _uy));
                    if (_ul > 0.01) then {
                        _rwA = _p;
                        _rwB = [(_p select 0) + (_ux / _ul * 1200), (_p select 1) + (_uy / _ul * 1200), 0];
                    };
                };
            };
        };

        // Last resort, fit a line through whatever runway pieces were found.
        // Same farthest pair approach and same 200 m minimum span that
        // getRunwayCentreline uses, duplicated here to avoid a second sweep.
        if (_rwA isEqualTo [] && {count _runways > 1}) then {
            private _pts = [];
            { _pts pushBack (_x select 0); _pts pushBack (_x select 1); } forEach _runways;
            private _bestSpan = 0;
            {
                private _p = _x;
                private _pi = _forEachIndex;
                {
                    if (_forEachIndex > _pi) then {
                        private _d = _p distance2D _x;
                        if (_d > _bestSpan) then { _bestSpan = _d; _rwA = _p; _rwB = _x; };
                    };
                } forEach _pts;
            } forEach _pts;
            if (_bestSpan < 200) then { _rwA = []; _rwB = []; };
        };

        if !(_rwA isEqualTo []) then {
            _gotRunway = true;
            private _r = _rwHalf + ALiVE_airsideRunwayMargin;
            [_caps, _rwA, _rwB, _r, 1] call _fnc_pushCapsule;

            // Approach and departure strips, laid off each end along the axis.
            // Aircraft are lowest and slowest here, and it is the one part of
            // an airfield with no physical marking to keep traffic off it.
            private _vx = (_rwB select 0) - (_rwA select 0);
            private _vy = (_rwB select 1) - (_rwA select 1);
            private _vl = sqrt ((_vx * _vx) + (_vy * _vy));
            if (_vl > 0.01) then {
                private _ux = _vx / _vl;  private _uy = _vy / _vl;
                private _t = ALiVE_airsideThresholdLength;
                [_caps, _rwA, [(_rwA select 0) - (_ux * _t), (_rwA select 1) - (_uy * _t), 0], _r, 1] call _fnc_pushCapsule;
                [_caps, _rwB, [(_rwB select 0) + (_ux * _t), (_rwB select 1) + (_uy * _t), 0], _r, 1] call _fnc_pushCapsule;
            };
        };

        // ----------------------------------------------------------------
        // Taxiways.
        // ----------------------------------------------------------------
        {
            _x params ["_s", "_e", ["_hw", 4]];
            [_caps, _s, _e, (_hw max 12), 2] call _fnc_pushCapsule;
            _nTaxi = _nTaxi + 1;
        } forEach _taxiways;

        // ILS taxi routes, as consecutive vertex pairs. These are authored
        // config polylines, so where a terrain has them they are the most
        // reliable taxiway data available.
        private _taxiTails = [];
        private _world2 = configFile >> "CfgWorlds" >> worldName;
        {
            private _cfg = _x;
            {
                private _poly = getArray (_cfg >> _x);
                if (count _poly >= 4) then {
                    private _verts = [];
                    for "_k" from 0 to (count _poly - 2) step 2 do {
                        _verts pushBack [_poly select _k, _poly select (_k + 1), 0];
                    };
                    if ((_centre distance2D (_verts select 0)) < (ALiVE_airsideSearchRadius * 1.5)) then {
                        for "_k" from 0 to (count _verts - 2) do {
                            [_caps, _verts select _k, _verts select (_k + 1), 12, 2] call _fnc_pushCapsule;
                            _nTaxi = _nTaxi + 1;
                        };
                        // The far end of a taxi route is where aircraft are
                        // going, which is the best hint at parking that config
                        // offers. Recorded, not trusted: on some terrains this
                        // is the runway hold point instead.
                        _taxiTails pushBack (_verts select (count _verts - 1));
                    };
                };
            } forEach ["ilsTaxiIn", "ilsTaxiOff"];
        } forEach ([_world2] + ("true" configClasses (_world2 >> "SecondaryAirports")));

        // ----------------------------------------------------------------
        // Parking. Inferred, because nothing in the game data declares it.
        // ----------------------------------------------------------------

        // Authored tags first. This is the only exact source, and it mirrors
        // the ALiVE_runway and ALiVE_taxiway convention already in use.
        private _near = nearestObjects [_centre, [], ALiVE_airsideSearchRadius];
        {
            if (_x getVariable ["ALiVE_parking", false]) then {
                private _r = _x getVariable ["ALiVE_parkingRadius", 30];
                private _p = position _x;
                [_caps, _p, _p, _r, 3] call _fnc_pushCapsule;
                _nPark = _nPark + 1;
            };
        } forEach _near;

        { [_caps, _x, _x, 45, 3] call _fnc_pushCapsule; _nPark = _nPark + 1; } forEach _taxiTails;

        // Hangars and helipads. An aircraft parked at either is a thing ground
        // traffic should not drive through. Matched on name rather than a fixed
        // class list, because a hardcoded classname that does not exist fails
        // silently and would leave a coverage claim that is simply untrue.
        {
            private _t = toLower (typeOf _x);
            private _isHangar = (_t find "hangar") > -1 || {(_t find "hanger") > -1};
            private _isPad = (_t find "helipad") > -1 || {(_t find "helih") > -1};
            if (_isHangar || _isPad) then {
                private _p = position _x;
                [_caps, _p, _p, (if (_isHangar) then {30} else {15}), 3] call _fnc_pushCapsule;
                _nPark = _nPark + 1;
            };
        } forEach _near;

        // ----------------------------------------------------------------
        // Trim and pack.
        // ----------------------------------------------------------------
        // Terrain runway and taxiway pieces arrive as one object each, so a
        // single field can produce hundreds of near-identical discs. This is
        // the pathfinder's inner loop, so collapse them on a coarse grid and
        // then cap what survives.
        private _seen = [];
        private _packed = [];
        private _capCount = (count _caps) / 8;
        for "_j" from 0 to (_capCount - 1) do {
            private _c = _j * 8;
            private _key = format ["%1_%2_%3_%4",
                round ((_caps select _c) / 25),
                round ((_caps select (_c + 1)) / 25),
                round ((_caps select (_c + 2)) / 25),
                round ((_caps select (_c + 3)) / 25)];
            if !(_key in _seen) then {
                _seen pushBack _key;
                _packed append (_caps select [_c, 8]);
            };
        };

        private _packedCount = (count _packed) / 8;
        private _truncated = 0;
        if (_packedCount > ALiVE_airsideMaxCapsules) then {
            _truncated = _packedCount - ALiVE_airsideMaxCapsules;
            _packed resize (ALiVE_airsideMaxCapsules * 8);
            _packedCount = ALiVE_airsideMaxCapsules;
        };

        if (_packedCount > 0) then {
            // Bounding circle over every capsule endpoint plus the widest
            // radius. This is what lets a query reject a whole airfield in five
            // operations, so it must genuinely contain everything.
            private _minX = 1e12; private _maxX = -1e12;
            private _minY = 1e12; private _maxY = -1e12;
            private _maxR = 0;
            for "_j" from 0 to (_packedCount - 1) do {
                private _c = _j * 8;
                {
                    private _px = _packed select (_c + (_x * 2));
                    private _py = _packed select (_c + (_x * 2) + 1);
                    if (_px < _minX) then {_minX = _px}; if (_px > _maxX) then {_maxX = _px};
                    if (_py < _minY) then {_minY = _py}; if (_py > _maxY) then {_maxY = _py};
                } forEach [0, 1];
                private _r = _packed select (_c + 4);
                if (_r > _maxR) then {_maxR = _r};
            };
            private _cx = (_minX + _maxX) / 2;
            private _cy = (_minY + _maxY) / 2;
            private _br = (sqrt ((((_maxX - _minX) / 2) ^ 2) + (((_maxY - _minY) / 2) ^ 2))) + _maxR + 5;

            _bounds append [_cx, _cy, _br, (_br * _br)];
            _allCaps pushBack _packed;

            // The only way a terrain-dependent gap becomes visible. Parking in
            // particular is inferred and will be empty on some maps.
            ["ALiVE airside: field at %1 -- runway=%2 taxiway=%3 parking=%4 capsules=%5%6 radius=%7m",
                [round _cx, round _cy], _gotRunway, _nTaxi, _nPark, _packedCount,
                (if (_truncated > 0) then { format [" (dropped %1)", _truncated] } else { "" }),
                round _br] call ALiVE_fnc_dump;
        } else {
            ["ALiVE airside: field at %1 yielded nothing, skipped", [round (_centre select 0), round (_centre select 1)]] call ALiVE_fnc_dump;
        };

};

// Drive the build one airfield per frame, in the unscheduled environment. A
// spawn would sit in the scheduler queue behind everything else initialising at
// mission start and not run for a minute or more, which was measured at ~110s
// on the first attempt. A per-frame handler is immune to that starvation and
// still spreads the object sweeps across frames, so the exclusion data is ready
// almost immediately rather than two minutes in.
private _bounds = [];
private _allCaps = [];
private _idxRef = [0];

[{
    params ["_args", "_handle"];
    _args params ["_candidates", "_idxRef", "_bounds", "_allCaps", "_fnc_buildOne", "_fnc_pushCapsule"];
    private _idx = _idxRef select 0;

    if (_idx >= count _candidates) exitWith {
        ALiVE_airsideBounds = _bounds;
        ALiVE_airsideCapsules = _allCaps;
        publicVariable "ALiVE_airsideBounds";
        publicVariable "ALiVE_airsideCapsules";
        ALiVE_airsideCacheBuilding = nil;
        ["ALiVE airside: cache ready, %1 airfield(s) on %2", (count _bounds) / 4, worldName] call ALiVE_fnc_dump;
        _handle call CBA_fnc_removePerFrameHandler;
    };

    [_candidates select _idx, _bounds, _allCaps, _fnc_pushCapsule] call _fnc_buildOne;
    _idxRef set [0, _idx + 1];
}, 0, [_candidates, _idxRef, _bounds, _allCaps, _fnc_buildOne, _fnc_pushCapsule]] call CBA_fnc_addPerFrameHandler;
