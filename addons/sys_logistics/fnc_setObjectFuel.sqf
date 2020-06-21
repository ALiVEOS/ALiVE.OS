#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(getObjectFuel);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectFuel
Description:

Sets fuel state of the given object.

Parameters:
_this: ARRAY of OBJECTs

Returns:
NUMBER - Fuel

See Also:
- <ALIVE_fnc_setObjectCargo>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
params[["_object", objNull, [objNull]], ["_fuel", -1, [-1]]];

if (isNull _object) exitwith {};

_object setFuel _fuel;
_fuel;