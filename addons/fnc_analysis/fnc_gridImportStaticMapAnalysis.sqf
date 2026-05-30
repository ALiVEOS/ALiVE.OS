#include "\x\alive\addons\fnc_analysis\script_component.hpp"
SCRIPT(gridImportStaticMapAnalysis);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_gridImportStaticMapAnalysis

Description:
Import static map analysis data structures to a grid

Parameters:
Grid - the grid to run the map analysis on
String - world static analysis file to import

Returns:
...

Examples:
(begin example)
// import stratis static map analysis to the passed grid
_result = [_grid,"Stratis"] call ALIVE_fnc_gridImportStaticMapAnalysis;
(end)

See Also:


Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_grid","_worldName","_sectors","_staticMapAnalysis","_sector","_sectorID","_file"];

_grid = _this select 0;

_sectors = [_grid, "sectors"] call ALIVE_fnc_sectorGrid;

_worldName = [worldName] call CBA_fnc_capitalize;

// Track where the static index came from so the load-time
// viability assessor (`fnc_assessIndexViability`) can report it.
// Three possible states: "mission" (mission init.sqf populated
// the var before this loader ran), "bundled" (the addon-bundled
// data file under fnc_analysis/data/ filled it in), or "none"
// (no data file for this world -- dummy sector data is used and
// runtime will fall back to expensive engine queries).
if(isNil "ALIVE_gridData") then {
    _worldName = toLower(worldName);
    _file = format["x\alive\addons\fnc_analysis\data\data.%1.sqf", _worldName];
    call compile preprocessFileLineNumbers _file;

    if (isNil "ALIVE_gridData") then {
        ALIVE_gridDataSource = "none";
    } else {
        ALIVE_gridDataSource = "bundled";
    };
} else {
    ALIVE_gridDataSource = "mission";
};

if (isNil "ALIVE_gridData") exitWith {
    // Create dummy sector data
    {
        private _sector = _x;
        private _sectorID = [_sector, "id"] call ALIVE_fnc_sector;

        private _sectorData = [] call ALIVE_fnc_sectorDataDummy;

        [_sector, "data", _sectorData] call ALIVE_fnc_hashSet;
    } forEach _sectors;

    // Run the viability assessor even on the no-index path so the
    // RPT carries the "no static index loaded" verdict + the M5
    // (named-locations) partial score that doesn't depend on the
    // grid. Gated to fire once per session.
    if (isNil "ALIVE_indexViabilityAssessed") then {
        ALIVE_indexViabilityAssessed = true;
        [] call ALIVE_fnc_assessIndexViability;
    };
};

{
    _sector = _x;
    _sectorID = [_sector, "id"] call ALIVE_fnc_sector;
    [_sector, "data", [ALIVE_gridData, _sectorID] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

} forEach _sectors;

// Index loaded successfully -- assess and log the viability score
// once per session. Production callers (mil_cqb / sys_profile init)
// may invoke this loader multiple times; the latch ensures one
// RPT entry.
//
// The score + tier are published as globals (ALiVE_indexViabilityScore,
// ALiVE_indexViabilityTier) for other consumers. The runtime UI
// dialog approach was abandoned -- the Arma loading screen renders
// opaquely above all user-created dialogs (BIS_fnc_guiMessage,
// createDialog, cutRsc all blocked the same way), and waiting for
// the loading screen to dismiss deadlocked sys_profile against the
// modules downstream of its startupComplete. Early advisory now
// fires in Eden via `OnMissionPreview` (see main/XEH_preInit.sqf +
// ALIVE_fnc_indexViabilityEdenCheck), where it surfaces before the
// loading screen ever paints. RPT block still fires here at mission
// init for post-mortem.
if (isNil "ALIVE_indexViabilityAssessed") then {
    ALIVE_indexViabilityAssessed = true;
    [] call ALIVE_fnc_assessIndexViability;
};
