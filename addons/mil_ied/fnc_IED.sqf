#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(ied);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_IED
Description:
Creates the server side object to store settings

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enabled

INT - IED_Threat -
        values[]= {0,50,100,200,350};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 50;
INT - Starting_IED_Threat -
        values[]= {0,50,100,200,350};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 0;
INT - Bomber_Threat -
        values[]= {0,10,20,30,50};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 10;
INT - Locs_IED -
        values[]= {0,1,2};
        texts[]= {"Random","Enemy Occupied Only","Unoccupied"};
        default = 0;
INT - Ambient_VB-IEDs -
        values[]= {0,5,10,15,30};
        texts[]= {"None","Low","Med","High","Extreme"};
        default = 5;


Examples:
(begin example)
// Create instance by placing editor module and specifiying name myModule
(end)

See Also:
- <ALIVE_fnc_IEDInit>
- <ALIVE_fnc_IEDMenuDef>

Author:
Tupolov, modificationss by Trapw0w

Peer reviewed:
nil

// Arma 2 Classes
DEFAULT_ROADIEDS ["Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC"];
DEFAULT_URBANIEDS ["Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC","Land_IED_v1_PMC","Land_IED_v2_PMC","Land_IED_v3_PMC","Land_IED_v4_PMC","Land_Misc_Rubble_EP1","Land_Misc_Garb_Heap_EP1","Garbage_container","Misc_TyreHeapEP1","Misc_TyreHeap","Garbage_can","Land_bags_EP1"];
DEFAULT_CLUTTER [Land_Misc_Rubble_EP1","Land_Misc_Garb_Heap_EP1","Garbage_container","Misc_TyreHeapEP1","Misc_TyreHeap","Garbage_can","Land_bags_EP1"]

---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClass
#define MAINCLASS ALIVE_fnc_ied
#define DEFAULT_BOMBER_THREAT 15
#define DEFAULT_IED_THREAT 60
#define DEFAULT_VB_IED_THREAT 5
#define DEFAULT_VB_IED_SIDE "CIV"
#define DEFAULT_LOCS_IED 0
#define DEFAULT_STARTING_IED_THREAT 0
#define DEFAULT_TAOR []
#define DEFAULT_BLACKLIST []
#define DEFAULT_ROADIEDS ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDUrbanBig_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"]
#define DEFAULT_URBANIEDS ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDUrbanBig_Remote_Ammo","Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Basket_F","Land_Sack_F","Land_Sacks_goods_F","Land_Sacks_heap_F","Land_BarrelTrash_F"]
#define DEFAULT_CLUTTER ["Land_JunkPile_F","Land_GarbageContainer_closed_F","Land_GarbageBags_F","Land_Tyres_F","Land_GarbagePallet_F","Land_Basket_F","Land_Sack_F","Land_Sacks_goods_F","Land_Sacks_heap_F","Land_BarrelTrash_F"]

private ["_logic","_operation","_args","_result"];

TRACE_1("IED - input",_this);

params [
    ["_logic", objNull, [objNull]], 
    ["_operation", "", [""]], 
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

_result = true;

switch(_operation) do {
        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
        case "create": {
                if (isServer) then {
                    // Ensure only one module is used
                    if !(isNil QUOTE(ADDON)) then {
                        _logic = ADDON;
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_IED_ERROR1");
                    } else {
                        _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];
                        ADDON = _logic;
                    };

                    //Push to clients
                    PublicVariable QUOTE(ADDON);
                };

                TRACE_1("Waiting for object to be ready",true);

                waituntil {!isnil QUOTE(ADDON)};

                _logic = ADDON;

                TRACE_1("Creating class on all localities",true);

                // initialise module game logic on all localities
                _logic setVariable ["super", SUPERCLASS];
                _logic setVariable ["class", MAINCLASS];

                _args = _logic;
        };
        case "init": {
                /*
                MODEL - no visual just reference data
                - server side object only
                - ied threat
                - vb-ied threat
                - bomber threat
                - ied locations
                */

                // Ensure only one module is used
                if (isServer && !(isNil QUOTE(ADDON))) exitWith {
                        ERROR_WITH_TITLE(str _logic, localize "STR_ALIVE_ied_ERROR1");
                };

                if (isServer) then {
                    // and publicVariable to clients
                    private ["_debug","_mapInfo","_center","_radius","_taor","_blacklist"];

                    _errorMessage = "Please include the Requires ALiVE module! %1 %2";
                    _error1 = ""; _error2 = ""; //defaults
                    if(
                        !(["ALiVE_require"] call ALiVE_fnc_isModuleavailable)
                       ) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    ADDON = _logic;

                    // Create store initially on server
                    GVAR(STORE) = [] call ALIVE_fnc_hashCreate;
                    GVAR(Loaded) = false;

                    // if server, initialise module game logic
                    ADDON setVariable ["super", SUPERCLASS];
                    ADDON setVariable ["class", MAINCLASS];
                    ADDON setVariable ["init", true, true];

                    [ADDON, "debug", _logic getVariable ["debug", false]] call MAINCLASS;
                    [ADDON, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
                    [ADDON, "blacklist", _logic getVariable ["blacklist", DEFAULT_BLACKLIST]] call MAINCLASS;
                    [ADDON, "roadIEDClasses", _logic getVariable ["roadIEDClasses", DEFAULT_ROADIEDS]] call MAINCLASS;
                    [ADDON, "urbanIEDClasses", _logic getVariable ["urbanIEDClasses", DEFAULT_URBANIEDS]] call MAINCLASS;
                    [ADDON, "clutterClasses", _logic getVariable ["clutterClasses", DEFAULT_CLUTTER]] call MAINCLASS;
                    [ADDON, "thirdParty", _logic getVariable ["thirdParty", false]] call MAINCLASS;

                    publicVariable QUOTE(ADDON);

                    _debug = [_logic, "debug"] call MAINCLASS;
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_TAOR]);

                    // Reset states with provided data;
                    if (_logic getvariable ["Persistence",false]) then {
                        if (isServer && {[QMOD(SYS_DATA)] call ALiVE_fnc_isModuleAvailable}) then {
                            waituntil {!isnil QMOD(SYS_DATA) && {MOD(SYS_DATA) getvariable ["startupComplete",false]}};
                        };

                        _state = [_logic, "load"] call MAINCLASS;
                        if !(typeName _state == "BOOL") then {
                            GVAR(STORE) = _state;
                            GVAR(Loaded) = true;
                            [_logic, "restoreTriggers", [GVAR(STORE), "triggers"] call ALiVE_fnc_hashGet] call MAINCLASS;
                            // DEBUG -------------------------------------------------------------------------------------
                            if(_debug) then { ["IED - IEDs have been loaded from Database"] call ALiVE_fnc_dump; };
                            // DEBUG -------------------------------------------------------------------------------------
                        } else {
                            ["ALiVE IED - No data loaded.. restoring defaults"] call ALiVE_fnc_dump;
                            [GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                            [GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                        };

                    } else {
                        [GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                        [GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashSet;
                    };

                    GVAR(STORE) call ALIVE_fnc_inspectHash;

                    //Push to clients
                    PublicVariable QGVAR(STORE);

                    [_logic,"start"] call MAINCLASS;

                } else {
                    [_logic, "taor", _logic getVariable ["taor", DEFAULT_TAOR]] call MAINCLASS;
                    [_logic, "blacklist", _logic getVariable ["blacklist", DEFAULT_TAOR]] call MAINCLASS;
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["taor", DEFAULT_TAOR]);
                    {_x setMarkerAlpha 0} foreach (_logic getVariable ["blacklist", DEFAULT_TAOR]);
                };

              TRACE_2("After module init",ADDON,ADDON getVariable "init");

                // and wait for game logic to initialise
                // TODO merge into lazy evaluation
                waitUntil {!isNil QUOTE(ADDON)};
                waitUntil {ADDON getVariable ["init", false]};

                /*
                VIEW - purely visual
                - initialise menu
                - frequent check to modify menu and display status (ALIVE_fnc_IEDmenuDef)
                */

                /*
                CONTROLLER  - coordination
                - frequent check if player is server admin (ALIVE_fnc_IEDmenuDef)
                */
                _result = ADDON;
        };
        case "start": {
            if (isServer) then {

                private ["_debug","_locations","_placement","_worldName","_file","_clusters","_cluster","_taor","_taorClusters","_blacklist",
                "_sizeFilter","_priorityFilter","_blacklistClusters","_center","_faction","_error"];

                _debug = [_logic, "debug"] call MAINCLASS;

                if(_debug) then {
                    ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                    ["IED - Startup"] call ALiVE_fnc_dump;
                    [true] call ALIVE_fnc_timer;
                };

                _taor = [_logic, "taor"] call MAINCLASS;
                _blacklist = [_logic, "blacklist"] call MAINCLASS;
                _side = _logic getvariable ["VB_IED_Side", DEFAULT_VB_IED_SIDE];

                if !(GVAR(Loaded)) then {
                    // Initialise Locations
                    _mapInfo = [] call ALIVE_fnc_getMapInfo;
                    _center = _mapInfo select 0;
                    _radius = _mapInfo select 2;

                    _locations = nearestLocations [_center, ["NameCityCapital","NameCity","NameVillage","Strategic"],_radius];

                    // check markers for existance
                    private ["_marker","_counter"];
                    if(count _blacklist > 0) then {
                        _locations = [_blacklist, _locations, false] call ALiVE_fnc_validateLocations;
                    };

                    if(count _taor > 0) then {
                        _locations = [_taor, _locations, true] call ALiVE_fnc_validateLocations;

                    };

                    if (count synchronizedObjects _logic > 0) then {
                        for "_i" from 0 to ((count synchronizedObjects _logic) - 1) do {
                            _mod = (synchronizedObjects _logic) select _i;
                            if (typeof _mod == "ALiVE_mil_OPCOM") then {
                                [_logic, "setupTriggers", [_locations, "starting"]] call MAINCLASS;
                                _locations = [];
                            };
                        };
                    } else {
                        if (!(_logic getVariable["IED_Starting_Threat",0] == 0) && _debug) then {
                            ["ALIVE MIL - Starting IED Threat set without being synced with the OPCOM Commander! Ignoring Starting Threat.."] call ALiVE_fnc_dump;
                        };
                    };
                } else {
                    if (count synchronizedObjects _logic == 0) then {
                        // Setup SBIEDs & VBIEDs as they're not yet persisted. Once these are persisted this code can be removed along with the locations hash
                        _locations = [];
                        _locs = {
                            if (_key == "_id" || _key == "_rev") exitWith {};
                            _loc = [_logic, "convertLocations", [[_value, "LocationObj"] call ALiVE_fnc_hashGet]] call MAINCLASS;
                            _locations pushBack _loc;
                        };

                        [[GVAR(STORE), "locations"] call ALiVE_fnc_hashGet, _locs] call CBA_fnc_hashEachPair;
                        ["ALiVE MIL IED - Setting up new SBIED & VBIED Locations"] call ALiVE_fnc_dump;
                        [_logic, "setupTriggers", [_locations, "regular", true]] call MAINCLASS;
                    };
                    // Data has already been loaded & triggers restored, ensure we don't loop a second time
                    _locations = [];
                };

                [_logic, "setupTriggers", [_locations, "regular"]] call MAINCLASS;

                // DEBUG -------------------------------------------------------------------------------------
                if ([_logic, "debug"] call MAINCLASS) then {
                    ["ALIVE IED - Startup completed"] call ALIVE_fnc_dump;
                    ["ALIVE IED - Count IED Triggers %1", count ([GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet select 1)] call ALIVE_fnc_dump;
                    [] call ALIVE_fnc_timer;
                };
                // DEBUG -------------------------------------------------------------------------------------

                // set module as started
                _logic setVariable ["startupComplete", true];
            };
        };
        case "setupTriggers": {
            private ["_iedThreat", "_startupIED", "_triggerType", "_locations", "_noIED"];
            
            _locations = _args select 0;
            _triggerType = _args select 1;
            if (count _args > 2) then {
                _noIED = _args select 2;
            } else {
                _noIED = false;
            };


            switch (_triggerType) do {
                case "starting": {
                    _startupIED = true;
                    _iedThreat = _logic getvariable ["IED_Starting_Threat", DEFAULT_STARTING_IED_THREAT];
                };
                case "regular": {
                    _startupIED = false;
                    _iedThreat = _logic getvariable ["IED_Threat", DEFAULT_IED_THREAT];
                };
            };

            // Set up Bombers and IED triggers at each location (except any player starting location)
            {
                private ["_fate","_pos","_trg","_twn"];

                //Get the location object
                _pos = position _x;
                _twn = (nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","Strategic"],200]) select 0;
                _size = (size _twn) select 0;
                if (_size < 250) then {_size = 250;};

                if (_debug) then {
                    diag_log format ["town is %1 at %2. %3m in size and type %4", text _twn, position _twn, _size, type _twn];
                };

                // Place triggers if not within distance of players
                if ({(getpos _x distance _pos) < _size} count ([] call BIS_fnc_listPlayers) == 0 || GVAR(Loaded)) then {
                    private ["_sidelist","_sideNum","_factions","_factionClasses"];

                    // If ALiVE Ambient civilians are available get the faction from there
                    if (["ALiVE_amb_civ_placement"] call ALiVE_fnc_isModuleAvailable) then {

                        waituntil {!isnil QMOD(amb_civ_placement)};

                        _factions = [ALiVE_amb_civ_placement getvariable ["faction","CIV_F"]];
                    } else {
                        // Else get faction from side
                        _factions = [];
                        _sidelist = ["EAST","WEST","IND","CIV"];
                        _blacklist = ["Virtual_F","Interactive_F"];
                        _sideNum = _sidelist find _side;
                        _factionClasses = (configfile >> "CfgFactionClasses");
                        for "_i" from 1 to (count _factionClasses - 1) do {
                            private "_element";
                            _element = _factionClasses select _i;
                            if (isclass _element) then {
                                if (getnumber(_element >> "side") == _sideNum && (_blacklist find (configName _element)) == -1) then {
                                    _factions pushback configName _element;
                                };
                            };
                        };
                    };

                    _faction = (selectRandom _factions);

                    //Roll the dice
                    if (GVAR(Loaded)) then {
                        _fate = 0;
                    } else {
                        _fate = random 33;
                    };

                    // Bombers
                    if (_fate < _logic getvariable ["Bomber_Threat", DEFAULT_BOMBER_THREAT] && !(_startupIED)) then {

                        // Place Suicide Bomber trigger

                        _trg = createTrigger["EmptyDetector",getpos _twn];

                        _trg setTriggerArea[(_size+250),(_size+250),0,false];

                        _trg setTriggerActivation["ANY","PRESENT",false];
                        _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, _faction], ""];

                        if (_debug) then {
                            diag_log format ["ALIVE-%1 Suicide Bomber Trigger: created at %2 (%3)", time, text _twn, mapgridposition  (getpos _twn)];
                        };

                        if !(GVAR(Loaded)) then {
                            private ["_locs", "_data"];
                            // Set location in store
                            _locs = [GVAR(STORE), "locations", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                            _data = [] call ALiVE_fnc_hashCreate;
                            [_data, "LocationObj", [_logic, "convertLocations", [_x]] call MAINCLASS] call ALiVE_fnc_hashSet;
                            [_locs, text _x, _data] call ALiVE_fnc_hashSet;

                            [GVAR(STORE), "locations", _locs] call ALiVE_fnc_hashSet;
                        };
                    };

                    // VBIEDs
                    if (_fate < _logic getvariable ["VB_IED_Threat", DEFAULT_VB_IED_THREAT] && !(_startupIED)) then {

                        // Place VBIED
                        _trg = createTrigger["EmptyDetector",getpos _twn];

                        _trg setTriggerArea[(_size+250),(_size+250),0,false];

                        _trg setTriggerActivation["ANY","PRESENT",false];
                        _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [getpos thisTrigger,%1] call ALIVE_fnc_placeVBIED",_size], ""];

                        if (_debug) then {
                            diag_log format ["ALIVE-%1 VBIED Trigger: created at %2 (%3)", time, text _twn, mapgridposition  (getpos _twn)];
                        };

                        if !(GVAR(Loaded)) then {
                            private ["_locs", "_data"];
                            // Set location in store
                            _locs = [GVAR(STORE), "locations", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                            _data = [] call ALiVE_fnc_hashCreate;
                            [_data, "LocationObj", [_logic, "convertLocations", [_x]] call MAINCLASS] call ALiVE_fnc_hashSet;
                            [_locs, text _x, _data] call ALiVE_fnc_hashSet;

                            [GVAR(STORE), "locations", _locs] call ALiVE_fnc_hashSet;
                        };
                    };

                    // IEDS
                    if (_fate < (_iedThreat / 3) && !(_noIED)) then {
                        // Place IED trigger
                        _trg = createTrigger["EmptyDetector",getpos _twn];

                        _trg setTriggerArea[(_size+250), (_size+250),0,false];

                        if (_startupIED) then {
                            _num = round ((_size / 50) * ( _iedThreat / 100));
                            _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated
                            _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [getpos thisTrigger,%1,""%2"",%3] call ALIVE_fnc_createIED",_size, text _twn, _num], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",text _twn]];
                            [_logic, "storeTrigger", [_size,text _twn,getPos _twn, false,"IED",_num]] call MAINCLASS;
                        } else {
                            _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated
                            _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [getpos thisTrigger,%1,""%2""] call ALIVE_fnc_createIED",_size, text _twn], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED", text _twn]];
                            [_logic, "storeTrigger", [_size,text _twn,getPos _twn, false, "IED"]] call MAINCLASS;
                        };

                        if (_debug) then {
                            diag_log format ["ALIVE-%1 IED Trigger: created at %2 (%3)", time, text _twn, mapgridposition  (getpos _twn)];
                        };
                    };

                };
            } foreach _locations;
        };
        // Return TAOR marker
        case "removeIED": {
                if(typeName _args == "OBJECT") then {
                    private ["_IED","_ID","_town","_hash"];
                    _IED = _args;
                    _ID = _IED getvariable ["ID", nil];
                    if (isNil "_ID") exitWith {_result = false;};
                    _town = _IED getvariable "town";
                    _hash = [GVAR(STORE), "IEDs"] call ALiVE_fnc_hashGet;
                    _hash = [_hash, _town] call ALIVE_fnc_hashGet;
                    _result = [_hash, _ID] call ALiVE_fnc_hashRem;
                    if ([ADDON, "debug"] call MAINCLASS) then {
                            ["Removed IED %1 at %2", _IED, _town ] call ALIVE_fnc_dump;
                    };
                };
        };
        case "taor": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_TAOR];
        };
        case "blacklist": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_BLACKLIST];
        };
        case "roadIEDClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_ROADIEDS];
        };
        case "urbanIEDClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_URBANIEDS];
        };
        case "clutterClasses": {
                if(typeName _args == "STRING") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;
                        if(count _args > 0) then {
                                _logic setVariable [_operation, _args];
                        };
                };
                if(typeName _args == "ARRAY") then {
                        _logic setVariable [_operation, _args];
                };
                _result = _logic getVariable [_operation, DEFAULT_CLUTTER];
        };
        case "debug": {
            if (typeName _args == "BOOL") then {
                _logic setVariable ["debug", _args, true];
            } else {
                _args = _logic getVariable ["debug", false];
            };
            if (typeName _args == "STRING") then {
                    if(_args == "true") then {_args = true;} else {_args = false;};
                    _logic setVariable ["debug", _args, true];
            };
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            [_logic,"deleteMarkers"] call MAINCLASS;

            if (_args) then {
                // Mark each IED, Bomber, VB-IED?
                [_logic,"createMarkers"] call MAINCLASS;
            };
            _result = _args;
        };
        case "locations": {
            _result = [_logic,_operation,_args,[]] call ALIVE_fnc_OOsimpleOperation;
        };
        case "thirdParty": {
            _result = [_logic,_operation,_args,false] call ALIVE_fnc_OOsimpleOperation;
        };
        case "createMarkers": {

            // Create Markers for locations with IED, Suicide or VB-IED
            private ["_markers"];
            _markers = [];

            _generateMarkers = {
                private ["_pos","_twn","_size","_t","_m","_ieds", "_isObj"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                _isObj = [_logic, "convertString", [_value, "TrgObj"] call ALiVE_fnc_hashGet] call MAINCLASS;
                _pos = [_value, "TrgPos"] call ALiVE_fnc_hashGet;
                if (_isObj) then {
                    _size = [_value, "TrgSize"] call ALiVE_fnc_hashGet;

                    // Mark Locations
                    _t = format["loc_t%1", random 1000];
                    _m = [_t, _pos, "Ellipse", [_size+250,_size+250], "TEXT:", _key, "COLOR:", "ColorYellow", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
                    _markers pushback _m;

                    // Mark IEDs
                    _ieds = [[GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, _key, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                } else {
                    _twn = (nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","Strategic"],200]) select 0;
                    _size = (size _twn) select 0;
                    if (_size < 250) then {_size = 250;};

                    // Mark Locations
                    _t = format["loc_t%1", random 1000];
                    _m = [_t, getpos _twn, "Ellipse", [_size+250,_size+250], "TEXT:", text _twn, "COLOR:", "ColorRed", "BRUSH:", "Border", "GLOBAL"] call CBA_fnc_createMarker;
                    _markers pushback _m;

                    // Mark IEDs
                    _ieds = [[GVAR(STORE), "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, text _twn, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                };

                {
                    private ["_t","_m","_text","_iedm","_pos","_type"];

                    //Mark IED position
                    _IED = [_ieds, _x, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

                    _t = format["ied_r%1", floor (random 1000)];
                    _pos = [_IED, "IEDpos", [0,0,0]] call ALiVE_fnc_hashGet;
                    _type = [_IED, "IEDtype", "IED"] call ALiVE_fnc_hashGet;
                    _iedm = [_t, _pos, "Icon", [0.5,0.5], "TEXT:", _type, "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;

                    _markers pushback _iedm;

                } foreach (_ieds select 1);

            };

            [[GVAR(STORE), "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet, _generateMarkers] call CBA_fnc_hashEachPair;

            _logic setVariable ["debugMarkers",_markers];

        };
        case "deleteMarkers": {

            // Delete Location markers
            // Delete IED/VB-IED markers
            {
                [_x] call CBA_fnc_deleteEntity;
            } forEach (_logic getVariable ["debugMarkers", []]);

        };
        case "destroy": {
                if (isServer) then {
                        // if server
                        _logic setVariable ["super", nil];
                        _logic setVariable ["class", nil];
                        _logic setVariable ["init", nil];
                        // and publicVariable to clients
                        ADDON = _logic;
                        publicVariable QUOTE(ADDON);
                };

                if(hasInterface) then {
                };
        };

        case "storeTrigger": {
            private ["_num", "_data"];
            _args params ["_size", "_twn", "_pos", "_isObj","_type"];

            if (count _args > 5) then {
                _num = _args select 5;
            } else {
                _num = 0;
            };

            _data = [] call ALiVE_fnc_hashCreate;
            [_data, "TrgSize", _size] call ALiVE_fnc_hashSet;
            [_data, "TrgPos", _pos] call ALiVE_fnc_hashSet;
            [_data, "TrgNum", _num] call ALiVE_fnc_hashSet;
            [_data, "TrgType", _type] call ALiVE_fnc_hashSet;
            [_data, "TrgObj", _isObj] call ALiVE_fnc_hashSet;

            [[GVAR(STORE), "triggers"] call ALiVE_fnc_hashGet, format["%1-%2",_twn,_type], _data] call ALiVE_fnc_hashSet;

            if ([_logic, "debug"] call MAINCLASS) then {
                    ["ALIVE IED - Saving trigger for %1",str(_twn)] call ALiVE_fnc_dump;
            };
        };

        case "restoreTriggers": {
            _restoreTriggers = {
                private ["_data", "_twn", "_size", "_num", "_trg"];
                if (_key == "_id" || _key == "_rev") exitWith {};
                
                // Get data
                _type = [_value, "TrgType"] call ALiVE_fnc_hashGet;
                _pos = [_value, "TrgPos"] call ALiVE_fnc_hashGet;
                _twn = (nearestLocations [_pos, ["NameCityCapital","NameCity","NameVillage","Strategic"],5]) select 0;
                _size = [_value, "TrgSize"] call ALiVE_fnc_hashGet;
                _num = [_value, "TrgNum"] call ALiVE_fnc_hashGet;

                // Build trigger
                _trg = createTrigger["EmptyDetector",_pos];
                _trg setTriggerArea[(_size+250), (_size+250),0,false];
                _trg setTriggerActivation["ANY","PRESENT",true]; // true = repeated

                // Restore OPCOM Objectives that aren't in a town
                if (isNil "_twn") then {
                    _twn = _key;
                };

                if (_num > 0) then {
                    _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [getpos thisTrigger,%1,""%2"", %3] call ALIVE_fnc_createIED",_size, text _twn, _num], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",text _twn]];
                } else {
                    _trg setTriggerStatements["this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)", format ["null = [getpos thisTrigger,%1,""%2""] call ALIVE_fnc_createIED",_size, text _twn], format ["null = [getpos thisTrigger,""%1""] call ALIVE_fnc_removeIED",text _twn]];
                };

                if (_logic getVariable["debug",false]) then {
                    ["ALIVE IED - Restoring %1 trigger in %2",_type,str(_twn)] call ALiVE_fnc_dump;
                };

            };

            [_args, _restoreTriggers] call CBA_fnc_hashEachPair;
        };

        case "state": {
            TRACE_1("ALiVE IED state called",_logic);

            if ((isnil "_args") || {!isServer}) exitwith {
                _result = GVAR(STORE)
            };

            // State is being set - restore IEDs
            _result = GVAR(STORE);
        };
        case "load": {
            // Get IEDs from DB
            _result = call ALiVE_fnc_IEDLoadData;
        };

        case "convertLocations": {
            // Convert between Positions (ARRAY) & Locations (LOCATION)
            private ["_data"];

            _data = _args select 0;

            switch (typeName _data) do {
                case "ARRAY": {
                    _result = (nearestLocations [_data, ["NameCityCapital","NameCity","NameVillage","Strategic"],5]) select 0;
                };
                case "LOCATION": {
                    _result = getPos _data;
                };
            };
            _result;
        };

        case "convertString": {
            private["_data"];
            _data = _args;
            _type = typeName _data;

            switch (_type) do {
                case "ARRAY": {
                    _converted = [];
                    {
                        if (typeName _x != "SCALAR") then {
                            _converted pushBack (parseNumber _x);
                        } else {
                            _converted pushBack _x;
                        };
                    } forEach _data;
                    _result = _converted;
                };
                case "SCALAR": {
                    _result = _data;
                };
                case "STRING": {
                    switch (_data) do {
                        case "true": {
                            _result = true;
                        };
                        case "false": {
                            _result = false;
                        };
                        case default {
                            _result = parseNumber _data;
                        };
                    };
                };
                case "BOOL": {
                    _result = _data;
                };
            };
        };

        case "convertData": {
            // CouchDB returns SCALAR values encased in "", making them strings. This converts the STRINGS back to SCALAR.
            private["_data", "_locations", "_triggers", "_ieds"];
            _data = _args;

            _locations = [_data, "locations", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
            _triggers = [_data, "triggers", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;
            _ieds = [_data, "IEDs", [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet;

            _convertLocations = {
                private ["_loc"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                _loc = [_logic, "convertString", [_value, "LocationObj"] call ALiVE_fnc_hashGet] call MAINCLASS;
                [_value, "LocationObj", _loc] call ALiVE_fnc_hashSet;
            };

            _convertTriggers = {
                private ["_keys"];
                if (_key == "_id" || _key == "_rev") exitWith {};

                _keys = ["TrgPos", "TrgSize", "TrgNum"];
                {
                    private ["_converted"];
                    _converted = [_logic, "convertString", [_value, _x] call ALiVE_fnc_hashGet] call MAINCLASS;
                    [_value, _x, _converted] call ALiVE_fnc_hashSet;
                } forEach _keys;
            };

            _convertIEDs = {
                private ["_keys"];
                if (_key == "_id" || _key == "_rev") exitWith {};
                
                _script = {
                    _keys = ["IEDpos", "IEDDud"];
                    {
                        private ["_return"];
                        _return = [_logic, "convertString", [_value, _x] call ALiVE_fnc_hashGet] call MAINCLASS;
                        [_value, _x, _return] call ALiVE_fnc_hashSet;

                    } forEach _keys;
                };

                // Each IED location has a sub-hash per IED
                [_value, _script] call CBA_fnc_hashEachPair;
            };

            [_locations, _convertLocations] call CBA_fnc_hashEachPair;
            [_triggers, _convertTriggers] call CBA_fnc_hashEachPair;
            [_ieds, _convertIEDs] call CBA_fnc_hashEachPair;
        };
};
TRACE_1("IED - output",_result);
_result;
