#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(getObjectSize);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectSize
Description:

Gets an approximate volume of the given objects.
If only one object is given, it returns the approx. volume of this object

Parameters:
_this: ARRAY of OBJECTs

Returns:
Number - approximate volume

See Also:
- <ALIVE_fnc_getObjectWeight>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_objects","_sum"];

_objects = _this;
_sum = 0;

{
    private ["_object","_size","_type"];
    
	_object = _x;

    switch (typeName _object) do {
		case ("OBJECT") : {_type = typeOf _object};
		case ("STRING") : {_type = _object};
    };
    
    _size = getNumber(configFile >> "CfgVehicles" >> _type >> "mapSize");
    
    _sum = _sum + _size;
} foreach _objects;

_sum;