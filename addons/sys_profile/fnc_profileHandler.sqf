#include <\x\alive\addons\sys_profile\script_component.hpp>
SCRIPT(profileHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
The main profile handler / repository

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state
Hash - registerProfile - Profile hash to register on the handler
Hash - unregisterProfile - Profile hash to unregister on the handler
String - getProfile - Profile object id to get profile by
None - getProfiles
String - getProfilesByType - String profile type to get filtered array of profiles by
String - getProfilesBySide - String profile side to get filtered array of profiles by
String - getProfilesByVehicleType - String profile vehicle type to get filtered array of profiles by

Examples:
(begin example)
// create a profile handler
_logic = [nil, "create"] call ALIVE_fnc_profileHandler;

// init profile handler
_result = [_logic, "init"] call ALIVE_fnc_profileHandler;

// register a profile
_result = [_logic, "registerProfile", _profile] call ALIVE_fnc_profileHandler;

// unregister a profile
_result = [_logic, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;

// get a profile by id
_result = [_logic, "getProfile", "agent_01"] call ALIVE_fnc_profileHandler;

// get hash of all profiles
_result = [_logic, "getProfiles"] call ALIVE_fnc_profileHandler;

// get profiles by type
_result = [_logic, "getProfilesByType", "entity"] call ALIVE_fnc_profileHandler;

// get profiles by side
_result = [_logic, "getProfilesBySide", "WEST"] call ALIVE_fnc_profileHandler;

// get profiles by vehicle type
_result = [_logic, "getProfilesByVehicleType", "Car"] call ALIVE_fnc_profileHandler;

// get profiles by company
_result = [_logic, "getProfilesByCompany", "company_01"] call ALIVE_fnc_profileHandler;

// get object state
_state = [_logic, "state"] call ALIVE_fnc_profileHandler;
(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_profileHandler

private ["_result"];

TRACE_1("profileHandler - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

#define MTEMPLATE "ALiVE_PROFILEHANDLER_%1"

switch(_operation) do {

    case "init": {
        /*
        MODEL - no visual just reference data
        - nodes
        - center
        - size
        */

        if (isServer) then {
            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;
            TRACE_1("After module init",_logic);

            private _blankHash = [] call ALiVE_fnc_hashCreate;

            // set defaults
            [_logic,"debug", false] call ALIVE_fnc_hashSet;
            [_logic,"profiles", +_blankHash] call ALIVE_fnc_hashSet;
            [_logic,"profilesByCompany", +_blankHash] call ALIVE_fnc_hashSet;
            [_logic,"profilesActive", []] call ALIVE_fnc_hashSet;
            [_logic,"profilesInActive", []] call ALIVE_fnc_hashSet;
            [_logic,"entitiesActive", []] call ALIVE_fnc_hashSet;
            [_logic,"entitiesInActive", []] call ALIVE_fnc_hashSet;
            [_logic,"profilePositions", [] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"profileCount", 0] call ALIVE_fnc_hashSet;
            [_logic,"profileEntityCount", 0] call ALIVE_fnc_hashSet;
            [_logic,"profileVehicleCount", 0] call ALIVE_fnc_hashSet;
            [_logic,"playerEntities", _blankHash] call ALIVE_fnc_hashSet;
            [_logic,"playerIndex", _blankHash] call ALIVE_fnc_hashSet;

            private _profilesBySide = [
                [
                    ["EAST", []],
                    ["WEST", []],
                    ["GUER", []],
                    ["CIV", []]
                ]
            ] call ALIVE_fnc_hashCreate;
            [_logic,"profilesBySide", _profilesBySide] call ALIVE_fnc_hashSet;

            private _profilesBySideFull = [
                [
                    ["EAST", +_blankHash],
                    ["WEST", +_blankHash],
                    ["GUER", +_blankHash],
                    ["CIV", +_blankHash]
                ]
            ] call ALIVE_fnc_hashCreate;
            [_logic,"profilesBySideFull", _profilesBySideFull] call ALIVE_fnc_hashSet;

            _profilesActiveBySide = +_profilesBySideFull;
            [_logic,"profilesActiveBySide", _profilesActiveBySide] call ALIVE_fnc_hashSet;

            _profilesInActiveBySide = +_profilesBySideFull;
            [_logic,"profilesInActiveBySide", _profilesInActiveBySide] call ALIVE_fnc_hashSet;

            [_logic,"profilesByFaction", +_blankHash] call ALIVE_fnc_hashSet;
            [_logic,"profilesByFactionByType", +_blankHash] call ALIVE_fnc_hashSet;
            [_logic,"profilesByFactionByVehicleType", +_blankHash] call ALIVE_fnc_hashSet;

            private _profilesByType = [
                [
                    ["entity", []],
                    ["vehicle", []]
                ]
            ] call ALIVE_fnc_hashCreate;
            [_logic,"profilesByType", _profilesByType] call ALIVE_fnc_hashSet;

            private _profilesByVehicleType = [
                [
                    ["Car", []],
                    ["Tank", []],
                    ["Armored", []],
                    ["Truck", []],
                    ["Ship", []],
                    ["Helicopter", []],
                    ["Plane", []],
                    ["StaticWeapon", []],
                    ["Vehicle", []]
                ]
            ] call ALIVE_fnc_hashCreate;
            [_logic,"profilesByVehicleType", _profilesByVehicleType] call ALIVE_fnc_hashSet;

            _profilesByVehicleTypeEAST = +_profilesByVehicleType;
            [_profilesByVehicleTypeEAST,"Vehicle", []] call ALIVE_fnc_hashSet;

            _profilesByVehicleTypeWEST = +_profilesByVehicleType;
            [_profilesByVehicleTypeWEST,"Vehicle", []] call ALIVE_fnc_hashSet;

            _profilesByVehicleTypeGUER = +_profilesByVehicleType;
            [_profilesByVehicleTypeGUER,"Vehicle", []] call ALIVE_fnc_hashSet;

            _profilesByVehicleTypeCIV = +_profilesByVehicleType;
            [_profilesByVehicleTypeCIV,"Vehicle", []] call ALIVE_fnc_hashSet;

            _profilesByTypeEAST = +_profilesByType;
            _profilesByTypeWEST = +_profilesByType;
            _profilesByTypeGUER = +_profilesByType;
            _profilesByTypeCIV = +_profilesByType;

            private _catagoriesEAST = [
                [
                    ["type", _profilesByTypeEAST],
                    ["vehicleType", _profilesByVehicleTypeEAST]
                ]
            ] call ALIVE_fnc_hashCreate;

            private _catagoriesWEST = [
                [
                    ["type", _profilesByTypeWEST],
                    ["vehicleType", _profilesByVehicleTypeWEST]
                ]
            ] call ALIVE_fnc_hashCreate;

            private _catagoriesGUER = [
                [
                    ["type", _profilesByTypeGUER],
                    ["vehicleType", _profilesByVehicleTypeGUER]
                ]
            ] call ALIVE_fnc_hashCreate;

            private _catagoriesCIV = [
                [
                    ["type", _profilesByTypeCIV],
                    ["vehicleType", _profilesByVehicleTypeCIV]
                ]
            ] call ALIVE_fnc_hashCreate;

            private _profilesCatagorised = [
                [
                    ["EAST", _catagoriesEAST],
                    ["WEST", _catagoriesWEST],
                    ["GUER", _catagoriesGUER],
                    ["CIV", _catagoriesCIV]
                ]
            ] call ALIVE_fnc_hashCreate;
            [_logic,"profilesCatagorised",_profilesCatagorised] call ALIVE_fnc_hashSet;
        };

        /*
        VIEW - purely visual
        */

        /*
        CONTROLLER  - coordination
        */
    };

    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;

        if (isServer) then {
            [_logic, "destroy"] call SUPERCLASS;
        };
    };

    case "debug": {
        if !(_args isEqualType true) then {
            _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
            [_logic,"debug", _args] call ALIVE_fnc_hashSet;
        };

        private _profiles = [_logic,"profiles"] call ALIVE_fnc_hashGet;

        if !(_profiles isEqualTo []) then {
            {
                switch([_x,"type"] call ALIVE_fnc_hashGet) do {
                    case "entity": {
                        [_x,"debug", false] call ALIVE_fnc_profileEntity;
                    };
                    case "vehicle": {
                        [_x,"debug", false] call ALIVE_fnc_profileVehicle;
                    };
                };
            } forEach (_profiles select 2);

            if (_args) then {
                {
                    switch([_x, "type"] call ALIVE_fnc_hashGet) do {
                        case "entity": {
                            [_x,"debug", true] call ALIVE_fnc_profileEntity;
                        };
                        case "vehicle": {
                            [_x,"debug", true] call ALIVE_fnc_profileVehicle;
                        };
                    };
                } forEach (_profiles select 2);

                // DEBUG -------------------------------------------------------------------------------------
                //["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
                //["ALIVE Profile Handler State"] call ALIVE_fnc_dump;
                //_state = [_logic, "state"] call MAINCLASS;
                //_state call ALIVE_fnc_inspectHash;
                // DEBUG -------------------------------------------------------------------------------------
            };
        };

        _result = _args;
    };

    case "state": {
        if !(_args isEqualTo []) then {
            // Save state

            private _state = [] call ALIVE_fnc_hashCreate;

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

            // loop the passed hash and set vars on the class hash
            {
                [_logic,_x,[_args,_x] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
            } forEach (_args select 1);
        };
    };

    case "registerProfile": {
        if (_args isEqualType []) then {
            private _profile = _args;

            private _profiles = [_logic,"profiles"] call ALIVE_fnc_hashGet;
            private _profilesByType = [_logic,"profilesByType"] call ALIVE_fnc_hashGet;
            private _profilesCatagorised = [_logic,"profilesCatagorised"] call ALIVE_fnc_hashGet;
            private _profilePositions = [_logic,"profilePositions"] call ALIVE_fnc_hashGet;

            private _profileSide = [_profile,"side"] call ALIVE_fnc_hashGet;
            private _profileID = [_profile,"profileID"] call ALIVE_fnc_hashGet;
            private _profileType = [_profile,"type"] call ALIVE_fnc_hashGet;
            private _profilePosition = [_profile,"position"] call ALIVE_fnc_hashGet;

            // insert into spacial grid
            private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
            [_spacialGrid,"insert", [[_profilePosition,_profile]]] call ALiVE_fnc_spacialGrid;

            private _profilesCatagorisedSide = [_profilesCatagorised, _profileSide] call ALIVE_fnc_hashGet;

            if (isnil "_profilesCatagorisedSide") exitwith {["ALIVE Error on detecting correct side #hash for profile %1",_profileID] call ALiVE_fnc_Dump};

            // store on main profiles hash
            [_profiles, _profileID, _profile] call ALIVE_fnc_hashSet;

            // store the position in the position index
            [_profilePositions, _profileID, _profilePosition] call ALIVE_fnc_hashSet;

            // store reference to main profile on by type hash
            _profilesType = [_profilesByType, _profileType] call ALIVE_fnc_hashGet;
            _profilesType pushback _profileID;

            // store reference to main profile on by catagorised type hash
            private _profilesCatagorisedTypes = [_profilesCatagorisedSide, "type"] call ALIVE_fnc_hashGet;
            _profilesCatagorisedType = [_profilesCatagorisedTypes, _profileType] call ALIVE_fnc_hashGet;
            _profilesCatagorisedType pushback _profileID;


            // DEBUG -------------------------------------------------------------------------------------
            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                switch(_profileType) do {
                    case "entity": {
                        [_profile,"debug", true] call ALIVE_fnc_profileEntity;
                    };
                    case "vehicle": {
                        [_profile,"debug", true] call ALIVE_fnc_profileVehicle;
                    };
                };
                ["ALIVE Profile Handler - Register Profile [%1]",_profileID] call ALIVE_fnc_dump;
                //_profile call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------


            if (_profileType in ["entity","vehicle","civ"]) then {

                // store reference to main profile on by side hash
                private _profilesBySide = [_logic,"profilesBySide"] call ALIVE_fnc_hashGet;
                private _profilesSide = [_profilesBySide, _profileSide] call ALIVE_fnc_hashGet;
                _profilesSide pushback _profileID;

                // store profile on side hash
                private _profilesBySideFull = [_logic,"profilesBySideFull"] call ALIVE_fnc_hashGet;
                private _profilesSideFull = [_profilesBySideFull, _profileSide] call ALIVE_fnc_hashGet;
                [_profilesSideFull, _profileID, _profile] call ALIVE_fnc_hashSet;

                private ["_profilesFactionType","_profilesFactionVehicleType"];

                // store reference to main profile on by faction hash

                private _profileFaction = [_profile,"faction"] call ALIVE_fnc_hashGet;

                private _profilesByFaction = [_logic,"profilesByFaction"] call ALIVE_fnc_hashGet;
                private _profilesFaction = [_profilesByFaction, _profileFaction] call ALIVE_fnc_hashGet;

                private _profilesByFactionByType = [_logic,"profilesByFactionByType"] call ALIVE_fnc_hashGet;
                private _profilesByFactionByVehicleType = [_logic,"profilesByFactionByVehicleType"] call ALIVE_fnc_hashGet;

                if (!isnil "_profilesFaction") then {
                    _profilesFactionType = [_profilesByFactionByType, _profileFaction] call ALIVE_fnc_hashGet;
                    _profilesFactionVehicleType = [_profilesByFactionByVehicleType, _profileFaction] call ALIVE_fnc_hashGet;
                } else {
                    _profilesFaction = [];
                    [_profilesByFaction, _profileFaction, _profilesFaction] call ALIVE_fnc_hashSet;

                    _profilesFactionType = [
                        [
                            ["entity", []],
                            ["vehicle", []]
                        ]
                    ] call ALIVE_fnc_hashCreate;
                    [_profilesByFactionByType, _profileFaction, _profilesFactionType] call ALIVE_fnc_hashSet;

                    _profilesFactionVehicleType = [
                        [
                            ["Car", []],
                            ["Tank", []],
                            ["Armored", []],
                            ["Truck", []],
                            ["Ship", []],
                            ["Helicopter", []],
                            ["Plane", []],
                            ["StaticWeapon", []],
                            ["Vehicle", []]
                        ]
                    ] call ALIVE_fnc_hashCreate;
                    [_profilesByFactionByVehicleType, _profileFaction, _profilesFactionVehicleType] call ALIVE_fnc_hashSet;
                };

                _profilesFaction pushback _profileID;

                private _profileFactionType = [_profilesFactionType, _profileType] call ALIVE_fnc_hashGet;
                _profileFactionType pushback _profileID;

                if ([_profile, "active"] call ALIVE_fnc_hashGet) then {
                    private _profilesActive = [_logic,"profilesActive"] call ALIVE_fnc_hashGet;
                    _profilesActive pushback _profileID;

                    // store profile on side hash
                    private _profilesActiveBySide = [_logic,"profilesActiveBySide"] call ALIVE_fnc_hashGet;
                    private _profilesActiveSide = [_profilesActiveBySide, _profileSide] call ALIVE_fnc_hashGet;
                    [_profilesActiveSide, _profileID, _profile] call ALIVE_fnc_hashSet;

                    if (_profileType == "entity") then {
                        private _entityProfilesActive = [_logic,"entitiesActive"] call ALIVE_fnc_hashGet;
                        _entityProfilesActive pushback _profileID;
                    };
                } else {
                    private _profilesInActive = [_logic,"profilesInActive"] call ALIVE_fnc_hashGet;
                    _profilesInActive pushback _profileID;

                    // store profile on side hash
                    private _profilesInActiveBySide = [_logic,"profilesInActiveBySide"] call ALIVE_fnc_hashGet;
                    private _profilesInActiveSide = [_profilesInActiveBySide, _profileSide] call ALIVE_fnc_hashGet;
                    [_profilesInActiveSide, _profileID, _profile] call ALIVE_fnc_hashSet;

                    if (_profileType == "entity") then {
                        private _entityProfilesInActive = [_logic,"entitiesInActive"] call ALIVE_fnc_hashGet;
                        _entityProfilesInActive pushback _profileID;
                    };
                };

                if (_profileType != "vehicle") then {

                    // if player entity
                    if ([_profile,"isPlayer"] call ALIVE_fnc_hashGet) then {
                        private _playerEntities = [_logic,"playerEntities"] call ALIVE_fnc_hashGet;
                        [_playerEntities, _profileID, _profile] call ALIVE_fnc_hashSet;
                    };

                    // if company id is set
                    private _profileCompany = [_profile,"companyID"] call ALIVE_fnc_hashGet;
                    if (_profileCompany != "") then {
                        private _profilesByCompany = [_logic,"profilesByCompany"] call ALIVE_fnc_hashGet;
                        private _profleByCompanyArray = [_profilesByCompany, _profileCompany] call ALIVE_fnc_hashGet;

                        if (isnil "_profleByCompanyArray") then {
                            [_profilesByCompany, _profileCompany, [_profileID]] call ALIVE_fnc_hashSet;
                        } else {
                            _profleByCompanyArray pushback _profileID;
                        };
                    };
                } else {
                    private _profileVehicleType = [_profile,"objectType"] call ALIVE_fnc_hashGet;

                    // vehicle type
                    private _profilesByVehicleType = [_logic,"profilesByVehicleType"] call ALIVE_fnc_hashGet;
                    private _profilesVehicleType = [_profilesByVehicleType,_profileVehicleType] call ALIVE_fnc_hashGet;
                    _profilesVehicleType pushback _profileID;

                    private _profileFactionVehicleType = [_profilesFactionVehicleType,_profileVehicleType] call ALIVE_fnc_hashGet;
                    _profileFactionVehicleType pushback _profileID;

                    private _profilesCatagorisedVehicleTypes = [_profilesCatagorisedSide,"vehicleType"] call ALIVE_fnc_hashGet;
                    private _profilesCatagorisedVehicleType = [_profilesCatagorisedVehicleTypes, _profileVehicleType] call ALIVE_fnc_hashGet;
                    _profilesCatagorisedVehicleType pushback _profileID;
                };
            };
        };
    };

    case "unregisterProfile": {
        if (_args isEqualType "") then {_args = [_logic,"getProfile", _args] call MAINCLASS};

        if (_args isEqualType []) then {
            private _profile = _args;

            private _profiles = [_logic,"profiles"] call ALIVE_fnc_hashGet;
            private _profilesByType = [_logic,"profilesByType"] call ALIVE_fnc_hashGet;
            private _profilesCatagorised = [_logic,"profilesCatagorised"] call ALIVE_fnc_hashGet;
            private _profilePositions = [_logic,"profilePositions"] call ALIVE_fnc_hashGet;

            private _profileSide = [_profile,"side"] call ALIVE_fnc_hashGet;
            private _profileID = [_profile,"profileID"] call ALIVE_fnc_hashGet;
            private _profileType = [_profile,"type"] call ALIVE_fnc_hashGet;
            private _profilePosition = [_profile,"position"] call ALIVE_fnc_hashGet;

            // remove from spacial grid
            private _spacialGrid = [ALiVE_profileSystem,"spacialGridProfiles"] call ALiVE_fnc_hashGet;
            [_spacialGrid,"remove", [_profilePosition,_profile]] call ALiVE_fnc_spacialGrid;

            private _profilesCatagorisedSide = [_profilesCatagorised, _profileSide] call ALIVE_fnc_hashGet;
            private _profilesCatagorisedTypes = [_profilesCatagorisedSide, "type"] call ALIVE_fnc_hashGet;
            private _profilesCatagorisedVehicleTypes = [_profilesCatagorisedSide, "vehicleType"] call ALIVE_fnc_hashGet;

            // remove on main profiles hash
            [_profiles, _profileID] call ALIVE_fnc_hashRem;

            // remove from position index
            [_profilePositions, _profileID] call ALIVE_fnc_hashRem;

            // remove reference to main profile on by type hash
            private _profilesType = [_profilesByType, _profileType] call ALIVE_fnc_hashGet;
            _profilesType deleteat (_profilesType find _profileID);

            // remove reference to main profile on by catagorised type hash
            private _profilesCatagorisedType = [_profilesCatagorisedTypes, _profileType] call ALIVE_fnc_hashGet;
            _profilesCatagorisedType deleteat (_profilesCatagorisedType find _profileID);

            // disable debugging on the profile
            if([_profile, "debug"] call ALIVE_fnc_hashGet) then {
                switch(_profileType) do {
                    case "entity": {
                        _result = [_profile,"debug", false] call ALIVE_fnc_profileEntity;
                    };
                    case "civ": {
                        _result = [_profile,"debug", false] call ALIVE_fnc_profileCiv;
                    };
                    case "vehicle": {
                        _result = [_profile,"debug", false] call ALIVE_fnc_profileVehicle;
                    };
                };
            };

            // DEBUG -------------------------------------------------------------------------------------
            if([_logic,"debug"] call ALIVE_fnc_hashGet) then {
                ["ALIVE Profile Handler - Un-Register Profile [%1]",_profileID] call ALIVE_fnc_dump;
                //_profile call ALIVE_fnc_inspectHash;
            };
            // DEBUG -------------------------------------------------------------------------------------

            if (_profileType in ["entity","vehicle","mil"]) then {
                private _profileFaction = [_profile,"faction"] call ALIVE_fnc_hashGet;
                private _profilesBySide = [_logic,"profilesBySide"] call ALIVE_fnc_hashGet;

                // remove reference to main profile on by side hash
                private _profilesSide = [_profilesBySide, _profileSide] call ALIVE_fnc_hashGet;
                _profilesSide deleteat (_profilesSide find _profileID);

                // remove profile on full side hash
                private _profilesBySideFull = [_logic,"profilesBySideFull"] call ALIVE_fnc_hashGet;
                private _profilesSide = [_profilesBySideFull, _profileSide] call ALIVE_fnc_hashGet;
                [_profilesSide, _profileID] call ALIVE_fnc_hashRem;

                // remove reference to main profile on by faction hash
                private _profilesByFaction = [_logic,"profilesByFaction"] call ALIVE_fnc_hashGet;
                private _profilesFaction = [_profilesByFaction, _profileFaction] call ALIVE_fnc_hashGet;
                _profilesFaction deleteat (_profilesFaction find _profileID);

                private _profilesByFactionByType = [_logic,"profilesByFactionByType"] call ALIVE_fnc_hashGet;
                private _profilesFactionType = [_profilesByFactionByType, _profileFaction] call ALIVE_fnc_hashGet;
                private _profileFactionType = [_profilesFactionType, _profileType] call ALIVE_fnc_hashGet;
                _profileFactionType deleteat (_profileFactionType find _profileID);

                private _profilesByFactionByVehicleType = [_logic,"profilesByFactionByVehicleType"] call ALIVE_fnc_hashGet;
                private _profilesFactionVehicleType = [_profilesByFactionByVehicleType, _profileFaction] call ALIVE_fnc_hashGet;

                if ([_profile, "active"] call ALIVE_fnc_hashGet) then {
                    // Remove ProfileID if any units are left
                    private _vehicle = [_profile,"vehicle"] call ALIVE_fnc_hashGet;
                    if !(isnil "_vehicle") then {_vehicle setvariable ["ProfileID",nil]};

                    private _units = [_profile,"units",[]] call ALIVE_fnc_hashGet;
                    if (count _units > 0) then {
                        {_x setVariable ["ProfileID",nil];
                    } foreach (units group (_units select 0))};

                    private _profilesActive = [_logic,"profilesActive"] call ALIVE_fnc_hashGet;
                    _profilesActive deleteat (_profilesActive find _profileID);

                    private _profilesActiveBySide = [_logic,"profilesActiveBySide"] call ALIVE_fnc_hashGet;
                    private _profilesActiveSide = [_profilesActiveBySide, _profileSide] call ALIVE_fnc_hashGet;
                    [_profilesActiveSide, _profileID] call ALIVE_fnc_hashRem;

                    if (_profileType == "entity") then {
                        private _entityProfilesActive = [_logic,"entitiesActive"] call ALIVE_fnc_hashGet;
                        _entityProfilesActive deleteat (_entityProfilesActive find _profileID);
                    };
                } else {
                    private _profilesInActiveBySide = [_logic,"profilesInActiveBySide"] call ALIVE_fnc_hashGet;
                    private _profilesInActive = [_logic,"profilesInActive"] call ALIVE_fnc_hashGet;

                    _profilesInActive deleteat (_profilesInActive find _profileID);

                    private _profilesInActiveSide = [_profilesInActiveBySide, _profileSide] call ALIVE_fnc_hashGet;
                    [_profilesInActiveSide, _profileID] call ALIVE_fnc_hashRem;

                    if (_profileType == "entity") then {
                        private _entityProfilesInActive = [_logic,"entitiesInActive"] call ALIVE_fnc_hashGet;
                        _entityProfilesInActive deleteat (_entityProfilesInActive find _profileID);
                    };
                };

                if (_profileType != "vehicle") then {
                    if([_profile,"isPlayer"] call ALIVE_fnc_hashGet) then {
                        private _playerEntities = [_logic,"playerEntities"] call ALIVE_fnc_hashGet;
                        [_playerEntities, _profileID] call ALIVE_fnc_hashRem;
                    };

                    // if company id is set
                    private _profileCompany = [_profile,"companyID"] call ALIVE_fnc_hashGet;
                    if (_profileCompany != "") then {
                        private _profilesByCompany = [_logic,"profilesByCompany"] call ALIVE_fnc_hashGet;
                        private _profleByCompanyArray = [_profilesByCompany, _profileCompany] call ALIVE_fnc_hashGet;
                        _profleByCompanyArray deleteat (_profleByCompanyArray find _profileID);
                    };
                } else {
                    private _profileVehicleType = [_profile,"objectType"] call ALIVE_fnc_hashGet;

                    // vehicle type
                    private _profilesByVehicleType = [_logic,"profilesByVehicleType"] call ALIVE_fnc_hashGet;
                    private _profilesVehicleType = [_profilesByVehicleType, _profileVehicleType] call ALIVE_fnc_hashGet;
                    _profilesVehicleType deleteat (_profilesVehicleType find _profileID);

                    private _profilesFactionVehicleType = [_profilesByFactionByVehicleType, _profileFaction] call ALIVE_fnc_hashGet;
                    _profileFactionVehicleType = [_profilesFactionVehicleType, _profileVehicleType] call ALIVE_fnc_hashGet;
                    _profileFactionVehicleType deleteat (_profileFactionVehicleType find _profileID);

                    private _profilesCatagorisedVehicleType = [_profilesCatagorisedVehicleTypes, _profileVehicleType] call ALIVE_fnc_hashGet;
                    _profilesCatagorisedVehicleType deleteat (_profilesCatagorisedVehicleType find _profileID);
                };
            };
        };
    };

    case "setActive": {
        private _profileID = _args select 0;
        private _side = _args select 1;
        private _profile = _args select 2;

        private _profilesInActive = [_logic, "profilesInActive"] call ALIVE_fnc_hashGet;
        private _profilesActive = [_logic, "profilesActive"] call ALIVE_fnc_hashGet;

        private _inactiveIndex = _profilesInActive find _profileID;
        if (_inactiveIndex != -1) then {
            _profilesInActive deleteat _inactiveIndex;
        };

        _profilesActive pushback _profileID;

        private _profilesActiveBySide = [_logic, "profilesActiveBySide"] call ALIVE_fnc_hashGet;
        private _profilesInActiveBySide = [_logic, "profilesInActiveBySide"] call ALIVE_fnc_hashGet;

        private _profilesInActiveSide = [_profilesInActiveBySide, _side] call ALIVE_fnc_hashGet;

        [_profilesInActiveSide, _profileID] call ALIVE_fnc_hashRem;

        private _profilesActiveSide = [_profilesActiveBySide, _side] call ALIVE_fnc_hashGet;
        [_profilesActiveSide, _profileID, _profile] call ALIVE_fnc_hashSet;
    };

    case "setInActive": {
        private _profileID = _args select 0;
        private _side = _args select 1;
        private _profile = _args select 2;

        private _profilesInActive = [_logic,"profilesInActive"] call ALIVE_fnc_hashGet;
        private _profilesActive = [_logic,"profilesActive"] call ALIVE_fnc_hashGet;

        private _activeIndex = _profilesActive find _profileID;
        if(_activeIndex != -1) then {
            _profilesActive deleteat _activeIndex;
        };

        _profilesInActive pushback _profileID;

        private _profilesActiveBySide = [_logic,"profilesActiveBySide"] call ALIVE_fnc_hashGet;
        private _profilesInActiveBySide = [_logic,"profilesInActiveBySide"] call ALIVE_fnc_hashGet;

        private _profilesActiveSide = [_profilesActiveBySide, _side] call ALIVE_fnc_hashGet;

        [_profilesActiveSide, _profileID] call ALIVE_fnc_hashRem;

        private _profilesInActiveSide = [_profilesInActiveBySide, _side] call ALIVE_fnc_hashGet;
        [_profilesInActiveSide, _profileID, _profile] call ALIVE_fnc_hashSet;
    };

    case "getPlayerEntities": {
        _result = [_logic,"playerEntities"] call ALIVE_fnc_hashGet;
    };

    case "getPlayerIndex":{
        _result = [_logic,"playerIndex"] call ALIVE_fnc_hashGet;
    };

    case "getActive": {
        _result = [_logic,"profilesActive"] call ALIVE_fnc_hashGet;
    };

    case "getInActive": {
        _result = [_logic,"profilesInActive"] call ALIVE_fnc_hashGet;
    };

    case "getActiveBySide": {
        private _profilesActiveBySide = [_logic, "profilesActiveBySide"] call ALIVE_fnc_hashGet;
        _result = [_profilesActiveBySide, _args] call ALIVE_fnc_hashGet;
    };

    case "getInActiveBySide": {
        private _side = _args;

        private _profilesInActiveSide = [_logic, "profilesInActiveBySide"] call ALIVE_fnc_hashGet;
        _result = [_profilesInActiveSide, _side] call ALIVE_fnc_hashGet;
    };

    case "setEntityActive": {
        private _profileID = _args;

        private _entityProfilesActive = [_logic, "entitiesActive"] call ALIVE_fnc_hashGet;
        private _entityProfilesInActive = [_logic, "entitiesInActive"] call ALIVE_fnc_hashGet;

        private _inactiveIndex = _entityProfilesInActive find _profileID;
        if (_inactiveIndex != -1) then {
            _entityProfilesInActive deleteat _inactiveIndex;
        };

        _entityProfilesActive pushback _profileID;
    };

    case "setEntityInActive": {
        private _profileID = _args;

        private _entityProfilesActive = [_logic,"entitiesActive"] call ALIVE_fnc_hashGet;
        private _entityProfilesInActive = [_logic,"entitiesInActive"] call ALIVE_fnc_hashGet;

        private _activeIndex = _entityProfilesActive find _profileID;
        if (_activeIndex != -1) then {
            _entityProfilesActive deleteat _activeIndex;
        };

        _entityProfilesInActive pushback _profileID;
    };

    case "getActiveEntities": {
        _result = [_logic, "entitiesActive"] call ALIVE_fnc_hashGet;
    };

    case "getInActiveEntities": {
        _result = [_logic, "entitiesInActive"] call ALIVE_fnc_hashGet;
    };

    case "getInActiveEntitiesForMarking": {
        private _entities = [_logic, "entitiesInActive"] call ALIVE_fnc_hashGet;
        _result = [];

        {
            private _profile = [ALIVE_profileHandler,"getProfile", _x] call ALIVE_fnc_profileHandler;

            if !(isNil "_profile") then {
                private _position = _profile select 2 select 2;
                private _side = _profile select 2 select 3;

                _result pushback [_position,_side];
            };
        } forEach _entities;
    };

    case "setPosition": {
        private _profileID = _args select 0;
        private _position = _args select 1;

        private _profilePositions = [_logic,"profilePositions"] call ALIVE_fnc_hashGet;
        [_profilePositions, _profileID, _position] call ALIVE_fnc_hashSet;
    };

    case "getProfile": {
        if (_args isEqualType "") then {
            private _profiles = [_logic, "profiles"] call ALIVE_fnc_hashGet;
            private _index = (_profiles select 1) find _args;

            if (_index != -1) then {
                _result = (_profiles select 2) select _index;
            };
        };
    };

    case "getProfiles": {
        _result = [_logic, "profiles"] call ALIVE_fnc_hashGet;
    };

    case "getProfilesByType": {
        if (_args isEqualType "") then {
            private _profilesByType = [_logic, "profilesByType"] call ALIVE_fnc_hashGet;

            _result = [_profilesByType, _args] call ALIVE_fnc_hashGet;
        };

    };

    case "getProfilesBySide": {
        if (_args isEqualType "") then {
            private _profilesBySide = [_logic, "profilesBySide"] call ALIVE_fnc_hashGet;

            _result = [_profilesBySide, _args] call ALIVE_fnc_hashGet;
        };
    };

    case "getProfilesBySideFull": {
        if (_args isEqualType "") then {
            private _profilesBySideFull = [_logic, "profilesBySideFull"] call ALIVE_fnc_hashGet;

            _result = [_profilesBySideFull, _args] call ALIVE_fnc_hashGet;
        };
    };

    case "getProfilesByFaction": {
        if (_args isEqualType "") then {
            private _profilesByFaction = [_logic, "profilesByFaction"] call ALIVE_fnc_hashGet;

            _result = [_profilesByFaction, _args, []] call ALIVE_fnc_hashGet;
        };
    };

    case "getProfilesByFactionByType": {
        private _faction = _args select 0;
        private _type = _args select 1;

        private _profilesByFactionByType = [_logic, "profilesByFactionByType"] call ALIVE_fnc_hashGet;
        private _profilesFactionType = [_profilesByFactionByType, _faction] call ALIVE_fnc_hashGet;

        _result = [_profilesFactionType, _type] call ALIVE_fnc_hashGet;
    };

    case "getProfilesByFactionByVehicleType": {
        private _faction = _args select 0;
        private _type = _args select 1;

        private _profilesByFactionByVehicleType = [_logic, "profilesByFactionByVehicleType"] call ALIVE_fnc_hashGet;
        private _profilesFactionType = [_profilesByFactionByVehicleType, _faction] call ALIVE_fnc_hashGet;

        _result = [_profilesFactionType, _type] call ALIVE_fnc_hashGet;
    };

    case "getFactionBreakdown": {
        private["_faction","_factionProfiles","_factionEntityProfiles","_factionVehicleProfiles","_factionVehicleCars","_factionVehicleTanks","_factionVehicleArmoured",
        "_factionVehicleTruck","_factionVehicleShips","_factionVehicleHelicopters","_factionVehiclePlane","_breakdown","_factionVehicleArmored"];

        if (typeName _args == "STRING") then {
            _faction = _args;

            _factionProfiles = [ALIVE_profileHandler, "getProfilesByFaction", _faction] call ALIVE_fnc_profileHandler;

            _factionEntityProfiles = [ALIVE_profileHandler, "getProfilesByFactionByType", [_faction,'entity']] call ALIVE_fnc_profileHandler;
            _factionVehicleProfiles = [ALIVE_profileHandler, "getProfilesByFactionByType", [_faction,'vehicle']] call ALIVE_fnc_profileHandler;

            _factionVehicleCars = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Car']] call ALIVE_fnc_profileHandler;
            _factionVehicleTanks = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Tank']] call ALIVE_fnc_profileHandler;
            _factionVehicleArmored = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Armored']] call ALIVE_fnc_profileHandler;
            _factionVehicleTruck = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Truck']] call ALIVE_fnc_profileHandler;
            _factionVehicleShips = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Ship']] call ALIVE_fnc_profileHandler;
            _factionVehicleHelicopters = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Helicopter']] call ALIVE_fnc_profileHandler;
            _factionVehiclePlane = [ALIVE_profileHandler, "getProfilesByFactionByVehicleType", [_faction,'Plane']] call ALIVE_fnc_profileHandler;

            _breakdown = [] call ALIVE_fnc_hashCreate;
            [_breakdown, "total", count _factionProfiles] call ALIVE_fnc_hashSet;
            [_breakdown, "entity", count _factionEntityProfiles] call ALIVE_fnc_hashSet;
            [_breakdown, "vehicle", count _factionVehicleProfiles] call ALIVE_fnc_hashSet;
            [_breakdown, "car", count _factionVehicleCars] call ALIVE_fnc_hashSet;
            [_breakdown, "tank", count _factionVehicleTanks] call ALIVE_fnc_hashSet;
            [_breakdown, "armor", count _factionVehicleArmored] call ALIVE_fnc_hashSet;
            [_breakdown, "truck", count _factionVehicleTruck] call ALIVE_fnc_hashSet;
            [_breakdown, "ship", count _factionVehicleShips] call ALIVE_fnc_hashSet;
            [_breakdown, "helicopters", count _factionVehicleHelicopters] call ALIVE_fnc_hashSet;
            [_breakdown, "plane", count _factionVehiclePlane] call ALIVE_fnc_hashSet;

            _result = _breakdown;
        };
    };

    case "getProfilesByVehicleType": {
        if (_args isEqualType "") then {
            private _profilesByVehicleType = [_logic, "profilesByVehicleType"] call ALIVE_fnc_hashGet;

            _result = [_profilesByVehicleType, _args] call ALIVE_fnc_hashGet;
        };
    };

    case "getProfilesByCompany": {
        if (_args isEqualType "") then {
            private _profilesByCompany = [_logic,"profilesByCompany"] call ALIVE_fnc_hashGet;

            _result = [_profilesByCompany, _args] call ALIVE_fnc_hashGet;
        };
    };

    case "getProfilesByCategory": {
        private _side = _args select 0;
        private _type = _args select 1;
        private _vehicleType = param [2, "none"];

        private _profilesCatagorised = [_logic,"profilesCatagorised"] call ALIVE_fnc_hashGet;

        if (_vehicleType == "none") then {
            // return the sides type
            _result = [[[_profilesCatagorised, _side] call ALIVE_fnc_hashGet,"type"] call ALIVE_fnc_hashGet, _type] call ALIVE_fnc_hashGet;
        }else{
            // return the sides vehicle type
            _result = [[[_profilesCatagorised, _side] call ALIVE_fnc_hashGet,"vehicleType"] call ALIVE_fnc_hashGet, _vehicleType] call ALIVE_fnc_hashGet;
        };
    };

    case "getNextInsertID": {
        private _profileCount = [_logic,"profileCount"] call ALIVE_fnc_hashGet;
        _result = _profileCount;

        _profileCount = _profileCount + 1;
        [_logic,"profileCount", _profileCount] call ALIVE_fnc_hashSet;
    };

    case "getNextInsertEntityID": {
        private _entityCount = [_logic,"profileEntityCount"] call ALIVE_fnc_hashGet;
        _result = format["entity_%1", _entityCount];

        _entityCount = _entityCount + 1;
        [_logic,"profileEntityCount", _entityCount] call ALIVE_fnc_hashSet;
    };

    case "getNextInsertVehicleID": {
        private _vehicleCount = [_logic,"profileVehicleCount"] call ALIVE_fnc_hashGet;
        _result = format["vehicle_%1", _vehicleCount];

        _vehicleCount = _vehicleCount + 1;
        [_logic,"profileVehicleCount", _vehicleCount] call ALIVE_fnc_hashSet;
    };

    case "getUnitCount": {
        private _unitCount = 0;

        {
            if((_x select 2 select 5) == "entity") then {
                _unitCount = _unitCount + ([_x,"unitCount"] call ALIVE_fnc_profileEntity);
            }
        } forEach (([_logic,"profiles"] call ALIVE_fnc_hashGet) select 2);

        _result = _unitCount;
    };

    case "getVehicleCount": {
        private _vehicles = [_logic,"getProfilesByType", "vehicle"] call MAINCLASS;
        _result = count _vehicles;
    };

    case "reset": {
        private _profiles = [_logic, "getProfiles"] call MAINCLASS;

        {
            _profile = [_profiles, _x] call ALIVE_fnc_hashGet;

            //_profile call ALIVE_fnc_inspectHash;

            _profileID = _profile select 2 select 4;
            _profileType = _profile select 2 select 5;
            _isPlayer = false;

            if (_profileType == "entity") then {
                _isPlayer = _profile select 2 select 30;
            };

            if!(_isPlayer) then {
                if(_profileType == "entity") then {
                    [_profile, "destroy"] call ALIVE_fnc_profileEntity;
                }else{
                    [_profile, "destroy"] call ALIVE_fnc_profileVehicle;
                };
            };

        } forEach (_profiles select 1);

        private _state = [_logic, "state"] call MAINCLASS;
        _state call ALIVE_fnc_inspectHash;
    };

    case "saveProfileData": {

        private ["_message","_messages","_saveResult","_datahandler","_exportProfiles","_async","_missionName","_message"];

        _result = [false,[]];

        _exportProfiles = [_logic, "exportProfileData"] call MAINCLASS;

        if(isNil"ALIVE_profileDatahandler") then {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS PROFILE - SAVE PROFILE, CREATE DATA HANDLER - NO!"] call ALIVE_fnc_dump;
            };

            ALIVE_profileDatahandler = [nil, "create"] call ALIVE_fnc_Data;
            [ALIVE_profileDatahandler,"storeType",true] call ALIVE_fnc_Data;
        };

        _message = format["ALiVE Profile System - Preparing to save %1 profiles..",count(_exportProfiles select 1)];
        _messages = _result select 1;
        _messages pushback _message;


        _async = false; // Wait for response from server
        _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;
        _missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName]; // must include group_id to ensure mission reference is unique across groups

        _saveResult = [ALIVE_profileDatahandler, "bulkSave", ["sys_profile", _exportProfiles, _missionName, _async]] call ALIVE_fnc_Data;

        _result set [0,_saveResult];

        _message = format["ALiVE Profile System - Save Result: %1",_saveResult];
        _messages = _result select 1;
        _messages pushback _message;

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS PROFILE - SAVE PROFILE DATA RESULT: %1",_saveResult] call ALIVE_fnc_dump;
        };

    };

    case "loadProfileData": {

        private ["_datahandler","_importProfiles","_async","_missionName"];

        if(isNil"ALIVE_profileDatahandler") then {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["LOAD PROFILE, CREATE DATA HANDLER"] call ALIVE_fnc_dump;
            };

            ALIVE_profileDatahandler = [nil, "create"] call ALIVE_fnc_Data;
            [ALIVE_profileDatahandler,"storeType",true] call ALIVE_fnc_Data;
        };

        _async = false; // Wait for response from server
        _missionName = [missionName, "%20", "-"] call CBA_fnc_replace;
        _missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName]; // must include group_id to ensure mission reference is unique across groups

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS PROFILE - LOAD PROFILE DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
        };

        _result = [ALIVE_profileDatahandler, "bulkLoad", ["sys_profile", _missionName, _async]] call ALIVE_fnc_Data;

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS PROFILE - LOAD PROFILE DATA RESULT: %1",_result] call ALIVE_fnc_dump;
        };

    };

    case "exportProfileData": {
        private["_profiles","_exportProfiles","_profile","_profileID","_profileType","_isPlayer","_exportProfile","_isPlayer","_vehicleAssignments","_assignmentKeys",
        "_assignmentValues","_ranks","_side","_spawnType","_entitiesInCommandOf","_entitiesInCargoOf","_vehiclesInCommandOf","_vehiclesInCargoOf","_ranksMap",
        "_exportRanks","_classes","_exportClasses","_rankMap"];

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
            ["ALiVE SYS PROFILE - EXPORT PROFILE DATA..."] call ALIVE_fnc_dump;
        };

        _profiles = [_logic, "getProfiles"] call MAINCLASS;
        _exportProfiles = [] call ALIVE_fnc_hashCreate;

        _ranksMap = [] call ALIVE_fnc_hashCreate;
        [_ranksMap, "PRIVATE", 0] call ALIVE_fnc_hashSet;
        [_ranksMap, "CORPORAL", 1] call ALIVE_fnc_hashSet;
        [_ranksMap, "SERGEANT", 2] call ALIVE_fnc_hashSet;
        [_ranksMap, "LIEUTENANT", 3] call ALIVE_fnc_hashSet;
        [_ranksMap, "CAPTAIN", 4] call ALIVE_fnc_hashSet;
        [_ranksMap, "MAJOR", 5] call ALIVE_fnc_hashSet;
        [_ranksMap, "COLONEL", 6] call ALIVE_fnc_hashSet;

        {
            _profile = _x;
            _profileID = _profile select 2 select 4;
            _profileType = _profile select 2 select 5;
            _isPlayer = false;

            if(_profileType == "entity") then {
                _isPlayer = _profile select 2 select 30;
            };

            if!(_isPlayer) then {

                _vehicleAssignments = _profile select 2 select 7;
                _assignmentKeys = _vehicleAssignments select 1;
                _assignmentValues = _vehicleAssignments select 2;

                if(_profileType == "entity") then {

                    _exportProfile = [_profile, [], [
                        "debug",
                        "active",
                        "leader",
                        "group",
                        "cargo",
                        "busy",
                        "companyID",
                        "groupID",
                        "waypoints",
                        "waypointsCompleted",
                        "units",
                        /*"hasSimulated",*/
                        "isCycling",
                        /*"activeCommands",*/
                        "inactiveCommands",
                        "debugMarkers",
                        "speedPerSecond",
                        /*"despawnPosition",*/
                        "vehicleAssignments",
                        "markers",
                        "damages",
                        "positions",
                        "isPlayer",
                        "objectType",
                        "unitCount",
                        "ranks",
                        "side"
                    ]] call ALIVE_fnc_hashCopy;

                    [_exportProfile, "type", 1] call ALIVE_fnc_hashSet;

                    _ranks = _profile select 2 select 20;
                    _exportRanks = [];

                    {
                        if(!isNil "_x") then {
                            if(typeName _x == "STRING") then {
                                _rankMap = [_ranksMap, toUpper(_x),"PRIVATE"] call ALIVE_fnc_hashGet;

                                if(typeName _rankMap == "SCALAR") then {
                                    _exportRanks pushback _rankMap;
                                }else{
                                    _exportRanks pushback 0;
                                };
                            }else{
                                 _exportRanks pushback 0;
                             };
                        }else{
                            _exportRanks pushback 0;
                        };
                    } forEach _ranks;

                    [_exportProfile, "ranks", _exportRanks] call ALIVE_fnc_hashSet;

                    _classes = _profile select 2 select 11;
                    _exportClasses = [];

                    {
                        if!(isNil "_x") then {
                            if(typeName _x == "STRING") then {
                                _exportClasses pushback _x;
                            };
                        };
                    } forEach _classes;

                    [_exportProfile, "unitClasses", _exportClasses] call ALIVE_fnc_hashSet;

                    _side = _profile select 2 select 3;

                    [_exportProfile, "side", [_side] call ALIVE_fnc_sideTextToNumber] call ALIVE_fnc_hashSet;

                    _vehiclesInCommandOf = [_exportProfile, "vehiclesInCommandOf"] call ALIVE_fnc_hashGet;
                    if(count _vehiclesInCommandOf == 0) then {
                        [_exportProfile, "vehiclesInCommandOf"] call ALIVE_fnc_hashRem;
                    };

                    _vehiclesInCargoOf = [_exportProfile, "vehiclesInCargoOf"] call ALIVE_fnc_hashGet;
                    if(count _vehiclesInCargoOf == 0) then {
                        [_exportProfile, "vehiclesInCargoOf"] call ALIVE_fnc_hashRem;
                    };

                }else{

                    _exportProfile = [_profile, [], [
                        "debug",
                        "active",
                        "vehicle",
                        /*"hasSimulated",*/
                        "debugMarkers",
                        "speedPerSecond",
                        /*"despawnPosition",*/
                        "vehicleAssignments",
                        "ammo",
                        "canMove",
                        "canFire",
                        "needReload",
                        "fuel",
                        "damage",
                        "side"
                    ]] call ALIVE_fnc_hashCopy;

                    [_exportProfile, "type", 2] call ALIVE_fnc_hashSet;

                    _side = _profile select 2 select 3;
                    [_exportProfile, "side", [_side] call ALIVE_fnc_sideTextToNumber] call ALIVE_fnc_hashSet;

                    _entitiesInCommandOf = [_exportProfile, "entitiesInCommandOf"] call ALIVE_fnc_hashGet;
                    if(count _entitiesInCommandOf == 0) then {
                        [_exportProfile, "entitiesInCommandOf"] call ALIVE_fnc_hashRem;
                    };

                    _entitiesInCargoOf = [_exportProfile, "entitiesInCargoOf"] call ALIVE_fnc_hashGet;
                    if(count _entitiesInCargoOf == 0) then {
                        [_exportProfile, "entitiesInCargoOf"] call ALIVE_fnc_hashRem;
                    };

                };

                if([_exportProfile, "_rev"] call ALIVE_fnc_hashGet == "") then {
                    [_exportProfile, "_rev"] call ALIVE_fnc_hashRem;
                };

                if([_exportProfile, "_id"] call ALIVE_fnc_hashGet == "") then {
                    [_exportProfile, "_id"] call ALIVE_fnc_hashRem;
                };

                _spawnType = [_exportProfile, "spawnType"] call ALIVE_fnc_hashGet;
                if(count _spawnType == 0) then {
                    [_exportProfile, "spawnType"] call ALIVE_fnc_hashRem;
                };

                if(count _assignmentKeys > 0) then {
                    [_exportProfile, "vehicleAssignmentKeys", _assignmentKeys] call ALIVE_fnc_hashSet;
                };

                if(count _assignmentValues > 0) then {
                    [_exportProfile, "vehicleAssignmentValues", _assignmentValues] call ALIVE_fnc_hashSet;
                };

                [_exportProfiles, _profileID, _exportProfile] call ALIVE_fnc_hashSet;

                if(ALiVE_SYS_DATA_DEBUG_ON) then {
                    ["ALiVE SYS PROFILE - EXPORT READY PROFILE:"] call ALIVE_fnc_dump;
                    _exportProfile call ALIVE_fnc_inspectHash;
                };

            };

        } forEach (_profiles select 2);

        _result = _exportProfiles;

    };

    case "importProfileData": {
        private["_profiles","_profile","_profileType","_vehicleAssignmentKeys","_vehicleAssignmentValues","_key","_value","_assignments","_assignment","_rebuiltHash",
        "_position","_entities","_vehicles","_total","_index","_damages","_damage","_ranks","_importRanks","_side","_ranksMap","_unitClasses","_side","_profileEntity","_profileVehicle","_boat"];

        if(typeName _args == "ARRAY") then {

            if(ALiVE_SYS_DATA_DEBUG_ON) then {
                ["ALiVE SYS PROFILE - IMPORT PROFILE DATA..."] call ALIVE_fnc_dump;
            };

            _ranksMap = [] call ALIVE_fnc_hashCreate;
            [_ranksMap, 0, "PRIVATE"] call ALIVE_fnc_hashSet;
            [_ranksMap, 1, "CORPORAL"] call ALIVE_fnc_hashSet;
            [_ranksMap, 2, "SERGEANT"] call ALIVE_fnc_hashSet;
            [_ranksMap, 3, "LIEUTENANT"] call ALIVE_fnc_hashSet;
            [_ranksMap, 4, "CAPTAIN"] call ALIVE_fnc_hashSet;
            [_ranksMap, 5, "MAJOR"] call ALIVE_fnc_hashSet;
            [_ranksMap, 6, "COLONEL"] call ALIVE_fnc_hashSet;

            _profiles = _args;

            _entities = [];
            _vehicles = [];
            _total = [_logic,"profileCount",0] call ALIVE_fnc_hashGet;

            {
                _profile = _x;
                _profileType = [_profile,"type"] call ALIVE_fnc_hashGet;

                if("vehicleAssignmentKeys" in (_profile select 1)) then {
                    _vehicleAssignmentKeys = [_profile,"vehicleAssignmentKeys"] call ALIVE_fnc_hashGet;
                    _vehicleAssignmentValues = [_profile,"vehicleAssignmentValues"] call ALIVE_fnc_hashGet;

                    _rebuiltHash = [] call ALIVE_fnc_hashCreate;

                    {
                        _key = _x;
                        _value = _vehicleAssignmentValues select _forEachIndex;
                        _assignments = _value select 2;

                        if(count _assignments < 6) then {
                            _assignments pushBack [];
                            _value set [2,_assignments];
                        };

                        [_rebuiltHash, _key, _value] call ALIVE_fnc_hashSet;
                    } forEach _vehicleAssignmentKeys;

                };

                //_profile call ALIVE_fnc_inspectHash;

                _total = _total + 1;

                if(_profileType == 1) then {

                    _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "init"] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "profileID", [_profile,"profileID"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "unitClasses", [_profile,"unitClasses"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "position", [_profile,"position"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "faction", [_profile,"faction"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "_rev", [_profile,"_rev"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    [_profileEntity, "_id", [_profile,"_id"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

                    [_profileEntity, "hasSimulated", [_profile,"hasSimulated"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    [_profileEntity, "despawnPosition", [_profile,"despawnPosition"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

                    /*
                    [_profileEntity, "objectType", [_profile,"objectType"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "unitCount", [_profile,"unitCount"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    [_profileEntity, "positions", [_profile,"positions"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    [_profileEntity, "damages", [_profile,"damages"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileEntity;
                    */

                    if("vehicleAssignmentKeys" in (_profile select 1)) then {
                        [_profileEntity, "vehicleAssignments", _rebuiltHash] call ALIVE_fnc_hashSet;
                    };

                    if("vehiclesInCommandOf" in (_profile select 1)) then {
                        [_profileEntity, "vehiclesInCommandOf", [_profile,"vehiclesInCommandOf"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if("vehiclesInCargoOf" in (_profile select 1)) then {
                        [_profileEntity, "vehiclesInCargoOf", [_profile,"vehiclesInCargoOf"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if("spawnType" in (_profile select 1)) then {
                        [_profileEntity, "spawnType", [_profile,"spawnType"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    _ranks = [_profile,"ranks"] call ALIVE_fnc_hashGet;
                    _importRanks = [];

                    {
                        _importRanks pushback ([_ranksMap, _x] call ALIVE_fnc_hashGet);
                    } forEach _ranks;

                    [_profileEntity, "ranks", _importRanks] call ALIVE_fnc_hashSet;

                    _side = [_profile,"side"] call ALIVE_fnc_hashGet;
                    if(typeName _side == "SCALAR") then {
                        _side = [_side] call ALIVE_fnc_sideNumberToText;
                    };
                    [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;

                    _unitClasses = [_profile,"unitClasses"] call ALIVE_fnc_hashGet;
                    _damages = [];
                    {
                        if !(isnil "_x") then {
                            _damages pushback 0;
                        };
                    } forEach _unitClasses;

                    [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;

                    if("activeCommands" in (_profile select 1)) then {
                        [_profileEntity, "activeCommands", [_profile,"activeCommands"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if("boat" in (_profile select 1)) then {
                        [_profileEntity, "boat", [_profile,"boat"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE SYS PROFILE - RECREATED PROFILE ENTITY:"] call ALIVE_fnc_dump;
                        _profileEntity call ALIVE_fnc_inspectHash;
                    };

                    [ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                    //Collect the index-number of the entity id
                    _index = [[_profileEntity,"profileID","entity_0"] call ALIVE_fnc_hashGet, "_"] call CBA_fnc_split;
                    if (count _index > 0) then {
                        _index sort true;
                        _index = parseNumber (_index select 0); // will fallback to 0 if a wrong input is given

                        _entities pushback _index;
                    };
                }else{

                    _profileVehicle = [nil, "create"] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "init"] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "profileID", [_profile,"profileID"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "objectType", [_profile,"objectType"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "vehicleClass", [_profile,"vehicleClass"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "position", [_profile,"position"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "direction", [_profile,"direction"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "faction", [_profile,"faction"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "engineOn", [_profile,"engineOn"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "_rev", [_profile,"_rev"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    [_profileVehicle, "_id", [_profile,"_id"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

                    [_profileVehicle, "hasSimulated", [_profile,"hasSimulated"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    [_profileVehicle, "despawnPosition", [_profile,"despawnPosition"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;

                    /*
                    [_profileVehicle, "damage", [_profile,"damage"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "ammo", [_profile,"ammo"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    [_profileVehicle, "fuel", [_profile,"fuel"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    */

                    if("vehicleAssignmentKeys" in (_profile select 1)) then {
                        [_profileVehicle, "vehicleAssignments", _rebuiltHash] call ALIVE_fnc_hashSet;
                    };

                    if("entitiesInCommandOf" in (_profile select 1)) then {
                        [_profileVehicle, "entitiesInCommandOf", [_profile,"entitiesInCommandOf"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if("entitiesInCargoOf" in (_profile select 1)) then {
                        [_profileVehicle, "entitiesInCargoOf", [_profile,"entitiesInCargoOf"] call ALIVE_fnc_hashGet] call ALIVE_fnc_hashSet;
                    };

                    if("spawnType" in (_profile select 1)) then {
                        [_profileVehicle, "spawnType", [_profile,"spawnType"] call ALIVE_fnc_hashGet] call ALIVE_fnc_profileVehicle;
                    };

                    _side = [_profile,"side"] call ALIVE_fnc_hashGet;
                    if(typeName _side == "SCALAR") then {
                        _side = [_side] call ALIVE_fnc_sideNumberToText;
                    };
                    [_profileVehicle, "side", _side] call ALIVE_fnc_profileVehicle;

                    if(ALiVE_SYS_DATA_DEBUG_ON) then {
                        ["ALiVE SYS PROFILE - RECREATED PROFILE VEHICLE:"] call ALIVE_fnc_dump;
                        _profileVehicle call ALIVE_fnc_inspectHash;
                    };


                    [ALIVE_profileHandler, "registerProfile", _profileVehicle] call ALIVE_fnc_profileHandler;

                    //Collect the index-number of the vehicle id
                    _index = [[_profileVehicle,"profileID","vehicle_0"] call ALIVE_fnc_hashGet, "_"] call CBA_fnc_split;
                    if (count _index > 0) then {
                        _index sort true;
                        _index = parseNumber (_index select 0); // will fallback to 0 if a wrong input is given

                        _vehicles pushback _index;
                    };
                };

            } forEach (_profiles select 2);

            //Sort collected index-numbers to get the highest one
            _vehicles sort false;
            _entities sort false;

            //Validating
            _entities = if (count _entities > 0 && {typeName (_entities select 0) == "SCALAR"}) then {_entities select 0} else {0};
            _vehicles = if (count _vehicles > 0 && {typeName (_vehicles select 0) == "SCALAR"}) then {_vehicles select 0} else {0};

            //Set highest index-number on the profiles-counters in order to let objects created lateron have correct unique IDs
            [_logic,"profileVehicleCount", _vehicles] call ALIVE_fnc_hashSet;
            [_logic,"profileEntityCount", _entities] call ALIVE_fnc_hashSet;
            [_logic,"profileCount", _total] call ALIVE_fnc_hashSet;
        };
    };

    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };

};

TRACE_1("profileHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};