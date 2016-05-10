// Disarm IED - ran on client only
#include <\x\alive\addons\mil_IED\script_component.hpp>
SCRIPT(disarmIED);

private ["_debug","_IED","_caller","_wire","_success","_selectedWire","_id","_IEDCharge"];

if (isDedicated) exitWith {diag_log "disarmIED running on server!";};

_debug = ADDON getVariable ["debug", false];

_IED = _this select 0;
_caller = _this select 1;
_id = _this select 2;

_IEDCharge = _IED getVariable ["charge", nil];

//Display timer for IED disarm
hint "Disarming IED…";
// timer graphic hint?
// sleep 120;

// Get disarming unit to do something (choose red wire or blue wire). Chance that device is new and therefore requires disarmer to guess how to disarm
if ((random 1) > 0.85) then {

	if ((random 1) > 0.5) then {
		_wire = "blue";
	} else {
		_wire = "red";
	};

	tup_ied_wire = "";

	// Ask question about which wire
	_tup_iedPrompt = createDialog "tup_ied_DisarmPrompt";

	noesckey = (findDisplay 1600) displayAddEventHandler ["KeyDown", "if ((_this select 1) == 1) then { true }"];

	waitUntil {sleep 0.3; tup_ied_wire != ""};

	// Accept input
	_selectedWire = tup_ied_wire;

	// Check success
	if (_selectedWire == _wire) then {
		_success = true;
	} else {
		_success = false;
	};

	If  !(_success) then {
		private "_shell";
		// Failure to disarm results in detonation
		_shell = [["M_Mo_120mm_AT","M_Mo_120mm_AT_LG","M_Mo_82mm_AT_LG","R_60mm_HE","Bomb_04_F","Bomb_03_F"],[4,8,2,1,1,1]] call BIS_fnc_selectRandomWeighted;
		_shell createVehicle getposATL (_this select 0);
		// Remove triggers

		_trgr = (position _IED) nearObjects ["EmptyDetector", 3];
		{
			deleteVehicle _x;
		} foreach _trgr;

		[[ADDON, "removeIED", _IED] ,"ALiVE_fnc_IED", false, false, true] call BIS_fnc_MP;

		deleteVehicle _IEDCharge;
		deleteVehicle _IED;
	} else {

		// Remove triggers

		_trgr = (position _IED) nearObjects ["EmptyDetector", 3];
		{
			deleteVehicle _x;
		} foreach _trgr;

		if !(isNil "_IEDCharge") then {
			_IEDCharge removeEventHandler ["handleDamage", _IED getVariable "ehID"];
		};

		[[ADDON, "removeIED", _IED] ,"ALiVE_fnc_IED", false, false, true] call BIS_fnc_MP;

		hint "You guessed correct! IED is disarmed";
	};

} else {
	// Tell unit that IED is disarmed

	if !(isDedicated) then {
		_IED removeAction _id;
	} else {
		[[_IED, _id],"ALiVE_fnc_removeActionIED", true, true, true] call BIS_fnc_MP;
	};

	_trgr = (position _IED) nearObjects ["EmptyDetector", 3];
	{
		deleteVehicle _x;
	} foreach _trgr;

	if !(isNil "_IEDCharge") then {
		_IEDCharge removeEventHandler ["handleDamage", _IED getVariable "ehID"];
	};

	[[ADDON, "removeIED", _IED] ,"ALiVE_fnc_IED", false, false, true] call BIS_fnc_MP;

 	hint "IED is disarmed";
};