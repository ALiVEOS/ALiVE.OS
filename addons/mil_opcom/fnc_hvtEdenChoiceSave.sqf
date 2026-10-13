#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(hvtEdenChoiceSave);

/* ----------------------------------------------------------------------------
Function: fnc_hvtEdenChoiceSave

Description:
Eden attributeSave for the High Value Target Class and Guards pickers (see fnc_hvtEdenChoiceLoad):
the ticked classes, then those typed below the list, separated by commas.

Parameters:
    [_display]

Returns:
String

Author:
Jman
---------------------------------------------------------------------------- */

params [["_display", controlNull]];
if (isNull _display) exitWith { "" };
// the ticked rows, then whatever is typed below the list (repeats kept, for several of one guard)
private _out = +(_display getVariable ["alive_selectedClasses", []]);
private _edit = _display controlsGroupCtrl 102;
if (!isNull _edit) then {
    { private _c = _x trim [" ", 0]; if (_c != "") then { _out pushBack _c } } forEach ((ctrlText _edit) splitString ",");
};
_out joinString ","
