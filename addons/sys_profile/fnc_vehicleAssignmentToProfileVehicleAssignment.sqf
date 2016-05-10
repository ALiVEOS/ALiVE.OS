#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(vehicleAssignmentToProfileVehicleAssignment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment

Description:
Read a real vehicles assignments and return a profileVehicle assignment

Parameters:
Vehicle - The vehicle
Group - The group

Returns:
assignments array

Examples:
(begin example)
// read group assignments for vehicle
_result = [_vehicle, _group] call ALIVE_fnc_vehicleAssignmentToProfileVehicleAssignment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_vehicle","_group","_units","_unitIndex","_assignments","_inVehicle","_assignedRole","_assignedRoleName","_cargo","_turret",
"_assignedTurret","_turretConfig","_turretIsGunner","_turretIsCommander","_turretIsPerson","_isTurret","_gunner","_commander"];

_vehicle = _this select 0;
_group = _this select 1;

_units = units _group;
_unitIndex = 0;

_assignments = [[],[],[],[],[],[]];

{
	_inVehicle = (vehicle _x);
	
	if(_inVehicle == _vehicle) then {
	
		_assignedRole = assignedVehicleRole _x;
		_assignedRoleName = _assignedRole select 0;

		//["ASS ROLE: %1",_assignedRoleName] call ALIVE_fnc_dump;
        
        if !(isnil "_assignedRoleName") then {

            _assignedRoleName = toLower(_assignedRoleName);

			switch(_assignedRoleName) do {
				case "driver":{
					_assignments set [0, [_unitIndex]];
				};
				case "cargo":{
					_cargo = _assignments select 4;
					_cargo set [count _cargo,_unitIndex];
					_assignments set [4, _cargo];
				};
				case "turret":{
					_assignedTurret = _assignedRole select 1;
					_turretConfig = [_vehicle, _assignedTurret] call CBA_fnc_getTurret;
					_turretIsGunner = getNumber(_turretConfig >> "primaryGunner");
					_turretIsCommander = getNumber(_turretConfig >> "primaryObserver");
					_turretIsPerson = getNumber(_turretConfig >> "isPersonTurret");
					_isTurret = true;				
					
					if(_turretIsGunner == 1) then {
						_gunner = _assignments select 1;
						_gunner set [count _gunner,_unitIndex];
						_assignments set [1, _gunner];
						_isTurret = false;
					};
					
					if(_turretIsCommander == 1) then {
						_commander = _assignments select 2;
						_commander set [count _commander,_unitIndex];
						_assignments set [2, _commander];
						_isTurret = false;
					};

					if(_turretIsPerson == 1) then {
					    _isTurret = false;
					    _turret = _assignments select 5;
						_turret set [count _turret,_unitIndex];
						_assignments set [5, _turret];
					};
					
					if(_isTurret) then {
						_turret = _assignments select 3;
						_turret set [count _turret,_unitIndex];
						_assignments set [3, _turret];
					};

					/*
					["ASS TUR: %1",_assignedTurret] call ALIVE_fnc_dump;
					["ASS TUR GUN: %1",_turretIsGunner] call ALIVE_fnc_dump;
					["ASS TUR COMMAND: %1",_turretIsCommander] call ALIVE_fnc_dump;
					["ASS TUR PERSON: %1",_turretIsPerson] call ALIVE_fnc_dump;
					["ASS TUR TUR: %1",_isTurret] call ALIVE_fnc_dump;
					*/
				};
			};
        };
	};	
	_unitIndex = _unitIndex + 1;
} forEach _units;

//["ASS: %1",_assignments] call ALIVE_fnc_dump;

_assignments