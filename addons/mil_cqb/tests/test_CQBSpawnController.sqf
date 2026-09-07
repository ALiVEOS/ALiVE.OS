#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(test_CQBSpawnController);

// Run on the server in an ALiVE test mission:
// execVM "\x\alive\addons\mil_cqb\tests\test_CQBSpawnController.sqf";
if (!isServer) exitWith {};

private _fixtures = [];
private _makeObject = {
    params ["_class", "_position"];
    private _object = createVehicleLocal [_class, _position, [], 0, "CAN_COLLIDE"];
    _object enableSimulation false;
    _object setPosATL _position;
    _fixtures pushBack _object;
    _object
};
private _base = [worldSize / 2, worldSize / 2, 0];
private _sourceA = ["Land_HelipadEmpty_F", _base] call _makeObject;
private _sourceB = ["Land_HelipadEmpty_F", _base vectorAdd [500,0,0]] call _makeObject;
private _houseA = ["Land_HelipadEmpty_F", _base vectorAdd [50,0,0]] call _makeObject;
private _houseB = ["Land_HelipadEmpty_F", _base vectorAdd [550,0,0]] call _makeObject;
private _outer = ["Land_HelipadEmpty_F", _base vectorAdd [110,0,0]] call _makeObject;
private _static = ["Land_HelipadEmpty_F", _base vectorAdd [150,0,0]] call _makeObject;
_static setVariable ["staticWeapons", []];
private _logic = ["Land_HelipadEmpty_F", [0,0,0]] call _makeObject;
private _registry = createHashMap;
{
    _registry set [hashValue _x, [_x, true, "idle"]];
} forEach [_houseA,_houseB,_outer,_static];
_logic setVariable ["houses", _registry];
_logic setVariable ["spawnDistance", 100];
_logic setVariable ["spawnDistanceStatic", 200];
_logic setVariable ["spawnDistanceHeli", 0];
_logic setVariable ["spawnDistanceJet", 0];
_logic setVariable ["GarbageCollecting", true];
_logic setVariable ["debug", false];
[_logic, "positionGrid"] call ALiVE_fnc_CQB;

private _failures = [];
private _check = {
    params ["_condition", "_message"];
    if (!_condition) then {_failures pushBack _message; diag_log format ["CQB controller FAIL: %1", _message]};
};
private _status = {
    params ["_house"];
    ((_logic getVariable "houses") get (hashValue _house)) select 2
};
private _makeGroup = {
    params ["_house"];
    private _group = createGroup west;
    private _unit = _group createUnit ["B_Soldier_F", getPosATL _house, [], 0, "NONE"];
    _unit enableSimulation false;
    _unit allowDamage false;
    _unit setVariable ["house", _house];
    _group setVariable ["house", _house];
    _house setVariable ["group", _group];
    [_group, _unit]
};

// Stub only the spawn step. This exercises the real claim and queue controller
// without depending on faction configuration or building positions.
{
    private _hadModule = !isNil QMOD(CQB);
    private _savedModule = missionNamespace getVariable [QMOD(CQB), objNull];
    private _hadSpawnStep = !isNil "ALiVE_fnc_CQBSpawnStep";
    private _savedSpawnStep = missionNamespace getVariable ["ALiVE_fnc_CQBSpawnStep", {}];
    private _hadPaused = !isNil "ALiVE_isGamePaused";
    private _savedPaused = missionNamespace getVariable ["ALiVE_isGamePaused", false];
    MOD(CQB) = _logic;
    ALiVE_isGamePaused = false;
    ALiVE_fnc_CQBSpawnStep = {
        params ["_logic", "_house", "_context"];
        _logic setVariable ["testSpawnCalls", (_logic getVariable ["testSpawnCalls", 0]) + 1];
        _logic setVariable ["testSpawnCanSuspend", canSuspend];
        _logic setVariable ["testSpawnHouse", _house];
        _logic setVariable ["testSpawnContext", _context];
        _logic getVariable ["testSpawnResult", "running"]
    };
    _logic setVariable ["active", true];
    _logic setVariable ["claims", createHashMap];
    _logic setVariable ["spawnQueue", []];
    _logic setVariable ["despawnQueue", []];
    _logic setVariable ["spawnStage", "snapshot"];
    _logic setVariable ["claimCycle", 0];
    _logic setVariable ["testSpawnResult", "running"];
    _logic setVariable ["testSpawnCalls", 0];

    // A gated claim snapshot leaves claim state untouched while both lifecycle
    // queues continue to make their normal per-frame progress.
    private _gateGroup = createGroup west;
    private _gateUnit = _gateGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    _gateUnit setVariable ["house", _houseB];
    _gateGroup setVariable ["house", _houseB];
    _houseB setVariable ["group", _gateGroup];
    (_registry get (hashValue _houseA)) set [2, "queued"];
    (_registry get (hashValue _houseB)) set [2, "despawnQueued"];
    private _gatedClaims = createHashMapFromArray [
        [hashValue _houseA, [_houseA, 4]],
        [hashValue _houseB, [_houseB, 3]]
    ];
    _logic setVariable ["claims", _gatedClaims];
    _logic setVariable ["claimCycle", 4];
    _logic setVariable ["spawnSources", [_sourceB]];
    _logic setVariable ["spawnQueue", [_houseA]];
    _logic setVariable ["despawnQueue", [_houseB]];
    _logic setVariable ["nextClaimCycleAt", diag_tickTime + 60];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnStage") == "snapshot" && {(_logic getVariable "claimCycle") == 4}, "gated snapshot does not advance claim cycle"] call _check;
    [(_logic getVariable "spawnSources") isEqualTo [_sourceB] && {(hashValue _houseB) in _gatedClaims}, "gated snapshot preserves sources and stale claims"] call _check;
    [isNull _gateUnit && {(_logic getVariable "despawnQueue") isEqualTo []}, "gated snapshot still processes despawn queue"] call _check;
    [(_logic getVariable "testSpawnCalls") == 1 && {typeName (_logic getVariable "spawnContext") == "HASHMAP"}, "gated snapshot still advances spawn queue"] call _check;

    // Move the gate behind the current diagnostic clock to accept immediately.
    _logic setVariable ["spawnContext", nil];
    _logic setVariable ["spawnQueue", []];
    _logic setVariable ["claims", createHashMap];
    (_registry get (hashValue _houseA)) set [2, "idle"];
    private _acceptedAt = diag_tickTime;
    _logic setVariable ["nextClaimCycleAt", _acceptedAt - 1];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(_logic getVariable "claimCycle") == 5 && {(_logic getVariable "spawnStage") == "sources"}, "expired gate accepts exactly one snapshot"] call _check;
    [(_logic getVariable "nextClaimCycleAt") >= _acceptedAt + 2, "accepted snapshot schedules next cycle two seconds later"] call _check;
    private _expectedSources = allPlayers - entities "HeadlessClient_F";
    if (!isNil "ALIVE_profileSystem" && {[ALIVE_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet}) then {
        {_expectedSources pushBackUnique _x} forEach allCurators;
    };
    private _snapshotSources = _logic getVariable "spawnSources";
    private _sourceCategory = {
        private _vehicle = vehicle _this;
        if (_vehicle isKindOf "Plane") exitWith {"plane"};
        if (_vehicle isKindOf "Helicopter") exitWith {"helicopter"};
        "ground"
    };
    private _subsequence = true;
    private _candidateCursor = 0;
    {
        private _offset = (_expectedSources select [_candidateCursor]) find _x;
        if (_offset < 0) exitWith {_subsequence = false};
        _candidateCursor = _candidateCursor + _offset + 1;
    } forEach _snapshotSources;
    [_subsequence, "snapshot keeps candidate order"] call _check;
    [{
        private _source = _x;
        private _category = _source call _sourceCategory;
        (_snapshotSources findIf {
            _x isNotEqualTo _source &&
            {(_x call _sourceCategory) == _category} &&
            {(getPosATL _x) distance (getPosATL _source) <= 30}
        }) >= 0
    } count _snapshotSources == 0, "snapshot has no redundant same-category pair"] call _check;
    {
        private _dropped = _x;
        private _droppedIndex = _expectedSources find _dropped;
        private _category = _dropped call _sourceCategory;
        [(_snapshotSources findIf {
            (_expectedSources find _x) < _droppedIndex &&
            {(_x call _sourceCategory) == _category} &&
            {(getPosATL _x) distance (getPosATL _dropped) <= 30}
        }) >= 0, "each dropped snapshot source is covered by an earlier kept source"] call _check;
    } forEach (_expectedSources - _snapshotSources);

    _logic setVariable ["spawnSources", [_sourceA,_sourceB]];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    private _claims = _logic getVariable "claims";
    [(_logic getVariable "spawnSourceIndex") == 1, "one source per frame"] call _check;
    [(hashValue _houseA) in _claims && {!((hashValue _houseB) in _claims)}, "first source only"] call _check;
    [(hashValue _static) in _claims, "static activation range"] call _check;
    [!((hashValue _outer) in _claims), "idle outer house is not retained"] call _check;
    private _firstHead = (_logic getVariable "spawnQueue") select 0;
    [[_firstHead] call _status == "spawning", "claimed queue head starts spawning"] call _check;
    [!(_logic getVariable ["testSpawnCanSuspend", true]), "spawn step runs unscheduled"] call _check;
    [((_logic getVariable "spawnQueue") select 0) isEqualTo _firstHead, "running spawn stays at queue head"] call _check;
    [typeName (_logic getVariable "spawnContext") == "HASHMAP", "running spawn retains one context"] call _check;
    private _queueCount = count (_logic getVariable "spawnQueue");
    [_logic, "claimHouses", _sourceA] call ALiVE_fnc_CQB;
    [count (_logic getVariable "spawnQueue") == _queueCount, "overlap does not duplicate jobs"] call _check;

    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(hashValue _houseB) in _claims, "claims union across sources"] call _check;
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnStage") == "groups", "sweep starts after all sources"] call _check;

    // Pending work uses retention range without overloading house.group.
    private _outerRecord = _registry get (hashValue _outer);
    _outerRecord set [2, "queued"];
    [_logic, "claimHouses", _sourceA] call ALiVE_fnc_CQB;
    [(hashValue _outer) in _claims, "queued house uses retention range"] call _check;
    [isNil {_outer getVariable "group"}, "queued house has no group sentinel"] call _check;
    _outerRecord set [2, "idle"];

    // Pausing preserves both claim and incremental spawn state.
    _logic setVariable ["pause", true];
    private _claimCount = count _claims;
    private _context = _logic getVariable "spawnContext";
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [count _claims == _claimCount, "pause preserves claims"] call _check;
    [(_logic getVariable "spawnStage") == "snapshot", "resume restarts source snapshot"] call _check;
    [(_logic getVariable "spawnContext") isEqualRef _context, "pause preserves spawn progress"] call _check;
    _logic setVariable ["pause", false];
    {
        if ((_y param [2, "idle"]) in ["queued", "spawning"]) then {_y set [2, "idle"]};
    } forEach _registry;

    // Invalid heads are consumed without running a step. A house already being
    // spawned by another CQB instance remains queued and is not double-started.
    _logic setVariable ["spawnContext", nil];
    _logic setVariable ["spawnQueue", [objNull, _static]];
    private _calls = _logic getVariable "testSpawnCalls";
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_static], "invalid head is discarded alone"] call _check;
    [(_logic getVariable "testSpawnCalls") == _calls, "invalid head never invokes spawn step"] call _check;
    private _otherLogic = ["Land_HelipadEmpty_F", [0,0,0]] call _makeObject;
    _otherLogic setVariable ["spawnQueue", [_houseA]];
    _otherLogic setVariable ["spawnContext", createHashMapFromArray [["phase", "units"]]];
    MOD(CQB) setVariable ["instances", [_logic, _otherLogic]];
    _houseA setVariable ["ALIVE_CQB_nextDetect", 0];
    private _houseARecord = _registry get (hashValue _houseA);
    _houseARecord set [2, "queued"];
    _logic setVariable ["claims", createHashMapFromArray [[hashValue _houseA, [_houseA, 1]]]];
    _logic setVariable ["spawnQueue", [_houseA]];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_houseA], "other-instance spawn leaves head queued"] call _check;
    [isNil {_logic getVariable "spawnContext"}, "other-instance spawn creates no local context"] call _check;
    [(_logic getVariable "testSpawnCalls") == _calls, "other-instance spawn never invokes spawn step"] call _check;
    MOD(CQB) setVariable ["instances", [_logic]];

    // Completion consumes this frame and does not begin the next queue entry.
    private _houseBRecord = _registry get (hashValue _houseB);
    ([_houseB] call _makeGroup) params ["_groupB", "_unitB"];
    _logic setVariable ["groups", [_groupB]];
    _logic setVariable ["spawnQueue", [_houseB, _static]];
    private _successStatic = ["Land_HelipadEmpty_F", _base vectorAdd [551,0,0]] call _makeObject;
    _houseB setVariable ["staticWeapons", [_successStatic]];
    _logic setVariable ["spawnContext", createHashMapFromArray [["phase", "activate"], ["createdStatics", [_successStatic]]]];
    _houseBRecord set [2, "spawning"];
    _logic setVariable ["testSpawnResult", "complete"];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_static], "completed head is removed alone"] call _check;
    [isNil {_logic getVariable "spawnContext"}, "completion releases spawn context"] call _check;
    [[_houseB] call _status == "active", "completion activates the house"] call _check;
    [[_static] call _status != "spawning", "completion defers next job to another frame"] call _check;
    [alive _successStatic && {(_houseB getVariable ["staticWeapons", []]) isEqualTo [_successStatic]}, "successful spawn preserves context-created statics"] call _check;

    // Failure deletes only statics owned by this attempt, preserving older ones.
    private _partial = createGroup west;
    _partial setVariable ["house", _houseA];
    _houseA setVariable ["group", _partial];
    private _existingStatic = ["Land_HelipadEmpty_F", _base vectorAdd [51,1,0]] call _makeObject;
    private _failedStatic = ["Land_HelipadEmpty_F", _base vectorAdd [51,2,0]] call _makeObject;
    _houseA setVariable ["staticWeapons", [_existingStatic, _failedStatic]];
    _logic setVariable ["spawnQueue", [_houseA, _static]];
    _logic setVariable ["spawnContext", createHashMapFromArray [["phase", "units"], ["group", _partial], ["createdStatics", [_failedStatic]]]];
    _houseARecord set [2, "spawning"];
    _logic setVariable ["testSpawnResult", "failed"];
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnQueue") isEqualTo [_static], "failed head is removed alone"] call _check;
    [isNull _partial && {isNil {_houseA getVariable "group"}}, "failed spawn deletes partial group"] call _check;
    [[_houseA] call _status == "idle", "failed spawn returns house to idle"] call _check;
    [(_houseA getVariable ["ALIVE_CQB_nextDetect", 0]) > time, "failed spawn backs off"] call _check;
    [isNull _failedStatic && {alive _existingStatic}, "failed spawn deletes only newly created statics"] call _check;
    [(_houseA getVariable ["staticWeapons", []]) isEqualTo [_existingStatic], "failed spawn removes deleted static references"] call _check;

    // Mid-spawn work rotates so a valid despawn behind it can drain next frame.
    _houseARecord set [2, "spawning"];
    _houseBRecord set [2, "despawnQueued"];
    (_logic getVariable "claims") set [hashValue _houseB, [_houseB, 1]];
    _logic setVariable ["spawnQueue", [_houseA]];
    _logic setVariable ["spawnContext", createHashMapFromArray [["phase", "units"]]];
    _logic setVariable ["despawnQueue", [_houseA, _houseB]];
    [_logic, "processDespawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseB, _houseA], "spawning house rotates behind later despawns"] call _check;
    [[_houseA] call _status == "spawning", "rotation preserves spawning lifecycle"] call _check;
    [isNil {_houseA getVariable "group"}, "pre-group spawn rotates safely"] call _check;
    [_logic, "processDespawnQueue"] call ALiVE_fnc_CQB;
    [isNull _unitB, "despawn does not recheck a reclaimed house"] call _check;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseA], "despawn consumes one valid entry"] call _check;
    [[_houseB] call _status == "idle", "distance despawn returns house to idle"] call _check;

    private _partialSpawn = createGroup west;
    _partialSpawn setVariable ["house", _houseA];
    _houseA setVariable ["group", _partialSpawn];
    _logic setVariable ["despawnQueue", [_houseA]];
    [_logic, "processDespawnQueue"] call ALiVE_fnc_CQB;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseA] && {!isNull _partialSpawn}, "post-group spawn rotates without deleting partial group"] call _check;

    // Claim expiration queues mid-spawn work, then the queue processor rotates it.
    _logic setVariable ["testSpawnResult", "running"];
    _logic setVariable ["claims", createHashMapFromArray [[hashValue _houseA, [_houseA, 1]]]];
    _logic setVariable ["despawnQueue", []];
    _logic setVariable ["spawnStage", "sources"];
    _logic setVariable ["spawnSources", []];
    _logic setVariable ["spawnSourceIndex", 0];
    _logic setVariable ["claimCycle", 2];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [count (_logic getVariable "claims") == 0, "empty cycle expires claims"] call _check;
    [(_logic getVariable "despawnQueue") isEqualTo [_houseA], "claim loss retains pending despawn for spawning house"] call _check;
    [[_houseA] call _status == "spawning", "claim loss does not cancel spawn"] call _check;

    // Garbage collection off consumes stale work while keeping the live group.
    ([_houseB] call _makeGroup) params ["_groupC", "_unitC"];
    _logic setVariable ["groups", [_groupC]];
    _houseBRecord set [2, "despawnQueued"];
    _logic setVariable ["GarbageCollecting", false];
    _logic setVariable ["despawnQueue", [_houseB]];
    [_logic, "processDespawnQueue"] call ALiVE_fnc_CQB;
    [alive _unitC && {(_logic getVariable "despawnQueue") isEqualTo []}, "GC disabled consumes despawn without deletion"] call _check;
    [[_houseB] call _status == "active", "GC disabled restores active lifecycle"] call _check;
    _logic setVariable ["GarbageCollecting", true];

    // Group metadata initialization repairs only missing ownership, installs one
    // handler pair, and the groups setter removes that pair with the group.
    private _metadataGroup = createGroup west;
    private _metadataLeader = _metadataGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    private _metadataMissing = _metadataGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    private _metadataOwned = _metadataGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    _metadataLeader setVariable ["house", _houseB];
    _metadataOwned setVariable ["house", _outer];
    [_logic, "groups", [_metadataGroup]] call ALiVE_fnc_CQB;
    [(_metadataGroup getVariable ["house", objNull]) isEqualTo _houseB && {_metadataGroup getVariable ["ALIVE_profileIgnore", false]}, "groups setter initializes group metadata from leader"] call _check;
    [(_metadataMissing getVariable ["house", objNull]) isEqualTo _houseB && {_metadataMissing getVariable ["ALIVE_profileIgnore", false]}, "initializer repairs missing unit metadata"] call _check;
    [(_metadataOwned getVariable ["house", objNull]) isEqualTo _outer, "initializer preserves existing unit house"] call _check;
    private _metadataHandlers = +(_metadataGroup getVariable ["ALIVE_CQB_metadataEventHandlers", []]);
    [_logic, "initializeGroupMetadata", [_metadataGroup, _houseB]] call ALiVE_fnc_CQB;
    [count _metadataHandlers == 2 && {(_metadataGroup getVariable ["ALIVE_CQB_metadataEventHandlers", []]) isEqualTo _metadataHandlers}, "metadata handler installation is idempotent"] call _check;
    private _joinedUnit = _metadataGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    [(_joinedUnit getVariable ["house", objNull]) isEqualTo _houseB && {_joinedUnit getVariable ["ALIVE_profileIgnore", false]}, "UnitJoined handler repairs new unit metadata"] call _check;
    [_logic, "groups", []] call ALiVE_fnc_CQB;
    [isNil {_metadataGroup getVariable "ALIVE_CQB_metadataEventHandlers"}, "groups setter removal cleans metadata handlers"] call _check;
    private _afterRemoval = _metadataGroup createUnit ["B_Soldier_F", getPosATL _houseB, [], 0, "NONE"];
    [isNil {_afterRemoval getVariable "house"}, "removed group no longer handles joined units"] call _check;

    // A lazy sweep repairs a missing marker or mismatched group house. Empty
    // queues must not dispatch either queue processor during that frame.
    private _lazyGroup = createGroup west;
    private _lazyLeader = _lazyGroup createUnit ["B_Soldier_F", getPosATL _houseA, [], 0, "NONE"];
    private _lazyMissing = _lazyGroup createUnit ["B_Soldier_F", getPosATL _houseA, [], 0, "NONE"];
    _lazyLeader setVariable ["house", _houseA];
    _lazyGroup setVariable ["house", _outer];
    _logic setVariable ["groups", [_lazyGroup]];
    _logic setVariable ["checkedGroups", [_lazyGroup]];
    _logic setVariable ["checkedGroupIndex", 0];
    _logic setVariable ["spawnStage", "groups"];
    _logic setVariable ["claims", createHashMapFromArray [[hashValue _houseA, [_houseA, 2]]]];
    _logic setVariable ["spawnQueue", []];
    _logic setVariable ["despawnQueue", []];
    private _savedCQB = ALiVE_fnc_CQB;
    private _hadTestOriginal = !isNil "ALIVE_test_CQBOriginal";
    private _priorTestOriginal = missionNamespace getVariable ["ALIVE_test_CQBOriginal", {}];
    private _hadTestLogic = !isNil "ALIVE_test_CQBLogic";
    private _priorTestLogic = missionNamespace getVariable ["ALIVE_test_CQBLogic", objNull];
    missionNamespace setVariable ["ALIVE_test_CQBOriginal", _savedCQB];
    missionNamespace setVariable ["ALIVE_test_CQBLogic", _logic];
    _logic setVariable ["testSpawnQueueDispatches", 0];
    _logic setVariable ["testDespawnQueueDispatches", 0];
    ALiVE_fnc_CQB = {
        params ["_logic", "_operation", ["_args", nil]];
        private _testLogic = missionNamespace getVariable ["ALIVE_test_CQBLogic", objNull];
        if (_logic isEqualTo _testLogic) then {
            if (_operation == "processSpawnQueue") then {_logic setVariable ["testSpawnQueueDispatches", (_logic getVariable "testSpawnQueueDispatches") + 1]};
            if (_operation == "processDespawnQueue") then {_logic setVariable ["testDespawnQueueDispatches", (_logic getVariable "testDespawnQueueDispatches") + 1]};
        };
        private _original = missionNamespace getVariable "ALIVE_test_CQBOriginal";
        if (isNil "_args") then {[_logic, _operation] call _original} else {[_logic, _operation, _args] call _original}
    };
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    ALiVE_fnc_CQB = _savedCQB;
    if (_hadTestOriginal) then {missionNamespace setVariable ["ALIVE_test_CQBOriginal", _priorTestOriginal]} else {missionNamespace setVariable ["ALIVE_test_CQBOriginal", nil]};
    if (_hadTestLogic) then {missionNamespace setVariable ["ALIVE_test_CQBLogic", _priorTestLogic]} else {missionNamespace setVariable ["ALIVE_test_CQBLogic", nil]};
    [(_lazyGroup getVariable ["house", objNull]) isEqualTo _houseA && {(_lazyMissing getVariable ["house", objNull]) isEqualTo _houseA}, "lazy sweep repairs mismatched group metadata"] call _check;
    [count (_lazyGroup getVariable ["ALIVE_CQB_metadataEventHandlers", []]) == 2, "lazy sweep installs metadata handlers"] call _check;
    [(_logic getVariable "testSpawnQueueDispatches") == 0 && {(_logic getVariable "testDespawnQueueDispatches") == 0}, "empty queues skip processor dispatch"] call _check;
    [_logic, "groups", []] call ALiVE_fnc_CQB;

    // A tracked local group with no house metadata remains an orphan and is
    // deleted by the regular group sweep.
    private _orphanGroup = createGroup west;
    private _orphanUnit = _orphanGroup createUnit ["B_Soldier_F", getPosATL _houseA, [], 0, "NONE"];
    _logic setVariable ["groups", [_orphanGroup]];
    _logic setVariable ["checkedGroups", [_orphanGroup]];
    _logic setVariable ["checkedGroupIndex", 0];
    _logic setVariable ["spawnStage", "groups"];
    [_logic, "onFrame"] call ALiVE_fnc_CQB;
    [isNull _orphanUnit && {isNull _orphanGroup}, "group sweep deletes orphan group"] call _check;
    {deleteVehicle _x} forEach units _metadataGroup;
    deleteGroup _metadataGroup;
    {deleteVehicle _x} forEach units _lazyGroup;
    deleteGroup _lazyGroup;

    // The context owns the partial group handle even after the house object is
    // deleted and its object variable space can no longer be consulted.
    private _deletedHouse = ["Land_HelipadEmpty_F", _base vectorAdd [700,0,0]] call _makeObject;
    private _deletedID = hashValue _deletedHouse;
    private _deletedGroup = createGroup west;
    _deletedGroup setVariable ["house", _deletedHouse];
    private _deletedStatic = ["Land_HelipadEmpty_F", _base vectorAdd [701,0,0]] call _makeObject;
    _registry set [_deletedID, [_deletedHouse, true, "spawning"]];
    _logic setVariable ["spawnQueue", [_deletedHouse]];
    _logic setVariable ["spawnContext", createHashMapFromArray [["phase", "units"], ["group", _deletedGroup], ["createdStatics", [_deletedStatic]]]];
    deleteVehicle _deletedHouse;
    [_logic, "processSpawnQueue"] call ALiVE_fnc_CQB;
    [isNull _deletedGroup, "deleted spawning house still cleans context-owned group"] call _check;
    [isNull _deletedStatic, "deleted spawning house still cleans context-owned static"] call _check;
    [isNil {_logic getVariable "spawnContext"} && {(_logic getVariable "spawnQueue") isEqualTo []}, "deleted spawning house releases queue state"] call _check;
    _registry deleteAt _deletedID;

    // Shutdown cleans the partial group and all local queue coordination state.
    private _shutdownGroup = _partialSpawn;
    private _shutdownStatic = ["Land_HelipadEmpty_F", _base vectorAdd [52,0,0]] call _makeObject;
    _houseA setVariable ["staticWeapons", [_existingStatic, _shutdownStatic]];
    _houseARecord set [2, "spawning"];
    _logic setVariable ["spawnQueue", [_houseA, _static]];
    _logic setVariable ["spawnContext", createHashMapFromArray [["phase", "units"], ["group", _shutdownGroup], ["createdStatics", [_shutdownStatic]]]];
    _logic setVariable ["despawnQueue", [_houseB]];
    [_logic, "active", false] call ALiVE_fnc_CQB;
    [isNull _shutdownGroup, "shutdown deletes partial spawn"] call _check;
    [isNil {_logic getVariable "spawnContext"}, "shutdown clears spawn context"] call _check;
    [(_logic getVariable ["spawnQueue", []]) isEqualTo [], "shutdown clears spawn queue"] call _check;
    [(_logic getVariable ["despawnQueue", []]) isEqualTo [], "shutdown clears despawn queue"] call _check;
    [isNull _shutdownStatic && {alive _existingStatic}, "shutdown deletes only current-spawn statics"] call _check;
    [(_houseA getVariable ["staticWeapons", []]) isEqualTo [_existingStatic], "shutdown removes deleted static references"] call _check;
    if (!isNull _groupC) then {[_logic, "delGroup", _groupC] call ALiVE_fnc_CQB};
    deleteVehicle _existingStatic;
    deleteVehicle _successStatic;

    if (_hadSpawnStep) then {ALiVE_fnc_CQBSpawnStep = _savedSpawnStep} else {missionNamespace setVariable ["ALiVE_fnc_CQBSpawnStep", nil]};
    [_logic, "active", true] call ALiVE_fnc_CQB;
    [(_logic getVariable ["nextClaimCycleAt", -1]) == 0, "activation allows its first claim snapshot immediately"] call _check;
    private _handle = _logic getVariable "spawnPFH";
    [_logic, "active", true] call ALiVE_fnc_CQB;
    [(_logic getVariable "spawnPFH") == _handle, "activation is idempotent"] call _check;
    [_logic, "active", false] call ALiVE_fnc_CQB;
    [isNil {_logic getVariable "spawnPFH"}, "shutdown removes PFH"] call _check;
    if (_hadPaused) then {ALiVE_isGamePaused = _savedPaused} else {missionNamespace setVariable ["ALiVE_isGamePaused", nil]};
    if (_hadModule) then {MOD(CQB) = _savedModule} else {missionNamespace setVariable [QMOD(CQB), nil]};
} call CBA_fnc_DirectCall;

{deleteVehicle _x} forEach _fixtures;
diag_log format ["CQB controller tests complete: %1 failures", count _failures];
_failures
