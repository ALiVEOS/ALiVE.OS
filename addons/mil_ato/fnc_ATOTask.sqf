#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(task);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOTask
Description:
Placeholder. Registered ahead of its build so the whole rewrite takes one PBO
rebuild rather than one per piece. See contract.md section 5 for what this owns.

Returns:
Nil - and says so in the log, so a caller reaching it early is not silent.

Author:
Jman
---------------------------------------------------------------------------- */

params [["_logic", objNull, [objNull,[]]], ["_operation", "", [""]]];

["ALIVE_fnc_ATOTask - not built yet, called with operation %1", _operation] call ALiVE_fnc_dump;

nil
