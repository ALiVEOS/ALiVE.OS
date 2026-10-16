#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobEdenManageSave);

/* ----------------------------------------------------------------------------
Function: fnc_fobEdenManageSave

Description:
Eden attributeSave for Who Can Dismantle (see fnc_fobEdenManageLoad): the ticked rows' tokens,
comma separated. Nothing ticked saves "", which leaves it to admins.

Parameters:
    [_display]

Returns:
String

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull]];
if (isNull _display) exitWith { "SIDE" };
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith { "SIDE" };
private _sel = lbSelection _list;
if !(_sel isEqualType []) then { _sel = [] };
((_sel apply { _list lbData _x }) select { _x != "" }) joinString ","
