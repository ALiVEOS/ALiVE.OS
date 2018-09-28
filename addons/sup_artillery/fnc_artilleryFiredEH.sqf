#include <\x\alive\addons\sup_artillery\script_component.hpp>
SCRIPT(ArtilleryFiredEH);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_artilleryFiredEH
Description:
Handles the fired event for all vehicles (guns) in the artillery group.

Parameters:
Object - The vehicle
String - The magazine type

Returns:
Nothing

Examples:
[_logic] call ALIVE_fnc_artillerySpawn;

See Also:

Author:
marceldev89
---------------------------------------------------------------------------- */
private _unit = param [0, objNull];
private _magazine = param [5, ""];

private _logic = (group _unit) getVariable ["logic", objNull];
private _fireMission = _logic getVariable ["fireMission", []];
private _roundType = [_fireMission, "roundType"] call ALIVE_fnc_hashGet;
private _roundsShot = [_fireMission, "roundsShot"] call ALIVE_fnc_hashGet;

if (_magazine == _roundType) then {
    private _delay = [_fireMission, "delay"] call ALIVE_fnc_hashGet;

    if (_delay > 0) then {
        private _units = [_fireMission, "units"] call ALIVE_fnc_hashGet;
        private _unitIndex = [_fireMission, "unitIndex"] call ALIVE_fnc_hashGet;

        if ((_unitIndex + 1) >= count _units) then {
            _unitIndex = 0;
        } else {
            _unitIndex = _unitIndex + 1;
        };

        [_fireMission, "unitIndex", _unitIndex] call ALIVE_fnc_hashSet;
        [_fireMission, "nextRoundTime", time + _delay] call ALIVE_fnc_hashSet;
    };

    [_fireMission, "roundsShot", _roundsShot + 1] call ALIVE_fnc_hashSet;
    _logic setVariable ["fireMission", _fireMission];
};
