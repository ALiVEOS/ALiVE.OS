#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(vehicleGenerateEmptyPositionData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_vehicleGenerateEmptyPositionData

Description:
Outputs all empty vehicle positions to RPT file in hash format

Parameters:

Returns:

Examples:
(begin example)
// generate vehcile position hash
_result = [] call ALIVE_fnc_vehicleGenerateEmptyPositionData;
(end)

See Also:
ALIVE_fnc_vehicleCountEmptyPositions
ALIVE_fnc_vehicleGetEmptyPositions

Author:
ARJay
---------------------------------------------------------------------------- */

[] spawn {

	private ["_cfg","_pos","_exportString","_item","_class","_type","_scope","_vehicle","_countPositions","_positions","_count"];
		
	_cfg = configFile >> "CfgVehicles";
	_pos = getPos player;
	_exportString = "";
	
	for "_i" from 0 to (count _cfg)-1 do {
	
		_item = _cfg select _i;
		
		if(isClass _item) then
		{
			_class = configName _item;
			_type = getNumber(_item >> "type");
			_scope = getNumber(_item >> "scope");
			
			if(_scope == 2) then {
				_positions = [_class] call ALIVE_fnc_configGetVehicleEmptyPositions;
				_count = 0;
				{
					_count = _count + _x;
				} forEach _positions;

				if(_count > 0) then {
					_exportString = _exportString + format['[ALIVE_vehiclePositions,"%1",%2] call ALIVE_fnc_hashSet;',_class,_positions];
				};
			};
		};
	};	
	
	copyToClipboard _exportString;
	["Generate vehicle empty positions analysis complete, results have been copied to the clipboard"] call ALIVE_fnc_dump;
};