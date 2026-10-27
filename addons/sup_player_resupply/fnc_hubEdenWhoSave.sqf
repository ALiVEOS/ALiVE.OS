#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hubEdenWhoSave);

/* ----------------------------------------------------------------------------
Function: fnc_hubEdenWhoSave

Description:
Eden attributeSave for the Logistics Hub's Who Can Collect (see fnc_hubEdenWhoLoad): the ticked
rows' tokens, comma separated. Nothing ticked saves "", which leaves it to admins.

Parameters:
    [_display, _default]

Returns:
String

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull], ["_default", "SIDE"]];
if (isNull _display) exitWith { _default };
private _list = _display controlsGroupCtrl 100;
if (isNull _list) exitWith { _default };
private _sel = lbSelection _list;
if !(_sel isEqualType []) then { _sel = [] };
((_sel apply { _list lbData _x }) select { _x != "" }) joinString ","
