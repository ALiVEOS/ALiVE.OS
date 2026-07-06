#include "\x\alive\addons\mil_c2istar\script_component.hpp"
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

        // Pre-assault staging position. Picked along the line from the
        // assigned player toward the objective, at a calibrated offset
        // from the objective:
        //   - Far enough that the AI defenders don't trigger on the
        //     staging position itself (~700m -- comfortably outside
        //     typical AI detection of 200-400m).
        //   - Close enough that the objective is inside ALiVE's
        //     profile spawn radius (default ~1500m), so defenders are
        //     real units by the time players arrive at the staging
        //     area and can press the assault without an extra
        //     spawn-in delay.
        //
        // Falls back to a point halfway between player and objective
        // if the player is already closer than the desired offset, or
        // to the objective itself if the caller didn't supply a player
        // position.
        //
        // Previous implementation picked the highest-elevation point in
        // the same ~500m sector as the objective, which produced
        // staging markers 100-300m from the objective -- visibly wrong
        // on the player's map and with no tactical value.
        private _desiredOffset = 700;
        private _stagingPos = _taskLocation;
        private _playerPos = if (count _this > 2) then { _this select 2 } else { [] };

        if (typeName _playerPos == "ARRAY" && {count _playerPos >= 2}) then {
            private _distToTarget = _playerPos distance _taskLocation;
            if (_distToTarget > _desiredOffset + 200) then {
                // Player far enough that the offset fits on the line
                private _dirToPlayer = _taskLocation getDir _playerPos;
                _stagingPos = _taskLocation getPos [_desiredOffset, _dirToPlayer];
            } else {
                // Player closer than desired offset -- midpoint between
                // them so the staging marker doesn't overshoot the
                // player position.
                _stagingPos = [
                    ((_playerPos select 0) + (_taskLocation select 0)) / 2,
                    ((_playerPos select 1) + (_taskLocation select 1)) / 2,
                    0
                ];
            };
        };

        // Water-avoidance: if the picked spot is on water (or in a
        // building footprint), nudge to nearest valid land via
        // BIS_fnc_findSafePos. 300m search keeps the position close
        // to the intended approach line.
        if (surfaceIsWater _stagingPos) then {
            _stagingPos = [_stagingPos, 0, 300, 1, 0, 0.25, 0, [], [_stagingPos]] call BIS_fnc_findSafePos;
        };

        _targetPosition = _stagingPos;

    };
};

_targetPosition