#include "\x\alive\addons\sup_group_manager\script_component.hpp"
SCRIPT(rallyEdenWhoSave);

/* ----------------------------------------------------------------------------
Function: fnc_rallyEdenWhoSave

Description:
Eden attributeSave for the Rally Points module's Who Can Manage (see fnc_rallyEdenWhoLoad): the
ticked rows' tokens, comma separated. Nothing ticked saves "", which leaves it to admins.

Parameters:
    [_display, _default]

Returns:
String

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_default", "OWNER"]];
if (isNull _display) exitWith { _default };
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith { _default };
private _sel = lbSelection _list;
if !(_sel isEqualType []) then { _sel = [] };
((_sel apply { _list lbData _x }) select { _x != "" }) joinString ","
