#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(setObjectPointDamage);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectPointDamage
Description:

Set specific hitpoint damage of given object.

Parameters:
_this: ARRAY of OBJECTs

Returns:
ARRAY - Damage hitpoint ARRAY

See Also:
- <ALIVE_fnc_setObjectCargo>

Author:
Trapw0w

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [["_object", objNull, [objNull]], ["_damage", objNull]];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SYS_LOGISTICS - SETTING HP: %1 - %2",_object, _damage] call ALIVE_fnc_dump;
};

if (isNull _object) exitwith {};

{
	_value = ((_damage select 2) select _forEachIndex);
	_object setHitPointDamage [_x, _value];
} forEach (_damage select 0);

_damage;
