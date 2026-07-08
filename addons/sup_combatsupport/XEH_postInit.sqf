#include "script_component.hpp"

// #940: the Combat Support client menu/actions are installed only inside the module
// function= body (fnc_combatSupport "init" -> ALIVE_fnc_combatSupportAddClientMenu),
// which BIS_fnc_initModules runs in a ONE-SHOT mission-init pass. A JIP / late-join
// client never runs that pass, so it never gets the support tablet menu and cannot
// call artillery / CAS / transport -- only players present at mission start can. This
// is the same class of bug as the #937 civilian-interaction JIP fix (46fca2c9).
//
// Rebuild it here on the client from the JIP-persistent NEO_radioLogic. Spawned so the
// wait can suspend; idempotent via the ALiVE_CS_menuInstalled guard inside the function,
// so a client present at start (whose module pass already installed the menu) simply
// skips the rebuild.
if (hasInterface) then {
    [] spawn {
        private _waitStart = diag_tickTime;
        waitUntil {
            sleep 1;
            (!isNil "ALiVE_CS_menuInstalled")
            || {(!isNil "NEO_radioLogic") && {NEO_radioLogic getVariable ["init", false]}}
            || {diag_tickTime - _waitStart > 180}
        };
        if (!isNil "NEO_radioLogic" && {NEO_radioLogic getVariable ["init", false]}) then {
            call ALIVE_fnc_combatSupportAddClientMenu;
        };
    };
};
