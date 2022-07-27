#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(getObjectWeight);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectWeight
Description:

Gets an approximate weight value of the given objects.
If only one object is given, it returns the approx. weight of this object

Parameters:
_this: ARRAY of OBJECTs

Returns:
Number - approximate weight

See Also:
- <ALIVE_fnc_getObjectSize>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_objects","_sum","_types","_weight"];

_objects = _this;
_sum = 0;

_types = [
        ["Truck_F",1000],
        ["Car",540],
        ["Tank",6500],
        ["Air",327],
        ["Ship",750],
        ["Reammobox_F",200],
        ["Static",400],
        ["ThingX",7],
        ["Man",200],
        ["StaticWeapon",60]
];

{
    private ["_object","_weight","_type"];

    _object = _x;

    switch (typeName _object) do {
        case ("OBJECT") : {_type = typeOf _object; _weight = getMass _object};
        case ("STRING") : {_type = _object; _weight = getNumber(configfile >> "CfgVehicles" >> _type >> "mass")};
    };

    // Code to make sure we get accurate mass for slingloadable vehicles
    if (_weight == 0 && typeName _object == "STRING" && (_object iskindof "Car" || _object isKindOf "Ship")) then {

        if (isNil "ALIVE_OBJECT_WEIGHTS") then {
            ALIVE_OBJECT_WEIGHTS = [] call ALiVE_fnc_hashCreate;
        };

        // Check to see if its in the cache to avoid unnecessary spawns
        _weight = [ALiVE_OBJECT_WEIGHTS, _object, 0] call ALiVE_fnc_hashGet;
        if (_weight == 0) then {
            private _vehicle = _object createVehicleLocal [0,0,1000];
            _weight = getMass _vehicle;
            deleteVehicle _vehicle;
            [ALiVE_OBJECT_WEIGHTS, _object, _weight] call ALiVE_fnc_hashSet;
        };

    };

    if (_weight == 0) then {{if (_type isKindOf (_x select 0)) exitwith {_weight = (getNumber(configFile >> "CfgVehicles" >> _type >> "mapSize")) * (_x select 1)}} foreach _types};

    _sum = _sum + _weight;

} foreach _objects;

_sum;