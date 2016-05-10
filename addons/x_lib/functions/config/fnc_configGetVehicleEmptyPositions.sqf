#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetVehicleEmptyPositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configGetVehicleEmptyPositions

Description:
Get an array of empty positions for the vehicle from config

Parameters:
String - The vehicle class name

Returns:
Array of empty positions [driver, gunner, commander, turretsEmpty, cargo]

Examples:
(begin example)
// get empty positions array
_result = ["B_Truck_01_transport_F"] call ALIVE_fnc_configGetVehicleEmptyPositions;
// returns [1,0,0,0,17]
(end)

See Also:

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private ["_vehicle","_positions","_class","_turretEmptyCount","_playerTurretEmptyCount","_findRecurse","_turrets"];
	
_vehicle = _this select 0;

_positions = [0,0,0,0,0,0];
_class = (configFile >> "CfgVehicles" >> _vehicle);

_positions set [0, getNumber(_class >> "hasDriver")];

// get turrets for this class ignoring gunner and commander turrets
_turretEmptyCount = 0;
_playerTurretEmptyCount = 0;

_findRecurse = {
	private ["_root","_turret","_path","_currentPath","_hasGunner","_primaryGunner","_primaryObserver","_copilot","_isPersonTurret"];
	
	_root = (_this select 0);
	_path = +(_this select 1);
	
	for "_i" from 0 to count _root -1 do {
	
		_turret = _root select _i;
		
		if (isClass _turret) then {
			_currentPath = _path + [_i];
			
			_primaryGunner = false;
			_primaryObserver = false;
			_copilot = false;
			_isPersonTurret = false;

			if(getNumber(_turret >> "primaryGunner") == 1) then {
				_primaryGunner = true;
				_positions set [1, 1];
			};
			
			if(getNumber(_turret >> "primaryObserver") == 1) then {
				_primaryObserver = true;
				_positions set [2, 1];
			};

			if(getNumber(_turret >> "isCopilot") == 1) then {
			    if(_vehicle == "B_Heli_Light_01_F") then {
			        _copilot = true;
			        _turretEmptyCount = _turretEmptyCount +1;
                };
			};

			if(getNumber(_turret >> "isPersonTurret") == 1) then {
			    _isPersonTurret = true;
			};

			if(!(_primaryGunner) && !(_primaryObserver) && !(_copilot)) then {
				if!(_isPersonTurret) then {
					_turretEmptyCount = _turretEmptyCount +1;
                }else{
                	_playerTurretEmptyCount = _playerTurretEmptyCount +1;
                };
			};

			//["PG: %1 PO: %2", _primaryGunner,_primaryObserver] call ALIVE_fnc_dump;
			
			_turret = _turret >> "turrets";
			
			if (isClass _turret) then {
				[_turret, _currentPath] call _findRecurse;
			};
		};
	};
};

_turrets = (configFile >> "CfgVehicles" >> _vehicle >> "turrets");

[_turrets, []] call _findRecurse;


_positions set [3, _turretEmptyCount];
_positions set [4, getNumber(_class >> "transportSoldier")];
_positions set [5, _playerTurretEmptyCount];

/*
["GET EMPTY POSITIONS: %1 %2",_vehicle,_positions] call ALIVE_fnc_dump;
_positions call ALIVE_fnc_inspectArray;
*/

_positions;