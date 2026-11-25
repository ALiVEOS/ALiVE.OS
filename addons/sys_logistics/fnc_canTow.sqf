#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(canTow);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_canTow
Description:

Checks if the given object can be towed by the given object

Parameters:
_this select 0: object to be towed
_this select 1: object that should tow the object above

Returns:
BOOL - yes/no

See Also:
- <ALIVE_fnc_canCarry>

Author:
Highhead
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_object","_container","_containerCanTow","_objectCanTow","_canTow","_blacklist"];

_object = _this param [0, objNull, [objNull]];
_container = _this param [1, objNull, [objNull]];
_allowedContainers = GVAR(TOWABLE) select 0;
_allowedObjects = GVAR(TOWABLE) select 1;
_blacklist = GVAR(TOWABLE) select 2;

_canTow = false;

// Basic checks
// Something already attached means the vehicle is towing or lifting, which is also how Untow and Release know there is
// a load. A crate strapped on with Cargo Straps (cgs_carrier) and its strap parts (simple objects) are not a load, so a
// vehicle carrying one can still tow and lift (#1143).
if (isnil "_container" || {_object == _container} || {{_object isKindOf _x} count _blackList > 0} || {!isnil {_object getvariable QGVAR(DISABLE)}} || {(getNumber (configFile >> "cfgVehicles" >> typeof _container >> "transportSoldier")) == 0} || {(({!(isSimpleObject _x) && {(_x getVariable ["cgs_carrier", objNull]) isNotEqualTo _container}} count attachedObjects _container) > 0)}) exitwith {_canTow};

{if (_container isKindOf _x) exitwith {_containerCanTow = true}} foreach _allowedContainers;
{if (_object isKindOf _x) exitwith {_objectCanTow = true}} foreach _allowedObjects;

if (!(isnil "_containerCanTow") && {!(isnil "_objectCanTow")}) then {_canTow = true};

if (_canTow) then {
    // Available weight must be free to tow the object, weight is taken by half as towing of a wheeled object is easier than stowing
    if ((([_object] call ALiVE_fnc_getObjectWeight)/2) > (([_container] call ALiVE_fnc_availableWeight))) exitwith {_canTow = false};
};

_canTow;
