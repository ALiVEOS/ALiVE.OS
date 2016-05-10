#include <\x\alive\addons\sys_aiskill\script_component.hpp>
SCRIPT(AISkillInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_AISkillInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module
_this select 1: ARRAY - Synchronized units

Returns:
Nil

See Also:
- <ALIVE_fnc_AISkill>

Author:
ARJay

Peer Reviewed:
Wolffy.au 20131113
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);
//DEFAULT_PARAM(1,_syncunits, []);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_AISkill","Main function missing");

if (isnil "_logic") then {_logic = [nil, "create"] call ALIVE_fnc_AISkill};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init"] call ALIVE_fnc_AISkill;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

