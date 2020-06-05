#include "\x\alive\addons\sys_logistics\script_component.hpp"
SCRIPT(setObjectState);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setObjectState
Description:

Sets the state of the given object with given state

Parameters:
_this select 0: object to set state on
_this select 1: ARRAY (#HASH) of state

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

params [["_object", objNull, [objNull]], ["_state", ["",[],[],nil], [[]]]];

private ["_id","_data"];

_id = [MOD(SYS_LOGISTICS),"id",_object] call ALiVE_fnc_logistics;
[GVAR(STORE),_id,_state] call ALiVE_fnc_HashSet;

[_logic,"setEH",[_object]] call ALiVE_fnc_logistics;

_object setposATL ([_state,QGVAR(POSITION)] call ALiVE_fnc_HashGet);
_object setVectorDirAndUp ([_state,QGVAR(VECDIRANDUP)] call ALiVE_fnc_HashGet);

[_object,([_state,QGVAR(CARGO)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectCargo;
[_object,([_state,QGVAR(FUEL)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectFuel;


_damageModel = [_state,QGVAR(POINTDAMAGE)] call ALiVE_fnc_HashGet;


if (_object isKindof "LandVehicle" || _object isKindOf "Air" || _object isKindOf "Ship") then {
	// _damageModel returns Nil if HP currently not set. This is needed for backwards compatibility
	if (isNil "_damageModel") then {
		if(ALiVE_SYS_DATA_DEBUG_ON) then {
			["ALiVE SYS_LOGISTICS - RESTORING LEGACY DAMAGE FOR %1", _object] call ALIVE_fnc_dump;
		};
		[_object,([_state,QGVAR(DAMAGE)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectDamage;
	} else {
		[_object,_damageModel] call ALiVE_fnc_setObjectPointDamage;
	};
} else {
	[_object,([_state,QGVAR(DAMAGE)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectDamage;
};
_state;