#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(ALiVE_fnc_civInteractionOnAction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractionOnAction
Description:
Handles civ interaction interface events

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

[MOD(civInteraction),"onAction", _this] call ALiVE_fnc_civInteraction;