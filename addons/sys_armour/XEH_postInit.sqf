#include "script_component.hpp"
/*
    sys_armour postInit: apply the armour sets once the ALiVE Addon Options
    are known. Runs on every machine (server, headless clients and players),
    because ACE works out a soldier's wounds where that soldier is local.

    Author: Jman
*/

["CBA_settingsInitialized", {
    [] call ALIVE_fnc_armourInit;
}] call CBA_fnc_addEventHandler;
