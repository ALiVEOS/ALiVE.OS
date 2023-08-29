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

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false]];

private _units = units _group;
_radius = 50;
if (isNil {_group getVariable "alive_garrison_buildings"}) then {
    _group setVariable ["alive_garrison_buildings", []];
};
private _garrisonedBuildings = _group getVariable ["alive_garrison_buildings", []];

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