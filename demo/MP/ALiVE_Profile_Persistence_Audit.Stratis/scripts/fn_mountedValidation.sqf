// Repeat the real PNS load with both record orders. An entity-first save
// exposes speed calculations that run before the referenced vehicles exist.
params ["_saved", "_baseline"];
private _snapshots = _baseline select 1;
{
    private _firstType = _x;
    private _label = ["vehicles first", "entities first"] select (_firstType == 1);
    private _ordered = [] call ALIVE_fnc_hashCreate;
    {
        private _type = _x;
        {
            if (([_x, "type"] call ALIVE_fnc_hashGet) == _type) then {
                [_ordered, (_saved select 1) select _forEachIndex, _x] call ALIVE_fnc_hashSet;
            };
        } forEach (_saved select 2);
    } forEach [_firstType, 3 - _firstType];
    [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _ordered, PA_missionKey, false]] call ALIVE_fnc_Data;
    private _written = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
    private _orderReady = [format ["Mounted-speed fixture saved with %1", _label],
        (_written select 1) isEqualTo (_ordered select 1),
        _ordered select 1, _written select 1] call PA_fnc_assert;
    if (_orderReady) then {
        ALIVE_loadProfilesPersistent = true;
        ALiVE_sysProfileLastLoadTime = nil;
        call ALIVE_fnc_profilesLoadData;
        {
            _x params ["_alias", "_id", "_fields"];
            if (_alias in ["mounted", "partlyMounted", "multipleVehicles", "onFoot"]) then {
                private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
                [format ["%1 / %2: profile exists", _label, _alias], !isNil "_profile", _id,
                    if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
                if (!isNil "_profile") then {
                    {
                        _x params ["_field", "_expected"];
                        if (_field in ["speedPerSecond", "unitCount"]) then {
                            private _actual = [_profile, _field, "(missing)"] call ALIVE_fnc_hashGet;
                            [format ["%1 / %2: %3 restored", _label, _alias, _field],
                                _actual isEqualTo _expected, _expected, _actual] call PA_fnc_assert;
                        };
                    } forEach _fields;
                };
            };
        } forEach _snapshots;
    };
} forEach [1, 2];

// Old saves may reference a vehicle that no longer exists. Exercise the
// same speed resolver without registering or modifying this probe profile.
private _missingID = "PA_SPEED_MISSING_VEHICLE_PROBE";
private _probe = [nil, "create"] call ALIVE_fnc_profileEntity;
[_probe, "init"] call ALIVE_fnc_profileEntity;
[_probe, "unitClasses", ["B_crew_F"]] call ALIVE_fnc_profileEntity;
[_probe, "unitCount"] call ALIVE_fnc_profileEntity;
[_probe, "vehiclesInCommandOf", [_missingID]] call ALIVE_fnc_hashSet;
private _assignment = [_missingID, "PA_SPEED_PROBE_ENTITY", [[0], [], [], [], [], []]];
private _assignments = [[[_missingID, _assignment]]] call ALIVE_fnc_hashCreate;
[_probe, "vehicleAssignments", _assignments] call ALIVE_fnc_hashSet;
private _result = "PA_speed_probe_result";
private _speed = [_assignments, _probe] call ALIVE_fnc_profileVehicleAssignmentsGetSpeedPerSecond;
["Unresolved vehicle references return a complete walking-speed array",
    _speed isEqualTo ("Man" call ALIVE_fnc_vehicleGetSpeedPerSecond),
    "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond, _speed] call PA_fnc_assert;
["Speed resolver leaves its caller's result unchanged",
    _result isEqualTo "PA_speed_probe_result", "PA_speed_probe_result", _result] call PA_fnc_assert;

// Keep the original saved fixture snapshot available for a later cold load.
[ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _saved, PA_missionKey, false]] call ALIVE_fnc_Data;
ALIVE_loadProfilesPersistent = true;
ALiVE_sysProfileLastLoadTime = nil;
call ALIVE_fnc_profilesLoadData;
diag_log "[PA] Mounted-speed ordering checks finished; the original profile snapshot was restored.";
