#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(listDelete);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_listDelete

Description:
Deletes the given index from a list, and optionally selecting a logical next index

Parameters:
Control - list
String - data to select
Bool - if true, will select all indices with given data. Optional - Default : false

Returns:
Scalar - Selected index, if multiselection is true, array of indices is returned

Examples:
(begin example)
[_list,5] call ALIVE_fnc_listDelete;
(end)

See Also:
nil

Author:
SpyderBlack
---------------------------------------------------------------------------- */

params [
    ["_list", controlNull, [controlNull]],
    ["_indexToDelete",0,[0]],
    ["_selectNewIndex", true, [true]]
];

private _newSelectedIndex = -1;

private _listSize = lbsize _list;
if (_indexToDelete >= 0 && { _indexToDelete < _listSize }) then {
    _list lbdelete _indexToDelete;

    if (_selectNewIndex && { _listSize > 1 }) then {
        _newSelectedIndex = _indexToDelete;
        _list lbSetCurSel _newSelectedIndex;
    };
};

_newSelectedIndex