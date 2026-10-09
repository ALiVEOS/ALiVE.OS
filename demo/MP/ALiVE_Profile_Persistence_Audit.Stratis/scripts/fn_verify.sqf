private _baseline = profileNamespace getVariable [PA_baselineKey, []];
if (count _baseline < 3) exitWith {
    "[PA] BLOCKED: no saved baseline; run Local tests or Save fresh fixtures first." remoteExec ["systemChat", 0];
};
_baseline params ["_mode", "_snapshots", "_pendingDestination"];
if (_mode == "empty") exitWith {
    ["Empty save is accepted as persistent", ALIVE_loadProfilesPersistent, true, ALIVE_loadProfilesPersistent] call PA_fnc_assert;
    private _export = [ALIVE_profileHandler, "exportProfileData"] call ALIVE_fnc_profileHandler;
    ["Empty save leaves no non-player profiles", count (_export select 1) == 0, 0, count (_export select 1)] call PA_fnc_assert;
};
PA_fixtures = _snapshots apply {[_x select 0, _x select 1]};
{
    _x params ["_alias", "_id", "_fields"];
    private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
    [format ["%1: profile exists after load", _alias], !isNil "_profile", _id,
        if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
    if (!isNil "_profile") then {
        {
            _x params ["_key", "_expected"];
            private _actual = [_profile, _key, "(missing)"] call ALIVE_fnc_hashGet;
            [format ["%1: %2 survives save/load", _alias, _key],
                _actual isEqualTo _expected, _expected, _actual] call PA_fnc_assert;
        } forEach _fields;
        if (_alias == "pending") then {
            private _applied = ([_profile, "waypoints", []] call ALIVE_fnc_hashGet)
                + ([_profile, "waypointsCompleted", []] call ALIVE_fnc_hashGet);
            private _destinations = _applied apply {[_x, "position"] call ALIVE_fnc_hashGet};
            {
                _destinations pushBack ([_x select 3, "position"] call ALIVE_fnc_hashGet);
            } forEach ([_profile, "pendingWaypointPaths", []] call ALIVE_fnc_hashGet);
            ["Applied route control survives", [1850, 5620, 0] in _destinations, [1850, 5620, 0], _destinations] call PA_fnc_assert;
            ["Queued order destination survives, applied or awaiting a new path",
                _pendingDestination in _destinations, _pendingDestination, _destinations] call PA_fnc_assert;
        };
    };
} forEach _snapshots;
diag_log format ["[PA] SUMMARY: %1 PASS, %2 FAIL", {(_x select 1) == "PASS"} count PA_results, {(_x select 1) == "FAIL"} count PA_results];
