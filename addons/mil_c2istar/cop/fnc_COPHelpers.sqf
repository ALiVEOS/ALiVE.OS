#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPHelpers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPHelpers

Description:
    Declares 18 pure helper globals used across COP server, client, and
    render code. Running this function seeds the following globals on
    missionNamespace:

      ALIVE_fnc_COPGetSideKey         — side enum → "WEST"/"EAST"/"GUER"
      ALIVE_fnc_COPGetSideFromKey     — inverse
      ALIVE_fnc_COPGetSideColor       — side key → RGBA
      ALIVE_fnc_COPGetIconPath        — side key + type → NATO marker texture path
      ALIVE_fnc_COPTypeFromProfile    — ALiVE profile → internal type string
      ALIVE_fnc_COPDominantType       — pick highest-threat type from list
      ALIVE_fnc_COPSizeIndicator      — profile count → NATO size string
      ALIVE_fnc_COPFactionShortCode   — faction classname → display short code
                                        (consults ALIVE_COP_FACTION_CODES_OVERRIDES
                                         first, then bundled defaults, then falls
                                         back to prefix-strip)
      ALIVE_fnc_COPGetLocationName    — world pos → nearest location name
                                        (cached 50 m buckets)
      ALIVE_fnc_COPGetActivityFromState — OPCOM state string → A/D/M/G/R letter
      ALIVE_fnc_COPGetActivityColor   — activity letter → RGBA
      ALIVE_fnc_COPClusterByGrid      — array of contacts → array of grid-bucket
                                        clusters
      ALIVE_fnc_COPClusterCenter      — cluster → average position
      ALIVE_fnc_COPHashArray          — array → stable hash string (rounds
                                        positions to 10 m to ignore jitter)
      ALIVE_fnc_COPAgeAlpha           — age seconds → alpha multiplier (fade)
      ALIVE_fnc_COPConfidenceStyle    — age seconds → "solid"/"dashed"/"dotted"
      ALIVE_fnc_COPIsThreat           — type string → threat-list membership
      ALIVE_fnc_COPBroadcastIfChanged — hash-diff + publicVariable gate

    Idempotent: re-invoking this function simply re-assigns the helper globals
    with no side effect beyond that. Call once per machine during module init.

Parameters:
    (none)

Returns:
    BOOL - true after globals are seeded.

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPHelpers - input",_this);

// ============================================================================
// Side/side-key conversion
// ============================================================================

ALIVE_fnc_COPGetSideKey = {
    params [["_side", sideUnknown, [west]]];
    switch (_side) do {
        case west:        { "WEST" };
        case east:        { "EAST" };
        case independent: { "GUER" };
        default           { "UNKNOWN" };
    };
};

ALIVE_fnc_COPGetSideFromKey = {
    params [["_key", "", [""]]];
    switch (toUpper _key) do {
        case "WEST":        { west };
        case "EAST":        { east };
        case "GUER":        { independent };
        case "INDEPENDENT": { independent };
        default             { sideUnknown };
    };
};

ALIVE_fnc_COPGetSideColor = {
    params [["_sideKey", "", [""]]];
    switch (toUpper _sideKey) do {
        case "WEST": { ALIVE_COP_COLOR_BLUFOR };
        case "EAST": { ALIVE_COP_COLOR_OPFOR };
        case "GUER": { ALIVE_COP_COLOR_INDEP };
        default      { [1, 1, 1, 1] };
    };
};

// ============================================================================
// NATO icon path (cached by side+type key)
// ============================================================================

ALIVE_fnc_COPGetIconPath = {
    params [["_sideKey", "", [""]], ["_type", "infantry", [""]]];

    // Fast cache path — avoids switch+format per call after first hit.
    private _cacheKey = _sideKey + "_" + _type;
    private _cached = ALIVE_COP_ICON_CACHE getOrDefault [_cacheKey, ""];
    if (_cached != "") exitWith { _cached };

    // APP-6 / MIL-STD-2525 affiliation prefix.
    // b = friend (rectangle), o = hostile (diamond), n = neutral (square),
    // u = unknown (quatrefoil). Default → u so an unresolved side renders
    // as the doctrinally correct unknown frame, not mislabelled as neutral.
    private _prefix = switch (toUpper _sideKey) do {
        case "WEST": { "b" };
        case "EAST": { "o" };
        case "GUER": { "n" };
        default      { "u" };
    };

    // Internal type → Arma's NATO icon suffix
    private _suffix = switch (toLower _type) do {
        case "infantry":   { "inf" };
        case "motor":      { "motor_inf" };
        case "motorized":  { "motor_inf" };
        case "mech":       { "mech_inf" };
        case "mechanized": { "mech_inf" };
        case "recon":      { "recon" };
        case "armor":      { "armor" };
        case "armored":    { "armor" };
        case "art":        { "art" };
        case "artillery":  { "art" };
        case "at":         { "at" };
        case "aa":         { "aa" };
        case "air":        { "air" };
        case "helicopter": { "air" };
        case "plane":      { "plane" };
        case "uav":        { "uav" };
        case "naval":      { "naval" };
        case "med":        { "med" };
        case "hq":         { "hq" };
        default            { "unknown" };
    };

    private _path = format [ALIVE_COP_NATO_PATH_TEMPLATE, _prefix, _suffix];
    ALIVE_COP_ICON_CACHE set [_cacheKey, _path];
    _path
};

// ============================================================================
// Profile → internal type classification (cached by classname)
//
// Reads ALiVE profile tuple at `select 2`:
//   index 5 = type ("entity" / "vehicle")
//   index 8 = vehicles-in-command-of array
// Defensive count guards preserved for schema drift resilience.
// ============================================================================

ALIVE_fnc_COPTypeFromProfile = {
    params [["_profile", [], [[]]]];

    if (count _profile == 0) exitWith { "unknown" };

    private _entityType = "unknown";
    // _vehicleIDs are profile IDs (strings like "VEH_42") stored at
    // entity-profile select 2 select 8 (vehiclesInCommandOf). They are NOT
    // engine classnames — each ID has to be resolved through the profile
    // handler to read the actual vehicleClass field on the vehicle profile.
    // Prior versions treated these as classnames directly, which made every
    // isKindOf check below fall through to the "infantry" fallback for any
    // group with vehicles. See sys_profile/fnc_profileVehicle.sqf:129
    // (vehicleClass at select 2 select 11) and the resolution pattern in
    // mil_opcom/fnc_OPCOM.sqf:1029-1031.
    private _vehicleIDs = [];

    if (count _profile >= 3) then {
        private _data = _profile select 2;
        if (count _data >= 6) then { _entityType = _data select 5; };
        if (count _data >= 9) then { _vehicleIDs = _data select 8; };
    };

    // Resolve each vehicle profile ID to its classname.
    private _vehicles = [];
    {
        if (!isNil "_x" && {_x isEqualType ""}) then {
            private _vehProfile = [ALiVE_ProfileHandler, "getProfile", _x] call ALiVE_fnc_ProfileHandler;
            if (!isNil "_vehProfile" && {count _vehProfile >= 3}) then {
                private _vehData = _vehProfile select 2;
                if (count _vehData >= 12) then {
                    private _class = _vehData select 11;
                    if (_class isEqualType "" && {_class != ""}) then {
                        _vehicles pushBack _class;
                    };
                };
            };
        };
    } forEach _vehicleIDs;

    private _hasArmor = false;
    private _hasMech = false;
    private _hasMotor = false;
    private _hasAir = false;
    private _hasArt = false;
    private _hasAA = false;
    private _hasAT = false;

    {
        private _veh = _x;
        if (!isNil "_veh") then {
            private _class = if (_veh isEqualType "") then { _veh } else { typeOf _veh };
            if (_class != "") then {
                // Classname cache — avoids 7 isKindOf config walks per vehicle.
                private _cachedType = ALIVE_COP_TYPE_CACHE getOrDefault [_class, ""];
                if (_cachedType != "") then {
                    switch (_cachedType) do {
                        case "armor": { _hasArmor = true; };
                        case "mech":  { _hasMech = true; };
                        case "motor": { _hasMotor = true; };
                        case "air":   { _hasAir = true; };
                        case "art":   { _hasArt = true; };
                        case "aa":    { _hasAA = true; };
                        case "at":    { _hasAT = true; };
                    };
                } else {
                    private _vehType = "none";
                    if (_class isKindOf "Tank") then { _hasArmor = true; _vehType = "armor"; };
                    if (_vehType == "none" && {_class isKindOf "Wheeled_APC_F" || _class isKindOf "Tracked_APC"}) then { _hasMech = true; _vehType = "mech"; };
                    if (_vehType == "none" && {_class isKindOf "Car"}) then { _hasMotor = true; _vehType = "motor"; };
                    if (_vehType == "none" && {_class isKindOf "Air"}) then { _hasAir = true; _vehType = "air"; };
                    if (_vehType == "none" && {_class isKindOf "StaticMortar"}) then { _hasArt = true; _vehType = "art"; };
                    if (_vehType == "none" && {_class isKindOf "StaticAAWeapon"}) then { _hasAA = true; _vehType = "aa"; };
                    if (_vehType == "none" && {_class isKindOf "StaticATWeapon"}) then { _hasAT = true; _vehType = "at"; };
                    ALIVE_COP_TYPE_CACHE set [_class, _vehType];
                };
            };
        };
    } forEach _vehicles;

    // Highest threat wins
    if (_hasAir)   exitWith { "air" };
    if (_hasArmor) exitWith { "armor" };
    if (_hasMech)  exitWith { "mech" };
    if (_hasArt)   exitWith { "art" };
    if (_hasAA)    exitWith { "aa" };
    if (_hasAT)    exitWith { "at" };
    if (_hasMotor) exitWith { "motor" };

    // Fallback: infantry if entity, unknown if vehicle without classification
    if (_entityType == "entity") exitWith { "infantry" };
    "unknown"
};

// ============================================================================
// Dominant type / size indicator / faction short code
// ============================================================================

ALIVE_fnc_COPDominantType = {
    params [["_types", [], [[]]]];

    if (count _types == 0) exitWith { "unknown" };

    private _bestIdx = 999;
    private _best = "unknown";

    {
        private _idx = ALIVE_COP_THREAT_ORDER find _x;
        if (_idx >= 0 && _idx < _bestIdx) then {
            _bestIdx = _idx;
            _best = _x;
        };
    } forEach _types;

    _best
};

ALIVE_fnc_COPSizeIndicator = {
    params [["_count", 1, [0]]];

    if (_count <= ALIVE_COP_SIZE_THRESH_SQUAD)   exitWith { "squad" };
    if (_count <= ALIVE_COP_SIZE_THRESH_PLATOON) exitWith { "platoon" };
    if (_count <= ALIVE_COP_SIZE_THRESH_COMPANY) exitWith { "company" };
    "battalion"
};

ALIVE_fnc_COPFactionShortCode = {
    params [["_faction", "", [""]]];

    if (_faction == "") exitWith { "" };

    // Mission-supplied overrides take precedence over the bundled defaults,
    // so a mission can name custom factions without editing the addon.
    private _overrides = missionNamespace getVariable ["ALIVE_COP_FACTION_CODES_OVERRIDES", createHashMap];
    private _code = _overrides getOrDefault [_faction, ""];
    if (_code != "") exitWith { _code };

    _code = ALIVE_COP_FACTION_CODES getOrDefault [_faction, ""];
    if (_code != "") exitWith { _code };

    // Fallback: strip common vendor prefixes, uppercase first 5 chars.
    private _stripped = _faction;
    {
        if (_stripped find _x == 0) then {
            _stripped = _stripped select [count _x];
        };
    } forEach ["rhs_faction_", "rhsgref_faction_", "rhssaf_faction_"];

    toUpper (_stripped select [0, 5])
};

// ============================================================================
// Location name lookup (50 m bucket cache on ALIVE_COP_LOC_CACHE)
// ============================================================================

ALIVE_fnc_COPGetLocationName = {
    params [["_pos", [0,0,0], [[]]]];

    private _bucket = ALIVE_COP_LOC_CACHE_BUCKET;
    private _bx = round ((_pos select 0) / _bucket);
    private _by = round ((_pos select 1) / _bucket);
    private _key = format ["%1_%2", _bx, _by];

    if (_key in ALIVE_COP_LOC_CACHE) exitWith {
        ALIVE_COP_LOC_CACHE get _key
    };

    private _nearLocs = nearestLocations [_pos, ["NameCity", "NameVillage", "NameLocal"], ALIVE_COP_LOC_SEARCH_RADIUS];
    private _result = if (count _nearLocs > 0) then {
        text (_nearLocs select 0)
    } else {
        mapGridPosition _pos
    };

    // Cap the cache — drop the oldest 25% if we've hit the limit. Hashmap
    // iteration order is insertion order in Arma 3, so the first keys are
    // the oldest.
    if (count ALIVE_COP_LOC_CACHE >= ALIVE_COP_LOC_CACHE_MAX) then {
        private _allKeys = keys ALIVE_COP_LOC_CACHE;
        private _drop = floor (ALIVE_COP_LOC_CACHE_MAX * 0.25);
        for "_i" from 0 to (_drop - 1) do {
            ALIVE_COP_LOC_CACHE deleteAt (_allKeys select _i);
        };
    };

    ALIVE_COP_LOC_CACHE set [_key, _result];
    _result
};

// ============================================================================
// Activity: OPCOM state → letter + color
// ============================================================================

ALIVE_fnc_COPGetActivityFromState = {
    params [["_state", "", [""]]];

    switch (toLower _state) do {
        case "attack";
        case "attacking";
        case "capture":    { "A" };
        case "defend";
        case "defending":  { "D" };
        case "moving":     { "M" };
        case "garrison";
        case "garrisoned": { "G" };
        case "reserve";
        case "reserving":  { "R" };
        default            { "" };
    };
};

ALIVE_fnc_COPGetActivityColor = {
    params [["_activity", "", [""]]];

    switch (toUpper _activity) do {
        case "A": { ALIVE_COP_COLOR_ACT_ATTACK };
        case "D": { ALIVE_COP_COLOR_ACT_DEFEND };
        case "M": { ALIVE_COP_COLOR_ACT_MOVE };
        case "G": { ALIVE_COP_COLOR_ACT_GARRISON };
        case "R": { ALIVE_COP_COLOR_ACT_RESERVE };
        default   { [1, 1, 1, 1] };
    };
};

// ============================================================================
// Grid-bucket clustering (stateless, per-cycle)
//
// Not substitutable with ALIVE_fnc_cluster — that's a persistent strategic
// cluster OO class; this is a one-pass grid bucketer used per broadcast
// cycle to visually group spotrep entries.
// ============================================================================

ALIVE_fnc_COPClusterByGrid = {
    params [["_contacts", [], [[]]], ["_radius", 200, [0]]];

    if (count _contacts == 0) exitWith { [] };

    private _buckets = createHashMap;

    {
        private _contact = _x;
        private _pos = _contact select 0;
        private _bx = floor ((_pos select 0) / _radius);
        private _by = floor ((_pos select 1) / _radius);
        private _key = format ["%1_%2", _bx, _by];

        private _bucket = _buckets getOrDefault [_key, []];
        _bucket pushBack _contact;
        _buckets set [_key, _bucket];
    } forEach _contacts;

    private _result = [];
    { _result pushBack _y; } forEach _buckets;

    _result
};

ALIVE_fnc_COPClusterCenter = {
    params [["_cluster", [], [[]]]];

    if (count _cluster == 0) exitWith { [0, 0, 0] };

    private _sumX = 0;
    private _sumY = 0;
    private _n = count _cluster;

    {
        private _pos = _x select 0;
        _sumX = _sumX + (_pos select 0);
        _sumY = _sumY + (_pos select 1);
    } forEach _cluster;

    [_sumX / _n, _sumY / _n, 0]
};

// ============================================================================
// Hash-diff broadcast
// ============================================================================

ALIVE_fnc_COPHashArray = {
    params [["_arr", [], [[]]]];

    if (count _arr == 0) exitWith { "empty" };

    private _parts = [];
    {
        private _entry = _x;
        // Round position to 10 m if first element looks like a coordinate.
        if (count _entry > 0 && {(_entry select 0) isEqualType []}) then {
            private _p = _entry select 0;
            private _rx = round ((_p select 0) / 10) * 10;
            private _ry = round ((_p select 1) / 10) * 10;
            _parts pushBack format ["%1_%2_%3", _rx, _ry, str (_entry select [1])];
        } else {
            _parts pushBack str _entry;
        };
    } forEach _arr;

    _parts joinString "|"
};

ALIVE_fnc_COPBroadcastIfChanged = {
    params [["_varName", "", [""]], ["_data", [], [[]]], ["_hashMap", createHashMap, [createHashMap]]];

    private _newHash = [_data] call ALIVE_fnc_COPHashArray;
    private _lastHash = _hashMap getOrDefault [_varName, ""];

    if (_newHash != _lastHash) then {
        // Third arg `true` = JIP-persistent broadcast: engine queues the latest
        // value for late joiners, so a player who connects between server cycles
        // immediately sees the current intel instead of an empty map.
        missionNamespace setVariable [_varName, _data, true];
        _hashMap set [_varName, _newHash];
        ["debug", "broadcast", "%1 changed (%2 entries) — broadcasting", [_varName, count _data]] call ALIVE_fnc_COPLog;
        true
    } else {
        ["trace", "broadcast", "%1 unchanged — skipped", [_varName]] call ALIVE_fnc_COPLog;
        false
    }
};

// ============================================================================
// Age / confidence / threat-list checks
// ============================================================================

ALIVE_fnc_COPAgeAlpha = {
    params [["_age", 0, [0]]];

    if (_age <= ALIVE_COP_AGE_FRESH) exitWith { 1.0 };
    if (_age >= ALIVE_COP_AGE_FADED) exitWith { ALIVE_COP_AGE_MIN_ALPHA };

    private _range = ALIVE_COP_AGE_FADED - ALIVE_COP_AGE_FRESH;
    private _t = (_age - ALIVE_COP_AGE_FRESH) / _range;
    1.0 - (_t * (1.0 - ALIVE_COP_AGE_MIN_ALPHA))
};

ALIVE_fnc_COPConfidenceStyle = {
    params [["_age", 0, [0]]];

    if (_age < ALIVE_COP_CONFIDENCE_FRESH) exitWith { "solid" };
    if (_age < ALIVE_COP_CONFIDENCE_AGING) exitWith { "dashed" };
    "dotted"
};

ALIVE_fnc_COPIsThreat = {
    params [["_type", "", [""]]];
    _type in ALIVE_COP_THREAT_TYPES
};

// ============================================================================
// Lifecycle log
// ============================================================================
["COP - Helpers: 18 helpers seeded"] call ALiVE_fnc_dump;

private _result = true;
TRACE_1("COPHelpers - output",_result);
_result
