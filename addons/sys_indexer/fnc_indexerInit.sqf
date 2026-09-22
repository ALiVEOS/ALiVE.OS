#include "\x\alive\addons\sys_indexer\script_component.hpp"
SCRIPT(indexerInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_indexerInit
Description:
Creates the server side object to store settings

Parameters:
_this select 0: OBJECT - Reference to module


Returns:
Nil

See Also:
- <ALIVE_fnc_indexer>

Author:
Gunny
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];

PARAMS_1(_logic);

// Confirm init function available
ASSERT_DEFINED("ALIVE_fnc_indeXer","Main function missing");

// Ensure only one module is used. Two placed Map Indexers both ran their init
// and the addon ended up pointing at whichever finished last, so the second
// one could quietly take over the first one settings with no warning. The
// string for this has existed as long as the module and was never shown, since
// nothing ever tested for the case. (#1048)
if !(isNil QMOD(sys_indexer)) exitWith {
    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_INDEXER_ERROR1");
    false
};

if (isnil "_logic") then {_logic = [nil, "create"] call ALIVE_fnc_indeXer};

_moduleID = [_logic, true] call ALIVE_fnc_dumpModuleInit;

[_logic, "init",[]] call ALIVE_fnc_indexer;

[_logic, false, _moduleID] call ALIVE_fnc_dumpModuleInit;

true


