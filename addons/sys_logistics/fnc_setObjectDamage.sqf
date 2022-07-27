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

private ["_object","_damage"];

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_damage = [_this, 1, -1, [-1]] call BIS_fnc_param;

if (isNull _object) exitwith {};

_object setDamage _damage;
_damage;