#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(setObjectDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectDamage
Description:

Set damage of given object

Parameters:
_this: ARRAY of OBJECTs

Returns:
SCALAR - Damage

See Also:
- <ALIVE_fnc_setObjectCargo>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params[["_object", objNull, [objNull]], ["_damage", -1, [-1]]];

if (isNull _object) exitwith {};

_object setDamage _damage;
_damage;