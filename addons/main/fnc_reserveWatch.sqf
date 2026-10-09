#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(reserveWatch);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_reserveWatch

Description:
    Starts the reserve-activation watcher for a placement module's objectives
    and lists them on the module, so a save can find every reserve still
    waiting (ALIVE_fnc_reservePersist). Every 5 s each objective is handed to
    ALIVE_fnc_activateReserve, which decides whether one of its reserves wakes.
    The watcher ends by itself once the module logic is gone.

    Shared by mil_placement, mil_placement_custom, civ_placement and
    civ_placement_custom, both at a fresh start and after a persistent load.

Parameters:
    _this select 0: ARRAY  - objective (cluster) hashes holding reservePool
    _this select 1: OBJECT - the placement module logic

Returns:
    Nothing

Examples:
    (begin example)
    [_clusters, _logic] call ALIVE_fnc_reserveWatch;
    (end)

See Also:
    ALIVE_fnc_activateReserve, ALIVE_fnc_reservePersist

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_clusters", [], [[]]],
    ["_logic", objNull, [objNull]]
];

if (isNull _logic || {_clusters isEqualTo []}) exitWith {};

// Mil. Placement (Cust. Obj.) starts one watcher per objective, so the list grows by one each call.
_logic setVariable ["ALiVE_reserveClusters", (_logic getVariable ["ALiVE_reserveClusters", []]) + _clusters];
if (isNil "ALiVE_reserveModules") then { ALiVE_reserveModules = [] };
ALiVE_reserveModules pushBackUnique _logic;

[{
    params ["_args", "_handle"];
    _args params ["_watchClusters", "_watchLogic"];
    if (isNull _watchLogic) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    {
        [_x, _watchLogic] call ALIVE_fnc_activateReserve;
    } forEach _watchClusters;
}, 5, [_clusters, _logic]] call CBA_fnc_addPerFrameHandler;
