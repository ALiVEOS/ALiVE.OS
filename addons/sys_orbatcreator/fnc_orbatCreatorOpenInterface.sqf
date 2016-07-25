#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(orbatCreatorOnUnload);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorOnUnload
Description:
Handles orbat creator interface events

Parameters:
String - Operation
Any - Args

Returns:
none

See Also:
ALiVE_fnc_orbatCreator

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

[MOD(orbatCreator),_this select 0, _this select 1] call ALiVE_fnc_orbatCreator;