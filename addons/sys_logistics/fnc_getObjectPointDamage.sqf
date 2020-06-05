#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(getObjectPointDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectPointDamage
Description:

Gets damage state of each hitpoint on an object

Parameters:
_this: ARRAY of OBJECTs

Returns:
ARRAY - Nested ARRAY containing hitpointsNamesArray, selectionsNamesArray, damageValuesArray

See Also:
- <ALIVE_fnc_getObjectCargo>

Author:
Trapw0w

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [["_object", objNull, [objNull]]];

if (isNull _object) exitwith {};

_d = getAllHitPointsDamage _object;
_d;