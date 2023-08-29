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
ARJay, Highhead, Jman
---------------------------------------------------------------------------- */
#define RND(var) random 1 > var

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_profileCount",0], ["_profileID",nil], ["_guardPatrolPercentage",50]];

private _units = units _group;
private _unitPercentCount = ((count _units) * _guardPatrolPercentage) / 100;
private _profile = nil;

// DEBUG -------------------------------------------------------------------------------------
if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
 ["ALIVE_fnc_groupGarrison - _unitPercentCount: %1", _unitPercentCount] call ALiVE_fnc_dump;
};
// DEBUG -------------------------------------------------------------------------------------

if !(isNil "_profileID") then {
 _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;
 // DEBUG -------------------------------------------------------------------------------------
 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
   ["ALIVE_fnc_groupGarrison - _profile: %1", _profile] call ALiVE_fnc_dump;
 };
 // DEBUG -------------------------------------------------------------------------------------
};

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

private _buildings = nearestObjects [_position,ALIVE_garrisonPositions select 1,_radius];
if (count _buildings == 0 || _profileCount > 3) then {
	 // DEBUG -------------------------------------------------------------------------------------
	 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
	  ["ALIVE_fnc_groupGarrison - _profileCount: %1, Getting ALIVE_fnc_getEnterableHouses()", _profileCount] call ALiVE_fnc_dump;
	 };
	 // DEBUG -------------------------------------------------------------------------------------
    _buildings = [_position, floor(_radius/2)] call ALIVE_fnc_getEnterableHouses;
};



if ((count _buildings == 0) && !(isNil "_profile") && ([_profile,"isCycling"] call ALiVE_fnc_HashGet)) exitwith {
	
	   private _id = [_profile,"profileID","error"] call ALiVE_fnc_HashGet;
	 	 private _thisGroup = [_profile,"group"] call ALiVE_fnc_HashGet;
	   [_thisGroup] call CBA_fnc_clearWaypoints;
	   [_profile,"isCycling",false] call ALIVE_fnc_hashSet;
	   [_profile,"busy",false] call ALIVE_fnc_hashSet;
	   [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
	   [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
	   // DEBUG -------------------------------------------------------------------------------------
	   if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
      ["ALIVE_fnc_groupGarrison - No enterable buildings found!. Calling CBA_fnc_taskSearchArea on: group: %1, profileID: %2, _radius %3", _group, _id, _radius] call ALiVE_fnc_dump;
	   }; 
	 	 // DEBUG ------------------------------------------------------------------------------------- 
	 	 [_group, [_position, _radius, _radius, 0, false]] call CBA_fnc_taskSearchArea;
};


{ // forEach _buildings
	
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
		    _buildingPositions append (_building buildingPos -1);
        [_buildingPositions, true] call CBA_fnc_Shuffle;
            
        // sort based on height
        _buildingPositions = [_buildingPositions, [], { _x select 2 }, "DESCEND"] call BIS_fnc_sortBy;      
        
        // DEBUG -------------------------------------------------------------------------------------  
        if (ALiVE_SYS_PROFILE_DEBUG_ON) then {     
         ["ALIVE_fnc_groupgarrison - class: %1 count positions: %2, count _units: %3", _class, count _buildingPositions, count units _group] call ALiVE_fnc_dump;  	
        };
        // DEBUG -------------------------------------------------------------------------------------
        
        { // foreach _buildingPositions

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
            
            if (_guardPatrolPercentage > 0) then {
            	 if (_unitPercentCount > 0 ) then {
                 // Patrol the buildings
                 [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
                 [_group, _unit, _buildings, ALiVE_SYS_PROFILE_DEBUG_ON] execFSM "\x\alive\addons\mil_command\buildingPatrol.fsm";
                 _unitPercentCount = _unitPercentCount -1;
               };
            }; 
            
            
            _units deleteAt 0;
        } foreach _buildingPositions;
    } else {
    	// DEBUG -------------------------------------------------------------------------------------
    	if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
    	 ["ALIVE_fnc_groupGarrison - _buildingIsEmpty: %3, count _buildings: %1, _buildings: %2", count _buildings, _buildings, _buildingIsEmpty] call ALiVE_fnc_dump;
    	};
    	// DEBUG -------------------------------------------------------------------------------------
    	 // if no buildings then patrol!
    	 if !(isNil "_profile") then {
    	 	 // DEBUG -------------------------------------------------------------------------------------
    	 	 if (ALiVE_SYS_PROFILE_DEBUG_ON) then {
    	 	  ["ALIVE_fnc_groupGarrison - No more empty buildings, lets patrol! calling ALIVE_fnc_ambientMovement"] call ALiVE_fnc_dump;
    	 	 };
    	 	 // DEBUG -------------------------------------------------------------------------------------
    	   [_profile,"clearWaypoints"] call ALIVE_fnc_profileEntity;
         [_profile, [200,"SAFE"]] call ALIVE_fnc_ambientMovement;
       };
    };
} forEach _buildings;