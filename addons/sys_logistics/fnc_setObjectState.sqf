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
Jman

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

// ACE fuel and ammo cargo as saved (#869), through ACE's own setters so it updates what it shows.
private _aceFuel = [_state, QGVAR(ACEFUEL), -1] call ALiVE_fnc_HashGet;
if (_aceFuel isEqualType 0 && {_aceFuel >= 0}) then {
    if (!isNil "ace_refuel_fnc_setFuel") then { [_object, _aceFuel] call ace_refuel_fnc_setFuel } else { _object setVariable ["ace_refuel_currentFuelCargo", _aceFuel, true] };
};
private _aceAmmo = [_state, QGVAR(ACEAMMO), -1] call ALiVE_fnc_HashGet;
if (_aceAmmo isEqualType 0 && {_aceAmmo >= 0}) then {
    if (!isNil "ace_rearm_fnc_setSupplyCount") then { [_object, _aceAmmo] call ace_rearm_fnc_setSupplyCount } else { _object setVariable ["ace_rearm_currentSupply", _aceAmmo, true] };
};


_damageModel = [_state,QGVAR(POINTDAMAGE)] call ALiVE_fnc_HashGet;


if (_object isKindof "LandVehicle" || _object isKindOf "Air" || _object isKindOf "Ship") then {
	// _damageModel returns Nil if HP currently not set. This is needed for backwards compatibility
	if (isNil "_damageModel") then {
		if(ALiVE_SYS_DATA_DEBUG_ON) then {
			["SYS_LOGISTICS - RESTORING LEGACY DAMAGE FOR %1", _object] call ALiVE_fnc_dump;
		};
		[_object,([_state,QGVAR(DAMAGE)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectDamage;
	} else {
		[_object,_damageModel] call ALiVE_fnc_setObjectPointDamage;
	};
} else {
	[_object,([_state,QGVAR(DAMAGE)] call ALiVE_fnc_HashGet)] call ALiVE_fnc_setObjectDamage;
};
_state;