// ----------------------------------------------------------------------------

#include "\x\alive\addons\mil_logistics\script_component.hpp"
SCRIPT(test_ML_AIRLIFT_AIRCRAFT);

// execVM "\x\alive\addons\mil_logistics\tests\test_ML_AIRLIFT_AIRCRAFT.sqf"
//
// Triggers the OPCOM strategic AIRLIFT path (Rule 1.5 + opcomAirlift*
// state machine) with a fixed-wing transport class set on the synced
// Mil Logistics module. Use this to smoke-test the full
// dispatch -> fly -> land -> unload -> takeoff2 -> RTB -> returnLand
// -> despawn pipeline end-to-end.
//
// Expected RPT signal sequence (search "AIRLIFT"):
//   ML - AIRLIFT airliftAircraftClass: <class>...
//   ML - Delivery type: AIRLIFT (source ... -> dest ...)
//   ML - AIRLIFT _reinforcementPosition overridden to source airport ...
//   ML - AIRLIFT dispatched: plane ... source airport ... -> dest airport ...
//   ML - opcomAirliftFly: ... distance to dest=...m tick=...
//   ML - opcomAirliftFly: plane within approach distance (...m <= 3000m), transitioning to opcomAirliftLand
//   ML - opcomAirliftLand: landAt issued for plane ... at dest airport ...
//   ML - opcomAirliftLand: plane stopped on runway. Transitioning to opcomAirliftUnload
//   ML - opcomAirliftUnload: ... cargo profiles repositioned to dest airport ...
//   ML - opcomAirliftTakeoff2: plane woken up, RTB waypoint added to source airport ...
//   ML - opcomAirliftTakeoff2: plane airborne (AGL ...m) ...
//   ML - opcomAirliftRTB: ... distance to source=...m tick=...
//   ML - opcomAirliftReturnLand: ... (landAt issued OR no players within 1000m, skipping)
//   ML - opcomAirliftDespawn: source runway released, ... profiles despawned. Event ... complete.
//
// Suppression cases (any of these means Rule 1.5 didn't fire -- read the
// log line to see why and adjust mission setup):
//   ML - AIRLIFT suppressed: airliftAircraftClass ... invalid ...
//   ML - AIRLIFT suppressed: no friendly airports for side ...
//   ML - AIRLIFT suppressed: no destination airport within 3000m ...
//   ML - AIRLIFT suppressed: only one friendly airport ... -- offmap fallback ...
//     (offmap fallback should activate; if you see this, check
//      calculateOffmapSpawnPos returned a position >= 1500m from dest)
//   ML - AIRLIFT suppressed: flight distance ...m < 1500m minimum
//
// Pre-flight checklist for the mission running this test:
//   - Mil Logistics module placed, airliftAircraftClass set to a cargo plane
//     classname that's kindOf Plane and has transportSoldier > 0.
//     Vanilla candidates: B_T_VTOL_01_infantry_F (BLUFOR),
//     O_T_VTOL_02_infantry_F (OPFOR), I_T_VTOL_02_infantry_F (IND).
//     RHS / CUP / SPE C-130 variants also work.
//   - Mil OPCOM module placed and synced to the Mil Logistics module,
//     side / faction matching the _side / _faction below.
//   - At least one friendly OPCOM-held objective within 250m of a map
//     airport for the test to find a destination airport. For the
//     two-airport path you need two such airfields.
//
// Adjust _position to a held-or-near-held position that has a
// friendly airport in range (default below uses the player position
// + offset for convenience; on Altis this works near Pyrgos / Selakano).

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_position","_faction","_side","_forceMakeup","_event","_eventID"];

LOG("Testing ML AIRLIFT PLANE");

ASSERT_DEFINED("ALIVE_fnc_ML","");

#define STAT(msg) sleep 0.5; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

//========================================

STAT("Create OPCOM AIRLIFT reinforcement event (forces eventType pre-decision tree)");

// Drop destination 200m off the player's south side -- close enough
// to verify visually but far enough that ground convoy isn't trivially
// preferred by Rule 0.
_position = ((getPos player) getPos [200, 180]);

_faction = "BLU_F";
_side = "WEST";

// Mixed force makeup -- exercises the cargo unload path for infantry
// + motorised + armour. Plane / heli reinforcement profiles excluded
// (they're cargo categories not delivery vehicles, and add complexity
// to verify visually). Switch to pure infantry for first-pass smoke
// tests, mixed for cargo unload coverage.
_forceMakeup = [
    3, // infantry
    1, // motorised
    1, // mechanised
    1, // armour
    0, // plane (cargo)
    0  // heli  (cargo)
];

// Pure-infantry alt for first-pass smoke testing (uncomment to use):
// _forceMakeup = [3, 0, 0, 0, 0, 0];

// IMPORTANT: eventType "AIRLIFT" here is what OPCOM would emit for
// the test bypass path. The Rule 1.5 decision tree will pick AIRLIFT
// naturally if all conditions are met regardless of what's passed
// here, but using AIRLIFT makes the intent explicit.
_event = ['LOGCOM_REQUEST', [_position,_faction,_side,_forceMakeup,"AIRLIFT"],"OPCOM"] call ALIVE_fnc_event;
_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

diag_log format ["TEST_ML_AIRLIFT_PLANE: Event %1 dispatched. Watch RPT for ML - AIRLIFT* lines.", _eventID];

nil;
