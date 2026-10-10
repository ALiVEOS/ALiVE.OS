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
// A man walking to a slot isn't on it yet, so it's claimed for him for as long as his walk may
// take (it gives up after two minutes) and isn't handed to another group meanwhile. His own group
// garrisoning again gives it back to him, or to its next man if he has a post already.
private _placingGroup = group (_units param [0, objNull]);
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

    // Skip a position that already has a (non-player) occupant, or a man on his way to it, so
    // overlapping garrison groups don't stack two units on the same slot. Keeps the unit for the
    // next free one.
    (_x getVariable ["ALiVE_garrisonClaim", [objNull, 0]]) params ["_claimant", "_claimedUntil"];
    private _claimHeld = alive _claimant && {time < _claimedUntil};
    if ((!_claimHeld || {group _claimant == _placingGroup}) && {((nearestObjects [_cbaPos, ["CAManBase"], 1.5]) findIf {alive _x && {!isPlayer _x}}) == -1}) then {

        private _unit = [_units select 0, _claimant] select (_claimHeld && {_claimant in _units});

        if (_moveInstantly) then {
            _unit setPosATL _cbaPos;
            // A stop only takes on the machine that owns the man, which for a group a headless
            // client owns isn't the server running this.
            // Held there under fire as well, standing in his trench or post, the same as every
            // garrison post (see ALIVE_fnc_groupGarrison); his group's next order lets him go.
            if (local _unit) then {
                _unit setDir _cbaDir;
                doStop _unit;
                _unit setUnitPos "UP";
                _unit disableAI "PATH";
            } else {
                [_unit, _cbaDir] remoteExecCall ["setDir", _unit];
                _unit remoteExecCall ["doStop", _unit];
                [_unit, "UP"] remoteExecCall ["setUnitPos", _unit];
                [_unit, "PATH"] remoteExecCall ["disableAI", _unit];
            };
            _unit setVariable ["ALiVE_garrisonHeld", true, true];
            // The hold lives on the machine that owns the man, so it is put back if he moves to another, as when
            // a headless client takes the group. The handler only fires where it was added: server and headless clients.
            if !(_unit getVariable ["ALiVE_garrisonLocalEH", false]) then {
                _unit setVariable ["ALiVE_garrisonLocalEH", true];
                private _owners = [[clientOwner], (entities "HeadlessClient_F") select { isPlayer _x } apply { owner _x }] select isServer;
                [_unit, ["Local", { params ["_u", "_isLocal"]; if (_isLocal && {_u getVariable ["ALiVE_garrisonHeld", false]}) then { doStop _u; _u disableAI "PATH" } }]] remoteExecCall ["addEventHandler", ([2] + _owners) arrayIntersect ([2] + _owners)];
            };
        } else {
            _movementAssignments pushBack [_unit, _cbaPos, _cbaDir];
            _x setVariable ["ALiVE_garrisonClaim", [_unit, time + 125]];
        };

        _units deleteAt (_units find _unit);
    };
} forEach _cbaObjects;

_movementAssignments
