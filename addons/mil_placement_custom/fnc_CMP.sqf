//#define DEBUG_MPDE_FULL
#include "\x\alive\addons\mil_placement_custom\script_component.hpp"
SCRIPT(CMP);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CMP
Description:
Military objectives

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Nil - init - Intiate instance
Nil - destroy - Destroy instance
Boolean - debug - Debug enabled
Array - state - Save and restore module state
Array - faction - Faction associated with module

Examples:
[_logic, "faction", "BLU_F"] call ALiVE_fnc_CMP;

See Also:
- <ALIVE_fnc_CMPInit>

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS                      ALIVE_fnc_baseClass
#define MAINCLASS                       ALIVE_fnc_CMP
#define MTEMPLATE                       "ALiVE_CMP_%1"
#define DEFAULT_FACTION                 QUOTE(BLU_F)
#define DEFAULT_SIZE                    "50"
#define DEFAULT_PRIORITY                "50"
#define DEFAULT_NO_TEXT                 "0"
#define DEFAULT_COMPOSITION             false
#define DEFAULT_OBJECTIVES              []
#define DEFAULT_READINESS_LEVEL         "1"
#define DEFAULT_AMBIENT_VEHICLE_AMOUNT  "0.2"
#define DEFAULT_HQ_BUILDING             objNull
#define DEFAULT_HQ_CLUSTER              []
#define DEFAULT_AMBIENT_GUARD_AMOUNT "0.2"
#define DEFAULT_AMBIENT_GUARD_RADIUS "200"
#define DEFAULT_AMBIENT_GUARD_PATROL_PERCENT "50"
// Reserve-pool defaults - mirror mil_placement (canonical source).
#define DEFAULT_ACTIVE_PATROL_PERCENT "0.75"
#define DEFAULT_RESERVE_ACTIVATION_THRESHOLD "0.5"
#define DEFAULT_RESERVE_ACTIVATION_COOLDOWN "30"
#define DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER "3"
#define DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS "1"
#define DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED "1"
#define DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR "SpawnAsInfantry"

TRACE_1("CMP - input",_this);

params [
    ["_logic", objNull, [objNull]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

private _result = true;

switch(_operation) do {

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            // if server
            _logic setVariable ["super", nil];
            _logic setVariable ["class", nil];

            [_logic, "destroy"] call SUPERCLASS;
        };

    };

    case "debug": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["debug", _args];
        } else {
            _args = _logic getVariable ["debug", false];
        };

        if (typeName _args == "STRING") then {
                if(_args == "true") then {_args = true;} else {_args = false;};
                _logic setVariable ["debug", _args];
        };

        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "state": {
        private["_state","_data","_nodes","_simple_operations"];
        _simple_operations = ["targets", "size","type","faction"];

        if(typeName _args != "ARRAY") then {
            _state = [] call CBA_fnc_hashCreate;
            // Save state
            {
                [_state, _x, _logic getVariable _x] call ALIVE_fnc_hashSet;
            } forEach _simple_operations;

            if ([_logic, "debug"] call MAINCLASS) then {
                diag_log PFORMAT_2(QUOTE(MAINCLASS), _operation,_state);
            };
            _result = _state;
        } else {
            ASSERT_TRUE([_args] call ALIVE_fnc_isHash,str _args);

            // Restore state
            {
                [_logic, _x, [_args, _x] call ALIVE_fnc_hashGet] call MAINCLASS;
            } forEach _simple_operations;
        };
    };

    case "customInfantryCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "customMotorisedCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "customMechanisedCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "customArmourCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "customSpecOpsCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "onEachSpawn": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawnOnce": {
        _result = [_logic, _operation, _args, true] call ALIVE_fnc_OOsimpleOperation;
    };

    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[] call ALiVE_fnc_configGetFactions] call ALIVE_fnc_OOsimpleOperation;

        if !(_args isEqualType "") then {
            private _compiledFaction = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if !(_compiledFaction isEqualTo "") then {
                _result = _compiledFaction;
            };
        };
    };
    
    case "guardProbability": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };
    
    case "guardRadius": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_RADIUS] call ALIVE_fnc_OOsimpleOperation;
    };
    
    case "guardPatrolPercentage": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_GUARD_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "size": {
        _result = [_logic,_operation,_args,DEFAULT_SIZE] call ALIVE_fnc_OOsimpleOperation;
    };

    case "priority": {
        _result = [_logic,_operation,_args,DEFAULT_PRIORITY] call ALIVE_fnc_OOsimpleOperation;
    };

    case "readinessLevel": {
        _result = [_logic,_operation,_args,DEFAULT_READINESS_LEVEL] call ALIVE_fnc_OOsimpleOperation;
    };
    case "activePatrolPercent": {
        _result = [_logic,_operation,_args,DEFAULT_ACTIVE_PATROL_PERCENT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveActivationThreshold": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ACTIVATION_THRESHOLD] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveActivationCooldown": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ACTIVATION_COOLDOWN] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveEngagementMultiplier": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ENGAGEMENT_MULTIPLIER] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveLockClearedBuildings": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_LOCK_CLEARED_BUILDINGS] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveEmptyVehicleLocked": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_EMPTY_VEHICLE_LOCKED] call ALIVE_fnc_OOsimpleOperation;
    };
    case "reserveOrphanCrewBehaviour": {
        _result = [_logic,_operation,_args,DEFAULT_RESERVE_ORPHAN_CREW_BEHAVIOUR] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the Ambient Vehicle Amount
    case "ambientVehicleAmount": {
        _result = [_logic,_operation,_args,DEFAULT_AMBIENT_VEHICLE_AMOUNT] call ALIVE_fnc_OOsimpleOperation;
    };

    // Return the HQ Building
    case "HQBuilding": {
        _result = [_logic,_operation,_args,DEFAULT_HQ_BUILDING] call ALIVE_fnc_OOsimpleOperation;
    };

    case "createHQ": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["createHQ", _args];
        } else {
            _args = _logic getVariable ["createHQ", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["createHQ", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "createFieldHQ": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["createFieldHQ", _args];
        } else {
            _args = _logic getVariable ["createFieldHQ", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["createFieldHQ", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "placeHelis": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["placeHelis", _args];
        } else {
            _args = _logic getVariable ["placeHelis", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["placeHelis", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "placeSupplies": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["placeSupplies", _args];
        } else {
            _args = _logic getVariable ["placeSupplies", false];
        };
        if (typeName _args == "STRING") then {
            if(_args == "true") then {_args = true;} else {_args = false;};
            _logic setVariable ["placeSupplies", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    case "composition": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["composition", _args];
        } else {
            _args = _logic getVariable ["composition", false];
        };
        if (typeName _args == "STRING") then {
                _logic setVariable ["composition", _args];
        };

        // Catch a bug that was introduced by the conversion of the
        // "composition" module field from dropdown to text field
        if (_args == "false") then {
            _logic setVariable ["composition", ""];
            _args = "";
        };

        _result = _args;
    };

    case "objectives": {
        _result = [_logic,_operation,_args,DEFAULT_OBJECTIVES] call ALIVE_fnc_OOsimpleOperation;
    };

    case "allowPlayerTasking": {
        if (typeName _args == "BOOL") then {
            _logic setVariable ["allowPlayerTasking", _args];
        } else {
            _args = _logic getVariable ["allowPlayerTasking", true];
        };

        if (typeName _args == "STRING") then {
            if (_args == "true") then {
                _args = true;
            }
            else {
                _args = false;
            };

            _logic setVariable ["allowPlayerTasking", _args];
        };

        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };

    // Main process
    case "init": {

        if (isServer) then {
            // if server, initialise module game logic
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];
            _logic setVariable ["moduleType", "ALIVE_CMP"];
            _logic setVariable ["startupComplete", false];

            TRACE_1("After module init",_logic);

            if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["Profile System module not placed! Exiting..."] call ALiVE_fnc_DumpR;
                _logic setVariable ["startupComplete", true];
            };

            waituntil {!(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

            [_logic,"start"] call MAINCLASS;
        };

    };

    case "start": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["CMP - Startup"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            if (isNil "ALIVE_clustersMilCustom") then {
                ALIVE_clustersMilCustom = [] call ALIVE_fnc_hashCreate;
            };

            // instantiate static vehicle position data
            if(isNil "ALIVE_groupConfig") then {
                [] call ALIVE_fnc_groupGenerateConfigData;
            };

            // all CMP modules execute at the same time
            // ALIVE_groupConfig is created, but not 100% filled
            // before the rest of the modules start creating their profiles

            waitUntil {!isnil "ALiVE_GROUP_CONFIG_DATA_GENERATED"};

            [_logic, "placement"] call MAINCLASS;
        };

    };

    // Placement
    case "placement": {

        if (isServer) then {

            private _debug = [_logic, "debug"] call MAINCLASS;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                ["CMP - Placement"] call ALiVE_fnc_dump;
                [true] call ALIVE_fnc_timer;
            };
            // DEBUG -------------------------------------------------------------------------------------

            private _guardProbability = parseNumber([_logic, "guardProbability"] call MAINCLASS);

            private _countInfantry = [_logic, "customInfantryCount"] call MAINCLASS;
            _countInfantry = parseNumber _countInfantry;
            
            private _countMotorized = [_logic, "customMotorisedCount"] call MAINCLASS;
            _countMotorized = parseNumber _countMotorized;

            private _countMechanized = [_logic, "customMechanisedCount"] call MAINCLASS;
            _countMechanized = parseNumber _countMechanized;

            private _countArmored = [_logic, "customArmourCount"] call MAINCLASS;
            _countArmored = parseNumber _countArmored;

            private _countSpecOps = [_logic, "customSpecOpsCount"] call MAINCLASS;
            _countSpecOps = parseNumber _countSpecOps;

            private _faction = [_logic, "faction"] call MAINCLASS;
            private _size = [_logic, "size"] call MAINCLASS;
            
            
            private _onEachSpawn = [_logic, "onEachSpawn"] call MAINCLASS;
            private _onEachSpawnOnce = [_logic, "onEachSpawnOnce"] call MAINCLASS;

            private _guardProbabilityCount = [_countInfantry,[_logic, "guardProbability"] call MAINCLASS] call ALIVE_fnc_infantryGuardProbabilityCount;
            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
	            ["CMP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------
            
            if (_guardProbabilityCount > 0) then {
              _countInfantry = _countInfantry - _guardProbabilityCount;
            };  
            

            if(typeName _size == "STRING") then {
                _size = parseNumber _size;
            };

            private _priority = [_logic, "priority"] call MAINCLASS;

            if(typeName _priority == "STRING") then {
                _priority = parseNumber _priority;
            };

            private _composition = [_logic, "composition"] call MAINCLASS;
            private _ambientVehicleAmount = parseNumber([_logic, "ambientVehicleAmount"] call MAINCLASS);
            private _createHQ = [_logic, "createHQ"] call MAINCLASS;
            private _createFieldHQ = [_logic, "createFieldHQ"] call MAINCLASS;
            private _placeHelis = [_logic, "placeHelis"] call MAINCLASS;
            private _placeSupplies = [_logic, "placeSupplies"] call MAINCLASS;
            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _countProfiles = 0;
            private _position = position _logic;
            private _allowPlayerTasking = [_logic, "allowPlayerTasking"] call MAINCLASS;

            // Load static data
            call ALiVE_fnc_staticDataHandler;

            // Spawn the composition.
            //
            // Track whether a user-picker composition spawned + at what
            // position, so the createHQ block downstream can use that
            // position as its building-search anchor (the composition's
            // own buildings should be the HQ source when the user has
            // picked compositions). Falls back to the createFieldHQ
            // safePos, then to the raw module pos.
            //
            // Marker name + class are tracked separately so the createHQ
            // block can delete the Custom Comp marker and emit a combined
            // "HQ + Custom Comp (Class)" label when the HQ Building
            // happens to BE the composition's central object.
            private _compositionSpawned = false;
            private _compositionSafePos = position _logic;
            private _compositionMarkerName = "";
            private _compositionSpawnedClass = "";
            private _compositionEnvelope = 30;

            if (typeName _composition == "STRING" && _composition != "" && _composition != "false") then {
                if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                    // Resolve the composition config first so we can size the
                    // validator's envelope to its actual footprint.
                    private _compType = "Military";
                    If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                        _compType = "Guerrilla";
                    };

                    // The composition attribute is now a comma-separated list
                    // of class names (multi-select picker). Parse, dedupe,
                    // pick one at random per spawn. Legacy single-class
                    // strings round-trip cleanly as a 1-element list.
                    //
                    // Strip the optional [F:sideIdx,sizeIdx,categoryIdx,
                    // sourceIdx] prefix the Eden picker prepends for filter-
                    // state persistence across mission save/reload. Only
                    // the picker's LOAD handler cares about the indices;
                    // the runtime spawn just needs the class CSV.
                    private _compForParse = _composition;
                    if (count _compForParse > 3 && {(_compForParse select [0, 3]) == "[F:"}) then {
                        private _closeIdx = _compForParse find "]";
                        if (_closeIdx > 3) then {
                            _compForParse = _compForParse select [_closeIdx + 1];
                        };
                    };
                    private _compClasses = [];
                    {
                        private _t = _x;
                        while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
                        while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do { _t = _t select [0, count _t - 1] };
                        if (_t != "") then { _compClasses pushBackUnique _t };
                    } forEach ([_compForParse, ","] call CBA_fnc_split);

                    // Multi-class fitment search. When the picker has multiple
                    // selections the validator tries each candidate at each
                    // tier and picks the FIRST that fits, so a tight terrain
                    // can still get a spawn from an alternative composition
                    // in the user's pool. Tier-major iteration prefers tighter
                    // placement (all candidates tried at 50m before any falls
                    // back to 150m); within a tier the candidate order is
                    // shuffled so multiple module instances get variety
                    // rather than always picking the same first-listed class.
                    //
                    // Tier 1 (50m)  - strict, respects user's chosen pos
                    // Tier 2 (150m) - mild expansion, near module
                    // Tier 3 (300m) - generous, composition in vicinity

                    private _spawnedComp = configNull;
                    private _spawnedSafePos = position _logic;
                    private _spawnedSafeDir = direction _logic;
                    private _spawnedTier = -1;

                    {
                        private _tier = _x;
                        if (!isNull _spawnedComp) exitWith {};

                        // Inline Fisher-Yates shuffle of _compClasses for
                        // this tier's pass. No BIS_fnc_arrayShuffle dep.
                        private _shufflePool = +_compClasses;
                        private _shuffled = [];
                        while {count _shufflePool > 0} do {
                            _shuffled pushBack (_shufflePool deleteAt (floor random count _shufflePool));
                        };

                        {
                            private _entry = _x;
                            if (!isNull _spawnedComp) exitWith {};

                            // Picker entries can be qualified `class|category|size`
                            // (new format - disambiguates size variants of the
                            // same class) or legacy `class` (old saves + Override
                            // Edit free-text). Qualified path uses the size hint
                            // to pull the exact variant; legacy falls back to
                            // findComposition's first-match.
                            private _class = _entry;
                            private _entrySize = "";
                            private _pipeIdx = _entry find "|";
                            if (_pipeIdx > 0) then {
                                _class = _entry select [0, _pipeIdx];
                                private _rest = _entry select [_pipeIdx + 1];
                                private _pipe2 = _rest find "|";
                                if (_pipe2 > 0) then {
                                    _entrySize = _rest select [_pipe2 + 1];
                                };
                            };

                            // Resolve composition config. Prefer size-qualified
                            // getCompositions when the picker entry carries a
                            // size hint, then findComposition first-match,
                            // then size-agnostic getCompositions as the final
                            // fallback.
                            private _comp = [];
                            if (_entrySize != "" && {_entrySize != "Unspecified"}) then {
                                private _compDef = ([_compType, [_class], [_entrySize], _faction] call ALiVE_fnc_getCompositions);
                                if (count _compDef > 0) then { _comp = selectRandom _compDef };
                            };
                            if (count _comp == 0) then {
                                _comp = [_class, _compType] call ALIVE_fnc_findComposition;
                            };
                            if (count _comp == 0) then {
                                private _compDef = ([_compType, [_class], [], _faction] call ALiVE_fnc_getCompositions);
                                if (count _compDef > 0) then {
                                    _comp = selectRandom _compDef;
                                };
                            };
                            if (count _comp > 0) then {
                                private _envelope = [_comp] call ALiVE_fnc_getCompositionRadius;
                                private _result = [_position, _tier, _envelope, "military", direction _logic, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                                if (count _result > 0) then {
                                    _result params ["_sp", "_sd"];
                                    _spawnedComp = _comp;
                                    _spawnedSafePos = _sp;
                                    _spawnedSafeDir = _sd;
                                    _spawnedTier = _tier;
                                };
                            };
                        } forEach _shuffled;
                    } forEach [50, 150, 300];

                    if (!isNull _spawnedComp) then {
                        [_spawnedComp, _spawnedSafePos, _spawnedSafeDir, _faction] call ALIVE_fnc_spawnComposition;
                        _compositionSpawned = true;
                        _compositionSafePos = _spawnedSafePos;
                        _compositionSpawnedClass = configName _spawnedComp;
                        // Cache the envelope so the createHQ block downstream
                        // can size its composition-membership search to the
                        // actual layout (small radio kit vs. a sprawling
                        // BIS Camp Bravery have very different reaches).
                        _compositionEnvelope = ([_spawnedComp] call ALiVE_fnc_getCompositionRadius) max 30;
                        if (_debug) then {
                            _compositionMarkerName = [_spawnedSafePos, 4, format ["%1 - Custom Comp (%2)", _side, _compositionSpawnedClass], "ColorOrange", "placement.cmp.comp"] call ALIVE_fnc_placeDebugMarker;
                            ["CMP [%1] - Custom composition %2 spawned at %3 (module pos was %4, %5m offset, search tier %6m, picked from %7 selections)",
                                _faction, _compositionSpawnedClass, _spawnedSafePos, _position, round (_spawnedSafePos distance _position), _spawnedTier, count _compClasses] call ALiVE_fnc_dump;
                        };
                    } else {
                        ["CMP [%1] - Warning: None of the %2 selected compositions could be placed within 300m of module (tried 3 search tiers) - skipped (selections: '%3')",
                            _faction, count _compClasses, _composition] call ALiVE_fnc_dump;
                    };
                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Size: %1 Priority: %2",_size,_priority] call ALiVE_fnc_dump;
                ["CMP [%1] - SideNum: %1 Side: %2 Faction: %3 Composition: %4",_factionSideNumber,_side,_faction,_composition] call ALiVE_fnc_dump;
                ["CMP Allow player tasking: %1", _allowPlayerTasking] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // assign the objective to OPCOMS
            /*

            for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                private _moduleObject = (synchronizedObjects _logic) select _i;

                waituntil {_module = _moduleObject getVariable "handler"; !(isnil "_module")};
                _private module = _moduleObject getVariable "handler";

                private _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];
                private _objective = [_objectiveName, _position, _size, "MIL", _priority];

                [_module,"addObjective",_objective] call ALiVE_fnc_OPCOM;
            };
            */

            private _objectiveName = format["CUSTOM_%1",floor((_position select 0) + (_position select 1))];

            private _cluster = [nil, "create"] call ALIVE_fnc_cluster;
            [_cluster,"nodes", (nearestObjects [_position,["static"],_size])] call ALIVE_fnc_hashSet;
            [_cluster,"clusterID", _objectiveName] call ALIVE_fnc_hashSet;
            [_cluster,"center", _position] call ALIVE_fnc_hashSet;
            [_cluster,"size", _size] call ALIVE_fnc_hashSet;
            [_cluster,"type", "MIL"] call ALIVE_fnc_hashSet;
            [_cluster,"priority", _priority] call ALIVE_fnc_hashSet;
            [_cluster,"allowPlayerTasking", _allowPlayerTasking] call ALIVE_fnc_hashSet;
            [_cluster,"debug", _debug] call ALIVE_fnc_cluster;

            [_logic, "objectives", [_cluster]] call MAINCLASS;

            [ALIVE_clustersMilCustom, _objectiveName, _cluster] call ALIVE_fnc_hashSet;

            if(ALIVE_loadProfilesPersistent) exitWith {

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then { ["CMP - Profiles are persistent, no creation of profiles"] call ALiVE_fnc_dump; };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];

            };


            // Spawn the main force

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Force creation ",_faction] call ALiVE_fnc_dump;
                ["CMP Count Armor: %1",_countArmored] call ALiVE_fnc_dump;
                ["CMP Count Mech: %1",_countMechanized] call ALiVE_fnc_dump;
                ["CMP Count Motor: %1",_countMotorized] call ALiVE_fnc_dump;
                ["CMP Count Infantry: %1",_countInfantry] call ALiVE_fnc_dump;
                ["CMP Count Garrison Infantry: %1",_guardProbabilityCount] call ALIVE_fnc_dump;
                ["CMP Count Spec Ops: %1",_countSpecOps] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Assign groups
            private _groups = [];
            private _infantryGroups = [];
            private _motorizedGroups = [];

            for "_i" from 0 to _countInfantry -1 do {
                private _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                };
            };

            for "_i" from 0 to _countSpecOps -1 do {
                private _group = ["SpecOps",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _infantryGroups pushback _group;
                };
            };

            _groups append _infantryGroups;

            for "_i" from 0 to _countMotorized -1 do {
                private _group = ["Motorized",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _motorizedGroups pushback _group;
                };
            };

            if(count _motorizedGroups == 0) then {
                for "_i" from 0 to _countMotorized -1 do {
                    private _group = ["Motorized_MTP",_faction] call ALIVE_fnc_configGetRandomGroup;
                    if!(_group == "FALSE") then {
                        _motorizedGroups pushback _group;
                    };
                };
            };

            _groups append _motorizedGroups;

            for "_i" from 0 to _countMechanized -1 do {
                private _group = ["Mechanized",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                }
            };

            for "_i" from 0 to _countArmored -1 do {
                private _group = ["Armored",_faction] call ALIVE_fnc_configGetRandomGroup;
                if!(_group == "FALSE") then {
                    _groups pushback _group;
                };
            };

            _infantryGroups = _infantryGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _motorizedGroups = _motorizedGroups - ALiVE_PLACEMENT_GROUPBLACKLIST;
            _groups = _groups - ALiVE_PLACEMENT_GROUPBLACKLIST;

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Groups ",_groups] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
              ["CMP [%1] - Garrison _guardProbabilityCount: %2", _faction, _guardProbabilityCount] call ALiVE_fnc_dump;           
            };
            // DEBUG -------------------------------------------------------------------------------------
                    
            private _guardRadius = parseNumber([_logic, "guardRadius"] call MAINCLASS);
            private _guardPatrolPercentage = parseNumber([_logic, "guardPatrolPercentage"] call MAINCLASS);
            private _guardDistance = parseNumber([_logic, "size"] call MAINCLASS);

            // Position and create groups
            private _groupCount = count _groups;
            private _totalCount = 0;

            if(_groupCount > 0) then {
                // Guards
                if (count _infantryGroups > 0 && _guardProbabilityCount > 0) then {
                    for "_i" from 0 to _guardProbabilityCount -1 do {
                        _guardGroup = (selectRandom _infantryGroups);
                        _guards = [_guardGroup, [_position, _guardDistance] call CBA_fnc_RandPos, random(360), true, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                        // DEBUG -------------------------------------------------------------------------------------
                        if(_debug) then {
                            ["CMP [%1] - Placing Garrison Guards - %2", _faction, _guardGroup] call ALiVE_fnc_dump;
                        };
                        // DEBUG -------------------------------------------------------------------------------------

                        // Garrison & Patrols instead of the static garrison.
                        {
                            if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage]]] call ALIVE_fnc_profileEntity;
                            };
                        } forEach _guards;
                        _countProfiles = _countProfiles + count _guards;
                    };
                };

                // Main Force - reserve-pool placement model. Mirrors mil_placement
                // semantics: Readiness = fraction of force ACTIVE at start; the
                // remainder stays in the cluster's reserve pool and wakes when
                // active losses cross the activation threshold or a player
                // engages. Vehicle reserves spawn empty (locked by default);
                // infantry reserves hold off until activation places them at a
                // candidate building.
                //
                // Semantic change from previous CMP behaviour: Readiness used to
                // be a garrison-vs-patrol slider (1 - readiness = garrison
                // fraction). It now controls active-vs-reserve, while the new
                // 'Active patrol percent' attribute drives the garrison vs
                // patrol split inside the active force.
                private _readinessLevel = parseNumber([_logic, "readinessLevel"] call MAINCLASS);
                private _activePatrolPercent = parseNumber([_logic, "activePatrolPercent"] call MAINCLASS);
                private _vehicleEmptyLocked = (parseNumber([_logic, "reserveEmptyVehicleLocked"] call MAINCLASS)) > 0;

                // Group order in _groups: infantry first (Infantry + SpecOps),
                // then motorised, then mechanised, then armoured. So the
                // infantry/vehicle boundary is count(_infantryGroups).
                private _infantryGroupCount = count _infantryGroups;
                private _vehicleGroupCount = _groupCount - _infantryGroupCount;
                private _infantryActiveCount = round (_infantryGroupCount * _readinessLevel);
                private _vehicleActiveCount = round (_vehicleGroupCount * _readinessLevel);
                // Garrison budget for infantry only - vehicles always patrol.
                private _garrisonCount = round (_infantryActiveCount * (1 - _activePatrolPercent));

                // Per-iteration trackers.
                private _infantryActivePlacedCount = 0;
                private _vehicleActivePlacedCount = 0;

                // Helper: extract first LandVehicle classname from a CfgGroups
                // class. Returns "" if no eligible vehicle (statics excluded).
                private _fnc_getGroupVehicleClass = {
                    params ["_groupClass", "_groupFaction"];
                    private _config = [_groupFaction, _groupClass] call ALIVE_fnc_configGetGroup;
                    if (count _config == 0) exitWith { "" };
                    private _result = "";
                    for "_i" from 0 to (count _config - 1) do {
                        if (_result != "") exitWith {};
                        private _entry = _config select _i;
                        if (isClass _entry) then {
                            private _veh = getText (_entry >> "vehicle");
                            if (_veh isKindOf "LandVehicle") then { _result = _veh };
                        };
                    };
                    _result
                };

                // Helper: cluster-aware parking-position lookup. Cascade:
                // road -> auto -> flat seed -> wide retry -> raw random.
                // Sloped accepts get gradient-rejected.
                private _fnc_findVehicleParkingPos = {
                    params ["_vehicleClass", "_clusterCenter", "_clusterSize"];
                    if (_vehicleClass == "") exitWith {
                        [_clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360], random 360]
                    };
                    private _fnc_isFlatEnough = {
                        params ["_pos"];
                        private _flat = _pos isFlatEmpty [-1, -1, 0.4, 5, 0, false, objNull];
                        count _flat >= 2
                    };
                    private _searchRadius = (_clusterSize + 100) max 200;
                    private _seedPos = _clusterCenter getPos [(random (_clusterSize / 2)) + 30, random 360];
                    private _seedDir = random 360;

                    private _result = [_vehicleClass, _seedPos, _searchRadius, "road", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    _result = [_vehicleClass, _seedPos, _searchRadius, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    if ([_seedPos] call _fnc_isFlatEnough) exitWith { [_seedPos, _seedDir] };

                    _result = [_vehicleClass, _clusterCenter, _clusterSize * 3, "auto", _seedDir] call ALiVE_fnc_findVehicleSpawnPosition;
                    if (count _result >= 2 && {[_result select 0] call _fnc_isFlatEnough}) exitWith { _result };

                    [_clusterCenter getPos [50, random 360], _seedDir]
                };

                // Per-cluster reserve metadata. CMP has a single cluster (the
                // module's position); attach the reserve hashes to it so the
                // shared activateReserve in addons/main can dispatch.
                [_cluster, "reservePool", []] call ALiVE_fnc_hashSet;
                [_cluster, "reserveActiveAtSpawn", 0] call ALiVE_fnc_hashSet;
                [_cluster, "activeProfileIDs", []] call ALiVE_fnc_hashSet;
                [_cluster, "lastReserveWake", -999] call ALiVE_fnc_hashSet;
                [_cluster, "reserveModule", _logic] call ALiVE_fnc_hashSet;
                [_cluster, "reserveModuleClass", MAINCLASS] call ALiVE_fnc_hashSet;

                for "_i" from 0 to (_groupCount - 1) do {
                    private ["_command","_radius","_garrisonPos","_position"];
                    private _group = _groups select _i;
                    private _isInfantry = _i < _infantryGroupCount;
                    private _isVehicle = !_isInfantry;

                    private _vehicleReserveClass = "";
                    if (_isVehicle && {_vehicleActivePlacedCount >= _vehicleActiveCount}) then {
                        _vehicleReserveClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                    };
                    private _isVehicleReserve = _vehicleReserveClass != "";
                    private _isInfantryReserve = _isInfantry && {_infantryActivePlacedCount >= _infantryActiveCount};
                    private _isReserve = _isVehicleReserve || _isInfantryReserve;

                    if (_isReserve) then {
                        private _reservePool = [_cluster, "reservePool"] call ALiVE_fnc_hashGet;
                        if (_isVehicleReserve) then {
                            // Empty vehicle reserve - profile parked at a
                            // road-validated position; crew added at activation.
                            private _t0 = diag_tickTime;
                            private _parking = [_vehicleReserveClass, position _logic, _size] call _fnc_findVehicleParkingPos;
                            private _vehiclePos = _parking select 0;
                            private _vehicleDir = _parking select 1;
                            if (surfaceIsWater _vehiclePos) then {
                                _vehiclePos = (position _logic) getPos [50, random 360];
                            };
                            diag_log format ["[ALiVE Reserve DEBUG] CMP-VEHICLE-RESERVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _vehicleReserveClass, _vehiclePos, round ((diag_tickTime - _t0) * 1000)];

                            private _emptyProfiles = [_vehicleReserveClass, _side, _faction, _vehiclePos, _vehicleDir, false, _faction] call ALIVE_fnc_createProfilesUnCrewedVehicle;
                            private _profileEntity = _emptyProfiles select 0;
                            private _profileVehicle = _emptyProfiles select 1;
                            [_profileEntity, "objectType", _group] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "aiBehaviour", "STEALTH"] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                            [_profileEntity, "busy", true] call ALIVE_fnc_profileEntity;
                            [_profileVehicle, "busy", true] call ALIVE_fnc_profileVehicle;
                            [_profileEntity, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                            [_profileVehicle, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                            private _vehicleProfileID = [_profileVehicle, "profileID"] call ALiVE_fnc_hashGet;
                            private _entityProfileID = [_profileEntity, "profileID"] call ALiVE_fnc_hashGet;
                            _reservePool pushBack ["VEHICLE", _group, _vehicleProfileID, _entityProfileID, _faction, _onEachSpawn, _onEachSpawnOnce];
                            _countProfiles = _countProfiles + 2;
                        } else {
                            _reservePool pushBack ["INFANTRY", _group, _faction, _onEachSpawn, _onEachSpawnOnce];
                        };
                        [_cluster, "reservePool", _reservePool] call ALiVE_fnc_hashSet;
                        _totalCount = _totalCount + 1;
                    } else {
                        // Active placement. Vehicles always patrol; only
                        // infantry participates in the garrison budget.
                        private _activeDir = random 360;
                        private _activeT0 = diag_tickTime;
                        private _activeVehClass = "";
                        if (_isVehicle) then {
                            _command = "ALIVE_fnc_ambientMovement";
                            _radius = [_guardRadius,"SAFE",[0,0,0]];
                            _activeVehClass = [_group, _faction] call _fnc_getGroupVehicleClass;
                            if (_activeVehClass != "") then {
                                private _parking = [_activeVehClass, position _logic, _size] call _fnc_findVehicleParkingPos;
                                _position = _parking select 0;
                                _activeDir = _parking select 1;
                            } else {
                                _position = [position _logic, random((_radius select 0) + ((_radius select 0)/0.25)), random(360)] call BIS_fnc_relPos;
                            };
                        } else {
                            if (_infantryActivePlacedCount < _garrisonCount) then {
                                _command = "ALIVE_fnc_garrison";
                                _radius = [_guardRadius,"true",[0,0,0],"",_guardProbabilityCount, _guardPatrolPercentage];
                                _position = [position _logic, 30] call CBA_fnc_RandPos;
                            } else {
                                _command = "ALIVE_fnc_ambientMovement";
                                _radius = [_guardRadius,"SAFE",[0,0,0]];
                                _position = [position _logic, random((_radius select 0) + ((_radius select 0)/0.25)), random(360)] call BIS_fnc_relPos;
                            };
                        };

                        if !(surfaceIsWater _position) then {
                            private _profiles = [_group, _position, _activeDir, false, _faction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                            if (_isVehicle) then {
                                diag_log format ["[ALiVE Reserve DEBUG] CMP-VEHICLE-ACTIVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _faction, _totalCount, _group, _activeVehClass, _position, round ((diag_tickTime - _activeT0) * 1000)];
                            };

                            {
                                if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                    [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                    [_x, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                    private _profileID = [_x, "profileID"] call ALiVE_fnc_HashGet;
                                    private _activeIDs = [_cluster, "activeProfileIDs"] call ALiVE_fnc_HashGet;
                                    _activeIDs pushBack _profileID;
                                    [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_HashSet;
                                };
                                if (([_x,"type"] call ALiVE_fnc_HashGet) == "vehicle") then {
                                    [_x, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                };
                            } foreach _profiles;

                            _countProfiles = _countProfiles + count _profiles;
                            _totalCount = _totalCount + 1;
                            if (_isInfantry) then { _infantryActivePlacedCount = _infantryActivePlacedCount + 1 };
                            if (_isVehicle) then { _vehicleActivePlacedCount = _vehicleActivePlacedCount + 1 };

                            private _spawned = [_cluster, "reserveActiveAtSpawn"] call ALiVE_fnc_hashGet;
                            [_cluster, "reserveActiveAtSpawn", _spawned + 1] call ALiVE_fnc_hashSet;
                        };
                    };
                };

                // Activation watcher PFH (5 s tick). Self-terminates if the
                // module logic becomes null. Identical pattern to mil_placement.
                private _totalReserves = count ([_cluster, "reservePool", []] call ALiVE_fnc_hashGet);
                if (_totalReserves > 0) then {
                    [{
                        params ["_args", "_handle"];
                        _args params ["_watchClusters", "_watchLogic"];
                        if (isNull _watchLogic) exitWith {
                            [_handle] call CBA_fnc_removePerFrameHandler;
                        };
                        {
                            [_x, _watchLogic] call ALIVE_fnc_activateReserve;
                        } forEach _watchClusters;
                    }, 5, [[_cluster], _logic]] call CBA_fnc_addPerFrameHandler;
                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP - Total profiles created: %1",_countProfiles] call ALiVE_fnc_dump;
                ["CMP - Placement completed"] call ALiVE_fnc_dump;
                [] call ALIVE_fnc_timer;
                ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // Create Field HQ - auto-pick fallback.
            //
            // Spawns a random FieldHQ composition ONLY when the picker is
            // genuinely EMPTY (no class names saved). When the user has
            // ticked compositions in the picker but validator failed for
            // all of them, this block does NOT substitute a different
            // composition - the user's intent is respected and createHQ
            // falls back to a building search at module pos instead.
            //
            // Behaviour matrix:
            //   picker has selections + createFieldHQ on   -> picker comp (this block skipped)
            //   picker has selections + createFieldHQ off  -> picker comp
            //   picker has selections, validator fails     -> NO composition; createHQ does building search
            //   picker empty  + createFieldHQ on           -> auto FieldHQ (this block fires)
            //   picker empty  + createFieldHQ off          -> no composition

            private _fieldHQSpawned = false;
            private _fieldHQSafePos = position _logic;
            private _fieldHQMarkerName = "";
            private _fieldHQSpawnedClass = "";
            private _fieldHQEnvelope = 30;
            // Strip the picker's [F:...] prefix before checking emptiness so
            // a saved-but-empty picker (just "[F:0,0,0,0]" with no classes)
            // correctly evaluates as empty.
            private _pickerCheck = _composition;
            if (typeName _pickerCheck == "STRING" && {count _pickerCheck > 3} && {(_pickerCheck select [0, 3]) == "[F:"}) then {
                private _closeIdx = _pickerCheck find "]";
                if (_closeIdx > 3) then { _pickerCheck = _pickerCheck select [_closeIdx + 1] };
            };
            private _pickerEmpty = (typeName _pickerCheck != "STRING") || {_pickerCheck == ""} || {_pickerCheck == "false"};

            if (_createFieldHQ && _pickerEmpty) then {
                if (isNil QMOD(COMPOSITIONS_LOADED)) then {
                    private _compType = "Military";
                    If (_faction call ALiVE_fnc_factionSide == RESISTANCE) then {
                        _compType = "Guerrilla";
                    };
                    private _HQ = (selectRandom ([_compType, ["FieldHQ"], ["Large","Medium"], _faction] call ALiVE_fnc_getCompositions));
                    if (isNil "_HQ") then {
                        _HQ = (selectRandom ([_compType, ["HQ","FieldHQ"], ["Medium","Small"], _faction] call ALiVE_fnc_getCompositions));
                    };

                    if (!isNil "_HQ") then {
                        private _envelope = [_HQ] call ALiVE_fnc_getCompositionRadius;
                        // Wider tiers than the implicit fallback - users who
                        // explicitly enabled Create Field HQ want a FieldHQ
                        // even if the surrounding area is built up. 500m
                        // outer reach mirrors mil_placement Field HQ's
                        // cluster-size search radius.
                        private _radii = [50, 200, 500];
                        private _compResult = [];
                        private _tierUsed = -1;
                        {
                            _compResult = [position _logic, _x, _envelope, "fieldhq", direction _logic, _debug] call ALiVE_fnc_findCompositionSpawnPosition;
                            if (count _compResult > 0) exitWith { _tierUsed = _x };
                        } forEach _radii;

                        if (count _compResult > 0) then {
                            _compResult params ["_safePos", "_safeDir"];
                            [_HQ, _safePos, _safeDir, _faction] call ALIVE_fnc_spawnComposition;
                            _fieldHQSpawned = true;
                            _fieldHQSafePos = _safePos;
                            _fieldHQSpawnedClass = configName _HQ;
                            _fieldHQEnvelope = ([_HQ] call ALiVE_fnc_getCompositionRadius) max 30;
                            if (_debug) then {
                                _fieldHQMarkerName = [_safePos, 4, format ["%1 - Field HQ (%2)", _side, _fieldHQSpawnedClass], "ColorOrange", "placement.cmp.comp"] call ALIVE_fnc_placeDebugMarker;
                                ["CMP [%1] - Field HQ composition %2 spawned at %3 (module pos was %4, %5m offset, search tier %6m)",
                                    _faction, _fieldHQSpawnedClass, _safePos, position _logic, round (_safePos distance position _logic), _tierUsed] call ALiVE_fnc_dump;
                            };
                        } else {
                            ["CMP [%1] - Warning: Field HQ validator found no clear spawn position within %2m of module (tried %3 search tiers) - composition %4 not spawned",
                                _faction, selectMax _radii, count _radii, configName _HQ] call ALiVE_fnc_dump;
                        };
                    };
                };
            };

            // Create HQ

            if(_createHQ) then {

                // Building-search anchor cascade: when a composition has
                // been placed near the module, search for HQ buildings
                // starting at that composition's validated position so
                // its own buildings get registered as the HQ. Priority:
                //   1. User-picker composition pos (when populated + spawned)
                //   2. Auto-FieldHQ pos (when picker empty + createFieldHQ on)
                //   3. Module position (no composition spawned)
                private _modulePosition = switch (true) do {
                    case (_compositionSpawned): { _compositionSafePos };
                    case (_fieldHQSpawned):     { _fieldHQSafePos };
                    default                     { position _logic };
                };

                private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                private _buildings = [_nodes, ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                _buildings = [_buildings,[_modulePosition],{_Input0 distance _x},"ASCENDING",{[_x] call ALIVE_fnc_isHouseEnterable}] call ALiVE_fnc_SortBy;

                if (count _buildings == 0) then {_buildings = [_modulePosition, _size, ALIVE_militaryBuildingTypes + ALIVE_militaryHQBuildingTypes] call ALIVE_fnc_findNearObjectsByType};

                // When a composition was spawned at this anchor, ADD the
                // composition's substantial static objects to the candidate
                // pool. Lets non-typed compositions (radar dome, watertower,
                // checkpoint kit) count as HQ buildings even when their
                // class names aren't in ALIVE_militaryHQBuildingTypes / the
                // wider militaryBuildingTypes list. Closest-to-anchor wins
                // after re-sort, so the composition's central object
                // typically dominates over distant map-placed buildings.
                //
                // No implicit composition spawn here - createHQ uses
                // EITHER the picker's spawned composition OR an existing
                // building. Auto-FieldHQ generation is the explicit job of
                // the Auto Field HQ if empty toggle above (which fires
                // before this block when picker is empty).
                // Track which objects came from the just-spawned composition
                // so the HQ-Building marker dedupe below can identify when the
                // chosen building is part of the composition (vs. an existing
                // map building that happened to be nearby). Search radius is
                // sized to the spawned composition's actual envelope so a
                // sprawling layout (e.g. BIS Camp Bravery) still has all its
                // objects considered, not just those within an arbitrary 30m.
                private _compStructures = [];
                if (_compositionSpawned || _fieldHQSpawned) then {
                    private _searchRadius = if (_compositionSpawned) then { _compositionEnvelope } else { _fieldHQEnvelope };
                    private _compNearby = nearestObjects [_modulePosition, [], _searchRadius];
                    _compStructures = _compNearby select {
                        (!(_x isKindOf "AllVehicles")) && {
                            private _bbox = boundingBoxReal _x;
                            _bbox params ["_bMin", "_bMax"];
                            private _w = (_bMax select 0) - (_bMin select 0);
                            private _l = (_bMax select 1) - (_bMin select 1);
                            private _h = (_bMax select 2) - (_bMin select 2);
                            (_w * _l * _h) > 8
                        }
                    };
                    {
                        if !(_x in _buildings) then { _buildings pushBack _x };
                    } forEach _compStructures;
                    // Re-sort the combined pool by distance to anchor so
                    // the composition's centre object (typically at safePos)
                    // wins over map-placed buildings further out.
                    _buildings = [_buildings, [_modulePosition], {_Input0 distance _x}, "ASCENDING"] call ALiVE_fnc_SortBy;
                };

                if (count _buildings > 0) then {

                    private _hqBuilding = _buildings select 0;


                    // DEBUG -------------------------------------------------------------------------------------
                    if(_debug) then {
                        // Detect when the registered HQ Building IS one of
                        // the composition's own objects (membership test, not
                        // distance test - composition anchor and main object
                        // can be many metres apart in larger layouts). When
                        // it is, delete the redundant Custom Comp / Field HQ
                        // marker and use a combined label on the HQ Building
                        // marker so a single object isn't tagged twice.
                        private _hqPos = position _hqBuilding;
                        private _hqIsCompObj = (_hqBuilding in _compStructures);
                        private _hqIsComp    = _compositionSpawned && _hqIsCompObj;
                        private _hqIsFieldHQ = _fieldHQSpawned     && _hqIsCompObj;

                        if (_hqIsComp && {_compositionMarkerName != ""}) then {
                            deleteMarker _compositionMarkerName;
                            deleteMarker (_compositionMarkerName + "_anchor");
                        };
                        if (_hqIsFieldHQ && {_fieldHQMarkerName != ""}) then {
                            deleteMarker _fieldHQMarkerName;
                            deleteMarker (_fieldHQMarkerName + "_anchor");
                        };

                        private _hqLabel = switch (true) do {
                            case (_hqIsComp):    { format ["%1 - HQ + Custom Comp (%2)", _side, _compositionSpawnedClass] };
                            case (_hqIsFieldHQ): { format ["%1 - HQ + Field HQ (%2)",    _side, _fieldHQSpawnedClass] };
                            default              { format ["%1 - HQ Building (%2)",      _side, _faction] };
                        };

                        [_hqPos, 4, _hqLabel, "ColorOrange", "placement.cmp"] call ALIVE_fnc_placeDebugMarker;
                        ["CMP [%1] - HQ Building placed at %2 - building %3 (compObj=%4, hqIsComp=%5, hqIsFieldHQ=%6, compStructuresCount=%7)",
                            _faction, _hqPos, typeOf _hqBuilding, _hqIsCompObj, _hqIsComp, _hqIsFieldHQ, count _compStructures] call ALiVE_fnc_dump;
                    };
                    // DEBUG -------------------------------------------------------------------------------------

                    if(_hqBuilding in _nodes) then {
                        [_cluster, "priority",1000] call ALIVE_fnc_hashSet;
                    };

                    [_logic, "HQBuilding", _hqBuilding] call MAINCLASS;
                } else {
                    ["CMP - Warning no HQ locations found"] call ALiVE_fnc_dump;
                };

            };

            // Spawn supplies in objectives

            private _countSupplies = 0;

            if(_placeSupplies) then {

                // attempt to get supplies by faction
                private _staticFaction = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
                private _supplyClasses = [ALIVE_factionDefaultSupplies,_staticFaction,[]] call ALIVE_fnc_hashGet;

                //["SUPPLY CLASSES: %1",_supplyClasses] call ALIVE_fnc_dump;

                // if no supplies found for the faction use side supplies
                if(count _supplyClasses == 0) then {
                    _supplyClasses = [ALIVE_sideDefaultSupplies,_side] call ALIVE_fnc_hashGet;
                };

                _supplyClasses = _supplyClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _supplyClasses > 0) then {

                        private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                        private _buildings = [_nodes, ALIVE_militarySupplyBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                        //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                        //[_x, "debug", true] call ALIVE_fnc_cluster;
                        {
                            private _position = position _x;
                            private _direction = direction _x;
                            private _vehicleClass = (selectRandom _supplyClasses);

                            if(random 1 > 0.3) then {
                                private _box = createVehicle [_vehicleClass, _position, [], 0, "NONE"];
                                _countSupplies = _countSupplies + 1;
                            };
                        } forEach _buildings;

                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Supplies placed: %2",_faction,_countSupplies] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Spawn helicopters on pads

            private _countCrewedHelis = 0;
            private _countUncrewedHelis = 0;

            if(_placeHelis) then {

                private _heliClasses = [0,_faction,"Helicopter"] call ALiVE_fnc_findVehicleType;
                _heliClasses = _heliClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                if(count _heliClasses > 0) then {

                    private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                    //[_x, "debug", true] call ALIVE_fnc_cluster;
                    {
                        if (typeOf _x in ALIVE_militaryHeliBuildingTypes || typeOf _x in ALIVE_civilianHeliBuildingTypes || typeOf _x in ["Land_HelipadSquare_F","Land_HelipadCircle_F"]) then {
                            private _position = position _x;
                            private _direction = direction _x;
                            private _vehicleClass = (selectRandom _heliClasses);

                            // Threshold reconciled to 0.2 to match mil_placement (was
                            // `> 0.8` = 80% crewed, an inversion bug or historical drift
                            // that produced unwanted AI pilots on most ambient helis).
                            // Crewed helis are gated on mil_ato presence - same logic as
                            // mil_placement: if no ATO module to task them, no point
                            // burning AI slots on idle pilots.
                            private _atoActive = count (allMissionObjects "ALiVE_mil_ato") > 0;
                            private _diceRoll = random 1;
                            private _crewed = _atoActive && {_diceRoll <= 0.2};
                            if (!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}) then {
                                diag_log format ["[ALiVE VehSpawn DEBUG] HELI-PLACEMENT module=mil_placement_custom faction=%1 class=%2 pos=%3 atoActive=%4 dice=%5 threshold=0.2 result=%6",
                                    _faction, _vehicleClass, _position, _atoActive, _diceRoll,
                                    if (_crewed) then {"CREWED"} else {"UNCREWED"}];
                            };

                            if !(_crewed) then {
                                [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                _countProfiles = _countProfiles + 1;
                                _countUncrewedHelis =_countUncrewedHelis + 1;
                            }else{
                                [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direction,false,_faction] call ALIVE_fnc_createProfilesCrewedVehicle;
                                _countProfiles = _countProfiles + 2;
                                _countCrewedHelis = _countCrewedHelis + 1;
                            };
                        };
                    } forEach _nodes;

                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Heli units placed: crewed:%2 uncrewed:%3",_faction,_countCrewedHelis,_countUncrewedHelis] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // Spawn ambient vehicles

            private _countLandUnits = 0;

            if(_ambientVehicleAmount > 0) then {

                private _carClasses = [0,_faction,"Car"] call ALiVE_fnc_findVehicleType;
                private _armorClasses = [0,_faction,"Tank"] call ALiVE_fnc_findVehicleType;

                private _landClasses = _carClasses + _armorClasses;
                _landClasses = _landClasses - ALiVE_PLACEMENT_VEHICLEBLACKLIST;

                private _staticFaction = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
                private _supportClasses = [ALIVE_factionDefaultSupports,_staticFaction,[]] call ALIVE_fnc_hashGet;

                //["SUPPORT CLASSES: %1",_supportClasses] call ALIVE_fnc_dump;

                // if no supports found for the faction use side supplies
                if(count _supportClasses == 0) then {
                    _supportClasses = [ALIVE_sideDefaultSupports,_side] call ALIVE_fnc_hashGet;
                };

                if(count _landClasses == 0) then {
                    _landClasses = _landClasses + _supportClasses;
                }else{
                    _landClasses = _landClasses - _supportClasses;
                };

                //["LAND CLASSES: %1",_landClasses] call ALIVE_fnc_dump;

                if(count _landClasses > 0) then {

                    private _supportCount = 0;
                    private _supportMax = 0;

                    private _nodes = [_cluster, "nodes"] call ALIVE_fnc_hashGet;

                    private _buildings = [_nodes, ALIVE_militaryParkingBuildingTypes] call ALIVE_fnc_findBuildingsInClusterNodes;

                    //["BUILDINGS: %1",_buildings] call ALIVE_fnc_dump;

                    private _countBuildings = count _buildings;
                    private _parkingChance = 0.1 * _ambientVehicleAmount;

                    //["COUNT BUILDINGS: %1",_countBuildings] call ALIVE_fnc_dump;
                    //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                    if(_countBuildings > 50) then {
                        _supportMax = 5;
                        _parkingChance = 0.1 * _ambientVehicleAmount;
                    };

                    if(_countBuildings > 40 && _countBuildings < 50) then {
                        _supportMax = 5;
                        _parkingChance = 0.2 * _ambientVehicleAmount;
                    };

                    if(_countBuildings > 30 && _countBuildings < 41) then {
                        _supportMax = 5;
                        _parkingChance = 0.3 * _ambientVehicleAmount;
                    };

                    if(_countBuildings > 20 && _countBuildings < 31) then {
                        _supportMax = 3;
                        _parkingChance = 0.4 * _ambientVehicleAmount;
                    };

                    if(_countBuildings > 10 && _countBuildings < 21) then {
                        _supportMax = 2;
                        _parkingChance = 0.6 * _ambientVehicleAmount;
                    };

                    if(_countBuildings > 0 && _countBuildings < 11) then {
                        _supportMax = 1;
                        _parkingChance = 0.8 * _ambientVehicleAmount;
                    };

                    //["SUPPORT MAX: %1",_supportMax] call ALIVE_fnc_dump;
                    //["CHANCE: %1",_parkingChance] call ALIVE_fnc_dump;

                    private _usedPositions = [];

                    {
                        private ["_vehicleClass"];

                        if(random 1 < _parkingChance) then {

                            private _building = _x;

                            private _supportPlacement = false;

                            if(_supportCount <= _supportMax) then {
                                _supportPlacement = true;
                                _vehicleClass = (selectRandom _supportClasses);
                            }else{
                                _vehicleClass = (selectRandom _landClasses);
                            };

                            //["SUPPORT PLACEMENT: %1",_supportPlacement] call ALIVE_fnc_dump;
                            //["VEHICLE CLASS: %1",_vehicleClass] call ALIVE_fnc_dump;

                            private _parkingPosition = [_vehicleClass,_building,[]] call ALIVE_fnc_getParkingPosition;

                            if (count _parkingPosition == 2) then {

                                private _positionOK = true;

                                {
                                    private _position = _x select 0;
                                    if((_parkingPosition select 0) distance _position < 10) then {
                                        _positionOK = false;
                                    };
                                } forEach _usedPositions;

                                //["POS OK: %1",_positionOK] call ALIVE_fnc_dump;

                                if(_positionOK) then {
                                    // Trailing `,[],true` removed - paired fix with
                                    // mil_placement/fnc_MP.sqf:1200. The `true` was
                                    // mis-positionally setting `_isSPE` and skipping the
                                    // unified spawn-position validator on activation.
                                    [_vehicleClass,_side,_faction,_parkingPosition select 0,_parkingPosition select 1,false,_faction] call ALIVE_fnc_createProfileVehicle;

                                    _countLandUnits = _countLandUnits + 1;

                                    _usedPositions pushback _parkingPosition;

                                    if(_supportPlacement) then {
                                        _supportCount = _supportCount + 1;
                                    };
                                };

                            };
                        };

                    } forEach _buildings;

                };
            };


            // DEBUG -------------------------------------------------------------------------------------
            if(_debug) then {
                ["CMP [%1] - Ambient land units placed: %2",_faction,_countLandUnits] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------

            // set module as started
            _logic setVariable ["startupComplete", true];

        };

    };

};

TRACE_1("CMP - output",_result);

_result;
