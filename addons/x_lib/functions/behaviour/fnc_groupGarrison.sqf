#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGarrison);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrison
Description:
Garrisons units in defensible structures and static weapons
Parameters:
Group - group
Array - position
Scalar - radius
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Returns:
Examples:
(begin example)
[_group,_position,200,true] call ALIVE_fnc_groupGarrison;
(end)
See Also:
Author:
ARJay, Highhead
---------------------------------------------------------------------------- */

private _group = _this select 0;
private _position = _this select 1;
private _radius = _this select 2;
private _moveInstantly = _this select 3;
private _onlyProfiled = if (count _this > 4) then {_this select 4} else {false};

private _units = units _group;

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
    if ([_x] call ALIVE_fnc_isArmed && {!(_onlyProfiled && !(isNil {_x getVariable "profileID"}))}) then {
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

private _buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];
if (count _buildings == 0) then {
    _buildings = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;
};

// TODO(marcel): Spread units out over multiple buildings?
{
    if (count _units == 0) exitWith {};

    private _building = _x;
    private _class = typeOf _building;

    private _buildingIsEmpty = true;
    {
        if ((_x getVariable ["alive_garrison_buildings", []]) find _building != -1) exitWith {
            _buildingIsEmpty = false;
        };
    } forEach (allGroups select {_x != _group && {side _x == side _group}});

    if (_buildingIsEmpty) then {
        private _buildingPositions = [];
        if ((ALIVE_garrisonPositions select 1) find _class != -1) then {
            {
                private _buildingPos = _building buildingPos _x;
                if !(_buildingPos isEqualTo [0,0,0]) then {
                    _buildingPositions pushBack _buildingPos;
                };
            } forEach ([ALIVE_garrisonPositions,_class] call ALIVE_fnc_hashGet);
        } else {
            _buildingPositions = _building buildingPos -1;
        };

        {
            if (count _units == 0) exitWith {};

            _garrisonedBuildings pushBackUnique _building;

            private _unit = _units select 0;
            private _position = _x;

            if (_moveInstantly) then {
                _unit setposATL _position;
                _unit setdir ((_unit getRelDir _building)-180);

                dostop _unit;
            } else {
                [_unit, _position, _building] spawn {
                    private _unit = _this select 0;
                    private _position = _this select 1;
                    private _building = _this select 2;

                    [_unit, _position] call ALiVE_fnc_doMoveRemote;

                    waitUntil {sleep 1; _unit call ALiVE_fnc_unitReadyRemote};

                    doStop _unit;
                };
            };

            _units deleteAt 0;
        } foreach _buildingPositions;
    };
} forEach _buildings;
