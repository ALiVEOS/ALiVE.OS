//#define DEBUG_MODE_FULL
#include "\x\ALiVE\addons\mil_opcom\script_component.hpp"
SCRIPT(commander);

/* ----------------------------------------------------------------------------
We don't know shit yet
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClass
#define MAINCLASS   ALiVE_fnc_commander

private "_result";

params [
    ["_logic", objNull, [objNull,[],""]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

switch (_operation) do {

    case "init": {

        if (!isserver) exitwith {};

        _logic setVariable ["super", "ALiVE_fnc_baseClass"];
        _logic setVariable ["class", "ALiVE_fnc_Commander"];
        _logic setVariable ["moduleType", "ALiVE_Commander"];


        private _controlType = _logic getvariable ["controltype", "invasion"];
        private _faction1 = _logic getvariable ["faction1", "OPF_F"];
        private _faction2 = _logic getvariable ["faction2", "NONE"];
        private _faction3 = _logic getvariable ["faction3", "NONE"];
        private _faction4 = _logic getvariable ["faction4", "NONE"];
        private _factions = (_logic getvariable ["factions", []]) call ALiVE_fnc_stringListToArray;

        private _debug = (_logic getvariable ["debug", "false"]) == "true";
        private _persistent = (_logic getvariable ["persistent", "false"]) == "true";
        private _reinforcements = parsenumber (_logic getvariable ["reinforcements","0.9"]);
        private _roadblocks = _logic getvariable ["roadblocks",true];

        private _modulePosition = getpos _logic;

        // wipe pre-set properties
        { _logic setvariable [_x, nil] } foreach (allvariables _logic);

        // if any factions were set in the dropdown fields
        // add them to the player-set faction array for single-source access

        private _dropdownFactions = [_faction1,_faction2,_faction3,_faction4];
        {
            if (_x != "NONE") then {
                _factions pushbackunique _x;
            };
        } foreach _dropdownFactions;
        _factions = _factions apply { tolower _x };

        // ensure this opcom is only commanding factions of a single side

        private _commandingSide = [ getnumber (((_factions select 0) call ALiVE_fnc_configGetFactionClass) >> "side") ] call ALiVE_fnc_sideNumberToText;
        private _commandingSideObject = [_commandingSide] call ALiVE_fnc_sideTextToObject;

        private _allSides = ["EAST","WEST","GUER"];
        private _sidesEnemy = (_allSides - [_commandingSide]) select {
            private _sideToCheck = _x;
            private _sideToCheckObject = [_sideToCheck] call ALiVE_fnc_sideTextToObject;
            private _isEnemy = _sideToCheckObject getfriend _commandingSideObject < 0.6;

            _isEnemy
        };
        private _sidesFriendly = _allSides - _sidesEnemy;

        // init logic object

        SET_PROPERTY(_logic,"id", "");
        SET_PROPERTY(_logic,"debug", _debug);
        SET_PROPERTY(_logic,"startupComplete", false);
        SET_PROPERTY(_logic,"position", _modulePosition);
        SET_PROPERTY(_logic,"persistent", _persistent);
        SET_PROPERTY(_logic,"controlType", _controlType);
        SET_PROPERTY(_logic,"reinforcementsLevel", _reinforcements);
        SET_PROPERTY(_logic,"side", _commandingSide);
        SET_PROPERTY(_logic,"sidesFriendly", _sidesFriendly);
        SET_PROPERTY(_logic,"sidesEnemy", _sidesEnemy);
        SET_PROPERTY(_logic,"factions", _factions);
        SET_PROPERTY(_logic,"objectivesByID", [] call CBA_fnc_createNamespace);
        SET_PROPERTY(_logic,"objectivesByPriorityOrder", []);

        private _personality = [[
            ["cautious", 0.5],
            ["aggressive", 0.5]
        ]] call ALiVE_fnc_hashCreate;
        SET_PROPERTY(_logic,"personality", _personality);

        private _opcom = [nil,"create", _logic] call ALiVE_fnc_opcom;
        [_opcom,"init"] call ALiVE_fnc_OPCOM;

        private _tacom = [nil,"create", _logic] call ALiVE_fnc_tacom;
        [_tacom,"init"] call ALiVE_fnc_TACOM;

        SET_PROPERTY(_logic,"opcom", _opcom);
        SET_PROPERTY(_logic,"tacom", _tacom);


        [_logic] spawn {
            params ["_logic"];

            // wait until commander has been registered with commander handler
            waituntil { GET_PROPERTY(_logic,"id") != "" };

            [_logic,"start"] call MAINCLASS;
        };

    };



    // getters/setters

    ADD_SIMPLE_ACCESSOR("id", "");
    ADD_SIMPLE_ACCESSOR("debug", true);
    ADD_SIMPLE_ACCESSOR("position", []);
    ADD_SIMPLE_ACCESSOR("persistent", true);
    ADD_SIMPLE_ACCESSOR("startupComplete", true);
    ADD_SIMPLE_ACCESSOR("controltype", "");
    ADD_SIMPLE_ACCESSOR("reinforcementsLevel", 0);
    ADD_SIMPLE_ACCESSOR("side", "");
    ADD_SIMPLE_ACCESSOR("sidesFriendly", []);
    ADD_SIMPLE_ACCESSOR("sidesEnemy", []);
    ADD_SIMPLE_ACCESSOR("factions", []);
    ADD_SIMPLE_ACCESSOR("objectivesByID", objNull);
    ADD_SIMPLE_ACCESSOR("objectivesByPriorityOrder", []);
    ADD_SIMPLE_ACCESSOR("personality", []);
    ADD_SIMPLE_ACCESSOR("opcom", []);
    ADD_SIMPLE_ACCESSOR("tacom", []);

    // getters/setters



    case "start": {

        waituntil { !(isnil "ALiVE_ProfileHandler") && { [ALiVE_ProfileSystem,"startupComplete", false] call ALiVE_fnc_hashGet }};

        // load objectives from synced modules

        private _startingObjectives = [_logic,"initObjectives"] call MAINCLASS;

        private _objectiveCount = count _startingObjectives;
        if (_objectiveCount == 0) then {
            private _factions = GET_PROPERTY(_logic,"factions");
            ["OPCOM that controls factions %1 has no objectives", _factions] call ALiVE_fnc_DumpR;
        } else {
            if (_objectiveCount > 120) then {
                ["PERFORMANCE WARNING: OPCOM that controls factions %1 has %2 objectives. Recommended maximum objective count is 120", _factions, _objectiveCount] call ALiVE_fnc_DumpR;
            };

            private _debug = GET_PROPERTY(_logic,"debug");
            if (_debug) then {
                private _factions = GET_PROPERTY(_logic,"factions");
                ["Commander controlling factions %1 starts with %2 objectives", _factions, _objectiveCount] call ALiVE_fnc_DumpR;
            };
        };

        private _opcom = GET_PROPERTY(_logic,"opcom");
        private _tacom = GET_PROPERTY(_logic,"tacom");

        [_opcom,"start"] call ALiVE_fnc_opcom;
        [_tacom,"start"] call ALiVE_fnc_tacom;

        SET_PROPERTY(_logic,"startupComplete", true);

    };

    case "getAllObjectives": {

        private _objectiveIDMap = GET_PROPERTY(_logic,"objectivesByID");

        _result = (allvariables _objectiveIDMap) apply { _objectiveIDMap getvariable _x };

    };

    case "addObjectives": {

        _args params ["_newObjectives", ["_moreObjectivesComing", false]];

        private _opcom = GET_PROPERTY(_logic,"opcom");
        private _objectiveIDMap = GET_PROPERTY(_logic,"objectivesByID");

        {
            private _objectiveID = [_x,"clusterID"] call ALiVE_fnc_hashGet;
            _objectiveIDMap setvariable [_objectiveID, _x];

            [_opcom,"initObjectiveState", _x] call ALiVE_fnc_opcom;
        } foreach _newObjectives;

        if (!_moreObjectivesComing) then {
            [_logic,"sortObjectives"] call MAINCLASS;
        };

    };

    case "removeObjectives": {

        _args params ["_objectives", ["_moreObjectivesComing", false]];

        private _objectiveIDMap = GET_PROPERTY(_logic,"objectivesByID");

        {
            private _objectiveID = [_x,"clusterID"] call ALiVE_fnc_hashGet;
            _objectiveIDMap setvariable [_objectiveID, nil];
        } foreach _newObjectives;

        if (!_moreObjectivesComing) then {
            [_logic,"sortObjectives"] call MAINCLASS;
        };

    };

    case "findAllProfilesUnderControl": {

        private _result = [];

        private _controlledFactions = GET_PROPERTY(_logic,"factions");
        {
            private _faction = _x;
            private _profilesForFaction = [ALiVE_profileHandler,"getProfilesByFaction", _faction] call ALiVE_fnc_profileHandler;

            _result append _profilesForFaction;
        } foreach _controlledFactions;

    };

    case "sortProfilesByType": {

        private _profileIDs = _args;

        private _infantry = [];
        private _motorized = [];
        private _aa = [];
        private _armored = [];
        private _air = [];
        private _sea = [];
        private _mechanized = [];
        private _artillery = [];

        {
            private _profileID = _x;
            private _profile = [ALiVE_profileHandler,"getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (!isnil "_profile") then {
                private _profileType = [_profile,"type"] call ALiVE_fnc_hashGet;

                switch (_profileType) do {
                    case "entity": {
                        private _assignedToVehicle = count (([_profile,"vehicleAssignments", ["",[],[],nil]] call ALiVE_fnc_hashGet) select 1);
                        private _unitClasses = [_profile,"unitClasses", []] call ALiVE_fnc_hashGet;

                        if (
                            !_assignedToVehicle &&
                            { !([_profile,"isPlayer", false] call ALiVE_fnc_hashGet) } &&
                            { { ((toLower _x) find "pilot") != -1 } count _unitClasses == 0 }   // no pilots in entity
                        ) then {
                            _infantry pushback _profileID;
                        };
                    };
                    case "vehicle": {
                        private _assignments = [_profile,"entitiesInCommandOf", []] call ALiVE_fnc_hashGet;

                        private _playerInAssignments = false;
                        {
                            private _assignment = [ALiVE_profileHandler,"getProfile", _x] call ALiVE_fnc_profileHandler;
                            if ([_assignment,"isPlayer", false] call ALiVE_fnc_hashGet) exitwith {
                                _playerInAssignments = true;
                            };
                        } foreach _assignments;
                        if (_playerInAssignments) exitwith {};

                        private _profileTypeSpecific = _profile call ALiVE_fnc_getProfileTypeSpecific;
                        switch (_profileTypeSpecific) do {
                            case "Car";
                            case "Truck": {
                                _motorized append _assignments;
                            };
                            case "armored": {
                                _mechanized append _assignments;
                            };
                            case "aa": {
                                _aa append _assignments;
                            };
                            case "artillery": {
                                _artillery append _assignments;
                            };
                            case "ship": {
                                _sea append _assignments;
                            };
                            // Since ATO is in place do not control air assets and pilots
                            //case "helicopter";
                            //case "plane": {
                            //    _air append _assignments;
                            //};
                        };
                    };
                };
            };
        } foreach _profileIDs;

        _result = [[
            ["infantry", _infantry],
            ["motorized", _motorized],
            ["mechanized", _mechanized],
            ["armored", _armored],
            ["artillery", _artillery],
            ["AAA", _aa],
            ["air", _air],
            ["sea", _sea]
        ]] call ALiVE_fnc_hashCreate;

    };

    case "initObjectives": {

        private _placementModules = ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_mil_placement_custom"];
        private _syncedModules = (synchronizedObjects _logic) select { (typeof _x) in _placementModules || { _syncedObject iskindof "LocationBase_F" }};
        private _syncedModulesCount = count _syncedModules;

        {
            private _syncedObject = _x;
            private _isLastObjectiveToAdd = _forEachIndex == _syncedModulesCount - 1;

            if ((typeof _syncedObject) in _placementModules) then {
                waituntil { _syncedObject getVariable ["startupComplete", false] };

                private _moduleObjectives = [_syncedObject,"objectives",objNull,[]] call ALiVE_fnc_OOsimpleOperation;

                [_logic,"addObjectives", [_moduleObjectives, !_isLastObjectiveToAdd]] call MAINCLASS;
            } else {
                // we can assume module is of type LocationBase_F

                private _center = getpos _syncedObject;
                private _type = getText( configfile >> "CfgVehicles" >> (typeof _syncedObject) >> "displayName");
                private _size = _syncedObject getvariable ["size", 150];
                private _priority = _syncedObject getvariable ["priority", 200];

                private _obj = [[
                    ["center", _center],
                    ["size", _size],
                    ["objectiveType", _type],
                    ["priority", _priority],
                    ["clusterID", ""]
                ]] call ALiVE_fnc_hashCreate;

                [_logic,"addObjectives", [[_obj], !_isLastObjectiveToAdd]] call MAINCLASS;
            };
        } foreach _syncedModules;

        _result = [_logic,"getAllObjectives"] call MAINCLASS;

    };

    case "sortObjectives": {

        private _filter = _args;

        if !(_filter isequaltype "") then { _filter = "" };

        if (_filter == "") then {
            private _controlType = GET_PROPERTY(_logic,"controlType");

            _filter = switch (_controlType) do {
                case "occupation"   : { "strategic" };
                case "invasion"     : { "distance" };
                case "asymmetric"   : { "asymmetric" };
            };
        };

        private _objectives = [_logic,"getAllObjectives"] call MAINCLASS;
        private _modulePosition = GET_PROPERTY(_logic,"position");

        switch (_filter) do {
            case "distance": {
                _objectives = [_objectives, [_logic], {
                    private _objectivePosition = _x select 2 select 2;
                    private _objectivePriority = _x select 2 select 5;

                    private _score = (_objectivePosition distance _modulePosition) - (_objectivePriority * 2.5);

                    _score * (1 - (random 0.25))
                }, "ASCEND"] call ALiVE_fnc_SortBy;
            };
            case "strategic": {
                _objectives = [_objectives, [_logic], {
                    private _objectivePosition = _x select 2 select 2;
                    private _objectivePriority = _x select 2 select 5;
                    private _objectiveSize = _x select 2 select 3;

                    private _score = (_objectivePosition distance _modulePosition) - (_objectivePriority * 6) - _objectiveSize;

                    _score * (1 - (random 0.25))
                }, "ASCEND"] call ALiVE_fnc_SortBy;
            };
            case "asymmetric": {

            };
        };

        private _debug = GET_PROPERTY(_logic,"debug");
        if (_debug) then {
            [_logic,"drawObjectiveDebugMarkers"] call MAINCLASS;
        };

        { [_x,"clusterID"] call ALiVE_fnc_hashGet } foreach _objectives;

        SET_PROPERTY(_logic,"objectivesByPriorityOrder", _objectives);

    };

    case "drawObjectiveDebugMarkers": {

        private _objectives = [_logic,"getAllObjectives"] call MAINCLASS;
        private _side = GET_PROPERTY(_logic,"side");
        private _sideColor = _side call ALiVE_fnc_sideTextToColor;

        {
            private _objectiveDebugMarkers = [_x,"debugMarkers"] call ALiVE_fnc_hashGet;
            { deleteMarker _x } foreach _objectiveDebugMarkers;

            private _objectiveID = [_x,"clusterID"] call ALiVE_fnc_HashGet;
            private _objectiveCenter = [_x,"center"] call ALiVE_fnc_HashGet;
            private _objectiveType = [_x,"type"] call ALiVE_fnc_hashGet;

            private _marker = createMarker [format ["alive_commander_objective_%1", _objectiveID], _objectiveCenter];
            _marker setmarkersize [0.7,0.7];
            _marker setmarkertext (format ["%1: #%2 - %3", _side, _forEachIndex, _objectiveType]);
            _marker setmarkercolor _sideColor;
            _marker setmarkertype "mil_dot";

            _objectiveDebugMarkers pushback _marker;
        } foreach _objectives;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

if !(isnil "_result") then {_result} else {nil};
