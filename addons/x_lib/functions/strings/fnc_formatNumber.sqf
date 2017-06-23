#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_formatNumber

Description:
    Adds zero-based padding to numbers, or shortens them to specification.

Parameters:
    0 - Number [number:string]
    1 - Integer Width [number] (optional)
    2 - Decimal Width [number] (optional)

Returns:
    Formatted number [string]

Attributes:
    N/A

Examples:
    N/A

See Also:

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

params [["_number", "",  ["", 0]], ["_intWidth", 1, [0]], ["_decWidth", 0, [0]]];

if (typeName(_number) != "STRING") then {_number = str(_number)};

private ["_integer", "_decimal", "_decIndex"];
_integer = toArray(_number);
_decimal = [];
_decIndex = _integer find 46;

if (_decIndex >= 0) then // Decimal number
{
    for "_i" from (_decIndex + 1) to ((count _integer) - 1) do
    {
        _decimal pushBack (_integer select _i);
    };

    _integer resize _decIndex;

    while {(count _decimal) < _decWidth} do
    {
        _decimal pushBack 48;
    };

    _decimal resize _decWidth;
};

for "_i" from 1 to (_intWidth - (count _integer)) do
{
    _integer = [48] + _integer;
};

_integer resize _intWidth;

toString(_integer + (if ((count _decimal) > 0) then {[46] + _decimal} else {[]}));
