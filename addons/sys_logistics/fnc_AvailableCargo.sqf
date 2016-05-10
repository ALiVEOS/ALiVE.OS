#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(AvailableCargo);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AvailableCargo
Description:

Gets the available cargo volume of all objects/vehicles

Parameters:
_this: ARRAY of OBJECTs

Returns:
Number - available volume in m^3

See Also:
- <ALIVE_fnc_getObjectSize>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_objects","_available","_types","_factor"];

_objects = _this;
_factor = 0.2;
_available = 0;

_types = [
	["Man",0.5],
	["Truck_F",0.9],
	["Car",0.8],
	["Tank",0.1],
	["Helicopter",0.5],
	["Ship",0.3],
	["Static",0],
	["Reammobox_F",1],
	["ThingX",0]
];

{
    private ["_object","_cargo"];
    
    _object = _x;
    _cargo = (_object getvariable [QGVAR(CARGO),[]]);
    
    {if (_object isKindOf (_x select 0)) exitwith {_factor = _x select 1}} foreach _types;
    _available = ([_object] call ALiVE_fnc_getObjectSize)*_factor;
   
    {_available = _available - ([_x] call ALiVE_fnc_getObjectSize)} foreach _cargo;
} foreach _objects;

_available;