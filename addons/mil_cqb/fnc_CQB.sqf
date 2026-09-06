#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(CQB);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CQB
Description:
XXXXXXXXXX

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled
Boolean - enabled - Enabled or disable module

Parameters:
none

Description:
CQB Module! Detailed description to follow

Examples:
[_logic, "factions", ["OPF_F"] call ALiVE_fnc_CQB;
[_logic, "houses", _nonStrategicHouses] call ALiVE_fnc_CQB;
[_logic, "spawnDistance", 500] call ALiVE_fnc_CQB;
[_logic, "active", true] call ALiVE_fnc_CQB;

See Also:
- <ALIVE_fnc_CQBInit>

Author:
Wolffy, Highhead
Jman
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_CQB

#define MTEMPLATE "ALiVE_CQB_%1"
#define GTEMPLATE "ALiVE_CQB_g_%1"
#define STEMPLATE "ALiVE_CQB_s_%1"
#define DEFAULT_FACTIONS ["OPF_F"]
#define DEFAULT_BLACKLIST []
#define DEFAULT_WHITELIST []
#define DEFAULT_STATICWEAPONS ["B_HMG_01_high_F","O_Mortar_01_F","O_HMG_01_high_F"]
#define SUBGRID_SIZE 10

private ["_logic","_operation","_args"];

PARAMS_1(_logic);
DEFAULT_PARAM(1,_operation,"");
DEFAULT_PARAM(2,_args,nil);

/* Debug Code */
#ifdef DEBUG_MODE_FULL
    #define TRACE_TIME(comp,varArr) \
        _traceCount = _traceCount + 1; \
        _tdString = format["%1 [TRACE %3 | TIME %2 | BENCH %4]", comp, diag_tickTime, _traceCount, (diag_tickTime - _intTime)]; \
        {_tdString = _tdString + "; " + _x + "=" + format["%1", (call compile _x)]} forEach varArr; \
        diag_log text _tdString; \
        _intTime = diag_tickTime

        private ["_intTime", "_traceCount", "_tdString"];
        _intTime = diag_tickTime;
        _traceCount = 0;
#else
    #define TRACE_TIME(comp,varArr)
#endif

PROFILE_SCOPE(OPERATION,_operation)

switch(_operation) do {
        default {
            private["_err"];
            _err = format["%1 does not support %2 operation", _logic, _operation];
            ERROR_WITH_TITLE(str _logic,_err);
        };
        case "create": {
                if (isServer) then {
                    // Ensure only one module is used
                    if !(isNil QMOD(CQB)) then {
                        _logic = MOD(CQB);
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_PLAYERTAGS_ERROR1");
                    } else {
                        _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];
                        MOD(CQB) = _logic;
                    };

                    //Push to clients
                    PublicVariable QMOD(CQB);
                };

                TRACE_1("Waiting for object to be ready",true);

                waituntil {!isnil QMOD(CQB)};

                _logic = MOD(CQB);

                TRACE_1("Creating class on all localities",true);

                // initialise module game logic on all localities
                _logic setVariable ["super", SUPERCLASS];
                _logic setVariable ["class", MAINCLASS];

                _args = _logic;
        };
        case "init": {

            // Out of sight first, before anything else in here.
            //
            // Everything below waits on the line further down for the server to say the module
            // exists, and a machine that is not the server cannot answer that itself. On a
            // dedicated server that wait was measured at 78 seconds, against a briefing map that
            // is gone long before, and the briefing map is the only time anyone sees these areas.
            // So the hide was landing while the player watched the loading screen, and by the
            // time the map could be opened again there was nothing left to notice.
            //
            // Nothing here needs the module to be ready. Both settings arrive with it when the
            // mission loads, and reading them through the module only turns the comma separated
            // text into the list of marker names.
            if (hasInterface) then {
                private _blacklistAreas = [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call ALiVE_fnc_CQB;
                private _whitelistAreas = [_logic, "whitelist", _logic getVariable ["whitelist", DEFAULT_WHITELIST]] call ALiVE_fnc_CQB;
                if (_blacklistAreas isEqualType []) then {{_x setMarkerAlpha 0} forEach _blacklistAreas};
                if (_whitelistAreas isEqualType []) then {{_x setMarkerAlpha 0} forEach _whitelistAreas};
            };

            if (isServer) then {
                //if server, and no CQB master logic present yet, then initialise CQB master game logic on server and inform all clients
                if (isnil QMOD(CQB)) then {
                    MOD(CQB) = _logic;
                    MOD(CQB) setVariable ["super", SUPERCLASS];
                    MOD(CQB) setVariable ["class", ALIVE_fnc_CQB];
                    publicVariable QMOD(CQB);
                };
            };

            waituntil {!isnil QMOD(CQB)};

            //Only one init per instance is allowed
            if !(isnil {_logic getVariable "initGlobal"}) exitwith {["MIL CQB - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_dump};

            //Start init
            _logic setVariable ["initGlobal", false];

            //Initialise module game logic on all localities (clientside spawn)
            _logic setVariable ["super", SUPERCLASS];
            _logic setVariable ["class", MAINCLASS];

            TRACE_1("After module init",_logic);

            //Init further mandatory params on all localities
            private _debug = _logic getvariable ["CQB_debug_setting","false"];
            if (_debug isequaltype "") then {_debug = (_debug == "true")};
            _logic setVariable ["debug", _debug];

            private _CQB_spawn = _logic getvariable ["CQB_spawn_setting", "0.01"];
            if (_CQB_spawn isequaltype "") then {_CQB_spawn = call compile _CQB_spawn};
            //// For backward compatibility, remove after some months ////
            //// Please update the list when this code is read, but not changed
            ////	- 6/2/2019
            if (_CQB_spawn >= 1) then {_CQB_spawn = _CQB_spawn / 100};
            /////////////////////////////////////////////////////////////
            _logic setVariable ["CQB_spawn", _CQB_spawn];

            private _CQB_density = _logic getvariable ["CQB_DENSITY","99999"];
            if (_CQB_density isequaltype "") then {_CQB_density = call compile _CQB_density};
            _logic setVariable ["CQB_DENSITY", _CQB_density];

            private _CQB_patrolChance = _logic getvariable ["CQB_patrol_chance","0.30"];
            if (_CQB_patrolChance isequaltype "") then {_CQB_patrolChance = call compile _CQB_patrolChance};
            _logic setVariable ["CQB_patrol_chance", _CQB_patrolChance];

            private _CQB_patrolMinDist = _logic getvariable ["CQB_patrol_mindist","50"];
            if (_CQB_patrolMinDist isequaltype "") then {_CQB_patrolMinDist = call compile _CQB_patrolMinDist};
            _logic setVariable ["CQB_patrol_mindist", _CQB_patrolMinDist];

            private _CQB_patrolMaxDist = _logic getvariable ["CQB_patrol_maxist","100"];
            if (_CQB_patrolMaxDist isequaltype "") then {_CQB_patrolMaxDist = call compile _CQB_patrolMaxDist};
            _logic setVariable ["CQB_patrol_maxist", _CQB_patrolMaxDist];

            private _CQB_patrolSearchChance = _logic getvariable ["CQB_patrol_searchchance","0.30"];
            if (_CQB_patrolSearchChance isequaltype "") then {_CQB_patrolSearchChance = call compile _CQB_patrolSearchChance};
            _logic setVariable ["CQB_patrol_searchchance", _CQB_patrolSearchChance];

            private _CQB_patrolMinWaitTime = _logic getvariable ["CQB_patrol_minwaittime","0"];
            if (_CQB_patrolMinWaitTime isequaltype "") then {_CQB_patrolMinWaitTime = call compile _CQB_patrolMinWaitTime};
            _logic setVariable ["CQB_patrol_minwaittime", _CQB_patrolMinWaitTime];

            private _CQB_patrolMidWaitTime = _logic getvariable ["CQB_patrol_midwaittime","15"];
            if (_CQB_patrolMidWaitTime isequaltype "") then {_CQB_patrolMidWaitTime = call compile _CQB_patrolMidWaitTime};
            _logic setVariable ["CQB_patrol_midwaittime", _CQB_patrolMidWaitTime];

            private _CQB_patrolMaxWaitTime = _logic getvariable ["CQB_patrol_maxwaittime","30"];
            if (_CQB_patrolMaxWaitTime isequaltype "") then {_CQB_patrolMaxWaitTime = call compile _CQB_patrolMaxWaitTime};
            _logic setVariable ["CQB_patrol_maxwaittime", _CQB_patrolMaxWaitTime];

            // Patrol disposition for non-combat garrison patrols (Dutch request,
            // 2026-05). Stored as uppercase behaviour/speed tokens consumed by
            // the taskPatrol branch below and HousePatrol.fsm. Enemy-contact
            // escalation in the FSM stays hardwired so QRF reaction is intact.
            private _CQB_patrolBehaviour = _logic getvariable ["CQB_patrol_behaviour","SAFE"];
            if (_CQB_patrolBehaviour isequaltype "") then {_CQB_patrolBehaviour = toUpper _CQB_patrolBehaviour};
            _logic setVariable ["CQB_patrol_behaviour", _CQB_patrolBehaviour];

            private _CQB_patrolSpeed = _logic getvariable ["CQB_patrol_speed","LIMITED"];
            if (_CQB_patrolSpeed isequaltype "") then {_CQB_patrolSpeed = toUpper _CQB_patrolSpeed};
            _logic setVariable ["CQB_patrol_speed", _CQB_patrolSpeed];

            private _spawn = _logic getvariable ["CQB_spawndistance","700"];
            if (_spawn isequaltype "") then {_spawn = call compile _spawn};
            _logic setVariable ["spawnDistance", _spawn];

            private _spawnStatic = _logic getvariable ["CQB_spawndistanceStatic","1200"];
            if (_spawnStatic isequaltype "") then {_spawnStatic = call compile _spawnStatic};
            _logic setVariable ["spawnDistanceStatic", _spawnStatic];

            private _spawnHeli = _logic getvariable ["CQB_spawndistanceHeli","0"];
            if (_spawnHeli isequaltype "") then {_spawnHeli = call compile _spawnHeli};
            _logic setVariable ["spawnDistanceHeli", _spawnHeli];

            private _spawnJet = _logic getvariable ["CQB_spawndistanceJet","0"];
            if (_spawnJet isequaltype "") then {_spawnJet = call compile _spawnJet};
            _logic setVariable ["spawnDistanceJet", _spawnJet];

            private _amount = _logic getvariable ["CQB_amount","2"];
            if (_amount isequaltype "") then {_amount = call compile _amount};
            _logic setVariable ["CQB_amount", _amount];

            private _staticWeaponsIntensity = _logic getvariable ["CQB_staticWeapons","0"];
            // Guard the empty string: missions saved with the old empty attribute
            // default store "" and `call compile ""` yields nil, erroring both
            // setVariable copies below on every init
            if (_staticWeaponsIntensity isequaltype "") then {
                _staticWeaponsIntensity = if (_staticWeaponsIntensity == "") then {0} else {call compile _staticWeaponsIntensity};
            };
            _logic setVariable ["CQB_staticWeapons", _staticWeaponsIntensity];

            private _staticWeaponsClassnames = _logic getvariable ["CQB_staticWeaponsClassnames","B_HMG_01_high_F,O_Mortar_01_F,O_HMG_01_high_F"];
			_staticWeaponsClassnames = _staticWeaponsClassnames call ALiVE_fnc_stringListToArray;
			if (count _staticWeaponsClassnames == 0) then { _staticWeaponsClassnames = DEFAULT_STATICWEAPONS };
            _logic setVariable ["CQB_staticWeaponsClassnames", _staticWeaponsClassnames];

            private _type = _logic getvariable ["CQB_TYPE","regular"];
            _logic setVariable ["type", _type];

            private _locality = _logic getvariable ["CQB_locality_setting","server"];
            _logic setVariable ["locality", _locality];

            // Union multi-select list + manual override field; dedup and drop empties
            private _factionsRaw    = _logic getVariable ["CQB_FACTIONS",       []];
            private _factionsManual = _logic getVariable ["CQB_FACTIONS_manual", ""];
            // Accepts ARRAY, bare CSV "a,b,c", or SQF array literal STRING
            // '["a","b"]' (canonical form emitted by fnc_edenFactionChoiceMultiSave).
            // Same strip-then-split pattern mil_opcom's `case "convert"` uses.
            private _factionsArr = if (typeName _factionsRaw == "ARRAY") then {
                +_factionsRaw
            } else {
                if (_factionsRaw == "") then { [] } else {
                    private _stripped = [_factionsRaw, " ", ""] call CBA_fnc_replace;
                    _stripped = [_stripped, "[", ""] call CBA_fnc_replace;
                    _stripped = [_stripped, "]", ""] call CBA_fnc_replace;
                    _stripped = [_stripped, """", ""] call CBA_fnc_replace;
                    [_stripped, ","] call CBA_fnc_split
                }
            };
            private _manualArr = if (_factionsManual == "") then { [] } else {
                private _strippedManual = [_factionsManual, " ", ""] call CBA_fnc_replace;
                _strippedManual = [_strippedManual, "[", ""] call CBA_fnc_replace;
                _strippedManual = [_strippedManual, "]", ""] call CBA_fnc_replace;
                _strippedManual = [_strippedManual, """", ""] call CBA_fnc_replace;
                [_strippedManual, ","] call CBA_fnc_split
            };
            private _merged = [];
            {
                if (typeName _x == "STRING" && {_x != ""} && {_x != "NONE"} && {!(_x in _merged)}) then {
                    _merged pushBack _x;
                };
            } forEach (_factionsArr + _manualArr);
            if (count _merged == 0) then { _merged = DEFAULT_FACTIONS; };
            _factions = [_logic, "factions", _merged] call ALiVE_fnc_CQB;

            private _useDominantFaction = _logic getvariable ["CQB_UseDominantFaction","true"];
            if (_useDominantFaction isEqualType "") then {_useDominantFaction = (_useDominantFaction == "true")};
            _logic setVariable ["CQB_UseDominantFaction", _useDominantFaction];

            private _CQB_onEachSpawn = _logic getvariable ["onEachSpawn", ""];
            _logic setVariable ["onEachSpawn", _CQB_onEachSpawn];

            private _CQB_onEachSpawnOnce = _logic getvariable ["onEachSpawnOnce", true];
            if (_CQB_onEachSpawnOnce isEqualType "") then {_CQB_onEachSpawnOnce = (_CQB_onEachSpawnOnce == "true")};
            _logic setVariable ["onEachSpawnOnce", _CQB_onEachSpawnOnce];

            private _CQB_Locations = _logic getvariable ["CQB_LOCATIONTYPE","towns"];

            if (isnil QMOD(smoothSpawn)) then {MOD(smoothSpawn) = 0.3};

            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call ALiVE_fnc_CQB;
            [_logic, "whitelist", _logic getVariable ["whitelist", DEFAULT_WHITELIST]] call ALiVE_fnc_CQB;

            // The areas went out of sight at the top of this case, ahead of the wait for the
            // server. The two reads above stay because the module uses both settings from here on.

            /*
            MODEL - no visual just reference data
            - server side object only
            - enabled/disabled
            */

            /*
            // Ensure only one module is used on server
            if (isServer && {!(isNil QMOD(CQB))}) exitWith {
                    ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_CQB_ERROR1");
            };
            */

            if (isServer) then {
                MOD(CQB) setVariable ["startupComplete", false,true];

                // Where the startup time actually goes. CQB is the single largest cost in
                // ALiVE startup on a large mission, measured between 243 and 353 seconds of a
                // 320 to 430 second wait, and it says nothing at all between its start and its
                // finish, so the log cannot show which stage is responsible.
                //
                // The TRACE_TIME markers already sat at these points but expand to nothing
                // unless DEBUG_MODE_FULL is set when the addon is built, so they have never
                // reported anything from a normal build.
                //
                // Counts are carried alongside the times because several stages here grow an
                // array with + in a loop, which copies everything gathered so far on every
                // pass. Times alone cannot tell that apart from work that is simply large.
                //
                // Gated on its own switch rather than on the module debug attribute, which would
                // have been the obvious choice and is wrong here. Turning CQB debug on makes the
                // init call below draw a map marker for every house the module holds, thousands of
                // them, each broadcast to every machine and each costing a sector lookup, and it
                // does that inside the stretch being measured. Measuring would have changed the
                // measurement, and inflated it.
                //
                // Set ALiVE_CQB_STARTUP_DIAG to true on the server before the mission starts to get
                // these lines. Off by default, so a normal run pays nothing.
                //
                // The clock is updated whether or not the line is written, so switching it on part
                // way through still gives truthful stage times rather than one enormous first
                // reading.
                private _cqbDiagT0 = diag_tickTime;
                private _cqbDiagLast = _cqbDiagT0;
                private _fnc_cqbDiagMark = {
                    params ["_stage", ["_detail", ""]];
                    private _now = diag_tickTime;
                    if (!isNil "ALiVE_CQB_STARTUP_DIAG" && {ALiVE_CQB_STARTUP_DIAG}) then {
                        ["DIAG-STRIP CQB DIAG %1 - %2: %3s for this stage, %4s since init began%5",
                            _type, _stage,
                            (round ((_now - _cqbDiagLast) * 100)) / 100,
                            (round ((_now - _cqbDiagT0) * 100)) / 100,
                            if (_detail == "") then {""} else {"   " + _detail}] call ALiVE_fnc_dump;
                    };
                    _cqbDiagLast = _now;
                };

                //Set instance on main module
                MOD(CQB) setVariable ["instances",(MOD(CQB) getVariable ["instances",[]]) + [_logic],true];

                //Create ID
                _id = (format["CQB_%1_%2",_type,count (MOD(CQB) getVariable ["instances",[]])]);
                call compile (format["%1 = _logic;",_id]);

                call ALiVE_fnc_staticDataHandler;

                private ["_strategicTypes","_UnitsBlackList","_data","_success", "_units_blacklist_module"];

                _strategicTypes = GVAR(STRATEGICHOUSES);
                _UnitsBlackList = GVAR(UNITBLACKLIST);

                // CQB module blacklisted units
                _units_blacklist_module = _logic getvariable ["units_blacklist",""];
                _units_blacklist_module = [_units_blacklist_module, " ", ""] call CBA_fnc_replace;
                _units_blacklist_module = [_units_blacklist_module, "[", ""] call CBA_fnc_replace;
                _units_blacklist_module = [_units_blacklist_module, "]", ""] call CBA_fnc_replace;
                _units_blacklist_module = [_units_blacklist_module, """", ""] call CBA_fnc_replace;
                // + instead of append makes _UnitsBlackList local- so unique to each module
                // this is desired behaviour
                _UnitsBlackList = _UnitsBlackList + ([_units_blacklist_module, ","] call CBA_fnc_split);

                //Create Collection

                TRACE_TIME(QUOTE(COMPONENT),[]); // 1
                ["setup"] call _fnc_cqbDiagMark;

                private ["_collection","_center", "_radius","_objectives"];

                _center = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
                _radius = (((_center select 0) max (_center select 1)) * sqrt(2))*2;
                _collection = [];
                _objectives = [];

                if (count synchronizedObjects _logic > 0) then {
                    for "_i" from 0 to ((count synchronizedObjects _logic) - 1) do {

                        _mod = (synchronizedObjects _logic) select _i;

                        if ((typeof _mod) in ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_civ_placement_custom"]) then {
                            waituntil {_mod getVariable ["startupComplete", false]};
                            [format ["waited for %1", typeOf _mod]] call _fnc_cqbDiagMark;

                            _obj = [_mod,"objectives",objNull,[]] call ALIVE_fnc_OOsimpleOperation;
                            _objectives = _objectives + _obj;

                            {_collection pushback [([_x,"center"] call ALiVE_fnc_HashGet), ([_x,"size"] call ALiVE_fnc_HashGet)]} foreach _obj;

                            ["CQB Houses loaded from MIL/CIV Placement module!"] call ALiVE_fnc_dump;
                        };

                        if (typeof _mod == "ALiVE_mil_OPCOM") then {
                            _collection = [[_center, _radius]];

                            _faction1 = _mod getvariable ["faction1","OPF_F"];
                            _faction2 = _mod getvariable ["faction2","NONE"];
                            _faction3 = _mod getvariable ["faction3","NONE"];
                            _faction4 = _mod getvariable ["faction4","NONE"];
                            _factions = [_mod getvariable ["factions",[]]] call ALiVE_fnc_parseArrayFromString;

                            if ((count _factions) == 0) then {{if (!(_x == "NONE") && {!(_x in _factions)}) then {_factions pushBack _x}} foreach [_faction1,_faction2,_faction3,_faction4]};

                            _factions = [_logic,"factions",_factions] call ALiVE_fnc_CQB;
                            _logic setVariable ["CQB_UseDominantFaction", false];

                            ["CQB Houses prepared for use with OPCOM Insurgency!"] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    _center = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
                    _radius = (((_center select 0) max (_center select 1)) * sqrt(2))*2;

                    switch (_CQB_Locations) do {
                        case ("towns") : {
                            _objectives = nearestLocations [_center, ["NameCityCapital","NameCity","NameVillage","NameLocal","Hill"], _radius];
                            { // forEach
                                private ["_size"];
                                _size = size _x;
                                _collection pushback [(getPos _x), ((_size select 0) max (_size select 1))];
                            } foreach _objectives;
                        };
                        case ("all") : {
                            _collection pushback [_center, _radius];
                        };
                        default {};
                    };

                    ["CQB Houses loaded from map!"] call ALiVE_fnc_dump;
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 2
                ["built the area list", format ["%1 areas, %2 objectives",
                    count _collection, count _objectives]] call _fnc_cqbDiagMark;

                private ["_houses","_total","_result","_debugColor"];

                //Get all enterable houses
                _houses = []; {_houses = _houses + ([_x select 0, _x select 1] call ALiVE_fnc_getEnterableHouses)} foreach _collection;

                TRACE_TIME(QUOTE(COMPONENT),[]); // 3
                ["gathered enterable houses", format ["%1 houses from %2 areas",
                    count _houses, count _collection]] call _fnc_cqbDiagMark;

                _total = [_houses, _strategicTypes, _CQB_density, _CQB_spawn, [_logic, "blacklist"] call ALiVE_fnc_CQB, [_logic, "whitelist"] call ALiVE_fnc_CQB] call ALiVE_fnc_CQBsortStrategicHouses;

                switch (_type) do {
                    case ("regular") : {_result = _total select 1; _debugColor = "ColorGreen"};
                    case ("strategic") : {_result = _total select 0; _debugColor = "ColorRed"};
                    default {_result = _total select 1; _debugColor = "ColorGreen"};
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 4
                ["sorted strategic houses", format ["%1 kept of %2", count _result, count _houses]]
                    call _fnc_cqbDiagMark;

                //set default values on main CQB instance
                [MOD(CQB), "allHouses", (MOD(CQB) getvariable ["allHouses",[]]) + _result] call ALiVE_fnc_CQB;
                [MOD(CQB), "allFactions", (MOD(CQB) getvariable ["allFactions",[]]) + _factions] call ALiVE_fnc_CQB;

                TRACE_TIME(QUOTE(COMPONENT),[]); // 5
                ["merged into the main instance", format ["%1 houses held in total",
                    count (MOD(CQB) getVariable ["allHouses",[]])]] call _fnc_cqbDiagMark;

                // Create CQB instance
                _logic setVariable ["class", ALiVE_fnc_CQB];
                _logic setVariable ["id",_id,true];
                _logic setVariable ["instancetype",_type,true];
                _logic setVariable ["UnitsBlackList",_UnitsBlackList,true];
                _logic setVariable ["locality",_locality,true];
                _logic setVariable ["amount",_amount,true];
                _logic setVariable ["debugColor",_debugColor,true];
                _logic setVariable ["debugPrefix",_type,true];
                _logic setVariable ["staticWeaponsIntensity",_staticWeaponsIntensity,true];
				_logic setVariable ["staticWeaponsClassnames",_staticWeaponsClassnames,true];
                _logic setVariable ["cleared", []];
                [_logic, "houses",_result] call ALiVE_fnc_CQB;
                [_logic, "factions",_factions] call ALiVE_fnc_CQB;
                [_logic, "spawnDistance",_spawn] call ALiVE_fnc_CQB;
                [_logic, "spawnDistanceStatic", _spawnStatic] call ALiVE_fnc_CQB;
                [_logic, "spawnDistanceHeli",_spawnHeli] call ALiVE_fnc_CQB;
                [_logic, "spawnDistanceJet",_spawnJet] call ALiVE_fnc_CQB;
                [_logic, "debug",_debug] call ALiVE_fnc_CQB;

                TRACE_TIME(QUOTE(COMPONENT),[]); // 6
                ["applied settings"] call _fnc_cqbDiagMark;

                //Check if there is data in DB
                _data = false call ALiVE_fnc_CQBLoadData;
                _success = (!(isnil "_data") && {typeName _data == "ARRAY"} && {count _data > 2});

                //if data was loaded from DB before then overwrite CQB state
                if (_success) then {
                    {
                        private ["_cqb_logic"];
                        _cqb_logic = _x;

                        {
                            [_cqb_logic,"state",_x] call ALiVE_fnc_CQB
                        } foreach (_data select 2);
                    } foreach (MOD(CQB) getVariable ["instances",[]]);

                    ["CQB DATA loaded from DB! CQB states were reset!"] call ALiVE_fnc_dump;
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 7
                ["loaded saved state", if (_success) then {"from a save"} else {"nothing saved"}]
                    call _fnc_cqbDiagMark;

                /*
                CONTROLLER  - coordination
                - Start CQB Controller on Server
                */

                // Initial positions and any persisted state are now populated.
                [_logic, "positionGrid"] call ALiVE_fnc_CQB;
                [_logic, "GarbageCollecting", true] call ALiVE_fnc_CQB;
                [_logic, "active", true] call ALiVE_fnc_CQB;

                //Indicate startup is done on server for that instance
                ["started the controller"] call _fnc_cqbDiagMark;

                [_factions] call ALiVE_fnc_initFindVehicleTypeCache;

                _logic setVariable ["init",true,true];
                _logic setVariable ["startupComplete",true,true];

                if ({!(_x getVariable ["init",false])} count (MOD(CQB) getvariable ["instances",[]]) == 0) then {
                    //Indicate all instances are initialised on server
                    MOD(CQB) setVariable ["startupComplete",true,true];
                };

                //and publicVariable instance to clients
                Publicvariable _id;

                #ifdef DEBUG_MODE_FULL
                    ["CQB State: %1",([_logic, "state"] call ALiVE_fnc_CQB)] call ALiVE_fnc_dump;
                #endif
            };

            TRACE_2("After module init",_logic,_logic getVariable "init");

            TRACE_TIME(QUOTE(COMPONENT),[]); // 7

            /*
            VIEW - purely visual
            - initialise menu
            - frequent check to modify menu and display status (ALIVE_fnc_CQBsmenuDef)
            */

            TRACE_2("Waiting for CQB PV",isDedicated,isHC);

            //Client
            if(hasInterface) then {

                //As stated in the trace above the client needs to wait for the CQB module to be ready
                waituntil {_logic getVariable ["init",false]};

                //Report FPS
                //[_logic, "reportFPS", true] call ALiVE_fnc_CQB;

                //Activate Debug only serverside
                //[_logic, "debug", _debug] call ALiVE_fnc_CQB;

                // The areas are read and put out of sight up at module init now, alongside every
                // other module that owns a blacklist, so there is nothing left to do here. The
                // two calls that stood here read the same two settings that had already been
                // read further up and set them to what they already were.
            };

            TRACE_TIME(QUOTE(COMPONENT),[]); // 8
        };

        case "pause": {
            if(isNil "_args") then {
                // if no new value was provided return current setting
                _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
            } else {
                    // if a new value was provided set groups list
                    ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                    private ["_state"];
                    _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                    if (_state && _args) exitwith {};

                    //Set value
                    _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;
                    ["Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_dump;
            };
        };

        case "blacklist": {
            if !(isnil "_args") then {
                if(typeName _args == "STRING") then {
                    if !(_args == "") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, "[", ""] call CBA_fnc_replace;
                        _args = [_args, "]", ""] call CBA_fnc_replace;
                        _args = [_args, "'", ""] call CBA_fnc_replace;
                        _args = [_args, """", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;

                        if(count _args > 0) then {
                            _logic setVariable [_operation, _args];
                        };
                    } else {
                        _logic setVariable [_operation, []];
                    };
                } else {
                    if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                    };
                };
            };
            _args = _logic getVariable [_operation, DEFAULT_BLACKLIST];
        };

        case "whitelist": {
            if !(isnil "_args") then {
                if(typeName _args == "STRING") then {
                    if !(_args == "") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, "[", ""] call CBA_fnc_replace;
                        _args = [_args, "]", ""] call CBA_fnc_replace;
                        _args = [_args, "'", ""] call CBA_fnc_replace;
                        _args = [_args, """", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;

                        if(count _args > 0) then {
                            _logic setVariable [_operation, _args];
                        };
                    } else {
                        _logic setVariable [_operation, []];
                    };
                } else {
                    if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                    };
                };
            };
            _args = _logic getVariable [_operation, DEFAULT_WHITELIST];
        };

        case "reportFPS": {
            if (!hasInterface || {isnil "_args"}) exitwith {};

            if !(_args) exitwith {
                if !(isnil QGVAR(REPORTFPS)) exitwith {
                    terminate GVAR(REPORTFPS); GVAR(REPORTFPS) = nil; _args = nil;
                };
            };

            if !(isnil QGVAR(REPORTFPS)) exitwith {_args = GVAR(REPORTFPS)};

            GVAR(REPORTFPS) = [] spawn {

                _avgArr = [];

                player setvariable ["averageFPS",diag_fps,true];

                waituntil {
                    private ["_avg"];

                    //randomize to not broadcastStorm
                    sleep (20 + (random 10));

                    //Remove first entries after some iterations
                    if (count _avgArr == 5) then {_avgArr set [0,0]; _avgArr = _avgArr - [0]};

                    //Add current FPS
                    _avgArr pushback diag_fps;

                    //Calculate average
                    _avg = 0; {_avg = _avg + _x} foreach _avgArr; _avg = _avg / (count _avgArr);

                    //Set on player
                    player setvariable ["averageFPS",_avg,true];

                    //Exit if needed
                    isnil QGVAR(REPORTFPS);
                };

                GVAR(REPORTFPS) = nil;
            };

            _args = GVAR(REPORTFPS);
        };

        case "destroy": {
                if (isServer) then {
                        // if server

                        [_logic,"active",false] call ALiVE_fnc_CQB;
                        {[_logic, "delGroup", _x] call ALiVE_fnc_CQB} forEach +(_logic getVariable ["groups", []]);
                        [_logic,"debug",false] call ALiVE_fnc_CQB;

                        sleep 2;

                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];

                        MOD(CQB) setVariable ["instances",(MOD(CQB) getVariable ["instances",[]]) - [_logic],true];

                        deletegroup (group _logic);
                        deletevehicle _logic;

                        if (count (MOD(CQB) getVariable ["instances",[]]) == 0) then {

                            _logic = MOD(CQB);

                            _logic setVariable ["super", nil];
                            _logic setVariable ["class", nil];
                            _logic setVariable ["init", nil];
                            deletegroup (group _logic);
                            deletevehicle _logic;

                            MOD(CQB) = nil;
                            publicVariable QMOD(CQB);
                        };
                };
        };

    case "debug": {
        if(isNil "_args") then {
            _args = _logic getVariable ["debug", false];
        } else {
            _logic setVariable ["debug", _args];
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        if !(isServer) exitwith {
            [[_logic, _operation, _args],"ALIVE_fnc_CQB", false, false] call BIS_fnc_MP;
        };

        private ["_houses","_color","_prefix"];

        _houses = values (_logic getVariable ["houses", createHashMap]);
        _color = _logic getVariable ["debugColor","ColorGreen"];
        _prefix = _logic getVariable ["debugPrefix","CQB"];

        if (_args) then {

            [{
                _x params ["_house", "_enabled"];
                private _type = if (isNil {_house getVariable "group"}) then { "mil_dot" } else { "Waypoint" };
                private _alpha = if (_enabled) then {1} else {0.2};

                [format[MTEMPLATE, _house], getposATL _house,"ICON", [0.5,0.5],_color,_prefix,_type,"FDiagonal",0,_alpha] call ALIVE_fnc_createMarkerGlobal;

                private _sector = [ALIVE_sectorGrid, "positionToSector", getPosATL _house] call ALIVE_fnc_sectorGrid;
                private _subSector = [_sector, SUBGRID_SIZE, getPosATL _house] call ALiVE_fnc_positionToSubSector;
                private _subSectorID = [_subSector, "id"] call ALiVE_fnc_sector;
                private _subSectorPosition = [_subSector, "position"] call ALiVE_fnc_sector;
                private _subSectorDimensions = [_subSector, "dimensions"] call ALiVE_fnc_sector;

                if (getMarkerType (format [GTEMPLATE, _subSectorID]) == "") then {
                    [format[GTEMPLATE, _subSectorID], _subSectorPosition, "RECTANGLE", _subSectorDimensions, "ColorBlack", _subSectorID, "", "Solid", 0, 0.6] call ALIVE_fnc_createMarkerGlobal;
                };

                if (getMarkerType (format [STEMPLATE, _subSectorID]) == "") then {
                    [format[STEMPLATE, _subSectorID], _subSectorPosition, "ICON", [0.5, 0.5], "ColorBlack", _subSectorID, "mil_dot", "FDiagonal", 0, 1] call ALIVE_fnc_createMarkerGlobal;
                };
            },_houses,10] call ALiVE_fnc_arrayFrameSplitter;
        } else {
            [{
                private _house = _x select 0;
                deleteMarker format[MTEMPLATE, _house];
                deleteMarker format[GTEMPLATE, _house getVariable ["sectorID", ""]];
                deleteMarker format[STEMPLATE, _house getVariable ["sectorID", ""]];
            },_houses,10] call ALiVE_fnc_arrayFrameSplitter;
        };

        _args;
    };

    case "state": {
        private["_state","_data"];

        if(isNil "_args") then {
            _state = [] call ALiVE_fnc_hashCreate;
            // Save state
            {
                [_state, _x, _logic getVariable _x] call ALiVE_fnc_hashSet;
            } forEach [
                "id",
                "instancetype",
                "spawnDistance",
                "spawnDistanceStatic",
                "spawnDistanceHeli",
                "spawnDistanceJet",
                "factions",

                //Get data Identifyer
                "_rev"
            ];

            //Get global cleared sectors
            [_state,"cleared", MOD(CQB) getvariable "cleared"] call ALiVE_fnc_hashSet;

            _data = [] call ALiVE_fnc_HashCreate;
            {
                _x params ["_house", "_enabled"];
                private ["_hash","_type"];
                _hash = [] call ALiVE_fnc_HashCreate;

                switch (_logic getVariable ["instancetype","regular"]) do {
                    case ("regular") : {_type = "R"};
                    case ("strategic") : {_type = "S"};
                };

                [_hash,"id",_logic getVariable "id"] call ALiVE_fnc_HashSet;
                [_hash,"instancetype",_logic getVariable "instancetype"] call ALiVE_fnc_HashSet;
                private _position = getPosATL _house;
                [_hash,"pos",[_position select 0,_position select 1]] call ALiVE_fnc_HashSet;
                [_hash,"house",typeOf _house] call ALiVE_fnc_HashSet;
                [_hash,"units",_house getVariable ["unittypes", []]] call ALiVE_fnc_HashSet;
                [_hash,"enabled",_enabled] call ALiVE_fnc_HashSet;

                //Get data Identifyer
                [_hash,"_rev",_house getVariable "_rev"] call ALiVE_fnc_hashSet;

                private _recordID = format ["%1|%2|%3|%4", _logic getVariable ["id", ""], typeOf _house, _position, getDir _house];
                [_data,_recordID,_hash] call ALiVE_fnc_HashSet;
            } forEach (values (_logic getVariable ["houses", createHashMap]));

            [_state, "houses", _data] call ALiVE_fnc_hashSet;

            _args = _state;
            //_args call AliVE_fnc_InspectHash;
        } else {
            private["_houses","_groups","_data","_idIn","_idOut"];

            //Exit if wrong dataset is provided
            _idIn = [_args, "id","in"] call ALiVE_fnc_hashGet;
            _idOut = _logic getvariable ["id","out"];

            if !(_idIn == _idOut) exitwith {};

            private _wasActive = _logic getVariable ["active", false];
            if (_wasActive) then {[_logic, "active", false] call ALiVE_fnc_CQB};

            //_args call AliVE_fnc_InspectHash;

            //Restore main state
            [_logic, "id", [_args, "id"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "instancetype", [_args, "instancetype"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "spawnDistance", [_args, "spawnDistance"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "spawnDistanceStatic", [_args, "spawnDistanceStatic"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "spawnDistanceHeli", [_args, "spawnDistanceHeli"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "spawnDistanceJet", [_args, "spawnDistanceJet"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;
            [_logic, "factions", [_args, "factions"] call ALiVE_fnc_hashGet] call ALiVE_fnc_CQB;

            //Restore global cleared sectors
            MOD(CQB) setvariable ["cleared", [_args, "cleared", []] call ALiVE_fnc_hashGet,true];

            //Restore data Identifyer
            _logic setvariable ["_rev",[_args,"_rev"] call ALiVE_fnc_hashGet,true];

            private _savedHouses = [_args, "houses", "__CQB_NO_HOUSES__"] call ALiVE_fnc_hashGet;
            private _disabled = [];

            // Restore a provided houselist, including an explicitly saved empty list.
            if (_savedHouses isEqualType []) then {

                //Reset groups and markers
                {[_logic, "delGroup", _x] call ALiVE_fnc_CQB} forEach (_logic getVariable ["groups",[]]);
                {
                    deleteMarker format[MTEMPLATE, _x];
                    deleteMarker format[GTEMPLATE, _x getVariable ["sectorID", ""]];
                    deleteMarker format[STEMPLATE, _x getVariable ["sectorID", ""]];
                } forEach ((values (_logic getVariable ["houses", createHashMap])) apply {_x select 0});

                //Reset dynamic groups. Keep the old house list until the setter below
                //can remove stale entries from the persistent position grid.
                _logic setVariable ["groups",[]];

                //Collect new houselist
                _data = [];
                {
                    private["_house"];

                    private _instanceID = _logic getVariable ["id", ""];
                    if (
                        ([_x,"instancetype","regular"] call ALiVE_fnc_HashGet) == ([_logic,"instancetype"] call ALiVE_fnc_CQB) &&
                        {([_x,"id",_instanceID] call ALiVE_fnc_HashGet) == _instanceID}
                    ) then {
                        _house = ([_x,"pos",[0,0,0]] call ALiVE_fnc_HashGet) nearestObject ([_x,"house",""] call ALiVE_fnc_HashGet);
                        _house setVariable ["unittypes",([_x,"units"] call ALiVE_fnc_HashGet), true];

                        //Set data Identifyer
                        _house setVariable ["_rev",([_x,"_rev"] call ALiVE_fnc_HashGet), true];

                        _data pushback _house;
                        if !([_x,"enabled",true] call ALiVE_fnc_HashGet) then {
                            _disabled pushBack _house;
                        };
                    };
                } forEach (_savedHouses select 2);

            //If no houselist was provided take the existing houselist
            } else {
                _data = (values (_logic getVariable ["houses", createHashMap])) apply {_x select 0};
                _disabled = ((values (_logic getVariable ["houses", createHashMap])) select {!(_x select 1)}) apply {_x select 0};
            };

            //Apply houselist
            [_logic, "houses", _data] call ALiVE_fnc_CQB;
            [_logic, "setHousesEnabled", _disabled apply {[_x, false]}] call ALiVE_fnc_CQB;
            if (_wasActive) then {[_logic, "active", true] call ALiVE_fnc_CQB};

            _args = [_logic,"state"] call ALiVE_fnc_CQB;
            //_args call AliVE_fnc_InspectHash;
        };
    };

    case "factions": {
        if(isNil "_args") then {
            // if no new faction list was provided return current setting
            _args = _logic getVariable [_operation, DEFAULT_FACTIONS];
        } else {
            private _factions = DEFAULT_FACTIONS;

            if(typeName _args == "STRING") then {
                if !(_args == "") then {
                    _args = [_args, " ", ""] call CBA_fnc_replace;
                    _args = [_args, "[", ""] call CBA_fnc_replace;
                    _args = [_args, "]", ""] call CBA_fnc_replace;
                    _args = [_args, """", ""] call CBA_fnc_replace;
                    _args = [_args, ","] call CBA_fnc_split;
                    if(count _args > 0) then {
                        _factions = _args;
                    };
                };
            } else {
                if(typeName _args == "ARRAY" && {count _args > 0}) then {
                    _factions = _args;
                };
            };

            _logic setVariable [_operation, _factions, true];
            _args = _factions;
        };
    };

    case "allFactions": {
        if(isNil "_args") then {
            // if no new faction list was provided return current setting
            _args = _logic getVariable [_operation, []];
        } else {
            if(typeName _args == "STRING") then {
                if !(_args == "") then {
                    _args = [_args, " ", ""] call CBA_fnc_replace;
                    _args = [_args, "[", ""] call CBA_fnc_replace;
                    _args = [_args, "]", ""] call CBA_fnc_replace;
                    _args = [_args, """", ""] call CBA_fnc_replace;
                    _args = [_args, ","] call CBA_fnc_split;
                    if(count _args > 0) then {
                        _logic setVariable [_operation, _args];
                    };
                } else {
                    _logic setVariable [_operation, []];
                };
            } else {
                if(typeName _args == "ARRAY") then {
                    _logic setVariable [_operation, _args];
                };
            };
            _args = _logic getVariable [_operation, []];
        };
        _logic setVariable [_operation, _args, true];
    };

    case "instancetype": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable ["instancetype", "regular"];
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "STRING",str typeName _args);
            _logic setVariable ["instancetype", _args, true];
        };
    };

    case "id": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable "id";
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "STRING",str typeName _args);
            _logic setVariable ["id", _args, true];
        };
    };

    case "spawnDistance": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable ["spawnDistance", 700];
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "SCALAR",str typeName _args);
            _logic setVariable ["spawnDistance", _args, true];
        };
        _args;
    };

    case "spawnDistanceStatic": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable ["spawnDistanceStatic", 1200];
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "SCALAR",str typeName _args);
            _logic setVariable ["spawnDistanceStatic", _args, true];
        };
        _args;
    };

    case "spawnDistanceHeli": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable ["spawnDistanceHeli", 0];
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "SCALAR",str typeName _args);
            _logic setVariable ["spawnDistanceHeli", _args, true];
        };
        _args;
    };

    case "spawnDistanceJet": {
        if(isNil "_args") then {
            // if no new distance was provided return spawn distance setting
            _args = _logic getVariable ["spawnDistanceJet", 0];
        } else {
            // if a new distance was provided set spawn distance settings
            ASSERT_TRUE(typeName _args == "SCALAR",str typeName _args);
            _logic setVariable ["spawnDistanceJet", _args, true];
        };
        _args;
    };

    case "allHouses": {
        if !(isNil "_args") then {
            ASSERT_TRUE(_args isequaltype [], typeName _args);

            _logic setVariable ["allHouses", _args];
        };

        _args = _logic getVariable ["allHouses", []];
    };

    case "positionGrid": {
        private _grid = _logic getVariable "positionGrid";
        if (isNil "_grid") then {
            private _registry = _logic getVariable ["houses", createHashMap];

            // Size once for all known positions, including currently disabled houses.
            private _minX = -3000;
            private _minY = -3000;
            private _maxX = worldSize + 3000;
            private _maxY = worldSize + 3000;

            {
                private _position = getPosATL (_x select 0);
                _minX = _minX min (_position select 0);
                _minY = _minY min (_position select 1);
                _maxX = _maxX max (_position select 0);
                _maxY = _maxY max (_position select 1);
            } forEach (values _registry);

            private _size = ((_maxX - _minX) max (_maxY - _minY)) + 1;
            _grid = [nil,"create", [[_minX, _minY], _size, 1000]] call ALiVE_fnc_spacialGrid;
            private _entries = [];
            {
                private _house = _y select 0;
                _entries pushBack [getPosATL _house, _x];
            } forEach _registry;
            _grid call ["insert", _entries];

            _logic setVariable ["positionGrid", _grid];
        };

        _args = _grid;
    };

    case "positionsInRange": {
        _args params ["_grid", "_groundRange", "_staticRange", "_jetRange", "_heliRange", "_sources"];

        if (isNil "_sources") then {
            _sources = allPlayers - entities "HeadlessClient_F";
            if (!isNil "ALIVE_profileSystem" && {[ALIVE_profileSystem,"zeusSpawn"] call ALiVE_fnc_hashGet}) then {
                _sources append allCurators;
            };
        };

        private _near = createHashMap;
        private _registry = _logic getVariable "houses";
        {
            private _source = _x;
            private _vehicle = vehicle _source;
            private _ground = !(_vehicle isKindOf "Plane") && {!(_vehicle isKindOf "Helicopter")};
            private _queries = if (_ground) then {
                [[_groundRange, false]]
            } else {
                [[if (_vehicle isKindOf "Plane") then {_jetRange} else {_heliRange}, false]]
            };
            if (_ground && {_staticRange > _groundRange}) then {
                _queries pushBack [_staticRange, true];
            };
            {
                _x params ["_radius", "_staticOnly"];
                if (_radius > 0) then {
                    private _candidates = _grid call ["findInRange", [getPosATL _source, _radius, false, true, true]];
                    {
                        private _houseID = _x;
                        (_registry get _houseID) params ["_house", "_enabled"];
                        if (_enabled && {!isNull _house} && {!_staticOnly || {!isNil {_house getVariable "staticWeapons"}}}) then {
                            private _nearSources = _near getOrDefault [_houseID, [], true];
                            _nearSources pushBackUnique _source;
                        };
                    } forEach _candidates;
                };
            } forEach _queries;
        } forEach _sources;

        _args = _near;
    };

    case "houses": {
        private ["_debug"];
        _debug = _logic getVariable ["debug", false];

        if (!isNil "_args") then {
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

            private _oldRegistry = _logic getVariable ["houses", createHashMap];
            private _registry = createHashMap;

            if (_debug) then {
                { // forEach
                    deleteMarker format[MTEMPLATE, _x];
                    deleteMarker format[GTEMPLATE, _x getVariable ["sectorID", ""]];
                    deleteMarker format[STEMPLATE, _x getVariable ["sectorID", ""]];
                } forEach ((values _oldRegistry) apply {_x select 0});
            };

            //Initialise SectorGrid if profile system is not present
            if (isnil "ALIVE_sectorGrid") then {
                // create sector grid
                ALIVE_sectorGrid = [nil, "create"] call ALIVE_fnc_sectorGrid;
                [ALIVE_sectorGrid, "init"] call ALIVE_fnc_sectorGrid;
                [ALIVE_sectorGrid, "createGrid"] call ALIVE_fnc_sectorGrid;
                [ALIVE_sectorGrid] call ALIVE_fnc_gridImportStaticMapAnalysis;
            };

            //Exclude houses in formerly cleared areas from input list and flag the rest with sectorID on server for persistence
            private _cleared = MOD(CQB) getVariable ["cleared", []];

            { // forEach
                private _housePosition = getPosATL _x;
                private _sector = [ALIVE_sectorGrid, "positionToSector", _housePosition] call ALIVE_fnc_sectorGrid;

                // Make sure we got back a hash because we might be testing a
                // position outside the ALIVE_sectorGrid returning ["",[],[],nil]
                if ([_sector] call CBA_fnc_isHash) then {
                    private _sectorID = [_sector, "id"] call ALiVE_fnc_sector;

                    // Divide sector into x rows and columns
                    private _subSector = [_sector, SUBGRID_SIZE, _housePosition] call ALiVE_fnc_positionToSubSector;
                    private _subSectorID = [_subSector, "id"] call ALiVE_fnc_sector;
                    private _subSectorDimensions = [_subSector, "dimensions"] call ALiVE_fnc_sector;
                    private _subSectorPosition = [_subSector, "position"] call ALiVE_fnc_sector;

                    if (!isNil "_sectorID" && !isNil "_subSectorID") then {
                        if (!(_sectorID in _cleared) && !(_subSectorID in _cleared)) then {
                            _x setVariable ["sectorID", _subSectorID];
                            _registry set [hashValue _x, [_x, true]];
                        };
                    };
                };
            } forEach _args;

            private _oldIDs = keys _oldRegistry;
            {
                if !(_x in _registry) then {
                    [_logic, "removeHouse", (_oldRegistry get _x) select 0] call ALiVE_fnc_CQB;
                };
            } forEach _oldIDs;

            // Replace the registry. Runtime object hashes are deliberately not persisted.
            _logic setVariable ["houses", _registry];
            if (!isNil {_logic getVariable "positionGrid"}) then {
                private _grid = _logic getVariable "positionGrid";
                private _added = [];
                {
                    if !(_x in _oldIDs) then {
                        private _house = (_registry get _x) select 0;
                        _added pushBack [getPosATL _house, _x];
                    };
                } forEach (keys _registry);
                _grid call ["insert", _added];
            };

            // mark all strategic and non-strategic houses in debug
            if (_debug) then {
                [_logic, "debug", true] call MAINCLASS;
            };
        };

        _args = _logic getVariable ["houses", createHashMap];
    };

    case "addHouse": {
        ASSERT_TRUE(_args isequaltype objnull,typeName _args);

        if (!isnull _args) then {
            private _house = _args;
            private _registry = _logic getVariable ["houses"];
            private _houseID = hashValue _house;

            if !(_houseID in _registry) then {
                _registry set [_houseID, [_house, true]];

                private _positionGrid = _logic getVariable "positionGrid";
                _positionGrid call ["insert", [[getPosATL _house, _houseID]]];
            };

            if (_logic getVariable "debug") then {
                ["CQB Population: Adding house %1...", _house] call ALiVE_fnc_Dump;
                [_logic,"debug", true] call MAINCLASS;
            };
        };
    };

    case "setHousesEnabled": {
        private _registry = _logic getVariable ["houses", createHashMap];
        private _changed = false;

        {
            _x params ["_house", "_enabled"];

            private _houseID = hashValue _house;
            private _record = _registry get _houseID;

            if (!isNil "_record") then {
                _record set [1, _enabled];
            };
        } forEach _args;
    };

    case "removeHouse": {
        private _house = _args;
        ASSERT_TRUE(_house isequaltype objnull,typeName _house);

        private _registry = _logic getVariable "houses";
        private _houseID = hashValue _house;

        if (_houseID in _registry) then {
            if (_house isEqualTo (_logic getVariable ["spawningHouse", objNull]) && {!(_house isEqualTo (_logic getVariable ["clearingHouse", objNull]))}) then {
                private _process = _logic getVariable "process";
                if (!isNil "_process") then {
                    terminate _process;
                };

                [_logic,"finishSpawn", true] call ALiVE_fnc_CQB;
            };

            if ((_house getVariable ["group", grpNull]) isEqualType "") then {
                _house setVariable ["group", nil, true];
            };

            private _positionGrid = _logic getVariable "positionGrid";
            _positionGrid call ["remove", [getPosATL _house, _houseID]];

            _registry deleteAt _houseID;
        };
    };

    case "clearHouse": {
        if (!isNil "_args") then {
            private _house = _args;
            private _sectorID = _house getvariable ["sectorID","none"];

            private _debug = _logic getVariable "debug";

            // delete the group
            private _grp = _house getVariable "group";

            if (
                !isNil "_grp" &&
                { {alive _x} count (units _grp) == 0 }
            ) then {
                // Remove group from list but dont delete bodies (done by GC)

                [_logic,"groups",[_grp],true,true] call BIS_fnc_variableSpaceRemove;

                if (_debug) then {
                    ["CQB Population: Removing group %1...", _grp] call ALiVE_fnc_Dump;
                    ["CQB Population: Clearing house %1...", _house] call ALiVE_fnc_Dump;
                };
            } else {
                if (_debug) then {
                    ["MIL CQB Warning: Group %1 is still alive! Removing...", _grp] call ALiVE_fnc_dump;
                };

                [_logic,"delGroup", _grp] call ALiVE_fnc_CQB;
            };

            // clearHouse may run inside the current spawn worker. Mark that path so
            // removeHouse does not terminate the script before registry cleanup completes.
            _logic setVariable ["clearingHouse", _house];
            [_logic, "removeHouse", _house] call ALiVE_fnc_CQB;
            _logic setVariable ["clearingHouse", nil];

            private _parentSectorID = ((_sectorID splitString "_") select [0, 2]) joinString "_";
            private _parentCount = 0;
            private _count = 0;
            {
                {
                    private _registeredHouse = _y select 0;
                    private _houseSectorID = _registeredHouse getVariable ["sectorID", "in"];
                    private _houseParentSectorID = ((_houseSectorID splitString "_") select [0, 2]) joinString "_";
                    _count = _count + (parseNumber (_houseSectorID == _sectorID));
                    _parentCount = _parentCount + (parseNumber (_houseParentSectorID == _parentSectorID));
                } forEach (_x getVariable "houses");
            } forEach (MOD(CQB) getVariable ["instances", []]);

            // Disabled houses remain registered and therefore prevent sector clearing.
            if (_count == 0) then {
                ["MIL CQB Cleared sub sector %1!", _sectorID] call ALiVE_fnc_dump;

                private _cleared = MOD(CQB) getVariable ["cleared", []];
                _cleared pushBackUnique _sectorID;

                deleteMarker format [GTEMPLATE, _house getVariable ["sectorID", ""]];
                deleteMarker format [STEMPLATE, _house getVariable ["sectorID", ""]];

                if (_parentCount == 0) then {
                    ["MIL CQB Cleared sector %1!", _parentSectorID] call ALiVE_fnc_dump;
                    _cleared pushBackUnique _parentSectorID;

                    for "_x" from 0 to SUBGRID_SIZE do {
                        for "_y" from 0 to SUBGRID_SIZE do {
                            private _id = format ["%1_%2_%3", _parentSectorID, _x, _y];
                            private _index = _cleared find _id;
                            if (_index >= 0) then {_cleared deleteAt _index};
                        };
                    };
                };
                MOD(CQB) setVariable ["cleared", _cleared, true];
            };

            deleteMarker format [MTEMPLATE, _house];
        };
    };

    case "GarbageCollecting": {
        if (isNil "_args") then {
            _args = _logic getVariable ["GarbageCollecting", true];
        } else {
            _logic setVariable ["GarbageCollecting", _args, true];
        };
    };

    case "groups": {
        if(isNil "_args") then {
            // if no new groups list was provided return current setting
            _args = _logic getVariable ["groups", []];
        } else {
                // if a new groups list was provided set groups list
                ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
                _logic setVariable ["groups", _args, true];
        };
        _args;
    };

    case "addGroup": {
        if(!isNil "_args") then {
            private ["_house","_grp","_leader"];
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);
            _house = ARG_1(_args,0);
            ASSERT_TRUE(typeName _house == "OBJECT",str typeName _house);
            _grp = ARG_1(_args,1);
            ASSERT_TRUE(typeName _grp == "GROUP",str typeName _grp);

            _leader = leader _grp;
            _grp setVariable ["house", _house];
            _grp setVariable ["ALIVE_profileIgnore", true];

            // if a house is not enterable, you can't spawn AI on it
            if (!([_house] call ALiVE_fnc_isHouseEnterable)) exitWith {
                _house setVariable ["group", _grp, true];
                [_logic, "clearHouse", _house] call ALiVE_fnc_CQB;
            };

            //Add group to main groups data
            [_logic,"groups",[_grp],true,true] call BIS_fnc_variableSpaceAdd;

            //Set group on house (globally with public flag so all localities know about it)
            _house setVariable ["group", _grp, true];

            //Set house and ALiVE_profileIgnore on all single units locally without public flag to save PVs
            {_x setVariable ["house",_house]; _x setVariable ["ALIVE_profileIgnore",true]} foreach (units _grp);

            //Only public flag leader with house and AliVE_profileIgnore information to save PVs (and groups cant carry public flag on setvariable either way)
            //See the "active" operation for setting the variables on the group
            _leader setVariable ["house",_house, true];
            _leader setvariable ["ALIVE_profileIgnore",true,true];

            if (_logic getVariable ["debug", false]) then {
                ["CQB Population: Group %1 created on %2", _grp, owner _leader] call ALiVE_fnc_Dump;
            };
            // mark active houses
            format[MTEMPLATE, _house] setMarkerType "Waypoint";
        };
    };

    case "delGroup": {
        ASSERT_TRUE(_args isequaltype grpNull ,typeName _args);

        private _grp = _args;

        private _leader = leader _grp;
        private _house = _leader getVariable ["house", _grp getVariable ["house", objNull]];

        // Update house that group despawned
        if (!isnil "_house") then {
            _house setVariable ["group", nil, true];
            (format [MTEMPLATE, _house]) setMarkerType "mil_Dot";
        };

        if (isnil "_grp") exitwith {
            _house setVariable ["group", nil, true];
        };

        // Despawn group
        private _debug = _logic getVariable "debug";
        if (_debug) then {
            ["CQB Population: Deleting group %1 from %2...", _grp, owner _leader] call ALiVE_fnc_Dump;
        };

        _logic setVariable ["groups", (_logic getVariable ["groups", []]) - [_grp], true];

        // Clear pending waypoints BEFORE deleting units - CBA patrol/search
        // follow-up waypoint statements otherwise fire against a half-deleted
        // group and spam undefined-variable errors from CBA's internals
        { deleteWaypoint _x } forEachReversed waypoints _grp;
        { deleteVehicle _x } forEach (units _grp);

        _grp call ALiVE_fnc_DeleteGroupRemote;
    };

    case "spawnGroup": {
        if (isNil "_args") then {
            // if no units and house was provided return false
            _args = false;
        } else {
            // if a house and unit is provided start spawn process
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

            private ["_factions","_units","_blacklist","_faction","_houseFaction","_staticWeapons","_staticWeaponsIntensity"];

            _house = _args select 0;
            _faction = _args select 1;
            _factions = (_logic getvariable ["factions",DEFAULT_FACTIONS]);
            _blacklist = (_logic getvariable ["UnitsBlackList",GVAR(UNITBLACKLIST)]);
            _staticWeaponsIntensity = _logic getvariable ["StaticWeaponsIntensity",0];
            _debug = _logic getVariable ["debug",false];
            _strategicPlatforms = GVAR(STRATEGICPLATFORMS);

            private ["_side","_units"];

            // Action: spawn AI
            // this just flags the house as beginning spawning
            // and will be over-written in addHouse

            _units = _house getVariable ["unittypes", []];
            _houseFaction = _house getVariable ["faction", (selectRandom _factions)];

            // Check: if no units already defined
            if ((count _units == 0) || {!(_houseFaction == _faction)}) then {
                // Action: identify AI unit types
                private ["_amount"];

               if (_strategicPlatforms find (typeof _house) != -1) then {  
                  _amount = 1;
               } else {
              	  _amount = ceil(random(_logic getVariable ["amount",2]));
               };

                _units = [[_faction],_amount, _blacklist, true] call ALiVE_fnc_chooseRandomUnits;

                _house setVariable ["unittypes", _units, true];
                _house setVariable ["faction", _faction, true];
            };

            if (count _units == 0) exitWith {
                if (_debug) then {
                    ["CQB Population: no units..."] call ALiVE_fnc_Dump;
                };
            };

            // Action: restore AI
            switch (getNumber(configFile >> "Cfgvehicles" >> _units select 0 >> "side")) do {
                case 0 : {_side = EAST};
                case 1 : {_side = WEST};
                case 2 : {_side = RESISTANCE};
                case 3 : {_side = CIVILIAN};
                default {_side = EAST};
            };

            //["CQB spawning %1 AI",count _units] call ALiVE_fnc_DumpH;
            //_grp = [getPosATL _house,_side, _units] call BIS_fnc_spawnGroup;

            // Publish the partial group atomically so stopping the worker can
            // always delete it, even before the first unit has been created.
            _grp = {
                private _created = createGroup _side;
                _created setVariable ["house", _house];
                if (_house isEqualTo (_logic getVariable ["spawningHouse", objNull])) then {
                    _logic setVariable ["spawningGroup", _created];
                };
                _created
            } call CBA_fnc_DirectCall;

            {if !(isnil "_x") then {_unit = _grp createUnit [_x, getPosATL _house, [], 0 , "NONE"]}; sleep MOD(smoothSpawn)} foreach _units;

            if (count units _grp == 0) exitWith {
                if (_debug) then {
                    ["CQB Population: Group %1 deleted on creation - no units...", _grp] call ALiVE_fnc_Dump;
                };
                [_logic, "delGroup", _grp] call ALiVE_fnc_CQB;
            };

            // position AI - engine building positions, plus CBA AI Building Positions when the mission has any
            if (isNil QGVAR(HASCBAPOSITIONS)) then {
                GVAR(HASCBAPOSITIONS) = !((allMissionObjects "CBA_buildingPos") isEqualTo []);
            };

            private _housePositions = [_house] call ALiVE_fnc_getBuildingPositions;

            if (GVAR(HASCBAPOSITIONS) && {!(_house isKindOf "CBA_buildingPos")}) then {
                // CBA_fnc_buildingPositions returns engine buildingPos plus any CBA position
                // helper objects inside this building's bounding box, in the same world
                // position space. Additive-only merge: seed with the engine list and add only
                // genuinely new spots, so an engine position can never be dropped and a helper
                // placed on top of an engine slot cannot double-book it. Recomputed per spawn
                // (like the engine list) so a destroyed building never serves stale positions.
                private _cbaAdded = 0;
                {
                    private _candidate = _x;
                    if ((_housePositions findIf {_x distance _candidate < 0.5}) == -1) then {
                        _housePositions pushBack _candidate;
                        _cbaAdded = _cbaAdded + 1;
                    };
                } forEach ([_house] call CBA_fnc_buildingPositions);

                if (_cbaAdded > 0 && {_debug}) then {
                    ["CQB Population: House %1 building positions: %2 engine + %3 CBA AI Building Positions", typeof _house, (count _housePositions) - _cbaAdded, _cbaAdded] call ALiVE_fnc_Dump;
                };
            };

            _positions = [_housePositions, true] call CBA_fnc_shuffle;

            if (count _positions == 0) exitwith {_args = _grp};

            [_logic, "addGroup", [_house, _grp]] call ALiVE_fnc_CQB;
            if (isNull _grp || {!((_house getVariable ["group", grpNull]) isEqualTo _grp)}) exitWith {_args = grpNull};
            [_logic, "addStaticWeapons", [_house, _staticWeaponsIntensity]] call ALiVE_fnc_CQB;

            // Execute onEachSpawn hook if defined
            private _cqbOnEachSpawn = _logic getvariable ["onEachSpawn", ""];
            if (_cqbOnEachSpawn != "") then {
                private _cqbOnEachSpawnOnce = _logic getvariable ["onEachSpawnOnce", true];
                {
                    private _unit = _x;
                    private _profileID = _unit getvariable ["profileID", ""];
                    private _side = side (group _unit);
                    private _faction = _unit getvariable ["faction", ""];
                    if (!_cqbOnEachSpawnOnce || {!(_unit getvariable ["ALIVE_hookFired", false])}) then {
                        _unit setVariable ["ALIVE_hookFired", true];
                        [_unit, _profileID, _side, _faction] spawn (compile _cqbOnEachSpawn);
                    };
                } forEach (units _grp);
            };

            // Each unit takes its own position from the shuffled list (wrapping when
            // the group outnumbers the positions). The old loop walked every unit
            // through ALL positions, stacking the whole group on the last one.
            private _usablePositions = _positions;
            if (_strategicPlatforms find (typeof _house) != -1) then {
                // strategic platforms: only elevated positions qualify
                _usablePositions = _positions select {(_x select 2) > 1};
            };
            if (count _usablePositions > 0) then {
                {
                    private _pos = _usablePositions select (_forEachIndex % (count _usablePositions));
                    _x setPosATL [_pos select 0, _pos select 1, (_pos select 2 + 0.4)];
                } forEach (units _grp);
            };


            // TODO Notify controller to start directing

            private _CQB_patrolChance = _logic getvariable ["CQB_patrol_chance","0.30"];
            private _CQB_patrolMinDist = _logic getvariable ["CQB_patrol_mindist","50"];
            private _CQB_patrolMaxDist = _logic getvariable ["CQB_patrol_maxist","100"];
            private _CQB_patrolMinWaitTime = _logic getvariable ["CQB_patrol_minwaittime","0"];
            private _CQB_patrolMidWaitTime = _logic getvariable ["CQB_patrol_midwaittime","15"];
            private _CQB_patrolMaxWaitTime = _logic getvariable ["CQB_patrol_maxwaittime","30"];
            private _CQB_patrolBehaviour = _logic getvariable ["CQB_patrol_behaviour","SAFE"];
            private _CQB_patrolSpeed = _logic getvariable ["CQB_patrol_speed","LIMITED"];
            {
             private _unit = _x;
             _unit setVariable ["ALIVE_cqb_instance", _logic, true];
            } forEach (units _grp);
            if (random 1 <= _CQB_patrolChance) then {
                [_grp, getpos (leader _grp), _CQB_patrolMinDist + random (_CQB_patrolMaxDist - _CQB_patrolMinDist), [3,7] call BIS_fnc_randomInt, "MOVE", _CQB_patrolBehaviour, "YELLOW", _CQB_patrolSpeed, "STAG COLUMN",
                "
                _module = this getVariable ['ALIVE_cqb_instance', objNull];
                _CQB_patrolSearchChance = 0.3;
                if !(isNull _module) then {
                 _CQB_patrolSearchChance = (_module getVariable ['CQB_patrol_searchchance', 0.3]);
                };
                if (random 1 <= _CQB_patrolSearchChance) then {
                    private _group = group this;
                    if (!isNull this && {alive this} && {_group != grpNull} && {count (units _group) > 0}) then {
                        [_group] call CBA_fnc_searchNearby;
                    };
                };
                "
                , [_CQB_patrolMinWaitTime, _CQB_patrolMidWaitTime, _CQB_patrolMaxWaitTime]] call CBA_fnc_taskPatrol;
            } else { 
                _fsm = "\x\alive\addons\mil_cqb\HousePatrol.fsm";
                _hdl = [_logic,(leader _grp), 50, true, 60] execFSM _fsm;
                (leader _grp) setVariable ["FSM", [_hdl,_fsm], true];
                _args = _grp;
            };
        };
        _args;
    };

    case "addStaticWeapons": {

	    if (isNil "_args" || {count _args < 2} || {isNull (_args select 0)} || {_args select 1 <= 0}) exitWith {
            //["CQB Input does not allow for creation of static weapons: %1!",_args] call ALiVE_fnc_dump;
            _args = [];
            _args;
	    };

        private _building = _args select 0;
        private _count = _args select 1;
        private _buildingPosition = getposATL _building;
        private _staticWeapons = _building getvariable ["staticWeapons",[]];

        if ({alive _x} count _staticWeapons > 0) exitwith {
           //["CQB Static weapons exisiting: %1! Not creating new ones...",_staticWeapons] call ALiVE_fnc_dumpR;
        	_args = _staticWeapons;
        	_args;
        };

		private _positions = _building call ALiVE_fnc_getBuildingPositions;
		private _onTop = [];


		scopeName "#Main";

		_positions = [_positions,[],
			{
		    	_x select 2;
			},"DESCENDING",{

			}
		] call ALiVE_fnc_SortBy;

        //["CQB Found building positions: %1",_positions] call ALiVE_fnc_dumpR;

		{
		    private _position = AGLtoASL _x;
		    private _checkPos = +_position; _checkPos set [2,(_checkpos select 2) + 10];

		    if (count lineIntersectsSurfaces [_position,_checkPos] == 0) then {
		        _onTop pushBack (ASLtoAGL _position)
		    };
		} foreach _positions;

        //["CQB Found on top positions: %1",_onTop] call ALiVE_fnc_dumpR;

		if (random 1 < _count && {count _onTop > 0}) then {

        	_count = ceil _count;

            [_onTop] call CBA_fnc_Shuffle;

			private _staticWeaponClassnames = _logic getvariable ["staticWeaponsClassnames", []];

			{
			    if (count _staticWeapons < _count) then {

                    private _class = selectRandom _staticWeaponClassnames;
	                private _placement = _x;

	                _placement set [2,(_placement select 2) + 0.3];
                    _placement = [_placement,1.5,_placement getdir _buildingPosition] call BIS_fnc_relPos;

			    	private _staticWeapon = createVehicle [_class, _placement, [], 0, "CAN_COLLIDE"];

                    _staticWeapon setpos _placement;
                    _staticWeapon setdir (_buildingPosition getDir _placement);

			        _staticWeapons pushback _staticWeapon;
			    } else {
			        breakTo "#Main"
			    };
			} foreach _onTop;
        };

        if (count _staticWeapons > 0) then {
            _building setvariable ["staticWeapons",_staticWeapons,true];

            //["CQB Static weapons created: %1",_staticWeapons] call ALiVE_fnc_dumpR;
        };

		_args = _staticWeapons;

        _args;
    };

    case "claimHouses": {
        // Precise activation and retention queries share the same source/range rules.
        private _source = _args;
        if (isNull _source) exitWith {};
        private _groundRange = _logic getVariable ["spawnDistance", 700];
        private _staticRange = _logic getVariable ["spawnDistanceStatic", 1200];
        private _jetRange = _logic getVariable ["spawnDistanceJet", 0];
        private _heliRange = _logic getVariable ["spawnDistanceHeli", 0];
        private _grid = [_logic, "positionGrid"] call ALiVE_fnc_CQB;
        private _activation = [_logic, "positionsInRange", [_grid, _groundRange, _staticRange, _jetRange, _heliRange, [_source]]] call ALiVE_fnc_CQB;
        private _retention = [_logic, "positionsInRange", [_grid, _groundRange * 3, _staticRange * 3, _jetRange * 3, _heliRange * 3, [_source]]] call ALiVE_fnc_CQB;
        private _claims = _logic getVariable "claims";
        private _cycle = _logic getVariable "claimCycle";
        private _queue = _logic getVariable "spawnQueue";
        private _registry = _logic getVariable ["houses", createHashMap];
        {
            private _houseID = _x;
            private _house = (_registry get _houseID) select 0;
            if (alive _house) then {
                private _inActivation = _houseID in _activation;
                private _existing = _house getVariable "group";
                private _spawning = _house isEqualTo (_logic getVariable ["spawningHouse", objNull]);
                if (_inActivation || {!isNil "_existing"} || {_spawning}) then {
                    _claims set [_houseID, [_house, _cycle]];
                    if (_inActivation && {isNil "_existing"} && {!_spawning} && {time >= (_house getVariable ["ALIVE_CQB_nextDetect", 0])}) then {
                        _house setVariable ["group", "preinit", true];
                        _queue pushBack _house;
                        if (_logic getVariable ["debug", false] && {_source in allCurators}) then {
                            ["CQB Population: Zeus curator claimed house at %1", getPosATL _house] call ALiVE_fnc_Dump;
                        };
                    };
                };
            };
        } forEach (keys _retention);
    };

    case "spawnHouse": {
        // Scheduled worker: faction detection and spawnGroup may suspend.
        private _house = _args;
        private _houseID = hashValue _house;
        private _registry = _logic getVariable ["houses", createHashMap];
        private _record = _registry get _houseID;
        if (isNil "_record" || {!(_record select 1)}) exitWith {};
        private _faction = nil;
        private _range = _logic getVariable ["spawnDistance", 700];
        if (!isNil {_house getVariable "staticWeapons"}) then {
            _range = _range max (_logic getVariable ["spawnDistanceStatic", 1200]);
        };
        if (_logic getVariable ["CQB_UseDominantFaction", false]) then {
            if (time >= (_house getVariable ["ALIVE_CQB_nextDetect", 0])) then {
                _faction = [getPosATL _house, 250, true] call ALiVE_fnc_getDominantFaction;
                if (isNil "_faction") then {
                    _faction = [getPosATL _house, 250 max _range, true] call ALiVE_fnc_getDominantFaction;
                };
            };
        } else {
            _faction = selectRandom (_logic getVariable ["factions", DEFAULT_FACTIONS]);
        };
        _record = (_logic getVariable ["houses", createHashMap]) get _houseID;
        if (!isNil "_faction" && {_logic getVariable ["active", false]} && {_houseID in (_logic getVariable "claims")} && {!isNil "_record"} && {_record select 1}) then {
            [_logic,"spawnGroup", [_house, _faction]] call ALiVE_fnc_CQB;
        };
    };

    case "finishSpawn": {
        private _force = if (!isNil "_args") then {_args} else {false};

        private _house = _logic getVariable ["spawningHouse", objNull];
        private _grp = _logic getVariable ["spawningGroup", grpNull];
        private _registered = _house getVariable ["group", "preinit"];

        private _registry = _logic getVariable "houses";
        private _record = _registry get (hashValue _house);
        private _houseEnabled = !isNil "_record" && {_record select 1};

        if (
            _force ||
            { !_houseEnabled } ||
            { !((hashValue _house) in _registry) } ||
            { !alive _house } ||
            { !(_registered isEqualType grpNull) } ||
            { isNull _grp } ||
            { count units _grp == 0 }
        ) then {
            if (!isNull _grp) then {
                [_logic,"delGroup", _grp] call ALiVE_fnc_CQB;
            };

            if (!isNull _house) then {
                _house setVariable ["group", nil, true];

                // Back off failures, but allow immediate retries after cancellation.
                if (!_force && {_houseEnabled} && {(hashValue _house) in (_logic getVariable ["claims", createHashMap])} && {alive _house}) then {
                    _house setVariable ["ALIVE_CQB_nextDetect", time + 30];
                };
            };
        };

        _logic setVariable ["spawningHouse", nil];
        _logic setVariable ["spawningGroup", nil];
        _logic setVariable ["process", nil];

        private _queue = _logic getVariable ["spawnQueue", []];
        if (_queue isnotequalto [] && {(_queue select 0) isEqualTo _house}) then {
            _queue deleteAt 0;
        };
    };

    case "onFrame": {
        if (ALiVE_isGamePaused || { !(_logic getVariable "active") }) exitWith {};
        if (isNil QMOD(CQB) || {MOD(CQB) getVariable ["pause", false]}) exitWith {
            _logic setVariable ["spawnStage", "snapshot"];
        };

        private _claims = _logic getVariable "claims";
        switch (_logic getVariable ["spawnStage", "snapshot"]) do {
            case "snapshot": {
                private _sources = allPlayers - entities "HeadlessClient_F";
                if (!isNil "ALIVE_profileSystem" && {[ALIVE_profileSystem, "zeusSpawn"] call ALiVE_fnc_hashGet}) then {
                    {_sources pushBackUnique _x} forEach allCurators;
                };
                _logic setVariable ["spawnSources", _sources];
                _logic setVariable ["spawnSourceIndex", 0];
                _logic setVariable ["claimCycle", (_logic getVariable ["claimCycle", 0]) + 1];
                _logic setVariable ["spawnStage", "sources"];
            };
            case "sources": {
                private _sources = _logic getVariable "spawnSources";
                private _index = _logic getVariable "spawnSourceIndex";
                if (_index < count _sources) then {
                    [_logic,"claimHouses", _sources select _index] call ALiVE_fnc_CQB;
                    _logic setVariable ["spawnSourceIndex", _index + 1];
                } else {
                    // all spawn sources have been iterated
                    // Queue active houses that no source retained this cycle.
                    private _cycle = _logic getVariable "claimCycle";
                    {
                        (_claims get _x) params ["_house", "_claimedCycle"];
                        if (_claimedCycle != _cycle) then {
                            _claims deleteAt _x;
                            private _group = _house getVariable ["group", grpNull];
                            if (_group isEqualType grpNull && {!isNull _group}) then {
                                (_logic getVariable "despawnQueue") pushBackUnique _house;
                            };
                            if ((_house getVariable ["group", grpNull]) isEqualType "") then {
                                _house setVariable ["group", nil, true];
                            };
                        };
                    } forEach (keys _claims);

                    _logic setVariable ["checkedGroups", +(_logic getVariable ["groups", []])];
                    _logic setVariable ["checkedGroupIndex", 0];
                    _logic setVariable ["spawnStage", "groups"];
                };
            };
            case "groups": {
                // Check one group per frame; actual house cleanup goes through the queue.
                private _groups = _logic getVariable "checkedGroups";
                private _index = _logic getVariable "checkedGroupIndex";
                if (_index < count _groups) then {
                    private _grp = _groups select _index;
                    _logic setVariable ["checkedGroupIndex", _index + 1];
                    if (!isNull _grp && {!(_grp isEqualTo (_logic getVariable ["spawningGroup", grpNull]))}) then {
                        private _leader = leader _grp;
                        private _house = _leader getVariable ["house", _grp getVariable ["house", objNull]];
                        if (local _grp) then {
                            if (isNull _house) then {
                                [_logic, "delGroup", _grp] call ALiVE_fnc_CQB;
                            } else {
                                {
                                    if (isNil {_x getVariable "house"}) then {
                                        _x setVariable ["house", _house];
                                        _x setVariable ["ALIVE_profileIgnore", true];
                                    };
                                } forEach units _grp;
                                _grp setVariable ["house", _house];
                                _grp setVariable ["ALIVE_profileIgnore", true];
                                if (({alive _x} count units _grp) == 0 || {!alive _house}) then {
                                    (_logic getVariable "despawnQueue") pushBackUnique _house;
                                } else {
                                    if (!((hashValue _house) in _claims) && {_logic getVariable ["GarbageCollecting", true]}) then {
                                        (_logic getVariable "despawnQueue") pushBackUnique _house;
                                    };
                                };
                            };
                        };
                    };
                } else {
                    _logic setVariable ["groups", (_logic getVariable ["groups", []]) - [grpNull]];
                    _logic setVariable ["spawnStage", "snapshot"];
                };
            };
        };

        [_logic,"processDespawnQueue"] call ALiVE_fnc_CQB;
        [_logic,"processSpawnQueue"] call ALiVE_fnc_CQB;
    };

    case "processSpawnQueue": {
        private _queue = _logic getVariable ["spawnQueue", []];
        if (_queue isequalto []) exitWith {};

        private _house = _queue select 0;
        private _process = _logic getVariable "process";
        if (!isNil "_process") then {
            // spawn in progress
            if (scriptDone _process) then {
                [_logic,"finishSpawn"] call ALiVE_fnc_CQB;
            };
        } else {
            // start spawn process
            private _houses = _logic getVariable "houses";
            private _houseEntry = _houses get (hashValue _house);

            if (
                !isnil "_houseEntry" && 
                { (hashValue _house) in (_logic getVariable "claims") } &&
                { _record select 1 } &&
                {(_house getVariable ["group", grpNull]) isEqualType ""}
            ) then {
                _logic setVariable ["spawningHouse", _house];
                private _worker = [_logic, _house] spawn {
                    params ["_logic", "_house"];
                    [_logic,"spawnHouse", _house] call ALiVE_fnc_CQB;
                };
                _logic setVariable ["process", _worker];
            } else {
                _queue deleteAt 0;
                if (!isNull _house) then {
                    _house setVariable ["group", nil, true];
                };
            };
        };
    };

    case "processDespawnQueue": {
        private _queue = _logic getVariable ["despawnQueue", []];
        if (_queue isequalto []) exitWith {};

        private _house = _queue deleteAt 0;

        // finishSpawn validates the current worker's claims and cleans partial groups.
        if (isNull _house || {_house isEqualTo (_logic getVariable ["spawningHouse", objNull])}) exitWith {};

        private _grp = _house getVariable ["group", grpNull];
        if (
            !(_grp isEqualType grpNull) ||
            {isNull _grp} ||
            {!local _grp}
        ) exitWith {};

        if (
            ({alive _x} count units _grp) == 0 ||
            {!alive _house}
        ) then {
            [_logic,"clearHouse", _house] call ALiVE_fnc_CQB;
        } else {
            // Revalidate: another source may have reclaimed this house while it waited.
            if (!((hashValue _house) in (_logic getVariable "claims")) && {_logic getVariable ["GarbageCollecting", true]}) then {
                [_logic,"delGroup", _grp] call ALiVE_fnc_CQB;
            };
        };
    };

    case "active": {
        if (isNil "_args") exitWith {
            _args = _logic getVariable ["active", false];
        };

        ASSERT_TRUE(_args isequaltype true, str _args);

        private _valueChanged = (_args isNotEqualTo (_logic getVariable "active"));
        _logic setVariable ["active", _args];

        if (_valueChanged) then {
            if (_args) then {
                [_logic,"positionGrid"] call ALiVE_fnc_CQB;

                _logic setVariable ["claims", createHashMap];
                _logic setVariable ["spawnQueue", []];
                _logic setVariable ["despawnQueue", []];
                _logic setVariable ["spawnSources", []];
                _logic setVariable ["spawnStage", "snapshot"];
                _logic setVariable ["claimCycle", 0];

                private _pfh = [{
                    params ["_logic", "_handle"];
                    if (isNull _logic) exitWith {[_handle] call CBA_fnc_removePerFrameHandler};
                    [_logic,"onFrame"] call ALiVE_fnc_CQB;
                }, 0, _logic] call CBA_fnc_addPerFrameHandler;
                _logic setVariable ["spawnPFH", _pfh];
            } else {
                private _pfh = _logic getVariable ["spawnPFH", -1];
                [_pfh] call CBA_fnc_removePerFrameHandler;
                _logic setVariable ["spawnPFH", nil];

                private _process = _logic getVariable "process";
                if (!isNil "_process") then {
                    terminate _process;
                    [_logic,"finishSpawn", true] call ALiVE_fnc_CQB;
                };

                {
                    if ((_x getVariable ["group", grpNull]) isEqualType "") then {
                        _x setVariable ["group", nil, true];
                    };
                } forEach (_logic getVariable ["spawnQueue", []]);

                _logic setVariable ["spawnQueue", []];
                _logic setVariable ["despawnQueue", []];
                _logic setVariable ["spawnSources", []];
                _logic setVariable ["claims", createHashMap];
            };
        };
    };
};

PROFILE_SCOPE_END(OPERATION)

if !(isnil "_args") then {_args} else {nil};
