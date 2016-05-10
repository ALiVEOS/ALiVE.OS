#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_param

Description:
	Selects a parameter from a parameter list.
	
Parameters:
	0 - Parameter list [array]
	1 - Parameter selection index [number]
	2 - Type list [array] (optional)
	3 - Default value [any] (optional)

Returns:
	Parameter [any]

Attributes:
	N/A

Examples:
	N/A

See Also:

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_list", "_index", "_typeList"];
_list = _this select 0;
_index = _this select 1;
_typeList = if ((count _this) > 2) then {_this select 2} else {[]};

if (isNil "_list") then {_list = []};
if (typeName(_list) != "ARRAY") then {_list = [_list]};

if (((count _list) > _index) && {(_typeList isEqualTo []) || {typeName(_list select _index) in _typeList}}) then
{
	_list select _index; // Valid value
}
else
{
	if ((count _this) > 2) then
	{
		_this select 3; // Default value
	}
	else
	{
		nil; // No valid matching value
	};
};
