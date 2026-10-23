#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetSideSectorVehicles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSideSectorVehicles

Description:
Get side sector that contains vehicles

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

_sideSectors = [ALIVE_battlefieldAnalysis,"getSectorsContainingSideVehicles",[_side]] call ALIVE_fnc_battlefieldAnalysis;

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

    // Maximum Task Distance (TheLogatron on Discord, 23 Oct): only those within it of the player; none within
    // it (blacklisted spots aside), the whole list stays and the nearest beyond is used, as Minimum Task Distance falls back
    private _maxDistance = missionNamespace getVariable ["ALIVE_taskMaxDistance", 0];
    if (_taskLocationType in ["Short", "Medium", "Long"] && {_maxDistance > 0} && {count _candidateSectors > 0}) then {
        private _bl = missionNamespace getVariable ["ALIVE_taskBlacklistMarkers", []];
        private _within = _candidateSectors select { private _p = [_x, "position", []] call ALIVE_fnc_hashGet; _p isNotEqualTo [] && {(_taskLocation distance2D _p) <= _maxDistance} && {(_bl findIf { _p inArea _x }) < 0} };
        _candidateSectors = if (_within isEqualTo []) then {
            ["C2ISTAR - nothing within Maximum Task Distance %1 of %2, so the nearest beyond it is used", _maxDistance, mapGridPosition _taskLocation] call ALiVE_fnc_dump; _candidateSectors
        } else { _within };
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
