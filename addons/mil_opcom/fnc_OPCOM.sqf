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
    ["_logic", objNull, [objNull,[],""]],
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
    };

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

        private _handler = [nil, "create"] call ALIVE_fnc_BaseClass;
        _handler setvariable ["class", nil];

        _logic setVariable ["handler", _handler];

        // add to global OPCOM_instances array for easier access
        if (isnil "OPCOM_instances") then {
            OPCOM_instances = [];
        };
        OPCOM_instances pushback _handler;

        private _opcomID = format ["OPCOM_%1", count OPCOM_instances];

        _handler setvariable ["side", _side];
        _handler setvariable ["factions", _factions];
        _handler setvariable ["sidesEnemy", _sidesEnemy];
        _handler setvariable ["sidesFriendly", _sidesFriendly];
        _handler setvariable ["position", _position];
        _handler setvariable ["simultaneousobjectives", _simultaneousObjectives];
        _handler setvariable ["minAgents", _minAgents];
        _handler setvariable ["opcomID", _opcomID];
        _handler setvariable ["debug", _debug];
        _handler setvariable ["persistent", _persistent];
        _handler setvariable ["moduleObject", _logic];
        _handler setvariable ["reinforcementRatio", _reinforcementRatio];
        _handler setvariable ["asym_occupation", _occupation];
        _handler setvariable ["controltype", _type];
        _handler setvariable ["intelchance", _intelChance];
        _handler setvariable ["roadblocks", _roadblocks];

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

        _handler setvariable ["CQB", _syncedCQBModules];

        // set dynamic data depending on type

        switch (_type) do {
            case ("invasion") : {
                _handler setvariable ["sectionsamount_attack", 4];
                _handler setvariable ["sectionsamount_reserve", 1];
                _handler setvariable ["sectionsamount_defend", 2];
            };
            case ("occupation") : {
                _handler setvariable ["sectionsamount_attack", 4];
                _handler setvariable ["sectionsamount_reserve", 1];
                _handler setvariable ["sectionsamount_defend", 5];
            };
            case ("asymmetric") : {
                _handler setvariable ["sectionsamount_attack", 1];
                _handler setvariable ["sectionsamount_reserve", 1];
                _handler setvariable ["sectionsamount_defend", 1];

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

            switch (_type) do {
                case ("occupation") : {
                    _objectives = [_handler,"sortObjectives", [_objectives,"strategic"]] call MAINCLASS;
                };
                case ("invasion") : {
                    _objectives = [_handler,"sortObjectives", [_objectives,"distance"]] call MAINCLASS;
                };
                case ("asymmetric") : {
                    _objectives = [_handler,"sortObjectives", [_objectives,"asymmetric"]] call MAINCLASS;
                };

                _handler setvariable ["objectives", _objectives];
            };

            if (_debug) then {
                ["ALiVE OPCOM created %1 new objectives!",count _objectives] call ALiVE_fnc_Dump;
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
                //private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";
                private _tacomFSM = 723;

                _handler setvariable ["opcomFSM", _opcomFSM];
                _handler setvariable ["tacomFSM", _tacomFSM];
            };
            case ("invasion") : {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\opcom.fsm";
                //private _tacomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\tacom.fsm";
                private _tacomFSM = 723;

                _handler setvariable ["opcomFSM", _opcomFSM];
                _handler setvariable ["tacomFSM", _tacomFSM];
            };
            case ("asymmetric") : {
                private _opcomFSM = [_handler] execFSM "\x\alive\addons\mil_opcom\insurgency.fsm";

                _handler setvariable ["opcomFSM", _opcomFSM];
            };
        };

        // set startup complete and end loading screen if init has passed or an error occurred
        _logic setVariable ["startupComplete",true,true];

        _handler setvariable ["startupComplete", true];
    };

    case "sortObjectives": {
        _args params ["_objectives","_sortType"];

        _result = _objectives;
    };

    case "debug": {
        if (_args isequaltype true) then {
            _logic setvariable ["debug", _args];
        } else {
            _result = _logic getvariable "debug";
        };
    };

    case "objectives": {
        if (_args isequaltype []) then {
            _logic setvariable ["objectives", _args];
        } else {
            _args = _logic getvariable "objectives";
        };

        _result = _args;
    };

    case "destroy": {
        [_logic,"stop"] call MAINCLASS;

        OPCOM_instances deleteat (OPCOM_instances find _logic);

        private _module = _logic getvariable "moduleObject";

        private _group = group _module;
        deleteVehicle _module;
        deletegroup _group;
    };

    case "pause": {
        if (_args isequaltype true) then {
            private _opcomFSM = _logic getvariable "opcomFSM";
            private _tacomFSM = _logic getvariable "tacomFSM";

            _opcomFSM setFSMVariable ["pause", _args];
            _tacomFSM setFSMVariable ["pause", _args];

            _logic setvariable ["pause", _args];
        } else {
            _result = _logic getvariable "pause";
        };
    };

    case "stop": {
        private _opcomFSM = _logic getvariable "OPCOM_FSM";
        private _tacomFSM = _logic getvariable "TACOM_FSM";

        _opcomFSM setFSMvariable ["_exitFSM",true];
        _tacomFSM setFSMvariable ["_exitFSM",true];

        private _debug = _logic getvariable "debug";
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
