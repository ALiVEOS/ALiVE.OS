#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(FOBTypesInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_FOBTypesInit

Description:
FOB Types module (NeisAEL on Discord, 20 Oct). It holds the list of FOB types; the Player FOBs
module it's synced to reads that list when it starts (ALiVE_fnc_FOB "typesParse"), so there is
nothing to start here beyond saying it was placed.

Parameters:
_this select 0: OBJECT - Reference to module

Returns:
Nil

See Also:
- <ALIVE_fnc_FOB>

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull]]];

private _moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

_logic setVariable ["moduleType", "ALiVE_SUP_FOB_TYPES"];
_logic setVariable ["startupComplete", true];

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;
