#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(listSelectData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_listSelectData

Description:
Selects the list index that contains the given data string

Parameters:
Control - list
String - data to select
Bool - if true, will select all indices with given data. Optional - Default : false

Returns:
Scalar - Selected index, if multiselection is true, array of indices is returned

Examples:
(begin example)
[_list,"MyIndexData"] call ALIVE_fnc_listSelectData;
(end)

See Also:
nil

Author:
SpyderBlack
---------------------------------------------------------------------------- */

private "_selected";
params [
    ["_list", controlNull, [controlNull]],
    ["_data","",["",[]]],
    ["_multiselection", false, [false]]
];

if (!_multiselection) then {
    _selected = -1;
} else {
    _selected = [];
};

scopename "main";

for "_i" from 0 to (lbSize _list - 1) do {

    if (_multiselection) then {
        if ((_list lbData _i) in _data) then {
            _list lbSetSelected [_i, true];
            _selected pushback _i;
        } else {
            _list lbSetSelected [_i, false];
        };
    } else {
        if ((_list lbData _i) == _data) then {
            _list lbSetCurSel _i;
            _selected = _i;
            breakTo "main";
        };
    };
};

if (_selected isEqualType []) then {
    private _countSelected = count _selected;

    if (_countSelected > 0) then {
        _list lbSetCurSel (_selected select (_countSelected - 1)); // this triggers onSel events
    };
};

_selected