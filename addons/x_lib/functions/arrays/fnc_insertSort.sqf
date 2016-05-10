#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_insertSort

Description:
	A generic implementation of the insertion sorting algorithm (that's one 
	of the simplest there is). The original list does NOT get altered.
	
Parameters:
	0 - Array [array]
	1 - Comparative function [string:code]

Returns:
	Sorted array copy [array]

Attributes:
	N/A

Examples:
	N/A

See Also:
	- <ALiVE_fnc_shellSort>
	- <ALiVE_fnc_insert>
	
Notes:
	1. This sorting algorithm is very sensitive to the initial ordering of 
	the given list and thus only efficient for small/mostly-sorted 
	lists (we swap only adjacent elements!). Use another one for 
	large/totally unsorted lists (e.g. ALiVE_fnc_shellSort).
	2. Sedgewick says: "In short, insertion sort is the method of choice
	for `almost sorted` files with few inversions: for such files, it
	will outperform even the sophisticated methods [...]"   
	3. Scenarios:
		- Best case: O(n)
		- Worst case: O(n^2)
	4. To simply invert the sort order, pass {_this * -1} as
	second parameter (for numbers).

	5. Default sorting order is ASCENDING
	
Author:
	rübe
---------------------------------------------------------------------------- */

private ["_list", "_selectSortValue", "_item", "_i", "_j"];
_list = +(_this select 0);
_selectSortValue = {_this};

if ((count _this) > 1) then
{
   if ((typeName (_this select 1)) == "CODE") then
   {
	  _selectSortValue = _this select 1;
   }
   else
   {
	  _selectSortValue = compile (_this select 1);
   };
};

// Insert Sort
for "_i" from 1 to ((count _list) - 1) do
{
   _item = +(_list select _i);
   _j = 0;
   
   for [{_j = _i}, {_j > 0}, {_j = _j - 1}] do
   {
	  if (((_list select (_j - 1)) call _selectSortValue) < (_item call _selectSortValue)) exitWith {};
	  _list set [_j, (_list select (_j - 1))];
   };
   
   _list set [_j, _item];
};

_list
