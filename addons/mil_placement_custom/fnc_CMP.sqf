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
        _simple_operations = ["targets", "size","type","faction","factions"];

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
    case "customArtilleryCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customArtilleryFaction": {
        _result = [_logic,_operation,_args,""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "customArtillerySectionSize": {
        _result = [_logic,_operation,_args,"4"] call ALIVE_fnc_OOsimpleOperation;
    };

    case "customSpecOpsCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "aaCount": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };

    case "aaBehaviour": {
        _result = [_logic,_operation,_args,"static"] call ALIVE_fnc_OOsimpleOperation;
    };

    case "aaClasses": {
        _result = [_logic,_operation,_args,DEFAULT_NO_TEXT] call ALIVE_fnc_OOsimpleOperation;
    };
    case "factions": {
        _result = [_logic,_operation,_args,"[]"] call ALIVE_fnc_OOsimpleOperation;
    };

    case "onEachSpawn": {
        _result = [_logic, _operation, _args, ""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "onEachSpawnOnce": {
        // The editor stores a yes or no here as text. The shared settings helper replaces
        // any value whose type differs from the default it is handed, and writes that
        // default back onto the module, so handing it a plain yes or no threw the setting
        // away and stamped the default over it permanently. Keep it as text on the way
        // through for that reason, and settle it on the way out so callers need not care.
        if (_args isEqualType true) then { _args = ["false", "true"] select _args };

        private _value = [_logic, _operation, _args, "true"] call ALIVE_fnc_OOsimpleOperation;

        if (_value isEqualType true) then {
            _result = _value;
        } else {
            _result = (toLower (_value + "")) in ["true", "yes", "1"];
        };
    };

    case "faction": {
        _result = [_logic,_operation,_args,DEFAULT_FACTION,[""] + ([] call ALiVE_fnc_configGetFactions)] call ALIVE_fnc_OOsimpleOperation;

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
    case "garrisonPatrolBehaviour": {
        _result = [_logic,_operation,_args,"SAFE"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "preferredGarrisonPositions": {
        _result = [_logic,_operation,_args,""] call ALIVE_fnc_OOsimpleOperation;
    };
    case "garrisonPatrolSpeed": {
        _result = [_logic,_operation,_args,"LIMITED"] call ALIVE_fnc_OOsimpleOperation;
    };
    case "garrisonCompositions": {
        _result = [_logic,_operation,_args,"true"] call ALIVE_fnc_OOsimpleOperation;
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
        // "composition" module field from dropdown to text field.
        // A module with no composition value at all, such as one created from script, arrives
        // here with the false fallback above; comparing that to text threw and stopped its start.
        if (!(_args isEqualType "") || {_args == "false"}) then {
            _logic setVariable ["composition", ""];
            _args = "";
        };

        _result = _args;
    };

    // #875 - objective scenery objects: AA-style triplet.
    case "objectiveObjects": {
        if (typeName _args == "STRING") then {
            _logic setVariable ["objectiveObjects", _args];
        } else {
            _args = _logic getVariable ["objectiveObjects", ""];
        };
        if (typeName _args != "STRING") then { _args = ""; };
        _result = _args;
    };
    case "objectiveObjectsCount": {
        if (typeName _args == "STRING") then {
            _logic setVariable ["objectiveObjectsCount", _args];
        } else {
            _args = _logic getVariable ["objectiveObjectsCount", "0"];
        };
        if (typeName _args != "STRING") then { _args = "0"; };
        _result = _args;
    };
    case "objectiveObjectsChance": {
        if (typeName _args == "STRING") then {
            _logic setVariable ["objectiveObjectsChance", _args];
        } else {
            _args = _logic getVariable ["objectiveObjectsChance", "100"];
        };
        if (typeName _args != "STRING") then { _args = "100"; };
        _result = _args;
    };
    case "objectiveObjectsBehaviour": {
        if (typeName _args == "STRING") then {
            _logic setVariable ["objectiveObjectsBehaviour", _args];
        } else {
            _args = _logic getVariable ["objectiveObjectsBehaviour", "dispersed"];
        };
        if (typeName _args != "STRING" || {_args == ""}) then { _args = "dispersed"; };
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

            // A count box holding something that isn't a number counts as 0: say so, rather than place
            // nothing without a word.
            {
                _x params ["_box", "_text"];
                if (_text isEqualType "" && {((toArray _text) findIf {!(_x in [32, 45, 46] || {_x >= 48 && {_x <= 57}})}) > -1}) then {
                    ["CMP - the %1 count box holds ""%2"", which isn't a number, so it counts as 0", _box, _text] call ALiVE_fnc_dump;
                };
            } forEach [["infantry", [_logic, "customInfantryCount"] call MAINCLASS], ["motorised", [_logic, "customMotorisedCount"] call MAINCLASS], ["mechanised", [_logic, "customMechanisedCount"] call MAINCLASS], ["armour", [_logic, "customArmourCount"] call MAINCLASS], ["spec ops", [_logic, "customSpecOpsCount"] call MAINCLASS], ["artillery", [_logic, "customArtilleryCount"] call MAINCLASS]];
            private _countInfantry = [_logic, "customInfantryCount"] call MAINCLASS;
            _countInfantry = parseNumber _countInfantry;
            
            private _countMotorized = [_logic, "customMotorisedCount"] call MAINCLASS;
            _countMotorized = parseNumber _countMotorized;

            private _countMechanized = [_logic, "customMechanisedCount"] call MAINCLASS;
            _countMechanized = parseNumber _countMechanized;

            private _countArmored = [_logic, "customArmourCount"] call MAINCLASS;
            _countArmored = parseNumber _countArmored;

            private _countArtillery = [_logic, "customArtilleryCount"] call MAINCLASS;
            _countArtillery = parseNumber _countArtillery;

            private _countSpecOps = [_logic, "customSpecOpsCount"] call MAINCLASS;
            _countSpecOps = parseNumber _countSpecOps;

            // AA placement attrs. aaCount Edit defaults to "0" - no AA
            // spawned unless raised. aaBehaviour Combo defaults to
            // "static". aaClasses CSV from picker, faction-default fallback
            // at spawn time.
            private _aaCount = [_logic, "aaCount"] call MAINCLASS;
            if (_aaCount == "") then { _aaCount = 0 } else { _aaCount = parseNumber _aaCount };
            private _aaBehaviour = [_logic, "aaBehaviour"] call MAINCLASS;
            if (_aaBehaviour == "") then { _aaBehaviour = "static" };
            private _aaClasses = [_logic, "aaClasses"] call MAINCLASS;

            private _fnc_parseFactions = {
                params ["_value"];
                private _parsed = [];
                if (_value isEqualType []) then {
                    {
                        if (_x isEqualType "" && {_x != ""} && {_x != "NONE"} && {!(_x in _parsed)}) then {
                            _parsed pushBack _x;
                        };
                    } forEach _value;
                    _parsed
                } else {
                    if !(_value isEqualType "") exitWith { [] };
                    if (_value == "") exitWith { [] };
                    private _s = _value;
                    _s = [_s, " ", ""] call CBA_fnc_replace;
                    _s = [_s, "[", ""] call CBA_fnc_replace;
                    _s = [_s, "]", ""] call CBA_fnc_replace;
                    _s = [_s, """", ""] call CBA_fnc_replace;
                    {
                        if (_x != "" && {_x != "NONE"} && {!(_x in _parsed)}) then {
                            _parsed pushBack _x;
                        };
                    } forEach ([_s, ","] call CBA_fnc_split);
                    _parsed
                };
            };

            private _fnc_getOpcomFactions = {
                params ["_opcom"];
                private _opcomFactions = [_opcom getVariable ["factions", ""]] call _fnc_parseFactions;
                {
                    if !(_x in _opcomFactions) then { _opcomFactions pushBack _x };
                } forEach ([_opcom getVariable ["factionsManual", ""]] call _fnc_parseFactions);

                if (count _opcomFactions == 0) then {
                    {
                        private _legacyFaction = _opcom getVariable [_x, ""];
                        if (_legacyFaction != "" && {_legacyFaction != "NONE"} && {!(_legacyFaction in _opcomFactions)}) then {
                            _opcomFactions pushBack _legacyFaction;
                        };
                    } forEach ["faction1", "faction2", "faction3", "faction4"];
                };
                if (count _opcomFactions == 0) then { _opcomFactions pushBack DEFAULT_FACTION };

                _opcomFactions
            };

            private _factions = [_logic getVariable ["factions", ""]] call _fnc_parseFactions;
            // A Custom Faction Compiler synced to this module places its compiled faction, ahead of
            // Force Factions, as the faction getter does for the other placement modules. This
            // module never called that getter, so a synced compiler did nothing here.
            private _compiledFaction = [_logic] call ALiVE_fnc_factionCompilerResolveForModule;
            if (_compiledFaction != "") then {
                _factions = [_compiledFaction];
                ["%1 - a synced Custom Faction Compiler sets this module's force to %2", "CMP", _compiledFaction] call ALiVE_fnc_dump;
            };
            // Read the raw hidden legacy value so only a non-default legacy
            // faction blocks OPCOM inheritance.
            private _legacyFactions = [_logic getVariable ["faction", ""]] call _fnc_parseFactions;
            // Old SQMs often carry the former BLU_F default in the now-hidden
            // field; don't let that stale default block commander inheritance.
            private _legacyIsDefault = (count _legacyFactions == 1) && {(_legacyFactions select 0) == DEFAULT_FACTION};
            if ((count _factions == 0) && {count _legacyFactions > 0} && {!_legacyIsDefault}) then {
                _factions = +_legacyFactions;
            };
            if (count _factions == 0) then {
                {
                    if ((typeOf _x) isEqualTo "ALiVE_mil_OPCOM") then {
                        {
                            if !(_x in _factions) then { _factions pushBack _x };
                        } forEach ([_x] call _fnc_getOpcomFactions);
                    };
                } forEach (synchronizedObjects _logic);
                // Each group is placed on its own faction's side, so commanders of two enemy sides
                // synced to one module put both sides' groups on one objective. A faction is kept
                // only if its side and every kept faction's side are friends both ways, first one
                // first, so allied commanders still give a joint force; the others are left out,
                // and the log says which. (Friendship isn't transitive: a side friendly to two
                // enemies mustn't bring both in.)
                if (count _factions > 1) then {
                    private _kept = [_factions select 0];
                    {
                        private _side = _x call ALiVE_fnc_factionSide;
                        private _clash = _kept findIf {
                            private _keptSide = _x call ALiVE_fnc_factionSide;
                            (_keptSide getFriend _side) < 0.6 || {(_side getFriend _keptSide) < 0.6}
                        };
                        if (_clash < 0) then { _kept pushBack _x };
                    } forEach (_factions select [1, count _factions - 1]);
                    private _hostile = _factions - _kept;
                    if (count _hostile > 0) then {
                        _factions = _kept;
                        ["%1 - Force Factions is empty and the synced commanders include enemies of each other: placing %2, leaving out %3", "CMP", _kept, _hostile] call ALiVE_fnc_dump;
                    };
                };
            };
            if ((count _factions == 0) && {count _legacyFactions > 0}) then {
                _factions = +_legacyFactions;
            };
            if (count _factions == 0) then { _factions = [DEFAULT_FACTION] };

            private _faction = _factions select 0;
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

            // Nearest dry ground within the objective, looked for from the module outwards in rings
            // the first time a group, guard or parked vehicle spot falls in the water. [] if none.
            private _landAnchor = [-1];
            private _fnc_landAnchor = {
                if (_landAnchor isEqualTo [-1]) then {
                    _landAnchor = [];
                    private _centre = position _logic;
                    if (!surfaceIsWater _centre) exitWith { _landAnchor = _centre };
                    for "_r" from 25 to (_size max 25) step 25 do {
                        if !(_landAnchor isEqualTo []) exitWith {};
                        for "_a" from 0 to 345 step 15 do {
                            private _p = _centre getPos [_r, _a];
                            if (!surfaceIsWater _p) exitWith { _landAnchor = _p };
                        };
                    };
                };
                _landAnchor
            };
            // A dry spot within _this metres of that ground (ten tries, else the anchor itself), or
            // [] when the objective has no dry ground at all.
            private _fnc_landSpot = {
                private _jitter = _this;
                private _anchor = call _fnc_landAnchor;
                if (_anchor isEqualTo []) exitWith { [] };
                private _spot = _anchor;
                for "_try" from 1 to 10 do {
                    private _candidate = [_anchor, _jitter] call CBA_fnc_RandPos;
                    if (!surfaceIsWater _candidate) exitWith { _spot = _candidate };
                };
                _spot
            };
            // Guard groups left out because the objective has no dry ground at all, as groups are.
            private _guardsInWater = 0;

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
            private _garrisonCompositions = ([_logic, "garrisonCompositions"] call MAINCLASS) in [true, "true"];
            private _objectiveObjectsRaw = [_logic, "objectiveObjects"] call MAINCLASS;
            private _factionConfig = _faction call ALiVE_fnc_configGetFactionClass;
            private _factionSideNumber = getNumber(_factionConfig >> "side");
            private _side = _factionSideNumber call ALIVE_fnc_sideNumberToText;
            private _countProfiles = 0;
            private _position = position _logic;
            private _allowPlayerTasking = [_logic, "allowPlayerTasking"] call MAINCLASS;

            // Outline circle showing the configured Objective Size
            // (size attr) radius. Mirrors the mil_ied / civ_placement_custom
            // debug-marker pattern - Ellipse + Border so the area is
            // visible without obscuring map detail.
            if (_debug) then {
                private _circleName = format ["alive_cmp_objsize_%1", floor((_position select 0) + (_position select 1))];
                [_circleName, _position, "Ellipse", [_size, _size], "TEXT:", format ["Objective Size (%1m)", _size], "COLOR:", "ColorRed", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
            };

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
            private _compositionSeats = 0;

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

                    // A picker with nothing chosen still hands over its filter prefix, so the
                    // attribute reads as something like [F:0,0,0,0] rather than an empty string
                    // and the check above lets it through. The parse then leaves no classes at
                    // all. Without this the tier sweep runs looking for somewhere to put
                    // nothing, and ends by warning that none of zero compositions could be
                    // placed, which reads like a fault when it is simply an empty picker.
                    if (_compClasses isEqualTo []) exitWith {
                        if (_debug) then {
                            ["CMP [%1] - No compositions selected, nothing to place", _faction] call ALiVE_fnc_dump;
                        };
                    };

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
                    // Tiers extend progressively from 50m up to the user-
                    // configured Objective Size (size attr), capped down
                    // by half-distance to the nearest sibling ALiVE
                    // placement-class module so adjacent modules don't
                    // compete for the same patch. The user's debug-circle
                    // marker shows the resulting search area.

                    private _compCap = [_logic, _position, _size, 50, _size] call ALIVE_fnc_neighbourAwareSearchCap;
                    private _allTiers = [50, 150, 300, 500, 800, 1200, 2000];
                    private _compTiers = _allTiers select { _x <= _compCap };
                    if (count _compTiers == 0 || (_compTiers select (count _compTiers - 1)) < _compCap) then {
                        _compTiers pushBack _compCap;
                    };

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
                    } forEach _compTiers;

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
                        // estimate garrison seats so the guard pass knows how
                        // many groups to divert into the composition. Ring
                        // geometry mirrors x_lib fnc_groupGarrison - keep in sync
                        {
                            // Only the positions the seating loop will offer. It drops any reading as the
                                        // world origin, so counting them here sizes a garrison for seats it will refuse.
                                        private _bp = count ((_x buildingPos -1) select {!(_x isEqualTo [0,0,0])});
                            if (_bp > 0) then {
                                _compositionSeats = _compositionSeats + _bp;
                            } else {
                                (boundingBoxReal _x) params ["_bMin","_bMax"];
                                private _ringRadius = 0.5 * (((_bMax select 0) - (_bMin select 0)) max ((_bMax select 1) - (_bMin select 1))) + 1;
                                _compositionSeats = _compositionSeats + (2 max (floor ((2 * pi * _ringRadius) / 4)) min 6);
                            };
                        } forEach ([nearestObjects [_spawnedSafePos, ALIVE_garrisonPositions select 1, _compositionEnvelope]] call ALIVE_fnc_garrisonAllowedBuildings);
                        {
                            _compositionSeats = _compositionSeats + ([_x] call ALIVE_fnc_vehicleCountEmptyPositions);
                        } forEach (nearestObjects [_spawnedSafePos, ["StaticWeapon"], _compositionEnvelope]);
                        if (_debug) then {
                            _compositionMarkerName = [_spawnedSafePos, 4, format ["%1 - Custom Comp (%2)", _side, _compositionSpawnedClass], "ColorOrange", "placement.cmp.comp"] call ALIVE_fnc_placeDebugMarker;
                            ["CMP [%1] - Custom composition %2 spawned at %3 (module pos was %4, %5m offset, search tier %6m, picked from %7 selections)",
                                _faction, _compositionSpawnedClass, _spawnedSafePos, _position, round (_spawnedSafePos distance _position), _spawnedTier, count _compClasses] call ALiVE_fnc_dump;
                        };
                    } else {
                        ["CMP [%1] - Warning: None of the %2 selected compositions could be placed within %3m of module (tried %4 search tiers: %5) - skipped (selections: '%6')",
                            _faction, count _compClasses, _compTiers select (count _compTiers - 1), count _compTiers, _compTiers, _composition] call ALiVE_fnc_dump;
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

            // Modules whose coordinates add up to the same whole number share that key. They're told
            // apart by where they stand, west to east and then south to north, so each gets the same
            // key every session whatever order they start in: the first keeps the key as it always
            // was and the next gets _2, and so on. The counter below still catches anything left over.
            private _keyModules = (allMissionObjects "ALiVE_mil_placement_custom") + (allMissionObjects "ALiVE_mil_placement_spe");
            private _keySum = floor ((_position select 0) + (_position select 1));
            private _sameKey = [];
            {
                private _p = position _x;
                if (floor ((_p select 0) + (_p select 1)) == _keySum) then { _sameKey pushBack [_p select 0, _p select 1, _forEachIndex] };
            } forEach _keyModules;
            _sameKey sort true;
            private _keyRank = _sameKey findIf { (_keyModules select (_x select 2)) == _logic };
            if (_keyRank > 0) then { _objectiveName = format ["%1_%2", _objectiveName, _keyRank + 1] };
            private _cluster = [nil, "create"] call ALIVE_fnc_cluster;
            // A key still taken, two modules on the very same spot say, gets the next free number, so
            // the second never overwrites the first. Picked and claimed in one step, so two modules
            // starting together can't both take it.
            isNil {
                if ([ALIVE_clustersMilCustom, _objectiveName] call CBA_fnc_hashHasKey) then {
                    private _baseName = _objectiveName;
                    private _suffix = 2;
                    while {[ALIVE_clustersMilCustom, format ["%1_%2", _baseName, _suffix]] call CBA_fnc_hashHasKey} do { _suffix = _suffix + 1 };
                    _objectiveName = format ["%1_%2", _baseName, _suffix];
                };
                [ALIVE_clustersMilCustom, _objectiveName, _cluster] call ALIVE_fnc_hashSet;
            };
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
                ["CMP [%1] - Force creation ",_factions] call ALiVE_fnc_dump;
                ["CMP Count Armor: %1",_countArmored] call ALiVE_fnc_dump;
                ["CMP Count Artillery: %1",_countArtillery] call ALiVE_fnc_dump;
                ["CMP Count Mech: %1",_countMechanized] call ALiVE_fnc_dump;
                ["CMP Count Motor: %1",_countMotorized] call ALiVE_fnc_dump;
                ["CMP Count Infantry: %1",_countInfantry] call ALiVE_fnc_dump;
                ["CMP Count Garrison Infantry: %1",_guardProbabilityCount] call ALIVE_fnc_dump;
                ["CMP Count Spec Ops: %1",_countSpecOps] call ALiVE_fnc_dump;
            };
            // DEBUG -------------------------------------------------------------------------------------


            // Assign groups
            private _fnc_pickGroupForCategory = {
                params ["_category", "_slotIndex"];
                private _entry = ["FALSE", ""];
                private _factionCount = count _factions;
                if (_factionCount == 0) exitWith { _entry };
                private _start = _slotIndex mod _factionCount;
                for "_attempt" from 0 to (_factionCount - 1) do {
                    private _candidateFaction = _factions select ((_start + _attempt) mod _factionCount);
                    private _candidateGroup = [_category, _candidateFaction] call ALIVE_fnc_configGetRandomGroup;
                    if !(_candidateGroup == "FALSE") exitWith {
                        _entry = [_candidateGroup, _candidateFaction];
                    };
                };
                _entry
            };

            private _groups = [];
            private _infantryGroups = [];
            private _motorizedGroups = [];

            for "_i" from 0 to _countInfantry -1 do {
                private _entry = ["Infantry",_i] call _fnc_pickGroupForCategory;
                if!((_entry select 0) == "FALSE") then {
                    _infantryGroups pushback _entry;
                };
            };

            for "_i" from 0 to _countSpecOps -1 do {
                private _entry = ["SpecOps",_i] call _fnc_pickGroupForCategory;
                if!((_entry select 0) == "FALSE") then {
                    _infantryGroups pushback _entry;
                };
            };

            _groups append _infantryGroups;

            for "_i" from 0 to _countMotorized -1 do {
                private _entry = ["Motorized",_i] call _fnc_pickGroupForCategory;
                if((_entry select 0) == "FALSE") then {
                    _entry = ["Motorized_MTP",_i] call _fnc_pickGroupForCategory;
                };
                if!((_entry select 0) == "FALSE") then {
                    _motorizedGroups pushback _entry;
                };
            };

            _groups append _motorizedGroups;

            for "_i" from 0 to _countMechanized -1 do {
                private _entry = ["Mechanized",_i] call _fnc_pickGroupForCategory;
                if!((_entry select 0) == "FALSE") then {
                    _groups pushback _entry;
                }
            };

            for "_i" from 0 to _countArmored -1 do {
                private _entry = ["Armored",_i] call _fnc_pickGroupForCategory;
                if!((_entry select 0) == "FALSE") then {
                    _groups pushback _entry;
                };
            };

            // #887 groundwork - artillery sections ride the normal group pipeline;
            // OPCOM buckets them as an artillery force class
            private _artilleryWarned = false;
            private _artilleryGroupNames = [];
            private _artilleryFallback = 0;
            // #887 - optional donor faction for artillery: models batteries
            // attached from a sister branch (e.g. RHS Tank Troops guns
            // supporting Motor Rifles). The donor must fight for the same side
            private _artilleryDonor = trim ([_logic, "customArtilleryFaction"] call MAINCLASS);
            if (_artilleryDonor != "") then {
                private _donorConfig = _artilleryDonor call ALiVE_fnc_configGetFactionClass;
                if (!isClass _donorConfig) then {
                    ["CMP - Artillery faction %1 not found in CfgFactionClasses - artillery reverts to the composition factions",_artilleryDonor] call ALiVE_fnc_dump;
                    _artilleryDonor = "";
                } else {
                    if (getNumber (_donorConfig >> "side") != _factionSideNumber) then {
                        ["CMP - Artillery faction %1 does not fight for side %2 - artillery reverts to the composition factions",_artilleryDonor,_side] call ALiVE_fnc_dump;
                        _artilleryDonor = "";
                    };
                };
            };
            private _artyPullFactions = if (_artilleryDonor != "") then {[_artilleryDonor]} else {_factions};

            // rocket artillery is out-ranged by small terrains (4-5km minimum
            // range) - defer rocket groups there, howitzer batteries come from the
            // vehicle fallback below
            private _smallMapForRockets = worldSize < 10240;
            for "_i" from 0 to _countArtillery -1 do {
                private _entry = ["FALSE",""];
                if (_artilleryDonor != "") then {
                    // donor groups can ride the pipeline - CMP spawns each
                    // group with its own faction
                    private _donorGroup = ["Artillery",_artilleryDonor] call ALIVE_fnc_configGetRandomGroup;
                    if (_donorGroup != "FALSE") then { _entry = [_donorGroup,_artilleryDonor] };
                } else {
                    _entry = ["Artillery",_i] call _fnc_pickGroupForCategory;
                };
                if!((_entry select 0) == "FALSE") then {
                    if (_smallMapForRockets && {[_entry select 1, _entry select 0] call ALIVE_fnc_groupIsRocketArtillery}) then {
                        _artilleryFallback = _artilleryFallback + 1;
                        if (!_artilleryWarned) then {
                            _artilleryWarned = true;
                            ["CMP - %1 is rocket artillery, out-ranged by this terrain (worldSize %2) - composing a howitzer battery instead",_entry select 0,worldSize] call ALiVE_fnc_dump;
                        };
                    } else {
                        _groups pushback _entry;
                        _artilleryGroupNames pushback (_entry select 0);
                    };
                } else {
                    _artilleryFallback = _artilleryFallback + 1;
                    if (!_artilleryWarned) then {
                        _artilleryWarned = true;
                        ["CMP [%1] - no faction has Artillery groups - composing batteries from their artillery vehicles instead",_artyPullFactions] call ALiVE_fnc_dump;
                    };
                };
            };

            // Fallback artillery batteries - a faction has artillery VEHICLES but
            // no artillery GROUPS: compose each battery directly (one class, two
            // crewed guns) around the objective. Self-propelled guns take
            // priority: the first faction fielding them wins; towed/static
            // pieces are used only when no faction owns anything better
            if (_artilleryFallback > 0) then {
                private _fnc_factionGuns = {
                    private _c = _this call ALIVE_fnc_configGetFactionArtilleryVehicles;
                    // prefer gun artillery (howitzers) on small terrains; keep rockets
                    // only when the faction owns nothing else
                    if (_smallMapForRockets) then {
                        private _guns = _c select { !([_x] call ALIVE_fnc_isRocketArtillery) };
                        if (count _guns > 0) then { _c = _guns; };
                    };
                    _c
                };

                private _artyClasses = [];
                private _artyFaction = "";
                {
                    private _sp = (_x call _fnc_factionGuns) select { !(_x isKindOf "StaticWeapon") };
                    if (count _sp > 0) exitWith { _artyClasses = _sp; _artyFaction = _x; };
                } forEach _artyPullFactions;
                if (count _artyClasses == 0) then {
                    {
                        private _c = _x call _fnc_factionGuns;
                        if (count _c > 0) exitWith { _artyClasses = _c; _artyFaction = _x; };
                    } forEach _artyPullFactions;
                };

                if (count _artyClasses == 0) then {
                    ["CMP [%1] - no faction has artillery groups OR artillery vehicles - nothing to place",_artyPullFactions] call ALiVE_fnc_dump;
                } else {
                    private _artySideNum = getNumber ((_artyFaction call ALiVE_fnc_configGetFactionClass) >> "side");
                    private _artySide = _artySideNum call ALIVE_fnc_sideNumberToText;
                    private _usedArtyPositions = [];
                    // #876 - guns per vehicle-composed battery (Eden attribute, default 4).
                    // A larger section simply places proportionally more guns and crews.
                    private _sectionSize = parseNumber ([_logic,"customArtillerySectionSize"] call MAINCLASS);
                    if (_sectionSize < 1) then { _sectionSize = 4; };

                    for "_b" from 1 to _artilleryFallback do {
                        private _artyClass = selectRandom _artyClasses;
                        private _gunsPlaced = 0;
                        for "_g" from 1 to _sectionSize do {
                            private _safePos = [];
                            private _safeDir = 0;

                            // One wide search across the whole area, rather than thirty six narrow ones
                            // creeping outwards ring by ring. Same ground, a fraction of the work, and the
                            // guns end up spread across it instead of sitting on rings. See the helper for
                            // what the old way was costing.
                            // The search covers the objective, however big: at a flat 200 m a large one's guns all
                            // stood near its centre.
                            private _res = [_position, 200 max _size, 10, _usedArtyPositions, 25, _debug] call ALiVE_fnc_findBatterySpawnPosition;

                            if (count _res >= 2) then {
                                _safePos = _res select 0;
                                _safeDir = _res select 1;
                            };

                            if (count _safePos > 0) then {
                                _usedArtyPositions pushBack _safePos;
                                private _crewedProfiles = [_artyClass, _artySide, _artyFaction, "PRIVATE", _safePos, _safeDir, false, _artyFaction] call ALIVE_fnc_createProfilesCrewedVehicle;
                                // The On unit spawn scripts go on the crew, as they do for the module's other groups.
                                [_crewedProfiles select 0, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                                [_crewedProfiles select 0, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                                _gunsPlaced = _gunsPlaced + 1;
                            };
                        };

                        if (_gunsPlaced > 0) then {
                            if (_debug) then {
                                ["CMP - Artillery battery composed from vehicles: %1 x %2 at grid %3", _gunsPlaced, _artyClass, mapGridPosition _position] call ALiVE_fnc_dump;
                            };
                        };
                    };
                };
            };

            _infantryGroups = _infantryGroups select {!((_x select 0) in ALiVE_PLACEMENT_GROUPBLACKLIST)};
            _motorizedGroups = _motorizedGroups select {!((_x select 0) in ALiVE_PLACEMENT_GROUPBLACKLIST)};
            _groups = _groups select {!((_x select 0) in ALiVE_PLACEMENT_GROUPBLACKLIST)};

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
            private _garrisonPatrolBehaviour = toUpper ([_logic, "garrisonPatrolBehaviour"] call MAINCLASS);
            // Preferred garrison buildings, still in the canonical Class=idx,idx;... string the
            // attribute holds. Read once here beside the other garrison settings and threaded to
            // each garrison command below; the seating code parses it. Empty means no override,
            // which is what a mission that never touches the setting gets.
            private _preferredGarrisonPositions = [_logic, "preferredGarrisonPositions"] call MAINCLASS;
            if (isNil "_preferredGarrisonPositions" || {!(_preferredGarrisonPositions isEqualType "")}) then { _preferredGarrisonPositions = "" };
            private _garrisonPatrolSpeed = toUpper ([_logic, "garrisonPatrolSpeed"] call MAINCLASS);
            private _guardDistance = parseNumber([_logic, "size"] call MAINCLASS);

            // Position and create groups
            private _groupCount = count _groups;
            private _totalCount = 0;

            // hoisted from the Field HQ block below: the guard pass needs to
            // know whether an auto Field HQ is still coming so it can defer
            // its groups until that composition exists to anchor them.
            // Strip the picker's [F:...] prefix before checking emptiness so
            // a saved-but-empty picker (just "[F:0,0,0,0]" with no classes)
            // correctly evaluates as empty.
            private _pickerCheck = _composition;
            if (typeName _pickerCheck == "STRING" && {count _pickerCheck > 3} && {(_pickerCheck select [0, 3]) == "[F:"}) then {
                private _closeIdx = _pickerCheck find "]";
                if (_closeIdx > 3) then { _pickerCheck = _pickerCheck select [_closeIdx + 1] };
            };
            private _pickerEmpty = (typeName _pickerCheck != "STRING") || {_pickerCheck == ""} || {_pickerCheck == "false"};

            // guard diversion into spawned compositions - camps otherwise
            // stand empty while their guards scatter around the module
            private _deferFieldHQGuards = _garrisonCompositions && _pickerEmpty && _createFieldHQ;
            private _deferredCompGuards = [];
            private _compGuardCount = 0;
            if (_garrisonCompositions && {_compositionSpawned} && {_guardProbabilityCount > 0}) then {
                // cap at guardCount - 1 so at least one garrison group always
                // holds the objective anchor - never send the whole guard
                // force to the composition. A lone single guard stays put
                _compGuardCount = ((1 max (ceil (_compositionSeats / 8))) min (_guardProbabilityCount - 1)) max 0;
                if (_debug) then {
                    ["CMP [%1] - Diverting %2 of %3 guard groups to composition %4 at %5 (est. seats %6)", _faction, _compGuardCount, _guardProbabilityCount, _compositionSpawnedClass, mapGridPosition _compositionSafePos, _compositionSeats] call ALiVE_fnc_dump;
                };
            };

            if(_groupCount > 0) then {
                // Guards
                if (count _infantryGroups > 0 && _guardProbabilityCount > 0) then {
                    if (_deferFieldHQGuards && _debug) then {
                        ["CMP [%1] - %2 guard groups deferred pending Field HQ placement", _faction, _guardProbabilityCount] call ALiVE_fnc_dump;
                    };
                    for "_i" from 0 to _guardProbabilityCount -1 do {
                        private _guardEntry = selectRandom _infantryGroups;
                        if (_deferFieldHQGuards) then {
                            // spawn after the Field HQ block - see the
                            // deferred-guard drain below it
                            _deferredCompGuards pushBack _guardEntry;
                        } else {
                            _guardEntry params ["_guardGroup", "_guardFaction"];
                            // composition-diverted iterations anchor at the
                            // composition with tight jitter and command radius
                            // The garrison searches the objective it was sent to hold,
                            // from its centre and sized to it, rather than a guard radius
                            // around wherever it landed within it. The scatter below uses
                            // the objective's own size, so a group could be put beyond
                            // reach of every building it was meant to man. The guard
                            // radius is still passed and stays the floor of the search.
                            // Size defaults to 300 here against a guard radius of 200, so
                            // a mission that touched neither now searches the objective it
                            // drew rather than two thirds of it (#1016).
                            private _guardAnchor = _position;
                            private _guardJitter = _guardDistance;
                            private _thisRadius = _guardRadius;
                            private _thisSearchCentre = _position;
                            private _thisObjectiveSize = _guardDistance;
                            private _pinStationary = false;
                            if (_i < _compGuardCount) then {
                                _guardAnchor = _compositionSafePos;
                                _guardJitter = _compositionEnvelope * 0.5;
                                _thisRadius = _compositionEnvelope max 50;
                                // The composition is the objective for this leg.
                                _thisSearchCentre = _compositionSafePos;
                                _thisObjectiveSize = _compositionEnvelope;
                                _pinStationary = true;
                            };
                            // Water-aware random pick - up to 10 retries to
                            // avoid dropping infantry in water when the module
                            // anchor is coastal. Fallback to the anchor.
                            private _guardPos = _guardAnchor;
                            for "_try" from 1 to 10 do {
                                private _candidate = [_guardAnchor, _guardJitter] call CBA_fnc_RandPos;
                                if (!surfaceIsWater _candidate) exitWith { _guardPos = _candidate };
                            };
                            // Still in the water: dry ground by the nearest land within the objective, if there is any,
                            // scattered no more than 50 m so the guards stay by the objective.
                            if (surfaceIsWater _guardPos) then {
                                private _spot = ((_guardJitter min 50) max 20) call _fnc_landSpot;
                                if !(_spot isEqualTo []) then { _guardPos = _spot };
                            };
                            // Still in the water means the objective has no dry ground: the group is
                            // left out and counted, as the main force's groups are.
                            _guards = if (surfaceIsWater _guardPos) then {
                                _guardsInWater = _guardsInWater + 1;
                                []
                            } else {
                                [_guardGroup, _guardPos, random(360), true, _guardFaction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig
                            };

                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then {
                                ["CMP [%1] - Placing Garrison Guards - %2", _guardFaction, _guardGroup] call ALiVE_fnc_dump;
                            };
                            // DEBUG -------------------------------------------------------------------------------------

                            // Garrison & Patrols instead of the static garrison.
                            {
                                if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                    [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[_thisRadius,"true",_thisSearchCentre,"",_guardProbabilityCount, _guardPatrolPercentage, _garrisonPatrolBehaviour, _garrisonPatrolSpeed, _preferredGarrisonPositions, true, _thisObjectiveSize]]] call ALIVE_fnc_profileEntity;
                                    if (_pinStationary) then {
                                        // composition garrisons hold their posts -
                                        // the same pin roadblock guards use
                                        private _pid = [_x,"profileID",""] call ALiVE_fnc_HashGet;
                                        if (_pid != "") then {
                                            if (isNil "ALIVE_profileStationary") then { ALIVE_profileStationary = [] call ALIVE_fnc_hashCreate; };
                                            [ALIVE_profileStationary, _pid, true] call ALIVE_fnc_hashSet;
                                        };
                                    };
                                };
                            } forEach _guards;
                            _countProfiles = _countProfiles + count _guards;
                        };
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

                // Helper: does a CfgGroups class hold a static weapon or an artillery piece anywhere in it?
                // A woken vehicle reserve only brings back the first vehicle it parked, so a group like that
                // is kept active instead: parked, its guns would never appear.
                private _fnc_groupHasGun = {
                    params ["_groupClass", "_groupFaction"];
                    private _config = [_groupFaction, _groupClass] call ALIVE_fnc_configGetGroup;
                    if (count _config == 0) exitWith { false };
                    ((("true" configClasses _config) findIf {
                        private _veh = getText (_x >> "vehicle");
                        _veh isKindOf "StaticWeapon" || {_veh isKindOf "LandVehicle" && {[_veh] call ALIVE_fnc_isArtillery}}
                    }) > -1)
                };

                // Groups with a gun are always placed active and take no share of Readiness (see
                // _gunForcedActive below), so the vehicle share is worked out over the other vehicle groups.
                _vehicleActiveCount = round ((_vehicleGroupCount - ({[_x select 0, _x select 1] call _fnc_groupHasGun} count (_groups select [_infantryGroupCount, _vehicleGroupCount]))) * _readinessLevel);

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

                private _groupsInWater = 0;
                for "_i" from 0 to (_groupCount - 1) do {
                    private ["_command","_radius","_garrisonPos","_position"];
                    private _groupEntry = _groups select _i;
                    _groupEntry params ["_group", "_groupFaction"];
                    private _isInfantry = _i < _infantryGroupCount;
                    private _isVehicle = !_isInfantry;

                    private _vehicleReserveClass = "";
                    // A group with a static weapon or an artillery piece anywhere in it is always placed active:
                    // parked empty, a gun is one nobody fires, and a woken reserve only brings back its first
                    // vehicle. It takes no share of Readiness and stays out of the reserve threshold's count
                    // below. Active groups still use the helper to find their parking.
                    private _gunForcedActive = _isVehicle && {[_group, _groupFaction] call _fnc_groupHasGun};
                    if (_isVehicle && {!_gunForcedActive} && {_vehicleActivePlacedCount >= _vehicleActiveCount}) then {
                        _vehicleReserveClass = [_group, _groupFaction] call _fnc_getGroupVehicleClass;
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
                                // Dry ground by the nearest land within the objective, as for the groups.
                                private _spot = 50 call _fnc_landSpot;
                                _vehiclePos = if (_spot isEqualTo []) then { (position _logic) getPos [50, random 360] } else { _spot };
                            };
                            if ((!isNil "ALiVE_mil_placement_custom_debug" && {ALiVE_mil_placement_custom_debug})
                                && {!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}}) then {
                                ["[ALiVE Reserve DEBUG] CMP-VEHICLE-RESERVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _groupFaction, _totalCount, _group, _vehicleReserveClass, _vehiclePos, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
                            };

                            private _groupFactionConfig = _groupFaction call ALiVE_fnc_configGetFactionClass;
                            private _groupFactionSideNumber = getNumber(_groupFactionConfig >> "side");
                            private _groupSide = _groupFactionSideNumber call ALIVE_fnc_sideNumberToText;
                            private _emptyProfiles = [_vehicleReserveClass, _groupSide, _groupFaction, _vehiclePos, _vehicleDir, false, _groupFaction] call ALIVE_fnc_createProfilesUnCrewedVehicle;
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
                            _reservePool pushBack ["VEHICLE", _group, _vehicleProfileID, _entityProfileID, _groupFaction, _onEachSpawn, _onEachSpawnOnce];
                            _countProfiles = _countProfiles + 2;
                        } else {
                            _reservePool pushBack ["INFANTRY", _group, _groupFaction, _onEachSpawn, _onEachSpawnOnce];
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
                            _activeVehClass = [_group, _groupFaction] call _fnc_getGroupVehicleClass;
                            if (_activeVehClass != "") then {
                                private _parking = [_activeVehClass, position _logic, _size] call _fnc_findVehicleParkingPos;
                                _position = _parking select 0;
                                _activeDir = _parking select 1;
                            } else {
                                // Within the guard radius and a quarter again: dividing by 0.25 put
                                // patrols up to five guard radii out, 1 km from a 200 m objective.
                                _position = [position _logic, random((_radius select 0) + ((_radius select 0)*0.25)), random(360)] call BIS_fnc_relPos;
                            };
                        } else {
                            if (_infantryActivePlacedCount < _garrisonCount) then {
                                _command = "ALIVE_fnc_garrison";
                                // garrison legs anchor at the spawned composition
                                // when there is one - its structures are the
                                // defensible positions this leg is meant to man.
                                // The search is centred there too and sized to it, so a
                                // man dropped at the edge of the composition still sees
                                // the whole of it rather than a guard radius around his
                                // own boots (#1016). Worked out before the command is
                                // built, because the command now carries it.
                                private _garrisonAnchor = if (_garrisonCompositions && {_compositionSpawned}) then { _compositionSafePos } else { position _logic };
                                private _garrisonAnchorSize = if (_garrisonCompositions && {_compositionSpawned}) then { _compositionEnvelope } else { _size };
                                _radius = [_guardRadius,"true",_garrisonAnchor,"",_guardProbabilityCount, _guardPatrolPercentage, _garrisonPatrolBehaviour, _garrisonPatrolSpeed, _preferredGarrisonPositions, true, _garrisonAnchorSize];
                                _position = [_garrisonAnchor, 30] call CBA_fnc_RandPos;
                            } else {
                                _command = "ALIVE_fnc_ambientMovement";
                                _radius = [_guardRadius,"SAFE",[0,0,0]];
                                _position = [position _logic, random((_radius select 0) + ((_radius select 0)*0.25)), random(360)] call BIS_fnc_relPos;
                            };
                        };

                        // A spot in the water gets ten more tries within the objective, which keeps
                        // groups spread out along a coast, then dry ground by the nearest land; a
                        // group with none is left out and counted below, not unseen. A parked
                        // vehicle's try also needs flat, open ground, as its parking search asks.
                        if (surfaceIsWater _position) then {
                            for "_try" from 1 to 10 do {
                                private _candidate = [position _logic, _size] call CBA_fnc_RandPos;
                                if (!surfaceIsWater _candidate && {_activeVehClass == "" || {count (_candidate isFlatEmpty [-1, -1, 0.4, 5, 0, false, objNull]) >= 2}}) exitWith { _position = _candidate };
                            };
                            if (surfaceIsWater _position) then {
                                private _spot = 50 call _fnc_landSpot;
                                if !(_spot isEqualTo []) then { _position = _spot };
                            };
                            if (surfaceIsWater _position) then { _groupsInWater = _groupsInWater + 1 };
                        };

                        if !(surfaceIsWater _position) then {
                            private _profiles = [_group, _position, _activeDir, false, _groupFaction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig;

                            if (_debug && {_group in _artilleryGroupNames}) then {
                                ["CMP - Artillery section %1 placed at grid %2 %3", _group, mapGridPosition _position, _position] call ALiVE_fnc_dump;
                            };

                            if (_isVehicle
                                && {!isNil "ALiVE_mil_placement_custom_debug" && {ALiVE_mil_placement_custom_debug}}
                                && {!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}}) then {
                                ["[ALiVE Reserve DEBUG] CMP-VEHICLE-ACTIVE faction=%1 totalCount=%2 group=%3 class=%4 pos=%5 elapsed=%6ms", _groupFaction, _totalCount, _group, _activeVehClass, _position, round ((diag_tickTime - _activeT0) * 1000)] call ALiVE_fnc_dump;
                            };

                            {
                                if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                                    [_x, "setActiveCommand", [_command,"spawn",_radius]] call ALIVE_fnc_profileEntity;
                                    [_x, "homeCluster", _cluster] call ALiVE_fnc_HashSet;
                                    private _profileID = [_x, "profileID"] call ALiVE_fnc_HashGet;
                                    if (!_gunForcedActive) then {
                                        private _activeIDs = [_cluster, "activeProfileIDs"] call ALiVE_fnc_HashGet;
                                        _activeIDs pushBack _profileID;
                                        [_cluster, "activeProfileIDs", _activeIDs] call ALiVE_fnc_HashSet;
                                    };
                                };
                                if (([_x,"type"] call ALiVE_fnc_HashGet) == "vehicle") then {
                                    [_x, "ALiVE_reserveLocked", _vehicleEmptyLocked] call ALiVE_fnc_HashSet;
                                };
                            } foreach _profiles;

                            _countProfiles = _countProfiles + count _profiles;
                            _totalCount = _totalCount + 1;
                            if (_isInfantry) then { _infantryActivePlacedCount = _infantryActivePlacedCount + 1 };
                            if (_isVehicle && {!_gunForcedActive}) then { _vehicleActivePlacedCount = _vehicleActivePlacedCount + 1 };

                            // Not for a group with a gun (see _gunForcedActive).
                            if (!_gunForcedActive) then {
                                private _spawned = [_cluster, "reserveActiveAtSpawn"] call ALiVE_fnc_hashGet;
                                [_cluster, "reserveActiveAtSpawn", _spawned + 1] call ALiVE_fnc_hashSet;
                            };
                        };
                    };
                };

                if (_groupsInWater > 0) then {
                    ["CMP - %1 of this objective's groups were not placed: their spot was in the water and there is no dry ground within %2 m of the module at %3.", _groupsInWater, _size, getPos _logic] call ALiVE_fnc_dump;
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
                ["CMP [%1] - Total profiles created: %2",_factions,_countProfiles] call ALiVE_fnc_dump;
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
            // (_pickerEmpty is computed above the guard block - the guard
            // deferral needs it before this block runs)

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

            // deferred guard spawn: the auto Field HQ (if any) now exists, so
            // the diverted share anchors at it and the remainder uses the
            // module anchor - total spawned always equals the configured
            // guard count on every branch. Spawn recipe kept in sync with
            // the guard loop above
            if (count _deferredCompGuards > 0) then {
                private _fieldHQSeats = 0;
                private _hqGuardCount = 0;
                if (_fieldHQSpawned) then {
                    // seat estimate - ring geometry mirrors x_lib
                    // fnc_groupGarrison, keep in sync
                    {
                        // Only the positions the seating loop will offer. It drops any reading as the
                                        // world origin, so counting them here sizes a garrison for seats it will refuse.
                                        private _bp = count ((_x buildingPos -1) select {!(_x isEqualTo [0,0,0])});
                        if (_bp > 0) then {
                            _fieldHQSeats = _fieldHQSeats + _bp;
                        } else {
                            (boundingBoxReal _x) params ["_bMin","_bMax"];
                            private _ringRadius = 0.5 * (((_bMax select 0) - (_bMin select 0)) max ((_bMax select 1) - (_bMin select 1))) + 1;
                            _fieldHQSeats = _fieldHQSeats + (2 max (floor ((2 * pi * _ringRadius) / 4)) min 6);
                        };
                    } forEach ([nearestObjects [_fieldHQSafePos, ALIVE_garrisonPositions select 1, _fieldHQEnvelope]] call ALIVE_fnc_garrisonAllowedBuildings);
                    {
                        _fieldHQSeats = _fieldHQSeats + ([_x] call ALIVE_fnc_vehicleCountEmptyPositions);
                    } forEach (nearestObjects [_fieldHQSafePos, ["StaticWeapon"], _fieldHQEnvelope]);
                    // same reservation: at least one deferred group holds the
                    // objective anchor rather than the Field HQ
                    _hqGuardCount = ((1 max (ceil (_fieldHQSeats / 8))) min ((count _deferredCompGuards) - 1)) max 0;
                };
                if (_debug) then {
                    ["CMP [%1] - Deferred guards: %2 to Field HQ at %3, %4 at module anchor", _faction, _hqGuardCount, mapGridPosition _fieldHQSafePos, (count _deferredCompGuards) - _hqGuardCount] call ALiVE_fnc_dump;
                };
                {
                    _x params ["_guardGroup", "_guardFaction"];
                    private _guardAnchor = _position;
                    private _guardJitter = _guardDistance;
                    private _thisRadius = _guardRadius;
                    // The module's own anchor. The placement loop above declares its own
                    // _position and writes only that, so the outer one still holds this,
                    // but naming it outright keeps the search centre and the scatter anchor
                    // visibly the same thing.
                    private _thisSearchCentre = position _logic;
                    private _thisObjectiveSize = _guardDistance;
                    private _pinStationary = false;
                    if (_forEachIndex < _hqGuardCount) then {
                        _guardAnchor = _fieldHQSafePos;
                        _guardJitter = _fieldHQEnvelope * 0.5;
                        _thisRadius = _fieldHQEnvelope max 50;
                        // The field HQ is the objective for these guards.
                        _thisSearchCentre = _fieldHQSafePos;
                        _thisObjectiveSize = _fieldHQEnvelope;
                        _pinStationary = true;
                    };
                    private _guardPos = _guardAnchor;
                    for "_try" from 1 to 10 do {
                        private _candidate = [_guardAnchor, _guardJitter] call CBA_fnc_RandPos;
                        if (!surfaceIsWater _candidate) exitWith { _guardPos = _candidate };
                    };
                    // Still in the water: dry ground by the nearest land within the objective, if there is any,
                    // scattered no more than 50 m so the guards stay by the objective.
                    if (surfaceIsWater _guardPos) then {
                        private _spot = ((_guardJitter min 50) max 20) call _fnc_landSpot;
                        if !(_spot isEqualTo []) then { _guardPos = _spot };
                    };
                    private _dGuards = if (surfaceIsWater _guardPos) then {
                        _guardsInWater = _guardsInWater + 1;
                        []
                    } else {
                        [_guardGroup, _guardPos, random(360), true, _guardFaction, false, false, "STEALTH", _onEachSpawn, _onEachSpawnOnce] call ALIVE_fnc_createProfilesFromGroupConfig
                    };
                    {
                        if (([_x,"type"] call ALiVE_fnc_HashGet) == "entity") then {
                            [_x, "setActiveCommand", ["ALIVE_fnc_garrison","spawn",[_thisRadius,"true",_thisSearchCentre,"",_guardProbabilityCount, _guardPatrolPercentage, _garrisonPatrolBehaviour, _garrisonPatrolSpeed, _preferredGarrisonPositions, true, _thisObjectiveSize]]] call ALIVE_fnc_profileEntity;
                            if (_pinStationary) then {
                                // composition garrisons hold their posts - the
                                // same pin roadblock guards use
                                private _pid = [_x,"profileID",""] call ALiVE_fnc_HashGet;
                                if (_pid != "") then {
                                    if (isNil "ALIVE_profileStationary") then { ALIVE_profileStationary = [] call ALIVE_fnc_hashCreate; };
                                    [ALIVE_profileStationary, _pid, true] call ALIVE_fnc_hashSet;
                                };
                            };
                        };
                    } forEach _dGuards;
                    _countProfiles = _countProfiles + count _dGuards;
                } forEach _deferredCompGuards;

                // the "Total profiles created" summary above printed before
                // this drain ran - re-state the true total so profile-count
                // comparisons against the RPT stay honest
                if (_debug) then {
                    ["CMP [%1] - Total profiles created (incl. deferred guards): %2", _faction, _countProfiles] call ALiVE_fnc_dump;
                };
            };

            if (_guardsInWater > 0) then {
                ["CMP - %1 of this objective's guard groups were not placed: their spot was in the water and there is no dry ground within %2 m of the module at %3.", _guardsInWater, _size, getPos _logic] call ALiVE_fnc_dump;
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
                                // Spawn via createProfileVehicle so the
                                // crate enters ALiVE's profile system
                                // (virtualises when no players nearby,
                                // persists across save/load). Mirrors the
                                // pattern used by AA placement and the #875
                                // objective objects helper. Falls back to
                                // direct createVehicle if profile creation
                                // returns nil. createCrew=false (supplies
                                // don't need crew).
                                private _supplyProfile = [_vehicleClass, _side, _faction, _position, _direction, false, _faction] call ALIVE_fnc_createProfileVehicle;
                                // Force upright via the profile-spawn path:
                                // slot 10 is objNull until the profile
                                // activates physically. Pass classname +
                                // position so the helper can wire the class
                                // init EH that fires on eventual spawn.
                                [objNull, _direction, _vehicleClass, _position] call ALIVE_fnc_registerForceUpright;
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


            // #875 - objective scenery objects (AA-style triplet:
            // count + behaviour + picker pool). Shared helper does
            // validator-checked spawn with neighbour-aware radius
            // capping and configurable distribution shape.
            private _objSizeStr = [_logic, "size"] call MAINCLASS;
            private _objSizeRadius = if (typeName _objSizeStr == "STRING" && {_objSizeStr != ""}) then { parseNumber _objSizeStr } else { 150 };
            if (_objSizeRadius <= 0) then { _objSizeRadius = 150 };
            private _objCountStr = [_logic, "objectiveObjectsCount"] call MAINCLASS;
            private _objCount = if (typeName _objCountStr == "STRING" && {_objCountStr != ""}) then { parseNumber _objCountStr } else { 0 };
            private _objBehaviour = [_logic, "objectiveObjectsBehaviour"] call MAINCLASS;
            private _objChanceStr = [_logic, "objectiveObjectsChance"] call MAINCLASS;
            private _objChance = if (typeName _objChanceStr == "STRING" && {_objChanceStr != ""}) then { (parseNumber _objChanceStr) max 0 min 100 } else { 100 };
            private _countObjectiveObjects = [_logic, _position, _objSizeRadius, _objCount, _objBehaviour, _debug, _objChance, _faction] call ALiVE_fnc_spawnObjectiveObjects;
            if (_debug) then {
                ["CMP [%1] - Objective objects placed: %2 of %3 (radius=%4 behaviour=%5)",
                    _faction, _countObjectiveObjects, _objCount, _objSizeRadius, _objBehaviour] call ALiVE_fnc_dump;
            };


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
                            if ((!isNil "ALiVE_mil_placement_custom_debug" && {ALiVE_mil_placement_custom_debug})
                                && {!isNil "ALiVE_vehicleSpawn_debug" && {ALiVE_vehicleSpawn_debug}}) then {
                                ["[ALiVE VehSpawn DEBUG] HELI-PLACEMENT module=mil_placement_custom faction=%1 class=%2 pos=%3 atoActive=%4 dice=%5 threshold=0.2 result=%6",
                                    _faction, _vehicleClass, _position, _atoActive, _diceRoll,
                                    if (_crewed) then {"CREWED"} else {"UNCREWED"}] call ALiVE_fnc_dump;
                            };

                            if !(_crewed) then {
                                [_vehicleClass,_side,_faction,_position,_direction,false,_faction] call ALIVE_fnc_createProfileVehicle;
                                _countProfiles = _countProfiles + 1;
                                _countUncrewedHelis =_countUncrewedHelis + 1;
                            }else{
                                private _crewedProfiles = [_vehicleClass,_side,_faction,"CAPTAIN",_position,_direction,false,_faction] call ALIVE_fnc_createProfilesCrewedVehicle;
                                // The On unit spawn scripts go on the crew, as they do for the module's other groups.
                                [_crewedProfiles select 0, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                                [_crewedProfiles select 0, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
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


            // AA placement.
            //
            // Single-objective: _aaCount slots distributed around _position
            // (the objective centre). Each slot validated via
            // findCompositionSpawnPosition mode="field" with envelope=10m so
            // AA lands on a clear non-runway / non-taxiway position. Field,
            // not ato: field keeps the building check that ato skips.
            // Crewed via createProfileVehicle - profile system populates
            // the gun / launcher crew and engine AI engages incoming
            // aircraft.
            //
            // Class resolution: picker CSV first, ALIVE_factionDefaultAA
            // hash fallback. Empty result skips with debug log.
            //
            // _aaBehaviour ("static" / "roaming") tracked on
            // ALIVE_aaProfileBehaviour hash keyed by profileID - read-side
            // is consumed by OPCOM for movement decisions.
            if (_aaCount > 0) then {
                private _resolved = [];
                if (_aaClasses != "") then {
                    {
                        private _t = _x;
                        while {count _t > 0 && {(_t select [0, 1]) == " "}} do { _t = _t select [1] };
                        while {count _t > 0 && {(_t select [count _t - 1, 1]) == " "}} do {
                            _t = _t select [0, count _t - 1];
                        };
                        if (_t != "") then { _resolved pushBackUnique _t };
                    } forEach ([_aaClasses, ","] call CBA_fnc_split);
                };
                if (count _resolved == 0 && {!isNil "ALIVE_factionDefaultAA"}) then {
                    // hashGet returns the engine's `any` sentinel (not nil
                    // and not "" - effectively undefined) when the key is
                    // missing. `private _hashVal = <missing-key result>`
                    // doesn't populate the local; guard with !isNil before
                    // reading.
                    // The faction's own list first, then, for a compiled faction, its config faction's,
                    // which is where the supplies and supports look.
                    private _hashVal = [ALIVE_factionDefaultAA, _faction] call ALIVE_fnc_hashGet;
                    if (isNil "_hashVal") then { _hashVal = [ALIVE_factionDefaultAA, [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction] call ALIVE_fnc_hashGet };
                    if (!isNil "_hashVal" && {typeName _hashVal == "ARRAY"}) then { _resolved = _hashVal };
                };

                if (count _resolved > 0) then {
                    private _aaPlaced = 0;
                    // Used-positions list - findCompositionSpawnPosition has
                    // no memory of prior calls so without an exclusion the
                    // validator returns near-identical positions on each
                    // call (best spot in a 50m radius is often a single
                    // dominant candidate). 30m minimum separation - labels
                    // are pushed to a 60m radial offset from objective
                    // centre with per-AA angular jitter, so AA-AA label
                    // spacing is independent of AA-AA physical spacing.
                    private _usedAAPositions = [];

                    // Neighbour-aware search radius cap. Default 150m
                    // gives the validator more room than the prior 50m.
                    // Cap at half the distance to the nearest other
                    // placement-class module so AA from this module never
                    // spawns into territory another module owns. Floor
                    // 50m for close-packed modules; ceiling 200m so a
                    // lone module on a giant map doesn't search a useless
                    // 1km radius.
                    // AA placement uses the user-configured Objective Size
                    // as its search ceiling. Helper shrinks for close
                    // sibling modules. Floor 50m so very small _size
                    // values still leave room for the static-weapon
                    // footprint + 30m AA-AA separation.
                    private _aaSearchRadius = [_logic, _position, _size, 50, _size] call ALIVE_fnc_neighbourAwareSearchCap;
                    if (_debug) then {
                        ["CMP [%1] - AA search radius=%2m (size=%3)", _faction, _aaSearchRadius, _size] call ALiVE_fnc_dump;
                    };
                    for "_i" from 1 to _aaCount do {
                        private _aaClass = selectRandom _resolved;
                        // mode="field" excludes buildings + helipads +
                        // runways/taxiways + ALL roads. Static AA
                        // shouldn't sit in hangars, on helipads, on
                        // runways, or on roads (block traffic + tip on
                        // cambered surfaces). field mode is the only one
                        // with the road-exclusion flag set.
                        //
                        // Angular sweep: build a ring-grid of candidate
                        // centres around _position (12 angles x 4 distance
                        // rings = 48 candidates), shuffle for run-to-run
                        // variation, then validate each in shuffled order
                        // until one passes the field-mode clear check AND
                        // the 30m separation check. Candidates beyond
                        // _aaSearchRadius (neighbour-aware cap) are
                        // skipped, so the sweep never infringes on an
                        // adjacent placement module's territory.
                        private _safePos = [];
                        private _safeDir = 0;
                        private _accepted = false;
                        private _candidates = [];
                        {
                            private _ring = _x;
                            for "_a" from 0 to 11 do {
                                private _angle = _a * 30 + (random 25);
                                _candidates pushBack [
                                    (_position select 0) + _ring * (sin _angle),
                                    (_position select 1) + _ring * (cos _angle),
                                    _position param [2, 0]
                                ];
                            };
                        } forEach [40, 70, 100, 130];
                        _candidates = _candidates call BIS_fnc_arrayShuffle;
                        {
                            if (_accepted) exitWith {};
                            private _cand = _x;
                            if ((_cand distance2D _position) <= _aaSearchRadius) then {
                                private _aaResult = [_cand, 20, 10, "field", random 360, _debug, 0.6] call ALiVE_fnc_findCompositionSpawnPosition;
                                if (count _aaResult >= 2) then {
                                    private _testPos = _aaResult select 0;
                                    // Post-validator road backstop - layered
                                    // check. nearRoads catches CfgRoads
                                    // objects; isOnRoad sampled in an 8-point
                                    // ring catches drivable surfaces that
                                    // aren't in CfgRoads (dirt paths / trails).
                                    private _onRoad = count (_testPos nearRoads 15) > 0;
                                    if (!_onRoad) then {
                                        for "_a" from 0 to 7 do {
                                            private _samplePt = _testPos getPos [6, _a * 45];
                                            if (isOnRoad _samplePt) exitWith { _onRoad = true; };
                                        };
                                    };
                                    private _tooClose = _onRoad;
                                    { if (_testPos distance2D _x < 30) exitWith { _tooClose = true } } forEach _usedAAPositions;
                                    if (!_tooClose) then {
                                        _safePos = _testPos;
                                        _safeDir = _aaResult select 1;
                                        _accepted = true;
                                    };
                                };
                            };
                        } forEach _candidates;
                        if (_accepted) then {
                            _usedAAPositions pushBack _safePos;
                            // Crew-bearing classes (POOK SAM SA-19 / SA-22
                            // family - kindOf Tank with `crew` config -
                            // and any non-StaticWeapon mod AA vehicle)
                            // need explicit crew profiles. createProfileVehicle
                            // alone registers the vehicle without crew, so
                            // the spawned entity has empty seats and the
                            // gun never engages. createProfilesCrewedVehicle
                            // adds the crew unit profiles + vehicle
                            // assignment so gunner / loader spawn alongside.
                            private _aaCrewClass = getText (configFile >> "CfgVehicles" >> _aaClass >> "crew");
                            private _aaProfile = if (_aaCrewClass != "") then {
                                private _profiles = [_aaClass, _side, _faction, "PRIVATE", _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfilesCrewedVehicle;
                                // The On unit spawn scripts go on the crew, as they do for the module's other groups.
                                [_profiles select 0, "onEachSpawn", _onEachSpawn] call ALIVE_fnc_profileEntity;
                                [_profiles select 0, "onEachSpawnOnce", _onEachSpawnOnce] call ALIVE_fnc_profileEntity;
                                _profiles select 1
                            } else {
                                [_aaClass, _side, _faction, _safePos, _safeDir, false, _faction] call ALIVE_fnc_createProfileVehicle
                            };
                            if (!isNil "_aaProfile") then {
                                private _profileID = [_aaProfile, "profileID"] call ALIVE_fnc_profileVehicle;
                                if (typeName _profileID == "STRING" && {_profileID != ""}) then {
                                    if (isNil "ALIVE_aaProfileBehaviour") then {
                                        ALIVE_aaProfileBehaviour = [] call ALIVE_fnc_hashCreate;
                                    };
                                    [ALIVE_aaProfileBehaviour, _profileID, _aaBehaviour] call ALIVE_fnc_hashSet;
                                };
                                // Force upright when behaviour is static.
                                // Helper records position-grid key in a
                                // registry + class init EH so re-activations
                                // after virtualisation re-apply setVectorUp
                                // (the profile schema only stores pos+dir,
                                // not vectorUp - so re-spawn would tilt
                                // again without the persistent registry).
                                // Roaming AA skipped - vehicles need terrain
                                // alignment for normal physics.
                                if (_aaBehaviour == "static") then {
                                    // Profile-spawn path: slot 10 is objNull
                                    // until the profile activates physically
                                    // (player proximity). Pass classname +
                                    // position so the helper can wire the
                                    // class init EH that fires when the
                                    // engine eventually creates the entity.
                                    [objNull, _safeDir, _aaClass, _safePos] call ALIVE_fnc_registerForceUpright;
                                };
                            };
                            _aaPlaced = _aaPlaced + 1;

                            if (_debug) then {
                                // Anchor dot at actual spawn position +
                                // labeled marker at radial offset away
                                // from objective centre. Pushes the AA
                                // label clear of the cluster's own label
                                // (e.g. "FACTION|MIL|size|prio") which
                                // renders at the objective anchor. Per-
                                // index angular jitter fans labels of co-
                                // radial AA out to different angles.
                                private _aaLabel = format ["AA #%1 [%2]", _aaPlaced, _aaBehaviour];
                                private _dx = (_safePos select 0) - (_position select 0);
                                private _dy = (_safePos select 1) - (_position select 1);
                                private _norm = sqrt (_dx * _dx + _dy * _dy);
                                if (_norm < 1) then { _dx = 1; _dy = 0; _norm = 1 };
                                _dx = _dx / _norm; _dy = _dy / _norm;
                                private _jitterAngles = [0, 30, -30, 60, -60, 90, -90];
                                private _jit = _jitterAngles select ((_aaPlaced - 1) mod (count _jitterAngles));
                                private _cosJ = cos _jit; private _sinJ = sin _jit;
                                private _rdx = _cosJ * _dx - _sinJ * _dy;
                                private _rdy = _sinJ * _dx + _cosJ * _dy;
                                private _labelPos = [(_safePos select 0) + _rdx * 60, (_safePos select 1) + _rdy * 60, _safePos param [2, 0]];
                                [_safePos, 1, "", "ColorOrange"] call ALIVE_fnc_placeDebugMarker;
                                [_labelPos, 3, _aaLabel, "ColorOrange"] call ALIVE_fnc_placeDebugMarker;
                            };
                        };
                    };

                    if (_debug) then {
                        ["CMP [%1] - AA units placed: %2 of %3 (behaviour=%4, sources=%5)",
                            _faction, _aaPlaced, _aaCount, _aaBehaviour,
                            if (_aaClasses != "") then {"picker"} else {"factionDefault"}
                        ] call ALiVE_fnc_dump;
                    };
                } else {
                    if (_debug) then {
                        ["CMP [%1] - AA spawn skipped: picker empty AND no ALIVE_factionDefaultAA entry for this faction", _faction] call ALiVE_fnc_dump;
                    };
                };
            };


            [_factions] call ALiVE_fnc_initFindVehicleTypeCache;

            // set module as started
            _logic setVariable ["startupComplete", true];

        };

    };

};

TRACE_1("CMP - output",_result);

_result;
