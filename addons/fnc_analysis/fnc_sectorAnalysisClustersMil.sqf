#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(sectorAnalysisClustersMil);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sectorAnalysisClustersMil

Description:
Perform analysis on an array of sectors

Parameters:
None

Returns:
...

Examples:
(begin example)
// add units within sector data to passed sector objects
_result = [_sectors] call ALIVE_fnc_sectorAnalysisClustersMil;
(end)

See Also:


Author:
ARJay
---------------------------------------------------------------------------- */

private _sectors = _this select 0;

private _err = format["sector analysis units requires an array of sectors - %1",_sectors];
ASSERT_TRUE(_sectors isEqualType [], _err);

if(isNil "ALIVE_clustersMil" && isNil "ALIVE_loadedMilClusters") then {
    //["LOADING MO DATA"] call ALIVE_fnc_dump;
    //[true] call ALIVE_fnc_timer;

    private _worldName = toLower(worldName);
    private _file = format["\x\alive\addons\mil_placement\clusters\clusters.%1_mil.sqf", _worldName];
    call compile preprocessFileLineNumbers _file;
    ALIVE_loadedMilClusters = true;

    //[] call ALIVE_fnc_timer;
    //["MO DATA LOADED"] call ALIVE_fnc_dump;
};

{
    private _sector = _x;

    private _centerPosition = [_sector, "center"] call ALIVE_fnc_sector;
    private _id = [_sector, "id"] call ALIVE_fnc_sector;
    private _bounds = [_sector, "bounds"] call ALIVE_fnc_sector;
    private _dimensions = [_sector, "dimensions"] call ALIVE_fnc_sector;

    private _consolidated = [];
    private _air = [];
    private _heli = [];

    {
        private _cluster = _x;
        private _clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;

        if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
            private _clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
            _consolidated pushback _clusterCenter,_clusterID];
        };
    } forEach (ALIVE_clustersMil select 2);

    {
        private _cluster = _x;
        private _clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;

        if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
            private _clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
            _air pushback [_clusterCenter,_clusterID];
        };
    } forEach (ALIVE_clustersMilAir select 2);

    {
        private _cluster = _x;
        private _clusterCenter = [_cluster, "center"] call ALIVE_fnc_hashGet;

        if([_sector, "within", _clusterCenter] call ALIVE_fnc_sector) then {
            private _clusterID = [_cluster, "clusterID"] call ALIVE_fnc_hashGet;
            _heli pushback [_clusterCenter,_clusterID];
        };
    } forEach (ALIVE_clustersMilHeli select 2);

    private _clusters = [] call ALIVE_fnc_hashCreate;
    [_clusters, "consolidated", _consolidated] call ALIVE_fnc_hashSet;
    [_clusters, "air", _air] call ALIVE_fnc_hashSet;
    [_clusters, "heli", _heli] call ALIVE_fnc_hashSet;

    // store the result of the analysis on the sector instance
    [_sector, "data", ["clustersMil",_clusters]] call ALIVE_fnc_sector;
} forEach _sectors;