#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(setObjectFuel);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectFuel
Description:

Gets fuel state of the given object.

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

params[["_object", objNull, [objNull]]];

if (isNull _object) exitwith {};

fuel _object;