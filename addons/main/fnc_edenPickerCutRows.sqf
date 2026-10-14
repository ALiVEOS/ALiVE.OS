#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenPickerCutRows);

/* ----------------------------------------------------------------------------
Function: fnc_edenPickerCutRows

Description:
Hides the rows an ALiVE Eden picker has no use for and closes the gap they leave (#1083), so a
picker without a side filter or a typed field is no taller than it needs to be. Each cut is a band
of the picker in grid units: everything below it moves up by its height and the picker shrinks by
the same. The cuts are applied bottom first, so each is given in the picker's own layout
(CfgVehicles ALiVE_FilteredMultiSelect_Base and siblings).

The module's section layout (fnc_edenSectionCollapse.sqf) stacks the settings by their real height,
so the space given up is closed in the window too.

Parameters:
    _this select 0: CONTROL - the picker's controls group
    _this select 1: ARRAY   - idcs of the controls to hide
    _this select 2: ARRAY   - cuts, [y, h] in grid units

Example:
    // no side filter: hide its row and close the 5 units it took
    [_display, [1201, 1211], [[5, 5]]] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenPickerCutRows.sqf';

Author:
Jman
---------------------------------------------------------------------------- */

params [["_grp", controlNull], ["_hide", []], ["_cuts", []]];
if (isNull _grp) exitWith {};

{ private _c = _grp controlsGroupCtrl _x; if (!isNull _c) then { _c ctrlShow false } } forEach _hide;

private _g = pixelH * pixelGrid * 0.5;
private _kids = (allControls (ctrlParent _grp)) select { (ctrlParentControlsGroup _x) isEqualTo _grp };
private _order = +_cuts;
_order sort false;
{
    _x params ["_y", "_h"];
    private _top = _y * _g - (_g / 4);
    private _from = (_y + _h) * _g - (_g / 4);
    {
        private _p = ctrlPosition _x;
        switch (true) do {
            // below the band: up by its height
            case ((_p select 1) >= _from): {
                _p set [1, (_p select 1) - _h * _g];
                _x ctrlSetPosition _p;
                _x ctrlCommit 0;
            };
            // inside it (the hidden rows): folded to nothing at the top, so nothing is left below
            // the picker's new bottom for its frame to scroll to
            case ((_p select 1) >= _top): {
                _p set [1, 0];
                _p set [3, 0];
                _x ctrlSetPosition _p;
                _x ctrlCommit 0;
            };
        };
    } forEach _kids;
    private _gp = ctrlPosition _grp;
    _gp set [3, ((_gp select 3) - _h * _g) max 0];
    _grp ctrlSetPosition _gp;
    _grp ctrlCommit 0;
} forEach _order;
