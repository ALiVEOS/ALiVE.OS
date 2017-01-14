#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteractionOnAction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionOnAction
Description:
Handles civ interaction events

Parameters:
String - Operation
Any - Args

Returns:
None

See Also:
ALiVE_fnc_civInteraction

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[ADDON,"onAction", _this] call ALiVE_fnc_civInteraction;