//#define DEBUG_MODE_FULL
#include <\x\ALiVE\addons\mil_opcom\script_component.hpp>
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_OPCOM
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
_objectives = [_logic, "createobjectivesbydistance",SEP] call ALiVE_fnc_OPCOM;
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_OPCOM

#define MTEMPLATE "ALiVE_OPCOM_%1"

TRACE_1("OPCOM - input", _this);

private "_result";

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch(_operation) do {

    case "create": {

        private _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];

        TRACE_1("Creating class on all localities", true);

        // initialise module game logic on all localities
        _logic setVariable ["super", QUOTE(SUPERCLASS)];
        _logic setVariable ["class", QUOTE(MAINCLASS)];

        _result = _logic;

    };

    case "destroy": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _OPCOM_FSM = [_state,"OPCOM_FSM",-1] call ALiVE_fnc_HashGet;
        private _TACOM_FSM = [_state,"TACOM_FSM",-1] call ALiVE_fnc_HashGet;

        _TACOM_FSM setFSMvariable ["_exitFSM",true];
        _OPCOM_FSM setFSMvariable ["_exitFSM",true];

        private _registryID = [_logic,"registryID"] call MAINCLASS;
        [MOD(OPCOMGlobalRegistry),"unregister", _registryID] call ALiVE_fnc_OPCOMGlobalRegistry;

        _logic setVariable ["super", nil];
        _logic setVariable ["class", nil];

        deleteVehicle _logic;
        deletegroup (group _logic);

        _state = nil;
        _logic = nil;

    };

    case "state": {

        if (_args isEqualTo []) then {
            // Save state

            private _state = [] call ALiVE_fnc_hashCreate;

            // BaseClassHash CHANGE
            // loop the class hash and set vars on the state hash

            private _handler = [_logic,"handler"] call MAINCLASS;
            {
                if(!(_x == "super") && !(_x == "class")) then {
                    [_state,_x, ([_handler,_x] call ALiVE_fnc_hashGet)] call ALiVE_fnc_hashSet;
                };
            } forEach (_handler select 1);

            _result = _state;
        } else {
            // Restore state

            // BaseClassHash CHANGE
            // loop the passed hash and set vars on the class hash

            private _handler = [_logic,"handler"] call MAINCLASS;
            {
                [_handler,_x, ([_args,_x] call ALiVE_fnc_hashGet)] call ALiVE_fnc_hashSet;
            } forEach (_args select 1);
        };

    };

    case "debug": {

        if(_args isEqualTo true) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

        ASSERT_TRUE(_args isEqualTo true, str _args);

    };

    case "handler": {

        if(_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "registryID": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "controltype": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "asym_occupation": {

        if(_args isEqualType 0) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "intelchance": {

        if(_args isEqualType 0) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "faction1": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "faction2": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "faction3": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "faction4": {

        if(_args isEqualType "") then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "factions": {

        if(_args isEqualType []) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "simultanObjectives": {

        if(_args isEqualType 0) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "minAgents": {

        if(_args isEqualType 0) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "persistent": {

        if(_args isEqualType true) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "reinforcements": {

        if(_args isEqualType 0) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "roadblocks": {

        if(_args isEqualType true) then {
            _logic setVariable [_operation, _args];
        } else {
            _result = _logic getVariable [_operation, _args];
        };

    };

    case "init": {

        if (isServer) then {

            private _debug = call compile (_logic getvariable ["debug", "false"]);
            private _persistent = call compile (_logic getvariable ["persistent", "false"]);
            private _controlType = _logic getvariable ["controltype", "invasion"];
            private _faction1 = _logic getvariable ["faction1", "OPF_F"];
            private _faction2 = _logic getvariable ["faction2", "NONE"];
            private _faction3 = _logic getvariable ["faction3", "NONE"];
            private _faction4 = _logic getvariable ["faction4", "NONE"];
            private _factions = [_logic, "convert", _logic getvariable ["factions", []]] call MAINCLASS;

            private _reinforcementRate = _logic getvariable ["reinforcements", 0.9];
            private _simultanObjectives = _logic getvariable ["simultanObjectives", 10];

            private _asymmPreOccupation = _logic getvariable ["asym_occupation", -1];
            private _asymmIntelChance = _logic getvariable ["intelchance", 0];
            private _asymmPlaceRoadblocks = _logic getvariable ["roadblocks", true];
            private _minAgents = _logic getvariable ["minAgents", 2];

            private _modulePos = getposATL _logic;

            // collect factions and determine sides
            // if mission maker did not overwrite default factions then use the ones from the module dropdowns

            if ((count _factions) == 0) then {
                {
                    if (_x != "NONE") then {
                        _factions pushBackunique _x;
                    };
                } foreach [_faction1,_faction2,_faction3,_faction4];
            };

            private _opcomSide = "EAST";
            switch (getNumber(((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side")) do {
                case 0 : {_opcomSide = "EAST"};
                case 1 : {_opcomSide = "WEST"};
                case 2 : {_opcomSide = "GUER"};
                default {["ALiVE OPCOM - Warning: OPCOM was given a civilian faction to control (%1). OPCOM can only control factions of sides EAST, WEST, GUER", _factions select 0] call ALiVE_fnc_Dump};
            };

            private _sideObject = [_opcomSide] call ALiVE_fnc_sideTextToObject;
            private _allSides = ["EAST","WEST","GUER"];
            private _sidesEnemy = [];

            {
                if ((_sideObject getfriend ([_x] call ALiVE_fnc_sideTextToObject)) < 0.6) then {
                    _sidesEnemy pushBack _x;
                };
            } foreach (_allSides - [_opcomSide]);

            private _sidesFriendly = _allSides - _sidesEnemy;

            // init data

            _logic setVariable ["super", QUOTE(SUPERCLASS)];
            _logic setVariable ["class", QUOTE(MAINCLASS)];
            _logic setVariable ["moduleType", QMOD(OPCOM)];

            _logic setVariable ["paused", false];
            _logic setVariable ["stopped", false];
            _logic setVariable ["listenerID", ""];

            private _handler = [
                [
                    ["module", _logic],
                    ["opcomID",""],
                    ["debug", _debug],
                    ["persistent", _persistent],
                    ["position", _modulePos],
                    ["controlType", _controlType],
                    ["side", _opcomSide],
                    ["factions", _factions],
                    ["sidesEnemy", _sidesEnemy],
                    ["sidesFriendly", _sidesFriendly],
                    ["simultanObjectives", _simultanObjectives],
                    ["minAgents", _minAgents],
                    ["reinforcementRate", _reinforcementRate],
                    ["asymmPreOccupation", _asymmPreOccupation],
                    ["asymmPlaceRoadblocks", _asymmPlaceRoadblocks],
                    ["asymmIntelChance", _asymmIntelChance],

                    ["profileAmountAttack", 4],
                    ["profileAmountReserve", 1],
                    ["profileAmountDefend", 3],

                    ["objectives", []],

                    ["startForceStrength", [[], [], [], [], [], [], [], []]],
                    ["knownEnemies", []]
                ]
            ] call ALiVE_fnc_hashCreate;

            [_logic,"handler", _handler] call MAINCLASS;

            _logic setVariable ["startupComplete", false];

            // keep OPCOM_instances variable for backwards compatibility

            if (isnil "OPCOM_instances") then {
                OPCOM_instances = [];
            };

            OPCOM_instances pushback _handler;

            // create global intel chance datahandler

            if (isnil QMOD(MIL_OPCOM_INTELCHANCE)) then {
                ALiVE_MIL_OPCOM_INTELCHANCE = [] call ALiVE_fnc_hashCreate;
            };

            [ALiVE_MIL_OPCOM_INTELCHANCE,_opcomSide, _asymmIntelChance] call ALiVE_fnc_hashSet;

            publicVariable QMOD(MIL_OPCOM_INTELCHANCE);

            TRACE_1("After module init", _logic);

            TRACE_1("Starting process", _logic);

            [_logic,"start"] spawn MAINCLASS;

        };

    };

    case "start": {

        if (isServer) then {

            private _handler = [_logic,"handler"] call MAINCLASS;

            private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;
            private _persistent = [_handler,"persistent"] call ALiVE_fnc_hashGet;
            private _side = [_handler,"side"] call ALiVE_fnc_hashGet;
            private _factions = [_handler,"factions"] call ALiVE_fnc_hashGet;
            private _controlType = [_handler,"controlType"] call ALiVE_fnc_hashGet;

            // register with global registry

            if (isnil QMOD(OPCOMGlobalRegistry)) then {
                MOD(OPCOMGlobalRegistry) = [nil,"create"] call ALiVE_fnc_OPCOMGlobalRegistry;
                [MOD(OPCOMGlobalRegistry),"init"] call ALiVE_fnc_OPCOMGlobalRegistry;
            };

            private _opcomID = [MOD(OPCOMGlobalRegistry),"register", _logic] call ALiVE_fnc_OPCOMGlobalRegistry;

            [_handler,"opcomID", _opcomID] call ALiVE_fnc_hashSet;

            // wait for synced CQB modules to init
            // then store them

            private _cqb = [];
            {
                if (typeof _x == "ALiVE_mil_cqb") then {
                    waituntil {_x getVariable ["startupComplete", false]}; // cqb cannot fail init, starupComplete will always be set to true eventually

                    _cqb pushback _x;
                };
            } foreach (synchronizedObjects _logic);

            [_handler, "CQB", _cqb] call ALiVE_fnc_HashSet;

            switch (_controlType) do {

                case ("invasion") : {
                    [_handler, "sectionsAmountAttack", 4] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountReserve", 1] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountDefend", 3] call ALiVE_fnc_HashSet;
                };

                case ("occupation") : {
                    [_handler, "sectionsAmountAttack", 4] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountReserve", 2] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountDefend", 5] call ALiVE_fnc_HashSet;
                };

                case ("asymmetric") : {
                    [_handler, "sectionsAmountAttack", 1] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountReserve", 1] call ALiVE_fnc_HashSet;
                    [_handler, "sectionsAmountDefend", 1] call ALiVE_fnc_HashSet;

                    // init helper functions

                    call ALiVE_fnc_INS_helpers;

                    [[_handler, "CQB", []] call ALiVE_fnc_HashGet] call ALiVE_fnc_resetCQB;
                };

            };


            // ensure required modules are placed


            // ensure profile system module available

            if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
                ["No Virtual AI System module was found! Please use this module in your mission!"] call ALiVE_fnc_dumpR;
            };

            waituntil {[MOD(ProfileSystem),"startupComplete", false] call ALiVE_fnc_hashGet};

            // load Data from DB

            private _objectives = [];

            if (_persistent) then {
                _objectives append ([_handler,"loadObjectivesDB"] call ALiVE_fnc_OPCOM);

                ["ALiVE OPCOM loaded %1 objectives from DB!", count _objectives] call ALiVE_fnc_Dump;
            };

            // if no data was loaded from DB then get objectives
            // from synced placement and location modules

            if (count _objectives == 0) then {

                private _validModules = ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_mil_placement_custom"];

                for "_i" from 0 to (count synchronizedObjects _logic - 1) do {
                    private _mod = (synchronizedObjects _logic) select _i;

                    if ((typeof _mod) in _validModules) then {
                        waitUntil {_mod getVariable ["startupComplete", false]};

                        private _moduleObjectives = [_mod,"objectives", objNull, []] call ALiVE_fnc_OOsimpleOperation;
                        _objectives append _moduleObjectives;
                    } else {
                        if (_mod iskindof "LocationBase_F") then {

                            private _size = _mod getvariable ["size",150];
                            private _priority = _mod getvariable ["priority",200];
                            private _type = getText(configfile >> "CfgVehicles" >> (typeOf _mod) >> "displayName");

                            private _obj = [] call ALiVE_fnc_hashCreate;
                            [_obj,"center", getposATL _mod] call ALiVE_fnc_HashSet;
                            [_obj,"size", _size] call ALiVE_fnc_hashSet;
                            [_obj,"type", _type] call ALiVE_fnc_hashSet;
                            [_obj,"priority", _priority] call ALiVE_fnc_hashSet;
                            [_obj,"clusterID", ""] call ALiVE_fnc_hashSet;

                            _objectives pushback _obj;
                        };
                    };
                };

                switch (_controlType) do {

                    case ("occupation") : {
                        private _sortedObjectives = [_handler,"createobjectives", [_objectives,"strategic"]] call MAINCLASS;
                        _objectives = [_handler,"objectives", _sortedObjectives] call MAINCLASS;
                    };

                    case ("invasion") : {
                        private _sortedObjectives = [_handler,"createobjectives", [_objectives,"distance"]] call MAINCLASS;
                        _objectives = [_handler,"objectives", _sortedObjectives] call MAINCLASS;
                    };

                    case ("asymmetric") : {
                        private _sortedObjectives = [_handler,"createobjectives", [_objectives,"asymmetric"]] call MAINCLASS;
                        _objectives = [_handler,"objectives", _sortedObjectives] call MAINCLASS;
                    };

                };

                ["ALiVE OPCOM created %1 new objectives!", count _objectives] call ALiVE_fnc_Dump;

            };


            // validate module data


            if (count _objectives == 0) exitwith {
                ["There are no objectives for this OPCOM instance (%1)! Please assign Military or Civilian Placement Objectives!", _factions] call ALiVE_fnc_dumpR;
            };

            if ((count _objectives) > 80) then {
                ["There are %1 objectives for this OPCOM instance (%2)! Please lower the objective count for performance reasons, suggested is below 80!", count _objectives,_factions] call ALiVE_fnc_dumpR;
            };

            // ensure profiles are available to be controlled by this OPCOM

            private _profileCount = 0;

            {
                private _profileCountFaction = [MOD(profileHandler),"getProfilesByFaction", _x] call ALiVE_fnc_profileHandler;

                if !(count _profileCountFaction == 0) then {
                    _profileCount = _profileCount + (count _profileCountFaction);
                } else {
                    [
                        "There are are no groups available for OPCOM faction %1! Please ensure you have configured a Mil Placement or Mil Placement (Civ Obj) module for this faction (or faction units are synced to Virtual AI module). If so, please check groups are correctly configured for this faction.",
                        _x
                    ] call ALiVE_fnc_dumpR;
                };
            } foreach _factions;

            if (_profileCount == 0) exitwith {
                [
                    "There are are no groups available for OPCOM faction(s) %1! Please check you chose the correct faction(s), and that factions have groups defined in the ArmA 3 default categories infantry, motorized, mechanized, armored, artillery, air, sea!",
                    _factions
                ] call ALiVE_fnc_dumpR;
            };

            // ensure a selected faction isn't already being controlled by another commander

            private _error1 = "";
            private _error2 = "";
            private _exit = false;

            {
                waituntil {!isnil {[_x,"factions"] call ALiVE_fnc_HashGet}};

                private _opcomSide = [_x,"side"] call ALiVE_fnc_HashGet;
                private _opcomFactions = [_x,"factions"] call ALiVE_fnc_HashGet;

                {
                    private _faction = _x;

                    if (_faction in _factions) exitwith {
                        _error1 = _faction;
                        _error2 = _opcomSide;
                        _exit = true;
                    };
                } foreach _opcomFactions;

                if (_exit) exitwith {_exit = true};
            } foreach (OPCOM_instances - [_handler]);

            if (_exit) exitwith {
                ["Faction %1 is already used by another OPCOM (side: %2)! Please change the faction!", _error1, _error2] call ALiVE_fnc_dumpR;
            };

            // ensure all controlled factions belong to same side

            private _factionSide = getnumber (((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side");
            _exit = !(({_factionSide == (getNumber ((_x call ALiVE_fnc_configGetFactionClass) >> "side"))} count _factions)== count _factions);

            if (_exit) exitwith {
                ["There are factions belonging to different sides within this OPCOM %1! OPCOM may only control factions belong to the same side!", _opcomSide] call ALiVE_fnc_dumpR;
            };


            // validation complete


            if (_debug) then {
                ["OPCOM (%1) starts with %2 profiles and %3 objectives!", _factions, _profileCount, count _objectives] call ALiVE_fnc_dumpR;
            };

            // perform initial cluster occupation and troops analysis

            private _sidesFriendly = [_handler,"sidesFriendly"] call ALiVE_fnc_hashGet;
            private _sidesEnemy = [_handler,"sidesEnemy"] call ALiVE_fnc_hashGet;

            private _clusterOccupationAnalysis = [_logic,"analyzeclusteroccupation", [_sidesFriendly,_sidesEnemy]] call MAINCLASS;
            private _forces = [_logic,"scanTroops"] call MAINCLASS;

            private _count = [];

            {
                _count pushback (count _x);
            } foreach (_forces select 2);

            [_logic,"startForceStrength", _count] call ALiVE_fnc_HashSet;

            ["ALiVE OPCOM %1 Initial analysis done...", _side] call ALiVE_fnc_Dump;
            ["OPCOM and TACOM %1 starting with type %2...", _side, _controlType] call ALiVE_fnc_Dump;

            switch (_controlType) do {

                case ("occupation") : {
                    private _OPCOM = [_handler] call {
                        params ["_handler"];

                        private _OPCOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\opcom.fsm";
                        private _TACOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\tacom.fsm";

                        [_handler, "OPCOM_FSM", _OPCOM] call ALiVE_fnc_HashSet;
                        [_handler, "TACOM_FSM", _TACOM] call ALiVE_fnc_HashSet;
                    };
                };

                case ("invasion") : {
                    private _OPCOM = [_handler] call {
                        params ["_handler"];

                        private _OPCOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\opcom.fsm";
                        private _TACOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\tacom.fsm";

                        [_handler, "OPCOM_FSM", _OPCOM] call ALiVE_fnc_HashSet;
                        [_handler, "TACOM_FSM", _TACOM] call ALiVE_fnc_HashSet;
                    };
                };

                case ("asymmetric") : {
                    private _OPCOM = [_handler] call {
                        params ["_handler"];

                        private _OPCOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\insurgency.fsm";

                        [_handler, "OPCOM_FSM", _OPCOM] call ALiVE_fnc_HashSet;
                    };
                };

            };


            private _class = _logic getvariable ["mainclass", "ALiVE_fnc_OPCOM"];

            [_logic,"postStart"] call _class;
            [_logic,"cycle"] spawn _class;

        };

        // end loading screen

        if (isServer) then {

            _logic setVariable ["startupComplete", true, true];

            private _handler = [_logic,"handler"] call MAINCLASS;
            [_handler,"startupComplete", true] call ALiVE_fnc_HashSet;

        };

    };

    case "postStart": {



    };

    case "cycle": {



    };

    case "sortProfilesVisibleFromPosition": {

        // TAKES AN AGL FORMAT POSITION

        _args params ["_pos","_profiles",["_distance", 600]];

        _result = [];

        {
            private _profilePos = _x select 2 select 2;

            if (_profilePos distance _pos < _distance) then {
                private _profilePosRaised = [_profilePos select 0, _profilePos select 1, 2]; // raised to the height of a man

                if !(terrainIntersect [_pos, _profilePosRaised]) then {
                    _result pushback _x;
                };
            };
        } foreach _profiles;

    };

    case "getVisibleEnemies": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _sidesFriendly = [_handler,"sidesFriendly"] call ALiVE_fnc_hashGet;
        private _sidesEnemy = [_handler,"sidesEnemy"] call ALiVE_fnc_hashGet;

        private _friendlyProfiles = [];
        private _enemyProfiles = [];

        // TODO: make a function inside sys profile where we can pass in factions/sides
        // and get profiles separated by those filters - see getNearProfilesSorted
        // this will prevent us looping through the global profile array 5 times for two lists

        {
            _friendlyProfiles append ([MOD(profileHandler), "getProfilesBySide", _x] call ALiVE_fnc_profileHandler);
        } foreach _sidesFriendly;

        {
            _friendlyProfiles append ([MOD(profileHandler), "getProfilesBySide", _x] call ALiVE_fnc_profileHandler);
        } foreach _sidesEnemy;

        _result = [];

        {
            _result append ([_logic,"sortProfilesVisibleFromPosition", [_x select 2 select 2, _enemyProfiles]] call MAINCLASS);
        } foreach _friendlyProfiles;

    };

    case "sortProfilesInRange": {

        _args params ["_pos","_distance","_profiles",["_returnExcluded", false]];

        _result = [];

        {
            private _profilePos = _x select 2 select 2;

            if (!_returnExcluded) then {
                if (_profilePos distance _pos < _distance) then {
                    _result pushback _x;
                };
            } else {
                if (_profilePos distance _pos > _distance) then {
                    _result pushback _x;
                };
            };
        } foreach _profiles;

    };

    case "getObjectiveOccupation": {

        private _profiles = _args;

        _profiles params ["_friendlyProfiles","_enemyProfiles"];

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _objectives = [_handler,"objectives", []] call ALiVE_fnc_HashGet;

        // sort profiles

        _result = [];

        private _dist = 600;

        {
            private _objective = _x;

            private _objectiveID = [_objective,"objectiveID"] call ALiVE_fnc_HashGet;
            private _objectivePos = [_objective,"center"] call ALiVE_fnc_HashGet;
            private _objectiveSize = [_objective,"size"] call ALiVE_fnc_hashGet;

            private _inRangeFriendly = [_logic,"sortProfilesInRange", [_objectivePos,_objectiveSize max 500,_friendlyProfiles]] call MAINCLASS;
            private _inRangeEnemy = [_logic,"sortProfilesInRange", [_objectivePos,_objectiveSize max 500,_friendlyProfiles]] call MAINCLASS;

            _result pushback [_objective, [_inRangeFriendly,_inRangeEnemy]];
        } foreach _objectives;

    };

    case "getObjectiveStateByOccupation": {

        _args params ["_objective","_occupationData"];

        _occupationData params ["_friendlyProfiles","_enemyProfiles"];

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _countForAttack = [_handler,"profileAmountAttack"] call ALiVE_fnc_hashGet;
        private _countForDefend = [_handler,"profileAmountDefend"] call ALiVE_fnc_hashGet;
        private _countForReserve = [_handler,"profileAmountReserve"] call ALiVE_fnc_hashGet;

        // profileAmountforX
        // new states??

        // use nearby enemies and nearby friendlies to determine if defend/attack/idle need to be selected
        // if no nearby enemies (known) and no nearby friendlies, possible recon
        // always recon objectives closest to the frontline -- use objective priority to determine next recon target

        // remember to 'strike' new objectives after recon, then assault if possible

        // take into account all friendly troops, not just nearby ones (though subtract nearby ones when comparing)
        // how do we separate inf from spec ops inf?
        // spec ops and motorized should recon
        // attack groups should be balanced
        // good time to review OpcomOrder class

    };

    case "assignObjectiveStates": {

        private _occupationData = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        {
            _x params ["_objective","_occupationByHostility"];

            private _previousState = [_objective,"opcomState"] call ALiVE_fnc_hashGet;

            private _objectiveState = [_logic,"getObjectiveStateByOccupation", _occupationByHostility] call MAINCLASS;

            // set state
            // fire event if significant state change
            // etc fire event if objective goes from reserve to defend
            // if objective goes from idle to attack
            // if objective goes from idle to recon

            // all states?
            // idle -- just completely ignore for now
            // hold -- profiles are stationed at objective
            // attack -- an attack order is being prepared for the base
            // defend -- a defend order is being prepared for the base
            // recon -- a recon order is being prepared for the base
            // ...?
        } foreach _occupationData;

    };

















































































































    case "cleanupduplicatesections": {

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _objectives = [_handler,"objectives", []] call ALiVE_fnc_HashGet;
        private _size_reserve = [_handler,"sectionsamount_reserve", 1] call ALiVE_fnc_HashGet;
        private _factions = [_handler,"factions", []] call ALiVE_fnc_HashGet;

        private _profileIDs = [];
        {
            _profileIDs append ([MOD(profileHandler), "getProfilesByFaction", _x] call ALiVE_fnc_profileHandler);
        } foreach _factions;

        private _idlestates = ["unassigned","idle"];

        {
            private _objective = _x;
            private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;
            private _state = [_objective,"opcom_state",[]] call ALiVE_fnc_HashGet;

            private _waypointCount = 0;

            {
                private _profile = [MOD(ProfileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                if !(isnil "_profile") then {
                    _waypointCount = _waypointCount + (count (_profile select 2 select 16));
                } else {
                    [_handler,"resetorders", _x] call MAINCLASS;
                };
            } foreach _section;

            if (!(_state in _idlestates) && {count _section > 0} && {_waypointCount == 0}) then {
                {
                    [_handler,"resetorders", _x] call MAINCLASS;
                } foreach _section;

                [_handler,"resetObjective", ([_objective,"objectiveID"] call ALiVE_fnc_HashGet)] call MAINCLASS;
            };
        } foreach _objectives;

    };

    case "getNearestAvailableSection": {

        _args params ["_pos","_size",["_types", ["infantry"]]];

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _troops = [];

        {
            _troops append ([_handler,_x, []] call ALiVE_fnc_HashGet);
        } foreach _types;

        // ignore busy and reserved profiles

        private _busy = [];

        {
            _busy pushback (_x select 1);
        } foreach ([_handler,"pendingorders", []] call ALiVE_fnc_HashGet);

        {
            _busy append ([_x,"section", []] call ALiVE_fnc_HashGet);
        } foreach ([_handler,"objectives", []] call ALiVE_fnc_HashGet);

        private _reserved = [_handler,"ProfileIDsReserve", []] call ALiVE_fnc_HashGet;

        _busy = _busy - _reserved;

        if (_size >= 5) then {
            _troops = _troops - _reserved;
        } else {
            _troops = _troops - _busy;
            _troops = _troops - _reserved;
        };

        private _searchRadius = 2000;
        private _troopsUnsorted = [];
        private _opcomSide = [_handler,"side", "EAST"] call ALiVE_fnc_HashGet;

        while {
            private _nearProfiles = [_pos, _searchRadius, [_opcomSide, "entity"]] call ALiVE_fnc_getNearProfiles;
            _troopsUnsorted = [];

            {
                private _profileID = _x select 2 select 4;

                if (_profileID in _troops) then {
                    _troopsUnsorted pushBack _profileID;
                };
            } foreach _nearProfiles;

            ((count _troopsUnsorted <= _size) && {_searchRadius < 15000});
        } do {
            _searchRadius = _searchRadius + 2000;
        };

        // sort by distance

        private _sortCode = {
            if !(isnil "_x") then {
                private _p = nil;
                _p = [MOD(ProfileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

                if !(isnil "_p") then {
                    ([_p,"position", _Input0] call ALiVE_fnc_HashGet) distance _Input0;
                } else {
                    99999;
                };
            } else {
                99999;
            };
        };

        _troops = [_troopsUnsorted, [_pos], _sortCode, "ASCEND"] call ALiVE_fnc_SortBy;

        // collect section

        private _section = [];

        {
            if (count _section == _size) exitwith {};

            private _profile = [MOD(ProfileHandler),"getProfile", _x] call ALiVE_fnc_ProfileHandler;

            if (!isnil "_profile" && {!([_profile,"busy",false] call ALiVE_fnc_HashGet)}) then {
                _section pushback _x;
            };
        } foreach _troops;

        _result = _section;

    };

    case "entitiesNearSector": {

        _args params ["_pos","_side","_requireVisibility"];

        _pos set [2,0];

        private _ent = [];
        private _enemyProfiles = [];
        private _visibleEnemyProfiles = [];

        if (isnil "_pos") exitwith {_result = []};

        private _profiles = [_pos, 800, [_side,"entity"]] call ALiVE_fnc_getNearProfiles;

        {
            _enemyProfiles pushback [(_x select 2 select 4),(_x select 2 select 2)];
        } foreach _profiles;

        _result = _enemyProfiles;

        if (_requireVisibility) then {

            _pos = ATLtoASL _pos;
            _pos set [2,(_pos select 2) + 2];

            if ({(_x select 1) distance _pos < 600} count _enemyProfiles > 0) then {
                {
                    private _profileID = _x select 0;
                    private _profilePos = _x select 1;

                    if (_profilePos distance _pos < 600) then {
                        private _profilePosASL = [_profilePos select 0, _profilePos select 1, 0];
                        _profilePosASL = ATLtoASL _profilePosASL;
                        _profilePosASL set [2,(_profilePosASL select 2) + 2];

                        if ((_profilePos distance _pos < 500) && {!(terrainIntersectASL [_pos, _profilePosASL])}) then {
                            _visibleEnemyProfiles pushback _x;
                        };
                    };
                } foreach _enemyProfiles;
            };

            _result = _visibleEnemyProfiles;
        };

    };

    case "attackentity": {
        ASSERT_TRUE(typeName _args == "ARRAY",str _args);

        private ["_target","_reserved","_sides","_size","_type","_proIDs","_knownE","_attackedE","_pos","_profiles","_profileIDs","_profile","_section","_profileID","_i","_waypoints","_posAttacker","_dist","_rtb"];

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

           _section = [];
        _profileIDs = [];
        _dist = 1000;

        if (isnil "_profile") exitwith {_result = _section};

       {
            _proIDs = [ALiVE_profileHandler, "getProfilesBySide",_x] call ALiVE_fnc_profileHandler;
            _profileIDs = _profileIDs + _proIDs;
        } foreach _sides;

        _pos = [_profile,"position"] call ALiVE_fnc_HashGet;

        {
            if ((isnil "_x") || {_x select 0 == _target} || {!((_x select 0) in _profileIDs)}) then {
                _knownE set [_foreachIndex,"x"];
                _knownE = _knownE - ["x"];

                [_logic,"knownentities",_knownE] call ALiVE_fnc_HashSet;
            };
        } foreach _knownE;

        {
            if ((isnil "_x") || {time - (_x select 3) > 90} || {!((_x select 0) in _profileIDs)}) then {
                _attackedE set [_foreachIndex,"x"];
                _attackedE = _attackedE - ["x"];

                [_logic,"attackedentities",_attackedE] call ALiVE_fnc_HashSet;
            };
        } foreach _attackedE;

        if ({!(isnil "_x") && {_x select 0 == _target}} count _attackedE < 1) then {
            switch (_type) do {
                case ("infantry") : {
                    _profiles = [_logic,"infantry"] call ALiVE_fnc_HashGet;
                    _dist = 1000;
                };
                case ("mechandized") : {
                    _profiles = [_logic,"mechandized"] call ALiVE_fnc_HashGet;
                };
                case ("armored") : {
                    _profiles = [_logic,"armored"] call ALiVE_fnc_HashGet;
                    _dist = 3000;
                };
                case ("artillery") : {
                    _profiles = [_logic,"artillery"] call ALiVE_fnc_HashGet;
                    _dist = 5000;
                };
                case ("AAA") : {
                    _profiles = [_logic,"AAA"] call ALiVE_fnc_HashGet;
                    _dist = 5000;
                };
                case ("air") : {
                    _profiles = [_logic,"air"] call ALiVE_fnc_HashGet;
                    _dist = 15000;
                    _rtb = true;
                };
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

                            _waypoints = [_profile,"waypoints"] call ALiVE_fnc_hashGet;

                            if (({!(isnil "_x") && {_profileID in (_x select 2)}} count _attackedE) < 1 && {count _waypoints <= 2}) then {
                                if (!isnil "_rtb") then {
                                    _profileWaypoint = [_posAttacker, 50] call ALiVE_fnc_createProfileWaypoint;
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
                                                _vehicleProfiles = [_profile,'vehiclesInCommandOf',[]] call ALiVE_fnc_hashGet;

                                                {
                                                    _vehicleProfile = [ALiVE_ProfileHandler,'getProfile',_x] call ALiVE_fnc_ProfileHandler;
                                                    [_vehicleProfile,'engineOn',false] call ALiVE_fnc_HashSet;
                                                } foreach _vehicleProfiles;
                                            };
                                        ",str(_profileID)]
                                    ]] call ALiVE_fnc_hashSet;

                                    [_profile,"insertWaypoint",_profileWaypoint] call ALiVE_fnc_profileEntity;
                                };

                                _profileWaypoint = [_pos, 50, "MOVE", "FULL", 50, [], "LINE"] call ALiVE_fnc_createProfileWaypoint;
                                [_profile,"insertWaypoint",_profileWaypoint] call ALiVE_fnc_profileEntity;

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
            };
        } else {
            //player sidechat format["Target %1 already beeing attacked, dead or not existing for any reason...!",_target];
        };

        _result = _section;
    };

    case "setorders": {

        _args params ["_pos","_profileID","_objectiveID","_orders"];

        private _TACOM_FSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_HashGet;
        private _objectives = [_logic,"objectives", []] call ALiVE_fnc_HashGet;

        {
            private _id = [_x,"objectiveID", ""] call ALiVE_fnc_HashGet;
            private _section = [_x,"section", []] call ALiVE_fnc_HashGet;

            if ((_profileID in _section) && {!(_objectiveID == _id)}) then {
                [_logic,"resetorders",_profileID] call ALiVE_fnc_OPCOM;
            };
        } foreach _objectives;

        private _pendingOrders = [_logic,"pendingorders", []] call ALiVE_fnc_HashGet;
        private _pendingOrdersTmp = _pendingOrders;

        if (({(_x select 1) == _profileID} count _pendingOrdersTmp) > 0) then {
            {
                if ((_x select 1) == _profileID) then {_pendingOrdersTmp set [_foreachIndex,"x"]};
            } foreach _pendingOrdersTmp;

            _pendingOrders = _pendingOrdersTmp - ["x"];
        };

        private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;

        [_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;
        [_profile, "clearActiveCommands"] call ALiVE_fnc_profileEntity;

        private _args = ["_TACOM_DATA", ["completed", [_ProfileID,_objectiveID,_orders]]];
        private _statements = format["[] spawn {sleep (random 10); %1 setfsmvariable %2}", _TACOM_FSM, _args];

        private _profileWaypoint = [_pos, 15] call ALiVE_fnc_createProfileWaypoint;
        [_profileWaypoint,"statements", ["true",_statements]] call ALiVE_fnc_hashSet;
        [_profileWaypoint,"behaviour", "AWARE"] call ALiVE_fnc_hashSet;
        [_profileWaypoint,"speed", "NORMAL"] call ALiVE_fnc_hashSet;

        [_profile, "addWaypoint", _profileWaypoint] call ALiVE_fnc_profileEntity;

        private _ordersFull = [_pos, _ProfileID, _objectiveID, time];
        [_logic,"pendingorders", _pendingOrders + [_ordersFull]] call ALiVE_fnc_HashSet;

        _result = _profileWaypoint;

    };

    case "synchronizeorders": {

        private _ProfileIDInput = _args;
        private _profiles = ([ALiVE_profileHandler, "getProfiles","entity"] call ALiVE_fnc_profileHandler) select 1;
        private _ordersPending = ([_logic,"pendingorders",[]] call ALiVE_fnc_HashGet);
        private _synchronized = false;

        for "_i" from 0 to (count _ordersPending - 1) do {
            if (_i >= (count _ordersPending)) exitwith {};

            _item = _ordersPending select _i;

            if (_item isEqualType []) then {
                _item params ["_pos","_profileID","_objectiveID","_time"];

                private _dead = !(_ProfileID in _profiles);
                private _timeout = (time - _time) > 3600;

                if (_dead || {_timeout} || {_ProfileID == _ProfileIDInput}) then {
                    _ordersPending set [_i,"x"];
                    _ordersPending = _ordersPending - ["x"];

                    [_logic,"pendingorders",_ordersPending] call ALiVE_fnc_HashSet;
                    if (({_objectiveID == (_x select 2)} count (_ordersPending)) == 0) then {_synchronized = true};
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

            if !(isnil "_section") then {
                if (_profileID in _section) then {
                    _section = _section - [_profileID];
                    [_x,"section",_section] call ALiVE_fnc_HashSet;
                };

                if ((count _section) == 0) then {
                    [_logic,"resetObjective",([_x,"objectiveID"] call ALiVE_fnc_HashGet)] call ALiVE_fnc_OPCOM;
                };
            };
        } foreach _objectives;

        _profile = [ALiVE_profileHandler, "getProfile", _profileID] call ALiVE_fnc_profileHandler;
        if !(isnil "_profile") then {
           _active = [_profile, "active", false] call ALiVE_fnc_HashGet;
           _activeCommands = [_profile, "activeCommands", []] call ALiVE_fnc_HashGet;

           if (!_active && {count _activeCommands == 0}) then {
                [_profile, "clearActiveCommands"] call ALiVE_fnc_profileEntity;
                [_profile, "setActiveCommand", ["ALiVE_fnc_ambientMovement","spawn",[200,"SAFE",[0,0,0]]]] call ALiVE_fnc_profileEntity;
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
            } foreach ([_logic, "objectives"] call ALiVE_fnc_HashGet);
        } else {
            {
                private ["_exit"];

                _exit = false;

                {_o = _x; if (([_o,"objectiveID"] call ALiVE_fnc_hashGet) == _id) exitwith {_objective = _o; _exit = true}} foreach ([_x, "objectives"] call ALiVE_fnc_HashGet);

                if (_exit) exitwith {};

            } foreach OPCOM_INSTANCES;
        };

        _result = _objective;
    };

    case "sortObjectives": {
        if(isnil "_args") then {
            _args = [_logic,"objectives"] call ALiVE_fnc_hashGet;
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
                                _final = ([_Input0, "position"] call ALiVE_fnc_HashGet) distance (_x select 2 select 1);

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
                                _value4 = ((([_Input0, "position"] call ALiVE_fnc_HashGet) distance (_x select 2 select 1))/10);

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

                            _objectivesFilteredCiv = [_objectivesCiv,[_logic],{(([_Input0, "position"] call ALiVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "CIV"}] call ALiVE_fnc_SortBy;
                            _objectivesFilteredMil = [_objectivesMil,[_logic],{(([_Input0, "position"] call ALiVE_fnc_HashGet) distance (_x select 2 select 1))*(1-(random 0.20))},"ASCEND",{(_x select 2 select 3) == "MIL"}] call ALiVE_fnc_SortBy;

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
                                    _sector = [ALiVE_sectorGrid, "positionToSector", _center] call ALiVE_fnc_sectorGrid;
                                    _sectorData = [_sector,"data",["",[],[],nil]] call ALiVE_fnc_hashGet;
                                    _entitiesBySide = [_sectorData, "entitiesBySide",["",[],[],nil]] call ALiVE_fnc_hashGet;
                                    _agents = [];

                                    // Get amb civilian clusterdata
                                    if ("clustersCiv" in (_sectorData select 1)) then {

                                        if (isnil "ALiVE_agentHandler") exitwith {};

                                        _civClusters = [_sectorData,"clustersCiv"] call ALiVE_fnc_hashGet;
                                        _settlementClusters = [_civClusters,"settlement",[]] call ALiVE_fnc_hashGet;
                                        _agentClusterData = [ALiVE_agentHandler,"agentsByCluster",["",[],[],nil]] call ALiVE_fnc_hashGet;

                                        if (count _settlementClusters <= 0) exitwith {};

                                        _settlementClusters = [_settlementClusters,[_center],{_Input0 distance (_x select 0)},"ASCEND"] call ALiVE_fnc_SortBy;
                                        _agents =  ([_agentClusterData,_settlementClusters select 0 select 1,["",[],[],nil]] call ALiVE_fnc_HashGet) select 1;

                                        [_objective,"agents",_agents] call ALiVE_fnc_HashSet;
                                    };

                                    private ["_building","_road"];

                                    _buildings = [_center,_size] call ALiVE_fnc_getEnterableHouses;
                                    _roads = _center nearRoads _size;
                                    _faction = selectRandom _factions;
                                    _dominantFaction = [_center, _size] call ALiVE_fnc_getDominantFaction;

                                    if (isnil "_dominantFaction" || {!(([[_dominantFaction call ALiVE_fnc_factionSide] call ALiVE_fnc_SideObjectToNumber] call ALiVE_fnc_SideNumberToText) in _sidesEnemy)}) then {
                                        if (count (_buildings + _roads) > 0) then {

                                            if (count _buildings > 0) then {
                                                _type = selectRandom ["HQ","depot","factory"];
                                                _target = selectRandom _buildings;
                                            } else {
                                                if (count _roads > 0) then {
                                                    _type = selectRandom ["ied","roadblocks"];
                                                    if !(_roadblocks) then {
                                                        _type = "ied";
                                                    };
                                                    _target = selectRandom _roads;
                                                };
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

                    [format[MTEMPLATE, _id], _center,"ICON", [0.5,0.5],_color,format["%1 #%2",_side,_foreachIndex],"mil_dot","FDiagonal",0,0.5] call ALiVE_fnc_createMarkerGlobal;
                } foreach _objectives;
            };

            _args = _objectives;
        };
        _result = _args;
    };

    case "resetObjective": {
        if(isnil "_args") then {
                _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
        } else {
            ASSERT_TRUE(typeName _args == "STRING",str _args);
            private ["_objective"];

            _objective = [_logic,"getobjectivebyid",_args] call ALiVE_fnc_OPCOM;
            _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

            [_objective,"tacom_state","none"] call ALiVE_fnc_HashSet;
            [_objective,"opcom_state","unassigned"] call ALiVE_fnc_HashSet;
            [_objective,"danger",-1] call ALiVE_fnc_HashSet;
            [_objective,"section",[]] call ALiVE_fnc_HashSet;
            [_objective,"opcom_orders","none"] call ALiVE_fnc_HashSet;

            // debug ---------------------------------------
            if (_debug) then {_args setMarkerColorLocal "ColorWhite"};
            // debug ---------------------------------------

            _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
        };
        _result = _args;
    };

    case "initObjective": {
        if(isnil "_args") then {
                _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
        } else {
            ASSERT_TRUE(typeName _args == "STRING",str _args);
            private ["_objective"];

            _id = _args;

            _factions = [_logic,"factions",["OPF_F"]] call ALiVE_fnc_HashGet;
            _sidesEnemy = [_logic,"sidesenemy",["WEST"]] call ALiVE_fnc_HashGet;
            _sidesFriendly = [_logic,"sidesfriendly",["EAST"]] call ALiVE_fnc_HashGet;
            _CQB = [_logic,"CQB",[]] call ALiVE_fnc_HashGet;
            _debug = [_logic,"debug",false] call ALiVE_fnc_HashGet;

            _objective = [_logic,"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
            _center = [_objective,"center"] call ALiVE_fnc_HashGet;
            _size = [_objective,"size"] call ALiVE_fnc_HashGet;

            //Convert CQB modules
            _CQB = +_CQB; {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

            // Get sector data
            _sector = [ALiVE_sectorGrid, "positionToSector", _center] call ALiVE_fnc_sectorGrid;
            _sectorData = [_sector,"data",["",[],[],nil]] call ALiVE_fnc_hashGet;
            _entitiesBySide = [_sectorData, "entitiesBySide",["",[],[],nil]] call ALiVE_fnc_hashGet;
            _agents = [];

            // Get amb civilian clusterdata
            if ("clustersCiv" in (_sectorData select 1)) then {

                if (isnil "ALiVE_agentHandler") exitwith {};

                _civClusters = [_sectorData,"clustersCiv"] call ALiVE_fnc_hashGet;
                _settlementClusters = [_civClusters,"settlement",[]] call ALiVE_fnc_hashGet;
                _agentClusterData = [ALiVE_agentHandler,"agentsByCluster",["",[],[],nil]] call ALiVE_fnc_hashGet;

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

            if (ALiVE _factory) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"factory",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_factory};
            if (ALiVE _HQ) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"HQ",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_recruit};
            if (ALiVE _depot) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"depot",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_depot};
            if (ALiVE _roadblocks) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"roadblocks",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents,+_CQB] spawn ALiVE_fnc_INS_roadblocks};
            if (ALiVE _ied) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ied",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ied};
            if (ALiVE _ambush) then {[time,_center,_id,_size,selectRandom _factions,[_objective,"ambush",[]] call ALiVE_fnc_HashGet,_sidesEnemy,_agents] spawn ALiVE_fnc_INS_ambush};

            if (ALiVE _sabotage) then {
                private ["_buildings","_target"];

                //Selecting tallest enterable building as target...
                if (isnil "_buildings" || {count _buildings > 0}) then {
                    if (isnil "_buildings") then {_buildings = [_center, _size] call ALiVE_fnc_getEnterableHouses};

                    _buildings = [_buildings,[],{

                        _maxHeight = -999;
                        if (ALiVE _x && {!((typeOf _x) isKindOf "House_Small_F")}) then {

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

            if (ALiVE _suicide) then {
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

            //Set default data
            //[_objective,"opcom_orders","none"] call ALiVE_fnc_HashSet;
            //[_objective,"tacom_state","none"] call ALiVE_fnc_HashSet;
            //[_objective,"opcom_state","unassigned"] call ALiVE_fnc_HashSet;
            //[_objective,"section",[]] call ALiVE_fnc_HashSet;

            // debug ---------------------------------------
            if (_debug) then {_args setMarkerColorLocal "ColorWhite"};
            // debug ---------------------------------------

            _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
        };
        _result = _args;
    };

    case "removeObjective": {
        if(isnil "_args") then {
                _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
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
        [_objective,"section",_section] call ALiVE_fnc_HashSet;

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

                    if (isnil "_object" || {!ALiVE _object}) then {
                        _objects = (_args select 0) nearEntities [_args select 1,1];

                        if (count _objects > 0) then {_object = _objects select 0};
                    };
                };
            } else {
                if(typeName _args == "OBJECT") then {
                    if (ALiVE _args) then {_object = [[getposATL _args select 0,getposATL _args select 1],typeOf _args]} else {_object = []};
                };
            };
            _result = _object;
        };
    };

    case "saveData": {
        private ["_objectives","_exportObjectives","_objective","_objectiveID","_exportObjective","_objectivesGlobal","_save","_messages","_message","_saveResult"];

        if (isDedicated) then {

            if (!isNil "ALiVE_sys_data" && {!ALiVE_sys_data_DISABLED}) then {

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
                        if ([_x,"persistent",false] call ALiVE_fnc_HashGet) then {
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
                    ["ALiVE OPCOM - SAVE DATA - SYS DATA EXISTS"] call ALiVE_fnc_dump;
                };

                if (isNil QGVAR(DATAHANDLER)) then {

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - CREATE DATA HANDLER!"] call ALiVE_fnc_dump;
                    };

                    GVAR(DATAHANDLER) = [nil, "create"] call ALiVE_fnc_Data;
                    [GVAR(DATAHANDLER),"storeType",true] call ALiVE_fnc_Data;
                   };

                _exportObjectives = [] call ALiVE_fnc_hashCreate;

                {
                    _objective = _x;
                    _objectiveID = [_objective,"objectiveID",""] call ALiVE_fnc_HashGet;

                    _exportObjective = [_objective, [], []] call ALiVE_fnc_hashCopy;

                    if([_exportObjective, "_rev"] call ALiVE_fnc_hashGet == "") then {
                        [_exportObjective, "_rev"] call ALiVE_fnc_hashRem;
                    };

                    {[_exportObjective, _x] call ALiVE_fnc_hashRem} foreach _blacklist;

                    [_exportObjectives, _objectiveID, _exportObjective] call ALiVE_fnc_hashSet;

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE OPCOM - EXPORT READY OBJECTIVE:"] call ALiVE_fnc_dump;
                        _exportObjective call ALiVE_fnc_inspectHash;
                    };


                } forEach (GVAR(OBJECTIVES_DB_SAVE) select 0);


                _message = format["ALiVE OPCOM - Preparing to save %1 objectives..",count(_exportObjectives select 1)];
                _messages = _result select 1;
                _messages pushback _message;


                _async = false; // Wait for response from server
                _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
                _missionName = format["%1_%2", ALiVE_sys_data_GROUP_ID, _missionName]; // must include group_id to ensure mission reference is unique across groups

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALiVE_fnc_Dump;
                };

                _saveResult = [GVAR(DATAHANDLER), "bulkSave", ["mil_opcom", _exportObjectives, _missionName, _async]] call ALiVE_fnc_Data;
                _result set [0,_saveResult];

                _message = format["ALiVE OPCOM - Save Result: %1",_saveResult];
                _messages = _result select 1;
                _messages pushback _message;

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - SAVE DATA RESULT (maybe truncated in RPT, dont worry): %1",_saveResult] call ALiVE_fnc_dump;
                    ["ALiVE OPCOM - SAVE DATA SAVING COMPLETE!"] call ALiVE_fnc_Dump;
                };
            };
        };
    };

    case "loadData": {
        private ["_stopped","_result"];

        if !(isDedicated && {!(isNil "ALiVE_sys_data")} && {!(ALiVE_sys_data_DISABLED)}) exitwith {["ALiVE LOAD OPCOM DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE OR NOT DEDICATED!"] call ALiVE_fnc_dumpR};

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

                    _OPCOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\opcom.fsm";
                    _TACOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\tacom.fsm";

                    [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                    [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                };
            };
            case ("invasion") : {
                _OPCOM = [_logic] call {
                    _handler = _this select 0;

                    _OPCOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\opcom.fsm";
                    _TACOM = [_handler] execFSM "\x\ALiVE\addons\mil_opcom\tacom.fsm";

                    [_handler, "OPCOM_FSM",_OPCOM] call ALiVE_fnc_HashSet;
                    [_handler, "TACOM_FSM",_TACOM] call ALiVE_fnc_HashSet;
                };
            };
            case ("asymmetric") : {
                _OPCOM = [_logic] execFSM "\x\ALiVE\addons\mil_opcom\insurgency.fsm";

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

        if (isDedicated) then {

            if (!isNil "ALiVE_sys_data" && {!ALiVE_sys_data_DISABLED}) then {
                private ["_importProfiles","_async","_missionName","_result","_stopped","_i"];

                //defaults
                _async = false;
                _missionName = [missionName, "%20","-"] call CBA_fnc_replace;
                _missionName = format["%1_%2", ALiVE_sys_data_GROUP_ID, _missionName];

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
                            ["ALiVE OPCOM - CREATE DATA HANDLER!"] call ALiVE_fnc_dump;
                        };

                        GVAR(DATAHANDLER) = [nil, "create"] call ALiVE_fnc_Data;
                        [GVAR(DATAHANDLER),"storeType",true] call ALiVE_fnc_Data;
                   };

                    [true] call ALiVE_fnc_timer;
                    GVAR(OBJECTIVES_DB_LOAD) = [[GVAR(DATAHANDLER), "bulkLoad", ["mil_opcom", _missionName, _async]] call ALiVE_fnc_Data,time];
                    [] call ALiVE_fnc_timer;

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

                            [_x, "_id"] call ALiVE_fnc_hashRem;
                            [_x, "_rev"] call ALiVE_fnc_hashRem;

                            [_x,"_rev",_rev] call ALiVE_fnc_HashSet;

                            _objectives pushback _x;
                        };
                    } foreach (_result select 2);

                    private ["_keys"];

                    _keys = [
                                "objectiveID","center","size","type","priority","opcom_state","clusterID","opcomID",
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

                        _target = [] call ALiVE_fnc_hashCreate;

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
                        ["ALiVE OPCOM - LOAD DATA LOADING FROM DB FAILED!"] call ALiVE_fnc_dump;
                    };
                };
            } else {
                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE OPCOM - LOAD DATA FROM DB NOT POSSIBLE! NO SYS DATA MODULE AVAILABLE!"] call ALiVE_fnc_dumpR;
                };
            };
        };

        _result = _objectives;
    };

    case "objectives": {
            if(isnil "_args") then {
                    _args = [_logic,"objectives",[]] call ALiVE_fnc_hashGet;
            } else {
                    [_logic,"objectives",_args] call ALiVE_fnc_hashSet;
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
                _args = [_logic,"objectives"] call ALiVE_fnc_hashGet;
            } else {
                ASSERT_TRUE(typeName _args == "ARRAY",str _args);
                ASSERT_TRUE(count _args > 2,str _args);

                private ["_debug","_params","_side","_id","_pos","_size","_color","_type","_priority","_opcom_state","_clusterID","_target","_objectives","_opcomID"];

                _debug = [_logic, "debug",false] call ALiVE_fnc_HashGet;
                _side = [_logic, "side","EAST"] call ALiVE_fnc_HashGet;

                _id = [_args, 0, "", [""]] call BIS_fnc_param;
                _pos = [_args, 1, [0,0,0], [[]]] call BIS_fnc_param;
                _size = [_args, 2, 50, [-1]] call BIS_fnc_param;
                _type = [_args, 3, "unknown", [""]] call BIS_fnc_param;
                _priority = [_args, 4, 100, [-1]] call BIS_fnc_param;
                _opcom_state = [_args, 5, "unassigned", [""]] call BIS_fnc_param;
                _clusterID = [_args, 6, "none", [""]] call BIS_fnc_param;
                _opcomID = [_args, 7, [_logic,"opcomID",""] call ALiVE_fnc_HashGet, [""]] call BIS_fnc_param;

                _target = [] call ALiVE_fnc_hashCreate;
                [_target, "objectiveID",_id] call ALiVE_fnc_HashSet;
                [_target, "center",_pos] call ALiVE_fnc_HashSet;
                [_target, "size",_size] call ALiVE_fnc_HashSet;
                [_target, "type",_type] call ALiVE_fnc_HashSet;
                [_target, "priority",_priority] call ALiVE_fnc_HashSet;
                [_target, "opcom_state",_opcom_state] call ALiVE_fnc_HashSet;
                [_target, "clusterID",_clusterID] call ALiVE_fnc_HashSet;
                [_target, "opcomID",_opcomID] call ALiVE_fnc_HashSet;
                [_target,"_rev",""] call ALiVE_fnc_hashSet;

                if  (_debug) then {
                    if !((format[MTEMPLATE, _id]) call ALiVE_fnc_markerExists) then {

                         _color = switch (_side) do {
                            case "EAST" : {"COLORRED"};
                            case "WEST" : {"COLORBLUE"};
                            case "GUER" : {"COLORGREEN"};
                            default {"COLORYELLOW"};
                        };

                        [format[MTEMPLATE, _id], _pos,"ICON", [0.5,0.5],_color,format["%1 #%2",_side,_id],"mil_dot","FDiagonal",0,0.5] call ALiVE_fnc_createMarkerGlobal;
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
                    _args = [_logic,"objectives"] call ALiVE_fnc_hashGet;
            } else {

                private ["_objectives","_opcomID","_startpos","_side","_type","_typeOp","_pos","_height","_debug","_clusterID","_target","_asym_occupation","_factions"];

                //Collect objectives from SEP and order by distance from OPCOM module (for now)
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
                //_OID = (count (missionNameSpace getvariable ["OPCOM_instances",[]]))-1;
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

        _units = [_profile,"units"] call ALiVE_fnc_hashGet;
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

        [_profileUnit, "clearWaypoints"] call ALiVE_fnc_profileEntity;
        {[_profileUnit, "addWaypoint", _x] call ALiVE_fnc_profileEntity} foreach ([_profile,"waypoints",[]] call ALiVE_fnc_HashGet);

        {{titleText ['Inserting...', 'BLACK IN',2]} remoteExec ["BIS_fnc_Spawn",owner _x]; sleep 0.2} foreach _players;
    };

    case "analyzeClusterOccupation": {

        private _sides = _args;

        _sides params ["_sidesFriendly","_sidesEnemy"];

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _objectives = [_handler,"objectives", []] call ALiVE_fnc_HashGet;
        private _controltype = [_handler, "controltype", "invasion"] call ALiVE_fnc_HashGet;

        private _objective = [];

        for "_i" from 0 to (count _sides - 1) do {
            private _side = _sides select _i;
            private _nearForces = [];

            {
                for "_i" from 0 to (count _objectives - 1 ) do {
                    private _objective = _objectives select _i;

                    private _pos = [_objective,"center"] call ALiVE_fnc_HashGet;
                    private _size = [_objective,"size"] call ALiVE_fnc_hashGet;
                    private _id = [_objective,"objectiveID"] call ALiVE_fnc_HashGet;
                    private _section = [_objective,"section",[]] call ALiVE_fnc_HashGet;

                    private _entities = [];

                    private _nearProfiles = [_pos, (_size max 500), [_x,"entity"]] call ALiVE_fnc_getNearProfiles;

                    {
                        _entities pushback (_x select 2 select 4);  // [_x,"profileID"] call ALiVE_fnc_hashGet;
                    } foreach _nearProfiles;

                    if !(_entities isEqualTo []) then {
                        _nearForces pushback [_id,_entities];
                    };
                };
            } foreach _side;

            _resultTmp pushback _nearForces;
        };

        _targetsTaken1 =  _resultTmp select 0;
        _targetsTaken2 =  _resultTmp select 1;

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
        [_handler,"clusteroccupation",_result] call ALiVE_fnc_HashSet;

        _targetsTaken = _result select 0;
        _targetsAttacked = _result select 1;
        _targetsTakenEnemy = _result select 2;
        _targetsAttackedEnemy = _result select 3;

        private "_prios";

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

            default {
                _prios = [
                    [_targetsTaken,"reserve"],
                    [_targetsTakenEnemy,"attack"],
                    [_targetsAttackedEnemy,"defend"]
                ];
            };

        };

        {
            [_handler,"setstatebyclusteroccupation",[(_x select 0),(_x select 1)]] call MAINCLASS;
        } foreach _prios;

        //diag_log format ["%5: Taken %1 | Attacked %2 // %6: Taken %3 | Attacked %4",_targetsTaken, _targetsAttackedEnemy, _targetsTakenEnemy, _targetsAttackedEnemy,_sidesF,_sidesE];
        //player sidechat format ["%5: Taken %1 | Attacked %2 // %6: Taken %3 | Attacked %4",_targetsTaken, _targetsAttackedEnemy, _targetsTakenEnemy, _targetsAttackedEnemy,_sidesF,_sidesE];
    };

    case "scanEnemiesNearPosition": {

        private _pos = _args;

        private _handler = [_logic,"handler"] call MAINCLASS;

        private _sidesEnemy = [_handler,"sidesEnemy", ["EAST"]] call ALiVE_fnc_HashGet;
        private _knownEntities = [_handler,"knownEntities", []] call ALiVE_fnc_HashGet;
        private _knownEntities = _knownEntities - ["x"]; // TODO: probably doesnt need to be here

        private _visibleEnemies = [];

        {
            private _nearVisibleEntities = [_logic,"entitiesNearSector", [_pos,_x,true]] call MAINCLASS;
            _visibleEnemies append _nearVisibleEntities;
        } foreach _sidesEnemy;

        if !(_visibleEnemies isEqualTo []) then {
            {
                private _profileID = _x select 0;

                if !(
                    {(_x select 0) == _profileID} count _knownEntities > 0
                ) then {
                    _knownEntities pushback _x;
                };
            } foreach _visibleEnemies;

            [_logic,"knownEntities", _knownEntities] call ALiVE_fnc_HashSet;
        };

        _result = _knownEntities

    };

    case "scanTroops" : {

        private _handler = [_logic,"handler"] call MAINCLASS;
        private _debug = [_handler,"debug"] call ALiVE_fnc_hashGet;

        private _startTime = time;

        private _factions = [_handler,"factions"] call ALiVE_fnc_HashGet;

        private _profileIDs = [];
        {
            _profileIDs append ([MOD(profileHandler), "getProfilesByFaction", _x] call ALiVE_fnc_profileHandler);
        } foreach _factions;

        private _inf = [];
        private _mot = [];
        private _AAA = [];
        private _arm = [];
        private _air = [];
        private _sea = [];
        private _mech = [];
        private _arty = [];

        if (count _profileIDs == 0) exitwith {
            [_handler,"currentForceStrength", _count] call ALiVE_fnc_HashSet;

            _result = [_inf,_mot,_mech,_arm,_air,_sea,_arty,_AAA];
        };

        {
            private _profile = [MOD(profileHandler), "getProfile", _x] call ALiVE_fnc_profileHandler;

            if !(isnil "_profile") then {

                private _type = [_profile,"type"] call ALiVE_fnc_hashGet;

                switch (tolower _type) do {

                    case ("vehicle") : {

                        private _assignments = [_profile,"entitiesInCommandOf", []] call ALiVE_fnc_hashGet;

                        if (count _assignments > 0) then {

                            // dont collect vehicles with player profiles assigned

                            if ({(_x getvariable ["profileID",""]) in _assignments} count allPlayers > 0) exitwith {};

                            switch (tolower _objectType) do {
                                case "car": {
                                    {_mot pushbackunique _x} foreach _assignments;
                                };
                                case "tank": {
                                    private _vehicleClass = [_profile,"vehicleClass", ""] call ALiVE_fnc_hashGet;

                                    if ([_vehicleClass] call ALiVE_fnc_isAA || {[_vehicleClass] call ALiVE_fnc_isArtillery}) then {
                                        if ([_vehicleClass] call ALiVE_fnc_isArtillery) then {_arty pushbackunique _x} foreach _assignments};
                                        if ([_vehicleClass] call ALiVE_fnc_isAA) then {_AAA pushbackunique _x} foreach _assignments};
                                    } else {
                                        {_arm pushbackunique _x} foreach _assignments;
                                    };
                                };
                                case "armored": {
                                    {_mech pushbackunique _x} foreach _assignments;
                                };
                                case "truck": {
                                    {_mot pushbackunique _x} foreach _assignments;
                                };
                                case "ship": {
                                    {_sea pushbackunique _x} foreach _assignments;
                                };
                                case "helicopter": {
                                    {_air pushbackunique _x} foreach _assignments;
                                };
                                case "plane": {
                                    {_air pushbackunique _x} foreach _assignments;
                                };
                            };
                        };
                    };

                    case ("entity") : {

                        private _assignments = ([_profile,"vehicleAssignments", ["",[],[],nil]] call ALiVE_fnc_hashGet) select 1;

                        if ((count _assignments == 0) && {!([_profile,"isPlayer", false] call ALiVE_fnc_hashGet)}) then {
                            _inf pushback _x;
                        };
                    };
                };
            };
        } foreach _profileIDs;

        private _count = [count _inf, count _mot, count _mech, count _arm, count _arty, count _AAA, count _air, count _sea];
        [_handler,"currentForceStrength", _count] call ALiVE_fnc_HashSet;

        if (_debug) then {
            ["ALiVE OPCOM - Scantroops: time taken: %1 seconds", time - _duration] call ALiVE_fnc_DumpH;
        };

        _result = [
            [
                ["infantry", _inf],
                ["motorized", _mot],
                ["mechanized", _mech],
                ["armored", _arm],
                ["artillery", _arty],
                ["aaa", _AAA],
                ["air", _air],
                ["sea", _sea]
            ]
        ] call ALiVE_fnc_hashCreate;

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

                _pos = [_target,"center"] call ALiVE_fnc_HashGet;
                _stateX = [_target,"opcom_state"] call ALiVE_fnc_HashGet;
                if !(_stateX in _idleStates) then {
                    //player sidechat format["output: state %1 | operation: %2",_stateX,_operation];
                    [_target,"opcom_state",_operation] call ALiVE_fnc_HashSet;
                };
            } foreach _objectives;

            if !(isnil "_target") then {_result = [_target,_operation]} else {_result = nil};
    };

    case "selectordersbystate": {
            private ["_target","_state","_DATA_TMP","_ord","_module"];
            ASSERT_TRUE(typeName _args == "STRING",str _args);

            _state = _args;
            _module = [_logic,"module"] call ALiVE_fnc_HashGet;

            _DATA_TMP = nil;
            _ord = nil;

            switch (_state) do {
                case ("attack") : {
                    {
                        _state = [_x,"opcom_state"] call ALiVE_fnc_HashGet;

                        //Set attack only if any synchronized triggers are activated
                        if ((_state == "attack") && {{((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0}) exitwith {_target = _x};
                    } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);

                    //Trigger order execution
                    if !(isnil "_target") then {
                        _ord = [_target,"opcom_orders","none"] call ALiVE_fnc_HashGet;
                        [_target,"opcom_orders","attack"] call ALiVE_fnc_HashSet;
                        _DATA_TMP = ["execute",_target];
                    };
                };
                case ("unassigned") : {
                    {
                        _state = [_x,"opcom_state"] call ALiVE_fnc_HashGet;

                        //Set attack only if any synchronized triggers are activated
                        if ((_state == "unassigned") && {{((typeof _x) == "EmptyDetector") && {!(triggerActivated _x)}} count (synchronizedObjects _module) == 0}) exitwith {_target = _x};
                    } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);

                    //Trigger order execution
                    if !(isnil "_target") then {
                        _ord = [_target,"opcom_orders","none"] call ALiVE_fnc_HashGet;
                        //if (!(_ord == "attack")) then {
                            [_target,"opcom_orders","attack"] call ALiVE_fnc_HashSet;
                            _DATA_TMP = ["execute",_target];
                        //};
                    };
                };
                case ("defend") : {
                    {
                        _state = [_x,"opcom_state"] call ALiVE_fnc_HashGet;
                        if (_state == "defend") exitwith {_target = _x};
                    } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);

                    //Trigger order execution
                    if !(isnil "_target") then {
                        _ord = [_target,"opcom_orders","none"] call ALiVE_fnc_HashGet;
                        //if (!(_ord == "defend")) then {
                            [_target,"opcom_orders","defend"] call ALiVE_fnc_HashSet;
                            _DATA_TMP = ["execute",_target];
                        //};
                    };
                };
                case ("reserve") : {
                    {
                        _state = [_x,"opcom_state"] call ALiVE_fnc_HashGet;
                        if (_state == "reserve") exitwith {_target = _x};
                    } foreach ([_logic,"objectives",[]] call ALiVE_fnc_HashGet);;

                    //Trigger order execution
                    if !(isnil "_target") then {
                        _ord = [_target,"opcom_orders","none"] call ALiVE_fnc_HashGet;
                        //if (!(_ord == "reserve")) then {
                            [_target,"opcom_orders","reserve"] call ALiVE_fnc_HashSet;
                            _DATA_TMP = ["execute",_target];
                        //};
                    };
                };
            };

            if !(isnil "_DATA_TMP") then {_result = _DATA_TMP} else {_result = nil};
    };

    case "OPCOM_monitor": {
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        //private ["_hdl","_side","_state","_FSM","_cycleTime"];

        _hdl = [_logic,"monitor",false] call ALiVE_fnc_HashGet;

        if (!(_args) && {!(typeName _hdl == "BOOL")}) then {
                terminate _hdl;
                [_logic,"monitor",nil] call ALiVE_fnc_HashSet;
        } else {
            _hdl = _logic spawn {

                // debug ---------------------------------------
                if ([_this,"debug",false] call ALiVE_fnc_HashGet) then {
                    ["OPCOM and TACOM monitoring started..."] call ALiVE_fnc_dumpR;
                };
                // debug ---------------------------------------
                _FSM_OPCOM = [_this,"OPCOM_FSM"] call ALiVE_fnc_HashGet;
                _FSM_TACOM = [_this,"TACOM_FSM"] call ALiVE_fnc_HashGet;

                while {true} do {

                        _state = _FSM_OPCOM getfsmvariable "_OPCOM_status";
                        _state_TACOM = _FSM_TACOM getfsmvariable "_TACOM_status";
                        _side = _FSM_OPCOM getfsmvariable "_side";
                        _cycleTime = _FSM_OPCOM getfsmvariable "_cycleTime";
                        _timestamp = floor(time - (_FSM_OPCOM getfsmvariable "_timestamp"));

                        //Exit if FSM has ended
                        if (isnil "_cycleTime") exitwith {["Exiting OPCOM Monitor"] call ALiVE_fnc_Dump};

                        _maxLimit = _cycleTime + ((count allunits)*2);

                        if (_timestamp > _maxLimit) then {
                        //if (true) then {
                            // debug ---------------------------------------
                            if ([_this,"debug",false] call ALiVE_fnc_HashGet) then {
                                _message = parsetext (format["<t align=left>OPCOM side: %1<br/><br/>WARNING! Max. duration exceeded!<br/>state OPCOM: %2<br/>state TACOM: %4<br/>duration: %3</t>",_side,_state,_timestamp,_state_TACOM]);
                                [_message] call ALiVE_fnc_dump; hintsilent _message;

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
            [_logic,"monitor",_hdl] call ALiVE_fnc_HashSet;
        };
        _result = _hdl;
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};

TRACE_1("OPCOM - output", _result);

if !(isnil "_result") then {_result} else {nil};