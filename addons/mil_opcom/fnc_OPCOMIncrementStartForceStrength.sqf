#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMIncrementStartForceStrength);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMIncrementStartForceStrength
Description:
Increment StartForceStrength of targeted side of OPCOM_INSTANCES

Parameters:
STRING - _side ("WEST","EAST","GUER")
STRING - _type (string of "Infantry", "Motorized", "Mechanized", "Armored", "Artillery", "AAA", "Air", "Sea")
NUMBER - _incrementAmount (increase StartForceStrength type by amount


Returns:
startForceStrength

Attributes:
none

Examples:
(begin example)
["GUER","Armored",10] call ALIVE_fnc_OPCOMIncrementStartForceStrength;
(end)

See Also:

Author:
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_sideTarget","_typeNum","_currentVal","_newVal","_result;"];

params ["_side","_type","_incrementAmount"];

_result = [];

["OPCOM Call ALIVE_fnc_OPCOMIncrementStartForceStrength: _side: %1 _type %2 _incrementAmount: %3", _side, _type, _incrementAmount] call ALIVE_fnc_dump;

// Execute on Server only
if !(isServer) exitwith {
    hint "Requesting update to OPCOM! Please have some patience, soldier!";
    [_side,_type,_incrementAmount] remoteExec ["ALIVE_fnc_OPCOMIncrementStartForceStrength",2];
};

switch _type do {
  case ("Infantry") : {
   _typeNum = 0;
  };
  case ("Motorized") : {
   _typeNum = 1;
  };
  case ("Mechanized") : {
   _typeNum = 2;
  };
  case ("Armored") : {
  	_typeNum = 3;
  };
  case ("Artillery") : {
   _typeNum = 4;
  };
  case ("AAA") : {
   _typeNum = 5;
  };
  case ("Air") : {
   _typeNum = 6;
  };
  case ("Sea") : {
   _typeNum = 7;
  };
};
   
{ 
	_sideTarget = [_x, "side", ""] call ALIVE_fnc_hashGet;
	if (_sideTarget == _side) then { 
		_instance =  [_x,"startForceStrength"] call ALiVE_fnc_HashGet;
		_currentVal = _instance select _typeNum;
		_instance = _instance set [_typeNum, (_instance select _typeNum) +_incrementAmount];
		_newVal = _instance select _typeNum;
		_result = _instance;
	}; 
} forEach OPCOM_INSTANCES;

["OPCOM %1 incremented %2 StartForceStrength from: %3 to: %4, increment amount: %5", _side, _type, _currentVal, _newVal, _incrementAmount] call ALIVE_fnc_dump;
  
_result
