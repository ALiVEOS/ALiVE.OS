#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOMdecrementStartForceStrength);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOMdecrementStartForceStrength
Description:
Decrement StartForceStrength of targeted side of OPCOM_INSTANCES

Parameters:
STRING - _side ("WEST","EAST","GUER")
STRING - _type (string of "Infantry", "Motorized", "Mechanized", "Armored", "Artillery", "AAA", "Air", "Sea")
NUMBER - _decrementAmount (decrease StartForceStrength type by amount


Returns:
startForceStrength

Attributes:
none

Examples:
(begin example)
["GUER","Armored",10] call ALIVE_fnc_OPCOMdecrementStartForceStrength;
(end)

See Also:

Author:
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_sideTarget","_typeNum","_currentVal","_newVal","_result","_instance"];

params ["_side","_type","_decrementAmount"];

_result = [];

["OPCOM Call ALIVE_fnc_OPCOMdecrementStartForceStrength: _side: %1 _type %2 _decrementAmount: %3", _side, _type, _decrementAmount] call ALIVE_fnc_dump;

// Execute on Server only
if !(isServer) exitwith {
    hint "Requesting update to OPCOM! Please have some patience, soldier!";
    [_side,_type,_decrementAmount] remoteExec ["ALIVE_fnc_OPCOMdecrementStartForceStrength",2];
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
		if ((_instance select _typeNum) > 0) then {
		  _instance set [_typeNum, (_instance select _typeNum) - _decrementAmount];
      _result = [_x,"startForceStrength"] call ALiVE_fnc_HashGet;  
      _newVal = _result select _typeNum;  
		  ["OPCOM %1 decremented %2 StartForceStrength from: %3 to: %4, decrement amount: %5, startForceStrength: %6", _side, _type, _currentVal, _newVal, _decrementAmount, _result] call ALIVE_fnc_dump;
	  } else {
	  	_result = [_x,"startForceStrength"] call ALiVE_fnc_HashGet;  
	  	["OPCOM %1 cannot decrement %2 StartForceStrength; already zero!, startForceStrength: %3", _side, _type, _result] call ALIVE_fnc_dump;
	  };
		break;
	}; 
} forEach OPCOM_INSTANCES;

_result


