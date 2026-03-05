#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
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

    private _candidateSectors = +_sortedSectors;
    private _minDistance = missionNamespace getVariable ["ALIVE_taskMinDistance", 0];
    if (_taskLocationType in ["Short", "Medium", "Long"] && {_minDistance > 0}) then {
        private _filteredSectors = [];
        {
            private _sectorPos = [_x, "position", []] call ALIVE_fnc_hashGet;
            if !(_sectorPos isEqualTo []) then {
                if (_taskLocation distance2D _sectorPos >= _minDistance) then {
                    _filteredSectors pushBack _x;
                };
            };
        } forEach _sortedSectors;

        if (count _filteredSectors > 0) then {
            _candidateSectors = _filteredSectors;
        };
    };

    _countSectors = count _candidateSectors;

    if(_countSectors > 0) then {

        if(_taskLocationType == "Map" || _taskLocationType == "Short") then {
            _targetSector = _candidateSectors select 0;
        };

        if(_taskLocationType == "Medium") then {
            _targetSector = _candidateSectors select (floor(_countSectors/2));
        };

        if(_taskLocationType == "Long") then {
            _targetSector = _candidateSectors select (_countSectors-1);
        };

    };

};

_targetSector
