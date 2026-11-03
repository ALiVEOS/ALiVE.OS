#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(siteWhoEdenSave);

/* ----------------------------------------------------------------------------
Function: fnc_siteWhoEdenSave

Description:
Eden attributeSave shared by every site's Who Can setting (see fnc_siteWhoEdenLoad): the ticked
rows' tokens, comma separated. Nothing ticked saves an empty string (only admins).

Parameters:
    [_display, _default]

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
