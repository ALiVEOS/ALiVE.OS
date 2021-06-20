#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_deleteIf

Description:
    Deletes any values that match the passed condition from the array

Parameters:
    0 - Array [array]
    1 - Condition for erase [code]

Returns:
    none

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    SpyderBlack723
---------------------------------------------------------------------------- */

params ["_array","_condition"];

private _indexes = (_array select { call _condition }) apply { _array find _x };

[_array, _indexes] call ALiVE_fnc_deleteAtMany;