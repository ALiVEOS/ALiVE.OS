//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOM
Description:
Virtual AI Controller (WIP)

Base class for OPCOM objects to inherit from

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
init
createhashobject
createobjectivesbydistance
objectives
analyzeclusteroccupation
setorders
synchronizeorders
NearestAvailableSection
setstatebyclusteroccupation
selectordersbystate

Examples:
(begin example)
// create OPCOM objectives of SEP (ingame object for now) objectives and distance
_objectives = [_logic, "createobjectivesbydistance",SEP] call ALIVE_fnc_OPCOM;
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_OPCOM

private ["_result"];

TRACE_1("OPCOM - input",_this);

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = nil;

/*
_blackOps = ["id"];

if !(_operation in _blackOps) then {
    _check = "nothing"; if !(isnil "_args") then {_check = _args};

    ["op: %1 | args: %2",_operation,_check] call ALiVE_fnc_DumpR;
};
*/

#define MTEMPLATE "ALiVE_OPCOM_%1"

switch(_operation) do {
        // Main process
        case "create": {
                private ["_logic"];

                _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];

                TRACE_1("Creating class on all localities",true);

                // initialise module game logic on all localities
                _logic setVariable ["super", SUPERCLASS];
                _logic setVariable ["class", MAINCLASS];

                _result = _logic;
        };

        case "init": {
            if (isServer) then {
                // if server, initialise module game logic
                _logic setVariable ["super", SUPERCLASS];
                _logic setVariable ["class", MAINCLASS];
                _logic setVariable ["moduleType", "ALIVE_OPCOM"];

                if (isnil QUOTE(ADDON)) then {
                    ADDON = _logic;

                    PublicVariable QUOTE(ADDON);
                };
            };

            TRACE_1("After module init",_logic);

            waituntil {!isnil QUOTE(ADDON)};

            TRACE_1("Starting process",_logic);

            if (isServer) then {
                [_logic,"start"] call MAINCLASS;
            };
        };

        case "start": {
                /*
                MODEL - no visual just reference data
                - nodes
                - center
                - size
                */

                private ["_handler","_objectives"];

                //startup
                _logic setVariable ["startupComplete", false];

                if (isServer) then {

                    //Retrieve module-object variables
                    _type = _logic getvariable ["controltype","invasion"];
                    _occupation = (_logic getvariable ["asym_occupation",-100])/100;
                    _intelChance = (_logic getvariable ["intelchance",-100])/100;
                    _faction1 = _logic getvariable ["faction1","OPF_F"];
                    _faction2 = _logic getvariable ["faction2","NONE"];
                    _faction3 = _logic getvariable ["faction3","NONE"];
                    _faction4 = _logic getvariable ["faction4","NONE"];
                    _factions = [_logic, "convert", _logic getvariable ["factions",[]]] call ALiVE_fnc_OPCOM;
                    _simultanObjectives = _logic getvariable ["simultanObjectives",10];
                    _minAgents = _logic getvariable ["minAgents",2];

                    _debug = ((_logic getvariable ["debug","false"]) == "true");
                    _persistent = ((_logic getvariable ["persistent","false"]) == "true");
                    _reinforcements = call compile (_logic getvariable ["reinforcements","0.9"]);
                    _roadblocks = _logic getvariable ["roadblocks",true];

                    //Get position
                    _position = getposATL _logic;

                    //Collect factions and determine sides
                    //If missionmaker did not overwrite default factions then use the ones from the module dropdowns
                    if ((count _factions) == 0) then {
                        {if (!(_x == "NONE") && {!(_x in _factions)}) then {_factions pushBack _x}} foreach [_faction1,_faction2,_faction3,_faction4];
                    };

                    _side = "EAST";
                    switch (getNumber(((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side")) do {
                        case 0 : {_side = "EAST"};
                        case 1 : {_side = "WEST"};
                        case 2 : {_side = "GUER"};
                        default {_side = "EAST"};
                    };

                    //Thank you, BIS...
                    if (_side == "GUER") then {_side = "RESISTANCE"};

                    _sides = ["EAST","WEST","RESISTANCE"];
                    _sidesEnemy = [];
                    {
                        if ((([_side] call ALIVE_fnc_sideTextToObject) getfriend ([_x] call ALIVE_fnc_sideTextToObject)) < 0.6) then {
                            _sidesEnemy pushBack _x
                        }
                    } foreach (_sides - [_side]);
                    _sidesFriendly = (_sides - _sidesEnemy);

                    //Thank you again, BIS...
                    if (_side == "RESISTANCE") then {_side = "GUER"};
                    {if (_x == "RESISTANCE") then {_sidesEnemy set [_foreachIndex,"GUER"]}} foreach _sidesEnemy;
                    {if (_x == "RESISTANCE") then {_sidesFriendly set [_foreachIndex,"GUER"]}} foreach _sidesFriendly;

                    //Finally set common data

                    //Create OPCOM #Hash#Datahandler
                    _handler = [nil, "createhashobject"] call ALIVE_fnc_OPCOM;

                    //Set handler on module
                    _logic setVariable ["handler",_handler];

                    //Add to OPCOM_instances global array for easier access
                    call compile format["OPCOM_%1 = _handler",count (missionNameSpace getvariable ["OPCOM_instances",[]])];
                    missionNameSpace setVariable ["OPCOM_instances",(missionNameSpace getvariable ["OPCOM_instances",[]]) + [_handler]];

                    //Create OPCOM ID
                    _opcomID = str(floor(_position select 0)) + str(floor(_position select 1));

                    [_handler, "side",_side] call ALiVE_fnc_HashSet;
                    [_handler, "factions",_factions] call ALiVE_fnc_HashSet;
                    [_handler, "sidesenemy",_sidesEnemy] call ALiVE_fnc_HashSet;
                    [_handler, "sidesfriendly",_sidesFriendly] call ALiVE_fnc_HashSet;
                    [_handler, "position",_position] call ALiVE_fnc_HashSet;
                    [_handler, "simultanobjectives",_simultanObjectives] call ALiVE_fnc_HashSet;
                    [_handler, "minAgents",_minAgents] call ALiVE_fnc_HashSet;
                    [_handler, "opcomID",_opcomID] call ALiVE_fnc_HashSet;
                    [_handler, "debug",_debug] call ALiVE_fnc_HashSet;
                    [_handler, "persistent",_persistent] call ALiVE_fnc_HashSet;
                    [_handler, "module",_logic] call ALiVE_fnc_HashSet;
                    [_handler, "reinforcements",_reinforcements] call ALiVE_fnc_HashSet;
                    [_handler, "asym_occupation",_occupation] call ALiVE_fnc_HashSet;
                    [_handler, "controltype",_type] call ALiVE_fnc_HashSet;
                    [_handler, "intelchance",_intelChance] call ALiVE_fnc_HashSet;
                    [_handler, "roadblocks",_roadblocks] call ALiVE_fnc_HashSet;

                    //Spread Intel Information for this OPCOMs side
                    call compile (format["ALiVE_MIL_OPCOM_INTELCHANCE_%1 = _intelChance",[_side] call ALiVE_fnc_SideTextToObject]);
                    call compile (format["PublicVariable 'ALiVE_MIL_OPCOM_INTELCHANCE_%1'",[_side] call ALiVE_fnc_SideTextToObject]);

                    //Get CQB modules and save them
                    {if (typeof _x == "ALiVE_mil_cqb") then {
                        waituntil {_x getVariable ["startupComplete",false]};

                        [_handler, "CQB",([_handler, "CQB",[]] call ALiVE_fnc_HashGet) + [_x]] call ALiVE_fnc_HashSet;
                    }} foreach (synchronizedObjects _logic);

                    //Set dynamic data depending on type, like section sizes
                    switch (_type) do {
                        case ("invasion") : {
                                [_handler, "sectionsamount_attack", 4] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_defend", 2] call ALiVE_fnc_HashSet;
                        };
                        case ("occupation") : {
                                [_handler, "sectionsamount_attack", 4] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_defend", 5] call ALiVE_fnc_HashSet;
                        };
                        case ("asymmetric") : {
                                [_handler, "sectionsamount_attack", 1] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_reserve", 1] call ALiVE_fnc_HashSet;
                                [_handler, "sectionsamount_defend", 1] call ALiVE_fnc_HashSet;

                                //initialise INS helpers
                                call ALiVE_fnc_INS_helpers;

                                //reset CQB
                                [[_handler, "CQB",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_resetCQB;
                        };
                    };

                    /*
                    CONTROLLER  - coordination
                    */

                    ///////////
                    //Before starting check if startup parameters are ok!
                    ///////////

                    //Check if a SYS Profile Module is available
                    _errorMessage = "No Virtual AI system module was found! Please use this module in your mission! %1 %2";
                    _error1 = ""; _error2 = ""; //defaults
                    if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    //Wait for virtual profiles ready, output debug for tracing mission makers errors (like forgetting Virtual AI System module)
                    waituntil {["ALiVE OPCOM Waiting for Virtual AI System..."] call ALiVE_fnc_Dump; !(isnil "ALiVE_ProfileHandler") && {[ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet}};

                    //Wait for sector grid to be ready
                    //waituntil {["ALiVE OPCOM Waiting for Sector Grid System..."] call ALiVE_fnc_Dump; count (([([ALIVE_sectorGrid, "positionToSector", [1,1,0]] call ALIVE_fnc_sectorGrid),"data"] call ALIVE_fnc_hashGet) select 1) > 0};

                    //Load Data from DB
                    if ([_handler,"persistent",false] call ALIVE_fnc_HashGet) then {
                        _objectives = [_handler,"loadObjectivesDB"] call ALiVE_fnc_OPCOM;

                        if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {
                            // Load starting forces
                            private _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;
                            private _key = format ["%1_%2-OPCOM_%3-starting-forces", ALIVE_sys_data_GROUP_ID, _missionName, [_handler, "opcomID"] call CBA_fnc_hashGet];
                            private _result = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;

                            if (_result isEqualType []) then {
                                private _startingForces = [_result, "data"] call CBA_fnc_hashGet;
                                [_handler, "startForceStrength", _startingForces] call CBA_fnc_hashSet;
                            };
                        };
                    };

                    if (!(isnil "_objectives") && {count _objectives > 0}) then {
                        ["ALiVE OPCOM loaded %1 objectives from DB!",count _objectives] call ALiVE_fnc_Dump;
                    } else {
                        //If no data was loaded from DB then get objectives data from other modules or placed Location logics!
                        _objectives = [];

                        //Iterate through all synchronized modules
                        for "_i" from 0 to ((count synchronizedObjects _logic)-1) do {
                            private ["_obj","_mod","_size","_type","_priority"];

                            _mod = (synchronizedObjects _logic) select _i;

                            if ((typeof _mod) in ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_mil_placement_custom"]) then {
                                while {_startupComplete = _mod getVariable ["startupComplete", false]; !(_startupComplete)} do {};

                                _obj = [_mod,"objectives",objNull,[]] call ALIVE_fnc_OOsimpleOperation;
                                _objectives = _objectives + _obj;
                            } else {
                                //Is it a synced editor location-gamelogic?
                                if (_mod iskindof "LocationBase_F") then {

                                    //These two values can be overwritten with f.e. *this setvariable ["size",700]* in init-field of editorobject...
                                    _size = _mod getvariable ["size",150];
                                    _priority = _mod getvariable ["priority",200];

                                    //Get type of location-logic from config
                                    _type = getText(configfile >> "CfgVehicles" >> (typeOf _mod) >> "displayName");

                                    //Create #Hash objective for this location
                                    _obj = [nil, "createhashobject"] call ALIVE_fnc_OPCOM;
                                    [_obj,"center",getposATL _mod] call ALiVE_fnc_HashSet;
                                    [_obj,"size",_size] call ALiVE_fnc_hashSet;
                                    [_obj,"objectiveType",_type] call ALiVE_fnc_hashSet;
                                    [_obj,"priority",_priority] call ALiVE_fnc_hashSet;
                                    [_obj,"clusterID",""] call ALiVE_fnc_hashSet;

                                    _objectives pushback _obj;
                                };
                            };
                        };

                        switch (_type) do {
                            case ("occupation") : {
                                _objectives = [_handler,"objectives",[_handler,"createobjectives",[_objectives,"strategic"]] call ALiVE_fnc_OPCOM] call ALiVE_fnc_OPCOM;
                            };
                            case ("invasion") : {
                                _objectives = [_handler,"objectives",[_handler,"createobjectives",[_objectives,"distance"]] call ALiVE_fnc_OPCOM] call ALiVE_fnc_OPCOM;
                            };
                            case ("asymmetric") : {
                                _objectives = [_handler,"objectives",[_handler,"createobjectives",[_objectives,"asymmetric"]] call ALiVE_fnc_OPCOM] call ALiVE_fnc_OPCOM;
                            };
                        };

                        ["ALiVE OPCOM created %1 new objectives!",count _objectives] call ALiVE_fnc_Dump;
                    };


                    ///////////
                    //Validate
                    ///////////


                    //Check if there are any objectives
                    _errorMessage = "There are %1 objectives for this %3 OPCOM instance! %2";
                    _error1 = count _objectives; _error2 = "Please assign Military or Civilian Placement Objectives!"; //defaults
                    if ((count _objectives) == 0) exitwith {
                        [_errorMessage,_error1,_error2,_factions] call ALIVE_fnc_dumpR;
                    };

                    //Warn if there are too many objectives
                    _errorMessage = "There are %1 objectives for this %3 OPCOM instance! %2";
                    _error1 = count _objectives; _error2 = "Please lower the objective count for performance reasons, suggested is below 80!"; //defaults
                    if ((count _objectives) > 80) then {
                        [_errorMessage,_error1,_error2,_factions] call ALIVE_fnc_dump;
                    };

                    //Check if there are any profiles available
                    _errorMessage = "There are are no groups for OPCOM faction(s) %1! %2";
                    _error1 = _factions;
                    _error2 = "Please check you chose the correct faction(s), and that factions have groups defined in the ArmA 3 default categories infantry, motorized, mechanized, armored, air, sea!";
                    private _profiles_count = 0;
                    {
                        private _profiles_count_tmp = ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);

                        if !(count _profiles_count_tmp == 0) then {
                            _profiles_count = _profiles_count + (count _profiles_count_tmp);
                        } else {
                            private _error2 = "Please ensure you have configured a Mil Placement or Mil Placement (Civ Obj) module for this faction (or faction units are synced to Virtual AI module). If so, please check groups are correctly configured for this faction.";
                            [_errorMessage,_x,_error2] call ALIVE_fnc_dumpR;
                        };
                    } foreach _factions;
                    if (_profiles_count == 0) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    //Ok? Check if there is no selected faction used by another OPCOM
                    _OPCOMS = (missionNameSpace getvariable ["OPCOM_instances",[]]) - [_handler];
                    _errorMessage = "Faction %1 is already used by another OPCOM (side: %2)! Please change the faction!";
                    _error1 = ""; _error2 = ""; _exit = false; //defaults
                    {
                        _Selected_OPCOM = _x;
                        //Wait until init has passed on that instance
                        waituntil {!(isnil {[_Selected_OPCOM, "factions"] call ALiVE_fnc_HashGet})};

                        _pos_OPCOM_selected = [_Selected_OPCOM, "position"] call ALiVE_fnc_HashGet;
                        _side_OPCOM_selected = [_Selected_OPCOM, "side"] call ALiVE_fnc_HashGet;
                        _factions_OPCOM_selected = [_Selected_OPCOM, "factions"] call ALiVE_fnc_HashGet;

                        //Not really beautiful to identify opcom by position (array check wont work), but it works...
                        if !(str(_position) == str(_pos_OPCOM_selected)) then {
                            {
                                _own_faction = _x;
                                if (_own_faction in _factions_OPCOM_selected) exitwith {
                                    _exit = true; _error1 = _own_faction; _error2 = _side_OPCOM_selected};
                            } foreach _factions;
                            if (_exit) exitwith {_exit = true};
                        };
                    } foreach _OPCOMS;
                    if (_exit) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    //Still there? Awesome, check if there are different sides within the factions
                    _errorMessage = "There are different sides within this OPCOM %1! Please only select one side per OPCOM!%2";
                    _error1 = _side; _error2 = ""; _exit = false;  //defaults
                    _exit = !(({(getNumber(((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side")) == (getNumber((_x call ALiVE_fnc_configGetFactionClass) >> "side"))} count _factions) == (count _factions));
                    if (_exit) exitwith {
                        [_errorMessage,_error1,_error2] call ALIVE_fnc_dumpR;
                    };

                    //Still there, mega, lets summarize...
                    if (_debug) then {
                        ["OPCOM %1 starts with %2 profiles and %3 objectives!",_side,_profiles_count,count _objectives] call ALIVE_fnc_dumpR;
                    };


                    ///////////
                    //Startup
                    ///////////


                    //Perform initial cluster occupation and troops analysis as MP modules are finished
                    _clusterOccupationAnalysis = [_handler,_side,_sidesEnemy,_sidesFriendly] call {[_this select 0,"analyzeclusteroccupation",[_this select 3,_this select 2]] call ALiVE_fnc_OPCOM};
                    _forcesInit = [_handler,"scantroops"] call ALiVE_fnc_OPCOM;
                    ["ALiVE OPCOM %1 Initial analysis done...",_side] call ALiVE_fnc_Dump;

                    //done this way to easily switch between spawn and call for testing purposes
                    ["OPCOM and TACOM %1 starting...",_side] call ALiVE_fnc_Dump;

                    switch _type do {
                        case ("occupation") : {
                            _OPCOM = [_handler] call {
                                _handler = _this select 0;

                                _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                                _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                                [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                                [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                            };
                        };
                        case ("invasion") : {
                            _OPCOM = [_handler] call {
                                _handler = _this select 0;

                                _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                                _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                                [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                                [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                            };
                        };
                        case ("asymmetric") : {
                            _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                            [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                        };
                    };
                };

                //Set startup complete and end loading screen if init has passed or an error occurred
                if (isServer) then {
                    _logic setVariable ["startupComplete",true,true];
                    [_handler,"startupComplete",true] call ALiVE_fnc_HashSet;

                };


                /*
                VIEW - purely visual
                */
        };

        case "cleanupduplicatesections": {
            private ["_objectives","_objective","_section","_proID","_state","_size_reserve","_pending_orders","_profile","_wayPoints","_orders","_profileIDs"];

                _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
                _pending_orders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
                _size_reserve = [_logic,"sectionsamount_reserve",1] call ALiVE_fnc_HashGet;
                _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
                //_profileIDs = [ALIVE_profileHandler, "getProfilesBySide",[_logic,"side"] call ALiVE_fnc_HashGet] call ALIVE_fnc_profileHandler;

                _profileIDs = [];
                {
                    _profileIDs = _profileIDs + ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
                } foreach _factions;

            {
                private ["_objective","_section","_state","_idlestates","_wps"];

                _objective = _x;
                _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
                _state = [_objective,"opcom_state",[]] call ALiVE_fnc_HashGet;
                _idlestates = ["unassigned","idle"];

                _wps = 0;
                {
                    private ["_profile"];

                    _profile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

                    if !(isnil "_profile") then {
                        _wps = _wps + (count (_profile select 2 select 16));
                    } else {
                        [_logic,"resetorders",_x] call ALiVE_fnc_OPCOM;
                    };
                } foreach _section;

                _section = [_objective,"section",_section] call ALiVE_fnc_HashGet;
                if (!(_state in _idlestates) && {count _section > 0} && {_wps == 0}) then {
                    {[_logic,"resetorders",_x] call ALiVE_fnc_OPCOM} foreach _section;
                    [_logic,"resetObjective",([_objective,"objectiveID"] call ALiVE_fnc_HashGet)] call ALiVE_fnc_OPCOM;
                };
            } foreach _objectives;
        };

        case "NearestAvailableSection": {

			//private _id = time; [true, "ALiVE OPCOM composing section!", format["OPCOM_nearestSection_%1",_id]] call ALIVE_fnc_timer;

            private ["_radius","_troopsunsorted","_types","_pos","_size","_troops","_busy","_section","_reserved","_profileIDs","_profile"];

            _pos = _args select 0;
            _size = _args select 1;
            if (count _args > 2) then {_types = _args select 2} else {_types = ["infantry"]};

			// Get troops from current OPCOM analysis
            _troops = []; {_troops = _troops + ([_logic,_x,[]] call ALiVE_fnc_HashGet)} foreach _types;

            //subtract busy and reserved profiles
            _busy = []; {_busy pushback (_x select 1)} foreach ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);
            {_busy = _busy + ([_x,"section",[]] call ALiVE_fnc_HashGet)} foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);
            _reserved = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
            _busy = _busy - _reserved;

			// If great amount of troops is requested reroute profiles if needed
            _troops = if (_size >= 5) then {_troops - _reserved} else {_troops - (_busy + _reserved)};

			// Filter troops
            _radius = 2000;
            while
            {
                private _nearProfiles = [_pos, _radius, [([_logic,"side","EAST"] call ALiVE_fnc_HashGet),"entity"]] call ALIVE_fnc_getNearProfiles;

                _troopsUnsorted = [];

                {
                    private _profile = _x;

                    if (!isnil "_profile") then {

	                    private _profileID = [_profile,"profileID",""] call ALiVE_fnc_HashGet;
	                    private _commander = (count ([_profile,"vehiclesInCommandOf",[]] call ALIVE_fnc_hashGet) > 0);
	                    private _busy = ([_profile,"busy",false] call ALiVE_fnc_HashGet);

	                    private _valid = !_busy && {_profileID in _troops} && {!_commander || {_commander && {!([[_profile,"position",[0,0,0]] call ALiVE_fnc_HashGet,_pos] call ALiVE_fnc_crossesSea)}}};

	                    if (_valid) then {_troopsUnsorted pushBack _profile};
                    };
                } foreach _nearProfiles;

                ((count _troopsUnsorted <= _size) && {_radius < 15000});
            } do {
                _radius = _radius + 2000;
            };

            //Sort by distance
            _troops = [_troopsUnsorted,[_pos],
		            	{([_x,"position",_Input0] call ALiVE_fnc_HashGet) distance _Input0}
		                	,"ASCEND",
						{!isnil "_x" && {count _x > 2}}
                      ] call ALiVE_fnc_SortBy;

            //Collect to section
            _section = [];
            {
                if (count _section == _size) exitwith {};

                if (!isnil "_x") then {_section pushback ([_x,"profileID",""] call ALiVE_fnc_HashGet)};
            } foreach _troops;

            _result = _section;

            //[false, "ALiVE OPCOM composing section!", format["OPCOM_nearestSection_%1",_id]] call ALIVE_fnc_timer;
        };

        ///////////////////////////////////////////////////
        // Scan position for nearby profiles belonging to
        // the passed sides.
        // Returns array of all found profiles
        ///////////////////////////////////////////////////

        case "findProfilesNearPosition": {
            _args params ["_pos","_sides","_requireVisibility"];
            _pos = [_pos select 0, _pos select 1, 0];

            if (_requireVisibility) then {
                _pos = ATLtoASL _pos;
                _pos set [2,(_pos select 2) + 2];
            };

            private _nearEnemies = [];

            private _nearProfiles = [_pos, 800, [_sides,"entity"]] call ALIVE_fnc_getNearProfiles;
            {
                if (_requireVisibility) then {
                    private _profileID = _x select 2 select 4;
                    private _profilePosition = _x select 2 select 2;

                    private _profilePosASL = ATLtoASL [_profilePosition select 0, _profilePosition select 1, 0];
                    _profilePosASL set [2,(_profilePosASL select 2) + 2];

                    if (_profilePosition distance _pos < 500 && { !(terrainIntersectASL [_profilePosASL, _pos]) }) then {
                        _nearEnemies pushbackunique [_x select 2 select 4, _x select 2 select 2]; // [id,pos]
                    };
                } else {
                    _nearEnemies pushbackunique [_x select 2 select 4, _x select 2 select 2]; // [id,pos]
                };
            } foreach _nearProfiles;

            _result = _nearEnemies;
        };

        case "attackentity": {
            ASSERT_TRUE(typeName _args == "ARRAY",str _args);

            private ["_target","_reserved","_sides","_size","_type","_proIDs","_knownE","_attackedE","_pos","_profiles","_profileIDs","_profile","_section","_profileID","_i","_waypoints","_posAttacker","_dist","_rtb","_vehicleProfile","_vehicleType","_ATOtype"];

            _target = _args select 0;
            _size = _args select 1;
            _type = _args select 2;

            _side = [_logic,"side"] call ALiVE_fnc_HashGet;
            _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
            _sides = [_logic,"sidesenemy",["EAST"]] call ALiVE_fnc_HashGet;
            _knownE = [_logic,"knownentities",[]] call ALiVE_fnc_HashGet;
            _attackedE = [_logic,"attackedentities",[]] call ALiVE_fnc_HashGet;
            _reserved = [_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet;
            _profile = [ALiVE_ProfileHandler,"getProfile",_target] call ALiVE_fnc_ProfileHandler;
            _pos = [_profile,"position"] call ALiVE_fnc_HashGet;

	        _vehicles = ([_profile,"vehicleAssignments",[[],[]]] call ALIVE_fnc_hashGet) select 1;
	        if (count _vehicles > 0) then {
	        	_vehicleProfile = [ALiVE_ProfileHandler,"getProfile",_vehicles select 0] call ALiVE_fnc_ProfileHandler;
	        };

            _section = [];
            _profileIDs = [];
            _profiles = [];
            _dist = 1000;

            if (isnil "_profile") exitwith {_result = _section};

           {
                _proIDs = [ALIVE_profileHandler, "getProfilesBySide",_x] call ALIVE_fnc_profileHandler;
                _profileIDs = _profileIDs + _proIDs;
            } foreach _sides;

            {
                if ((isnil "_x") || {_x select 0 == _target} || {!((_x select 0) in _profileIDs)}) then {
                    _knownE set [_foreachIndex,"x"];
                };
            } foreach _knownE;
            _knownE = _knownE - ["x"];
			[_logic,"knownentities",_knownE] call ALiVE_fnc_HashSet;

            {
                if ((isnil "_x") || {time - (_x select 3) > 90} || {!((_x select 0) in _profileIDs)}) then {
                    _attackedE set [_foreachIndex,"x"];
                };
            } foreach _attackedE;
            _attackedE = _attackedE - ["x"];
            [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;

            if ({!(isnil "_x") && {_x select 0 == _target}} count _attackedE < 1) then {

            	private _infantry = [_logic,"infantry",[]] call ALiVE_fnc_HashGet;
            	private _motorized = [_logic,"motorized",[]] call ALiVE_fnc_HashGet;
            	private _mechanized = [_logic,"mechandized",[]] call ALiVE_fnc_HashGet;
            	private _armored = [_logic,"armored",[]] call ALiVE_fnc_HashGet;
            	private _artillery = [_logic,"artillery",[]] call ALiVE_fnc_HashGet;
            	private _AAA = [_logic,"AAA",[]] call ALiVE_fnc_HashGet;
            	private _air = [_logic,"air",[]] call ALiVE_fnc_HashGet;

                switch (_type) do {
                    case ("infantry") : {
                        _profiles = _infantry;
                        _dist = 1000;
                    };
                    case ("motorized") : {
                        _profiles = _motorized;
                        _dist = 3000;
                    };
                    case ("mechandized") : {
                        _profiles = _mechanized;
                    };
                    case ("armored") : {
                        _profiles = _armored;
                        _dist = 3000;
                    };
                    case ("artillery") : {
                        _profiles = _artillery;
                        _dist = 5000;
                    };
                    case ("AAA") : {
                        _profiles = _AAA;
                        _dist = 5000;
                    };
                    case ("air") : {
                        _profiles = _air;
                        _dist = 30000;
                        _rtb = true;
                    };
                    default {
                    	_profiles = _infantry;
                    };
                };

                if (count _profiles == 0) then {
                	{
                		if (count _x > 0) exitwith {_profiles = _x};
                	} foreach [_armored,_mechanized,_motorized,_infantry];
                };

                if (!isnil "_rtb" && {["ALiVE_mil_ATO"] call ALiVE_fnc_IsModuleAvailable}) exitwith {

                	_ATOtype = "CAS";

                    // ["Calling ATO event"] call ALiVE_fnc_DumpR;

					_args = [
					    "RED",	// ROE
					    200,
					    "FULL",
					    0.1,
					    0.1,
					    2000,	// RADIUS
					    10,
					    [_target]  // TARGETS either profile or unit
					];
					_event = ['ATO_REQUEST', [_ATOtype, [_side] call ALiVE_fnc_sideTextToObject, _factions select 0, _pos, _args],"OPCOM"] call ALIVE_fnc_event;
					_eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                    _attackedE pushback [_target,_pos,_section,time];
                    [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
                };

                if (count _profiles > 0) then {

                    _profilesUnsorted = _profiles;
                    _profiles = [_profilesUnsorted,[_pos],{if !(isnil "_x") then {_p = nil; _p = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler; if !(isnil "_p") then {([_p,"position",_Input0] call ALiVE_fnc_HashGet) distance _Input0} else {[0,0,0] distance _Input0}} else {[0,0,0] distance _Input0}},"ASCEND"] call ALiVE_fnc_SortBy;

                    _i = 0;
                    while {count _section < _size} do {
                        private ["_profileWaypoint","_profileID"];

                        if (_i >= count _profiles) exitwith {};

                           _profileID = (_profiles select _i);
                        _profile = ([ALiVE_ProfileHandler,"getProfile",_profileID] call ALiVE_fnc_profileHandler);

                        if !(isnil "_profile") then {
                               _posAttacker = [_profile, "position"] call ALiVE_fnc_HashGet;

                            if (!(isnil "_profile") && {_pos distance _posAttacker < _dist} && {!(_profileID in _reserved)}) then {

                                _waypoints = [_profile,"waypoints"] call ALIVE_fnc_hashGet;

                                if (({!(isnil "_x") && {_profileID in (_x select 2)}} count _attackedE) < 1 && {count _waypoints <= 2}) then {
                                    if (!isnil "_rtb") then {
                                        _profileWaypoint = [_posAttacker, 50] call ALIVE_fnc_createProfileWaypoint;
                                        [_profileWaypoint,"statements",["true",
                                            format["
                                                if !(isServer) exitwith {};

                                                _profile = [ALiVE_ProfileHandler,'getProfile',%1] call ALiVE_fnc_profileHandler;
                                                _active = [_profile,'active',false] call ALiVE_fnc_HashGet;

                                                if (_active) then {
                                                    _group = _profile select 2 select 13;
                                                    _group setSpeedmode 'LIMITED';
                                                    {(vehicle _x) land 'LAND'} foreach (units _group);
                                                } else {
                                                    _vehicleProfiles = [_profile,'vehiclesInCommandOf',[]] call ALIVE_fnc_hashGet;

                                                    {
                                                        _vehicleProfile = [ALiVE_ProfileHandler,'getProfile',_x] call ALiVE_fnc_ProfileHandler;
                                                        [_vehicleProfile,'engineOn',false] call ALIVE_fnc_HashSet;
                                                    } foreach _vehicleProfiles;
                                                };
                                            ",str(_profileID)]
                                        ]] call ALIVE_fnc_hashSet;

                                        [_profile,"insertWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;
                                    };

                                    _profileWaypoint = [_pos, 50, "MOVE", "FULL", 50, [], "LINE"] call ALIVE_fnc_createProfileWaypoint;
                                    [_profile,"insertWaypoint",_profileWaypoint] call ALIVE_fnc_profileEntity;

                                    _section pushback _profileID;
                                } else {
                                    //player sidechat format["Entity %1 is already on attack mission...!",_profileID];
                                };
                            };
                        };

                        _i = _i + 1;
                    };

                    if (count _section > 0) then {
                        _attackedE pushback [_target,_pos,_section,time];
                        [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
                        //player sidechat format["Group %1 is attacked by %2",_target, _section];
                    };
                } else {
                	["OPCOM has no troops to respond on TACOM request for QRF on %1 of type %2",_target,_type] call ALiVE_fnc_DumpR;
                };
            } else {
                //player sidechat format["Target %1 already beeing attacked, dead or not existing for any reason...!",_target];
            };

            _result = _section;
        };

        case "setorders": {
                ASSERT_TRUE(typeName _args == "ARRAY",str _args);

                private ["_section","_profile","_profileID","_objectiveID","_pos","_orders","_pending_orders","_objectives","_id"];

                _pos = _args select 0;
                _profileID = _args select 1;
                _objectiveID = _args select 2;
                _orders = _args select 3;
                _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
                _objectives = [_logic,"objectives"] call ALiVE_fnc_HashGet;

                {
                    _id = [_x,"objectiveID"] call ALiVE_fnc_HashGet;
                    _section = [_x,"section",[]] call ALiVE_fnc_HashGet;

                    if ((_profileID in _section) && {!(_objectiveID == _id)}) then {
                        [_logic,"resetorders",_profileID] call ALiVE_fnc_OPCOM;
                    };
                } foreach _objectives;

                _pending_orders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
                _pending_orders_tmp = _pending_orders;

                if (({(_x select 1) == _profileID} count _pending_orders_tmp) > 0) then {
                    {
                        if ((_x select 1) == _profileID) then {_pending_orders_tmp set [_foreachIndex,"x"]};
                    } foreach _pending_orders_tmp;
                    _pending_orders = _pending_orders_tmp - ["x"];
                };

                _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

                [_profile, "clearWaypoints"] call ALIVE_fnc_profileEntity;
                [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;

                _profileWaypoint = [_pos, 15] call ALIVE_fnc_createProfileWaypoint;

                _var = ["_TACOM_DATA",["completed",[_ProfileID,_objectiveID,_orders]]];
                _statements = format["[] spawn {sleep (random 10); %1 setfsmvariable %2}",_TACOM_FSM,_var];
                [_profileWaypoint,"statements",["true",_statements]] call ALIVE_fnc_hashSet;
                [_profileWaypoint,"behaviour","AWARE"] call ALIVE_fnc_hashSet;
                [_profileWaypoint,"speed","NORMAL"] call ALIVE_fnc_hashSet;

                [_profile, "addWaypoint", _profileWaypoint] call ALIVE_fnc_profileEntity;

                _ordersFull = [_pos,_ProfileID,_objectiveID,time];
                [_logic,"pendingorders",_pending_orders + [_ordersFull]] call ALiVE_fnc_HashSet;

                _result = _profileWaypoint;
        };

        case "synchronizeorders": {
                ASSERT_TRUE(typeName _args == "STRING",str _args);

                private ["_ProfileIDInput","_profiles","_orders_pending","_synchronized","_item","_objectiveID","_profileID"];

                _ProfileIDInput = _args;
                _profiles = ([ALIVE_profileHandler, "getProfiles","entity"] call ALIVE_fnc_profileHandler) select 1;
                _orders_pending = ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);
                _synchronized = false;

                for "_i" from 0 to ((count _orders_pending)-1) do {
                    if (_i >= (count _orders_pending)) exitwith {};

                    _item = _orders_pending select _i;

                    if (typeName _item == "ARRAY") then {
                        _pos = _item select 0;
                        _profileID = _item select 1;
                        _objectiveID = _item select 2;
                        _time = _item select 3;
                        _dead = !(_ProfileID in _profiles);
                        _timeout = (time - _time) > 3600;

                        if ((_dead) || {_timeout} || {_ProfileID == _ProfileIDInput}) then {
                            _orders_pending set [_i,"x"]; _orders_pending = _orders_pending - ["x"];
                            [_logic,"pendingorders",_orders_pending] call ALiVE_fnc_HashSet;
                            if (({_objectiveID == (_x select 2)} count (_orders_pending)) == 0) then {_synchronized = true};
                        };
                    };
                };
                _result = _synchronized;
        };

        case "resetorders": {
            ASSERT_TRUE(typeName _args == "STRING",str _args);
            private ["_active","_profileID","_profile","_ProfileIDsBusy","_profileIDx","_pendingOrders","_ProfileIDsReserve","_section","_objectives"];

            _profileID = _args;

            //Reset busy queue if there is an entry for the entitiy
            [_logic,"ProfileIDsBusy",([_logic,"ProfileIDsBusy",[]] call ALiVE_fnc_HashGet) - [_profileID]] call ALiVE_fnc_HashSet;

            //Reset reserve queue if there is an entry for the entitiy
            [_logic,"ProfileIDsReserve",([_logic,"ProfileIDsReserve",[]] call ALiVE_fnc_HashGet) - [_profileID]] call ALiVE_fnc_HashSet;

            //Reset pending orders if there is an entry for the entitiy
            _pendingOrders = [_logic,"pendingorders",[]] call ALiVE_fnc_HashGet;
            {
                _profileIDx = _x select 1;

                if (_profileIDx == _profileID) then {
                    _pendingOrders set [_foreachIndex,"x"];
                };
            } foreach _pendingOrders;
            _pendingOrders = _pendingOrders - ["x"];
            [_logic,"pendingorders",_pendingOrders] call ALiVE_fnc_HashSet;

            //Reset section entry on objectives if the entitiy is still assigned to an objective
            _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
            {
                _section = [_x,"section",[]] call ALiVE_fnc_HashGet;
                [_x,"sectionAssist",[]] call ALiVE_fnc_HashSet;

                if (count _section > 0) then {
                    if (_profileID in _section) then {
                        _section = _section - [_profileID];

                        [_x,"section",_section] call ALiVE_fnc_HashSet;
                    };

                    if (count _section == 0) then {
                        [_logic,"resetObjective",([_x,"objectiveID"] call ALiVE_fnc_HashGet)] call ALiVE_fnc_OPCOM;
                    };
                };
            } foreach _objectives;

            _profile = [ALIVE_profileHandler, "getProfile", _profileID] call ALIVE_fnc_profileHandler;

            if !(isnil "_profile") then {
               _active = [_profile, "active", false] call ALIVE_fnc_HashGet;
               _activeCommands = [_profile, "activeCommands", []] call ALIVE_fnc_HashGet;

               if (!_active && {count _activeCommands == 0}) then {
                    [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity;
                    [_profile, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity;
               };
            };

            _result = true;
        };

        case "getOPCOMbyid": {
            ASSERT_TRUE(typeName _args == "STRING",str _args);

            {
                private ["_id"];

                _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;

                if (_id == _args) exitwith {_result = _x};

            } foreach OPCOM_instances;
        };

        case "getobjectivebyid": {
            ASSERT_TRUE(typeName _args == "STRING",str _args);

            private ["_objective","_id"];

            _id = _args;

            if (!isnil "_logic" && {typeName _logic == "ARRAY"} && {count _logic > 0}) then {
                {
                    if (([_x,"objectiveID"] call ALiVE_fnc_hashGet) == _id) exitwith {_objective = _x};
                } foreach ([_logic, "objectives"] call ALIVE_fnc_HashGet);
            } else {
                {
                    private ["_exit"];

                    _exit = false;

                    {_o = _x; if (([_o,"objectiveID"] call ALiVE_fnc_hashGet) == _id) exitwith {_objective = _o; _exit = true}} foreach ([_x, "objectives"] call ALIVE_fnc_HashGet);

                    if (_exit) exitwith {};

                } foreach OPCOM_INSTANCES;
            };

            _result = _objective;
        };

        case "sortObjectives": {
            if(isnil "_args") then {
                _args = [_logic,"objectives"] call ALIVE_fnc_hashGet;
            } else {
                private ["_objectives","_type","_asym_occupation","_side","_color"];

                _type = _args;
                _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
                _asym_occupation = [_logic,"asym_occupation",-1] call ALiVE_fnc_HashGet;
                _roadblocks = [_logic,"roadblocks",true] call ALiVE_fnc_HashGet;

                switch (_type) do {
                            //by distance
                            case ("distance") : {
                                _objectives = [_objectives,[_logic],{
                                    _final = ([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1);

                                    //["ALiVE OPCOM Priority calculated %1",_final] call ALiVE_fnc_DumpR;

                                    _final = _final*(1-(random 0.33));

                                    //["ALiVE OPCOM Priority randomized with a variety of one third in relation to distance %1 ",_final] call ALiVE_fnc_DumpR;

                                    _final
                                },"ASCEND"] call ALiVE_fnc_SortBy;
                            };

                            //by size and height
                            case ("strategic") : {
                                _objectives = [_objectives,[_logic],{
                                    _height = (ATLtoASL [(_x select 2 select 1) select 0,(_x select 2 select 1) select 1,0]) select 2;
                                    _value1 = (_x select 2 select 2);
                                    _value2 = (_x select 2 select 4);
                                    _value3 = (_height/2);
                                    _value4 = ((([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))/10);

                                    _final = (_value1 + _value2 + _value3) - _value4;

                                    //["ALiVE OPCOM Priority calculated %1",_final] call ALiVE_fnc_DumpR;

                                    _final = _final*(1-(random 0.33));

                                    //["ALiVE OPCOM Priority randomized with a variety of one third in relation to size, height, distance, cluster priority %1",_final] call ALiVE_fnc_DumpR;

                                    _final
                                },"DESCEND"] call ALiVE_fnc_SortBy;
                            };
                            case ("asymmetric") : {

                                _objectivesCiv = +_objectives;
                                _objectivesMil = +_objectives;

                                _objectivesFilteredCiv = [_objectivesCiv,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "CIV"}] call ALiVE_fnc_SortBy;
                                _objectivesFilteredMil = [_objectivesMil,[_logic],{(([_Input0, "position"] call ALIVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "MIL"}] call ALiVE_fnc_SortBy;

                                _objectives = _objectivesFilteredCiv + _objectivesFilteredMil;

                                //["ALiVE OPCOM Asymmetric Priority randomized with a variety of one fifth in relation to distance"] call ALiVE_fnc_DumpR;

                                if (_asym_occupation <= 0) exitwith {};

                                _factions = [_logic,"factions",["OPF_F"]] call ALiVE_fnc_HashGet;
                                _sidesEnemy = [_logic,"sidesenemy",["WEST"]] call ALiVE_fnc_HashGet;
                                _sidesFriendly = [_logic,"sidesfriendly",["EAST"]] call ALiVE_fnc_HashGet;
                                _CQB = [_logic,"CQB",[]] call ALiVE_fnc_HashGet;
                                _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

                                //Convert CQB modules
                                _CQB = +_CQB; {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

								{
	                                    private ["_center","_size"];

	                                    _objective = _x;

	                                    if (random 1 < _asym_occupation) then {

	                                        _center = [_objective,"center"] call ALiVE_fnc_HashGet;
	                                        _size = [_objective,"size",-1] call ALiVE_fnc_HashGet;
	                                        _id = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;

	                                        // Get sector data
	                                        _sector = [ALIVE_sectorGrid, "positionToSector", _center] call ALIVE_fnc_sectorGrid;
	                                        _sectorData = [_sector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;
	                                        _entitiesBySide = [_sectorData, "entitiesBySide",["",[],[],nil]] call ALIVE_fnc_hashGet;
	                                        _agents = [];

	                                        // Get amb civilian clusterdata
	                                        if ("clustersCiv" in (_sectorData select 1)) then {

	                                            if (isnil "ALIVE_agentHandler") exitwith {};

	                                            _civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
	                                            _settlementClusters = [_civClusters,"settlement",[]] call ALIVE_fnc_hashGet;
	                                            _agentClusterData = [ALIVE_agentHandler,"agentsByCluster",["",[],[],nil]] call ALiVE_fnc_hashGet;

	                                            if (count _settlementClusters <= 0) exitwith {};

	                                            _settlementClusters = [_settlementClusters,[_center],{_Input0 distance (_x select 0)},"ASCEND"] call ALiVE_fnc_SortBy;
	                                            _agents =  ([_agentClusterData,_settlementClusters select 0 select 1,["",[],[],nil]] call ALiVE_fnc_HashGet) select 1;

	                                            [_objective,"agents",_agents] call ALiVE_fnc_HashSet;
	                                        };

	                                        private ["_building","_road"];

	                                        _buildings = [_center,_size] call ALIVE_fnc_getEnterableHouses;
	                                        _roads = _center nearRoads _size;
	                                        _faction = selectRandom _factions;
	                                        _dominantFaction = [_center, _size] call ALiVE_fnc_getDominantFaction;

	                                        if (isnil "_dominantFaction" || {!(([[_dominantFaction call ALiVE_fnc_factionSide] call ALiVE_fnc_SideObjectToNumber] call ALiVE_fnc_SideNumberToText) in _sidesEnemy)}) then {
	                                            if (count (_buildings + _roads) > 0) then {

	                                                if (count _buildings > 0) then {
	                                                    _type = selectRandom ["HQ","depot","factory"];
	                                                    _target = selectRandom _buildings;
	                                                };

	                                                if (count _roads > 0 && {(random 1) < 0.45 || count _buildings == 0}) then {
	                                                        _type = selectRandom ["ied","roadblocks"];
	                                                        if !(_roadblocks) then {
	                                                            _type = "ied";
	                                                        };
	                                                        _target = selectRandom _roads;
	                                                };

	                                                _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM;

	                                                switch _type do {
	                                                    case ("factory") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_factory;
	                                                    };
	                                                    case ("depot") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_depot;
	                                                    };
	                                                    case ("HQ") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_recruit;
	                                                    };
	                                                    case ("ied") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ied;
	                                                    };
	                                                    /*
	                                                    case ("ambush") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ambush;
	                                                    };
	                                                    */
	                                                    case ("roadblocks") : {
	                                                        [time,_center,_id,_size,_faction,_target,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_roadblocks;
	                                                    };
	                                                };
	                                             };
	                                         };
	                                     };
	                                } foreach _objectives;
                            };

                            case ("size") : {};
                            default {};
                };
                [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;

                // Create additional debug markers
                if (_debug) then {
                    _side = [_logic,"side","EAST"] call ALiVE_fnc_HashGet;

                     _color = switch (_side) do {
                        case "EAST" : {"COLORRED"};
                        case "WEST" : {"COLORBLUE"};
                        case "GUER" : {"COLORGREEN"};
                        default {"COLORYELLOW"};
                    };

                    {
                        _center = [_x,"center"] call ALiVE_fnc_HashGet;
                        _id = [_x,"objectiveID"] call ALiVE_fnc_HashGet;

                        [format[MTEMPLATE, _id], _center,"ICON", [0.5,0.5],_color,format["%1 #%2",_side,_foreachIndex],"mil_dot","FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                    } foreach _objectives;
                };

                _args = _objectives;
            };
            _result = _args;
        };

        case "resetObjective": {
            if(isnil "_args") then {
                    _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
            } else {
                ASSERT_TRUE(typeName _args == "STRING",str _args);
                private ["_objective"];

                _objective = [_logic,"getobjectivebyid",_args] call ALiVE_fnc_OPCOM;
                _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

                [_objective,"tacom_state","none"] call AliVE_fnc_HashSet;
                [_objective,"opcom_state","unassigned"] call AliVE_fnc_HashSet;
                [_objective,"danger",-1] call AliVE_fnc_HashSet;
                [_objective,"section",[]] call AliVE_fnc_HashSet;
                [_objective,"opcom_orders","none"] call AliVE_fnc_HashSet;
                [_objective,"objectiveType",[_objective,"objectiveType","MIL"] call AliVE_fnc_HashGet] call AliVE_fnc_HashSet;

                // debug ---------------------------------------
                if (_debug) then {_args setMarkerColorLocal "ColorWhite"};
                // debug ---------------------------------------

                _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
            };
            _result = _args;
        };

        case "initObjective": {
            if(isnil "_args") then {
                    _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
            } else {
                ASSERT_TRUE(typeName _args == "STRING",str _args);
                private ["_objective"];

				//{
	                _id = _args;

	                _factions = [_logic,"factions",["OPF_F"]] call ALiVE_fnc_HashGet;
	                _sidesEnemy = [_logic,"sidesenemy",["WEST"]] call ALiVE_fnc_HashGet;
	                _sidesFriendly = [_logic,"sidesfriendly",["EAST"]] call ALiVE_fnc_HashGet;
	                _CQB = [_logic,"CQB",[]] call ALiVE_fnc_HashGet;
	                _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

	                _objective = [_logic,"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
	                _center = [_objective,"center"] call AliVE_fnc_HashGet;
	                _size = [_objective,"size"] call AliVE_fnc_HashGet;

	                //Convert CQB modules
	                _CQB = +_CQB; {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

	                // Get sector data
	                _sector = [ALIVE_sectorGrid, "positionToSector", _center] call ALIVE_fnc_sectorGrid;
	                _sectorData = [_sector,"data",["",[],[],nil]] call ALIVE_fnc_hashGet;
	                _entitiesBySide = [_sectorData, "entitiesBySide",["",[],[],nil]] call ALIVE_fnc_hashGet;
	                _agents = [];

	                // Get amb civilian clusterdata
	                if ("clustersCiv" in (_sectorData select 1)) then {

	                    if (isnil "ALIVE_agentHandler") exitwith {};

	                    _civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
	                    _settlementClusters = [_civClusters,"settlement",[]] call ALIVE_fnc_hashGet;
	                    _agentClusterData = [ALIVE_agentHandler,"agentsByCluster",["",[],[],nil]] call ALiVE_fnc_hashGet;

	                    if (count _settlementClusters <= 0) exitwith {};

	                    _settlementClusters = [_settlementClusters,[_center],{_Input0 distance (_x select 0)},"ASCEND"] call ALiVE_fnc_SortBy;
	                    _agents =  ([_agentClusterData,_settlementClusters select 0 select 1,["",[],[],nil]] call ALiVE_fnc_HashGet) select 1;

	                    [_objective,"agents",_agents] call ALiVE_fnc_HashSet;
	                };

	                _factory = [_logic,"convertObject",[_objective,"factory",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _HQ = [_logic,"convertObject",[_objective,"HQ",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _ambush = [_logic,"convertObject",[_objective,"ambush",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _depot = [_logic,"convertObject",[_objective,"depot",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _sabotage = [_logic,"convertObject",[_objective,"sabotage",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _ied = [_logic,"convertObject",[_objective,"ied",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _suicide = [_logic,"convertObject",[_objective,"suicide",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;
	                _roadblocks = [_logic,"convertObject",[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

	                if (alive _factory) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"factory",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_factory};
	                if (alive _HQ) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"HQ",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_recruit};
	                if (alive _depot) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"depot",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_depot};
	                if (alive _roadblocks) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_roadblocks};
	                if (alive _ied) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ied",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ied};
	                if (alive _ambush) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ambush",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ambush};

	                if (alive _sabotage) then {
	                    private ["_buildings","_target"];

	                    //Selecting tallest enterable building as target...
	                    if (isnil "_buildings" || {count _buildings > 0}) then {
	                        if (isnil "_buildings") then {_buildings = [_center, _size] call ALiVE_fnc_getEnterableHouses};

	                        _buildings = [_buildings,[],{

	                            _maxHeight = -999;
	                            if (alive _x && {!((typeOf _x) isKindOf "House_Small_F")}) then {

	                            if !((getText(configfile >> "CfgVehicles" >> (typeOf _x) >> "destrType")) == "DestructNo") then {
	                                    _bbr = boundingBoxReal _x;
	                                    _p1 = _bbr select 0; _p2 = _bbr select 1;
	                                    _maxHeight = abs((_p2 select 2)-(_p1 select 2));
	                                };
	                            };
	                            _maxHeight

	                        },"DESCEND"] call ALiVE_fnc_SortBy;

	                        if (count _buildings > 0) then {_target = _buildings select 0; _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM} else {_target = [[],"convertObject",objNull] call ALiVE_fnc_OPCOM};
	                    };

	                    [time,_center,_id,_size,selectRandom _factions,[_objective,"sabotage",[]] call ALiVE_fnc_HashGet,_target,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_sabotage;
	                };

	                if (alive _suicide) then {
	                    private ["_civFactions"];

	                    _civFactions = [];

	                    // Get civilian factions of existing groups
	                    {if ((side leader _x) == CIVILIAN) then {_civFactions = (_civFactions - [faction leader _x]) + [faction leader _x]}} foreach allgroups;

	                    // Get civilian factions from Amb Civs
	                    If (!isnil "ALiVE_Agenthandler") then {
	                        _AllAgents = [ALiVE_Agenthandler,"agents",["",[],[],nil]] call ALiVE_fnc_HashGet;
	                        if (count (_AllAgents select 2) > 0) exitwith {_civFactions = _civFactions + [[(_AllAgents select 2 select 0),"faction","CIV_F"] call ALiVE_fnc_HashGet]};
	                    };

	                    [time,_center,_id,_size,selectRandom _factions,[_objective,"suicide",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,_civFactions] spawn ALiVE_fnc_INS_suicide;
	                };

                    if (alive _roadblocks) then {
                        if (!isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS") then {
                            {
                                // Reset "disable"-action on exisiting roadblocks at the objective once at mission start
                                if (_center distance _x < (_size + 50) && {count (nearestObjects [_x, ["ALIVE_DemoCharge_Remote_Ammo"],2]) < 2}) then {

                                    private _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", _x, [], 0, "CAN_COLLIDE"];

                                    [
                                        _charge,
                                        "disable the roadblock!",
                                        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                                        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                                        "_this distance2D _target < 2.5",
                                        "_caller distance2D _target < 2.5",
                                        {},
                                        {},
                                        {
                                            params ["_target", "_caller", "_ID", "_arguments"];

                                            private _charge = _arguments select 0;

                                            [getpos _charge,30] remoteExec  ["ALiVE_fnc_RemoveComposition",2];

                                            ["Nice Job", format ["%1 disabled the roadblock at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side _caller];

                                            deletevehicle _charge;
                                        },
                                        {},
                                        [_charge],
                                        15
                                    ] remoteExec ["BIS_fnc_holdActionAdd", 0,true];
                                };
                            } foreach ALiVE_CIV_PLACEMENT_ROADBLOCKS;
                        };
                    };

	                //Set default data
	                //[_objective,"opcom_orders","none"] call AliVE_fnc_HashSet;
	                //[_objective,"tacom_state","none"] call AliVE_fnc_HashSet;
	                //[_objective,"opcom_state","unassigned"] call AliVE_fnc_HashSet;
	                //[_objective,"section",[]] call AliVE_fnc_HashSet;
	                [_objective,"objectiveType",[_objective,"objectiveType","MIL"] call AliVE_fnc_HashGet] call AliVE_fnc_HashSet;

	                // debug ---------------------------------------
	                if (_debug) then {_args setMarkerColorLocal "ColorWhite"};
	                // debug ---------------------------------------

                //} call CBA_fnc_DirectCall;

                _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
            };
            _result = _args;
        };

        case "removeObjective": {
            if(isnil "_args") then {
                    _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
            } else {
                ASSERT_TRUE(typeName _args == "STRING",str _args);
                private ["_objective","_section","_debug","_objectiveID","_index"];

                _objectiveID = _args;

                _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
                _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

                {
                    _oID = [_x,"objectiveID",""] call ALiVE_fnc_HashGet;

                    if (_oID == _objectiveID) exitwith {
                        _section = [_x,"section",[]] call ALiVE_fnc_HashGet;

                        {[_logic,"resetorders",_x] call ALiVE_fnc_OPCOM} foreach _section;
                        [_logic,"resetObjective",_objectiveID] call ALiVE_fnc_OPCOM;

                        _index = _foreachIndex;
                    };
                } foreach _objectives;

                if !(isnil "_index") then {
                    _objectives set [_index,objNull];
                    _objectives = _objectives - [objNull];

                    [_logic,"objectives", _objectives] call ALiVE_fnc_HashSet;
                };

                _args = _objectives;

                // debug ---------------------------------------
                if (_debug) then {deletemarkerLocal _objectiveID};
                // debug ---------------------------------------
            };
            _result = _args;
        };

        case "findReinforcementBase": {
                _AO = [];
                _FOB = [];
                {
                    private ["_state","_orders"];

                    _orders = [_x,"opcom_orders",""] call ALiVE_fnc_HashGet;
                    _state = [_x,"opcom_state",""] call ALiVE_fnc_HashGet;

                    if (_orders in ["attack","defend"]) then {_AO pushback _x} else {
                        if (_state in ["reserving","idle"]) then {
                            _FOB pushback _x;
                        };
                    };
                } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);

                if (count _FOB > 0 && {count _AO > 0}) then {
                    _FOB = [_FOB,[[_AO select 0,"center",[0,0,0]] call ALiVE_fnc_HashGet],{_input0 distance ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

                    _result = _FOB select 0;
                } else {
                    if (count _FOB > 0) then {
                        _result = _FOB select 0;
                    };
                };
        };

        case "addTask": {
            _operation = _args select 0;
            _pos = _args select 1;
            _section = _args select 2;
            _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;

            _objective = [_logic,"addObjective",[_pos,100,"internal"]] call ALiVE_fnc_OPCOM;
            [_objective,"section",_section] call AliVE_fnc_HashSet;

            _TACOM_FSM setFSMVariable ["_busy",false];
            _TACOM_FSM setFSMVariable ["_TACOM_DATA",["true",nil]];

            switch (_operation) do {
                case ("recon") : {
                    _recon = [_objective,_section];
                    _TACOM_FSM setFSMVariable ["_recon",_recon];
                };
                case ("capture") : {
                    _capture = [_objective,_section];
                    _TACOM_FSM setFSMVariable ["_capture",_capture];
                };
                case ("defend") : {
                    _defend = [_objective,_section];
                    _TACOM_FSM setFSMVariable ["_defend",_defend];
                };
                case ("reserve") : {
                    _reserve = [_objective,_section];
                    _TACOM_FSM setFSMVariable ["_reserve",_reserve];
                };
            };
        };

        case "pause": {
            if(isNil "_args") then {
                // if no new value was provided return current setting
                _args = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
            } else {
                    // if a new value was provided set groups list
                    ASSERT_TRUE(typeName _args == "BOOL",str typeName _args);

                    waituntil {[_logic,"startupComplete",false] call ALiVE_fnc_HashGet && {([_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet) > -1} && {!isNil {([_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet) getFSMVariable "_pause"}}};

                    private ["_state"];

                    _state = [_logic,"pause",objNull,false] call ALIVE_fnc_OOsimpleOperation;
                    if (_state && _args) exitwith {};

                    //Set value
                    _args = [_logic,"pause",_args,false] call ALIVE_fnc_OOsimpleOperation;

                    _OPCOM_FSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
                    _TACOM_FSM = [_logic,"TACOM_FSM",-1] call ALiVE_fnc_HashGet;

                    _TACOM_FSM setFSMvariable ["_pause",_args];
                    _OPCOM_FSM setFSMvariable ["_pause",_args];

                    ["ALiVE Pausing state of %1 instance set to %2!",QMOD(ADDON),_args] call ALiVE_fnc_Dump;
            };
            _result = _args;
        };

        case "stop": {
            private ["_opcomID","_opcomFSM","_tacomFSM"];

            _opcomID = [_logic,"opcomID",""] call ALiVE_fnc_HashGet;
            _opcomFSM = [_logic, "OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
            _tacomFSM = [_logic, "TACOM_FSM",-1] call ALiVE_fnc_HashGet;

            if (_tacomFSM != -1) then {
                _tacomFSM setFSMvariable ["_exitFSM",true];
                _tacomFSM setFSMvariable ["_busy",false];
                waituntil {sleep 1; isnil {[_this select 0, "TACOM_FSM"] call ALiVE_fnc_HashGet}};
            };
            if (_opcomFSM != -1) then {
                _opcomFSM setFSMvariable ["_exitFSM",true];
                _opcomFSM setFSMvariable ["_busy",false];
                waituntil {sleep 1; isnil {[_this select 0, "OPCOM_FSM"] call ALiVE_fnc_HashGet}};
            };

            ["ALiVE OPCOM stopped..."] call ALiVE_fnc_Dump;

            _result = true;
        };

        case "createhashobject": {
                if (isServer) then {
                        _result = [] call ALIVE_fnc_hashCreate;
                        [_result,"super"] call ALIVE_fnc_hashRem;
                        [_result,"class"] call ALIVE_fnc_hashRem;
                };
        };

        case "convert": {
            if !(isNil "_args") then {
                if(typeName _args == "STRING") then {
                    if !(_args == "") then {
                        _args = [_args, " ", ""] call CBA_fnc_replace;
                        _args = [_args, "[", ""] call CBA_fnc_replace;
                        _args = [_args, "]", ""] call CBA_fnc_replace;
                        _args = [_args, """", ""] call CBA_fnc_replace;
                        _args = [_args, ","] call CBA_fnc_split;

                        if !(count _args > 0) then {
                            _args = [];
                        };
                    } else {
                        _args = [];
                    };
                };
                _result = _args;
            };
        };

        case "convertObject": {
            private ["_object"];

            if !(isNil "_args") then {
                if (typeName _args == "ARRAY") then {

                    _object = objNull;

                    if (count _args == 2) then {
                        _object = (_args select 0) nearestObject (_args select 1);

                        if (isnil "_object" || {!alive _object}) then {
                            _objects = (_args select 0) nearEntities [_args select 1,1];

                            if (count _objects > 0) then {_object = _objects select 0};
                        };
                    };
                } else {
                    if(typeName _args == "OBJECT") then {
                        if (alive _args) then {_object = [[getposATL _args select 0,getposATL _args select 1],typeOf _args]} else {_object = []};
                    };
                };
                _result = _object;
            };
        };

        case "saveData": {
            private ["_objectives","_exportObjectives","_objective","_objectiveID","_exportObjective","_objectivesGlobal","_save","_messages","_message","_saveResult"];

            if (isServer && {!isNil "ALIVE_sys_data"} && {!ALIVE_sys_data_DISABLED}) then {

                private ["_exportProfiles","_async","_missionName"];

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA TRIGGERED"] call ALiVE_fnc_Dump;
                };

                _result = [false,[]];
                _blacklist = ["code","actions"];

                //Save only every 60 seconds, bad hack because of this http://dev.withsix.com/issues/74321
                //For normal each instance would save their own objectives but the hack collects all objectives of all OPCOMs on one save, FIFO principle
                if (isnil QGVAR(OBJECTIVES_DB_SAVE) || {!(isnil QGVAR(OBJECTIVES_DB_SAVE)) && {time - (GVAR(OBJECTIVES_DB_SAVE) select 1) > 300}}) then {

                    _objectivesGlobal = [];
                    {
                        if ([_x,"persistent",false] call ALIVE_fnc_HashGet) then {
                            _objectivesGlobal = _objectivesGlobal + ([_x, "objectives",[]] call ALiVE_fnc_HashGet);
                        };
                    } foreach OPCOM_INSTANCES;

                    GVAR(OBJECTIVES_DB_SAVE) = [_objectivesGlobal,time];
                    {
                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - SAVE DATA Objective prepared for DB: %1",_x] call ALiVE_fnc_Dump;
                        };
                    } foreach (GVAR(OBJECTIVES_DB_SAVE) select 0);
                    _save = true;
                };
                if (isnil "_save") exitwith {["ALiVE OPCOM - SAVE DATA Please wait at least 5 minutes before saving again!"] call ALiVE_fnc_Dump;};
                if (count (GVAR(OBJECTIVES_DB_SAVE) select 0) == 0) exitwith {["ALiVE SAVE OPCOM DATA Dataset is empty, not saving...!"] call ALiVE_fnc_Dump;};

                //If I didnt send you to hell - go and save, the feck!
                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA - SYS DATA EXISTS"] call ALIVE_fnc_dump;
                };

                if (isNil QGVAR(DATAHANDLER)) then {

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
                    };

                    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
                   };

                _exportObjectives = [] call ALIVE_fnc_hashCreate;

                {
                    _objective = _x;
                    _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;

                    _exportObjective = [_objective, [], []] call ALIVE_fnc_hashCopy;

                    if([_exportObjective, "_rev"] call ALIVE_fnc_hashGet == "") then {
                        [_exportObjective, "_rev"] call ALIVE_fnc_hashRem;
                    };

                    {[_exportObjective, _x] call ALIVE_fnc_hashRem} foreach _blacklist;

                    [_exportObjectives, _objectiveID, _exportObjective] call ALIVE_fnc_hashSet;

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - EXPORT READY OBJECTIVE:"] call ALIVE_fnc_dump;
                        _exportObjective call ALIVE_fnc_inspectHash;
                    };


                } forEach (GVAR(OBJECTIVES_DB_SAVE) select 0);


                _message = format["ALiVE OPCOM - Preparing to save %1 objectives..",count(_exportObjectives select 1)];
                _messages = _result select 1;
                _messages pushback _message;


                _async = false; // Wait for response from server
                _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
                _missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName]; // must include group_id to ensure mission reference is unique across groups

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALiVE_fnc_Dump;
                };

                _saveResult = [GVAR(DATAHANDLER), "bulkSave", ["mil_opcom", _exportObjectives, _missionName, _async]] call ALIVE_fnc_Data;
                _result set [0,_saveResult];

                _message = format["ALiVE OPCOM - Save Result: %1",_saveResult];
                _messages = _result select 1;
                _messages pushback _message;

                // Save starting forces (every session to allow users to modify the array and persist it)
                if (!isnil {[_logic,"startForceStrength"] call ALiVE_fnc_HashGet}) then {
                    private _key = format ["%1-OPCOM_%2-starting-forces", _missionName, [_logic, "opcomID"] call CBA_fnc_hashGet];
                    private _prev = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;

                    private _startForceStrength = [_logic,"startForceStrength"] call ALiVE_fnc_HashGet;
                    private _data = [[["data", _startForceStrength]]] call CBA_fnc_hashCreate;

                    if (_prev isEqualType []) then {
                        private _rev = [_prev, "_rev"] call CBA_fnc_hashGet;

                        if (!isNil {_rev}) then {
                            [_data, "_rev", _rev] call CBA_fnc_hashSet;
                        };
                    };

                    [GVAR(DATAHANDLER), "write", ["mil_opcom", _data, false, _key]] call ALIVE_fnc_Data;
                };

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA RESULT (maybe truncated in RPT, dont worry): %1",_saveResult] call ALIVE_fnc_dump;
                    ["ALiVE OPCOM - SAVE DATA SAVING COMPLETE!"] call ALiVE_fnc_Dump;
                };
            };
        };

        case "loadData": {
            private ["_stopped","_result"];

            if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {["ALiVE LOAD OPCOM DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE OR NOT DEDICATED!"] call ALIVE_fnc_dumpR};

            //Stop OPCOM
            _stopped = [_logic,"stop"] call ALiVE_fnc_OPCOM;

            //Load from DB
            _objectives = [_logic,"loadObjectivesDB"] call ALiVE_fnc_OPCOM;

            //Reset objectives
            [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;

            //Restart OPCOM
            switch ([_logic,"controltype","invasion"] call ALiVE_fnc_HashGet) do {
                case ("occupation") : {
                    _OPCOM = [_logic] call {
                        _handler = _this select 0;

                        _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                        _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                        [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                        [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                    };
                };
                case ("invasion") : {
                    _OPCOM = [_logic] call {
                        _handler = _this select 0;

                        _OPCOM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                        _TACOM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                        [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                        [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                    };
                };
                case ("asymmetric") : {
                    _OPCOM = [_logic] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                    [_logic, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                    [_logic, "TACOM_FSM",-1] call ALiVE_fnc_HashSet;
                };
            };

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE OPCOM - LOAD DATA Imported %1 objectives from DB!",count ([_logic,"objectives",[]] call ALiVE_fnc_HashGet)] call ALiVE_fnc_Dump;
            };

            _result = _objectives;
        };

        case "loadObjectivesDB": {
            private["_objectives","_exportObjectives","_objective","_objectiveID","_exportObjective","_opcomFSM","_tacomFSM"];

            _opcomID = [_logic,"opcomID",""] call ALiVE_fnc_HashGet;
            _objectives = [];

            if (isServer) then {

                if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {
                    private ["_importProfiles","_async","_missionName","_result","_stopped","_i"];

                    //defaults
                    _async = false;
                    _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
                    _missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - LOAD DATA  - MISSION: %1",_missionName] call ALiVE_fnc_Dump;
                    };

                    //Load only every 5 minutes
                    if (isnil QGVAR(OBJECTIVES_DB_LOAD) || {!(isnil QGVAR(OBJECTIVES_DB_LOAD)) && {time - (GVAR(OBJECTIVES_DB_LOAD) select 1) > 300}}) then {

                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - LOAD DATA  FROM DB, PLEASE WAIT..."] call ALiVE_fnc_Dump;
                        };

                        if (isNil QGVAR(DATAHANDLER)) then {

                            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                                ["ALiVE OPCOM - CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
                            };

                            GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
                            [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
                       };

                        [true] call ALIVE_fnc_timer;
                        GVAR(OBJECTIVES_DB_LOAD) = [[GVAR(DATAHANDLER), "bulkLoad", ["mil_opcom", _missionName, _async]] call ALIVE_fnc_Data,time];
                        [] call ALIVE_fnc_timer;

                        //Exit if no loaded data
                        if (((typeName (GVAR(OBJECTIVES_DB_LOAD) select 0)) == "BOOL") && {!(GVAR(OBJECTIVES_DB_LOAD) select 0)}) exitwith {};

                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - LOAD DATA %1 OBJECTIVES LOADED FROM DB!",count ((GVAR(OBJECTIVES_DB_LOAD) select 0) select 2)] call ALiVE_fnc_Dump;
                        };
                    } else {

                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - LOAD DATA FROM CACHE!"] call ALiVE_fnc_Dump;
                        };
                    };

                    _result = GVAR(OBJECTIVES_DB_LOAD) select 0;

                    if (!(isnil "_result") && {typename _result == "ARRAY"} && {count _result > 0} && {count (_result select 2) > 0}) then {

                        _objectives = [];
                        {
                            _id = [_x,"opcomID",""] call ALiVE_fnc_HashGet;

                            if (_id == _opcomID) then {

                                //["ALiVE LOAD OPCOM DATA RESETTING RESULT %1/%2!",_foreachIndex,(count _objectives)] call ALiVE_fnc_Dump;

                                _rev = [_x,"_rev",""] call ALiVE_fnc_HashGet;

                                [_x, "_id"] call ALIVE_fnc_hashRem;
                                [_x, "_rev"] call ALIVE_fnc_hashRem;

                                [_x,"_rev",_rev] call ALiVE_fnc_HashSet;

                                _objectives pushback _x;
                            };
                        } foreach (_result select 2);

                        private ["_keys"];

                        _keys = [
                                    "objectiveID","center","size","objectiveType","priority","opcom_state","clusterID","opcomID",
                                    "opcom_orders","danger","sectionAssist","section","tacom_state",
                                    "factory","HQ","ambush","depot","sabotage","ied","suicide","roadblocks",
                                    "actionsFulfilled",
                                    "_rev"
                                ];

                        // Rebuild objectives in correct index-order
                        {
                            private ["_entry","_target"];

                            //["ALiVE LOAD OPCOM DATA CLEANING HASH %1/%2!",_foreachIndex,(count _objectives)] call ALiVE_fnc_Dump;

                            _entry = _x;

                            _target = [nil, "createhashobject"] call ALIVE_fnc_OPCOM;

                            {
                                _data = [_entry,_x] call ALiVE_fnc_HashGet;

                                if !(isnil "_data") then {
                                    [_target,_x,_data] call ALiVE_fnc_HashSet;
                                } else {
                                    [_target,_x] call ALiVE_fnc_HashRem;
                                };
                            } foreach _keys;

                            _objectives set [_foreachIndex,_target];
                        } foreach _objectives;

                        [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;
                        [_logic,"clusteroccupation",[]] call ALiVE_fnc_HashSet;

                        _i = 10;

                        _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
                        {
                            private ["_oID","_section","_orders","_state"];

                            _entry = _x;

                            if (_i == 10) then {
                                _i = 0;

                                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                                    ["ALiVE OPCOM - LOAD DATA REBUILDING OBJECTIVE %1/%2!",_foreachIndex,(count _objectives)] call ALiVE_fnc_Dump;
                                };
                            };

                            _i = _i + 1;

                            _oID = [_entry,"objectiveID",""] call ALiVE_fnc_HashGet;
                            _section = [_entry,"section",[]] call ALiVE_fnc_HashGet;

                            if !(isnil "_section") then {{[_logic,"resetorders",_x] call ALiVE_fnc_OPCOM} foreach _section};

                            if !(isnil "_oID") then {
                                switch ([_logic,"controltype","invasion"] call ALiVE_fnc_HashGet) do {
                                    case ("asymmetric") : {
                                        [_logic,"initObjective",_oID] call ALiVE_fnc_OPCOM;
                                    };

                                    default {
                                        [_logic,"resetObjective",_oID] call ALiVE_fnc_OPCOM;
                                    };
                                };
                            };
                        } foreach _objectives;

                        [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;
                        _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;

                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - LOAD DATA IMPORTED %1 OBJECTIVES FROM DB!",count _objectives] call ALiVE_fnc_Dump;
                        };
                    } else {
                        if(ALiVE_SYS_DATA_DEBUG_ON) then {
                            ["ALiVE OPCOM - LOAD DATA LOADING FROM DB FAILED!"] call ALIVE_fnc_dump;
                        };
                    };
                } else {
                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - LOAD DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE!"] call ALIVE_fnc_dumpR;
                    };
                };
            };

            _result = _objectives;
        };

        case "objectives": {
                if(isnil "_args") then {
                        _args = [_logic,"objectives",[]] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"objectives",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "ARRAY",str _args);

                _result = _args;
        };

        case "addObjective": {

                private ["_found"];

                if (typeName _logic == "STRING") then {


                    _found = false;

                    {
                        _factions = [_x,"factions",[]] call ALiVE_fnc_HashGet;
                        _side = [[_x,"side",""] call ALiVE_fnc_HashGet];

                        _input = _factions + _side;

                        if (_logic in _input) exitwith {_found = true; _logic = _x};
                    } foreach OPCOM_instances;
                };

                if (!isnil "_found" && {!_found}) exitwith {["ALiVE - vAI operation addObjective didn't find an OPCOM of faction or side %1!",_logic] call ALiVE_fnc_Dump};

                if(isnil "_args") then {
                    _args = [_logic,"objectives"] call ALIVE_fnc_hashGet;
                } else {
                    ASSERT_TRUE(typeName _args == "ARRAY",str _args);
                    ASSERT_TRUE(count _args > 2,str _args);

                    private ["_debug","_params","_side","_id","_pos","_size","_color","_type","_priority","_opcom_state","_clusterID","_target","_objectives","_opcomID"];

                    _debug = [_logic, "debug",false] call ALIVE_fnc_HashGet;
                    _side = [_logic, "side","EAST"] call ALIVE_fnc_HashGet;

                    _id = [_args, 0, "", [""]] call BIS_fnc_param;
                    _pos = [_args, 1, [0,0,0], [[]]] call BIS_fnc_param;
                    _size = [_args, 2, 50, [-1]] call BIS_fnc_param;
                    _type = [_args, 3, "unknown", [""]] call BIS_fnc_param;
                    _priority = [_args, 4, 100, [-1]] call BIS_fnc_param;
                    _opcom_state = [_args, 5, "unassigned", [""]] call BIS_fnc_param;
                    _clusterID = [_args, 6, "none", [""]] call BIS_fnc_param;
                    _opcomID = [_args, 7, [_logic,"opcomID",""] call ALiVE_fnc_HashGet, [""]] call BIS_fnc_param;

                    _target = [nil, "createhashobject"] call ALIVE_fnc_OPCOM;
                    [_target, "objectiveID",_id] call ALIVE_fnc_HashSet;
                    [_target, "center",_pos] call ALIVE_fnc_HashSet;
                    [_target, "size",_size] call ALIVE_fnc_HashSet;
                    [_target, "objectiveType",_type] call ALIVE_fnc_HashSet;
                    [_target, "priority",_priority] call ALIVE_fnc_HashSet;
                    [_target, "opcom_state",_opcom_state] call ALIVE_fnc_HashSet;
                    [_target, "clusterID",_clusterID] call ALIVE_fnc_HashSet;
                    [_target, "opcomID",_opcomID] call ALIVE_fnc_HashSet;
                    [_target,"_rev",""] call ALIVE_fnc_hashSet;

                    if  (_debug) then {
                        if !((format[MTEMPLATE, _id]) call ALiVE_fnc_markerExists) then {

                             _color = switch (_side) do {
                                case "EAST" : {"COLORRED"};
                                case "WEST" : {"COLORBLUE"};
                                case "GUER" : {"COLORGREEN"};
                                default {"COLORYELLOW"};
                            };

                            [format[MTEMPLATE, _id], _pos,"ICON", [0.5,0.5],_color,format["%1 #%2",_side,_id],"mil_dot","FDiagonal",0,0.5] call ALIVE_fnc_createMarkerGlobal;
                        };
                    };

                    _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;

                    _objectives pushback _target;

                    [_logic,"objectives",_objectives] call ALiVE_fnc_HashSet;

                    _args = _target;
                };
                _result = _args;
        };

        case "createobjectives": {
                if(isnil "_args") then {
                        _args = [_logic,"objectives"] call ALIVE_fnc_hashGet;
                } else {

                    private ["_objectives","_opcomID","_startpos","_side","_type","_typeOp","_pos","_height","_debug","_clusterID","_target","_asym_occupation","_factions"];

                    //Collect objectives from Military and Civilian Placement modules and order by distance from OPCOM module (for now)
                    _objectives = _args select 0;
                    _typeOp = _args select 1;

                    _startpos = [_logic,"position"] call ALiVE_fnc_HashGet;
                    _side = [_logic,"side"] call ALiVE_fnc_HashGet;
                    _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
                    _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;
                    _opcomID = [_logic,"opcomID",""] call ALiVE_fnc_HashGet;

                    _objectives_unsorted = [];
                    {
                        private ["_target","_pos","_size","_type","_priority","_clusterID","_height"];
                                _target = _x;
                                _pos = [_target,"center"] call ALiVE_fnc_hashGet;
                                _size = [_target,"size"] call ALiVE_fnc_hashGet;
                                _type = [_target,"type"] call ALiVE_fnc_hashGet;
                                _priority = [_target,"priority"] call ALiVE_fnc_hashGet;
                                _clusterID = [_target,"clusterID"] call ALiVE_fnc_hashGet;
                                _height = (ATLtoASL [_pos select 0, _pos select 1,0]) select 2;

                                _objectives_unsorted pushback [_pos,_size,_type,_priority,_height,_clusterID,_opcomID];
                    } foreach _objectives;

                    //Create objectives for OPCOM and set it on the OPCOM Handler
                    //GetObjectivesByPriority
                    {
                        private ["_target","_id","_pos","_size","_type","_priority","_clusterID","_opcom_state"];

                                _id = format["OPCOM_%1_objective_%2",_opcomID,_foreachIndex];
                                _pos = _x select 0;
                                _size = _x select 1;
                                _type = _x select 2;
                                _priority = _x select 3;
                                _opcom_state = "unassigned";
                                _clusterID = _x select 5;
                                _opcomID = _x select 6;

                                [_logic,"addObjective",[_id,_pos,_size,_type,_priority,_opcom_state,_clusterID,_opcomID]] call ALiVE_fnc_OPCOM;
                     } foreach _objectives_unsorted;

                     [_logic,"sortObjectives",_typeOp] call ALiVE_fnc_OPCOM;

                    _args = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
                };

                ASSERT_TRUE(typeName _args == "ARRAY",str _args);

                _result = _args;
        };

        case "nearestObjectives": {
            ASSERT_TRUE(typeName _args == "ARRAY" && {count _args >= 1},str _args);

            private ["_state","_pos","_objectives","_tmp"];

            _pos = _args select 0;
            _state = _args select 1; if (isnil "_state") then {_state = "attacking"};

            _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;

            if (count _objectives == 0) exitwith {_result = []};

            _tmp = []; {if (([_x,"opcom_state",""] call ALiVE_fnc_HashGet) == _state) then {_tmp pushback _x}} foreach _objectives;
            _tmp = [_tmp,[_pos],{_Input0 distance ([_x,"center",[0,0,0]] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

            _result = +_tmp;
        };

        case "nearestEntity": {
            ASSERT_TRUE(typeName _args == "ARRAY" && {count _args >= 1},str _args);

            private ["_objectives","_state"];

            _unit = _args select 0;
            _state = _args select 1; if (isnil "_state") then {_state = "attacking"};

            _pos = getposATL _unit;
            _faction = faction _unit;

            _objectives = [_logic,"nearestObjectives",[_pos,_state]] call ALiVE_fnc_OPCOM;

            if (count _objectives == 0) exitwith {};

            {
                private ["_profile"];

                _profile = [ALiVE_ProfileHandler,"getProfile",_x] call ALiVE_fnc_ProfileHandler;

                if !(isnil "_profile") exitwith {_result = _x}
            } foreach ([_objectives select 0,"section",[]] call ALiVE_fnc_HashGet);
        };

        case "joinObjectiveClient": {
            ASSERT_TRUE(typeName _args == "ARRAY",str _args);

            private ["_positions","_pos"];

            // Execute Function on Clients only
            if !(hasInterface) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",owner _unit]};

            _args params [
                ["_unit", player, [objNull]],
                ["_objectives", [], [[]]],
                ["_color", "COLORYELLOW", [""]]
            ];

            // Only run function if objectives are provided
            if (count _objectives == 0) exitwith {hint "OPCOM currently has no assault objectives in his list!"};

            // Mark objectives, this handy function should be moved to x lib
            _fnc_createMarkerArray = {
                private ["_markers"];

                params [
                    ["_positions", [], [[]]],
                    ["_color", "COLORYELLOW", [""]],
                    ["_shape", "RECTANGLE", [""]],
                    ["_size", [500, 500], [[]]],
                    ["_type", "EMPTY", [""]],
                    ["_text", "", [""]],
                    ["_brush", "SOLID", [""]],
                    ["_alpha", 0.5, [-1]]
                ];

                _markers = [];
                {
                    _m = createMarkerLocal [str(_x), _x];
                    _m setMarkerShapeLocal _shape;
                    _m setMarkerSizeLocal _size;
                    _m setMarkerTypeLocal _type;
                    _m setMarkerColorLocal _color;
                    _m setMarkerTextLocal _text;
                    _m setMarkerBrushLocal _brush;
                    _m setMarkerAlphaLocal _alpha;

                    _markers pushback _m;
                } foreach _positions;

                _markers;
            };
            _positions = []; {_positions pushback ([_x,"center"] call ALiVE_fnc_Hashget)} foreach _objectives;
            [_positions,_color,"RECTANGLE",[500,500],"EMPTY","","FDiagonal",0.5] call _fnc_createMarkerArray;

            // Select position on map
            openmap true; hint "Click on map to select objective!";
            ALiVE_MIL_OPCOM_CLICKPOS = nil; onMapSingleclick "ALiVE_MIL_OPCOM_CLICKPOS = _pos; onMapSingleclick ''";
            waituntil {!isnil "ALiVE_MIL_OPCOM_CLICKPOS"}; _pos = ALiVE_MIL_OPCOM_CLICKPOS;
            ALiVE_MIL_OPCOM_CLICKPOS = nil; hint "Objective selected! Please wait while OPCOM is preparing the operation...";

            // Get nearest objective from that position
            _objectives = [_objectives,[_pos],{_Input0 distance ([_x,"center"] call ALiVE_fnc_HashGet)},"ASCEND"] call ALiVE_fnc_SortBy;

            [_logic,"joinObjectiveServer",[_unit,_objectives select 0]] call ALiVE_fnc_OPCOM;

            openmap false;

            // Remove markers
            {deleteMarkerLocal str(_x)} foreach _positions;
        };

        case "joinObjectiveServer": {
            ASSERT_TRUE(typeName _args == "ARRAY",str _args);

            private ["_section","_entityID","_profile","_error","_players"];

            // Execute on Server only
            if !(isServer) exitwith {[_logic,_operation,_args] remoteExec ["ALiVE_fnc_OPCOM",2]};

            _args params [
                ["_unit", objNull, [objNull]],
                ["_objective", [], [[]]]
            ];

            _section = ([_objective,"section",[]] call ALiVE_fnc_HashGet) - [_unit getvariable ["profileID",""]]; if (count _section <= 0) then {_error = "OPCOM responds that the select section is destroyed!"};
            _profile = [ALiVE_ProfileHandler,"getProfile",_section select 0] call ALiVE_fnc_ProfileHandler; if (isnil "_profile") then {_error = "OPCOM reports that the assigned group is already dead!"};
            _profileUnit = [ALiVE_ProfileHandler,"getProfile",_unit getvariable ["profileID",""]] call ALiVE_fnc_ProfileHandler; if (isnil "_profileUnit") then {_error = "OPCOM reports that players group cannot be assigned!"};

            if !(isnil "_error") exitwith {hint _error; ["%1",_error] call ALiVE_fnc_Dump};

            _players = []; {if (isPlayer _x) then {_players pushback _x}} foreach (units group _unit);

            {{titleText ['Preparing Insertion...', 'BLACK OUT',2]} remoteExec ["BIS_fnc_Spawn",owner _x]; sleep 0.2} foreach _players;

            sleep 5;

            _unit setposATL ([_profile,"position"] call ALiVE_fnc_HashGet);

            waituntil {sleep 1; [_profile,"active"] call ALiVE_fnc_HashGet};

            _units = [_profile,"units"] call ALIVE_fnc_hashGet;
            _group = group (_units select 0);

            (units (group _unit)) join _group;

            sleep 5;

            if ((vehicle leader _group) == (leader _group)) then {
                {_x setposATL (formationPosition _x)} foreach (units (group _unit));

                //_x addBackpack "B_Parachute" is local - applause
                //_pos set [2,1000];
                //{_x addBackpack "B_Parachute"; _x setPosATL _pos} foreach _groupUnits;
            } else {
                {_x setposATL ([getposATL leader _group,50] call CBA_fnc_RandPos); _x moveInCargo (vehicle leader _group)} foreach (units (group _unit));
            };

            [_profileUnit, "clearWaypoints"] call ALIVE_fnc_profileEntity;
            {[_profileUnit, "addWaypoint", _x] call ALIVE_fnc_profileEntity} foreach ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet);

            {{titleText ['Inserting...', 'BLACK IN',2]} remoteExec ["BIS_fnc_Spawn",owner _x]; sleep 0.2} foreach _players;
        };

        case "analyzeclusteroccupation": {
            ASSERT_TRUE(typeName _args == "ARRAY",str _args);

            private ["_pos","_item","_type","_prios","_side","_sides","_id","_entArr","_ent","_sectors","_entities","_state","_controltype"];

            _sides = _args;
            _sidesF = _sides select 0;
            _sidesE = _sides select 1;
            _objectives = [_logic,"objectives",[]] call ALiVE_fnc_HashGet;
            _controltype = [_logic, "controltype","invasion"] call ALiVE_fnc_HashGet;

            //_distance = _args select 1;
            _result_tmp = [];
            for "_i" from 0 to ((count _sides)-1) do {
                    _sideX = _sides select _i;
                    _nearForces = [];

                    {
                          for "_z" from 0 to ((count _objectives)-1) do {
                        _item = _objectives select _z;
                        _pos = [_item,"center"] call ALiVE_fnc_HashGet;
                        _id = [_item,"objectiveID"] call ALiVE_fnc_HashGet;
                        _state = [_item,"opcom_state","unassigned"] call ALiVE_fnc_HashGet;
                        _size_reserve = [_logic,"sectionsamount_reserve",1] call ALiVE_fnc_HashGet;
                        _section = [_item,"section",[]] call ALiVE_fnc_HashGet;

                        _type = "surroundingsectors";
                        _entArr = [];
                        _entities = [];

                       if (count _section < 1) then {[_item,"opcom_state","unassigned"] call ALiVE_fnc_HashSet; [_item,"opcom_orders","none"] call ALiVE_fnc_HashSet; [_item,"danger",-1] call ALiVE_fnc_HashSet};

                       _profiles = [_pos, 500, [_x,"entity"]] call ALIVE_fnc_getNearProfiles;
                        {
                            if (typeName (_x select 2 select 4) == "STRING") then {
                                _entities pushback (_x select 2 select 4);

                                //player sidechat format["Entities: %1, count total %2 val %3",_entities,count _entities,(_x select 2 select 4)];
                                   //diag_log format["Entities: %1, count total %2 val %3",_entities,count _entities,(_x select 2 select 4)];
                            };
                            //sleep 0.03;
                        } foreach _profiles;


                        if (count _entities > 0) then {_nearForces pushback [_id,_entities]};
                    };
                } foreach _sideX;

                _result_tmp pushback _nearForces;
            };

            _targetsTaken1 =  _result_tmp select 0;
            _targetsTaken2 =  _result_tmp select 1;

            _targetsAttacked1 = [];
            _remover1 = [];
            {
                _targetID = _x select 0;
                _entities = _x select 1;

                if (({(_x select 0) == _targetID} count _targetsTaken2 > 0) && {(typename _x == "ARRAY")}) then {
                    _targetsAttacked1 pushback _x;
                    _remover1 pushback _foreachIndex;
                };
                //sleep 0.03;
            } foreach _targetsTaken1;

            _targetsAttacked2 = [];
            _remover2 = [];
            {
                _targetID = _x select 0;
                _entities = _x select 1;

                if (({(_x select 0) == _targetID} count _targetsTaken1 > 0) && {(typename _x == "ARRAY")}) then {
                    _targetsAttacked2 pushback _x;
                    _remover2 pushback _foreachIndex;
                };
                //sleep 0.03;
            } foreach _targetsTaken2;


            {
                if !(_x > ((count _targetsTaken1)-1)) then {
                       _targetsTaken1 set [_x,"x"];
                       _targetsTaken1 = _targetsTaken1 - ["x"];
                };
                //sleep 0.03;
            } foreach _remover1;

            _targetsTaken1 = _targetsTaken1 - [objNull];

            {
                if !(_x > ((count _targetsTaken2)-1)) then {
                       _targetsTaken2 set [_x,"x"];
                       _targetsTaken2 = _targetsTaken2 - ["x"];
                };
                //sleep 0.03;
            } foreach _remover2;

            _targetsTaken2 = _targetsTaken2 - [objNull];

            _result = [_targetsTaken1, _targetsAttacked1, _targetsTaken2, _targetsAttacked2,time];
            [_logic,"clusteroccupation",_result] call AliVE_fnc_HashSet;

            _targetsTaken = _result select 0;
            _targetsAttacked = _result select 1;
            _targetsTakenEnemy = _result select 2;
            _targetsAttackedEnemy = _result select 3;

            switch (_controltype) do {
                case ("invasion") : {
                    _prios = [
                        [_targetsTaken,"reserve"],
                        [_targetsTakenEnemy,"attack"],
                        [_targetsAttackedEnemy,"defend"]
                    ];
                };

                case ("occupation") : {
                    _prios = [
                        [_targetsTaken,"reserve"],
                        [_targetsTakenEnemy,"attack"],
                        [_targetsAttackedEnemy,"defend"]
                    ];
                };
                case ("asymmetric") : {
                    _prios = [
                        [_targetsTaken,"reserve"],
                        [_targetsTakenEnemy,"attack"],
                        [_targetsAttackedEnemy,"defend"]
                    ];
                };
            };

            {
                [_logic,"setstatebyclusteroccupation",[(_x select 0),(_x select 1)]] call ALiVE_fnc_OPCOM;
            } foreach _prios;

            //diag_log format ["%5: Taken %1 | Attacked %2 // %6: Taken %3 | Attacked %4",_targetsTaken, _targetsAttackedEnemy, _targetsTakenEnemy, _targetsAttackedEnemy,_sidesF,_sidesE];
            //player sidechat format ["%5: Taken %1 | Attacked %2 // %6: Taken %3 | Attacked %4",_targetsTaken, _targetsAttackedEnemy, _targetsTakenEnemy, _targetsAttackedEnemy,_sidesF,_sidesE];
        };

        ///////////////////////////////////////////////////
        // Scan position for nearby, visible enemy profiles.
        // Returns array of all found enemies
        ///////////////////////////////////////////////////

        case "scanForNearEnemies": {
            _args params ["_position",["_requireVisibility", true]];

            private _sidesEnemy = [_logic,"sidesenemy", ["EAST"]] call ALiVE_fnc_HashGet;

            _result = [_logic,"findProfilesNearPosition", [_pos,_sidesEnemy,_requireVisibility]] call MAINCLASS;
        };

        ///////////////////////////////////////////////////
        // Scan all controlled profiles for nearby enemy profiles.
        // Wipes existing knownentities data.
        // Returns array of all found enemies
        ///////////////////////////////////////////////////

        case "scanFriendliesForNearEnemies": {

            private _factions = [_logic,"factions",[]] call ALiVE_fnc_HashGet;

            // private _duration = time; ["TACOM Trigger enemyscan for %1 at %2",_factions,_duration] call ALiVE_fnc_DumpR;

			private _controlledProfileIDs = [];
			{
				_controlledProfileIDs = _controlledProfileIDs + ([ALiVE_ProfileHandler,"getProfilesByFaction",_x] call ALiVE_fnc_ProfileHandler);
			} foreach _factions;

            private _knownEntities = [];
			{
				private _profile = [ALiVE_ProfileHandler,"getProfile", _x] call ALiVE_fnc_ProfileHandler;

				if (!isnil "_profile") then {
					private _pos = [_profile,"position"] call ALiVE_fnc_HashGet;
                    private _nearEnemies = [_logic,"scanForNearEnemies", [_pos,true]] call MAINCLASS;

                    {
                        _knownEntities pushbackunique _x;
                    } foreach _nearEnemies;
                };
			} foreach _controlledProfileIDs;

			[_logic,"knownentities", _knownEntities] call ALiVE_fnc_HashSet;

            // ["TACOM enemyscan for %1 finished in %2 seconds",_factions, time - _duration] call ALiVE_fnc_DumpR;

            _result = _knownEntities;

        };

        case "scantroops" : {

            private ["_inf","_mot","_mech","_arm","_air","_sea","_profileIDs","_artilleryClasses","_AAA","_AAAClasses"];

            _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
            _duration = time;

            _profileIDs = [];
            {
                _profileIDs = _profileIDs + ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
            } foreach _factions;

            _inf = [];
            _mot = [];
            _AAA = [];
            _arm = [];
            _air = [];
            _sea = [];
            _mech = [];
            _arty = [];

            if (isnil "_profileIDs" || {count _profileIDs == 0}) exitwith {_result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA]};

            {
                private ["_profile","_assignments","_type","_objectType","_vehicleClass","_busy"];

                _profile = [ALIVE_profileHandler, "getProfile",_x] call ALIVE_fnc_profileHandler;

                if !(isnil "_profile") then {

                    _type = [_profile,"type",""] call ALIVE_fnc_hashGet;
                    _objectType = [_profile,"objectType",""] call ALIVE_fnc_hashGet;
                    _vehicleClass = [_profile,"vehicleClass",""] call ALIVE_fnc_hashGet;

                    switch (tolower _type) do {

                        case ("vehicle") : {

                            _assignments = [_profile,"entitiesInCommandOf",[]] call ALIVE_fnc_hashGet;

                            if ((count (_assignments)) > 0) then {

                                // Dont collect vehicles with player profiles assigned
                                if ({(_x getvariable ["profileID",""]) in _assignments} count allPlayers > 0) exitwith {};

                                switch (tolower _objectType) do {
                                    case "car": {
                                            {if !(_x in _mot) then {_mot pushback _x}} foreach _assignments;
                                    };
                                    case "tank": {
                                            if ([_vehicleClass] call ALiVE_fnc_isAA || {[_vehicleClass] call ALiVE_fnc_isArtillery}) then {
                                                if ([_vehicleClass] call ALiVE_fnc_isArtillery) then {{if !(_x in _arty) then {_arty pushback _x}} foreach _assignments};
                                                if ([_vehicleClass] call ALiVE_fnc_isAA) then {{if !(_x in _AAA) then {_AAA pushback _x}} foreach _assignments};
                                            } else {
                                                {if !(_x in _arm) then {_arm pushback _x}} foreach _assignments;
                                            };
                                    };
                                    case "armored": {
                                            {if !(_x in _mech) then {_mech pushback _x}} foreach _assignments;
                                    };
                                    case "truck": {
                                            {if !(_x in _mot) then {_mot pushback _x}} foreach _assignments;
                                    };
                                    case "ship": {
                                            {if !(_x in _sea) then {_sea pushback _x}} foreach _assignments;
                                    };

                                    /* // Since ATO is in place do not control air assets and pilots
                                    case "helicopter": {
                                            {if !(_x in _air) then {_air pushback _x}} foreach _assignments;
                                    };
                                    case "plane": {
                                            {if !(_x in _air) then {_air pushback _x}} foreach _assignments;
                                    };
                                    */
                                };
                            };
                        };

                        case ("entity") : {

                            _assignments = ([_profile,"vehicleAssignments",["",[],[],nil]] call ALIVE_fnc_hashGet) select 1;
                            _unitClasses = [_profile,"unitClasses",[]] call ALIVE_fnc_hashGet;

                            if (
                                count _assignments == 0 && // entity is not assigned to a vehicle
                                {!([_profile,"isPlayer",false] call ALIVE_fnc_hashGet)} && // not a player
                                {{[toLower _x, "pilot"] call CBA_fnc_find != -1} count _unitClasses == 0} // no pilots in entity
                               ) then {
                                _inf pushback _x;
                            };
                        };
                    };
                };
            } foreach _profileIDs;

            [_logic,"infantry",_inf] call ALiVE_fnc_HashSet;
            [_logic,"motorized",_mot] call ALiVE_fnc_HashSet;
            [_logic,"mechanized",_mech] call ALiVE_fnc_HashSet;
            [_logic,"armored",_arm] call ALiVE_fnc_HashSet;
            [_logic,"artillery",_arty] call ALiVE_fnc_HashSet;
            [_logic,"AAA",_AAA] call ALiVE_fnc_HashSet;
            [_logic,"air",_air] call ALiVE_fnc_HashSet;
            [_logic,"sea",_sea] call ALiVE_fnc_HashSet;

            _count = [
                count _inf,
                count _mot,
                count _mech,
                count _arm,
                count _air,
                count _sea,
                count _arty,
                count _AAA
            ];

            if (isnil {[_logic,"startForceStrength"] call ALiVE_fnc_HashGet}) then {
                [_logic,"startForceStrength",+_count] call ALiVE_fnc_HashSet
            };
            _currentForceStrength = [_logic,"currentForceStrength",_count] call ALiVE_fnc_HashSet;

            _duration = time - _duration;
            //["Scantroops time taken: %1 sec.",_duration] call ALiVE_fnc_DumpH;
            _result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA];
        };

        case "setstatebyclusteroccupation": {
                ASSERT_TRUE(typeName _args == "ARRAY",str _args);

                private ["_objectives","_operation","_idleStates","_stateX","_target"];
                _objectives = _args select 0;
                _operation = _args select 1;

                switch (_operation) do {
                    case ("unassigned") : {_idleStates = ["internal","unassigned"]};
                    case ("attack") : {_idleStates = ["internal","attack","attacking","defend","defending"]};
                    case ("defend") : {_idleStates = ["internal","defend","defending","attack","attacking"]};
                    case ("reserve") : {_idleStates = ["internal","attack","attacking","defend","defending","reserve","reserving","idle"]};
                    default {_idleStates = ["internal","reserve","reserving","idle"]};
                };

                {
                    _id = _x; if (typeName _x == "ARRAY") then {_id = _x select 0};
                    _target = [_logic,"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                    //player sidechat format["input: ID %1 | operation: %2",_id,_operation];

                    _pos = [_target,"center"] call AliVE_fnc_HashGet;
                    _stateX = [_target,"opcom_state"] call AliVE_fnc_HashGet;
                    if !(_stateX in _idleStates) then {
                        //player sidechat format["output: state %1 | operation: %2",_stateX,_operation];
                        [_target,"opcom_state",_operation] call AliVE_fnc_HashSet;
                    };
                } foreach _objectives;

                if !(isnil "_target") then {_result = [_target,_operation]} else {_result = nil};
        };

        case "selectordersbystate": {
                ASSERT_TRUE(typeName _args == "STRING",str _args);

                private _state = _args;
                private _module = [_logic,"module"] call ALiVE_fnc_HashGet;

                private _OPCOM_FSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
                private _OPCOM_SKIP_OBJECTIVES = _OPCOM_FSM getFSMvariable ["_OPCOM_SKIP_OBJECTIVES", []];

                private _objectives = [_logic, "objectives", []] call AliVE_fnc_HashGet;
                private _target = nil;
                private _order = nil;

                {
                    private _objectiveID = [_x, "objectiveID"] call AliVE_fnc_HashGet;

                    if !(_objectiveID in _OPCOM_SKIP_OBJECTIVES) then {
                        private _objectiveState = [_x, "opcom_state"] call AliVE_fnc_HashGet;

                        if (_objectiveState == _state) then {
                            switch (true) do {
                                case (_state == "attack" && {{((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0}); /* FALLTHROUGH */
                                case (_state == "unassigned" && {{((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0}): {
                                    _target = _x;
                                    _order = "attack";
                                };
                                case (_state == "defend"); /* FALLTHROUGH */
                                case (_state == "reserve"): {
                                    _target = _x;
                                    _order = _state;
                                };
                            };
                        };

                        if !(isNil "_target") exitWith {};
                    };
                } forEach _objectives;

                if !(isNil "_target") then {
                    [_target, "opcom_orders", _order] call AliVE_fnc_HashSet;

                    _result = ["execute", _target];
                } else {
                    _result = nil;
                };
        };

        case "destroy": {

                switch (typeName _logic) do {
                    case ("OBJECT") : {_logic = _logic getVariable "handler"};
                    case ("ARRAY") : {};
                };

                _OPCOM_FSM = [_logic,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
                _TACOM_FSM = [_logic,"TACOM_FSM",-1] call ALiVE_fnc_HashGet;
                _module = [_logic, "module",objNull] call ALiVE_fnc_HashGet;

                _TACOM_FSM setFSMvariable ["_exitFSM",true];
                _OPCOM_FSM setFSMvariable ["_exitFSM",true];

                missionNameSpace setVariable ["OPCOM_instances",(missionNameSpace getvariable ["OPCOM_instances",[]]) - [_logic]];

                _module setVariable ["super", nil];
                _module setVariable ["class", nil];

                deleteVehicle _module;
                deletegroup (group _module);

                _logic = nil;
        };

        case "debug": {
                if(typeName _args != "BOOL") then {
                        _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
                } else {
                        [_logic,"debug",_args] call ALIVE_fnc_hashSet;
                };
                ASSERT_TRUE(typeName _args == "BOOL",str _args);

                _result = _args;
        };

        case "OPCOM_monitor": {
            ASSERT_TRUE(typeName _args == "BOOL",str _args);

            //private ["_hdl","_side","_state","_FSM","_cycleTime"];

            _hdl = [_logic,"monitor",false] call AliVE_fnc_HashGet;

            if (!(_args) && {!(typeName _hdl == "BOOL")}) then {
                    terminate _hdl;
                    [_logic,"monitor",nil] call AliVE_fnc_HashSet;

                    if ([_this,"debug",false] call ALiVE_fnc_HashGet) then {
                        ["OPCOM and TACOM monitoring ended..."] call ALIVE_fnc_dumpR;
                    };
            } else {
                _hdl = _logic spawn {

                    // debug ---------------------------------------
                    if ([_this,"debug",false] call ALiVE_fnc_HashGet) then {
                        ["OPCOM and TACOM monitoring started..."] call ALIVE_fnc_dumpR;
                    };
                    // debug ---------------------------------------
                    _FSM_OPCOM = [_this,"OPCOM_FSM"] call AliVE_fnc_HashGet;
                    _FSM_TACOM = [_this,"TACOM_FSM"] call AliVE_fnc_HashGet;

                    private _OPCOM_OBJECTIVES = [_this,"objectives",[]] call AliVE_fnc_HashGet;

                    if (isnil QGVAR(MONITOR_FULL)) then {GVAR(MONITOR_FULL) = false};

                    while {true} do {

                            _state = _FSM_OPCOM getfsmvariable "_OPCOM_status";
                            _OPCOM_busy = _FSM_OPCOM getfsmvariable "_busy";
                            _side = _FSM_OPCOM getfsmvariable "_side";
                            _cycleTime = _FSM_OPCOM getfsmvariable "_cycleTime";
                            _timestamp = floor(time - (_FSM_OPCOM getfsmvariable "_timestamp"));
                            _OPC_DATA = _FSM_OPCOM getfsmvariable ["_OPCOM_DATA","nil"];
                            _OPC_QUEUE = _FSM_OPCOM getfsmvariable ["_OPCOM_QUEUE",[]];
                            _state_TACOM = _FSM_TACOM getfsmvariable "_TACOM_status";
                            _TACOM_busy = _FSM_TACOM getfsmvariable "_busy";

                            //Exit if FSM has ended
                            if (isnil "_cycleTime") exitwith {["Exiting OPCOM Monitor"] call ALiVE_fnc_Dump};

                            _maxLimit = _cycleTime + ((count allunits)*2);

                            if (GVAR(MONITOR_FULL)) then {

                                private _currentForceStrength = [_this,"currentForceStrength",[]] call ALiVE_fnc_HashGet;

                                private _states = [] call ALiVE_fnc_HashCreate;

                                {
                                    private _objective = _x;
                                    private _state = [_objective,"opcom_state","none"] call ALiVE_fnc_Hashget;

                                    [_states,_state,([_states, _state, 0] call ALiVE_fnc_HashGet) + 1] call ALiVE_fnc_HashSet;
                                } foreach _OPCOM_OBJECTIVES;

                                _message = parsetext format[
                                        "OPC state: %1 (%2s %3)<br/>TAC state: %4 (%5)<br/>OPC data: %6<br/>OPC processes queued: %7<br/><br/>OPC states: %8<br/>OPC statecount: %9<br/>OPC forces: %10",
                                        _state,_timestamp,_OPCOM_busy,_state_TACOM,_TACOM_busy,_OPC_DATA,count _OPC_QUEUE,_states select 1,_states select 2,_currentForceStrength,_maxLimit
                                    ];
                                hintsilent _message;
                            };

                            if (_timestamp > _maxLimit) then {
                            //if (true) then {
                                // debug ---------------------------------------
                                if ([_this,"debug",false] call ALiVE_fnc_HashGet) then {
                                    _message = parsetext (format["<t align=left>OPCOM side: %1<br/><br/>WARNING! Max. duration exceeded!<br/>state OPCOM: %2<br/>state TACOM: %4<br/>duration: %3</t>",_side,_state,_timestamp,_state_TACOM]);
                                    [_message] call ALIVE_fnc_dump; hintsilent _message;

                                    if (_timestamp > 900) then {
                                        _FSM_OPCOM setfsmvariable ["_OPCOM_DATA",nil];
                                        _FSM_OPCOM setfsmvariable ["_busy",false];
                                    };
                                };
                                // debug ---------------------------------------
                            };

                            sleep 1;
                     };
                };
                [_logic,"monitor",_hdl] call AliVE_fnc_HashSet;
            };
            _result = _hdl;
        };

        case "state": {
                private["_state"];

                if(typeName _args != "ARRAY") then {

                        // Save state

                        _state = [] call ALIVE_fnc_hashCreate;

                        // BaseClassHash CHANGE
                        // loop the class hash and set vars on the state hash
                        {
                            if(!(_x == "super") && !(_x == "class")) then {
                                [_state,_x,[_logic,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                            };
                        } forEach (_logic select 1);

                        _result = _state;

                } else {
                        ASSERT_TRUE(typeName _args == "ARRAY",str typeName _args);

                        // Restore state

                        // BaseClassHash CHANGE
                        // loop the passed hash and set vars on the class hash
                        {
                            [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                        } forEach (_args select 1);
                };
        };

        default {
                _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("OPCOM - output",_result);
if !(isnil "_result") then {_result} else {nil};
