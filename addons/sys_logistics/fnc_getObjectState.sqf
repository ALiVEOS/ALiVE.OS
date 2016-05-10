#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(getObjectState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getObjectState
Description:

Returns the state of the given object

Parameters:
_this select 0: object to get state from

Returns:
ARRAY - Hash of objects state

See Also:
- <ALIVE_fnc_getObjectSize>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
if (isnil "_this") exitwith {};

private ["_object","_id"];

switch (typename _this) do {
    case ("OBJECT") : {_object = [_this]};
    case ("ARRAY") : {_object = _this};
};

_object = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_id = [MOD(SYS_LOGISTICS),"id",_object] call ALiVE_fnc_logistics;

[MOD(SYS_LOGISTICS),"updateObject",[_object]] call ALiVE_fnc_logistics;
_state = +([GVAR(STORE),_id] call ALiVE_fnc_HashGet);

_state;