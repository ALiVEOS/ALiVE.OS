#include <\x\alive\addons\sup_artillery\script_component.hpp>
SCRIPT(CAS);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CQB
Description:
XXXXXXXXXX

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

Description:
CQB Module! Detailed description to follow

Examples:
[_logic, "factions", ["OPF_F"] call ALiVE_fnc_CQB;
[_logic, "houses", _nonStrategicHouses] call ALiVE_fnc_CQB;
[_logic, "spawnDistance", 500] call ALiVE_fnc_CQB;
[_logic, "active", true] call ALiVE_fnc_CQB;

See Also:
- <ALIVE_fnc_CQBInit>

Author:
Wolffy, Highhead
---------------------------------------------------------------------------- */

#define SUPERCLASS nil

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);
ALIVE_coreLogic = _logic;
_position = getposATL ALIVE_coreLogic;
_callsign = _logic getvariable ["artillery_callsign","EAGLE ONE"];
_type = _logic getvariable ["artillery_type","B_Heli_Attack_01_F"];
_ordnace = _logic getvariable ["artillery_ordnace",["HE", 30]];
 ARTYPOS = _position; PublicVariable "ARTYPOS";





