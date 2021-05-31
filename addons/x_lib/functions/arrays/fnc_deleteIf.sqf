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

private _arrSize = count _array;
private _i = 0;
while { _i < _arrSize } do {
    private _x = _array select _i;
    if (call _condition) then {
        _array deleteat _i;
        _arrSize = _arrSize - 1;
    } else {
        _i = _i + 1;
    };
};