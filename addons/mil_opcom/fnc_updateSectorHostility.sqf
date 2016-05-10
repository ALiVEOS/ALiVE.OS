#include <\x\alive\addons\mil_opcom\script_component.hpp>
SCRIPT(updateSectorHostility);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_updateSectorHostility
Description:
Updates the current sector with hostiltiy data. needs ALiVE SectorGrid

Parameters:
_this select 0: ARRAY - position
_this select 1: ARRAY - sides
_this select 2: NUMBER - value

Returns:
Nil

See Also:
- <ALIVE_fnc_OPCOM>

Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_sector","_sectorData"];

if (isnil QMOD(SECTORGRID) || {isnil QMOD(CLUSTERHANDLER)} || {isnil QMOD(SECTORGRID)}) exitwith {};

PARAMS_3(_pos,_sides,_value);

_sector = [ALIVE_sectorGrid, "positionToSector", _pos] call ALIVE_fnc_sectorGrid;
_sectorData = [_sector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;

if ("clustersCiv" in (_sectorData select 1)) then {
    _civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
    _settlementClusters = [_civClusters,"settlement"] call ALIVE_fnc_hashGet;

    {
        _clusterID = _x select 1;
        _cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;

        if !(isNil "_cluster") then {
            _clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;
    
            {[_clusterHostility,_x,([_clusterHostility,_x,0] call ALIVE_fnc_hashGet) + _value] call ALIVE_fnc_hashSet} foreach _sides;
            [_cluster, "hostility",_clusterHostility] call ALIVE_fnc_hashSet;
        };
    } forEach _settlementClusters;
};