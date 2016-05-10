#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(ambush);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ambush

Description:
Garrison command for active units, run on spawn of profiles for guarding of objectives via placement modules

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_ambush","spawn",[_destinationPos]]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_type","_unit","_profile","_profileID","_pos","_radius","_assignments","_group","_sidesEnemy"];

_profile = [_this, 0, ["",[],[],nil], [[]]] call BIS_fnc_param;
_params = [_this, 1, [], [[]]] call BIS_fnc_param;
_destination = [_params, 2, [0,0,0], [[]]] call BIS_fnc_param;

if (isnil "_profile") exitwith {};

_profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
_type = [_profile,"type",""] call ALiVE_fnc_HashGet;
_assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;
_pos = [_profile,"position"] call ALiVE_fnc_HashGet;
_bombs = [];

if (isnil "_pos") exitwith {};

waituntil {sleep 0.5; [_profile,"active"] call ALiVE_fnc_HashGet};
waituntil {sleep 0.5; !isnil {(_profile select 2 select 13)} && {!isnull (_profile select 2 select 13)}};

if (_type == "entity") then {
    private ["_driver","_gunner","_inVehicle"];
    
    _group = _profile select 2 select 13;
    _units = +(units _group);

	waituntil {sleep 2; {alive _x && _x distance _destination < 50} count _units > 0 || count _units == 0};

	_roads = _destination nearRoads 50;
    
    if (count _roads > 0) then {
        {
			_agent = _x;

			[_agent, getposATL (_roads call BIS_fnc_SelectRandom)] call ALiVE_fnc_doMoveRemote;
            
            sleep 5;
                   
			_agent playActionNow "PutDown";
			_bomb = "DemoCharge_Remote_Ammo_Scripted" createVehicle (getposATL _agent);
			_bomb setposATL (getposATL _agent);
            
			_bombs pushBack _bomb;
        } foreach _units;

        _newPosition = [
			_destination, 
			100, 
			250,
			1, 
			0, 
			100,
			0, 
			[], 
			[_destination]
		] call BIS_fnc_findSafePos;

        [_group,_newPosition] call ALiVE_fnc_MoveRemote;
        _group setbehaviour "AWARE";
		_group setSpeedmode "NORMAL";
       
        [_bombs,_destination] spawn {
            _time = time; waituntil {sleep 2; {_x distance (_this select 1) < 20} count vehicles > 0 || {time - _time > 1800}};
            
            // timeout
            if (time - _time >= 1800) then {
                {deletevehicle _x} foreach (_this select 0);
            // detonate
            } else {
                {_x setdamage 1} foreach (_this select 0);
            };
        };        
    };
};