#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(logisticsDisable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_logisticsDisable
Description:

Creates the disable logistics module

Parameters:
_this select 0: OBJECT - Reference to module logic

Returns:
Nil

See Also:
- <ALIVE_fnc_logistics>

Author:
Highhead

Peer Reviewed:
nil
---------------------------------------------------------------------------- */
private ["_logic"];

PARAMS_1(_logic);


{_x setvariable [QGVAR(DISABLE),true]} foreach (synchronizedObjects _logic);

if !(isServer) exitwith {};

_debug = _logic getvariable ["DEBUG","false"];
_exit = _logic getvariable ["DISABLELOG","false"];
_disableCarry = _logic getvariable ["DISABLECARRY","false"];
_disablePersistence = _logic getvariable ["DISABLEPERSISTENCE","false"];
_disableTow = _logic getvariable ["DISABLETOW","false"];
_disableLift = _logic getvariable ["DISABLELIFT","false"];
_disableLoad = _logic getvariable ["DISABLELOAD","false"];
_disable3D = _logic getvariable ["DISABLE3D","false"];
_blacklist = _logic getvariable ["BLACKLIST",""];

waituntil {!isnil QMOD(SYS_LOGISTICS)};

MOD(SYS_LOGISTICS) setvariable ["DEBUG", _debug == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLELOG", _exit == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLECARRY", _disableCarry == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLEPERSISTENCE", _disablePersistence == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLETOW", _disableTow == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLELIFT", _disableLift == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLELOAD", _disableLoad == "true", true];
MOD(SYS_LOGISTICS) setvariable ["DISABLE3D", _disable3D == "true", true];
MOD(SYS_LOGISTICS) setvariable ["BLACKLIST",[_logic, "blacklist", _blacklist] call ALiVE_fnc_Logistics, true];

_logic