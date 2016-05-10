#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(canCarry);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_canCarry
Description:

Checks if the given object can be carried by the given object

Parameters:
_this select 0: object to be carried
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

private ["_object","_container","_containerCanCarry","_objectCanCarry","_canCarry","_blacklist"];

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_container = [_this, 1, objNull, [objNull]] call BIS_fnc_param;
_allowedContainers = GVAR(CARRYABLE) select 0;
_allowedObjects = GVAR(CARRYABLE) select 1;
_blackList = GVAR(CARRYABLE) select 2;

_canCarry = false;

// Basic checks
if ((_object == _container) || {{_object isKindOf _x} count _blackList > 0} || {!isnil {_object getvariable QGVAR(DISABLE)}}) exitwith {_canCarry};

// Only one object may be carried at a time
if (count (_container getvariable [QGVAR(CARGO),[]]) > 0) exitwith {_canCarry};

{if (_container isKindOf _x) exitwith {_containerCanCarry = true}} foreach _allowedContainers;
{if (_object isKindOf _x) exitwith {_objectCanCarry = true}} foreach _allowedObjects;

if (!(isnil "_containerCanCarry") && {!(isnil "_objectCanCarry")}) then {_canCarry = true};

_canCarry;
