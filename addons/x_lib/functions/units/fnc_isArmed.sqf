#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(isArmed);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isArmed

Description:
Checks if given unit/vehicle is an armed object by default!
Useful for dynamic selection of armed units/vehicles.

Parameters:
OBJECT (unit or vehicle)

Returns:
BOOL - is armed (true / false)

Examples:
(begin example)
// get near units
_isArmed = [player] call ALIVE_fnc_isArmed;
(end)

See Also:


Author:
Highhead
---------------------------------------------------------------------------- */

private ["_object","_isArmed"];

_object = _this param [0, objNull, [objNull,""]];

switch (typeName _object) do {
    case ("OBJECT") : {_object = typeOf _object};
};

_isArmed = false;

if (_object isKindOf "CAManBase") then {

    // Checks if default weapons[] is set with weapons
    _isArmed = count ((getArray(configfile >> "CfgVehicles" >> _object >> "weapons")) - ["Throw","Put","FakeWeapon"]) > 0;

} else {

    if (_object isKindOf "AllVehicles" && {!(_object isKindof "Plane")}) then {
        // Checks if magazines are set for the main turrets, tbc: AH9 Pawnee seems to be misconfiged (no magazines)
        _isArmed = count (getArray(configfile >> "CfgVehicles" >> _object >> "Turrets" >> "MainTurret" >> "Magazines")) > 0 || count (getArray(configfile >> "CfgVehicles" >> _object >> "Turrets" >> "M2_Turret" >> "Magazines")) > 0;
    } else {
	    if (_object isKindOf "Plane") then {
	
	        // Checks for planez
	        _isArmed = count (getArray(configfile >> "CfgVehicles" >> _object >> "Weapons") - ["Laserdesignator_mounted", "CMFlareLauncher","Laserdesignator_pilotCamera"]) > 0; // more than just flare/chaff launcher
	
	        if !(_isArmed) then {
	            // Check for any turrets with weapons
	            {
	                _isArmed = count (getArray(configfile >> "CfgVehicles" >> _object >> "Turrets" >> _x >> "weapons") - ["Laserdesignator_mounted", "CMFlareLauncher","Laserdesignator_pilotCamera"]) > 0;
	                if (_isArmed) exitWith {};
	            } foreach (getArray(configfile >> "CfgVehicles" >> _object >> "Turrets"));
	        };
	
	        // Need to check for new dynamic loadout vehicles too - check pylons
	        if (!_isArmed) then {
	            _isArmed = count (configfile >> "CfgVehicles" >> _object >> "Components" >> "TransportPylonsComponent" >> "pylons") > 0;
	        };
	
	    };
	};
};

_isArmed;

