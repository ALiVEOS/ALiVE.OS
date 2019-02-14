﻿#include "\x\alive\addons\sys_weather\script_component.hpp"
SCRIPT(weatherInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_weatherInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module


Returns:
Nil

See Also:
- <ALIVE_fnc_weather>

Author:
Jman
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_weather","Main function missing");

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_weather;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;


