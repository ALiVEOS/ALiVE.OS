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
garrison groups don't stack two units on one slot. Non-instant moves are returned as
assignments for the caller's group movement worker. Does nothing when no CBA positions
are present. Shared by ALIVE_fnc_groupGarrison and
ALIVE_fnc_groupGarrisonSPE. (#945)

Parameters:
Array   - units still to place; MUTATED in place (filled units are removed)
Array   - centre position to search from
Number  - search radius for CBA_buildingPos objects
Boolean - optional, teleport (true, default) vs move-order (false)
Array   - optional, where the group stands; slots are handed out nearest to it.
          Defaults to the search centre, which is what every caller sent before.

Returns:
Array - non-instant movement assignments in the form [unit, ATL position, direction]

Examples:
(begin example)
private _movementAssignments = [_units, _position, _radius, false] call ALIVE_fnc_garrisonUnitsOnCBAPositions;
(end)

Author:
Jman
---------------------------------------------------------------------------- */

params ["_units", "_position", "_radius", ["_moveInstantly", true], ["_sortFrom", [], [[]]]];

private _movementAssignments = [];
// The sweep covers the area asked for, which for a placed garrison is the whole
// objective, but the slots are handed out nearest the men. nearestObjects returns them
// ordered from the sweep centre, so without this the first man of a group at the rim
// takes a trench slot on the far side of the objective (#1016).
if (_sortFrom isEqualTo []) then { _sortFrom = _position };
private _cbaObjects = nearestObjects [_position, ["CBA_buildingPos"], _radius];
_cbaObjects = [_cbaObjects, [], { _x distance2D _sortFrom }, "ASCEND"] call BIS_fnc_sortBy;

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
            _movementAssignments pushBack [_unit, _cbaPos, _cbaDir];
        };

        _units deleteAt 0;
    };
} forEach _cbaObjects;

_movementAssignments
