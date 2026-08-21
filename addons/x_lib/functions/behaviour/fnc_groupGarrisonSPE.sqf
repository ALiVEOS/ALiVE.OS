#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGarrisonSPE);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrisonSPE
Description:
Garrisons units in area and static weapons
Parameters:
Group - group
Array - position
Scalar - radius
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Returns:
Examples:
(begin example)
[_group,_position,200,true] call ALIVE_fnc_groupGarrisonSPE;
(end)
See Also:
Author:
Jman
---------------------------------------------------------------------------- */

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_cbaSearchRadius", 300]];

private _units = units _group;
_radius = 50;

[_group] call ALiVE_fnc_releaseGarrisonBuildings;

if (count _units < 2) exitwith {};

call ALiVE_fnc_staticDataHandler;

if (!_moveInstantly) then {
    _group lockWP true;
};

private _staticWeapons = nearestObjects [_position, ["StaticWeapon"], _radius];

// Add armed vehicles to list of static weapons to garrison
{
    if ([_x] call ALIVE_fnc_isArmed && { !_onlyProfiled || !isnil { _x getVariable "profileID" } }) then {
        _staticWeapons pushBack _x;
    };
} foreach (nearestObjects [_position, ["Car"], _radius]);

if (count _staticWeapons > 0) then
{
    {
        if (count _units == 0) exitWith {};

        private _weapon = _x;
        private _positionCount = [_weapon] call ALIVE_fnc_vehicleCountEmptyPositions;
        private _unit = _units select 0;

        if (_positionCount > 0) then {
            if (_moveInstantly) then {
                _unit assignAsGunner _weapon;
                _unit moveInGunner _weapon;
            } else {
                _unit assignAsGunner _weapon;
                [_unit] orderGetIn true;
            };
        };

        _units deleteAt 0;
    } forEach _staticWeapons;
};

if (count _units == 0) exitwith {};

// Garrison any remaining units onto CBA AI Building Positions (CBA_buildingPos objects) when
// the mission-maker has placed them, so a Garrison Objective mans custom positions such as
// trench slots. Sweep the whole objective (radius = the objective's Size, passed in), not just
// the 50 m static-weapon search above -- a trench / defensive line can span well beyond it. (#945)
private _movementAssignments = [_units, _position, _cbaSearchRadius, _moveInstantly] call ALIVE_fnc_garrisonUnitsOnCBAPositions;

if !(_movementAssignments isEqualTo []) then {
    [_group, _movementAssignments] spawn {
        params ["_movementGroup", "_assignments"];

        {
            _x params ["_unit", "_destination"];
            [_unit, _destination] call ALiVE_fnc_doMoveRemote;
        } forEach _assignments;

        waitUntil {
            sleep 3;

            {
                _x params ["_unit", "_destination", ["_direction", -1]];
                private _stillAssigned = !isNull _unit && {alive _unit} && {group _unit isEqualTo _movementGroup};

                if (!_stillAssigned || {_unit call ALiVE_fnc_unitReadyRemote}) then {
                    if (_stillAssigned) then {
                        if (_direction >= 0) then {
                            _unit setDir _direction;
                        };
                        doStop _unit;
                    };
                    _assignments deleteAt _forEachIndex;
                };
            } forEachReversed _assignments;

            _assignments isEqualTo []
        };
    };
};
