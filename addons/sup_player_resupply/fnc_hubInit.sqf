#include "\x\alive\addons\sup_player_resupply\script_component.hpp"
SCRIPT(hubInit);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_hubInit

Description:
The Logistics Hub module's init: hands the module to ALIVE_fnc_hub.

Parameters:
_this select 0: OBJECT - the module

Returns:
Nil

See Also:
- <ALIVE_fnc_hub>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];
if (isNull _logic) exitWith {};

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

["init", [_logic]] call ALIVE_fnc_hub;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
