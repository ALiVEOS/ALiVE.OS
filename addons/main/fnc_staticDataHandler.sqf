#include <\x\alive\addons\main\script_component.hpp>
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

// Already loaded or loading, standby //
if (!isNil QMOD(STATIC_DATA_LOADED)) exitWith {
    waitUntil {MOD(STATIC_DATA_LOADED)};
};

// Not loaded and never loaded, initialize vars //
if ((isNil QMOD(STATIC_DATA_LOADED)) && (isNil QGVAR(Processing))) then {
    MOD(STATIC_DATA_LOADED) = false;
    GVAR(Processing) = false;
};

// Not loading, load //
if !(GVAR(Processing)) then {
    GVAR(Processing) = true;

    ["ALiVE staticData Handler starting data load."] call ALiVE_fnc_dump;
    call compile preprocessFileLineNumbers "\x\alive\addons\main\static\staticData.sqf";
    ["ALiVE staticData Handler finished data load."] call ALiVE_fnc_dump;

    GVAR(Processing) = false;
};
