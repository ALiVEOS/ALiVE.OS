#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(arrayFrameSplitter);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_arrayFrameSplitter
Description:
Executes code on each array entry (pointer _x), splits the given array in the parts given and executes the code in unscheduled

Parameters:
code - Given code, use _x as pointer on the array entry
array - the given array
number - the amount of parts the array should be splitted in, each part is executed within one frame

Returns:
Any - nothing

Examples:
(begin example)
[{
    private _entry = _x;

    ["This is executed in unscheduled %1 entry %2",!canSuspend, _entry] call ALiVE_fnc_DumpR;
},[1,2,3,4,5,6,7], 3] call ALiVE_fnc_arrayFrameSplitter;
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
params ["_code", "_array", "_split"];

private _count = count _array;
private _range = ceil(_count / _split);

if (_count < _split) then {
    _range = _count;
    _split = 1;
};

private _index = 0;

for "_i" from 1 to _split do {
    
    private _block = _array select [_index,_range];
    
    {_code foreach _block} call CBA_fnc_DirectCall;
    
    _index = _index + _range;
};