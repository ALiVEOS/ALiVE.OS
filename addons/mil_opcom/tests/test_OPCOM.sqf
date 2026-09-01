// ----------------------------------------------------------------------------
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(test_OPCOM);
// ----------------------------------------------------------------------------

if !(isnil QGVAR(TEST_OPCOM)) exitwith {};

GVAR(TEST_OPCOM) = true;

#define MAINCLASS ALiVE_fnc_OPCOM

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
["Timer End %1",_timeEnd] call ALiVE_fnc_dump;

//========================================

LOG("Testing OPCOM");

TIMERSTART

STAT("Testing task profile override parsing");

private _overrideHandler = [] call ALIVE_fnc_hashCreate;
private _countOverrides = [objNull, "parseTaskProfileCountOverrides", "[[""attack"",6],[""defend"",3],[""terrorize"",2],[""ambush"",1],[""reserve"",0]]"] call MAINCLASS;
private _typeOverrides = [objNull, "parseTaskProfileTypeOverrides", "[[""attack"",[""mechanized"",""ARMORED""]],[""ambush"",[""infantry""]],[""terrorize"",[""motorized""]],[""reserve"",[]]]"] call MAINCLASS;
private _malformedOverrideHandler = [] call ALIVE_fnc_hashCreate;
private _malformedCountOverrides = [objNull, "parseTaskProfileCountOverrides", "[[123,2],[""attack"",5]]"] call MAINCLASS;
private _malformedTypeOverrides = [objNull, "parseTaskProfileTypeOverrides", "[[123,[""air""]],[""attack"",[""mechanized""]]]"] call MAINCLASS;
private _syntaxErrorOverrideHandler = [] call ALIVE_fnc_hashCreate;
private _syntaxErrorCountOverrides = [objNull, "parseTaskProfileCountOverrides", "[[""attack"",6]"] call MAINCLASS;
private _syntaxErrorTypeOverrides = [objNull, "parseTaskProfileTypeOverrides", "[[""attack"",[""mechanized""]]" ] call MAINCLASS;
private _invalidTokenOverrideHandler = [] call ALIVE_fnc_hashCreate;
private _invalidTokenTypeOverrides = [objNull, "parseTaskProfileTypeOverrides", "[[""attack"",[""mechnized""]],[""reserve"",[]]]"] call MAINCLASS;

[_overrideHandler, "taskProfileCountOverrides", _countOverrides] call ALIVE_fnc_hashSet;
[_overrideHandler, "taskProfileTypeOverrides", _typeOverrides] call ALIVE_fnc_hashSet;
[_malformedOverrideHandler, "taskProfileCountOverrides", _malformedCountOverrides] call ALIVE_fnc_hashSet;
[_malformedOverrideHandler, "taskProfileTypeOverrides", _malformedTypeOverrides] call ALIVE_fnc_hashSet;
[_syntaxErrorOverrideHandler, "taskProfileCountOverrides", _syntaxErrorCountOverrides] call ALIVE_fnc_hashSet;
[_syntaxErrorOverrideHandler, "taskProfileTypeOverrides", _syntaxErrorTypeOverrides] call ALIVE_fnc_hashSet;
[_invalidTokenOverrideHandler, "taskProfileTypeOverrides", _invalidTokenTypeOverrides] call ALIVE_fnc_hashSet;

_err = "Attack count override parse failed";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileCount", ["attack", 4]] call MAINCLASS) == 6, _err);

_err = "Terrorize fallback count override failed";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileCount", ["factory", 1, "terrorize"]] call MAINCLASS) == 2, _err);

_err = "Zero reserve override should be preserved";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileCount", ["reserve", 3]] call MAINCLASS) == 0, _err);

_err = "Attack type override parse failed";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileTypes", ["attack", ["infantry"]]] call MAINCLASS) isEqualTo ["mechanized", "armored"], _err);

_err = "Terrorize fallback type override failed";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileTypes", ["suicide", ["infantry"], "terrorize"]] call MAINCLASS) isEqualTo ["motorized"], _err);

_err = "Empty reserve type override should be preserved";
ASSERT_TRUE(([_overrideHandler, "getTaskProfileTypes", ["reserve", ["infantry"]]] call MAINCLASS) isEqualTo [], _err);

_err = "Malformed count override entries should be ignored safely";
ASSERT_TRUE(([_malformedOverrideHandler, "getTaskProfileCount", ["attack", 4]] call MAINCLASS) == 5, _err);

_err = "Malformed type override entries should be ignored safely";
ASSERT_TRUE(([_malformedOverrideHandler, "getTaskProfileTypes", ["attack", ["infantry"]]] call MAINCLASS) isEqualTo ["mechanized"], _err);

_err = "Syntax errors in count overrides should fall back safely";
ASSERT_TRUE(([_syntaxErrorOverrideHandler, "getTaskProfileCount", ["attack", 4]] call MAINCLASS) == 4, _err);

_err = "Syntax errors in type overrides should fall back safely";
ASSERT_TRUE(([_syntaxErrorOverrideHandler, "getTaskProfileTypes", ["attack", ["infantry"]]] call MAINCLASS) isEqualTo ["infantry"], _err);

_err = "Invalid type tokens should not create empty overrides";
ASSERT_TRUE(([_invalidTokenOverrideHandler, "getTaskProfileTypes", ["attack", ["infantry"]]] call MAINCLASS) isEqualTo ["infantry"], _err);

_err = "Explicit empty type overrides should still be preserved";
ASSERT_TRUE(([_invalidTokenOverrideHandler, "getTaskProfileTypes", ["reserve", ["infantry"]]] call MAINCLASS) isEqualTo [], _err);

STAT("Testing asymmetric installation override parsing");

private _installationOverrides = [objNull, "parseAsymmetricInstallationCountOverrides", "[[""HQ"",2],[""depot"",0],[""roadblock"",1],[""factory"",3]]"] call MAINCLASS;
private _aliasInstallationOverrides = [objNull, "parseAsymmetricInstallationCountOverrides", "[[""recruit"",1],[""ied_factory"",2]]"] call MAINCLASS;
private _malformedInstallationOverrides = [objNull, "parseAsymmetricInstallationCountOverrides", "[[123,2],[""factory"",1]]"] call MAINCLASS;
private _syntaxErrorInstallationOverrides = [objNull, "parseAsymmetricInstallationCountOverrides", "[[""factory"",2]"] call MAINCLASS;

_err = "HQ installation override parse failed";
ASSERT_TRUE(([_installationOverrides, "HQ", -1] call ALIVE_fnc_hashGet) == 2, _err);

_err = "Roadblock alias should normalize to roadblocks";
ASSERT_TRUE(([_installationOverrides, "roadblocks", -1] call ALIVE_fnc_hashGet) == 1, _err);

_err = "Zero depot override should be preserved";
ASSERT_TRUE(([_installationOverrides, "depot", -1] call ALIVE_fnc_hashGet) == 0, _err);

_err = "Recruit alias should normalize to HQ";
ASSERT_TRUE(([_aliasInstallationOverrides, "HQ", -1] call ALIVE_fnc_hashGet) == 1, _err);

_err = "IED factory alias should normalize to factory";
ASSERT_TRUE(([_aliasInstallationOverrides, "factory", -1] call ALIVE_fnc_hashGet) == 2, _err);

_err = "Malformed installation override entries should be ignored safely";
ASSERT_TRUE(([_malformedInstallationOverrides, "factory", -1] call ALIVE_fnc_hashGet) == 1, _err);

_err = "Syntax errors in installation overrides should fall back safely";
ASSERT_TRUE(count (_syntaxErrorInstallationOverrides select 1) == 0, _err);

_err = "Unknown installation types should normalize to an empty string";
ASSERT_TRUE(([objNull, "normalizeAsymmetricInstallationType", "unknown"] call MAINCLASS) == "", _err);

STAT("Testing empty troop snapshot publication");

private _emptyTroopHandler = [] call ALIVE_fnc_hashCreate;
[_emptyTroopHandler, "factions", []] call ALIVE_fnc_hashSet;
{
    [_emptyTroopHandler, _x, ["stale-profile"]] call ALIVE_fnc_hashSet;
} forEach ["infantry","motorized","mechanized","armored","artillery","AAA","air","sea"];
[_emptyTroopHandler, "currentForceStrength", [1,1,1,1,1,1,1,1]] call ALIVE_fnc_hashSet;
[_emptyTroopHandler, "startForceStrength", [2,2,2,2,2,2,2,2]] call ALIVE_fnc_hashSet;

private _emptyTroopResult = [_emptyTroopHandler, "scantroops"] call MAINCLASS;

_err = "Empty troop scan should return eight empty categories";
ASSERT_TRUE(_emptyTroopResult isEqualTo [[],[],[],[],[],[],[],[]], _err);

_err = "Empty troop scan should clear every published category";
ASSERT_TRUE(({([_emptyTroopHandler, _x, ["stale-profile"]] call ALIVE_fnc_hashGet) isEqualTo []} count ["infantry","motorized","mechanized","armored","artillery","AAA","air","sea"]) == 8, _err);

_err = "Empty troop scan should publish zero current force strength";
ASSERT_TRUE(([_emptyTroopHandler, "currentForceStrength", []] call ALIVE_fnc_hashGet) isEqualTo [0,0,0,0,0,0,0,0], _err);

_err = "Empty troop scan should preserve the historical starting force strength";
ASSERT_TRUE(([_emptyTroopHandler, "startForceStrength", []] call ALIVE_fnc_hashGet) isEqualTo [2,2,2,2,2,2,2,2], _err);

STAT("Creating Virtual AI System...");

//Profile System
private ["_logic"];
_logic = (createGroup sideLogic) createUnit ["ALiVE_sys_profile", [0,0], [], 0, "NONE"];
_logic setVariable ["debug","true"];
_logic setVariable ["spawnRadius","1500"];
_profiles = _logic;
waituntil {!isnil "ALIVE_profileSystem"};

STAT("Testing correlated OPCOM/TACOM order lifecycle");

private _waitForRuntimeCondition = {
    params ["_condition", ["_timeout", 5]];
    private _deadline = diag_tickTime + _timeout;

    waitUntil {
        sleep 0.05;
        (call _condition) || {diag_tickTime >= _deadline}
    };

    call _condition
};

private _enqueueRuntimeMessage = {
    params ["_fsm", "_queueName", "_message"];
    private _queue = _fsm getFSMVariable [_queueName, []];
    _queue pushBack _message;
    _fsm setFSMVariable [_queueName, _queue];
    _fsm setFSMVariable ["_busy", false];
};

private _makeRuntimeObjective = {
    params ["_id", "_state"];

    [[
        ["objectiveID", _id],
        ["center", [1000, 1000, 0]],
        ["size", 100],
        ["objectiveType", "mil"],
        ["priority", 1],
        ["opcom_state", _state],
        ["clusterID", "runtime-test"],
        ["opcomID", "runtime-test"],
        ["deleted", false],
        ["_rev", ""],
        ["opcom_orders", "none"],
        ["danger", -1],
        ["sectionAssist", []],
        ["section", []],
        ["tacom_state", "none"]
    ]] call ALIVE_fnc_hashCreate
};

private _runtimeObjectives = [];
private _runtimeHandler = [[
    ["class", "ALiVE_OPCOM_RUNTIME_TEST"],
    ["module", objNull],
    ["side", "WEST"],
    ["factions", ["BLU_F"]],
    ["sidesenemy", ["EAST"]],
    ["sidesfriendly", ["WEST"]],
    ["controltype", "invasion"],
    ["simultanobjectives", 1],
    ["reinforcements", 0.9],
    ["debug", false],
    ["opcomID", "runtime-test"],
    ["objectives", _runtimeObjectives],
    ["objectivesByID", createHashMap],
    ["profileObjectiveAssignment", createHashMap],
    ["clusteroccupation", [[], [], [], time]],
    ["pendingorders", []],
    ["playertasks", []],
    ["infantry", []],
    ["motorized", []],
    ["mechanized", []],
    ["armored", []],
    ["artillery", []],
    ["AAA", []],
    ["air", []],
    ["sea", []],
    ["knownentities", []],
    ["sectionsamount_attack", 1],
    ["sectionsamount_defend", 1],
    ["sectionsamount_reserve", 1]
]] call ALIVE_fnc_hashCreate;

private _runtimeOPCOM = [_runtimeHandler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
private _runtimeTACOM = [_runtimeHandler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";
[_runtimeHandler, "OPCOM_FSM", _runtimeOPCOM] call ALiVE_fnc_HashSet;
[_runtimeHandler, "TACOM_FSM", _runtimeTACOM] call ALiVE_fnc_HashSet;

private _runtimeReady = [{
    !isNil {_runtimeOPCOM getFSMVariable "_OPCOM_QUEUE"}
    && {!isNil {_runtimeTACOM getFSMVariable "_TACOM_QUEUE"}}
    && {(_runtimeOPCOM getFSMVariable ["_OPCOM_status", "PreInit"]) != "PreInit"}
    && {(_runtimeTACOM getFSMVariable ["_TACOM_status", "PreInit"]) != "PreInit"}
}, 10] call _waitForRuntimeCondition;

_err = "Isolated OPCOM/TACOM FSMs did not initialize";
ASSERT_TRUE(_runtimeReady, _err);

_runtimeOPCOM setFSMVariable ["_cycleTime", 1e9];
_runtimeOPCOM setFSMVariable ["_lastAnalyze", time];
_runtimeTACOM setFSMVariable ["_lastAnalyze", time];

private _runtimeSettled = [{
    !(_runtimeOPCOM getFSMVariable ["_busy", true])
    && {!(_runtimeTACOM getFSMVariable ["_busy", true])}
    && {(_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE", []]) isEqualTo []}
    && {(_runtimeTACOM getFSMVariable ["_TACOM_QUEUE", []]) isEqualTo []}
}, 10] call _waitForRuntimeCondition;

_err = "Isolated OPCOM/TACOM FSMs did not become idle";
ASSERT_TRUE(_runtimeSettled, _err);

// Manual tasks must carry their complete request in the TACOM queue and must
// never recruit profiles beyond the IDs supplied by the caller.
_runtimeTACOM setFSMVariable ["_pause", true];
private _manualTacomPaused = [{
    !(_runtimeTACOM getFSMVariable ["_busy", true])
}, 3] call _waitForRuntimeCondition;
_err = "TACOM did not become idle before the manual-order test";
ASSERT_TRUE(_manualTacomPaused, _err);

private _manualObjective = [_runtimeHandler,"addTask",["recon",[1200,1200,0],["runtime-profile-a","runtime-profile-a",42,"runtime-profile-b"]]] call MAINCLASS;
private _manualQueue = _runtimeTACOM getFSMVariable ["_TACOM_QUEUE",[]];
private _manualMessageIndex = _manualQueue findIf {(_x param [0,""]) == "manual_order"};
_err = "addTask did not enqueue a manual_order message";
ASSERT_TRUE(_manualMessageIndex >= 0, _err);

private _manualPayload = if (_manualMessageIndex >= 0) then {
    (_manualQueue select _manualMessageIndex) select 1
} else {
    []
};
_err = "Manual order did not preserve its operation and exact deduplicated profile IDs";
ASSERT_TRUE(
    (_manualPayload param [0,""]) == "recon"
    && {(_manualPayload param [1,[]]) isEqualRef _manualObjective}
    && {(_manualPayload param [2,[]]) isEqualTo ["runtime-profile-a","runtime-profile-b"]},
    _err
);
_err = "Manual task mutated TACOM operation state before dequeue";
ASSERT_TRUE(isNil {_runtimeTACOM getFSMVariable "_recon"}, _err);
_err = "Manual task assigned profiles before its queued message was dequeued";
ASSERT_TRUE(([_manualObjective,"section",[]] call ALiVE_fnc_HashGet) isEqualTo [], _err);
_err = "Manual task objective was not created as internal transient state";
ASSERT_TRUE(
    ([_manualObjective,"objectiveID",""] call ALiVE_fnc_HashGet) isNotEqualTo ""
    && {([_manualObjective,"center",[]] call ALiVE_fnc_HashGet) isEqualTo [1200,1200,0]}
    && {([_manualObjective,"opcom_state",""] call ALiVE_fnc_HashGet) == "internal"}
    && {[_manualObjective,"manualTask",false] call ALiVE_fnc_HashGet},
    _err
);

private _manualObjectiveID = [_manualObjective,"objectiveID",""] call ALiVE_fnc_HashGet;
_runtimeTACOM setFSMVariable ["_pause", false];
private _manualOrderCleanedUp = [{
    private _objectivesByID = [_runtimeHandler,"objectivesByID"] call ALiVE_fnc_HashGet;
    isNil {_objectivesByID get _manualObjectiveID}
    && {!(_runtimeTACOM getFSMVariable ["_busy", true])}
}, 10] call _waitForRuntimeCondition;
_err = "Failed manual order did not clean up its transient objective";
ASSERT_TRUE(_manualOrderCleanedUp, _err);
_err = "Manual order emitted an OPCOM confirmation";
ASSERT_TRUE(
    ((_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE",[]]) findIf {(_x param [0,""]) == "confirmed"}) < 0,
    _err
);

private _protocolObjective = ["runtime-protocol", "attack"] call _makeRuntimeObjective;

// ID-less confirmations must not resolve a live request.
private _strictOrderID = 900001;
_runtimeOPCOM setFSMVariable ["_unconfirmedOrders", [[_strictOrderID, "reserve", _protocolObjective, time + 60]]];
[_runtimeOPCOM, "_OPCOM_QUEUE", ["confirmed", [false, [_protocolObjective, []]]]] call _enqueueRuntimeMessage;

private _legacyConfirmationProcessed = [{
    ((_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE", []]) findIf {(_x param [0, ""]) == "confirmed"}) < 0
}, 3] call _waitForRuntimeCondition;

_err = "ID-less confirmation was not processed by the runtime harness";
ASSERT_TRUE(_legacyConfirmationProcessed, _err);
_err = "ID-less confirmation incorrectly resolved a correlated order";
ASSERT_TRUE((count (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []])) == 1, _err);

// A valid ID for the wrong objective must also leave the request untouched.
private _wrongObjective = ["runtime-wrong-objective", "attack"] call _makeRuntimeObjective;
[_runtimeOPCOM, "_OPCOM_QUEUE", ["confirmed", [false, [_wrongObjective, []], _strictOrderID, time]]] call _enqueueRuntimeMessage;
private _wrongObjectiveConfirmationProcessed = [{
    ((_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE", []]) findIf {(_x param [0, ""]) == "confirmed"}) < 0
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Mismatched objective confirmation was not processed by the runtime harness";
ASSERT_TRUE(_wrongObjectiveConfirmationProcessed, _err);
_err = "Mismatched objective confirmation incorrectly resolved a correlated order";
ASSERT_TRUE((count (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []])) == 1, _err);

// The exact ID/objective pair must resolve it.
[_runtimeOPCOM, "_OPCOM_QUEUE", ["confirmed", [false, [_protocolObjective, []], _strictOrderID, time]]] call _enqueueRuntimeMessage;
private _strictOrderResolved = [{
    (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []]) isEqualTo []
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Strictly correlated confirmation did not resolve its order";
ASSERT_TRUE(_strictOrderResolved, _err);

// An order already expired in TACOM's queue must be rejected without tactical mutation.
private _expiredOrderID = 900002;
private _expiredDeadline = time - 1;
private _tacomStateBeforeExpiry = [_protocolObjective, "tacom_state", "none"] call ALiVE_fnc_HashGet;
private _sectionBeforeExpiry = +([_protocolObjective, "section", []] call ALiVE_fnc_HashGet);
_runtimeOPCOM setFSMVariable ["_unconfirmedOrders", [[_expiredOrderID, "attack", _protocolObjective, _expiredDeadline]]];
[_runtimeTACOM, "_TACOM_QUEUE", ["analyze_order", [_expiredOrderID, "attack", _protocolObjective, _expiredDeadline]]] call _enqueueRuntimeMessage;

private _expiredOrderResolved = [{
    (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []]) isEqualTo []
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
    && {!(_runtimeTACOM getFSMVariable ["_busy", true])}
}, 5] call _waitForRuntimeCondition;
_err = "TACOM did not reject and resolve an already-expired order";
ASSERT_TRUE(_expiredOrderResolved, _err);
_err = "Expired TACOM order changed tactical state";
ASSERT_TRUE(([_protocolObjective, "tacom_state", "none"] call ALiVE_fnc_HashGet) == _tacomStateBeforeExpiry, _err);
_err = "Expired TACOM order changed objective section assignment";
ASSERT_TRUE(([_protocolObjective, "section", []] call ALiVE_fnc_HashGet) isEqualTo _sectionBeforeExpiry, _err);

// A late confirmation for the expired ID must not resolve a retry for the same objective.
private _retryOrderID = 900003;
private _retryDeadline = time + 60;
_runtimeOPCOM setFSMVariable ["_unconfirmedOrders", [[_retryOrderID, "attack", _protocolObjective, _retryDeadline]]];
[_runtimeOPCOM, "_OPCOM_QUEUE", ["confirmed", [true, [_protocolObjective, []], _expiredOrderID, time]]] call _enqueueRuntimeMessage;
private _staleConfirmationProcessed = [{
    ((_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE", []]) findIf {(_x param [0, ""]) == "confirmed"}) < 0
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Stale confirmation was not processed by the runtime harness";
ASSERT_TRUE(_staleConfirmationProcessed, _err);
private _retryOrders = _runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []];
_err = "Late confirmation for an expired ID resolved the retry";
ASSERT_TRUE((count _retryOrders) == 1 && {((_retryOrders select 0) select 0) == _retryOrderID}, _err);
[_runtimeOPCOM, "_OPCOM_QUEUE", ["confirmed", [false, [_protocolObjective, []], _retryOrderID, time]]] call _enqueueRuntimeMessage;
private _retryOrderResolved = [{
    (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []]) isEqualTo []
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Strictly correlated retry confirmation did not resolve its order";
ASSERT_TRUE(_retryOrderResolved, _err);

// Pause TACOM so OPCOM lifecycle follow-ups can be inspected before consumption.
_runtimeTACOM setFSMVariable ["_pause", true];
private _tacomPaused = [{
    !(_runtimeTACOM getFSMVariable ["_busy", true])
}, 3] call _waitForRuntimeCondition;
_err = "TACOM did not become idle before lifecycle inspection";
ASSERT_TRUE(_tacomPaused, _err);
_runtimeTACOM setFSMVariable ["_TACOM_QUEUE", []];

{
    _x params ["_completedOperation", "_expectedOperation"];
    _runtimeOPCOM setFSMVariable ["_unconfirmedOrders", []];
    _runtimeOPCOM setFSMVariable ["_OPCOM_QUEUE", []];
    _runtimeTACOM setFSMVariable ["_TACOM_QUEUE", []];
    [_runtimeOPCOM, "_OPCOM_QUEUE", ["completed", [_completedOperation, _protocolObjective]]] call _enqueueRuntimeMessage;

    private _followUpRegistered = [{
        (count (_runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []])) == 1
        && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
    }, 3] call _waitForRuntimeCondition;
    _err = format ["%1 completion did not register a follow-up order", _completedOperation];
    ASSERT_TRUE(_followUpRegistered, _err);

    private _followUpOrders = _runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []];
    private _followUp = _followUpOrders select 0;
    _err = format ["%1 completion mapped to the wrong strategic operation", _completedOperation];
    ASSERT_TRUE((_followUp select 1) == _expectedOperation, _err);

    private _tacomQueue = _runtimeTACOM getFSMVariable ["_TACOM_QUEUE", []];
    private _requestIndex = _tacomQueue findIf {
        (_x param [0, ""]) == "analyze_order"
        && {(((_x param [1, []]) param [0, -1]) == (_followUp select 0))}
    };
    _err = format ["%1 follow-up was not queued for TACOM", _completedOperation];
    ASSERT_TRUE(_requestIndex >= 0, _err);

    private _requestPayload = (_tacomQueue select _requestIndex) select 1;
    _err = format ["%1 follow-up omitted its absolute deadline", _completedOperation];
    ASSERT_TRUE((count _requestPayload) == 4 && {(_requestPayload select 3) == (_followUp select 3)}, _err);
} forEach [["recon", "attack"], ["capture", "reserve"], ["defend", "defend"]];

// A pending attack must consume the only simultaneous-objective slot.
private _pendingObjective = ["runtime-pending", "attack"] call _makeRuntimeObjective;
private _candidateObjective = ["runtime-candidate", "attack"] call _makeRuntimeObjective;
[_runtimeHandler, "objectives", [_candidateObjective]] call ALiVE_fnc_HashSet;
[_runtimeHandler, "clusteroccupation", [[], [], [], time]] call ALiVE_fnc_HashSet;
_runtimeOPCOM setFSMVariable ["_unconfirmedOrders", [[900100, "attack", _pendingObjective, time + 60]]];
_runtimeOPCOM setFSMVariable ["_OPCOM_QUEUE", []];
_runtimeTACOM setFSMVariable ["_TACOM_QUEUE", []];
[_runtimeOPCOM, "_OPCOM_QUEUE", ["analyze", nil]] call _enqueueRuntimeMessage;
private _cappedAnalysisFinished = [{
    ((_runtimeOPCOM getFSMVariable ["_OPCOM_QUEUE", []]) findIf {(_x param [0, ""]) == "analyze"}) < 0
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Capacity-capped analysis did not finish";
ASSERT_TRUE(_cappedAnalysisFinished, _err);
private _cappedOrders = _runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []];
_err = "Pending attack did not consume simultanObjectives capacity";
ASSERT_TRUE((count _cappedOrders) == 1 && {((_cappedOrders select 0) select 0) == 900100}, _err);

// Releasing the slot must allow the candidate attack to be registered.
_runtimeOPCOM setFSMVariable ["_unconfirmedOrders", []];
[_runtimeOPCOM, "_OPCOM_QUEUE", ["analyze", nil]] call _enqueueRuntimeMessage;
private _candidateRegistered = [{
    private _orders = _runtimeOPCOM getFSMVariable ["_unconfirmedOrders", []];
    (count _orders) == 1 && {((_orders select 0) select 2) isEqualRef _candidateObjective}
    && {!(_runtimeOPCOM getFSMVariable ["_busy", true])}
}, 3] call _waitForRuntimeCondition;
_err = "Attack was not registered after simultanObjectives capacity was released";
ASSERT_TRUE(_candidateRegistered, _err);

// Stop the isolated FSM pair before continuing with the existing integration test.
_runtimeTACOM setFSMVariable ["_pause", false];
_runtimeTACOM setFSMVariable ["_exitFSM", true];
_runtimeTACOM setFSMVariable ["_busy", false];
_runtimeOPCOM setFSMVariable ["_exitFSM", true];
_runtimeOPCOM setFSMVariable ["_busy", false];
private _runtimeStopped = [{
    completedFSM _runtimeTACOM && {completedFSM _runtimeOPCOM}
}, 5] call _waitForRuntimeCondition;
_err = "Isolated OPCOM/TACOM FSMs did not stop";
ASSERT_TRUE(_runtimeStopped, _err);

STAT("Testing deferred enemy-scan publication");

private _deferredScanHandler = [] call ALIVE_fnc_hashCreate;
[_deferredScanHandler, "factions", []] call ALIVE_fnc_hashSet;
[_deferredScanHandler, "knownentities", [["stale-contact"]]] call ALIVE_fnc_hashSet;

private _deferredScanResult = [_deferredScanHandler, "scanFriendliesForNearEnemies", [false]] call MAINCLASS;

_err = "Deferred enemy scan should still return its private result";
ASSERT_TRUE(_deferredScanResult isEqualTo [], _err);

_err = "Deferred enemy scan should not publish known entities before generation acceptance";
ASSERT_TRUE(([_deferredScanHandler, "knownentities", []] call ALIVE_fnc_hashGet) isEqualTo [["stale-contact"]], _err);

[_deferredScanHandler, "scanFriendliesForNearEnemies"] call MAINCLASS;

_err = "Default enemy scan should preserve its public publication behavior";
ASSERT_TRUE(([_deferredScanHandler, "knownentities", [["stale-contact"]]] call ALIVE_fnc_hashGet) isEqualTo [], _err);


STAT("Creating Military Placement instance");

//Military Placement
private ["_logic"];
_logic = (createGroup sideLogic) createUnit ["ALiVE_mil_placement", [2000,2000], [], 0, "NONE"];
_logic setVariable ["faction","BLU_F"];
_logic setVariable ["debug","true"];
_MP = _logic;
waituntil {_logic getVariable ["startupComplete", false]};

STAT("Creating Military AI Commander instance");

//OPCOM
private ["_logic"];
_logic = [nil,"create"] call MAINCLASS;
_logic setvariable ["faction1","BLU_F"];
_logic setvariable ["debug","true"];
_logic synchronizeObjectsAdd [_MP];

_cond = typeof _logic == QUOTE(ADDON);
_err = "Creation of OPCOM failed";
if !(_cond) then {STAT(_err)};
ASSERT_TRUE(_cond, _err);

sleep 2;

STAT("Destroying Military AI Commander instance");
_instances = count OPCOM_instances;
_result = [_logic, "destroy"] call MAINCLASS;
_err = "Destruction of Military AI Commander failed";
if !(_instances - (count OPCOM_instances) == 1) then {STAT(_err)};
ASSERT_TRUE(_instances - (count OPCOM_instances) == 1, _err);

STAT("Waiting for FSM to end");
sleep 20;

STAT("Cleaning up MP");
_result = [_MP, "destroy"] call ALiVE_fnc_MP;
_err = "Destruction of Military Placement instance failed";
if !(isnull _MP) then {STAT(_err)};
ASSERT_TRUE(isnull _MP, _err);

sleep 2;

STAT("Destroying Virtual AI System");
_result = [ALIVE_profileSystem, "destroy"] call ALIVE_fnc_profileSystem;
_err = "Destruction of Virtual AI System failed";
if (count (ALiVE_ProfileSystem select 1) > 0) then {STAT(_err)};
ASSERT_TRUE(count (ALiVE_ProfileSystem select 1) == 0, _err);

TIMEREND

GVAR(TEST_OPCOM) = nil;
