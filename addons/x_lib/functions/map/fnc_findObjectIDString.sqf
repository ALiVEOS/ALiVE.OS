//#define DEBUG_MODE_FULL
#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(findObjectIDString);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_findObjectIDString

Description:
Returns the Visitor object ID of a map placed object in string format

Parameters:
Object - A map placed object

Returns:
Scalar - Returns the master list

Examples:
(begin example)
// 388c2080# 88544: helipadsquare_f.p3d
_id = _helipad call ALIVE_fnc_findObjectIDString
// returns "88544"
(end)

See Also:
- <ALIVE_fnc_cluster>

Author:
Wolffy.au
Peer Review:
nil
---------------------------------------------------------------------------- */

private ["_tmp","_result"];

// 388c2080# 88544: helipadsquare_f.p3d
_tmp = _this param [0, objNull, [objNull]];

//["t: %1",str _tmp] call ALIVE_fnc_dump;

_result = [str _tmp, ": "] call CBA_fnc_split;

if(count _result > 1) then {
	_result = [_result select 0, "# "] call CBA_fnc_split;
	if(count _result > 1) then {
		_result = _result select 1;
	}else{
		_result = _result select 0;
	};
} else {
	_result = typeOf _tmp;
};

//["r: %1",str _result] call ALIVE_fnc_dump;

_result;
