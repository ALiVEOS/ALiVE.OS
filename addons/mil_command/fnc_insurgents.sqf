#include <\x\alive\addons\mil_command\script_component.hpp>
SCRIPT(insurgents);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_insurgents

Description:
Garrison command for active units, run on spawn of profiles for guarding of objectives via placement modules

Parameters:
Profile - profile
Args - array

Returns:

Examples:
(begin example)
[_profile, "setActiveCommand", ["ALIVE_fnc_insurgents","spawn",[]]] call ALIVE_fnc_profileEntity;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_type","_unit","_profile","_profileID","_pos","_radius","_assignments","_group","_sidesEnemy"];

_profile = [_this, 0, ["",[],[],nil], [[]]] call BIS_fnc_param;
_params = [_this, 1, [], [[]]] call BIS_fnc_param;
_sidesEnemy = [_params, 0, ["WEST"], [[]]] call BIS_fnc_param;

_sidesEnemy = +_sidesEnemy;

if (isnil "_profile") exitwith {};

_profileID = [_profile,"profileID"] call ALiVE_fnc_HashGet;
_type = [_profile,"type",""] call ALiVE_fnc_HashGet;
_assignments = [_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_HashGet;
_pos = [_profile,"position"] call ALiVE_fnc_HashGet;

if (isnil "_pos") exitwith {};

{
    if (_x == "GUER") then {_sidesEnemy set [_foreachIndex,RESISTANCE]} else {
        if (_x == "CIV") then {_sidesEnemy set [_foreachIndex,CIVILIAN]} else {
            if (_x == "EAST") then {_sidesEnemy set [_foreachIndex,EAST]} else {
                if (_x == "WEST") then {_sidesEnemy set [_foreachIndex,WEST]};
            };
        };
    };
} foreach _sidesEnemy;




waituntil {sleep 0.5; [_profile,"active"] call ALiVE_fnc_HashGet};
waituntil {sleep 0.5; !isnil {(_profile select 2 select 13)} && {!isnull (_profile select 2 select 13)}};




if (_type == "entity") then {
    
    private ["_driver","_gunner","_inVehicle"];
    
    _group = _profile select 2 select 13;
    _units = +(units _group);

    waituntil {
        sleep 5;
        
        count ((getposATL (leader _group) nearEntities ["CAManBase",50]) - _units) > 0
    };
    
	_side = side _group;
    _units = +(units _group);
    _speedMode = speedmode _group;
    _behaviour = behaviour (leader _group);
    _position = getposATL (leader _group);
    
    _inVehicle = false;
    _vehicle = vehicle (leader _group);
    
    if (_vehicle != leader _group) then {
        _inVehicle = true;
        _driver = driver _vehicle;
        _gunner = gunner _vehicle;
    };
    
    _fate = "attack"; if ((random 1) <= 0.3) then {_fate = "suicide"};
	    
    switch (_fate) do {
        
        case ("attack") : {
            private ["_target"];
            
	        _armed = false;
	        _tempGroupE = creategroup EAST;
            
	        while {sleep 1; {alive _x} count _units > 0} do {

                if (isnil "_target") then {
	                _list = _position nearEntities ["CAManBase",60];
	            	
                    {
                        if !((side _x) in _sidesEnemy) then {
                        	_list set [_foreachindex,objnull];
                        };
                    } foreach _list;
                    
                    _list = _list - [_units,objnull];
                    
                    if (count _list > 0) then {_target = _list call BIS_fnc_SelectRandom};
                };
                		        
	            if (!isnil "_target" && {alive _target} && {{alive _x && {_x distance _target < 20}} count _units > 0}) then {
                    
                    if !(alive _target) exitwith {_target = nil};
					
	                if !(_armed) then {
	                    _armed = true;
	                    
	                    if (isnull _tempGroupE) then {deletegroup _tempGroupE;_tempGroupE = creategroup EAST};
	                    
	                    _cwp = currentWaypoint _group;
	                    _tempGroupE copyWaypoints _group;
	                    
	                	_units join _tempGroupE;
	                    _tempGroupE setCurrentWaypoint [_tempGroupE,_cwp];
	
	                    _group setVariable ["profileID",nil];
	                    _tempGroupE setVariable ["profileID",_profileID];
	                    
	                    [_profile,"group",_tempGroupE] call ALiVE_fnc_HashSet;
                        
                        {_x leaveVehicle _vehicle} foreach _units;
	                    
	                    _tempGroupE setspeedmode "NORMAL";
	                    _tempGroupE setbehaviour "AWARE";
	
			            {
				            removeallweapons _x;
				            
				            _x addMagazine "30Rnd_9x21_Mag";
							_x addWeapon "hgun_P07_F";
	                        
	                        _x dowatch _target;
	                        _x doTarget _target;
	                        _x suppressFor 10;
				        } foreach _units;
	                };
	            } else {
	                if (_armed) then {
	                    
	                    if !({_x distance _target < 100} count _units == 0) exitWith {};
	                    
	                    _armed = false;
	                    
						if (isnull _group) then {deletegroup _group; _group = creategroup _side};
	                    
	                    _cwp = currentWaypoint _tempGroupE;
	                    _group copyWaypoints _tempGroupE;
		                
	                    _units join _group;
	                    _group setCurrentWaypoint [_group,_cwp];
	
						_tempGroupE setVariable ["profileID",nil];
	                    _group setVariable ["profileID",_profileID];
	                    
	                    [_profile,"group",_group] call ALiVE_fnc_HashSet;
                        
                        {removeallweapons _x} foreach _units;

						if (_inVehicle) then {
	                        _driver assignAsDriver _vehicle;
	                        _gunner assignasgunner _vehicle;
	                        {_x assignAsCargo _vehicle} foreach (_units - [_driver,_gunner]);
                            
                            _units orderGetin true;
	    				};

						_group setspeedmode _speedmode;
	                    _group setbehaviour _behaviour;                                        
	                };
	            };
	            
	            //["_Group %1 | _tempGroupE %2 | units %3 | null %4 | WP %5",units _group, units _tempGroupE, _units, isnull _tempGroupE || isnull _group, waypoints _group] call ALiVE_fnc_DumpH;
	            
	            sleep 1;
	        };
	
			deletegroup _tempGroupE;
        };
        
        case ("suicide") : {

            while {sleep 3; {alive _x} count _units > 0} do {
                
                if (isnil "_target" || {!alive _target}) then {
		            _list = _position nearEntities ["CAManBase",60];
		        	
		            {
		                if !((side _x) in _sidesEnemy) then {
		                	_list set [_foreachindex,objnull];
		                };
		            } foreach _list;
		            
		            _list = _list - [_units,objnull];
		        
		        	if (count _list > 0) then {_target = _list call BIS_fnc_SelectRandom};
                };
                
                if (!isnil "_target" && {alive _target}) then {
	                {
	                    if ((_x distance _target) < 5) exitwith {"Bo_GBU12_LGB_MI10" createvehicle (getposATL _x)};
	                    
	                    if !([_target,_x] call ALiVE_fnc_canSee) then {
	                        
	                        _x setspeedmode "FULL";
	                        _x setbehaviour "CARELESS";
                            [_x, getposATL _target] call ALiVE_fnc_doMoveRemote;
	                    } else {
	                        
	                        _x setspeedmode _speedmode;
	                        _x setbehaviour _behaviour;                          
	                    };
	                } foreach _units;
                };
            };
        };
    };
};