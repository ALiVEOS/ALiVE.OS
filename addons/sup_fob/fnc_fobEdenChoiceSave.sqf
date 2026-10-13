#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobEdenChoiceSave);

/* ----------------------------------------------------------------------------
Function: fnc_fobEdenChoiceSave

Description:
Eden attributeSave for the Player FOBs pickers (see fnc_fobEdenChoiceLoad): the three picks as
one string, BLUFOR|OPFOR|Independent.

Parameters:
    [_display]

Returns:
String

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull]];
if (isNull _display) exitWith { "" };
private _picks = +(_display getVariable ["alive_fobPicks", ["", "", ""]]);
_picks resize 3;
(_picks apply { if (isNil "_x") then { "" } else { _x } }) joinString "|"
