#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: ALIVE_sys_statistics_fnc_feedEvent

Description:
Sends one mission event (a task's outcome, an objective taken, a support call...) the way every statistics
event goes, for the War Room's live feed. Does nothing while Statistics are off. Callable on the server or a
player's machine: from a player's machine it goes to the server, which writes it once.

Parameters:
Array - [key, value] pairs, the first ["Event", <name>]

Returns:
Nothing

Examples:
(begin example)
if (!isNil "ALIVE_sys_statistics_fnc_feedEvent") then { [["Event","FOBBuilt"], ["side","WEST"], ["pos",[100,200]]] call ALIVE_sys_statistics_fnc_feedEvent };
(end)

Author:
Jman
---------------------------------------------------------------------------- */
if !(missionNamespace getVariable [QGVAR(ENABLED), false]) exitWith {};
if !(_this isEqualType [] && {count _this > 0} && {(_this select 0) param [0, ""] == "Event"}) exitWith {};
if (isServer) then {
    if (!isNil QGVAR(fnc_writeEvent)) then { [QGVAR(UPDATE_EVENTS), _this] call GVAR(fnc_writeEvent) };
} else {
    GVAR(UPDATE_EVENTS) = _this;
    publicVariableServer QGVAR(UPDATE_EVENTS);
};
