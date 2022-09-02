#include "\x\alive\addons\sup_command\script_component.hpp"
SCRIPT(commandHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Server side command handling

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)
// create a command handler
_logic = [nil, "create"] call ALiVE_fnc_commandHandler;

// init command handler
_result = [_logic, "init"] call ALiVE_fnc_commandHandler;

(end)

See Also:

Author:
SpyderBlack / ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS  ALiVE_fnc_baseClassHash
#define MAINCLASS   ALiVE_fnc_commandHandler

private ["_result"];

TRACE_1("groupHandler - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

#define MTEMPLATE "ALiVE_COMMANDHANDLER_%1"

switch(_operation) do {

    case "destroy": {

        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            [_logic, "destroy"] call SUPERCLASS;
        };

    };

    case "debug": {

        private["_tasks"];

        if(typeName _args != "BOOL") then {
            _args = [_logic,"debug"] call ALiVE_fnc_hashGet;
        } else {
            [_logic,"debug",_args] call ALiVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;

    };

    case "init": {

        if (isServer) then {

            // if server, initialise module game logic

            [_logic,"super"] call ALiVE_fnc_hashRem;
            [_logic,"class",MAINCLASS] call ALiVE_fnc_hashSet;

            // set defaults

            [_logic,"debug",false] call ALiVE_fnc_hashSet;

            if ([QMOD(sys_profile)] call ALiVE_fnc_isModuleAvailable) then {
                waituntil {!(isnil "ALiVE_profileSystemInit")};
            };

            TRACE_1("After module init",_logic);

        };

    };

    case "handleEvent": {

        if (_args isEqualType []) then {

            _args params ["_type","_data"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;
            if (_debug) then {
                ["----------------------------------------------------------------------------------------"] call ALiVE_fnc_dump;
                ["Command Handler - %1 Event received", _type] call ALiVE_fnc_dump;
                _data call ALiVE_fnc_inspectArray;
            };

            switch (_type) do {

                case "INTEL_TYPE_SELECT": {

                    [_logic, "intelTypeSelected", _data] call MAINCLASS;

                };

                case "INTEL_OPCOM_SELECT": {

                    [_logic, "intelOPCOMSelected", _data] call MAINCLASS;

                };

                case "OPS_DATA_PREPARE": {

                    [_logic,"opsDataPrepare", _data] call MAINCLASS;

                };

                case "OPS_OPCOM_SELECT": {

                    [_logic,"opsOPCOMSelected", _data] call MAINCLASS;

                };

                case "OPS_GET_PROFILE": {

                    [_logic,"opsGetProfile", _data] call MAINCLASS;

                };

                case "OPS_GET_PROFILE_WAYPOINTS": {

                    [_logic,"opsGetProfileWaypoints", _data] call MAINCLASS;

                };

                case "OPS_CLEAR_PROFILE_WAYPOINTS": {

                    [_logic,"opsClearProfileWaypoints", _data] call MAINCLASS;

                };

                case "OPS_APPLY_PROFILE_WAYPOINTS": {

                    [_logic,"opsApplyProfileWaypoints", _data] call MAINCLASS;

                };

                case "OPS_JOIN_GROUP": {

                    [_logic,"opsJoinGroup", _data] spawn MAINCLASS;

                };

                case "OPS_SPECTATE_GROUP": {

                    [_logic,"opsSpectateGroup", _data] spawn MAINCLASS;

                };

                case "OPS_LOCK_GROUP": {

                    [_logic,"opsLockGroup", _data] call MAINCLASS;

                };

                default {

                    [_logic,_type, _data] call MAINCLASS;

                };

            };

        };

    };

    case "opsDataPrepare": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_limit","_side","_faction"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get opcoms available by limit set on intel

            private _opcomData = [];

            if (!isnil "OPCOM_INSTANCES") then {
                {
                    private _opcom = _x;
                    private _opcomID = [_opcom,"opcomID"] call ALiVE_fnc_hashGet;
                    private _opcomName = [_opcom,"name"] call ALiVE_fnc_hashGet;
                    private _opcomSide = [_opcom,"side"] call ALiVE_fnc_hashGet;
					
                    switch(_limit) do {
                        case "SIDE": {
							private _opcomSide = [_opcom,"side"] call ALiVE_fnc_hashGet;
							
                            if (_side == _opcomSide) then {
                                _opcomData pushBack [_opcomID,_opcomName,_opcomSide];
                            };
                        };
                        case "FACTION": {
                            private _opcomFactions = [_opcom,"factions"] call ALiVE_fnc_HashGet;

                            if (_faction in _opcomFactions) then {
                                _opcomData pushBack [_opcomID,_opcomName,_opcomSide];
                            };
                        };
                        case "ALL": {
                            _opcomData pushBack [_opcomID,_opcomName,_opcomSide];
                        };
                    };
                } foreach OPCOM_INSTANCES;
            };

            // send the data back to the players SCOM tablet

            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            ["OPS_SIDES_AVAILABLE", [_playerID,_opcomData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

        };

    };

    case "opsOPCOMSelected": {

        if (_args isEqualType []) then {

             _args params ["_playerID","_selOpcom"];
	     private _selOpcomID = (_selOpcom select 0);
	     private _side = (_selOpcom select 2);
			
            // get groups state for the selected opcom

            private _groups = [];
            {
                private _opcom = _x;
                private _opcomID = [_opcom,"opcomID"] call ALiVE_fnc_hashGet;

                if (_selOpcomID == _opcomID) then {
		        private _opcomFactions = [_opcom,"factions"] call ALiVE_fnc_hashGet;
			{
				private _faction = _x;
				private _profiles = [MOD(profileHandler),"getProfilesByFaction", _faction] call ALiVE_fnc_profileHandler;

				{
							
					private _data = [];
					private _typeUnits = [_opcom,_x, []] call ALiVE_fnc_HashGet;

					{
						if (_x in _profiles) then {

							private _profile = [MOD(profileHandler),"getProfile", _x] call ALiVE_fnc_profileHandler;

							if (!isnil "_profile") then {
								private _position = _profile select 2 select 2;
								_data pushBack [_x,_position];
							};
						};

					} foreach _typeUnits;

					_groups pushBack _data;
				} foreach ["infantry","motorized","mechanized","armored","air","sea","artillery","AAA"];
			} foreach _opcomFactions;
					
                };
            } foreach OPCOM_INSTANCES;

            // send the data back to the players SCOM tablet

            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            ["OPS_GROUPS", [_playerID,_side,_groups]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

        };

    };

    case "opsGetProfile": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];

            // get profile

            private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (!isnil "_profile") then {

                // send the data back to the players SCOM tablet

                private _waypoints = _profile select 2 select 16;               // waypoints
                _waypointPositions = _waypoints apply {(_x select 2) select 0}; // position

                private _profileData = [
                    _profile select 2 select 1,     // active
                    _profile select 2 select 3,     // side
                    _profile select 2 select 2,     // position
                    _profile select 2 select 13,    // group
                    _waypointPositions,
                    [_profile,"busy"] call ALiVE_fnc_hashGet
                ];

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_PROFILE", [_playerID,_profileData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };

        };

    };

    case "opsGetProfileWaypoints": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get profile

            private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if !(isnil "_profile") then {

                // send the data back to the players SCOM tablet

                private _waypoints = _profile select 2 select 16; // waypoints
                private _waypointsArray = _waypoints apply {_x select 2};

                private _profileData = [
                    _profile select 2 select 1,     // active
                    _profile select 2 select 3,     // side
                    _profile select 2 select 2,     // position
                    _profile select 2 select 13,    // group
                    _waypointsArray
                ];

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_PROFILE_WAYPOINTS", [_playerID,_profileData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };
        };

    };

    case "opsClearProfileWaypoints": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get profile

            private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (!isnil "_profile") then {

                // clear waypoints

                [_profile, 'clearWaypoints'] call ALiVE_fnc_profileEntity;

                // send the data back to the players SCOM tablet

                _profileData = [
                    _profile select 2 select 1,      // active
                    _profile select 2 select 3,     // side
                    _profile select 2 select 2,     // position
                    _profile select 2 select 13,    // group
                    []                              // waypoints
                ];

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_PROFILE_WAYPOINTS_CLEARED", [_playerID,_profileData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };

        };

    };

    case "opsApplyProfileWaypoints": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID","_updatedWaypoints"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get profile

            private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (!isnil "_profile") then {

                // set busy

                [_profile,"busy",true] call ALiVE_fnc_profileEntity;

                // clear waypoints

                [_profile, "clearWaypoints"] call ALiVE_fnc_profileEntity;

                {
                    private _waypointData = _x;
                    private _waypointType = _waypointData select 2;

                    if (_waypointType == "LAND OFF" || {_waypointType == "LAND HOVER"}) then {

                        private _waypointPosition = _waypointData select 0;
                        private _wp = [_waypointPosition,15] call ALiVE_fnc_createProfileWaypoint;

                        [_profile,"addWaypoint",_wp] call ALiVE_fnc_profileEntity;

                        private _helipad = "Land_HelipadEmpty_F" createVehicle _waypointPosition;

                        [_profile,_helipad,_waypointType] spawn {
                            params ["_profile","_helipad","_waypointType"];

                            private _timeTaken = time;

                            waituntil {
                                sleep 5;

                                ([_profile,"active"] call ALiVE_fnc_hashGet || {time - _timeTaken > 600})
                            };

                            if ([_profile,"active"] call ALiVE_fnc_hashGet) then {
                                private _group = _profile select 2 select 13;

                                waitUntil {
                                    sleep 2;

                                    unitReady (leader _group)
                                };

                                [_profile,"clearWaypoints"] call ALiVE_fnc_profileEntity;    // waypoint doesn't seem to complete when you use land command

                                if (_waypointType == "LAND OFF") then {
                                    [vehicle leader _group,"LAND"] call ALiVE_fnc_landRemote;
                                } else {
                                    [vehicle leader _group,"GET OUT"] call ALiVE_fnc_landRemote;
                                };

                                sleep 60;
                                deleteVehicle _helipad;
                            } else {
                                deleteVehicle _helipad;
                            };

                        };

                    } else {

                        private _wp = [_waypointData select 0] call ALiVE_fnc_createProfileWaypoint;
                        _wp set [2,_waypointData];

                        [_profile,"addWaypoint", _wp] call ALiVE_fnc_profileEntity;

                    };
                } foreach _updatedWaypoints;

                private _waypoints = _profile select 2 select 16;
                private _waypointsArray = _waypoints apply {_x select 2};

                private _profileData = [
                    _profile select 2 select 1,     // active
                    _profile select 2 select 3,     // side
                    _profile select 2 select 2,     // position
                    _profile select 2 select 13,    // group
                    _waypointsArray                 // waypoints
                ];

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_PROFILE_WAYPOINTS_UPDATED", [_playerID,_profileData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };
        };

    };

    case "opsJoinGroup": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get profile

            private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (!isnil "_profile") then {

                private _faction = _profile select 2 select 29;                 // faction
                private _position = _profile select 2 select 2;                 // position
                private _vehiclesInCommandOf = _profile select 2 select 8;      // vehiclesInCommandOf

                if (count _vehiclesInCommandOf == 0) then {

                    private _position = _position getPos [50, random 360];

                    if (surfaceIsWater _position) then {
                        _position = [_position] call ALiVE_fnc_getClosestLand;
                    };

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;

                    _player hideObjectGlobal true;

                    _player setPos _position;

                    waitUntil {_profile select 2 select 1}; // active

                    sleep 2;

                    private _group = _profile select 2 select 13;
                    private _unit = selectRandom (units _group);

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_GROUP_JOIN_READY", [_playerID,[_unit]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                } else {

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                };

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };
        };

    };

    case "opsSpectateGroup": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get profile

            private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if !(isnil "_profile") then {

                private _faction = _profile select 2 select 29;
                private _position = _profile select 2 select 2;
                private _vehiclesInCommandOf = _profile select 2 select 8;

                _position = _position getPos [50, random 360];

                if (surfaceIsWater _position) then {
                    _position = [_position] call ALiVE_fnc_getClosestLand;
                };

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;

                if (!isnil "_player") then {

                    _player hideObjectGlobal true;

                    _player setPos _position;

                    waitUntil {_profile select 2 select 1}; // active

                    sleep 2;

                    private _group = _profile select 2 select 13;
                    private _unit = selectRandom (units _group);

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_GROUP_SPECTATE_READY", [_playerID,[_unit]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                };

            } else {

                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

            };
        };

    };

    case "opsLockGroup": {

        private _eventData = _args;

        _eventData params ["_playerID","_profileID","_lock"];

        private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

        [_profile,"busy", _lock] call ALiVE_fnc_hashSet;

        private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
        ["OPS_GROUP_LOCK_UPDATED", [_playerID,[_profileID,_lock]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

    };

    case "intelTypeSelected": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_type","_limit","_side","_faction"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            switch (_type) do {

                case "Objectives": {

                    private["_objectiveData","_opcom","_opcomFactions","_opcomSide"];

                    // get opcoms available by limit set on intel

                    _opcomData = [];

                    if (!isnil "OPCOM_INSTANCES") then {

                        {
                            	private _opcom = _x;
				private _opcomID = [_opcom,"opcomID"] call ALiVE_fnc_hashGet;
				private _opcomName = [_opcom,"name"] call ALiVE_fnc_hashGet;
				private _opcomSide = [_opcom,"side"] call ALiVE_fnc_hashGet;
							
				switch(_limit) do {
					case "SIDE": {
						private _opcomSide = [_opcom,"side"] call ALiVE_fnc_hashGet;
									
						if (_side == _opcomSide) then {
							_opcomData pushBack [_opcomID,_opcomName,_opcomSide];
						};
					};
					case "FACTION": {
						private _opcomFactions = [_opcom,"factions"] call ALiVE_fnc_HashGet;

						if (_faction in _opcomFactions) then {
							_opcomData pushBack [_opcomID,_opcomName,_opcomSide];
						};
					};
					case "ALL": {
						_opcomData pushBack [_opcomID,_opcomName,_opcomSide];
					};
				};

                        } foreach OPCOM_INSTANCES;

                    };

                    // send the data back to the players SCOM tablet

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPCOM_SIDES_AVAILABLE", [_playerID,_opcomData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                };

                case "Marking": {

                    private[
                        "_opcoms","_profilesBySide","_knownEnemiesBySide","_opcom","_profileByType",
                        "_profIDs","_typeData","_profile","_profilePosition","_attackID"
                    ];

                    // get inactive profiles available by limit set on intel

                    _opcoms = [];
                    _profilesBySide = [[],[],[]];   // east, west, indep
                    _knownEnemiesBySide = [[],[],[]];

                    if (!isnil "OPCOM_instances") then {

                        switch(_limit) do {
                            case "SIDE": {
                                {
                                    if (_side == ([_x,"side","WEST"] call ALiVE_fnc_hashGet)) then {
                                        _opcoms pushback _x;
                                    };
                                } foreach OPCOM_instances;
                            };
                            case "FACTION": {
                                {
                                    if (_faction in ([_x,"factions",[]] call ALiVE_fnc_hashGet)) then {
                                        _opcoms pushback _x;
                                    };
                                } foreach OPCOM_instances;
                            };
                            case "ALL": {
                                _opcoms = OPCOM_instances;
                            };
                        };

                        {
                            _opcom = _x;
                            _profileByType = [];
                            _side = [_opcom,"side","WEST"] call ALiVE_fnc_hashGet;

                            {
                                _profIDs = [_opcom,_x,[]] call ALiVE_fnc_hashGet;
                                _typeData = [];

                                {
                                    _profile = [MOD(profileHandler), "getProfile", _x] call ALiVE_fnc_profileHandler;

                                    if !(isnil "_profile") then {
                                        _profilePosition = _profile select 2 select 2;
                                        _attackID = [_profile,"attackID", ""] call ALiVE_fnc_hashGet;
                                        _typeData pushback [_profilePosition,_attackID];
                                    };
                                } foreach _profIDs;

                                _profileByType pushback _typeData;
                            } foreach ["infantry","motorized","mechanized","armored","artillery","AAA","air","sea"];

                            switch (_side) do {
                                case "EAST": {(_profilesBySide select 0) pushback _profileByType};
                                case "WEST": {(_profilesBySide select 1) pushback _profileByType};
                                case "GUER": {(_profilesBySide select 2) pushback _profileByType};
                            };

                            private _knownEnemies = [_opcom,"knownentities",[]] call ALiVE_fnc_hashGet; // visible enemy - [id,pos]
                            {
                                private _profile = [MOD(profileHandler), "getProfile", _x select 0] call ALiVE_fnc_profileHandler;

                                if !(isnil "_profile") then {
                                    _side = _profile select 2 select 3;

                                    switch (_side) do {
                                        case "EAST": {(_knownEnemiesBySide select 0) pushbackunique (_x select 1)};
                                        case "WEST": {(_knownEnemiesBySide select 1) pushbackunique (_x select 1)};
                                        case "GUER": {(_knownEnemiesBySide select 2) pushbackunique (_x select 1)};
                                    };
                                };
                                false
                            } count _knownEnemies;
                            false
                        } count _opcoms;

                    };

                    // send the data back to the players SCOM tablet

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["UNIT_MARKING", [_playerID,_profilesBySide,_knownEnemiesBySide]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                };

                case "IMINT": {

                    private ["_sources","_transportArray","_casArray"];

                    // return all possible IMINT sources

                    _sources = [];

                    _side = [_side] call ALiVE_fnc_sideTextToObject;

                    if !(isnil "NEO_radioLogic") then {

                        // add aerial combat support vehicles

                        _transportArray = NEO_radioLogic getVariable [format ["NEO_radioTrasportArray_%1", _side], []];
                        {
                            private _veh = _x select 0;
                            private _name = _x select 2;
                            _sources pushback [_veh,_name]
                        } foreach _transportArray;

                        _casArray = NEO_radioLogic getVariable [format ["NEO_radioCasArray_%1", _side], []];
                        {
                            private _veh = _x select 0;
                            private _name = _x select 2;
                            _sources pushback [_veh,_name]
                        } foreach _casArray;

                    };

                    // add all uavs connected to a unit

                    {
                        if (side group _x == _side) then {

                            // get unit connected uav if one exists

                            private _connectedUAV = getConnectedUAV _x;

                            if !(isnull _connectedUAV) then {
                                private _droneType = getText (configFile >> "CfgVehicles" >> (typeOf _connectedUAV) >> "displayName");
                                private _name = format ["%1 - %2", _droneType, name _x];

                                _sources pushback [_connectedUAV,_name];
                            };

                            // if unit is in non-CS air vehicle and is driver, add vehicle

                            private _vehicle = vehicle _x;
                            if (_vehicle != _x && {driver _vehicle == _x} && {_vehicle isKindOf "Air"} && {!(_vehicle getVariable ["ALiVE_CombatSupport",false])}) then {

                                // ensure unit is not uav ai logic...
                                if !(unitIsUAV _x) then {
                                    private _vehicleName = getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "displayName");
                                    private _name = format ["%1 - %2", _vehicleName, name _x];

                                    _sources pushback [_vehicle,_name];
                                };
                            };
                        };

                        false
                    } count allUnits;

                    // send the data back to the players SCOM tablet

                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["IMINT_SOURCES_AVAILABLE", [_playerID,_sources]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

                };

            };

        };

    };

    case "intelOPCOMSelected": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_selOpcom"];
			
	    private _selOpcomID = (_selOpcom select 0);
            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // get objective state by selected opcom

            private _objectiveData = [];

            if (!isnil "OPCOM_instances") then {

                {
                    private _opcom = _x;
                    private _opcomID = [_opcom,"opcomID"] call ALiVE_fnc_hashGet;

                    if (_selOpcomID == _opcomID) then {

                        {
                            private _center = [_x,"center",[]] call ALiVE_fnc_hashGet;
                            private _size = [_x,"size",150] call ALiVE_fnc_hashGet;
                            private _tacom_state = [_x,"tacom_state","unassigned"] call ALiVE_fnc_hashGet;
                            private _opcom_state = [_x,"opcom_state","unassigned"] call ALiVE_fnc_hashGet;
                            private _section = [_x,"section"] call ALiVE_fnc_hashGet;

                            private _sections = [];

                            if (!isnil "_section") then {
                                {
                                    private _profile = [MOD(profileHandler),"getProfile", _] call ALiVE_fnc_profileHandler;

                                    if !(isnil "_profile") then {
                                        private _position = _profile select 2 select 2;
                                        private _dir = _position getDir _center;

                                        _sections pushBack [_position,_dir];
                                    };
                                } foreach _section;
                            };

                            _objectiveData pushBack [_size,_center,_tacom_state,_opcom_state,_sections];

                        } foreach ([_opcom,"objectives",[]] call ALiVE_fnc_HashGet);

                    };

                } foreach OPCOM_INSTANCES;

            };

            // send the data back to the players SCOM tablet

            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            ["OPCOM_OBJECTIVES", [_playerID,_objectiveData]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

        };
    };

    default {
        _result = _this call SUPERCLASS;
    };

};

TRACE_1("commandHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};
