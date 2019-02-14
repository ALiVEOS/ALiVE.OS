#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(staticDataHandler);


/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_staticDataHandler

Description:
Handles central loading of staticData

Parameters:

Returns:

Examples:
(begin example)
call ALiVE_fnc_staticDataHandler;
(end)

See Also:

Author:
Whigital

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

if (!canSuspend) then {
    ["WARNING: ALiVE staticData Handler called from unscheduled environment - %1", _fnc_scriptNameParent] call ALiVE_fnc_dump;
};

// Already loaded or loading, standby //
if (!isNil QMOD(STATIC_DATA_LOADED)) exitWith {
    waitUntil {MOD(STATIC_DATA_LOADED)};
};

// Nothing loaded, fire away //
MOD(STATIC_DATA_LOADED) = false;
["ALiVE staticData Handler loading started"] call ALiVE_fnc_dump;
call compile preprocessFileLineNumbers "\x\alive\addons\main\static\staticData.sqf";
["ALiVE staticData Handler loading finished"] call ALiVE_fnc_dump;