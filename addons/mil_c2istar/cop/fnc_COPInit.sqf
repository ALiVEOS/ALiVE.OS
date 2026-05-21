#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPInit

Description:
    Entry-point orchestrator for the COP (Common Operational Picture) feature.
    Dispatches start/stop operations for the server, asymmetric, and client
    subsystems. Called from fnc_C2ISTAR.sqf when the Eden attribute
    "commanderIntelMode" resolves to any non-Off tier.

Parameters:
    0: STRING - Operation: "startServer" | "startAsym" | "startClient" | "stop"
    1: ANY    - (optional) Operation-specific argument (e.g. side key for startClient)

Returns:
    BOOL - true if the dispatch routed, false if the operation is unknown.

Examples:
    (begin example)
    // Server-side, in fnc_C2ISTAR.sqf after the Eden attribute is read:
    ["startServer"] call ALIVE_fnc_COPInit;
    ["startAsym"]   call ALIVE_fnc_COPInit;

    // Client-side, inside hasInterface block:
    ["startClient", "WEST"] call ALIVE_fnc_COPInit;

    // Shutdown (called from c2istar module destroy):
    ["stop"] call ALIVE_fnc_COPInit;
    (end)

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

TRACE_1("COPInit - input",_this);

params [
    ["_operation", "", [""]],
    ["_arg",       nil]
];

// Seed all secondary function globals on the first dispatch per machine.
// COPConfig uses isNil guards so re-invocation is idempotent; missions that
// set ALIVE_COP_* overrides in init.sqf before module init have those values
// preserved. The isNil check on ALIVE_fnc_COPGetSideKey prevents re-assigning
// helper/debug/render function bodies on every dispatch.
if (isNil "ALIVE_fnc_COPGetSideKey") then {
    call ALIVE_fnc_COPConfig;
    call ALIVE_fnc_COPHelpers;
    call ALIVE_fnc_COPDebug;
    // Render globals exist on all machines — they cost ~0 to seed server-side
    // (just function assignments) and the Draw EH runs only client-side anyway.
    call ALIVE_fnc_COPRender;
};

private _result = switch (_operation) do {

    case "startServer": {
        if (!isServer) exitWith {
            ["warn", "init", "startServer called on non-server machine — ignored"] call ALIVE_fnc_COPLog;
            false
        };
        if (ALIVE_COP_SERVER_RUNNING) exitWith {
            ["info", "init", "startServer already running — skipping double-start"] call ALIVE_fnc_COPLog;
            true
        };
        ALIVE_COP_SERVER_RUNNING = true;
        ["info", "init", "startServer dispatched, anchor distance %1m", [missionNamespace getVariable ["ALIVE_COP_ANCHOR_DISTANCE", 1000]]] call ALIVE_fnc_COPLog;
        // COPServer waits for OPCOM_instances then spawns Loop A and Loop B.
        // Spawn rather than call so Init returns promptly.
        [] spawn ALIVE_fnc_COPServer;
        true
    };

    case "startAsym": {
        if (!isServer) exitWith {
            ["warn", "init", "startAsym called on non-server machine — ignored"] call ALIVE_fnc_COPLog;
            false
        };
        if (ALIVE_COP_ASYM_RUNNING) exitWith {
            ["info", "init", "startAsym already running — skipping double-start"] call ALIVE_fnc_COPLog;
            true
        };
        ALIVE_COP_ASYM_RUNNING = true;
        ["info", "init", "startAsym dispatched"] call ALIVE_fnc_COPLog;
        // COPAsym silent-disables if no asymmetric OPCOM is present — that
        // path is NOT a failure; missions without insurgency just don't use
        // Layer 5. Spawn so Init returns promptly.
        [] spawn ALIVE_fnc_COPAsym;
        true
    };

    case "startClient": {
        if (!hasInterface) exitWith {
            ["warn", "init", "startClient called on non-interface machine — ignored"] call ALIVE_fnc_COPLog;
            false
        };
        if (!isNil "ALIVE_COP_CLIENT_RUNNING" && {ALIVE_COP_CLIENT_RUNNING}) exitWith {
            ["info", "init", "startClient already running — skipping double-start"] call ALIVE_fnc_COPLog;
            true
        };
        ALIVE_COP_CLIENT_RUNNING = true;
        ["info", "init", "startClient dispatched for side %1", [_arg]] call ALIVE_fnc_COPLog;
        // COPClient waits briefly for player then registers a Map mission EH
        // that attaches the Draw EH on first map open. Spawn so Init returns.
        [_arg] spawn ALIVE_fnc_COPClient;
        true
    };

    case "stop": {
        ALIVE_COP_SERVER_RUNNING = false;
        ALIVE_COP_ASYM_RUNNING   = false;
        ALIVE_COP_CLIENT_RUNNING = false;
        ["info", "init", "stop dispatched — server + asym loops will exit on next cycle"] call ALIVE_fnc_COPLog;
        true
    };

    default {
        ["error", "init", "unknown operation '%1'", [_operation]] call ALIVE_fnc_COPLog;
        false
    };
};

TRACE_1("COPInit - output",_result);
_result
