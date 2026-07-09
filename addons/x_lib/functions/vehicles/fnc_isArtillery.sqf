#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isArtillery);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isArtillery

Description:
Checks if vehicle is an Artillery vehicle

Parameters:
Vehicle - The vehicle

Returns:
Array of empty positions

Examples:
(begin example)
_result = [_vehicle] call ALIVE_fnc_isArtillery;
(end)

See Also:
ALIVE_getEmptyVehiclePositions

Author:
HighHead
Jman
---------------------------------------------------------------------------- */
private ["_class","_hasArtyScanner"];

_class = _this select 0;

switch (typeName _class) do {
    case ("OBJECT") : {_class = typeOf _class};
    case ("STRING") : {_class = _class};
};

_hasArtyScanner = getnumber(configfile >> "CfgVehicles" >> _class >> "artilleryScanner");

if !(_class iskindOf "LandVehicle" && {_hasArtyScanner > 0}) exitWith { false };

// any turret elevating past 65 degrees counts (walk all turrets, not just
// MainTurret - mod artillery often mounts the gun on a different turret)
private _high = false;
{
    if (getNumber (_x >> "maxElev") > 65) exitWith { _high = true };
} forEach ("isClass _x" configClasses (configfile >> "CfgVehicles" >> _class >> "Turrets"));
_high