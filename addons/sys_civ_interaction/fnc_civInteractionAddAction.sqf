#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civilianInteractionAddAction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civilianInteractionAddAction

Description:
Adds interaction action to civilians

Parameters:

Returns:
Bool - true

Examples:
(begin example)
//
_result = _unit call ALiVE_fnc_civilianInteractionAddAction;
(end)

See Also:

Author:
SpyderBlack723
---------------------------------------------------------------------------- */

private _object = _this select 0;

if (side _object != CIVILIAN || {isnil QGVAR(ROLES_DISABLED)} || {GVAR(ROLES_DISABLED)}) exitWith {}; // only add actions if civilian roles module field != none

private _id = _object addAction [
    "Talk to civilian",
    "['onCivilianInteracted', _this] call ALiVE_fnc_civInteractionOnAction",              // code
    nil,
    1,
    false,
    true,
    "",
    "alive _target"
];

true;