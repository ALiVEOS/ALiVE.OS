#include <\x\alive\addons\sys_civ_interaction\script_component.hpp>
SCRIPT(civInteractionHandlerOnAction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionHandlerOnAction
Description:
Handles civ interaction handler events

Parameters:
String - Operation
Any - Args

Returns:
None

See Also:
ALiVE_fnc_civInteractionHandler

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(civInteractionHandler),"onAction", _this] call ALiVE_fnc_civInteractionHandler;