#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetSideSectorEntities);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSideSectorEntities

Description:
Get side sector that contains entities

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_taskLocation","_taskLocationType","_side","_targetPosition","_sideSectors","_sortedSectors","_countSectors",
"_spawnSectors","_targetSector","_sectorData"];

_taskLocation = _this select 0;
_taskLocationType = _this select 1;
_side = _this select 2;

_targetSector = [];

// try to find sectors containing enemy profiles

_sideSectors = [ALIVE_battlefieldAnalysis,"getSectorsContainingSide",[_side]] call ALIVE_fnc_battlefieldAnalysis;

if(count _sideSectors > 0) then {

    _sortedSectors = [_sideSectors, _taskLocation] call ALIVE_fnc_sectorSortDistance;

    _countSectors = count _sortedSectors;

    if(_countSectors > 0) then {

        if(_taskLocationType == "Map" || _taskLocationType == "Short") then {
            _targetSector = _sortedSectors select 0;
        };

        if(_taskLocationType == "Medium") then {
            _targetSector = _sortedSectors select (floor(_countSectors/2));
        };

        if(_taskLocationType == "Long") then {
            _targetSector = _sortedSectors select (_countSectors-1);
        };

    };

};

_targetSector