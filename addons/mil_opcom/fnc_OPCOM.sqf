//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(OPCOM);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_OPCOM
Description:
Virtual AI Controller

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Examples:
(begin example)
(end)

See Also:

Author:
Highhead / SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_OPCOM

#define MTEMPLATE   "ALiVE_OPCOM_%1"

TRACE_1("OPCOM - input",_this);

private ["_result"];
params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];


switch (_operation) do {

    case "create": {
        private _logic = (createGroup sideLogic) createUnit [QUOTE(ADDON), [0,0], [], 0, "NONE"];

        TRACE_1("Creating class on all localities",true);

        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];

        _result = _logic;
    };

    case "init": {

        if (!isserver) exitwith {};

        _logic setVariable ["super", SUPERCLASS];
        _logic setVariable ["class", MAINCLASS];
        _logic setVariable ["moduleType", "ALiVE_OPCOM"];

        [_logic,"start"] call MAINCLASS;
        //[_logic,"listen"] call MAINCLASS;
    };
/*
    case "listen": {
        private _handler = _logic getvariable "handler";
        private _listenerID = [ALiVE_eventLog,"addListener", [_handler, ["PROFILE_UNREGISTER"]]] call ALiVE_fnc_eventLog;
        _logic setVariable ["listenerID", _listenerID];
    };

    case "handleEvent": {
        private _event = _args; // a private event? how exclusive...

        private _eventData = [_event,"data"] call ALIVE_fnc_hashGet;

        private _profile = _eventData select 0;
        private _profileID = _profile select 2 select 4;

        private _allSections = [_logic,"allSections"] call ALiVE_fnc_hashGet;
        private _index = _allSections find { (_x select 2 select 4) == _profileID };

        if (_index != -1) then {
            private _sortType = (_allSections select _index) select 0;
            private _sectionsByType = [_logic,"sectionsByType"] call ALiVE_fnc_hashGet;


            _allSections deleteat _index;
            if (true) then {
                private _opcomFSM = [_logic,"OPCOM_FSM"] call ALiVE_fnc_hashGet;
                private _toDeleteQueue = _opcomFSM getFsmVariable ["_profilesUnregisteredWhileSorting", []];
                _toDeleteQueue pushback _profileID;
            };
        };
    };
*/
    case "start": {

        if (!isserver) exitwith {};

        _logic setVariable ["startupComplete", false];

        // retrieve module-object variables
        private _type = _logic getvariable ["controltype","invasion"];
        private _occupation = (_logic getvariable ["asym_occupation",-100])/100;
        private _intelChance = (_logic getvariable ["intelchance",-100])/100;
        private _faction1 = _logic getvariable ["faction1","OPF_F"];
        private _faction2 = _logic getvariable ["faction2","NONE"];
        private _faction3 = _logic getvariable ["faction3","NONE"];
        private _faction4 = _logic getvariable ["faction4","NONE"];
        private _factions = [_logic getvariable ["factions",[]]] call ALiVE_fnc_stringListToArray;
        private _simultaneousObjectives = _logic getvariable ["simultanObjectives",10];
        private _minAgents = _logic getvariable ["minAgents",2];

        private _debug = (_logic getvariable ["debug","false"]) == "true";
        private _persistent = (_logic getvariable ["persistent","false"]) == "true";
        private _reinforcementRatio = parsenumber (_logic getvariable ["reinforcements","0.9"]);
        private _roadblocks = _logic getvariable ["roadblocks",true];

        private _position = getposATL _logic;

        // If missionmaker did not overwrite default factions then use the ones from the module dropdowns
        // Collect factions and determine sides

        if (count _factions == 0) then {
            private _selectedDropdownFactions = [_faction1,_faction2,_faction3,_faction4] select { _x != "NONE" };
            _factions append _selectedDropdownFactions;
        };

        // use first faction to determine which side this opcom controls

        private _side = switch (getnumber(((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side")) do {
            case 0 : {"EAST"};
            case 1 : {"WEST"};
            case 2 : {"GUER"};
            default {"EAST"};
        };

        // determine friendly and enemy sides
        // #TODO: This could be dynamic

        private _sideObject = [_side] call ALIVE_fnc_sideTextToObject;
        private _sides = ["EAST","WEST","GUER"] - [_side];
        private _sidesEnemy = _sides select {
            private _friendRating = _sideObject getfriend ([_x] call ALIVE_fnc_sideTextToObject);

            _friendRating < 0.6
        };
        private _sidesFriendly = _sides - _sidesEnemy;

        // init data handler

        if (isnil "OPCOM_instances") then {
            OPCOM_instances = [];
        };

        private _opcomID = format ["OPCOM_%1", count OPCOM_instances];

        private _handler = [
            [
                ["side", _side],
                ["factions", _factions],
                ["sidesEnemy", _sidesEnemy],
                ["sidesFriendly", _sidesFriendly],
                ["position", _position],
                ["simultanobjectives", _simultaneousObjectives],
                ["minAgents", _minAgents],
                ["opcomID", _opcomID],
                ["debug", _debug],
                ["persistent", _persistent],
                ["module", _logic],
                ["reinforcements", _reinforcementRatio],
                ["asym_occupation", _occupation],
                ["controltype", _type],
                ["intelchance", _intelChance],
                ["roadblocks", _roadblocks],

                ["objectives", []],
                ["objectivesByID", [] call CBA_fnc_createNamespace],
                ["heldObjectives", []],
                ["orders", [] call ALiVE_fnc_hashCreate],
                ["pendingorders", [] call ALiVE_fnc_hashCreate],
                ["missions", [] call ALiVE_fnc_hashCreate],
                ["allSections", []],
                ["sectionsByType", [] call ALiVE_fnc_hashCreate],
                ["taskedSections", []],
                ["nextObjectiveID", 1],
                ["nextOrderID", 1],
                ["objectivesToAdd", []],
                ["missionOptions", []],

                ["sectionsamount_attack", 1],
                ["sectionsamount_reserve", 1],
                ["sectionsamount_defend", 1],

                ["CQB", []]
            ]
        ] call ALiVE_fnc_hashCreate;

        private _missionOptionReserve = call compile preprocessFileLineNumbers "x\alive\addons\mil_opcom\mission_options\reserve.sqf";
        [_handler,"addMissionOption", _missionOptionReserve] call MAINCLASS;

        _logic setVariable ["handler", _handler];

        // add to global OPCOM_instances array for easier access
        OPCOM_instances pushback _handler;

        // spread Intel Information for this OPCOMs side

        missionnamespace setvariable [
            format ["ALiVE_MIL_OPCOM_INTELCHANCE_%1", [_side] call ALiVE_fnc_SideTextToObject],
            _intelChance
        ];
        publicVariable (format ["ALiVE_MIL_OPCOM_INTELCHANCE_%1", [_side] call ALiVE_fnc_SideTextToObject]);

        // store synced CQB modules

        private _syncedObjects = synchronizedObjects _logic;
        private _syncedCQBModules = _syncedObjects select { typeof _x == "ALiVE_mil_cqb" };
        {
            waituntil { _x getVariable ["startupComplete",false] };
        } foreach _syncedCQBModules;

        [_handler,"CQB", _syncedCQBModules] call ALiVE_fnc_hashSet;

        // set dynamic data depending on type

        switch (_type) do {
            case ("invasion") : {
                [_handler,"sectionsamount_attack", 4] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_reserve", 1] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_defend", 2] call ALiVE_fnc_hashSet;
            };
            case ("occupation") : {
                [_handler,"sectionsamount_attack", 4] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_reserve", 1] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_defend", 5] call ALiVE_fnc_hashSet;
            };
            case ("asymmetric") : {
                [_handler,"sectionsamount_attack", 1] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_reserve", 1] call ALiVE_fnc_hashSet;
                [_handler,"sectionsamount_defend", 1] call ALiVE_fnc_hashSet;

                // init INS helpers
                call ALiVE_fnc_INS_helpers;

                [_syncedCQBModules] call ALiVE_fnc_resetCQB;
            };
        };

        //////////////////////////////////////////////////////
        //Before starting check if startup parameters are ok!
        //////////////////////////////////////////////////////

        // verify profile system module is placed

        if !(["ALiVE_sys_profile"] call ALiVE_fnc_isModuleAvailable) exitwith {
            ["No Virtual AI system module was found! Please use this module in your mission!"] call ALIVE_fnc_dumpR;
        };

        // wait for profile system to finish startup

        waituntil {
            ["ALiVE OPCOM Waiting for Virtual AI System..."] call ALiVE_fnc_Dump;

            !(isnil "ALiVE_ProfileHandler") && { [ALiVE_ProfileSystem,"startupComplete",false] call ALIVE_fnc_hashGet }
        };

        private _objectives = [];
        //    //Load Data from DB
        //    if ([_handler,"persistent",false] call ALIVE_fnc_HashGet) then {
        //        _objectives = [_handler,"loadObjectivesDB"] call ALiVE_fnc_OPCOM;
        //
        //        if (!isNil "ALIVE_sys_data" && {!ALIVE_sys_data_DISABLED}) then {
        //            // Load starting forces
        //            private _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;
        //            private _key = format ["%1_%2-OPCOM_%3-starting-forces", ALIVE_sys_data_GROUP_ID, _missionName, [_handler, "opcomID"] call CBA_fnc_hashGet];
        //            private _result = [GVAR(DATAHANDLER), "read", ["mil_opcom", [], _key]] call ALIVE_fnc_Data;
        //
        //            if (_result isEqualType []) then {
        //                private _startingForces = [_result, "data"] call CBA_fnc_hashGet;
        //                [_handler, "startForceStrength", _startingForces] call CBA_fnc_hashSet;
        //            };
        //        };
        //    };

        // store objectives from synced modules
        // create objectives for synced game logics

        if (count _objectives > 0) then {
            ["ALiVE OPCOM loaded %1 objectives from DB!", count _objectives] call ALiVE_fnc_Dump;
        } else {
            private _alivePlacementModules = ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_mil_placement_custom"];
            {
                if ((typeof _x) in _alivePlacementModules) then {
                    // wait for module to init
                    waituntil { _x getVariable ["startupComplete", false] };

                    private _moduleObjectives = [_x,"objectives",objNull,[]] call ALIVE_fnc_OOsimpleOperation;
                    _objectives append _moduleObjectives;
                } else {
                    if (_x iskindof "LocationBase_F") then {
                        // these two values can be overwritten with f.e. *this setvariable ["size",700]* in init-field of editorobject...
                        private _size = _x getvariable ["size",150];
                        private _priority = _x getvariable ["priority",200];

                        private _type = gettext (configfile >> "CfgVehicles" >> (typeOf _x) >> "displayName");

                        private _obj = [] call ALiVE_fnc_hashCreate;
                        [_obj,"center", getposATL _x] call ALiVE_fnc_HashSet;
                        [_obj,"size", _size] call ALiVE_fnc_hashSet;
                        [_obj,"objectiveType", _type] call ALiVE_fnc_hashSet;
                        [_obj,"priority", _priority] call ALiVE_fnc_hashSet;
                        [_obj,"clusterID", ""] call ALiVE_fnc_hashSet;

                        _objectives pushback _obj;
                    };
                };
            } foreach _syncedObjects;

            _objectives = [_handler,"createObjectives", _objectives] call MAINCLASS;

            // bypass buffer time so we can pass validation (below)
            [_handler,"addBufferedObjectives"] call MAINCLASS;

            if (_debug) then {
                ["ALiVE OPCOM created %1 new objectives!", count _objectives] call ALiVE_fnc_Dump;
            };
        };

        /////////////
        // Validate
        /////////////


        // exit if we don't have any objectives
        if (count _objectives == 0) exitwith {
            [
                "There are %1 objectives for this %3 OPCOM instance! Please assign Military or Civilian Placement Objectives!",
                count _objectives
            ] call ALIVE_fnc_dumpR;
        };

        // give performance warning if there are too many objectives
        if (count _objectives > 120) then {
            [
                "There are %1 objectives for commander which controls %2! Please lower the objective count for performance reasons, suggested is below 120!",
                count _objectives,
                _factions
            ] call ALIVE_fnc_dump;
        };

        // exit if we don't have any groups available for our factions
        private _availabeProfileCount = 0;
        {
            private _factionProfileCount = count ([ALiVE_profileHandler,"getProfilesByFaction", _x] call ALIVE_fnc_profileHandler);

            if (_factionProfileCount > 0) then {
                _availabeProfileCount = _availabeProfileCount + _factionProfileCount;
            } else {
                [
                    "There are are no groups for OPCOM faction(s) %1! Please ensure you have configured a Mil Placement or Mil Placement (Civ Obj) module for this faction (or faction units are synced to Virtual AI module). If so, please check groups are correctly configured for this faction.",
                    _x
                ] call ALIVE_fnc_dumpR;
            };
        } foreach _factions;

        // Ok? Exit if another OPCOM controls our factions
        private _allOpcomInstances = OPCOM_instances - [_handler];
        private _conflictingFactions = [];
        private _conflictingOpcomSide = "";
        {
            private _otherOpcom = _x;

            // wait until opcom gathering factions
            waituntil { !(isnil {_otherOpcom getvariable "factions"}) };

            private _otherOpcomSide = _otherOpcom getvariable "side";
            private _otherOpcomFactions = _otherOpcom getvariable "factions";

            private _sameFactions = _factions arrayIntersect _otherOpcomFactions;
            if (count _sameFactions > 0) exitwith {
                _conflictingFactions = _sameFactions;
                _conflictingOpcomSide = _otherOpcomSide;
            };
        } foreach _allOpcomInstances;

        if (count _conflictingFactions > 0) exitwith {
            [
                "Factions %1 are already used by another OPCOM (side: %2)! Please change the faction!",
                _conflictingFactions,
                _conflictingOpcomSide
            ] call ALIVE_fnc_dumpR;
        };

        // Still there? Awesome, make sure we only control factions belonging to one side
        _errorMessage = "There are different sides within this OPCOM %1! Please only select one side per OPCOM!%2";
        private _sidesControlled = [];
        {
            private _factionConfig = _x call ALiVE_fnc_configGetFactionClass;
            private _factionSide = [getnumber (_factionConfig >> "side")] call ALiVE_fnc_sideNumberToText;

            _sidesControlled pushback _factionSide;
        } foreach _factions;

        if (count _sidesControlled > 1) exitwith {
            ["There are different sides within this OPCOM %1! Please only select one side per OPCOM! %2", _sidesControlled] call ALIVE_fnc_dumpR;
        };

        // Still there, mega, lets summarize...
        if (_debug) then {
            ["OPCOM %1 starts with %2 profiles and %3 objectives!", _side, _availabeProfileCount, count _objectives] call ALIVE_fnc_dumpR;
        };


        ///////////
        //Startup
        ///////////


        // Perform initial cluster occupation and troops analysis as MP modules are finished
        //_clusterOccupationAnalysis = [_handler,_side,_sidesEnemy,_sidesFriendly] call {[_this select 0,"analyzeclusteroccupation",[_this select 3,_this select 2]] call ALiVE_fnc_OPCOM};
        //_forcesInit = [_handler,"scantroops"] call ALiVE_fnc_OPCOM;
        //["ALiVE OPCOM %1 Initial analysis done...",_side] call ALiVE_fnc_Dump;

        switch _type do {
            case ("occupation") : {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                [_handler,"OPCOM_FSM", _opcomFSM] call ALiVE_fnc_hashSet;
                [_handler,"TACOM_FSM", _tacomFSM] call ALiVE_fnc_hashSet;
            };
            case ("invasion") : {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";

                [_handler,"OPCOM_FSM", _opcomFSM] call ALiVE_fnc_hashSet;
                [_handler,"TACOM_FSM", _tacomFSM] call ALiVE_fnc_hashSet;
            };
            case ("asymmetric") : {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                [_handler,"OPCOM_FSM", _opcomFSM] call ALiVE_fnc_hashSet;
            };
        };

        // set startup complete and end loading screen if init has passed or an error occurred
        _logic setVariable ["startupComplete",true,true];
        [_handler,"startupComplete", true] call ALiVE_fnc_hashSet;
    };

    case "addObjective": {
        _args params [
            ["_id", "", [""]],
            ["_pos", [0,0,0], [[]]],
            ["_size", 50, [1]],
            ["_type", "CIV", [""]],
            ["_priority", 100, [1]],
            ["_opcomState", "unassigned", [""]],
            ["_clusterID", "", [""]],
            ["_danger", -1]
        ];

        private _opcomID = [_logic,"opcomID"] call ALIVE_fnc_HashGet;

        if (_id == "") then {
            private _objectiveIDNumber = [_logic,"nextObjectiveID"] call ALIVE_fnc_HashGet;
            _id = format ["%1_OBJ_%2", _opcomID, _objectiveIDNumber];

            [_logic,"nextObjectiveID", _objectiveIDNumber + 1] call ALIVE_fnc_HashSet;
        };

        private _objective = [
            [
                ["objectiveID", _id],
                ["center", _pos],
                ["size", _size],
                ["objectiveType", _type],
                ["priority", _priority],
                ["opcom_state", _opcomState],
                ["clusterID", _clusterID],
                ["opcomID", _opcomID],
                ["_rev", ""]
            ]
        ] call ALiVE_fnc_hashCreate;

        // objectives are qeued for addition
        // which is done once opcom cycle is completed
        private _objectivesToAdd = [_logic,"objectivesToAdd"] call ALiVE_fnc_HashGet;
        _objectivesToAdd pushback _objective;

        // #TODO: assign orders based on passed state
        // backwards compatibility

        switch (_opcomState) do {

        };

        _result = _objective;
    };

    case "createObjectives": {
        private _objectives = _args;

        private _startpos = [_logic,"position"] call ALiVE_fnc_HashGet;
        private _side = [_logic,"side"] call ALiVE_fnc_HashGet;
        private _factions = [_logic,"factions"] call ALiVE_fnc_HashGet;
        private _debug = [_logic,"debug"] call ALiVE_fnc_HashGet;

        private _objectives = _objectives apply {
            private _clusterID = [_x,"clusterID"] call ALiVE_fnc_hashGet;
            private _pos = [_x,"center"] call ALiVE_fnc_hashGet;
            private _size = [_x,"size"] call ALiVE_fnc_hashGet;
            private _type = [_x,"type"] call ALiVE_fnc_hashGet;
            private _priority = [_x,"priority"] call ALiVE_fnc_hashGet;
            private _height = (ATLtoASL [_pos select 0, _pos select 1,0]) select 2;

            [_logic,"addObjective", ["", _pos, round _size, _type, _priority, "unassigned", _clusterID]] call ALiVE_fnc_OPCOM;
        };

        _result = _objectives;
    };

    case "sortObjectives": {
        _args params ["_objectives",["_sortType",""]];

        if (_sortType == "") then {
            private _controlType = [_logic,"controltype"] call ALiVE_fnc_hashGet;

            _sortType = switch (_controlType) do {
                case "occupation":  { "strategic" };
                case "invasion":    { "distance" };
                case "asymmetric":  { "asymmetric" };
                default             { "distance" };
            };
        };

        _result = _objectives;

        private _modulePosition = [_logic,"position"] call ALiVE_fnc_hashGet;

        switch (_sortType) do {
            case "distance": {
                _result = [_objectives,[_logic],{
                    private _distToOpcom = (_x select 2 select 1) distance _modulePosition;
                    private _score = _distToOpcom * (1 - (random 0.33));

                    _score
                },"ASCEND"] call ALiVE_fnc_SortBy;
            };
            case "strategic": {
                _result = [_objectives,[_logic],{
                    private _height = (ATLtoASL [(_x select 2 select 1) select 0,(_x select 2 select 1) select 1,0]) select 2;
                    private _size = _x select 2 select 2;
                    private _priority = _x select 2 select 4;

                    private _heightScore = _height / 2;
                    private _distScore = ((_x select 2 select 1) distance _modulePosition) / 10;

                    private _score = (_size + _priority + _heightScore) - _distScore;
                    _score = _score * (1 - (random 0.33));

                    _score
                },"DESCEND"] call ALiVE_fnc_SortBy;
            };
            case ("asymmetric") : {
                _result = [+_objectives,[_logic],{
                    ((_x select 2 select 1) distance _modulePosition) * (1 - (random 0.20))
                },"ASCEND"] call ALiVE_fnc_SortBy;
            };
        };
    };

    case "createObjectiveDebugMarker": {
        private _objective = _args;

        private _id = [_objective,"objectiveID"] call ALiVE_fnc_HashGet;
        private _debugTextMarker = format [MTEMPLATE, _id];
        if !(_debugTextMarker call ALiVE_fnc_markerExists) then {
            private _side = [_logic,"side"] call ALiVE_fnc_HashGet;
            private _color = switch (_side) do {
                case "EAST" : {"COLORRED"};
                case "WEST" : {"COLORBLUE"};
                case "GUER" : {"COLORGREEN"};
                default {"COLORYELLOW"};
            };

            private _center = [_objective,"center"] call ALiVE_fnc_HashGet;
            private _size = [_objective,"size"] call ALiVE_fnc_hashGet;
            private _priority = [_objective,"priority"] call ALiVE_fnc_hashGet;

            // text marker
            [_debugTextMarker, _center,"ICON", [0.5,0.5], _color, format ["%1-size:%2-prio:%3",_id,_size,_priority], "mil_dot", "FDiagonal", 0, 0.5] call ALIVE_fnc_createMarkerGlobal;

            // circle marker
            private _debugMarker = format [MTEMPLATE, _id] + "_background";
            [_debugMarker, _center,"ELLIPSE", [_size / 2, _size / 2], _color, "", "", "FDiagonal", 0, 0.6] call ALIVE_fnc_createMarkerGlobal;
        };
    };

    case "deleteObjectiveDebugMarker": {
        private _objective = _args;
        private _debugTextMarker = format [MTEMPLATE, _id];
        private _debugMarker = format [MTEMPLATE, _id] + "_background";

        deletemarker _debugTextMarker;
        deletemarker _debugMarker;
    };

    case "addBufferedObjectives": {
        private _newObjectives = [_logic,"objectivesToAdd"] call ALiVE_fnc_hashGet;
        if !(_newObjectives isequalto []) then {
            private _objectives = [_logic,"objectives"] call ALiVE_fnc_hashGet;
            private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_hashGet;

            _objectives append _newObjectives;
            _objectives = [_logic,"sortObjectives", [_objectives]] call MAINCLASS;

            [_logic,"objectives", _objectives] call ALiVE_fnc_hashSet;

            {
                private _id = [_x,"objectiveID"] call ALiVE_fnc_hashGet;
                _objectivesByID setvariable [_id,_x];
            } foreach _newObjectives;

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;
            {
                [_logic,"createObjectiveDebugMarker", _x] call MAINCLASS;
            } foreach _newObjectives;

            [_logic,"objectivesToAdd", []] call ALiVE_fnc_hashSet;
        };
    };

    case "analyzeObjectiveOccupation": {
        private _objective = _args;

        private _opcomFactions = [_logic,"factions"] call ALiVE_fnc_hashGet;

        private _position = [_objective,"center"] call ALiVE_fnc_hashGet;
        private _size = [_objective,"size"] call ALiVE_fnc_hashGet;

        private _nearFriendlies = []; // just our units, not allies
        private _nearEnemies = [];

        private _nearProfiles = [_position, _size * 1.1, ["all","entity","none"]] call ALIVE_fnc_getNearProfiles;
        {
            private _profile = _x;
            private _profileFaction = [_profile,"faction"] call ALiVE_fnc_hashGet;
            private _vehiclesInCommandOf = (_profile select 2 select 8) apply { [ALiVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler };

            if (_profileFaction in _opcomFactions) then {
                _nearFriendlies pushback _profile;
        } else {
                _nearEnemies pushback _profile;
            };
        } foreach _nearProfiles;

        _result = [_objective, count _nearFriendlies, count _nearEnemies, _nearFriendlies, _nearEnemies];
    };

    case "sortProfilesByType": {
        private _profileIDs = _args;

        private _infantry = [];
        private _motorized = [];
        private _mechanized = [];
        private _armored = [];
        private _antiAir = [];
        private _artillery = [];
        private _naval = [];

        {
            private _profileID = _x;
            private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;
            private _type = _profile select 2 select 5;

            if (_type == "entity") then {
                private _vehicleAssignments = (_profile select 2 select 7) select 1; // hash

                if (_vehicleAssignments isequalto []) then {
                    private _isPlayer = [_profile,"isPlayer",false] call ALiVE_fnc_hashGet;

                    if (!_isPlayer) then {
                        _infantry pushback _profileID;
                    };
                };
            } else {
                private _objectType = _profile select 2 select 6;
                private _assignments = _profile select 2 select 8;

                switch (tolower _objectType) do {
                    case "car": {
                        _motorized append _assignments;
                    };
                    case "truck": {
                        _motorized append _assignments;
                    };
                    case "tank": {
                        private _vehicleClass = _profile select 2 select 11;
                        private _isAntiAir = [_vehicleClass] call ALiVE_fnc_isAA;
                        private _isArtillery = [_vehicleClass] call ALiVE_fnc_isArtillery;

                        if (_isAntiAir) then {
                            _antiAir append _assignments;
                        } else {
                            if (_isArtillery) then {
                                _artillery append _assignments;
                            } else {
                                _armored append _assignments;
                            };
                        };
                    };
                    case "armored": {
                        _mechanized append _assignments;
                    };
                    case "ship": {
                        _naval append _assignments;
                    };
                };
            };
        } foreach _profileIDs;

        _result = [_infantry,_motorized,_mechanized,_armored,_antiAir,_artillery,_naval];
    };

    case "getUntaskedSections": {

    };

    case "sortSectionsByDistance": {
        _args params ["_position",["_sections", []], ["_excludeBusy", false]];

        if (_sections isequalto []) then {
            _sections = [_logic,"allSections"] call ALiVE_fnc_hashGet;
        };

        private _profilesWithDistance = [];
        {
            private _profile = ALiVE_profileMap getvariable _x;

            if (!isnil "_profile") then {
                private _busy = [_profile,"busy", false] call ALiVE_fnc_hashGet;

                if (!_busy && _excludeBusy) then {
                    private _profilePos = _profile select 2 select 2;
                    private _distance = _profilePos distance _position;
                    _profilesWithDistance pushback [_distance,_profile];
                };
            };
        } foreach _sections;

        _profilesWithDistance sort true;

        _result = _profilesWithDistance apply { _x select 1 };
    };

    case "findNearestSection": {
        _args params ["_position",["_sections", []]];

        private _sectionsByDistance = [_logic,"sortSectionsByDistance", [_position, _sections]] call MAINCLASS;

        if !(_sectionsByDistance isequalto []) then {
            _result = _sectionsByDistance select 0;
        };
    };

    case "profileListRemoveDead": {
        private _profileIDs = _args;

        private _deadProfiles = [];

        private _profileIDCount = count _profileIDs;
        private _i = 0;
        while { _i < _profileIDCount && { _profileIDCount > 0 }} do {
            private _profile = ALiVE_profileMap getvariable (_profileIDs select _i);

            if (isnil "_profile") then {
                _deadProfiles pushback (_profileIDs deleteat _i);
                _profileIDCount = _profileIDCount - 1;
            } else {
                _i = _i + 1;
            };
        };

        _result = _deadProfiles;
    };

    case "getObjectiveByID": {
        private _id = _args;

        private _objectivesByID = [_logic,"objectivesByID"] call ALiVE_fnc_hashGet;

        _result = _objectivesByID getvariable _id;
    };

    case "getNextOrderID": {
        private _nextOrderID = [_logic,"nextOrderID"] call ALiVE_fnc_hashGet;
        [_logic,"nextOrderID", _nextOrderID + 1] call ALiVE_fnc_hashSet;

        _result = format ["order_%1", _nextOrderID];
    };

    case "addMissionOption": {
        private _newOptionData = _args;

        private _missionOptions = [_logic,"missionOptions"] call ALiVE_fnc_hashGet;

        private _newOption = [_newOptionData] call ALiVE_fnc_hashCreate;
        private _newOptionName = [_newOption,"name"] call ALiVE_fnc_hashGet;

        [_logic,"removeMissionOption", _newOptionName] call MAINCLASS;

        if (_missionOptions isequalto []) then {
            _missionOptions pushback _newOption;
        } else {
            private _newMissionPriority = [_newOption,"priority"] call ALiVE_fnc_hashGet;

            private _missionOptionCount = count _missionOptions;
            private _i = 0;
            while {
                private _curr = _missionOptions select _i;
                _i < _missionOptionCount && { _newMissionPriority <= [_curr,"priority"] call ALiVE_fnc_hashGet }
            } do {
                _i = _i + 1;
            };

            private _head = _missionOptions select [0, _i];
            private _tail = _missionOptions select [_i, _missionOptionCount - _i];

            _missionOptions = _head + [_newOption] + _tail;
            [_logic,"missionOptions", _missionOptions] call ALiVE_fnc_hashSet;
        };
    };

    case "removeMissionOption": {
        private _optionToRemoveName = _args;

        private _missionOptions = [_logic,"missionOptions"] call ALiVE_fnc_hashGet;

        {
            private _name = [_x,"name"] call ALiVE_fnc_hashGet;

            if (_name == _optionToRemoveName) exitwith {
                _missionOptions deleteat _foreachindex;
            };
        } foreach _missionOptions;
    };

    case "getMissionOption": {
        private _optionToRemoveName = _args;

        {
            private _name = [_x,"name"] call ALiVE_fnc_hashGet;

            if (_name == _optionToRemoveName) exitwith {
                _result = _x;
            };
        } foreach _missionOptions;
    };

    case "hasMissionOption": {
        private _optionName = _args;

        private _missionOptions = [_logic,"missionOptions"] call ALiVE_fnc_hashGet;

        _result = false;

        {
            private _name = [_x,"name"] call ALiVE_fnc_hashGet;

            if (_name == _optionName) exitwith {
                _result = true;
            };
        } foreach _missionOptions;
    };

    case "toggleObjectiveDebugMarkers": {
        private _enable = _args;

        if (_enable) then {
            {
                [_logic,"createObjectiveDebugMarker", _x] call MAINCLASS;
            } foreach _objectives;
        } else {
            {
                [_logic,"deleteObjectiveDebugMarker", _x] call MAINCLASS;
            } foreach _objectives;
        };
    };

    case "debug": {
        if (_args isequaltype true) then {
            [_logic,"debug", _args] call ALiVE_fnc_hashSet;
            [_logic,"toggleObjectiveDebugMarkers", _args] call MAINCLASS;
        } else {
            _result = [_logic,"debug"] call ALiVE_fnc_hashGet;
        };
    };

    case "objectives": {
        if (_args isequaltype []) then {
            [_logic,"objectives", _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,"objectives"] call ALiVE_fnc_hashGet;
        };

        _result = _args;
    };

    case "destroy": {
        [_logic,"stop"] call MAINCLASS;

        OPCOM_instances deleteat (OPCOM_instances find _logic);

        private _module = [_logic,"module"] call ALiVE_fnc_hashGet;

        private _group = group _module;
        deleteVehicle _module;
        deletegroup _group;
    };

    case "pause": {
        if (_args isequaltype true) then {
            private _opcomFSM = [_logic,"OPCOM_FSM"] call ALiVE_fnc_hashGet;
            private _tacomFSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_hashGet;

            _opcomFSM setFSMVariable ["pause", _args];
            _tacomFSM setFSMVariable ["pause", _args];

            [_logic,"pause", _args] call ALiVE_fnc_hashSet;
        } else {
            _result = [_logic,"pause"] call ALiVE_fnc_hashGet;
        };
    };

    case "stop": {
        private _opcomFSM = [_logic,"OPCOM_FSM"] call ALiVE_fnc_hashGet;
        private _tacomFSM = [_logic,"TACOM_FSM"] call ALiVE_fnc_hashGet;

        _opcomFSM setFSMvariable ["_exitFSM",true];
        _tacomFSM setFSMvariable ["_exitFSM",true];

        private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;
        if (_debug) then {
            ["ALiVE OPCOM stopped..."] call ALiVE_fnc_Dump;
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("OPCOM - output",_result);

if !(isnil "_result") then {_result} else {nil};
