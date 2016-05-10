#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskGetSideSectorCompositionPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetSideSectorCompositionPosition

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

private ["_taskLocation","_taskLocationType","_side","_targetPosition","_sideSectors","_sortedSectors","_countSectors",
"_spawnSectors","_position","_targetSector","_sectorData","_bestPlaces","_flatEmpty","_exposedHills"];

_taskLocation = _this select 0;
_taskLocationType = _this select 1;
_side = _this select 2;

_targetPosition = [];

// try to find sectors containing enemy profiles

_sideSectors = [ALIVE_battlefieldAnalysis,"getSectorsContainingSide",[_side]] call ALIVE_fnc_battlefieldAnalysis;

if(count _sideSectors > 0) then {

    _sortedSectors = [_sideSectors, _taskLocation] call ALIVE_fnc_sectorSortDistance;

    _spawnSectors = [];

    {
        _position = [_x, "position"] call ALIVE_fnc_hashGet;
        if([_position, 1000] call ALiVE_fnc_anyPlayersInRange == 0) then {
            _spawnSectors set [count _spawnSectors, _x];
        };
    } forEach _sortedSectors;

    _countSectors = count _spawnSectors;

    if(_countSectors > 0) then {

        if(_taskLocationType == "Map" || _taskLocationType == "Short") then {
            _targetSector = _spawnSectors select 0;
        };

        if(_taskLocationType == "Medium") then {
            _targetSector = _spawnSectors select (floor(_countSectors/2));
        };

        if(_taskLocationType == "Long") then {
            _targetSector = _spawnSectors select (_countSectors-1);
        };

        _targetPosition = [_targetSector, "position"] call ALIVE_fnc_hashGet;

        // got a sector with enemy
        // refine position with more analysis data

        _sectorData = [_targetSector,"data"] call ALIVE_fnc_hashGet;
        
        if (isnil "_sectorData") exitwith {_taskLocation};
        
        _bestPlaces = [_sectorData,"bestPlaces"] call ALIVE_fnc_hashGet;
        _flatEmpty = [_sectorData,"flatEmpty"] call ALIVE_fnc_hashGet;

        if("exposedHills" in (_bestPlaces select 1)) then {
            _exposedHills = [_bestPlaces,"exposedHills"] call ALIVE_fnc_hashGet;
            if(count _exposedHills > 0) then {
                _targetPosition = _exposedHills call BIS_fnc_selectRandom;
            }else{
                if(count _flatEmpty > 0) then {
                    _targetPosition = _flatEmpty call BIS_fnc_selectRandom;
                };
            };
        }else{
            if(count _flatEmpty > 0) then {
                _targetPosition = _flatEmpty call BIS_fnc_selectRandom;
            };
        };

    };

};

_targetPosition