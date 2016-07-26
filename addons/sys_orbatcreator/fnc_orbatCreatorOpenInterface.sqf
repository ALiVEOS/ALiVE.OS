#include <\x\alive\addons\sys_orbatcreator\script_component.hpp>
SCRIPT(orbatCreatorOpenInterface);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_orbatCreatorOpenInterface
Description:
Handles opening of orbat creator interfaces

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

[MOD(orbatCreator),"openInterface", _this select 0] spawn ALiVE_fnc_orbatCreator;