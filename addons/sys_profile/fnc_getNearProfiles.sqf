#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(getNearProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getNearProfiles

Description:
Returns an array of profiles within the passed radius

Parameters:
Array - position center of search
Scalar - radius of search

Returns:
Array of profiles

Examples:
(begin example)
// get profiles within the radius
_profiles = [getPos player, 500, ["WEST","vehicle","Car"]] call ALIVE_fnc_getNearProfiles;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position","_radius","_categorySelector","_result","_profiles","_categorySide","_categoryType","_categoryObjectType","_side","_type","_objectType","_profilePosition"];
	
_position = _this select 0;
_radius = _this select 1;
_categorySelector = if(count _this > 2) then {_this select 2} else {[]};

_result = [];

//Exit if ALIVE_profileHandler is not existing for any reason (f.e. due to being called on a remote locality with fnc_isEnemyNear)
if (isNil "ALIVE_profileHandler") exitwith {_result};

_profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;

if(count _categorySelector > 0) then {
	_categorySide = _categorySelector select 0;
	_categoryType = _categorySelector select 1;
	_categoryObjectType = if(count _categorySelector > 2) then {_categorySelector select 2} else {"none"};
	
	{
		if !(isnil "_x") then { 
		_type = _x select 2 select 5;
			if(_type == _categoryType) then {
			
				_side = _x select 2 select 3;

				if(_side == _categorySide) then {
								
					if(_categoryObjectType != "none") then {
					
						_objectType = _x select 2 select 6;
						
						if(_categoryObjectType == _objectType) then {
						
							_profilePosition = _x select 2 select 2;
							
							if(_position distance _profilePosition < _radius) then {
								_result pushback _x;
							};					
						};				
					}else{
					
						_profilePosition = _x select 2 select 2;
						
						if(_position distance _profilePosition < _radius) then {
							_result pushback _x;
						};				
					};
				};
			};
       };
	}forEach (_profiles select 2);
}else{
	_categoryType = "entity";
	
	{
        if !(isnil "_x") then {
			_type = _x select 2 select 5;
					
			if(_type == _categoryType) then {
			
				_profilePosition = _x select 2 select 2;
	            
	            //diag_log format ["NearEntitiescheck: _profilePosition by select %1 | _pos by hash %2",_profilePosition,([_x,"position"] call ALIVE_fnc_hashGet)];
				
				if(_position distance _profilePosition < _radius) then {
					_result pushback _x;
				};			
			};
        };
	}forEach (_profiles select 2);
};

_result