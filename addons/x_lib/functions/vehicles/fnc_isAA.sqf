#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(isAA);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isAA

Description:
Checks if vehicle is an AA vehicle

Parameters:
Vehicle - The vehicle

Returns:
Array of empty positions

Examples:
(begin example)
_result = [_vehicle] call ALIVE_fnc_isAA;
(end)

See Also:
ALIVE_getEmptyVehiclePositions

Author:
HighHead
---------------------------------------------------------------------------- */
private ["_class","_maxElev","_hasArtyScanner"];

_class = _this select 0;

switch (typeName _class) do {
	case ("OBJECT") : {_class = typeOf _class};
	case ("STRING") : {_class = _class};
};

_maxElev = getNumber(configfile >> "CfgVehicles" >> _class >> "Turrets" >> "MainTurret" >> "maxElev");
_hasArtyScanner = getnumber(configfile >> "CfgVehicles" >> _class >> "artilleryScanner");

_class iskindOf "LandVehicle" && {_maxElev > 65} && {_hasArtyScanner == 0};