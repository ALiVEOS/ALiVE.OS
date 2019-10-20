#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(listFindData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_listSelectData

Description:
Returns the list index that contains the given data string

Parameters:
Control - list
String - data to select
Bool - if true, will select all indices with given data. Optional - Default : false

Returns:
Scalar - Selected index, if findAll is true, array of indices is returned

Examples:
(begin example)
[_list,"MyIndexData"] call ALIVE_fnc_listSelectData;
(end)

See Also:
nil

Author:
SpyderBlack
---------------------------------------------------------------------------- */

params [
    ["_list", controlNull, [controlNull]],
    ["_data","",["",[]]],
    ["_findAll", false, [false]]
];

private _indices = [];
private _listSize = lbSize _list;

for "_i" from 0 to (_listSize - 1) do {
    if ((_list lbData _i) == _data) then {
        _indices pushback _i;

        if (_findAll) then {
            _i = _listSize;
        };
    };
};

if (_findAll) then {
    _indices
} else {
    if (_indices isequalto []) then {
        -1
    } else {
        _indices select 0
    }
};