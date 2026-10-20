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
// buildings: a class still in the typed field (OK pressed without leaving it) joins the side's ticked ones
private _typed = _display getVariable ["alive_fobTyped", ""];
if ((_display getVariable ["alive_fobMode", ""]) == "HUB" && {_typed != ""}) then {
    private _slot = _display getVariable ["alive_currentSlot", 0];
    private _have = ((_picks select _slot) splitString ", ;") apply { toLower _x };
    private _add = (_typed splitString ", ;") select { !(toLower _x in _have) };
    if (_add isNotEqualTo []) then { _picks set [_slot, (((_picks select _slot) splitString ", ;") + _add) joinString ", "] };
};
(_picks apply { if (isNil "_x") then { "" } else { _x } }) joinString "|"
