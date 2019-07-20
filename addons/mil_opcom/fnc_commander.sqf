//#define DEBUG_MODE_FULL
#include "\x\ALiVE\addons\mil_opcom\script_component.hpp"
SCRIPT(commander);

/* ----------------------------------------------------------------------------
We don't know shit yet
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
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

        // create commander object

        private _commander = [nil,"create"] call SUPERCLASS;
        [_commander,"moduleObject", _logic] call ALiVE_fnc_hashSet;
        [_commander,"id", ""] call ALiVE_fnc_hashSet;
        [_commander,"debug", _debug] call ALiVE_fnc_hashSet;
        [_commander,"position", _modulePosition] call ALiVE_fnc_hashSet;
        [_commander,"persistent", _persistent] call ALiVE_fnc_hashSet;
        [_commander,"controlType", _controlType] call ALiVE_fnc_hashSet;
        [_commander,"reinforcementsLevel", _reinforcements] call ALiVE_fnc_hashSet;
        [_commander,"side", _commandingSide] call ALiVE_fnc_hashSet;
        [_commander,"sidesFriendly", _sidesFriendly] call ALiVE_fnc_hashSet;
        [_commander,"sidesEnemy", _sidesEnemy] call ALiVE_fnc_hashSet;
        [_commander,"factions", _factions] call ALiVE_fnc_hashSet;
        [_commander,"objectives", []] call ALiVE_fnc_hashSet;

        private _personality = [
            [
                ["cautious", 0.5],
                ["aggressive", 0.5]
            ]
        ] call ALiVE_fnc_hashCreate;
        [_commander,"personality", _personality] call ALiVE_fnc_hashSet;

        private _opcom = [nil,"create"] call ALiVE_fnc_OPCOM;
        [_opcom,"init"] call ALiVE_fnc_OPCOM;

        private _tacom = [nil,"create"] call ALiVE_fnc_TACOM;
        [_tacom,"init"] call ALiVE_fnc_TACOM;

        [_commander,"opcom", _opcom] call ALiVE_fnc_hashSet;
        [_commander,"tacom", _tacom] call ALiVE_fnc_hashSet;

        [_commander,"startupComplete", false] call ALiVE_fnc_hashSet;

        _logic = _commander;

        _result = _logic;

        [_logic] spawn {
            params ["_logic"];

            // wait until commander has been registered with commander handler
            waituntil { ([_logic,"id"] call ALiVE_fnc_hashGet) != "" };

            [_logic,"start"] call MAINCLASS;
        };

    };

    case "start": {

        waituntil { !(isnil "ALiVE_ProfileHandler") && { [ALiVE_ProfileSystem,"startupComplete", false] call ALiVE_fnc_hashGet }};

        private _startingObjectives = [_logic,"initObjectives"] call MAINCLASS;

        private _objectiveCount = count _startingObjectives;
        if (_objectiveCount == 0) then {
            private _factions = [_logic,"factions"] call ALiVE_fnc_hashGet;
            ["OPCOM that controls factions %1 has no objectives", _factions] call ALiVE_fnc_DumpR;
        } else {
            if (_objectiveCount > 120) then {
                ["PERFORMANCE WARNING: OPCOM that controls factions %1 has %2 objectives. Recommended maximum objective count is 120", _factions, _objectiveCount] call ALiVE_fnc_DumpR;
            };

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;
            if (_debug) then {
                private _factions = [_logic,"factions"] call ALiVE_fnc_hashGet;
                ["Commander controlling factions %1 starts with %2 objectives", _factions, _objectiveCount] call ALiVE_fnc_DumpR;
            };
        };

        [_logic,"startupComplete", true] call ALiVE_fnc_hashSet;

    };

    case "sortObjectives": {

        _args params [["_filter",""]];

        private _objectives = [_logic,"objectives"] call MAINCLASS;

        if (_filter == "") then {
            private _controlType = [_logic,"controlType"] call ALiVE_fnc_hashGet;

            _filter = switch (_controlType) do {
                case "occupation"   : { "strategic" };
                case "invasion"     : { "distance" };
                case "asymmetric"   : { "asymmetric" };
            };
        };

        switch (_filter) do {
            case "distance": {

            };
            case "strategic": {

            };
            case "asymmetric": {

            };
        };

    };

    case "findAllProfilesUnderControl": {

        private _result = [];

        private _controlledFactions = [_logic,"factions"] call ALiVE_fnc_hashGet;
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

        private _moduleObject = [_logic,"moduleObject"] call ALiVE_fnc_hashGet;

        private _newObjectives = [];

        private _placementModules = ["ALiVE_mil_placement","ALiVE_civ_placement","ALiVE_mil_placement_custom"];

        {
            private _syncedObject = _x;

            if ((typeof _syncedObject) in _placementModules) then {
                waituntil { _syncedObject getVariable ["startupComplete", false] };

                private _moduleObjectives = [_syncedObject,"objectives",objNull,[]] call ALiVE_fnc_OOsimpleOperation;
                _newObjectives append _moduleObjectives;
            } else {
                if (_syncedObject iskindof "LocationBase_F") then {
                    private _type = getText( configfile >> "CfgVehicles" >> (typeof _syncedObject) >> "displayName");
                    private _size = _syncedObject getvariable ["size", 150];
                    private _priority = _syncedObject getvariable ["priority", 200];

                    private _obj = [[
                        ["center", getpos _syncedObject],
                        ["size", _size],
                        ["objectiveType", _type],
                        ["priority", _priority],
                        ["clusterID", ""]
                    ]] call ALiVE_fnc_hashCreate;

                    _newObjectives pushback _obj;
                };
            };
        } foreach (synchronizedObjects _moduleObject);

        private _objectives = [_logic,"objectives"] call ALiVE_fnc_hashGet;
        _objectives append _newObjectives;

        _result = _objectives;

    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

if !(isnil "_result") then {_result} else {nil};
