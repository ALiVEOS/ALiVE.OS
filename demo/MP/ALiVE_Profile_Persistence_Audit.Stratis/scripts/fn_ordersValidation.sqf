// Replay real queued orders and wait for the new engine jobs to finish.
[ALIVE_profileSystem, "pause", true] call ALIVE_fnc_profileSystem;
private _pathfindingWasEnabled = [ALIVE_profileSystem, "pathfinding"] call ALIVE_fnc_profileSystem;
[ALIVE_profileSystem, "pathfinding", true] call ALIVE_fnc_profileSystem;
PA_stale_order_callback = nil;
private _fixtures = [];
private _saved = [];
private _control = [1850, 5620, 0];
private _appendA = [1907, 5631, 0];
private _appendB = [1959, 5627, 0];
private _front = [1783, 5643, 0];
private _ambient = [1900, 5550, 0];
private _cancelled = [1880, 5540, 0];
private _legacyRaw = [];
[{
    {[ALIVE_Pathfinder, "cancelProfilePaths", _x] call ALIVE_fnc_pathfinder} forEach
        (([ALIVE_profileHandler, "getProfiles"] call ALIVE_fnc_profileHandler) select 1);
    [ALIVE_profileHandler, "reset"] call ALIVE_fnc_profileHandler;
    {
        private _alias = _x;
        private _profile = [["B_Soldier_F"], "WEST", "BLU_F", [1810, 5620, 0], 0, "", false,
            "PA_orders_" + _alias, false, "PRIVATE", [[1810, 5620, 0]]] call ALIVE_fnc_createProfileEntity;
        private _id = [_profile, "profileID"] call ALIVE_fnc_hashGet;
        _fixtures pushBack [_alias, _id];
        if (_alias == "mounted") then {
            private _vehicle = ["B_Quadbike_01_F", "WEST", "BLU_F", [1810, 5620, 0], 0, false,
                "PA_orders_vehicle"] call ALIVE_fnc_createProfileVehicle;
            [_profile, _vehicle] call ALIVE_fnc_createProfileVehicleAssignment;
        };
        [_profile, "addWaypointInternal", [_control, 0, "MOVE", "NORMAL", 5] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
        if (_alias != "legacy") then {
            {
                _x params ["_method", "_position", "_type"];
                private _waypoint = [_position, 2, _type, "FULL", 7, [2, 3, 4]] call ALIVE_fnc_createProfileWaypoint;
                [_waypoint, "statements", ["true", "PA_stale_order_callback = true;"]] call ALIVE_fnc_hashSet;
                [_profile, _method, _waypoint] call ALIVE_fnc_profileEntity;
            } forEach [["addWaypoint", _appendA, "MOVE"], ["addWaypoint", _appendB, "CYCLE"], ["insertWaypoint", _front, "SAD"]];
            private _ambientWP = [_ambient, 0, "MOVE"] call ALIVE_fnc_createProfileWaypoint;
            [_ambientWP, "statements", ["true", "_disableSimulation = true;"]] call ALIVE_fnc_hashSet;
            [_profile, "addWaypoint", _ambientWP] call ALIVE_fnc_profileEntity;
            private _cancelledWP = [_cancelled, 0, "MOVE"] call ALIVE_fnc_createProfileWaypoint;
            private _cancelledEntry = [_profile, "addPendingWaypoint", ["addWaypoint", _cancelledWP]] call ALIVE_fnc_profileEntity;
            _cancelledEntry set [1, "cancelled"];
            private _pending = [_profile, "pendingWaypointPaths"] call ALIVE_fnc_hashGet;
            ["Orders / " + _alias + ": real requests pending at save time", count _pending == 5,
                5, count _pending] call PA_fnc_assert;
            _legacyRaw pushBack [_id, +_pending];
        };
    } forEach ["foot", "mounted", "legacy"];
    ALIVE_saveProfilesPersistent = true;
    [true] call ALIVE_fnc_profilesSaveData;
    _saved = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", PA_missionKey, false]] call ALIVE_fnc_Data;
    {
        _x params ["_alias", "_id"];
        if (_alias != "legacy") then {
            private _record = [_saved, _id] call ALIVE_fnc_hashGet;
            private _orders = [_record, "pendingWaypointOrders", []] call ALIVE_fnc_hashGet;
            ["Orders / " + _alias + ": durable methods and destinations saved",
                (_orders apply {[_x select 0, [_x select 1, "position"] call ALIVE_fnc_hashGet]}) isEqualTo
                    [["addWaypoint", _appendA], ["addWaypoint", _appendB], ["insertWaypoint", _front]],
                "append A, append B, insert front", _orders apply {_x select 0}] call PA_fnc_assert;
            ["Orders / " + _alias + ": runtime queue omitted", !("pendingWaypointPaths" in (_record select 1)), false,
                "pendingWaypointPaths" in (_record select 1)] call PA_fnc_assert;
            private _liveProfile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
            private _livePending = [_liveProfile, "pendingWaypointPaths"] call ALIVE_fnc_hashGet;
            private _liveWaypoint = (_livePending select 0) select 3;
            ["Orders / " + _alias + ": callbacks removed and live orders unchanged",
                (_orders findIf {([_x select 1, "statements"] call ALIVE_fnc_hashGet) != ""}) == -1
                    && {([_liveWaypoint, "type"] call ALIVE_fnc_hashGet) == "MOVE"}
                    && {([_liveWaypoint, "statements"] call ALIVE_fnc_hashGet) isEqualTo ["true", "PA_stale_order_callback = true;"]},
                "empty saved callbacks; original waypoint type retained", _orders apply {[_x select 1, "statements"] call ALIVE_fnc_hashGet}] call PA_fnc_assert;
        };
    } forEach _fixtures;
}, []] call CBA_fnc_directCall;
private _legacyKey = format ["ALiVE_%1_%2", missionName, worldName];
private _legacyExisted = !isNil {profileNamespace getVariable _legacyKey};
private _legacyOriginal = profileNamespace getVariable [_legacyKey, false];
{
    _x params ["_case", "_loader", "_format", "_vehiclesFirst", "_enabled"];
    private _payload = +_saved;
    {
        _x params ["_alias", "_id"];
        private _record = [_payload, _id] call ALIVE_fnc_hashGet;
        if (_alias == "legacy") then {
            {[_record, _x] call ALIVE_fnc_hashRem} forEach ["pendingWaypointOrders", "pendingWaypointPaths"];
        } else {
            if (_format == "legacy") then {
                private _raw = +((_legacyRaw select (_legacyRaw findIf {(_x select 0) == _id})) select 1);
                // A ready entry behind an unfinished one still needs a fresh job.
                (_raw select 1) set [0, true];
                (_raw select 1) set [2, [[9999, 9999, 0]]];
                [_record, "pendingWaypointOrders"] call ALIVE_fnc_hashRem;
                [_record, "pendingWaypointPaths", _raw] call ALIVE_fnc_hashSet;
            };
            if (_format == "strings") then {
                {
                    private _wp = _x select 1;
                    [_wp, "position", ([_wp, "position"] call ALIVE_fnc_hashGet) apply {str _x}] call ALIVE_fnc_hashSet;
                    [_wp, "timeout", ["2", "3", "4"]] call ALIVE_fnc_hashSet;
                    [_wp, "radius", "2"] call ALIVE_fnc_hashSet;
                    [_wp, "completionRadius", "7"] call ALIVE_fnc_hashSet;
                } forEach ([_record, "pendingWaypointOrders"] call ALIVE_fnc_hashGet);
            };
        };
    } forEach _fixtures;
    private _ordered = [] call ALIVE_fnc_hashCreate;
    {
        private _type = _x;
        {if (([_x, "type"] call ALIVE_fnc_hashGet) == _type) then {[_ordered, (_payload select 1) select _forEachIndex, _x] call ALIVE_fnc_hashSet}}
            forEach (_payload select 2);
    } forEach ([ [1, 2], [2, 1] ] select _vehiclesFirst);
    [{
        [ALIVE_profileSystem, "pathfinding", _enabled] call ALIVE_fnc_profileSystem;
        [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _ordered, PA_missionKey, false]] call ALIVE_fnc_Data;
        private _legacyStore = [] call ALIVE_fnc_hashCreate;
        [_legacyStore, "ALiVE_SYS_PROFILE", _ordered] call ALIVE_fnc_hashSet;
        profileNamespace setVariable [_legacyKey, _legacyStore];
        ALIVE_loadProfilesPersistent = true;
        ALiVE_sysProfileLastLoadTime = nil;
        call _loader;
        {
            _x params ["_alias", "_id"];
            private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
            private _label = "Orders / " + _case + " / " + _alias;
            [_label + ": profile restored", !isNil "_profile", _id,
                if (isNil "_profile") then {"missing"} else {_id}] call PA_fnc_assert;
            if (!isNil "_profile") then {
                private _pending = [_profile, "pendingWaypointPaths"] call ALIVE_fnc_hashGet;
                private _expectedCount = [0, 3] select (_enabled && {_alias != "legacy"});
                [_label + ": fresh queue size", count _pending == _expectedCount, _expectedCount, count _pending] call PA_fnc_assert;
                private _jobs = (ALIVE_Pathfinder get "pathJobs") select {(_x select 4 select 0) == _id};
                [_label + ": fresh job count", count _jobs == _expectedCount, _expectedCount, count _jobs] call PA_fnc_assert;
                if (_expectedCount > 0) then {
                    [_label + ": methods and destinations restored", (_pending apply {[_x select 1, [_x select 3, "position"] call ALIVE_fnc_hashGet]}) isEqualTo
                        [["addWaypoint", _appendA], ["addWaypoint", _appendB], ["insertWaypoint", _front]],
                        "append A, append B, insert front", _pending apply {_x select 1}] call PA_fnc_assert;
                    private _procedure = ["Man", "LandRoad"] select (_alias == "mounted");
                    [_label + ": correct movement procedure", (_jobs findIf {(_x select 1 select 0) != _procedure}) == -1,
                        _procedure, _jobs apply {_x select 1 select 0}] call PA_fnc_assert;
                    [_label + ": readiness and waypoint settings restored",
                        (_pending apply {[_x select 3, "type"] call ALIVE_fnc_hashGet}) isEqualTo ["MOVE", "CYCLE", "SAD"]
                        && {(_pending findIf {(_x select 0)
                        || {([_x select 3, "radius"] call ALIVE_fnc_hashGet) != 2}
                        || {([_x select 3, "timeout"] call ALIVE_fnc_hashGet) isNotEqualTo [2, 3, 4]}
                        || {([_x select 3, "completionRadius"] call ALIVE_fnc_hashGet) != 7}}) == -1},
                        "not ready; numeric timeout and completion radius", _pending apply {_x select 0}] call PA_fnc_assert;
                };
            };
        } forEach _fixtures;
    }, []] call CBA_fnc_directCall;
    private _deadline = diag_tickTime + 30;
    waitUntil {
        sleep 0.05;
        (_fixtures findIf {
            private _profile = [ALIVE_profileHandler, "getProfile", _x select 1] call ALIVE_fnc_profileHandler;
            count ([_profile, "pendingWaypointPaths", []] call ALIVE_fnc_hashGet) > 0
        }) == -1 || {diag_tickTime > _deadline}
    };
    {
        _x params ["_alias", "_id"];
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        private _label = "Orders / " + _case + " / " + _alias;
        private _waypoints = [_profile, "waypoints"] call ALIVE_fnc_hashGet;
        private _positions = _waypoints apply {[_x, "position"] call ALIVE_fnc_hashGet};
        private _expected = [[_control], [_front, _control, _appendA, _appendB]] select (_alias != "legacy");
        [_label + ": queue drained", count ([_profile, "pendingWaypointPaths"] call ALIVE_fnc_hashGet) == 0,
            0, count ([_profile, "pendingWaypointPaths"] call ALIVE_fnc_hashGet)] call PA_fnc_assert;
        [_label + ": applied order sequence", (_positions select {_x in _expected}) isEqualTo _expected,
            _expected, _positions select {_x in _expected}] call PA_fnc_assert;
        private _expectedCycle = _alias != "legacy";
        [_label + ": cycle state preserved", ([_profile, "isCycling"] call ALIVE_fnc_hashGet) isEqualTo _expectedCycle,
            _expectedCycle, [_profile, "isCycling"] call ALIVE_fnc_hashGet] call PA_fnc_assert;
        [_label + ": filtered orders absent", !(_ambient in _positions) && {!(_cancelled in _positions)},
            "no ambient or cancelled destinations", _positions] call PA_fnc_assert;
        [_label + ": obsolete callbacks absent", isNil "PA_stale_order_callback", "undefined", missionNamespace getVariable ["PA_stale_order_callback", "undefined"]] call PA_fnc_assert;
    } forEach _fixtures;
} forEach [
    ["normal entities first", ALIVE_fnc_profilesLoadData, "new", false, true],
    ["normal vehicles first", ALIVE_fnc_profilesLoadData, "new", true, true],
    ["legacy loader", ALIVE_fnc_profilesLoadDataPNS, "new", false, true],
    ["legacy raw queue", ALIVE_fnc_profilesLoadData, "legacy", false, true],
    ["numeric strings", ALIVE_fnc_profilesLoadData, "strings", false, true],
    ["pathfinding disabled", ALIVE_fnc_profilesLoadData, "new", false, false]
];
[ALIVE_profileSystem, "pathfinding", _pathfindingWasEnabled] call ALIVE_fnc_profileSystem;
if (_legacyExisted) then {profileNamespace setVariable [_legacyKey, _legacyOriginal]} else {profileNamespace setVariable [_legacyKey, nil]};
