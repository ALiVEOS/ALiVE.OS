#include "\x\alive\addons\sys_perf\script_component.hpp"
SCRIPT(perfMenuInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_perfMenuInit
Description:
Sets up the Perf entry in the ALiVE menu (#1031). Spawned on every machine from
main's fnc_aliveInit.sqf, the same way Admin Actions is: a machine with a player
registers the menu (it only shows to an admin), and the server starts monitoring
straight away when the Required module asks for it.

Parameters:
_this select 0: BOOL - start monitoring at mission start (server only)

Returns:
Nil

See Also:
- <ALIVE_fnc_perfServer>
- <ALIVE_fnc_perfMenuDef>

Author:
Jman

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

params [["_atStart", false, [false]]];

if (isServer) then {
    if (isNil QGVAR(RUNNING)) then {
        GVAR(RUNNING) = false;
        publicVariable QGVAR(RUNNING);
    };
    if (_atStart) then { ["start"] call ALIVE_fnc_perfServer };
};

if (hasInterface) then {
    waitUntil {!isNull player};
    GVAR(SHOW) = false;
    [
        "player",
        [] call ALiVE_fnc_menuKeys,
        -9500,
        [
            "call ALIVE_fnc_perfMenuDef",
            ["main", "alive_flexiMenu_rscPopup"]
        ]
    ] call CBA_fnc_flexiMenu_Add;
};
