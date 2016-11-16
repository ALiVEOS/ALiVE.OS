#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisElevation);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisElevation

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add elevation data to passed sector objects
_result = [] call ALIVE_fnc_sectorAnalysisElevation;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private _sectors = _this select 0;

private _err = format["sector analysis elevation requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

{
    private _sector = _x;

    private _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
    private _id = [_sector, "id"] call ALIVE_fnc_sector;
    private _bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
    private _dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;
    private _sectorData = [_sector, "data"] call ALIVE_fnc_sector;
    private _terrainData = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;

    private _elevationData = [];
    private _markers = [];

    if(_terrainData == "SEA") then {
        private _m = [_centerPosition] call ALIVE_fnc_spawnDebugMarker;
        hideObject _m;
        _markers pushback _m;

        private _elevation = ((getPosATL _m) select 2);
        _elevation = _elevation - (_elevation * 2);
        _elevationData pushback [_centerPosition,_elevation];

    } else {
        private _m = [_centerPosition] call ALIVE_fnc_spawnDebugMarker;
        hideObject _m;
        _markers pushback _m;

        private _elevation = ((getPosASL _m) select 2);
        _elevationData pushback [_centerPosition,_elevation];
    };

    {
        deleteVehicle _x;
    } forEach _markers;

    // store the result of the analysis on the sector instance
    [_sector, "data", ["elevationSamples",_elevationData]] call ALIVE_fnc_sector;
    [_sector, "data", ["elevation",_elevation]] call ALIVE_fnc_sector;
} forEach _sectors;