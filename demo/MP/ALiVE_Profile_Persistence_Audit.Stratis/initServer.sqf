// Test mission only. Production functions are used without patching them.
PA_ready = false;
PA_busy = false;
PA_results = [];
PA_fixtures = [];
private _deadline = diag_tickTime + 120;
waitUntil {
    sleep 0.1;
    (missionNamespace getVariable ["ALIVE_profileSystemInit", false])
    || {diag_tickTime > _deadline}
};
if !(missionNamespace getVariable ["ALIVE_profileSystemInit", false]) exitWith {
    "[PA] BLOCKED: profile initialization timed out; check the server RPT." remoteExec ["systemChat", 0];
};
if (isNil "ALIVE_sys_data" || {missionNamespace getVariable ["ALIVE_sys_data_DISABLED", true]}) exitWith {
    "[PA] BLOCKED: the Local Data module is unavailable." remoteExec ["systemChat", 0];
};
// Freeze simulation and automatic activation. Explicit spawn actions still work.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
PA_missionKey = ([""] call ALIVE_fnc_storeKeys) select 0;
PA_baselineKey = PA_missionKey + "_PA_BASELINE_V1";
PA_ready = true;
private _baseline = profileNamespace getVariable [PA_baselineKey, []];
if (count _baseline > 0) then {
    // Keep this unscheduled: performance consumers must not repair unitCount
    // between loading and observing its raw cached value.
    [{[] call PA_fnc_verify}, []] call CBA_fnc_directCall;
};
"[PA] Ready. Use the player action menu. FAIL means the persistence invariant did not survive." remoteExec ["systemChat", 0];
