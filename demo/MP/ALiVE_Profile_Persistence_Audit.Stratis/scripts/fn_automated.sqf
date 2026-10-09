// Opt-in unattended run. Keep all audit failures visible, including unfixed findings.
PA_busy = true;
private _allResults = [];
diag_log "[PA] AUTOMATED START";
{
    private _mode = _x;
    PA_results = [];
    diag_log format ["[PA] AUTOMATED SUITE START | %1", _mode];
    [{params ["_mode"]; [_mode] call PA_fnc_local}, [_mode]] call CBA_fnc_directCall;
    _allResults append PA_results;
    diag_log format ["[PA] AUTOMATED SUITE END | %1 | assertions=%2 | failures=%3",
        _mode, count PA_results, {(_x select 1) == "FAIL"} count PA_results];
    sleep 0.1;
} forEach ["roundtrip", "empty"];
PA_results = _allResults;
PA_busy = false;
diag_log format ["[PA] AUTOMATED COMPLETE | assertions=%1 | failures=%2",
    count PA_results, {(_x select 1) == "FAIL"} count PA_results];
