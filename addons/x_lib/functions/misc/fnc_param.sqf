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
    Naught, dixon13
---------------------------------------------------------------------------- */

private ["_list", "_index", "_typeList"];
params [["_list", []], ["_index", 0], ["_typeList", []], ["_default", nil]];
WARNING("ALiVE_fnc_param - This function has been deprecated. Please use the params command instead.");
// _list = _this select 0;
// _index = _this select 1;
// _typeList = if ((count _this) > 2) then {_this select 2} else {[]};

// if (isNil "_list") then {_list = []};
// if (typeName(_list) != "ARRAY") then {_list = [_list]};

if (((count _list) > _index) && {(_typeList isEqualTo []) || {typeName(_list select _index) in _typeList}}) then {
    _list select _index // Valid value
} else {
    // Default value else no valid matching value
    if (_default != _nil) then { _default } else { nil };
};
