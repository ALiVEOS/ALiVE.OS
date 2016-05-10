#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(canLift);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_canLift
Description:

Checks if the given object can be lifted by the given object

Parameters:
_this select 0: object to be lifted
_this select 1: object that should lift the object above

Returns:
BOOL - yes/no

See Also:
- <ALIVE_fnc_getObjectSize>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_object","_container","_containerCanLift","_objectCanLift","_canLift","_blacklist"];

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_container = [_this, 1, objNull, [objNull]] call BIS_fnc_param;
_allowedContainers = GVAR(LIFTABLE) select 0;
_allowedObjects = GVAR(LIFTABLE) select 1;
_blacklist = GVAR(LIFTABLE) select 2;

_canLift = false;

// Basic checks
if (isnil "_object" || {isnil "_container"} || {{_object isKindOf _x} count _blackList > 0} || {!isnil {_object getvariable QGVAR(DISABLE)}} || {!(_container isKindOf "Air")} || {(getNumber (configFile >> "cfgVehicles" >> typeof _container >> "transportSoldier")) < 6} || {count attachedObjects _container > 0}) exitwith {_canLift};

{if (_container isKindOf _x) exitwith {_containerCanLift = true}} foreach _allowedContainers;
{if (_object isKindOf _x) exitwith {_objectCanLift = true}} foreach _allowedObjects;

if (!(isnil "_containerCanLift") && {!(isnil "_objectCanLift")}) then {_canLift = true};

if (_canLift) then {
    // Available Weight must be free to lift the object
    if (([_object] call ALiVE_fnc_getObjectWeight) > (([_container] call ALiVE_fnc_availableWeight))) exitwith {_canLift = false};
};

_canLift;
