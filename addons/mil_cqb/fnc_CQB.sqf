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
            if !(isnil {_logic getVariable "initGlobal"}) exitwith {["ALiVE MIL CQB - Only one init process per instance allowed! Exiting..."] call ALiVE_fnc_Dump};

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

            private _CQB_density = _logic getvariable ["CQB_DENSITY","1000"];
            if (_CQB_density isequaltype "") then {_CQB_density = call compile _CQB_density};
            _logic setVariable ["CQB_DENSITY", _CQB_density];

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
            if (_staticWeaponsIntensity isequaltype "") then {_staticWeaponsIntensity = call compile _staticWeaponsIntensity};
            _logic setVariable ["CQB_staticWeapons", _staticWeaponsIntensity];

            private _staticWeaponsClassnames = _logic getvariable ["CQB_staticWeaponsClassnames","B_HMG_01_high_F,O_Mortar_01_F,O_HMG_01_high_F"];
			_staticWeaponsClassnames = _staticWeaponsClassnames call ALiVE_fnc_stringListToArray;
			if (count _staticWeaponsClassnames == 0) then { _staticWeaponsClassnames = DEFAULT_STATICWEAPONS };
            _logic setVariable ["CQB_staticWeaponsClassnames", _staticWeaponsClassnames];

            private _type = _logic getvariable ["CQB_TYPE","regular"];
            _logic setVariable ["type", _type];

            private _locality = _logic getvariable ["CQB_locality_setting","server"];
            _logic setVariable ["locality", _locality];

            private _factions = _logic getvariable ["CQB_FACTIONS",DEFAULT_FACTIONS];
            _factions = [_logic,"factions",_factions] call ALiVE_fnc_CQB;

            private _useDominantFaction = _logic getvariable ["CQB_UseDominantFaction","true"];
            if (_useDominantFaction isEqualType "") then {_useDominantFaction = (_useDominantFaction == "true")};
            _logic setVariable ["CQB_UseDominantFaction", _useDominantFaction];

            private _CQB_Locations = _logic getvariable ["CQB_LOCATIONTYPE","towns"];

            if (isnil QMOD(smoothSpawn)) then {MOD(smoothSpawn) = 0.3};

            [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call ALiVE_fnc_CQB;
            [_logic, "whitelist", _logic getVariable ["whitelist", DEFAULT_WHITELIST]] call ALiVE_fnc_CQB;

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

                private ["_collection","_center", "_radius","_objectives"];

                _center = getArray(configFile >> "CfgWorlds" >> worldName >> "centerPosition");
                _radius = (((_center select 0) max (_center select 1)) * sqrt(2))*2;
                _collection = [];
                _objectives = [];

                if (count synchronizedObjects _logic > 0) then {
                    for "_i" from 0 to ((count synchronizedObjects _logic) - 1) do {

                        _mod = (synchronizedObjects _logic) select _i;

                        if ((typeof _mod) in ["ALiVE_mil_placement","ALiVE_civ_placement"]) then {
                            waituntil {_mod getVariable ["startupComplete", false]};

                            _obj = [_mod,"objectives",objNull,[]] call ALIVE_fnc_OOsimpleOperation;
                            _objectives = _objectives + _obj;

                            {_collection pushback [([_x,"center"] call ALiVE_fnc_HashGet), ([_x,"size"] call ALiVE_fnc_HashGet)]} foreach _objectives;

                            ["ALiVE CQB Houses loaded from MIL/CIV Placement module!"] call ALiVE_fnc_Dump;
                        };

                        if (typeof _mod == "ALiVE_mil_OPCOM") then {
                            _collection = [[_center, _radius]];

                            _faction1 = _mod getvariable ["faction1","OPF_F"];
                            _faction2 = _mod getvariable ["faction2","NONE"];
                            _faction3 = _mod getvariable ["faction3","NONE"];
                            _faction4 = _mod getvariable ["faction4","NONE"];
                            _factions = [_mod, "convert", _mod getvariable ["factions",[]]] call ALiVE_fnc_OPCOM;

                            if ((count _factions) == 0) then {{if (!(_x == "NONE") && {!(_x in _factions)}) then {_factions pushBack _x}} foreach [_faction1,_faction2,_faction3,_faction4]};

                            _factions = [_logic,"factions",_factions] call ALiVE_fnc_CQB;
                            _logic setVariable ["CQB_UseDominantFaction", false];

                            ["ALiVE CQB Houses prepared for use with OPCOM Insurgency!"] call ALiVE_fnc_Dump;
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

                    ["ALiVE CQB Houses loaded from map!"] call ALiVE_fnc_Dump;
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 2

                private ["_houses","_total","_result","_debugColor"];

                //Get all enterable houses
                _houses = []; {_houses = _houses + ([_x select 0, _x select 1] call ALiVE_fnc_getEnterableHouses)} foreach _collection;

                TRACE_TIME(QUOTE(COMPONENT),[]); // 3

                _total = [_houses, _strategicTypes, _CQB_density, _CQB_spawn, [_logic, "blacklist"] call ALiVE_fnc_CQB, [_logic, "whitelist"] call ALiVE_fnc_CQB] call ALiVE_fnc_CQBsortStrategicHouses;

                switch (_type) do {
                    case ("regular") : {_result = _total select 1; _debugColor = "ColorGreen"};
                    case ("strategic") : {_result = _total select 0; _debugColor = "ColorRed"};
                    default {_result = _total select 1; _debugColor = "ColorGreen"};
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 4

                //set default values on main CQB instance
                [MOD(CQB), "allHouses", (MOD(CQB) getvariable ["allHouses",[]]) + _result] call ALiVE_fnc_CQB;
                [MOD(CQB), "allFactions", (MOD(CQB) getvariable ["allFactions",[]]) + _factions] call ALiVE_fnc_CQB;

                TRACE_TIME(QUOTE(COMPONENT),[]); // 5

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

                    ["ALiVE CQB DATA loaded from DB! CQB states were reset!"] call ALiVE_fnc_Dump;
                };

                TRACE_TIME(QUOTE(COMPONENT),[]); // 7

                /*
                CONTROLLER  - coordination
                - Start CQB Controller on Server
                */

                [_logic, "GarbageCollecting", true] call ALiVE_fnc_CQB;
                [_logic, "active", true] call ALiVE_fnc_CQB;

                //Indicate startup is done on server for that instance
                _logic setVariable ["init",true,true];
                _logic setVariable ["startupComplete",true,true];

                if ({!(_x getVariable ["init",false])} count (MOD(CQB) getvariable ["instances",[]]) == 0) then {
                    //Indicate all instances are initialised on server
                    MOD(CQB) setVariable ["startupComplete",true,true];
                };

                //and publicVariable instance to clients
                Publicvariable _id;

                #ifdef DEBUG_MODE_FULL
                    ["ALiVE CQB State: %1",([_logic, "state"] call ALiVE_fnc_CQB)] call ALiVE_fnc_Dump;
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

                //Delete markers
                [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call ALiVE_fnc_CQB;
                {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_BLACKLIST]);
                [_logic, "whitelist", _logic getVariable ["whitelist", DEFAULT_WHITELIST]] call ALiVE_fnc_CQB;
                {_x setMarkerAlpha 0} foreach (_logic getVariable ["whitelist", DEFAULT_WHITELIST]);
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
                    ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_Dump;
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

        private ["_houses","_housesPending","_color","_prefix","_housesTotal"];

        _houses = _logic getvariable ["houses",[]];
        _housesPending = _logic getvariable ["houses_pending",[]];
        _color = _logic getVariable ["debugColor","ColorGreen"];
        _prefix = _logic getVariable ["debugPrefix","CQB"];

        _houses = _houses - _housesPending;
        _housesPending = _housesPending - _houses;
        _housesTotal = _housesPending + _houses;

        if (_args) then {

            [{
                private _type = if (isNil {_x getVariable "group"}) then { "mil_dot" } else { "Waypoint" };
                private _alpha = if (_x in _housesPending) then { 0.2 } else { 1 };

                [format[MTEMPLATE, _x], getposATL _x,"ICON", [0.5,0.5],_color,_prefix,_type,"FDiagonal",0,_alpha] call ALIVE_fnc_createMarkerGlobal;

                private _sector = [ALIVE_sectorGrid, "positionToSector", getPosATL _x] call ALIVE_fnc_sectorGrid;
                private _subSector = [_sector, SUBGRID_SIZE, getPosATL _x] call ALiVE_fnc_positionToSubSector;
                private _subSectorID = [_subSector, "id"] call ALiVE_fnc_sector;
                private _subSectorPosition = [_subSector, "position"] call ALiVE_fnc_sector;
                private _subSectorDimensions = [_subSector, "dimensions"] call ALiVE_fnc_sector;

                if (getMarkerType (format [GTEMPLATE, _subSectorID]) == "") then {
                    [format[GTEMPLATE, _subSectorID], _subSectorPosition, "RECTANGLE", _subSectorDimensions, "ColorBlack", _subSectorID, "", "Solid", 0, 0.6] call ALIVE_fnc_createMarkerGlobal;
                };

                if (getMarkerType (format [STEMPLATE, _subSectorID]) == "") then {
                    [format[STEMPLATE, _subSectorID], _subSectorPosition, "ICON", [0.5, 0.5], "ColorBlack", _subSectorID, "mil_dot", "FDiagonal", 0, 1] call ALIVE_fnc_createMarkerGlobal;
                };
            },_houses + _housesPending,10] call ALiVE_fnc_arrayFrameSplitter;
        } else {
            [{
                deleteMarker format[MTEMPLATE, _x];
                deleteMarker format[GTEMPLATE, _x getVariable ["sectorID", ""]];
                deleteMarker format[STEMPLATE, _x getVariable ["sectorID", ""]];
            },_housesTotal,10] call ALiVE_fnc_arrayFrameSplitter;
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
                private ["_hash","_type"];
                _hash = [] call ALiVE_fnc_HashCreate;

                switch (_logic getVariable ["instancetype","regular"]) do {
                    case ("regular") : {_type = "R"};
                    case ("strategic") : {_type = "S"};
                };

                [_hash,"id",_logic getVariable "id"] call ALiVE_fnc_HashSet;
                [_hash,"instancetype",_logic getVariable "instancetype"] call ALiVE_fnc_HashSet;
                [_hash,"pos",[getPosATL _x select 0,getPosATL _x select 1]] call ALiVE_fnc_HashSet;
                [_hash,"house",typeOf _x] call ALiVE_fnc_HashSet;
                [_hash,"units",_x getVariable "unittypes"] call ALiVE_fnc_HashSet;

                //Get data Identifyer
                [_hash,"_rev",_x getVariable "_rev"] call ALiVE_fnc_hashSet;

                [_data,_id,_hash] call ALiVE_fnc_HashSet;
            } forEach (_logic getVariable "houses");

            [_state, "houses", _data] call ALiVE_fnc_hashSet;

            _args = _state;
            //_args call AliVE_fnc_InspectHash;
        } else {
            private["_houses","_groups","_data","_idIn","_idOut"];

            //Exit if wrong dataset is provided
            _idIn = [_args, "id","in"] call ALiVE_fnc_hashGet;
            _idOut = _logic getvariable ["id","out"];

            if !(_idIn == _idOut) exitwith {};

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

            //Restore houselist and groups if a houselist is provided
            if (count (([_args, "houses",["",[],[],nil]] call ALiVE_fnc_hashGet) select 1) > 0) then {

                //Reset groups and markers
                {[_logic, "delGroup", _x] call ALiVE_fnc_CQB} forEach (_logic getVariable ["groups",[]]);
                {
                    deleteMarker format[MTEMPLATE, _x];
                    deleteMarker format[GTEMPLATE, _x getVariable ["sectorID", ""]];
                    deleteMarker format[STEMPLATE, _x getVariable ["sectorID", ""]];
                } foreach (_logic getVariable ["houses",[]]);

                //Reset dynamic houselist and groups
                _logic setVariable ["houses",[]];
                _logic setVariable ["groups",[]];

                //Collect new houselist
                _data = [];
                {
                    private["_house"];

                    if (([_x,"instancetype","regular"] call ALiVE_fnc_HashGet) == ([_logic,"instancetype"] call ALiVE_fnc_CQB)) then {
                        _house = ([_x,"pos",[0,0,0]] call ALiVE_fnc_HashGet) nearestObject ([_x,"house",""] call ALiVE_fnc_HashGet);
                        _house setVariable ["unittypes",([_x,"units"] call ALiVE_fnc_HashGet), true];

                        //Set data Identifyer
                        _house setVariable ["_rev",([_x,"_rev"] call ALiVE_fnc_HashGet), true];

                        _data pushback _house;
                    };
                } forEach (([_args, "houses"] call ALiVE_fnc_hashGet) select 2);

            //If no houselist was provided take the existing houselist
            } else {
                _data = _logic getVariable ["houses",[]];
            };

            //Apply houselist
            [_logic, "houses", _data] call ALiVE_fnc_CQB;

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
            // if new dataset was provided store it

            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

            _logic setVariable ["allHouses", _args];
        };

        _args = _logic getVariable ["allHouses", []];
    };

    case "houses": {
        private ["_houses", "_debug"];
        _houses = [];
        _debug = _logic getVariable ["debug", false];

        if(!isNil "_args") then {
            ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

            if (_debug) then {
                { // forEach
                    deleteMarker format[MTEMPLATE, _x];
                    deleteMarker format[GTEMPLATE, _x getVariable ["sectorID", ""]];
                    deleteMarker format[STEMPLATE, _x getVariable ["sectorID", ""]];
                } forEach (_logic getVariable ["houses", []]);
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
                            _houses pushBack _x;
                            _x setVariable ["sectorID", _subSectorID];
                        };
                    };
                };
            } forEach _args;

            //Set houselist
            _logic setVariable ["houses", _houses, true];

            // mark all strategic and non-strategic houses in debug
            if (_debug) then {
                [_logic, "debug", true] call MAINCLASS;
            };
        };

        _houses
    };

    case "addHouse": {
        if(!isNil "_args") then {
            ASSERT_TRUE(typeName _args == "OBJECT",str typeName _args);
            private ["_house","_m"];
            _house = _args;

            [_logic,"houses",[_house],true,true] call BIS_fnc_variableSpaceAdd;

            if (_logic getVariable ["debug", false]) then {
                ["CQB Population: Adding house %1...", _house] call ALiVE_fnc_Dump;
                [_logic, "debug", true] call MAINCLASS;
            };
        };
    };

    case "clearHouse": {
        if(!isNil "_args") then {
            ASSERT_TRUE(typeName _args == "OBJECT",str typeName _args);
            private ["_house","_grp","_sectorID"];
            _house = _args;
            _sectorID = _house getvariable ["sectorID","none"];

            // delete the group
            _grp = _house getVariable "group";

            if (!(isNil "_grp") && {({alive _x} count (units _grp) == 0)}) then {

                //Remove group from list but dont delete bodies (done by GC)
                if (_logic getVariable ["debug", false]) then {
                    ["CQB Population: Removing group %1...", _grp] call ALiVE_fnc_Dump;
                };
                [_logic,"groups",[_grp],true,true] call BIS_fnc_variableSpaceRemove;

                //Remove house from list
                if (_logic getVariable ["debug", false]) then {
                    ["CQB Population: Clearing house %1...", _house] call ALiVE_fnc_Dump;
                };
                [_logic,"houses",[_house],true,true] call BIS_fnc_variableSpaceRemove;
                [MOD(CQB),"houses",[_house],true,true] call BIS_fnc_variableSpaceRemove;

                private _parentSectorID = ((_sectorID splitString "_") select [0, 2]) joinString "_";
                private _parentCount = 0;
                private _count = 0;

                {
                    private _houseSectorID = _x getVariable ["sectorID", "in"];
                    private _houseParentSectorID = ((_houseSectorID splitString "_") select [0, 2]) joinString "_";
                    _count = _count + (parseNumber (_houseSectorID == _sectorID));
                    _parentCount = _parentCount + (parseNumber (_houseParentSectorID == _parentSectorID));
                } forEach (MOD(CQB) getvariable ["houses",[]]);

                // 100x100m sub sector doesn't have any CQB houses
                if (_count == 0) then {
                    ["ALiVE MIL CQB Cleared sub sector %1!", _sectorID] call ALiVE_fnc_Dump;

                    private _cleared = MOD(CQB) getVariable ["cleared", []];
                    _cleared pushBack _sectorID;

                    deleteMarker format[GTEMPLATE, _house getVariable ["sectorID", ""]];
                    deleteMarker format[STEMPLATE, _house getVariable ["sectorID", ""]];

                    // 1x1km sector doesn't have any CQB houses
                    if (_parentCount == 0) then {
                        ["ALiVE MIL CQB Cleared sector %1!", _parentSectorID] call ALiVE_fnc_Dump;
                        _cleared pushBack _parentSectorID;

                        // Remove sub sectors from cleared variable
                        for "_x" from 0 to SUBGRID_SIZE do {
                            for "_y" from 0 to SUBGRID_SIZE do {
                                private _id = format ["%1_%2_%3", _parentSectorID, _x, _y];
                                _cleared deleteAt (_cleared find _id);
                            };
                        };
                    };
                };
            } else {
                ["ALiVE MIL CQB Warning: Group %1 is still alive! Removing...", _grp] call ALiVE_fnc_Dump;

                [_logic, "delGroup", _grp] call ALiVE_fnc_CQB;
                [_logic,"houses",[_house],true,true] call BIS_fnc_variableSpaceRemove;
            };

            deleteMarker format[MTEMPLATE, _house];
        };
    };

    case "GarbageCollecting": {
            if(isNil "_args") then {
                // if no arguments provided return current setting
                _args = _logic getVariable ["GarbageCollecting", false];
            } else {
                // if an argument is provided then execute
                ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);
                _logic setVariable ["GarbageCollecting", _args, true];

                // if false then exit GC
                if !(_args) exitwith {};

                //else run a GC for each instance, until it is deleted
                private _spawn = _logic getVariable ["spawnDistance", 700];
                private _spawnStatic = _logic getVariable ["spawnDistanceStatic", 1200];
                private _spawnHeli = _logic getVariable ["spawnDistanceHeli", 0];
                private _spawnJet = _logic getVariable ["spawnDistanceJet", 0];

                _GC = [_logic,_spawn, _spawnStatic, _spawnHeli,_spawnJet] spawn {
                    private _logic = _this select 0;
                    private _spawn = _this select 1;
                    private _spawnStatic = _this select 2;
                    private _spawnHeli = _this select 3;
                    private _spawnJet = _this select 4;

                    while {_logic getVariable ["GarbageCollecting",false]} do {
                        sleep 30;
                        {
                           private _lead = leader _x;

                           // add static weapon distance to spawn distance
                           private _staticRange = 0;
                           if (!isNil {(_lead getVariable "house") getVariable "staticWeapons"}) then {
                               _staticRange = 0 max (_spawnStatic - _spawn);
                           };

                            if ((local _lead) && {!([getposATL _lead, (_spawn + _staticRange) * 3, _spawnJet*3,_spawnHeli*3] call ALiVE_fnc_anyPlayersInRangeIncludeAir)}) then {[_logic, "delGroup", _x] call ALiVE_fnc_CQB};
                        } forEach (_logic getVariable ["groups",[]]);
                    };
                };
        };
        _args;
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

            // if a house is not enterable, you can't spawn AI on it
            if (!([_house] call ALiVE_fnc_isHouseEnterable)) exitWith {
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
        if(!isNil "_args") then {
            ASSERT_TRUE(typeName _args == "GROUP",str typeName _args,_leader);
            private ["_grp","_house"];
            _grp = _args;
            _leader = leader _grp;
            _house = _leader getVariable "house";

            // Update house that group despawned
            if !(isnil "_house") then {
                _house setVariable ["group",nil, true];
                format[MTEMPLATE, _house] setMarkerType "mil_Dot";
            };

            if (isnil "_grp") exitwith {
                _house setVariable ["group",nil, true];
            };

            // Despawn group
            if (_logic getVariable ["debug", false]) then {
                ["CQB Population: Deleting group %1 from %2...", _grp, owner _leader] call ALiVE_fnc_Dump;
            };

            [_logic,"groups",[_grp],true,true] call BIS_fnc_variableSpaceRemove;

            {deleteVehicle _x} forEach units _grp;

            // FIX YOUR FUCKING CODES BIS. FINALLY. AFTER 239475987 gazillion years
            _grp call ALiVE_fnc_DeleteGroupRemote;
        };
    };

    case "spawnGroup": {
        if(isNil "_args") then {
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

                _amount = ceil(random(_logic getVariable ["amount",2]));

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

            _grp = createGroup _side;

            {if !(isnil "_x") then {_unit = _grp createUnit [_x, getPosATL _house, [], 0 , "NONE"]}; sleep MOD(smoothSpawn)} foreach _units;

            if (count units _grp == 0) exitWith {
                if (_debug) then {
                    ["CQB Population: Group %1 deleted on creation - no units...", _grp] call ALiVE_fnc_Dump;
                };
                [_logic, "delGroup", _grp] call ALiVE_fnc_CQB;
            };

            // position AI
            _positions = [_house] call ALiVE_fnc_getBuildingPositions;

            if (count _positions == 0) exitwith {_args = _grp};

            [_logic, "addGroup", [_house, _grp]] call ALiVE_fnc_CQB;
            [_logic, "addStaticWeapons", [_house, _staticWeaponsIntensity]] call ALiVE_fnc_CQB;

            {
                private _unit = _x;

                {
                    private _pos = _x;

                    _unit setPosATL [_pos select 0, _pos select 1, (_pos select 2 + 0.4)];
                } foreach _positions;

            } forEach (units _grp);

            // TODO Notify controller to start directing
            // TODO this needs to be refactored
            _fsm = "\x\alive\addons\mil_cqb\HousePatrol.fsm";
            _hdl = [_logic,(leader _grp), 50, true, 60] execFSM _fsm;
            (leader _grp) setVariable ["FSM", [_hdl,_fsm], true];
            _args = _grp;
        };
        _args;
    };

    case "addStaticWeapons": {

	    if (isNil "_args" || {count _args < 2} || {isNull (_args select 0)} || {_args select 1 <= 0}) exitWith {

            //["ALiVE CQB Input does not allow for creation of static weapons: %1!",_args] call ALiVE_fnc_Dump;

	    	_args = [];

            _args;
	    };

		private _building = _args select 0;
        private _count = _args select 1;

        private _buildingPosition = getposATL _building;

        private _staticWeapons = _building getvariable ["staticWeapons",[]];

        if ({alive _x} count _staticWeapons > 0) exitwith {

            //["ALiVE CQB Static weapons exisiting: %1! Not creating new ones...",_staticWeapons] call ALiVE_fnc_DumpR;

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

        //["ALiVE CQB Found building positions: %1",_positions] call ALiVE_fnc_DumpR;

		{
		    private _position = AGLtoASL _x;
		    private _checkPos = +_position; _checkPos set [2,(_checkpos select 2) + 10];

		    if (count lineIntersectsSurfaces [_position,_checkPos] == 0) then {
		        _onTop pushBack (ASLtoAGL _position)
		    };
		} foreach _positions;

        //["ALiVE CQB Found on top positions: %1",_onTop] call ALiVE_fnc_DumpR;

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

            //["ALiVE CQB Static weapons created: %1",_staticWeapons] call ALiVE_fnc_DumpR;
        };

		_args = _staticWeapons;

        _args;
    };

    case "active": {
    if(isNil "_args") exitWith {
        _args = _logic getVariable ["active", false];
    };

    ASSERT_TRUE(typeName _args == "BOOL",str _args);

    // xor check args is different to current debug setting
    if(
        ((_args || (_logic getVariable ["active", false])) &&
        !(_args && (_logic getVariable ["active", false])))
    ) then {
        ASSERT_TRUE(typeName _args == "BOOL",str _args);
        _logic setVariable ["active", _args];

        // if active
        if (_args) then {

            // spawn loop
            _process = _logic spawn {
                private ["_logic","_units","_grp","_positions","_house","_debug","_spawn","_spawnStatic","_spawnHeli","_spawnJet","_maxgrps","_leader","_despawnGroup","_host","_players","_hosts","_faction","_useDominantFaction","_inRange","_locality","_pause","_spawnPool"];

                _logic = _this;

                // default functions - can be overridden
                // over-arching spawning loop
                    waitUntil {
                        sleep (2 + random 1);
                        _debug = _logic getVariable ["debug",false];
                        _spawn = _logic getVariable ["spawnDistance", 700];
                        _spawnStatic = _logic getVariable ["spawnDistanceStatic", 1200];
                        _spawnHeli = _logic getVariable ["spawnDistanceHeli", 0];
                        _spawnJet = _logic getVariable ["spawnDistanceJet", 0];
                        _locality = _logic getVariable ["locality", "server"];
                        _useDominantFaction = _logic getvariable ["CQB_UseDominantFaction",false];

                        //[true,"cqb_performance","cqb_performance"] call ALiVE_fnc_Timer;

                        if (!isnil QMOD(CQB) && {!(MOD(CQB) getVariable ["pause", false])}) then {

							_spawnPool = [];

                            [{
                                // if conditions are right, spawn a group and place them
                                _house = _x;

                                // Check: house doesn't already have AI AND
                                // Check: if any players within spawn distance

                                // add static weapon distance to spawn distance
                                private _staticRange = 0;
                                if (!isNil {_house getVariable "staticWeapons"}) then {
                                    _staticRange = 0 max (_spawnStatic - _spawn);
                                };

                                _nearplayers = [getposATL _house,_spawn + _staticRange,_spawnJet,_spawnHeli] call ALiVE_fnc_PlayersInRangeIncludeAir;
                                if ((isNil {_house getVariable "group"}) && {count _nearplayers > 0}) then {

                                        switch (_locality) do {
                                            default {
                                                _hosts = [false];
                                            };
                                        };

                                        if (count _hosts > 0) then {
                                            _host = (selectRandom _hosts);

                                            if !(isnil "_host") then {
                                                _house setvariable ["group","preinit",true];

                                                if (_useDominantFaction) then {
                                                    _faction = [getposATL _house, 250,true] call ALiVE_fnc_getDominantFaction;

                                                    if (isnil "_faction") then {_faction = (selectRandom (_logic getvariable ["factions",DEFAULT_FACTIONS]))};
                                                } else {
                                                    _faction = (selectRandom (_logic getvariable ["factions",DEFAULT_FACTIONS]));
                                                };


                                                /////////////////////////////////////////////////////////////
                                                _spawnPool pushback [_house,_faction,_host];

                                                //["CQB Population: Group creation triggered on client %1 for house %2 and dominantfaction %3...",_host,_house,_faction] call ALiVE_fnc_Dump;
                                                //sleep 0.2;
                                            } else {
                                                //["CQB ERROR: Nil object on host %1",_host] call ALiVE_fnc_DumpR;
                                            };
                                        } else {
                                            //["CQB ERROR: No playerhosts for house %1!",_house] call ALiVE_fnc_DumpR;
                                        };
                                };
                            },_logic getVariable ["houses", []],10] call ALiVE_fnc_arrayFrameSplitter;

                            {[[_logic, "spawnGroup", [_x select 0,_x select 1]],"ALiVE_fnc_CQB",_x select 2,false,false] call BIS_fnc_MP; sleep MOD(smoothSpawn)} foreach _spawnPool;

                            [{
                                _grp = _x;

                                if !(isnil "_grp" || {isnull _grp}) then {
                                    _leader = leader _grp;

                                    // get house in question
                                    _house = _leader getVariable ["house",(_grp getvariable "house")];

                                    //If house is defined then... (can be disabled due to "object streaming")
                                    if !(isnil "_house") then {

                                        // Initializing group variables locally on all units to save PVs (see addgroup and deletgroup). Additionally public setvariable flag doesnt work for groups (only objects)
                                        // If not all units have been flagged yet then flag them;
                                        // Use only "house" variable as indicator if flagging has been done already, to save performance
                                        if (({!(isnil {_x getvariable ["house",nil]})} count (units _grp)) != (count units _grp)) then {
                                            {
                                                _x setvariable ["house",_house];
                                                _x setvariable ["ALIVE_profileIgnore",true];
                                            } foreach (units _grp);

                                            _grp setvariable ["house",_house];
                                            _grp setvariable ["ALIVE_profileIgnore",true];
                                        };

                                        // if group are all dead
                                        // mark house as cleared
                                        if (({alive _x} count (units _grp) == 0) || {!alive _house}) then {

                                            if (isnil "_house") exitwith {["CQB ERROR: _House didnt exist, when trying to clear it!"] call ALiVE_fnc_DumpR};

                                            // update central CQB house listings
                                            [_logic, "clearHouse", _house] call ALiVE_fnc_CQB;
                                        };
                                    } else {
                                        ["CQB ERROR: No House was defined for CQB group %1! Count units in group that have _house set: %2", _grp, {!(isnil {_x getvariable ["house",nil]})} count (units _grp)] call ALiVE_fnc_DumpR;
                                        [_logic, "delGroup", _grp] call ALiVE_fnc_CQB;
                                    };
                                } else {
                                    ["CQB ERROR: No Group was defined! Cleaning up..."] call ALiVE_fnc_DumpR;

                                    _logic setvariable ["groups",(_logic getVariable ["groups",[]]) - [grpNull]];
                                };

                            },_logic getVariable ["groups",[]],4] call ALiVE_fnc_arrayFrameSplitter;

                            if (_debug) then {

                                {
		                            _remaincount = count (_logic getVariable ["houses", []]);
		                            _housesempty = {(isNil {_x getVariable "group"})} count (_logic getVariable ["houses", []]);
		                            _activecount = count (_logic getVariable ["groups", []]);
		                            _groupsempty = {(isNil {(leader _x) getVariable "house"})} count (_logic getVariable ["groups", []]);

		                           ["CQB Population: %1 remaing positions | %2 active positions | inactive houses %3 | groups with no house %4...", _remaincount, _activecount,_housesempty,_groupsempty] call ALiVE_fnc_Dump;
                               } call CBA_fnc_DirectCall;
                            };
                        };

                        //[false,"cqb_performance","cqb_performance"] call ALiVE_fnc_Timer;

                        !([_logic,"active"] call ALiVE_fnc_CQB);
                    }; // end over-arching loop

                    // clean up groups if deactivated
                    {
                        [_logic, "delGroup", _x] call ALiVE_fnc_CQB;
                    } forEach (_logic getVariable ["groups",[]]);

                    //Clean up process entry
                    _logic setvariable ["process",nil];

                }; // end spawned process

                // Set process
                _logic setvariable ["process",_process];
            } else {
                private ["_handle"];

                // Switch off process
                _handle = _logic getvariable "process";

                if !(isnil "_handle") then {
                    terminate _handle; _logic setvariable ["process",nil];
                };
            }; // end
        };
    };
};
if !(isnil "_args") then {_args} else {nil};
