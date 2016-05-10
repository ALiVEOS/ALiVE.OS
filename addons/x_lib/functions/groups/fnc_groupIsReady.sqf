#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(groupIsReady);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupIsReady

Description:
Return if the entire group is in unitReady state

Parameters:
Group - group

Returns:
Boolean

Examples:
(begin example)
// get group ready state
_result = [_group] call ALIVE_fnc_groupIsReady;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_group", "_result"];
	
_group = _this select 0;

_result = true;

{
	if!(unitReady _x) exitwith
	{
		_result = false;
	};
} forEach units _group;

_result