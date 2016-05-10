#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleTurrets);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleTurretPositions

Description:
Get turrets data for a vehicle class

Parameters:
String - vehicle class name
Boolean - Ignore Gunner (optional)
Boolean - Ignore Commander (optional)

Returns:
Array of turret data

Examples:
(begin example)
// get vehicle turret data
_result = "O_Heli_Attack_02_F" call ALIVE_fnc_configGetVehicleTurretPositions;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type","_ignoreGunner","_ignoreCommander","_ignorePlayerTurrets","_ignoreCopilot","_ignoreNonPlayerTurrets","_result","_findRecurse","_class"];

_type = _this select 0;
_ignoreGunner = if(count _this > 1) then {_this select 1} else {false};
_ignoreCommander = if(count _this > 2) then {_this select 2} else {false};
_ignorePlayerTurrets = if(count _this > 3) then {_this select 3} else {false};
_ignoreCopilot = if(count _this > 4) then {_this select 4} else {false};
_ignoreNonPlayerTurrets = if(count _this > 5) then {_this select 5} else {false};

_result = [];

_findRecurse = {
	private ["_root","_class","_path","_currentPath","_ignore","_primaryGunner","_primaryObserver","_copilot","_isPersonTurret"];
	
	_root = (_this select 0);
	_path = +(_this select 1);
	
	for "_i" from 0 to count _root -1 do {
	
		_class = _root select _i;
		
		if (isClass _class) then {
			_currentPath = _path + [_i];
			_ignore = false;

			_primaryGunner = false;
            _primaryObserver = false;
            _copilot = false;
            _isPersonTurret = false;
			
			if!(getNumber(_class >> "hasGunner") == 1) then {
				_ignore = true;
			};
			
			if(_ignoreGunner && getNumber(_class >> "primaryGunner") == 1) then {
			    _primaryGunner = true;
				_ignore = true;
			};
			
			if(_ignoreCommander && getNumber(_class >> "primaryObserver") == 1) then {
			    _primaryObserver = true;
				_ignore = true;
			};

			if(_ignoreCopilot && getNumber(_class >> "isCopilot") == 1) then {
                _copilot = true;
                _ignore = true;
            };

			if(getNumber(_class >> "isPersonTurret") == 1) then {
                _isPersonTurret = true;
            };

            if(!(_primaryGunner) && !(_primaryObserver) && !(_copilot)) then {
                if(_ignorePlayerTurrets) then {
                    if(_isPersonTurret) then {
                        _ignore = true;
                    };
                };
                if(_ignoreNonPlayerTurrets) then {
                	if!(_isPersonTurret) then {
						_ignore = true;
					};
                };
            };

			//["class: %1 ignore: %2 gunner: %3 observer: %4 person: %5",_class,_ignore,getNumber(_class >> "primaryGunner"),getNumber(_class >> "primaryObserver"),getNumber(_class >> "isPersonTurret")] call ALIVE_fnc_dump;
			
			if!(_ignore) then {
				_result pushback _currentPath;
			};			
			
			_class = _class >> "turrets";
			
			if (isClass _class) then {
				[_class, _currentPath] call _findRecurse;
			};
		};
	};
};

_class = (configFile >> "CfgVehicles" >> _type >> "turrets");

[_class, []] call _findRecurse;

/*
["GET TURRET POSITIONS: %1 %2",_type,_result] call ALIVE_fnc_dump;
_result call ALIVE_fnc_inspectArray;
*/

_result;