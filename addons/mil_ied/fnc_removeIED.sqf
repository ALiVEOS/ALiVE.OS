#include <\x\alive\addons\mil_ied\script_component.hpp>
SCRIPT(removeIED);

// Remove IED
private ["_IEDs","_town","_position","_size","_j","_nodel","_debug"];

if !(isServer) exitWith {diag_log "RemoveIED Not running on server!";};

_position = _this select 0;
_town = _this select 1;

_IEDs = [[GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet, _town] call ALiVE_fnc_hashGet;

	//["REMOVE IED: %1",_IEDs] call ALIVE_fnc_dump;

_removeIED = {
	private ["_IED","_IEDObj","_IEDCharge","_IEDskin","_IEDpos","_trgr"];
	_IEDpos = [_value, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;
	_IEDskin = [_value, "IEDskin", "ALIVE_IEDUrbanSmall_Remote_Ammo"] call ALiVE_fnc_hashGet;

	// Delete Objects
	_IEDObj = (_IEDpos nearObjects [_IEDskin, 4]) select 0;

	//["REMOVE IED: %1, %2, %3",_IEDpos, _IEDskin, _IEDObj] call ALIVE_fnc_dump;

	if (isNil "_IEDObj") then {
		diag_log "IED NOT FOUND";
	};
	_IEDCharge = _IEDobj getVariable ["charge", nil];

	// Delete Triggers
	_trgr = (position _IEDObj) nearObjects ["EmptyDetector", 3];
	{
		deleteVehicle _x;
	} foreach _trgr;

	deleteVehicle _IEDCharge;
	deleteVehicle _IEDObj;

};

[_IEDs, _removeIED] call CBA_fnc_hashEachPair;

if ([ADDON, "debug"] call MAINCLASS) then {
	["Removed IEDs at %1 (%2)", _town, _position ] call ALIVE_fnc_dump;
};