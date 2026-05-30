#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(assessIndexViability);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_assessIndexViability

Description:
Score the terrain's static index quality and log the result to RPT.

Mission makers running ALiVE on a terrain without a proper static
index (no bundled data file in `fnc_analysis/data/`, no
mission-supplied `data.<worldName>.sqf` in the mission's subfolder)
get a 5-25 minute init while modules fall back to expensive engine
queries. The score gives them a quantitative read on what the
loaded index actually contains so they can drop in a better data
file, dial back module attributes, or accept the cost.

Five quality metrics (M1-M5), each 0-100, averaged for a quality
baseline. Four conditional penalties (Init complexity, Runway
presence, Mil-cluster coverage, Road network) modify the aggregate
downward. A separate diagnostic line (Re-index recommendation)
flags terrains where a fresh sys_indexer run would likely improve
the score, based on M1 coverage + a 3-sector sample comparing
engine-reported roads vs indexed roads. Tier label:
  80-100 Good      -- normal init expected
  60-79  Reduced   -- some features will underperform
  40-59  Poor      -- significant degradation, init will be slow
  0-39   Critical  -- mission unlikely to perform well

Reads:
  ALIVE_gridData                 -- the loaded sector hash, set by
                                    fnc_gridImportStaticMapAnalysis
  ALIVE_gridDataSource           -- "mission" / "bundled" / "none",
                                    set by the same loader
  ALiVE_AcceptLowIndexViability  -- Main module Eden attribute,
                                    suppresses the warning dialog
                                    when true

Writes (public variables):
  ALiVE_indexViabilityScore  -- aggregate score 0-100
  ALiVE_indexViabilityTier   -- "Good" / "Reduced" / "Poor" / "Critical"

Side effects:
  - RPT log block with per-metric breakdown + verdict
  - If hasInterface AND score < 60 AND attribute off AND not
    silenced: spawns the index viability advisory dialog
    (Continue / Continue+silence / Abort)

Parameters:
  None (reads global state)

Returns:
  Number - aggregate score 0-100.

Examples:
(begin example)
private _score = [] call ALIVE_fnc_assessIndexViability;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

private _source = if (isNil "ALIVE_gridDataSource") then { "none" } else { ALIVE_gridDataSource };
private _haveIndex = !(isNil "ALIVE_gridData") && {_source != "none"};

// -------------------------------------------------------------------
// M5: Named-locations (CfgWorlds -> Names)
// Runs on every path -- reads from engine config, not the static
// index. Absolute count rather than density per km^2: a small map
// with proportional content shouldn't outscore a big map with lots
// of total content. Baseline 50 names = max. Calibrated against
// 11 terrains (Stratis 41, Altis 176, Malden 122, Tanoa 138,
// Takistan 320, Chernarus 650, Livonia 64, pja305 45, kunduz
// 97, Bootcamp 7, Woodland 48).
// -------------------------------------------------------------------
private _names = "true" configClasses (configFile >> "CfgWorlds" >> worldName >> "Names");
private _nameCount = count _names;
private _mapAreaKm2 = ((worldSize ^ 2) / 1e6) max 0.01;
private _nameDensity = _nameCount / _mapAreaKm2;
private _m5 = (_nameCount / 50 * 100) min 100;

// -------------------------------------------------------------------
// Runway presence (penalty modifier on aggregate)
// No-runway terrains can't support mil_ato, fixed-wing CAS, MACC,
// or transport-insertion auto-tasks. Heuristic check: a terrain
// with a real airfield sets `ilsPosition` (primary runway ILS
// landing point) and/or has classes under `secondaryAirports`.
// Dirt strips with no ILS slip past this but that's an acceptable
// tradeoff for a cheap config-only check.
// -------------------------------------------------------------------
private _ilsPos = getArray (configFile >> "CfgWorlds" >> worldName >> "ilsPosition");
private _hasPrimaryRunway = (count _ilsPos >= 2) &&
    {([_ilsPos select 0, _ilsPos select 1] distance [0,0]) > 100};
private _secondaryAirports = configFile >> "CfgWorlds" >> worldName >> "secondaryAirports";
private _hasSecondary = isClass _secondaryAirports && {count _secondaryAirports > 0};
private _hasRunway = _hasPrimaryRunway || _hasSecondary;
private _runwayPenalty = if (_hasRunway) then { 0 } else { 15 };
private _runwayLabel = if (_hasRunway) then { "Present" } else { "Absent" };

// Tier classification, used by both branches.
private _classifyTier = {
    params ["_score"];
    switch (true) do {
        case (_score >= 80): {"Good"};
        case (_score >= 60): {"Reduced"};
        case (_score >= 40): {"Poor"};
        default              {"Critical"};
    }
};

// Compute the aggregate in whichever branch applies, capture it,
// then run the dialog-gate logic AFTER the branches return so we
// don't duplicate the trigger code.
private _aggregateFinal = if (!_haveIndex) then {
    private _qualityAvg = _m5 / 5;
    private _aggregate = ((_qualityAvg - _runwayPenalty) max 0) min 100;
    private _tier = [_aggregate] call _classifyTier;

    // Use ALIVE_fnc_dump so the score block carries the standard
    // "ALiVE 0 : <time> -" RPT prefix that other module init lines
    // do, making it greppable + sortable alongside the rest of the
    // boot trace.
    ["----------------------------------------------------------------------------"] call ALIVE_fnc_dump;
    [format ["ALiVE Index Viability -- worldName=%1", worldName]] call ALIVE_fnc_dump;
    ["  Source: none"] call ALIVE_fnc_dump;
    [format ["  World size                 : %1 m  (%2 km^2)",
        worldSize, (_mapAreaKm2 toFixed 1)]] call ALIVE_fnc_dump;
    ["  Action: drop data.<worldName>.sqf into the mission's subfolder,"] call ALIVE_fnc_dump;
    ["          or run sys_indexer against the terrain in Eden."] call ALIVE_fnc_dump;
    [format ["  M5 Named-locations         : %1  (%2 names, %3/km^2)",
        round _m5, _nameCount, (_nameDensity toFixed 2)]] call ALIVE_fnc_dump;
    [format ["  Runway                     : %1  (-%2)", _runwayLabel, _runwayPenalty]] call ALIVE_fnc_dump;
    ["  ----------------------------------------------------------------------------"] call ALIVE_fnc_dump;
    [format ["  Aggregate                  : %1  (%2)", round _aggregate, _tier]] call ALIVE_fnc_dump;
    ["----------------------------------------------------------------------------"] call ALIVE_fnc_dump;

    _aggregate
} else {
    // --- Index is loaded. Compute M1-M4 from ALIVE_gridData. ---

    private _sectorKeys = ALIVE_gridData select 1;
    private _sectorCount = count _sectorKeys;
    private _expectedSectorCount = round (((worldSize / 1000) ^ 2) max 1);

    // -------------------------------------------------------------------
    // M1: Sector coverage
    // sectorCount / expectedSectorCount, where expected = (worldSize/1000)^2
    // since sectors default to 1000x1000 m. Clamp at 100 so a slight
    // over-count (rounding) doesn't blow the score.
    // -------------------------------------------------------------------
    private _coverage = (_sectorCount / _expectedSectorCount) min 1;
    private _m1 = _coverage * 100;

    // -------------------------------------------------------------------
    // M2-M4: per-sector data densities. One pass over the sector hash
    // aggregates the per-sector counts; divide by sector count for
    // averages.
    // -------------------------------------------------------------------
    private _totalBestPlaces = 0;
    private _totalFlatEmpty = 0;
    private _totalRoadNodes = 0;
    private _totalMilClusters = 0;

    {
        private _sectorData = [ALIVE_gridData, _x] call ALIVE_fnc_hashGet;
        if (!isNil "_sectorData") then {
            private _bestPlaces = [_sectorData, "bestPlaces"] call ALIVE_fnc_hashGet;
            if (!isNil "_bestPlaces") then {
                private _forest = [_bestPlaces, "forest"] call ALIVE_fnc_hashGet;
                private _hills  = [_bestPlaces, "exposedHills"] call ALIVE_fnc_hashGet;
                if (!isNil "_forest") then { _totalBestPlaces = _totalBestPlaces + count _forest };
                if (!isNil "_hills")  then { _totalBestPlaces = _totalBestPlaces + count _hills  };
            };

            private _flatEmpty = [_sectorData, "flatEmpty"] call ALIVE_fnc_hashGet;
            if (!isNil "_flatEmpty") then { _totalFlatEmpty = _totalFlatEmpty + count _flatEmpty };

            private _roads = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
            if (!isNil "_roads") then {
                private _r = [_roads, "road"] call ALIVE_fnc_hashGet;
                private _c = [_roads, "crossroad"] call ALIVE_fnc_hashGet;
                if (!isNil "_r") then { _totalRoadNodes = _totalRoadNodes + count _r };
                if (!isNil "_c") then { _totalRoadNodes = _totalRoadNodes + count _c };
            };

            // Mil-cluster coverage: consolidated + air + heli entries
            // are the placement anchors mil_placement and OPCOM use.
            // A terrain without any indexed mil clusters forces the
            // mission maker to use Eden custom objective compositions.
            private _milClusters = [_sectorData, "clustersMil"] call ALIVE_fnc_hashGet;
            if (!isNil "_milClusters") then {
                private _consol = [_milClusters, "consolidated"] call ALIVE_fnc_hashGet;
                private _air    = [_milClusters, "air"] call ALIVE_fnc_hashGet;
                private _heli   = [_milClusters, "heli"] call ALIVE_fnc_hashGet;
                if (!isNil "_consol") then { _totalMilClusters = _totalMilClusters + count _consol };
                if (!isNil "_air")    then { _totalMilClusters = _totalMilClusters + count _air    };
                if (!isNil "_heli")   then { _totalMilClusters = _totalMilClusters + count _heli   };
            };
        };
    } forEach _sectorKeys;

    private _safeSectorCount = _sectorCount max 1;
    private _avgBestPlaces = _totalBestPlaces / _safeSectorCount;
    private _avgFlatEmpty  = _totalFlatEmpty  / _safeSectorCount;
    private _avgRoadNodes  = _totalRoadNodes  / _safeSectorCount;

    // Baselines calibrated 2026-05-19 against 11 terrains. Anchored
    // to the BIS-minimum-healthy values so all bundled-index BIS
    // terrains land at or near 100, with internal differentiation
    // coming from the other metrics. Densely-indexed CUP / community
    // terrains clamp out, which is fine -- we don't need to reward
    // over-indexing.
    //   M2 baseline 25 places/sector: Stratis 38.5 -> 100, Altis 22.5 -> 90.
    //   M3 baseline 15 positions/sector: Stratis 10.7 -> 71, Altis 22.3 -> 100.
    //   M4 baseline 30 nodes/sector: Stratis 32.5 -> 100, Altis 29.0 -> 97.
    private _m2 = (_avgBestPlaces / 25 * 100) min 100;
    private _m3 = (_avgFlatEmpty  / 15 * 100) min 100;
    private _m4 = (_avgRoadNodes  / 30 * 100) min 100;

    // -------------------------------------------------------------------
    // Init complexity (penalty modifier on aggregate)
    // Total indexed data points across the map -- best-places +
    // flat-empty positions + named locations. Large dense indexes
    // are expensive to feed downstream (mil_placement cluster scan,
    // pathfinder grid build, profile-system iteration). Split into
    // tiers calibrated 2026-05-19 against 11 terrains:
    //   Stratis 3k Light    Tanoa 22k Medium    pja305 110k Heavy
    //   Malden 9k Light     Livonia 36k Medium  ...
    //   ...                 Chernarus 51k Medium
    // -------------------------------------------------------------------
    private _totalDataPoints = _totalBestPlaces + _totalFlatEmpty + _nameCount;
    private _complexityTier = switch (true) do {
        case (_totalDataPoints < 15000):  {"Light"};
        case (_totalDataPoints < 75000):  {"Medium"};
        case (_totalDataPoints < 200000): {"Heavy"};
        default                           {"Extreme"};
    };
    private _complexityPenalty = switch (_complexityTier) do {
        case "Light":   { 0 };
        case "Medium":  { 5 };
        case "Heavy":   { 20 };
        case "Extreme": { 40 };
        default         { 0 };
    };

    // -------------------------------------------------------------------
    // Mil-cluster coverage (penalty modifier on aggregate)
    // Small penalty because the mission maker can fall back to Eden
    // custom objective composition modules. But terrains with zero
    // indexed mil clusters can't host auto-placed objectives at all,
    // so still worth flagging.
    // -------------------------------------------------------------------
    private _milClustersTier = switch (true) do {
        case (_totalMilClusters == 0): {"None"};
        case (_totalMilClusters < 5):  {"Limited"};
        default                        {"Present"};
    };
    private _milClustersPenalty = switch (_milClustersTier) do {
        case "None":    { 10 };
        case "Limited": { 5 };
        default         { 0 };
    };

    // -------------------------------------------------------------------
    // Road network (penalty modifier on aggregate, driven by M4)
    // Profiles need roads to travel and spawn alongside. M4 is
    // already in the quality average but its impact gets diluted
    // when the other four metrics are healthy. A separate modifier
    // amplifies the signal when the per-sector road density is
    // genuinely sparse. Intentional double-counting with M4 -- a
    // thin road graph hurts both the visual index quality AND the
    // actual gameplay, so it should land twice.
    // -------------------------------------------------------------------
    private _roadTier = switch (true) do {
        case (_m4 < 50): {"Sparse"};
        case (_m4 < 70): {"Limited"};
        default          {"Adequate"};
    };
    private _roadPenalty = switch (_roadTier) do {
        case "Sparse":  { 10 };
        case "Limited": { 5 };
        default         { 0 };
    };

    // -------------------------------------------------------------------
    // Re-index recommendation (diagnostic only -- not folded into score)
    // Sample three sectors spread across the map and compare what the
    // engine reports vs what the index captured. Roads are the cleanest
    // apples-to-apples signal: the indexer reads from the same engine
    // road graph, so a big gap means the indexer either missed the
    // sector or ran with low coverage settings.
    //
    // `nearRoads` is cheap (engine spatial index, ~10-50 ms per call).
    // Three samples bound the total cost at ~150 ms. The verdict
    // triggers if either: (a) M1 coverage shows missing sectors, or
    // (b) two of three samples show indexed < 40% of engine count.
    // -------------------------------------------------------------------
    // Sort sectors by indexed road density descending, take the
    // top half of content-bearing sectors, then pick three spread
    // across that pool. Positional sampling (first / middle / last
    // raw key) landed on coastal / map-edge sectors with 0/0
    // useless results on island terrains; this picks sectors that
    // actually have content to compare against.
    private _scored = _sectorKeys apply {
        private _sd = [ALIVE_gridData, _x] call ALIVE_fnc_hashGet;
        private _n = 0;
        if (!isNil "_sd") then {
            private _r = [_sd, "roads"] call ALIVE_fnc_hashGet;
            if (!isNil "_r") then {
                _n = (count ([_r, "road", []]      call ALIVE_fnc_hashGet))
                   + (count ([_r, "crossroad", []] call ALIVE_fnc_hashGet));
            };
        };
        [_n, _x]
    };
    _scored sort false;  // descending by road count

    // Drop zero-road sectors so the top-half slice is meaningful
    // content-bearing only.
    private _withContent = _scored select { (_x select 0) > 0 };
    private _withContentN = count _withContent;
    private _topHalfN = (floor (_withContentN / 2)) max 1;
    private _pool = (_withContent select [0, _topHalfN]) apply { _x select 1 };

    // Defensive: if the map is so sparse no sectors carry road
    // content, fall back to the raw key list so we still produce
    // a (likely empty) sample set without erroring.
    if (count _pool < 1) then { _pool = _sectorKeys };

    private _poolN = count _pool;
    private _sampleSectors = if (_poolN >= 3) then {
        [_pool select 0, _pool select (floor (_poolN / 2)), _pool select (_poolN - 1)]
    } else {
        _pool
    };

    private _samplesFlaggedLow = 0;
    private _sampleDetails = [];
    {
        private _sectorID = _x;
        private _parts = _sectorID splitString "_";
        private _cx = (parseNumber (_parts select 0)) * 1000 + 500;
        private _cy = (parseNumber (_parts select 1)) * 1000 + 500;
        private _center = [_cx, _cy, 0];

        private _engineRoads = count (_center nearRoads 500);

        private _indexedRoads = 0;
        private _sectorData = [ALIVE_gridData, _sectorID] call ALIVE_fnc_hashGet;
        if (!isNil "_sectorData") then {
            private _r = [_sectorData, "roads"] call ALIVE_fnc_hashGet;
            if (!isNil "_r") then {
                private _ra = [_r, "road"]      call ALIVE_fnc_hashGet;
                private _rc = [_r, "crossroad"] call ALIVE_fnc_hashGet;
                if (!isNil "_ra") then { _indexedRoads = _indexedRoads + count _ra };
                if (!isNil "_rc") then { _indexedRoads = _indexedRoads + count _rc };
            };
        };

        // Only flag sectors where the engine reports a meaningful road
        // presence -- skip ocean / desert sectors where 0/0 is correct.
        private _ratio = if (_engineRoads > 0) then { _indexedRoads / _engineRoads } else { 1 };
        if (_engineRoads > 5 && {_ratio < 0.4}) then { _samplesFlaggedLow = _samplesFlaggedLow + 1 };
        _sampleDetails pushBack (format ["%1=%2/%3", _sectorID, _indexedRoads, _engineRoads]);
    } forEach _sampleSectors;

    private _coverageMissing = _expectedSectorCount - _sectorCount;
    private _reindexYes = (_coverageMissing > 5) || (_samplesFlaggedLow >= 2);
    private _reindexReason = if (_coverageMissing > 5) then {
        format ["%1 sectors not in index", _coverageMissing]
    } else {
        if (_samplesFlaggedLow >= 2) then {
            format ["%1/3 samples show indexed << engine (%2)",
                _samplesFlaggedLow, _sampleDetails joinString ", "]
        } else {
            format ["sample %1", _sampleDetails joinString ", "]
        }
    };

    // Quality average across the five metrics, then apply all four
    // conditional penalties. Clamp to 0-100.
    private _qualityAvg = (_m1 + _m2 + _m3 + _m4 + _m5) / 5;
    private _aggregate = ((_qualityAvg - _complexityPenalty - _runwayPenalty - _milClustersPenalty - _roadPenalty) max 0) min 100;
    private _tier = [_aggregate] call _classifyTier;

    ["----------------------------------------------------------------------------"] call ALIVE_fnc_dump;
    [format ["ALiVE Index Viability -- worldName=%1", worldName]] call ALIVE_fnc_dump;
    [format ["  Source: %1", _source]] call ALIVE_fnc_dump;
    [format ["  World size                 : %1 m  (%2 km^2)",
        worldSize, (_mapAreaKm2 toFixed 1)]] call ALIVE_fnc_dump;
    [format ["  M1 Sector coverage         : %1  (%2/%3 sectors)",
        round _m1, _sectorCount, _expectedSectorCount]] call ALIVE_fnc_dump;
    [format ["  M2 Best-places density     : %1  (avg %2 places/sector)",
        round _m2, (_avgBestPlaces toFixed 1)]] call ALIVE_fnc_dump;
    [format ["  M3 Flat-empty density      : %1  (avg %2 positions/sector)",
        round _m3, (_avgFlatEmpty toFixed 1)]] call ALIVE_fnc_dump;
    [format ["  M4 Road graph density      : %1  (avg %2 nodes/sector)",
        round _m4, (_avgRoadNodes toFixed 1)]] call ALIVE_fnc_dump;
    [format ["  M5 Named-locations         : %1  (%2 names, %3/km^2)",
        round _m5, _nameCount, (_nameDensity toFixed 2)]] call ALIVE_fnc_dump;
    [format ["  Complexity                 : %1  (%2 data points, -%3)",
        _complexityTier, _totalDataPoints, _complexityPenalty]] call ALIVE_fnc_dump;
    [format ["  Runway                     : %1  (-%2)", _runwayLabel, _runwayPenalty]] call ALIVE_fnc_dump;
    [format ["  Mil clusters               : %1  (%2 indexed, -%3)",
        _milClustersTier, _totalMilClusters, _milClustersPenalty]] call ALIVE_fnc_dump;
    [format ["  Road network               : %1  (M4=%2, -%3)",
        _roadTier, round _m4, _roadPenalty]] call ALIVE_fnc_dump;
    [format ["  Re-index recommendation    : %1  (%2)",
        if (_reindexYes) then { "Yes" } else { "No" },
        _reindexReason]] call ALIVE_fnc_dump;
    ["  ----------------------------------------------------------------------------"] call ALIVE_fnc_dump;
    [format ["  Aggregate                  : %1  (%2)", round _aggregate, _tier]] call ALIVE_fnc_dump;
    ["----------------------------------------------------------------------------"] call ALIVE_fnc_dump;

    _aggregate
};

// -------------------------------------------------------------------
// Dialog gate. Fires once per session when:
//   - Aggregate < 80 (Reduced / Poor / Critical -- any sub-Good tier)
//   - Main module's "Accept low index viability" attribute is off
//   - The machine has an interface (player-host or local SP)
//   - The dialog wasn't already silenced this session
//
// Threshold of 80 captures any terrain where some features will
// underperform (Reduced) up through "mission unlikely to perform
// well" (Critical). pja305 at 66 belongs in that warning band --
// its 25-minute init on Inferno's setup is exactly the lived
// experience the dialog is meant to surface.
//
// Gated on hasInterface so a dedicated server doesn't try to
// display a dialog. The score is published as a global variable
// either way so other consumers can read it.
// -------------------------------------------------------------------
private _tierFinal = [_aggregateFinal] call _classifyTier;
ALiVE_indexViabilityScore = _aggregateFinal;
ALiVE_indexViabilityTier  = _tierFinal;
publicVariable "ALiVE_indexViabilityScore";
publicVariable "ALiVE_indexViabilityTier";

// Assessor is pure -- score + tier published as globals, no UI side
// effects. The caller (fnc_gridImportStaticMapAnalysis) owns the
// decision of whether to spawn the advisory dialog and whether to
// block on it. Keeping the dialog out of here means the assessor
// can also be called from offline / tooling contexts without an
// engine display.
_aggregateFinal
