#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(getObjectDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectDamage
Description:

Gets damage state of a given object

Parameters:
_this: ARRAY of OBJECTs

Returns:
SCALAR - Damage value, either int or float

See Also:
- <ALIVE_fnc_getObjectCargo>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [["_object", objNull, [objNull]]];

if (isNull _object) exitwith {};

damage _object;