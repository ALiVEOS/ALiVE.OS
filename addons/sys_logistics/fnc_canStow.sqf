#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(canStow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_canStow
Description:

Checks if the given object can be stowed in the other given object

Parameters:
_this select 0: object to be stowed
_this select 1: object that should carry the object above

Returns:
BOOL - yes/no

See Also:
- <ALIVE_fnc_getObjectSize>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_object","_container","_containerCanStow","_objectCanStow","_canStow","_blacklist"];

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_container = [_this, 1, objNull, [objNull]] call BIS_fnc_param;
_allowedContainers = GVAR(STOWABLE) select 0;
_allowedObjects = GVAR(STOWABLE) select 1;
_blacklist = GVAR(STOWABLE) select 2;

_canStow = false;

// Basic checks
if (isnil "_container" || {_object == _container} || {{_object isKindOf _x} count _blackList > 0} || {!isnil {_object getvariable QGVAR(DISABLE)}} || {getNumber(configFile >> "cfgVehicles" >> typeof _container >> "transportSoldier") == 0} || {_object in (_container getvariable [QGVAR(CARGO),[]])} || {!isnil {_object getvariable QGVAR(CONTAINER)}}) exitwith {_canStow};

{if (_container isKindOf _x) exitwith {_containerCanStow = true}} foreach _allowedContainers;
{if (_object isKindOf _x) exitwith {_objectCanStow = true}} foreach _allowedObjects;

if (!(isnil "_containerCanStow") && {!(isnil "_objectCanStow")}) then {_canStow = true};

if (_canStow) then {
	// Weight and Cargovolume must be free to fit the object in
	if (([_object] call ALiVE_fnc_getObjectWeight) > (([_container] call ALiVE_fnc_availableWeight))) exitwith {_canStow = false};
	if (([_object] call ALiVE_fnc_getObjectSize) > (([_container] call ALiVE_fnc_availableCargo))) exitwith {_canStow = false};
};

_canStow;
