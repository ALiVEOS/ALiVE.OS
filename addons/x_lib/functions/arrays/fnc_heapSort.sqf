#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_heapSort

Description:
	Sorts an array using the heap-sort algorithm.
	
Parameters:
	0 - Array [array]
	1 - Comparative function [code]

Returns:
	Sorted array copy [array]

Attributes:
	N/A

Examples:
	N/A

See Also:
	- <ALiVE_fnc_insertSort>
	- <ALiVE_fnc_shellSort>

Author:
	Naught
---------------------------------------------------------------------------- */

private ["_fnc_swap", "_fnc_siftDown"];
_fnc_swap = {
	private ["_array", "_pos1", "_pos2", "_temp"];
	_array = _this select 0;
	_pos1 = _this select 1;
	_pos2 = _this select 2;
	
	_temp = _array select _pos1;
	_array set [_pos1, (_array select _pos2)];
	_array set [_pos2, _temp];
};

_fnc_siftDown = {
	private ["_array", "_start", "_end", "_compFunc", "_root"];
	_array = _this select 0;
	_start = _this select 1;
	_end = _this select 2;
	_compFunc = _this select 3;
	_root = _start;
	
	while {((_root * 2) + 1) <= _end} do
	{
		private ["_child", "_swap"];
		_child = (_root * 2) + 1;
		_swap = _root;
		
		if (((_array select _swap) call _compFunc) < ((_array select _child) call _compFunc)) then
		{
			_swap = _child;
		};
		
		if (((_child + 1) <= _end) && ((_array select _swap) < (_array select (_child + 1)))) then
		{
			_swap = _child + 1;
		};
		
		if (_swap != _root) then
		{
			[_array, _root, _swap] call _fnc_swap;
			_root = _swap;
		};
	};
};

private ["_array", "_compFunc", "_start", "_end"];
_array = _this select 0;
_compFunc = [_this, 1, ["CODE"], {_this}] call ALiVE_fnc_param;
_start = ((count _array) - 2) / 2;
_end = (count _array) - 1;

if ((count _array) > 1) then
{
	while {_start >= 0} do
	{
		[_array, _start, _end, _compFunc] call _fnc_siftDown;
		_start = _start - 1;
	};
	
	while {_end > 0} do
	{
		[_array, _end, 0] call _fnc_swap;
		_end = _end - 1;
		[_array, 0, _end, _compFunc] call _fnc_siftDown;
	};
};

_array
