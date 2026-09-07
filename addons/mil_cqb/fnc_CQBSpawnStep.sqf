#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(CQBSpawnStep);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_CQBSpawnStep

Description:
Advances one small step of an unscheduled CQB house spawn. Engine and CBA
query commands used by individual steps remain indivisible.

Parameters:
Object - CQB module logic
Object - House at the head of the spawn queue
HashMap - Temporary progress for this spawn

Returns:
String - "running", "complete", or "failed"

Per-call batches:
Up to 256 profiles or groups within a 0.75 ms local scan budget, 64 config
classes, 16 class/position operations, 4 rooftop ray checks, and at most one
created unit or static weapon. Scans always process at least one entry.
---------------------------------------------------------------------------- */

params ["_logic", "_house", "_context"];

private _phase = _context getOrDefault ["phase", "faction"];
private _result = "running";
private _position = getPosATL _house;

PROFILE_SCOPE(CQBSPAWNSTEP, _phase)

switch (_phase) do {
    case "faction": {
        if (_logic getVariable ["CQB_UseDominantFaction", false]) then {
            private _range = _logic getVariable ["spawnDistance", 700];
            if (!isNil {_house getVariable "staticWeapons"}) then {
                _range = _range max (_logic getVariable ["spawnDistanceStatic", 1200]);
            };
            private _fallbackRadius = 250 max _range;
            private _profiles = [];
            private _usedProfileGrid = false;
            if (!isNil "ALiVE_profileSystem") then {
                private _grid = [ALiVE_profileSystem, "spacialGridProfiles"] call ALiVE_fnc_hashGet;
                if (!isNil "_grid") then {
                    _profiles = _grid call ["findInRange", [_position, _fallbackRadius, false, true, false]];
                    _usedProfileGrid = true;
                };
            };
            if (!_usedProfileGrid && {!isNil "ALIVE_profileHandler"}) then {
                private _allProfiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
                _profiles = +(_allProfiles select 2);
            };

            _context set ["dominantFallbackRadius", _fallbackRadius];
            _context set ["dominantProfiles", _profiles];
            _context set ["dominantGroups", +allGroups];
            _context set ["dominantCursor", 0];
            _context set ["dominantNearCounts", createHashMap];
            _context set ["dominantFarCounts", createHashMap];
            _context set ["dominantNearOrder", []];
            _context set ["dominantFarOrder", []];
            _context set ["phase", "factionProfiles"];
        } else {
            private _factions = _logic getVariable ["factions", ["OPF_F"]];
            if (_factions isEqualTo []) then {
                _result = "failed";
            } else {
                _context set ["faction", selectRandom _factions];
                _context set ["phase", "classes"];
            };
        };
    };

    case "factionProfiles": {
        private _profiles = _context get "dominantProfiles";
        private _cursor = _context get "dominantCursor";
        private _farRadius = _context get "dominantFallbackRadius";
        private _nearCounts = _context get "dominantNearCounts";
        private _farCounts = _context get "dominantFarCounts";
        private _nearOrder = _context get "dominantNearOrder";
        private _farOrder = _context get "dominantFarOrder";
        private _started = diag_tickTime;
        private _processed = 0;

        while {_cursor < count _profiles && {_processed < 256} && {_processed == 0 || {diag_tickTime - _started < 0.00075}}} do {
            private _profile = _profiles select _cursor;
            private _profilePosition = _profile select 2 select 2;
            private _distance = _profilePosition distance _position;
            if (((_profile select 2 select 5) == "entity") && {!(_profile select 2 select 1)} && {!(_profile select 2 select 30)} && {_distance < _farRadius}) then {
                private _faction = _profile select 2 select 29;
                if !(_faction in _farCounts) then {_farOrder pushBack _faction};
                _farCounts set [_faction, (_farCounts getOrDefault [_faction, 0]) + 1];
                if (_distance < 250) then {
                    if !(_faction in _nearCounts) then {_nearOrder pushBack _faction};
                    _nearCounts set [_faction, (_nearCounts getOrDefault [_faction, 0]) + 1];
                };
            };
            _cursor = _cursor + 1;
            _processed = _processed + 1;
        };

        _context set ["dominantCursor", _cursor];
        if (_cursor >= count _profiles) then {
            _context set ["dominantCursor", 0];
            _context set ["phase", "factionGroups"];
        };
    };

    case "factionGroups": {
        private _groups = _context get "dominantGroups";
        private _cursor = _context get "dominantCursor";
        private _farRadius = _context get "dominantFallbackRadius";
        private _nearCounts = _context get "dominantNearCounts";
        private _farCounts = _context get "dominantFarCounts";
        private _nearOrder = _context get "dominantNearOrder";
        private _farOrder = _context get "dominantFarOrder";
        private _started = diag_tickTime;
        private _processed = 0;

        while {_cursor < count _groups && {_processed < 256} && {_processed == 0 || {diag_tickTime - _started < 0.00075}}} do {
            private _group = _groups select _cursor;
            private _leader = leader _group;
            if (!isNull _leader) then {
                private _distance = _position distance getPosATL _leader;
                if (_distance < _farRadius && {{isPlayer _x} count units _group < 1}) then {
                    private _grounded = (units _group) select {
                        alive _x && {
                            isNull objectParent _x ||
                            {!((objectParent _x) isKindOf "Air")} ||
                            {(objectParent _x) isKindOf "ParachuteBase"}
                        }
                    };
                    if !(_grounded isEqualTo []) then {
                        private _faction = faction _leader;
                        if !(_faction in _farCounts) then {_farOrder pushBack _faction};
                        _farCounts set [_faction, (_farCounts getOrDefault [_faction, 0]) + 1];
                        if (_distance < 250) then {
                            if !(_faction in _nearCounts) then {_nearOrder pushBack _faction};
                            _nearCounts set [_faction, (_nearCounts getOrDefault [_faction, 0]) + 1];
                        };
                    };
                };
            };
            _cursor = _cursor + 1;
            _processed = _processed + 1;
        };

        _context set ["dominantCursor", _cursor];
        if (_cursor >= count _groups) then {
            _context set ["phase", "factionSelect"];
        };
    };

    case "factionSelect": {
        private _selectWinner = {
            params ["_counts", "_order"];
            private _winner = "";
            private _bestCount = 0;
            {
                private _count = _counts get _x;
                if (_count > _bestCount && {(_x call ALiVE_fnc_factionSide) != CIVILIAN}) then {
                    _winner = _x;
                    _bestCount = _count;
                };
            } forEach _order;
            _winner
        };
        private _bestFaction = [_context get "dominantNearCounts", _context get "dominantNearOrder"] call _selectWinner;
        if (_bestFaction == "") then {
            _bestFaction = [_context get "dominantFarCounts", _context get "dominantFarOrder"] call _selectWinner;
        };

        if (_bestFaction == "") then {
            _result = "failed";
        } else {
            _context set ["faction", _bestFaction];
            _context set ["phase", "classes"];
        };
    };

    case "classes": {
        private _faction = _context get "faction";
        private _units = _house getVariable ["unittypes", []];
        private _houseFaction = _house getVariable ["faction", ""];

        if (!(_units isEqualTo []) && {_houseFaction == _faction}) then {
            _context set ["unitClasses", +_units];
            _context set ["phase", "positions"];
        } else {
            private _blacklist = _logic getVariable ["UnitsBlackList", GVAR(UNITBLACKLIST)];
            private _cacheKey = str [_faction, _blacklist, ["winter", worldName] call BIS_fnc_inString];
            private _cache = _logic getVariable ["ALIVE_CQB_eligibleUnitCache", createHashMap];
            if (_cacheKey in _cache) then {
                private _eligible = _cache get _cacheKey;
                if (_eligible isEqualTo []) then {
                    _result = "failed";
                } else {
                    private _amount = if (GVAR(STRATEGICPLATFORMS) find typeOf _house != -1) then {1} else {ceil random (_logic getVariable ["amount", 2])};
                    private _selected = [];
                    for "_i" from 1 to _amount do {_selected pushBack selectRandom _eligible};
                    if (_selected isEqualTo []) then {
                        _result = "failed";
                    } else {
                        _house setVariable ["unittypes", _selected, true];
                        _house setVariable ["faction", _faction, true];
                        _context set ["unitClasses", _selected];
                        _context set ["phase", "positions"];
                    };
                };
            } else {
                private _sourceFaction = _faction;
                private _compiled = [];
                private _compiledSource = false;
                if (!isNil "ALiVE_fnc_factionCompilerIsCompiledFaction" && {!isNil "ALiVE_fnc_factionCompilerGetFactionData"} && {[_faction] call ALiVE_fnc_factionCompilerIsCompiledFaction}) then {
                    private _factionData = [_faction] call ALiVE_fnc_factionCompilerGetFactionData;
                    _compiled = ([_factionData, "unitClasses", []] call ALiVE_fnc_hashGet) + ([_factionData, "vehicleClasses", []] call ALiVE_fnc_hashGet);
                    _compiledSource = true;
                    if (!isNil "ALiVE_fnc_factionCompilerGetConfigFaction") then {
                        _sourceFaction = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
                    };
                };

                _context set ["classCandidates", +_compiled];
                _context set ["classFaction", _sourceFaction];
                _context set ["classCacheKey", _cacheKey];
                _context set ["compiledSource", _compiledSource];
                _context set ["baseEligibleCount", 0];
                if (_compiledSource) then {
                    _context set ["classCursor", 0];
                    _context set ["eligibleClasses", []];
                    _context set ["phase", "classFilter"];
                } else {
                    private _indexReady = !isNil "ALiVE_findVehicleTypeCachedFactions" && {ALiVE_findVehicleTypeCachedFactions getOrDefault [_sourceFaction, false]};
                    private _indexed = if (_indexReady && {!isNil "ALiVE_findVehicleTypeFactionIndex"}) then {ALiVE_findVehicleTypeFactionIndex getOrDefault [_sourceFaction, []]} else {[]};
                    if !(_indexed isEqualTo []) then {
                        _context set ["classCandidates", +_indexed];
                        _context set ["classCursor", 0];
                        _context set ["eligibleClasses", []];
                        _context set ["phase", "classFilter"];
                    } else {
                        _context set ["classCursor", 1];
                        _context set ["phase", "classConfigs"];
                    };
                };
            };
        };
    };

    case "classConfigs": {
        private _cfg = configFile >> "CfgVehicles";
        private _cursor = _context get "classCursor";
        private _end = (_cursor + 63) min (count _cfg - 1);
        private _faction = _context get "classFaction";
        private _candidates = _context get "classCandidates";

        for "_i" from _cursor to _end do {
            private _entry = _cfg select _i;
            if (isClass _entry && {getText (_entry >> "faction") == _faction}) then {
                private _class = configName _entry;
                if (!(getText (_entry >> "simulation") in ["parachute", "house"]) && {(["StaticWeapon", "CruiseMissile1", "CruiseMissile2", "Chukar_EP1", "Chukar", "Chukar_AllwaysEnemy_EP1"] findIf {_class isKindOf _x}) == -1}) then {
                    _candidates pushBackUnique _class;
                };
            };
        };

        _context set ["classCursor", _end + 1];
        if (_end >= count _cfg - 1) then {
            _context set ["phase", "classMission"];
        };
    };

    case "classMission": {
        private _faction = _context get "classFaction";
        if (isClass (missionConfigFile >> "CfgFactionClasses" >> _faction)) then {
            (_context get "classCandidates") append (_faction call ALiVE_fnc_configGetFactionUnitsByGroups);
        };
        _context set ["classCursor", 0];
        _context set ["eligibleClasses", []];
        _context set ["baseEligibleCount", 0];
        _context set ["phase", "classFilter"];
    };

    case "classFilter": {
        private _candidates = _context get "classCandidates";
        private _cursor = _context getOrDefault ["classCursor", 0];
        private _end = (_cursor + 16) min count _candidates;
        private _eligible = _context getOrDefault ["eligibleClasses", []];
        private _blacklist = _logic getVariable ["UnitsBlackList", GVAR(UNITBLACKLIST)];
        private _winter = ["winter", worldName] call BIS_fnc_inString;

        for "_i" from _cursor to (_end - 1) do {
            private _class = _candidates select _i;
            private _lower = toLower _class;
            private _gm = (_lower find "gm_") >= 0;
            private _baseEligible = isClass (configFile >> "CfgVehicles" >> _class) &&
                {getNumber (configFile >> "CfgVehicles" >> _class >> "scope") >= 1} &&
                {getNumber (configFile >> "CfgVehicles" >> _class >> "TransportSoldier") >= 0} &&
                {_class isKindOf "Man"} &&
                {[_class] call ALiVE_fnc_isArmed};
            if (_baseEligible) then {
                _context set ["baseEligibleCount", (_context getOrDefault ["baseEligibleCount", 0]) + 1];
            };
            private _excluded = _class in _blacklist ||
                {_gm && {_winter != ((_lower find "_win") >= 0)}} ||
                {_gm && {(_lower find "_sf_") >= 0 || {(_lower find "_blk") >= 0} || {(_lower find "_90_") >= 0}}} ||
                {(_lower find "crew") >= 0 || {(_lower find "pilot") >= 0} || {(_lower find "officer") >= 0} || {(_lower find "police") >= 0}};
            if (_baseEligible && {!_excluded}) then {
                _eligible pushBackUnique _class;
            };
        };

        _context set ["classCursor", _end];
        _context set ["eligibleClasses", _eligible];
        if (_end >= count _candidates) then {
            if ((_context getOrDefault ["compiledSource", false]) && {(_context getOrDefault ["baseEligibleCount", 0]) == 0}) then {
                _context set ["compiledSource", false];
                _context set ["classCandidates", []];
                _context set ["classCursor", 1];
                _context set ["eligibleClasses", []];
                _context set ["phase", "classConfigs"];
            } else {
                private _cache = _logic getVariable ["ALIVE_CQB_eligibleUnitCache", createHashMap];
                _cache set [_context get "classCacheKey", +_eligible];
                _logic setVariable ["ALIVE_CQB_eligibleUnitCache", _cache];
                if (_eligible isEqualTo []) then {
                    _result = "failed";
                } else {
                    private _amount = if (GVAR(STRATEGICPLATFORMS) find typeOf _house != -1) then {1} else {ceil random (_logic getVariable ["amount", 2])};
                    private _units = [];
                    for "_i" from 1 to _amount do {_units pushBack selectRandom _eligible};
                    if (_units isEqualTo []) then {
                        _result = "failed";
                    } else {
                        _house setVariable ["unittypes", _units, true];
                        _house setVariable ["faction", _context get "faction", true];
                        _context set ["unitClasses", _units];
                        _context set ["phase", "positions"];
                    };
                };
            };
        };
    };

    case "positions": {
        _context set ["positions", []];
        _context set ["positionCursor", 0];
        _context set ["phase", "positionEngine"];
    };

    case "positionEngine": {
        private _positions = _context get "positions";
        private _cursor = _context get "positionCursor";
        private _finished = false;
        for "_i" from 1 to 16 do {
            private _candidate = _house buildingPos _cursor;
            if (_candidate isEqualTo [0, 0, 0]) exitWith {_finished = true};
            _positions pushBack _candidate;
            _cursor = _cursor + 1;
        };
        _context set ["positionCursor", _cursor];

        if (_finished) then {
            _context set ["enginePositions", +_positions];
            if (isNil QGVAR(HASCBAPOSITIONS)) then {
                GVAR(HASCBAPOSITIONS) = !((allMissionObjects "CBA_buildingPos") isEqualTo []);
            };
            _context set ["positionCursor", 0];
            if (GVAR(HASCBAPOSITIONS) && {!(_house isKindOf "CBA_buildingPos")}) then {
                _context set ["cbaPositions", [_house] call CBA_fnc_buildingPositions];
                _context set ["phase", "positionMerge"];
            } else {
                _context set ["shuffleCursor", count _positions - 1];
                _context set ["phase", "positionShuffle"];
            };
        };
    };

    case "positionMerge": {
        private _positions = _context get "positions";
        private _cba = _context get "cbaPositions";
        private _cursor = _context get "positionCursor";
        private _end = (_cursor + 16) min count _cba;
        for "_i" from _cursor to (_end - 1) do {
            private _candidate = _cba select _i;
            if ((_positions findIf {_x distance _candidate < 0.5}) == -1) then {_positions pushBack _candidate};
        };
        _context set ["positionCursor", _end];
        if (_end >= count _cba) then {
            _context set ["shuffleCursor", count _positions - 1];
            _context set ["phase", "positionShuffle"];
        };
    };

    case "positionShuffle": {
        private _positions = _context get "positions";
        private _cursor = _context get "shuffleCursor";
        private _iterations = 0;
        while {_cursor > 0 && {_iterations < 16}} do {
            private _j = floor random (_cursor + 1);
            private _value = _positions select _cursor;
            _positions set [_cursor, _positions select _j];
            _positions set [_j, _value];
            _cursor = _cursor - 1;
            _iterations = _iterations + 1;
        };
        _context set ["shuffleCursor", _cursor];
        if (_cursor <= 0) then {
            _context set ["positionCursor", 0];
            _context set ["usablePositions", []];
            _context set ["phase", "positionFilter"];
        };
    };

    case "positionFilter": {
        private _positions = _context get "positions";
        private _cursor = _context get "positionCursor";
        private _end = (_cursor + 16) min count _positions;
        private _usable = _context get "usablePositions";
        private _strategic = GVAR(STRATEGICPLATFORMS) find typeOf _house != -1;
        for "_i" from _cursor to (_end - 1) do {
            private _candidate = _positions select _i;
            if (!_strategic || {(_candidate select 2) > 1}) then {_usable pushBack _candidate};
        };
        _context set ["positionCursor", _end];
        if (_end >= count _positions) then {
            if (_usable isEqualTo [] || {!([_house] call ALiVE_fnc_isHouseEnterable)}) then {
                _result = "failed";
            } else {
                _context set ["phase", "group"];
            };
        };
    };

    case "group": {
        private _units = _context get "unitClasses";
        private _side = switch (getNumber (configFile >> "CfgVehicles" >> (_units select 0) >> "side")) do {
            case 0: {EAST};
            case 1: {WEST};
            case 2: {RESISTANCE};
            case 3: {CIVILIAN};
            default {EAST};
        };
        private _group = createGroup _side;
        _group setVariable ["house", _house];
        _group setVariable ["ALIVE_profileIgnore", true];
        _house setVariable ["group", _group];
        // Retain the owned resource if the house object is deleted before the
        // controller handles a failure or module shutdown.
        _context set ["group", _group];
        _context set ["nextUnitAt", time];
        _context set ["phase", "units"];
    };

    case "units": {
        private _classes = _context get "unitClasses";

        if (_classes isequalto []) then {
            private _group = _house getVariable ["group", grpNull];
            if (isNull _group || {units _group isEqualTo []}) then {
                _result = "failed";
            } else {
                _context set ["phase", "staticInit"];
            };
        } else {
            if (time >= (_context get "nextUnitAt")) then {
                private _group = _house getVariable ["group", grpNull];

                if (isNull _group) then {
                    _result = "failed";
                } else {
                    private _unitClass = _classes deleteat 0;
                    PROFILE_SCOPE(CREATEUNIT,"createUnit")
                    private _unit = _group createUnit [_unitClass, [0,0,0], [], 0, "CAN_COLLIDE"];
                    PROFILE_SCOPE_END(CREATEUNIT)

                    if (!isNull _unit) then {
                        private _positions = _context get "usablePositions";
                        private _unitPosition = _positions select ((count units _group) % count _positions);
                        PROFILE_SCOPE(SETPOS,"SetPosATL")
                        _unit setPosATL [_unitPosition select 0, _unitPosition select 1, (_unitPosition select 2) + 0.4];
                        PROFILE_SCOPE_END(SETPOS)
                        _unit setVariable ["house", _house];
                        _unit setVariable ["ALIVE_profileIgnore", true];
                        _unit setVariable ["ALIVE_cqb_instance", _logic, true];
                    };

                    _context set ["nextUnitAt", time + MOD(smoothSpawn)];
                };
            };
        };
    };

    case "staticInit": {
        private _existing = _house getVariable ["staticWeapons", []];
        if ({alive _x} count _existing > 0) then {
            _context set ["phase", "finalize"];
        } else {
            private _intensity = _logic getVariable ["StaticWeaponsIntensity", 0];
            private _classes = _logic getVariable ["staticWeaponsClassnames", []];
            if (_intensity <= 0 || {_classes isEqualTo []} || {random 1 >= _intensity}) then {
                _context set ["phase", "finalize"];
            } else {
                _context set ["staticPositions", +(_context get "enginePositions")];
                _context set ["staticCursor", 0];
                _context set ["staticTop", []];
                _context set ["staticWeapons", _existing];
                _context set ["createdStatics", []];
                _context set ["staticTarget", ceil _intensity];
                _context set ["phase", "staticScan"];
            };
        };
    };

    case "staticScan": {
        private _positions = _context get "staticPositions";
        private _cursor = _context get "staticCursor";
        private _end = (_cursor + 4) min count _positions;
        private _top = _context get "staticTop";
        for "_i" from _cursor to (_end - 1) do {
            private _asl = AGLToASL (_positions select _i);
            private _check = +_asl;
            _check set [2, (_check select 2) + 10];
            if (lineIntersectsSurfaces [_asl, _check] isEqualTo []) then {_top pushBack ASLToAGL _asl};
        };
        _context set ["staticCursor", _end];
        if (_end >= count _positions) then {
            _context set ["staticShuffleCursor", count _top - 1];
            _context set ["phase", "staticShuffle"];
        };
    };

    case "staticShuffle": {
        private _positions = _context get "staticTop";
        private _cursor = _context get "staticShuffleCursor";
        private _iterations = 0;
        while {_cursor > 0 && {_iterations < 16}} do {
            private _j = floor random (_cursor + 1);
            private _value = _positions select _cursor;
            _positions set [_cursor, _positions select _j];
            _positions set [_j, _value];
            _cursor = _cursor - 1;
            _iterations = _iterations + 1;
        };
        _context set ["staticShuffleCursor", _cursor];
        if (_cursor <= 0) then {
            _context set ["staticCursor", 0];
            _context set ["phase", "statics"];
        };
    };

    case "statics": {
        private _created = _context get "staticWeapons";
        private _positions = _context get "staticTop";
        private _cursor = _context get "staticCursor";
        if (count _created >= (_context get "staticTarget") || {_cursor >= count _positions}) then {
            if !(_created isEqualTo []) then {_house setVariable ["staticWeapons", _created, true]};
            _context set ["phase", "finalize"];
        } else {
            private _placement = +(_positions select _cursor);
            private _buildingPosition = getPosATL _house;
            _placement set [2, (_placement select 2) + 0.3];
            _placement = [_placement, 1.5, _placement getDir _buildingPosition] call BIS_fnc_relPos;
            private _weapon = createVehicle [selectRandom (_logic getVariable ["staticWeaponsClassnames", []]), _placement, [], 0, "CAN_COLLIDE"];
            if (!isNull _weapon) then {
                _weapon setPos _placement;
                _weapon setDir (_buildingPosition getDir _placement);
                _created pushBack _weapon;
                (_context get "createdStatics") pushBack _weapon;
                _house setVariable ["staticWeapons", _created, true];
            };
            _context set ["staticCursor", _cursor + 1];
        };
    };

    case "finalize": {
        private _group = _house getVariable ["group", grpNull];
        if (isNull _group || {units _group isEqualTo []}) then {
            _result = "failed";
        } else {
            PROFILE_SCOPE(CQBFINALIZEREGISTRATION,"CQB finalize: registration")
            [_logic, "addGroup", [_house, _group]] call ALiVE_fnc_CQB;
            PROFILE_SCOPE_END(CQBFINALIZEREGISTRATION)
            if (isNull _group || {!((_house getVariable ["group", grpNull]) isEqualTo _group)}) then {
                _result = "failed";
            } else {
                PROFILE_SCOPE(CQBFINALIZEHOOKS,"CQB finalize: hooks")
                private _hookSource = _logic getVariable ["onEachSpawn", ""];
                if (_hookSource != "") then {
                    private _cachedHook = _logic getVariable ["ALIVE_CQB_onEachSpawnCode", ["", {}]];
                    if ((_cachedHook select 0) != _hookSource) then {
                        _cachedHook = [_hookSource, compile _hookSource];
                        _logic setVariable ["ALIVE_CQB_onEachSpawnCode", _cachedHook];
                    };
                    private _hook = _cachedHook select 1;
                    private _once = _logic getVariable ["onEachSpawnOnce", true];
                    {
                        if (!_once || {!(_x getVariable ["ALIVE_hookFired", false])}) then {
                            _x setVariable ["ALIVE_hookFired", true];
                            [_x, _x getVariable ["profileID", ""], side group _x, _x getVariable ["faction", ""]] spawn _hook;
                        };
                    } forEach units _group;
                };
                PROFILE_SCOPE_END(CQBFINALIZEHOOKS)

                private _chance = _logic getVariable ["CQB_patrol_chance", 0.30];
                if (random 1 <= _chance) then {
                    private _minDistance = _logic getVariable ["CQB_patrol_mindist", 50];
                    private _maxDistance = _logic getVariable ["CQB_patrol_maxist", 100];
                    PROFILE_SCOPE(CQBFINALIZEPATROL,"CQB finalize: patrol request")
                    [
                        _group,
                        getPos leader _group,
                        _minDistance + random (_maxDistance - _minDistance),
                        [3, 7] call BIS_fnc_randomInt,
                        "MOVE",
                        _logic getVariable ["CQB_patrol_behaviour", "SAFE"],
                        "YELLOW",
                        _logic getVariable ["CQB_patrol_speed", "LIMITED"],
                        "STAG COLUMN",
                        "_module = this getVariable ['ALIVE_cqb_instance', objNull]; _chance = if (isNull _module) then {0.3} else {_module getVariable ['CQB_patrol_searchchance', 0.3]}; if (random 1 <= _chance) then {_group = group this; if (!isNull this && {alive this} && {!isNull _group} && {!((units _group) isEqualTo [])}) then {[_group] call CBA_fnc_searchNearby}};",
                        [
                            _logic getVariable ["CQB_patrol_minwaittime", 0],
                            _logic getVariable ["CQB_patrol_midwaittime", 15],
                            _logic getVariable ["CQB_patrol_maxwaittime", 30]
                        ]
                    ] call ALIVE_fnc_taskPatrol;
                    PROFILE_SCOPE_END(CQBFINALIZEPATROL)
                } else {
                    private _fsm = "\x\alive\addons\mil_cqb\HousePatrol.fsm";
                    PROFILE_SCOPE(CQBFINALIZEFSM,"CQB finalize: FSM")
                    private _handle = [_logic, leader _group, 50, true, 60] execFSM _fsm;
                    (leader _group) setVariable ["FSM", [_handle, _fsm], true];
                    PROFILE_SCOPE_END(CQBFINALIZEFSM)
                };
                _result = "complete";
            };
        };
    };

    default {_result = "failed"};
};

PROFILE_SCOPE_END(CQBSPAWNSTEP)

_result
