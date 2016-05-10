#include <\x\alive\addons\x_lib\script_component.hpp>
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

private ["_group","_position","_radius","_moveInstantly","_onlyProfiled","_units","_file","_leader","_units","_armedCars"];

_group = _this select 0;
_position = _this select 1;
_radius = _this select 2;
_moveInstantly = _this select 3;
_onlyProfiled = if (count _this > 4) then {_this select 4} else {false};

_units = units _group;
_leader = leader (group (_units select 0));
_units = _units - [_leader];

if (count _units == 0) exitwith {};

// load static data
if(isNil "ALiVE_STATIC_DATA_LOADED") then {
    _file = "\x\alive\addons\main\static\staticData.sqf";
    call compile preprocessFileLineNumbers _file;
};

if(!_moveInstantly) then {
    _group lockWP true;
};

// stop leader
doStop _leader;

// find and garrison any static weapons

private ["_staticWeapons","_weapon","_positionCount","_unit"];

_staticWeapons = nearestObjects [_position, ["StaticWeapon"], _radius];

// Find any cars that are armed or optionally are vehicle profiles
_armedCars = nearestObjects [_position, ["Car"], _radius];
{
    if (!([_x] call ALiVE_fnc_isArmed) || {_onlyProfiled && {isnil {_x getvariable "profileID"}}}) then {_armedCars = _armedCars - [_x]};
} foreach _armedCars;

_staticWeapons = _staticWeapons + _armedCars;

if(count _staticWeapons > 0) then
{
    {
        _weapon = _x;

        _positionCount = [_weapon] call ALIVE_fnc_vehicleCountEmptyPositions;

        if(count _units > 0) then {

            _unit = _units select 0;

            if(!isNil "_unit") then {

                if(_positionCount > 0) then
                {
                    if(_moveInstantly) then {

                        _unit assignAsGunner _weapon;
                        _unit moveInGunner _weapon;

                    }else{

                        _unit assignAsGunner _weapon;
                        [_unit] orderGetIn true;

                    };

                };

                _units = _units - [_unit];

            };

        };

    } forEach _staticWeapons;
};

if (count _units == 0) exitwith {};

// find and garrison any predefined military buildings

private ["_buildings","_building","_class","_buildingPositions","_position"];

_buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];

if(count _buildings > 0) then {
    {
        _building = _x;
        _class = typeOf _building;

        _buildingPositions = [ALIVE_garrisonPositions,_class] call ALIVE_fnc_hashGet;

        if!(isNil "_buildingPositions") then {

            {
                if (_foreachIndex > ((count _units)-1)) exitwith {};

                if(count _units > 0) then {

                    _unit = _units select 0;

                    if(!isNil "_unit") then {

                        if(_moveInstantly) then {
                            _unit setposATL (_building buildingpos _x);
                            _unit setdir ((_unit getRelDir _building)-180);
                            _unit setUnitPos "UP";
                            
                            //_unit disableAI "MOVE";
                            
                            dostop _unit;
                            sleep 0.03;
                        }else{
                            _position = (_building buildingpos _x);

                            [_unit,_position] spawn {

                                private ["_unit","_position"];

                                _unit = _this select 0;
                                _position = _this select 1;

                                [_unit, _position] call ALiVE_fnc_doMoveRemote;

                                waitUntil {sleep 1; _unit call ALiVE_fnc_unitReadyRemote};

                                doStop _unit;
                            };

                        };

                        _units = _units - [_unit];

                    };
                };

            } foreach _buildingPositions;

        };


    } forEach _buildings;

}else{

    // find and garrison any nearby buildings

    _buildings = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;

    {
        _building = _x;

        _buildingPositions = [_building] call ALIVE_fnc_getBuildingPositions;

        {
            if (_foreachIndex > ((count _units)-1)) exitwith {};

            if(count _units > 0) then {

                _unit = _units select 0;

                if(!isNil "_unit") then {

                    if(_moveInstantly) then {
                        //_unit setposATL (_building buildingpos _x);
                        _unit setposATL _x;
                        _unit setdir ((_unit getRelDir _building)-180);
                        _unit setUnitPos "UP";
                        //_unit disableAI "MOVE";
                        sleep 0.03;
                        doStop _unit;
                        sleep 0.03;
                    }else{
                        //_position = (_building buildingpos _x);
                        _position = _x;

                        [_unit,_position] spawn {

                            private ["_unit","_position"];

                            _unit = _this select 0;
                            _position = _this select 1;

                            [_unit, _position] call ALiVE_fnc_doMoveRemote;

                            waitUntil {sleep 0.5; _unit call ALiVE_fnc_unitReadyRemote};

                            doStop _unit;
                        };
                    };

                    _units = _units - [_unit];

                };

            };

        } foreach _buildingPositions;

    } forEach _buildings;

};


