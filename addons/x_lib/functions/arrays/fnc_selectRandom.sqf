#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(selectRandom);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_selectRandom

Description:
Selects random by bias

Parameters:
[[_a,_b,_c],[9,6,3]] call ALiVE_fnc_selectRandom

Returns:
_biased value

Examples:
(begin example)
[[_a,_b,_c],[9,6,3]] call ALiVE_fnc_selectRandom
(end)

See Also:

Author:
Wolffy, Highhead
---------------------------------------------------------------------------- */

private ["_choices","_bias","_result","_j"];
_choices = _this select 0;
_bias = _this select 1;

_result = [];
_j = 0;
{
	for "_i" from 1 to _x do {
        _result pushback (_choices select _j);
	};
	_j = _j + 1;
} forEach _bias;

//hint str _result;

selectRandom _result;
