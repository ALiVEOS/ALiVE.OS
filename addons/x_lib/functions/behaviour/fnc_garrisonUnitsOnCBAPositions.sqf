#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(garrisonUnitsOnCBAPositions);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_garrisonUnitsOnCBAPositions

Description:
Garrisons units onto CBA AI Building Positions (objects of class "CBA_buildingPos",
from CBA's Custom Building Position module) found within a radius of a centre
position. Consumes units from the passed array as it fills positions (the array is
MUTATED in place -- filled units are removed), orients each unit to its position's
facing, and skips any position that already has a non-player occupant so overlapping
garrison groups don't stack two units on one slot. Does nothing when no CBA positions
are present. Shared by ALIVE_fnc_groupGarrison and ALIVE_fnc_groupGarrisonSPE. (#945)

Parameters:
Array   - units still to place; MUTATED in place (filled units are removed)
Array   - centre position to search from
Number  - search radius for CBA_buildingPos objects
Boolean - optional, teleport (true, default) vs move-order (false)

Returns:
nil

Examples:
(begin example)
[_units, _position, _radius, true] call ALIVE_fnc_garrisonUnitsOnCBAPositions;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params ["_units", "_position", "_radius", ["_moveInstantly", true]];

private _cbaObjects = nearestObjects [_position, ["CBA_buildingPos"], _radius];

{
    if (count _units == 0) exitWith {};

    private _cbaPos = getPosATL _x;
    private _cbaDir = getDir _x;

    // Skip a position that already has a (non-player) occupant, so overlapping garrison
    // groups don't stack two units on the same slot. Keeps the unit for the next free one.
    if (((nearestObjects [_cbaPos, ["CAManBase"], 1.5]) findIf {alive _x && {!isPlayer _x}}) == -1) then {

        private _unit = _units select 0;

        if (_moveInstantly) then {
            _unit setPosATL _cbaPos;
            _unit setDir _cbaDir;
            doStop _unit;
        } else {
            [_unit, _cbaPos, _cbaDir] spawn {
                params ["_unit", "_cbaPos", "_cbaDir"];
                [_unit, _cbaPos] call ALiVE_fnc_doMoveRemote;
                waitUntil {sleep 1; _unit call ALiVE_fnc_unitReadyRemote};
                _unit setDir _cbaDir;
                doStop _unit;
            };
        };

        _units deleteAt 0;
    };
} forEach _cbaObjects;
