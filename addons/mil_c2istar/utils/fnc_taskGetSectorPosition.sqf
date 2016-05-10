#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetSectorPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSectorPosition

Description:
Get a enemy cluster for a task

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskLocation","_positionType","_targetPosition","_sector","_sectorData","_sectorTerrain","_bestPlaces","_flatEmpty","_landElevation"];

_taskLocation = _this select 0;
_positionType = _this select 1;

_targetPosition = [];

_sector = [ALIVE_sectorGrid, "positionToSector", _taskLocation] call ALIVE_fnc_sectorGrid;
_sectorData = [_sector, "data"] call ALIVE_fnc_hashGet;

if (isnil "_sectorData") exitwith {_taskLocation};

_sectorTerrain = [_sectorData, "terrain"] call ALIVE_fnc_hashGet;
_bestPlaces = [_sectorData,"bestPlaces"] call ALIVE_fnc_hashGet;
_flatEmpty = [_sectorData,"flatEmpty"] call ALIVE_fnc_hashGet;
_landElevation = [_sectorData,"elevationSamplesLand"] call ALIVE_fnc_hashGet;

switch(_positionType) do {
    case "overwatch": {

        private["_sortedElevations","_highestElevation"];

        _sortedElevations = [_landElevation,[],{_x select 1},"ASCEND"] call ALiVE_fnc_SortBy;
        _highestElevation = _sortedElevations select (count (_sortedElevations)-1);
        _targetPosition = [_highestElevation select 0 select 0, _highestElevation select 0 select 1, 0];

    };
};

_targetPosition