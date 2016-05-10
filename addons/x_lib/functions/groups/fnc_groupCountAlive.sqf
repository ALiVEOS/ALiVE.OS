#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(groupCountAlive);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupCountAlive

Description:
Return count of alive units from a group

Parameters:
Group - group

Returns:
Scalar 

Examples:
(begin example)
// count group alive
_result = [_group] call ALIVE_fnc_groupCountAlive;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_group", "_count"];
	
_group = _this select 0;

_count = 0;	

{
	if(alive _x) then {
		_count = _count + 1;
	};
} forEach units _group;

_count