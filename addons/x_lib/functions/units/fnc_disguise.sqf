#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(disguise);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_disguise

Description:
Disguises given unit as the given enemy target if there are no nearby hostile units watching. Mind also civilians could be hostile.
Cover will be blown if unit is near enemies that can also see the unit and the unit acts obvious (shooting, running, etc.) or if the uniform is changed.

- Will add an action "Disguise as the enemy" on the local player client if called via "call ALIVE_fnc_disguise".
- Action will persist on respawn.
- Runs locally on players client only and therefore won't affect server performance at all.

Parameters:
ARRAY [_target,_unit]

Returns:
NUMBER (SCRIPTHANDLE) - if disguising process is running
NIL - if script is finished (f.e. if called without or empty params for initialization);

Examples:
(begin example)
// Initialize process (only add persistent actions and eventhandler)
call ALIVE_fnc_disguise;

// Initialize process and disguise as the officer you killed
_scriptHandle = [_killedOfficer, player] call ALIVE_fnc_disguise;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

///////////////////////////////////////////
/// Prerequisities
///////////////////////////////////////////

//Only on run on player clients
if !(hasInterface) exitwith {["ALiVE_fnc_disguise not running on players client - exiting!"] call ALiVE_fnc_Dump};

params [
	["_target", objNull, [objNull,[]]],
	["_unit", objNull, [objNull,[]]],
	["_debug",false]
];

waituntil {!isNull player};

///////////////////////////////////////////
/// Init, set up EH and actions
///////////////////////////////////////////

//Get existing or create local EH
private _EH = player getvariable QGVAR(DISGUISE_EH);
if (isNil "_EH") then {
	_EH = player addEventHandler ["Respawn", {
		params ["_unit","_corpse"];

		// let the new units initialize
		waituntil {!isnull _unit && {!isNull player}};

		private _action = player addAction [
			"Disguise as the enemy",
			{
				[cursortarget, player] call ALiVE_fnc_disGuise;
			},
			[],
			1,
			false,
			true,
			"",
			"isnil {_this getvariable 'ALiVE_X_LIB_DETECTIONRATE'} &&
			{!alive cursortarget} && {cursortarget distance _this < 5} &&
			{cursortarget isKindOf 'CAManBase'} &&
			{(((typeOf cursortarget) call ALiVE_fnc_classSide) getfriend ((typeOf _this) call ALiVE_fnc_classSide)) < 0.6}"
		];

		//Update Action ID
		player setvariable [QGVAR(DISGUISE_ACTION),_action];

		//If player unit has been captive before dying, set it captive false to be sure! 
		player setcaptive false;
	}];

	// Flag the player with the EH
	player setvariable [QGVAR(DISGUISE_EH),_EH];

	if (_debug) then {
		["ALiVE_fnc_disguise - Respawn EH (ID: %1) set on unit %2!",_EH,player] call ALiVE_fnc_dump;
	};
};

//Get existing or create action
private _action = player getvariable [QGVAR(DISGUISE_ACTION),-1];
if !(_action in (actionIds player)) then {
	
	_action = player addAction [
		"Disguise as the enemy",
		{
			[cursortarget, player] call ALiVE_fnc_disGuise;
		},
		[],
		1,
		false,
		true,
		"",
		"isnil {_this getvariable 'ALiVE_X_LIB_DETECTIONRATE'} &&
		{!alive cursortarget} &&
		{cursortarget distance _this < 5} &&
		{cursortarget isKindOf 'CAManBase'} &&
		{(((typeOf cursortarget) call ALiVE_fnc_classSide) getfriend ((typeOf _this) call ALiVE_fnc_classSide)) < 0.6}"
	];

	player setvariable [QGVAR(DISGUISE_ACTION),_action];

	if (_debug) then {
		["ALiVE_fnc_disguise - Action (ID: %1) created for unit %2!",_action,player] call ALiVE_fnc_dump;
	};
};

//Exit gracefully if no inputs are given
if (isNil "_this" || {count _this == 0}) exitwith {
	if (_debug) then {
		["ALiVE_fnc_disguise - No params given, exiting! Action: ID %1! EH: ID %2!",_action,_EH] call ALiVE_fnc_dump;
	};
};

///////////////////////////////////////////
/// Main and Detector process
///////////////////////////////////////////

private _clear = {(side _x) getFriend (side _unit) < 0.6 && {[_x,_unit] call ALiVE_fnc_canSee}} count ((getposATL _unit) nearEntities [["CAManBase"], 50]) == 0;

if (uniform _target == "") exitwith {
	_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
	_text = format["%1<t>The chosen target does not wear a uniform!</t>",_title];

	["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
	["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
};

if !(_clear) exitwith {
	_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
	_text = format["%1<t>There are enemy units nearby that could spot you during masquerading!</t>",_title];

	["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
	["setSideSmallText",_text] call ALIVE_fnc_displayMenu;
};

//Get or create detector process
private _scriptHandle = _unit getvariable QGVAR(DETECTOR);
if !(isNil "_scriptHandle") then {

	//Detector Process already running
	_title = "<t size='1.5' color='#68a7b7' shadow='1'>IMPERSONATION</t><br/>";
	_text = format["%1<t>You are already disguised as the enemy!</t>",_title];

	["openSideSmall",0.3] call ALIVE_fnc_displayMenu;
	["setSideSmallText",_text] call ALIVE_fnc_displayMenu;

	if (_debug) then {
		["ALiVE_fnc_disguise - Detector process (ID: %1) already running for unit %2!",_scriptHandle,_unit] call ALiVE_fnc_dump;
	};
} else {
	//All is clear - put on that clothes
	_unit forceAddUniform (uniform _target); removeUniform _target;
	_unit addHeadgear (headgear _target); removeHeadgear _target;
	_unit addGoggles (goggles _target); removeGoggles _target;

	_scriptHandle = [_unit,_debug] spawn {

		params ["_unit","_debug"];

		if (_debug) then {
			["ALiVE_fnc_disguise - Inputs fine! Spawning Detector process for unit %1!",_unit] call ALiVE_fnc_dump;
		};

		private _uniform = uniform _unit;
		private _side = (faction _unit) call ALiVE_fnc_FactionSide;
		private _time = time;

		player setcaptive true;
		_unit setvariable [QGVAR(DETECTIONRATE),0];

		private _detector = _unit addEventHandler ["fired", {

			if !((_this select 4) isKindOf "TimeBombCore") then {
				_target = cursortarget;
				
				if (!isnull _target && {_target isKindOf "AllVehicles"}) then {
					(_this select 0) setvariable [QGVAR(DETECTIONRATE),100]
				};
			};
		}];

		waituntil {
			sleep 5;

			private _detectionRate = _unit getvariable [QGVAR(DETECTIONRATE),0];
			private _nearUnits = (_unit nearEntities [["CAmanBase"],20]) - [_unit];

			if (count _nearUnits == 0 && {_detectionRate > 0}) then {
					_detectionRate = _detectionRate - 1
			} else {
				{
					private _enemyUnit = _x;

					if (((side _enemyUnit) getfriend _side) < 0.6) then {

						if (_enemyUnit distance _unit < 3 && {[_enemyUnit,_unit] call ALiVE_fnc_canSee}) exitwith {
							_detectionRate = _detectionRate + 15;
						};

						if (_enemyUnit distance _unit < 15 && {[_enemyUnit,_unit] call ALiVE_fnc_canSee}) exitwith {
							_detectionRate = _detectionRate + 5;
						};

						if (_unit == vehicle _unit && {speed _unit > 10}) then {
							_detectionRate = _detectionRate + 1;
						};
					};
				} foreach _nearUnits;
			};

			_unit setvariable [QGVAR(DETECTIONRATE),_detectionRate];

			private _done = !alive _unit || {uniform _unit != _uniform} || {_detectionRate > 30};

			if (_debug) then {
				["ALiVE_fnc_disguise - Detector process finished %1 on unit %2! Detection rate: %3!",_done,_unit,_detectionRate] call ALiVE_fnc_dumpR;
			};

			_done;
		};

		_unit removeEventHandler ["fired",_detector];
		_unit setvariable [QGVAR(DETECTIONRATE),nil];
		_unit setvariable [QGVAR(DETECTOR),nil];

		// If the player has been killed while being captive, player will be captive even after respawn.
		// Needs a failsafe to set the player captive false on respawn -> See Respawn EH above.
		_unit setcaptive false;

		if (_debug) then {
			["ALiVE_fnc_disguise - Detector process finished after %1 seconds! Cleanup done for unit %2!",time - _time,_unit] call ALiVE_fnc_dump;
		};
	};

	//Flag the unit with detector-scriptHandle
	_unit setvariable [QGVAR(DETECTOR),_scriptHandle];
};

_scriptHandle;