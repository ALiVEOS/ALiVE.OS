#include "\x\alive\addons\sys_logistics\script_component.hpp"
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
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_object","_container","_containerCanLift","_objectCanLift","_canLift","_blacklist"];

_object = _this param [0, objNull, [objNull]];
_container = _this param [1, objNull, [objNull]];
_allowedContainers = GVAR(LIFTABLE) select 0;
_allowedObjects = GVAR(LIFTABLE) select 1;
_blacklist = GVAR(LIFTABLE) select 2;

_canLift = false;

// Basic checks
// A helicopter carrying something is refused. A load hanging on its sling ropes isn't among its attachedObjects (a load
// this module lifts is, as is anything else attached to it), so getSlingLoad is asked as well: otherwise one slinging a
// vehicle was offered Lift object for whatever stood nearest, which was the load on its own ropes.
if (isnil "_object" || {isnil "_container"} || {{_object isKindOf _x} count _blackList > 0} || {!isnil {_object getvariable QGVAR(DISABLE)}} || {!(_container isKindOf "Air")} || {(getNumber (configFile >> "cfgVehicles" >> typeof _container >> "transportSoldier")) < 6} || {count attachedObjects _container > 0} || {!isNull getSlingLoad _container}) exitwith {_canLift};

{if (_container isKindOf _x) exitwith {_containerCanLift = true}} foreach _allowedContainers;
{if (_object isKindOf _x) exitwith {_objectCanLift = true}} foreach _allowedObjects;

if (!(isnil "_containerCanLift") && {!(isnil "_objectCanLift")}) then {_canLift = true};

if (_canLift) then {
    // Available Weight must be free to lift the object
    if (([_object] call ALiVE_fnc_getObjectWeight) > (([_container] call ALiVE_fnc_availableWeight))) exitwith {_canLift = false};
};

_canLift;
