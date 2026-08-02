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

            // The handler is authoritative on dedicated servers as well as a
            // hosted session. UID ownership lets disconnect cleanup release only
            // this player's pin when several players use the same profile.
            if ((missionNamespace getVariable ["ALiVE_SCOMDisconnectEH",-1]) < 0) then {
                private _disconnectEH = addMissionEventHandler ["HandleDisconnect",{
                    params ["_unit","_id","_uid"];
                    if (_uid != "" && {!isNil "ALIVE_commandHandler"}) then {
                        // Capture the occupied role before the engine retires the
                        // disconnected player object. The asynchronous cleanup may
                        // otherwise run after that object has already become null.
                        private _disconnectState = [];
                        if (!isNull _unit) then {
                            private _vehicle = vehicle _unit;
                            private _vehicleRole = [];
                            if !(_vehicle isEqualTo _unit) then {
                                private _rowIndex = (fullCrew [_vehicle,"",false]) findIf {(_x select 0) isEqualTo _unit};
                                if (_rowIndex >= 0) then {
                                    private _row = (fullCrew [_vehicle,"",false]) select _rowIndex;
                                    _vehicleRole = [toLower (_row param [1,"",[""]]),_row param [2,-1,[0]],_row param [3,[],[[]]]];
                                };
                            } else {
                                _vehicle = objNull;
                            };
                            _disconnectState = [getPosATL _unit,getDir _unit,getUnitLoadout _unit,damage _unit,_vehicle,_vehicleRole,alive _unit];
                        };
                        [ALIVE_commandHandler,"opsCleanupJoin",[_uid,_unit,_disconnectState]] spawn ALiVE_fnc_commandHandler;
                    };
                    false
                }];
                missionNamespace setVariable ["ALiVE_SCOMDisconnectEH",_disconnectEH];
            };

            // Dedicated-server fallback for missions whose client respawn event
            // is delayed or replaced. The server waits until the new object has
            // a UID, then resumes any takeover session already owned by that UID.
            if ((missionNamespace getVariable ["ALiVE_SCOMSelectedPlayerEH",-1]) < 0) then {
                private _selectedPlayerEH = addMissionEventHandler ["OnUserSelectedPlayer",{
                    params ["_networkID","_playerObject"];
                    if (!isNull _playerObject && {!isNil "ALIVE_commandHandler"}) then {
                        [_playerObject] spawn {
                            params ["_playerObject"];
                            private _deadline = diag_tickTime + 20;
                            waitUntil {
                                sleep 0.05;
                                isNull _playerObject || {getPlayerUID _playerObject != ""} || {diag_tickTime >= _deadline}
                            };
                            if (!isNull _playerObject && {getPlayerUID _playerObject != ""} && {!isNil "ALIVE_commandHandler"}) then {
                                private _playerID = getPlayerUID _playerObject;
                                private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
                                private _session = [ALIVE_commandHandler,_sessionKey,[]] call ALiVE_fnc_hashGet;
                                if !(_session isEqualTo []) then {
                                    private _sessionPlayer = [_session,"player",objNull] call ALiVE_fnc_hashGet;
                                    private _status = [_session,"status",""] call ALiVE_fnc_hashGet;
                                    if (!(_playerObject isEqualTo _sessionPlayer) || {_status in ["AWAITING_RESPAWN","RESPAWN_PROCESSING","CHOOSING_REPLACEMENT"]}) then {
                                        [ALIVE_commandHandler,"opsJoinPlayerRespawned",[_playerID,_playerObject,objNull]] spawn ALiVE_fnc_commandHandler;
                                    };
                                };
                            };
                        };
                    };
                }];
                missionNamespace setVariable ["ALiVE_SCOMSelectedPlayerEH",_selectedPlayerEH];
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

                    private _playerID = if (_data isEqualType [] && {count _data > 0}) then {_data select 0} else {""};
                    [_logic,format ["opsInstantJoinCancelled_%1",_playerID],false] call ALiVE_fnc_hashSet;
                    [_logic,"opsJoinGroup", _data] spawn MAINCLASS;

                };

                case "OPS_TAKEOVER_UNIT": {

                    [_logic,"opsTakeoverUnit",_data] spawn MAINCLASS;

                };

                case "OPS_JOIN_HANDOFF_COMPLETE": {

                    [_logic,"opsJoinHandoffComplete",_data] spawn MAINCLASS;

                };

                case "OPS_JOIN_PLAYER_KILLED": {

                    [_logic,"opsJoinPlayerKilled",_data] call MAINCLASS;

                };

                case "OPS_JOIN_PLAYER_RESPAWNED": {

                    [_logic,"opsJoinPlayerRespawned",_data] spawn MAINCLASS;

                };

                case "OPS_CANCEL_JOIN_ACTIVE": {

                    private _playerID = if (_data isEqualType [] && {count _data > 0}) then {_data select 0} else {""};
                    [_logic,format ["opsInstantJoinCancelled_%1",_playerID],true] call ALiVE_fnc_hashSet;
                    [_logic,"opsCancelJoinActive",_data] spawn MAINCLASS;

                };

                case "OPS_JOIN_RESTORE_COMPLETE": {

                    [_logic,"opsJoinRestoreComplete",_data] spawn MAINCLASS;

                };

                case "OPS_CANCEL_JOIN_PREP": {

                    private _playerID = if (_data isEqualType [] && {count _data > 0}) then {_data select 0} else {""};
                    [_logic,format ["opsInstantJoinCancelled_%1",_playerID],true] call ALiVE_fnc_hashSet;
                    [_logic,"opsCancelJoinPrep", _data] call MAINCLASS;

                };

                case "OPS_SPECTATE_GROUP": {

                    [_logic,"opsSpectateGroup", _data] spawn MAINCLASS;

                };

                case "OPS_LOCK_GROUP": {

                    [_logic,"opsLockGroup", _data] call MAINCLASS;

                };

                case "OPS_GET_OBJECTIVES": {

                    [_logic,"opsGetObjectives", _data] call MAINCLASS;

                };

                case "OPS_ADD_OBJECTIVE": {

                    [_logic,"opsAddObjective", _data] call MAINCLASS;

                };

                case "OPS_CANCEL_OBJECTIVE": {

                    [_logic,"opsCancelObjective", _data] call MAINCLASS;

                };

                case "OPS_MOVE_OBJECTIVE": {

                    [_logic,"opsMoveObjective", _data] call MAINCLASS;

                };

                default {

                    // every client-reachable event has an explicit case above; never
                    // forward an arbitrary client-supplied string as an operation name
                    // (would let a crafted event invoke "destroy" / "init" / "debug")

                    if (_debug) then {
                        ["Command Handler - unknown event type %1 dropped", _type] call ALiVE_fnc_dump;
                    };

                };

            };

        };

    };

    case "opsDataPrepare": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_limit","_side","_faction"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // never trust the client-sent limit/side/faction - a crafted event could
            // pass "ALL" to enumerate every commander. Re-derive from the caller.

            _limit = [_logic,"opsLimit","SIDE"] call ALiVE_fnc_hashGet;
            private _callerPlayer = [_playerID] call ALiVE_fnc_getPlayerByUID;
            if (isNull _callerPlayer) exitWith {};
            _side = [_logic,"opsPlayerSideText",_callerPlayer] call MAINCLASS;
            _faction = faction _callerPlayer;

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

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]]];

            if (count _selOpcom < 3) exitWith {};

            private _selOpcomID = (_selOpcom select 0);
            private _side = (_selOpcom select 2);

            // authorize the caller for this commander before returning its group state
            private _opcom = [_logic,"opsFindOPCOM", _selOpcomID] call MAINCLASS;
            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS) exitWith {
                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_GROUPS", [_playerID,_side,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
            };
			
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
								// Some OPCOM vehicle buckets contain the vehicle profile ID.
								// Tablet orders operate on entity/group profiles, so resolve the
								// vehicle to the entity commanding it before exposing it to the UI.
								if ((_profile select 2 select 5) == "vehicle") then {
									private _entityIDs = _profile select 2 select 8;
									if !(_entityIDs isEqualTo []) then {
										_profile = [MOD(profileHandler),"getProfile", _entityIDs select 0] call ALiVE_fnc_profileHandler;
									};
								};

								if (!isnil "_profile" && {(_profile select 2 select 5) == "entity"}) then {
									private _profileID = _profile select 2 select 4;
									private _position = _profile select 2 select 2;
									private _busy = [_profile,"busy",false] call ALiVE_fnc_hashGet;
									_data pushBackUnique [_profileID,_position,_busy];
								};
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

                // Tablet group actions are defined on entity/group profiles.
                // Reject a stale or crafted vehicle profile ID.
                if ((_profile select 2 select 5) != "entity") exitWith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

                if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

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

                if ((_profile select 2 select 5) != "entity") exitWith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

                if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

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

                if ((_profile select 2 select 5) != "entity") exitWith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

                if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

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

                if ((_profile select 2 select 5) != "entity") exitWith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

                if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", []] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

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

    case "opsAcquireProfilePin": {

        if (_args isEqualType [] && {count _args >= 3}) then {
            _args params ["_playerID","_profileID","_profile"];
            private _pinKey = format ["opsInstantJoinPin_%1",_profileID];
            private _pin = [_logic,_pinKey,[]] call ALiVE_fnc_hashGet;

            if (_pin isEqualTo []) then {
                private _priorSpawnType = [_profile,"spawnType"] call ALiVE_fnc_profileEntity;
                if (isNil "_priorSpawnType" || {!(_priorSpawnType isEqualType [])}) then {_priorSpawnType = []};
                _pin = [_profile,_priorSpawnType,[]];
            };

            private _owners = _pin param [2,[],[[]]];
            _owners pushBackUnique _playerID;
            _pin set [2,_owners];
            [_logic,_pinKey,_pin] call ALiVE_fnc_hashSet;
            [_profile,"spawnType",["preventDespawn"]] call ALiVE_fnc_profileEntity;
            _result = true;
        };

    };

    case "opsReleaseProfilePin": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_playerID","_profileID"];
            private _pinKey = format ["opsInstantJoinPin_%1",_profileID];
            private _pin = [_logic,_pinKey,[]] call ALiVE_fnc_hashGet;

            if !(_pin isEqualTo []) then {
                private _owners = _pin param [2,[],[[]]];
                _owners = _owners - [_playerID];
                if (_owners isEqualTo []) then {
                    private _profile = _pin select 0;
                    private _priorSpawnType = _pin param [1,[],[[]]];
                    if !(isNil "_profile") then {[_profile,"spawnType",_priorSpawnType] call ALiVE_fnc_profileEntity};
                    [_logic,_pinKey,[]] call ALiVE_fnc_hashSet;
                } else {
                    _pin set [2,_owners];
                    [_logic,_pinKey,_pin] call ALiVE_fnc_hashSet;
                };
            };
        };

    };

    case "opsJoinGroup": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_profileID"];
            private _cancelKey = format ["opsInstantJoinCancelled_%1",_playerID];
            if ([_logic,_cancelKey,false] call ALiVE_fnc_hashGet) exitWith {};
            private _profile = [MOD(profileHandler), "getProfile", _profileID] call ALiVE_fnc_profileHandler;
            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;

            private _sendFailure = {
                if (!isNull _player) then {
                    ["OPS_GROUP_JOIN_READY",[_playerID,[objNull]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
                };
            };

            if (isnil "_profile") exitWith {call _sendFailure};
            if ((_profile select 2 select 5) != "entity") exitWith {call _sendFailure};
            if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitWith {call _sendFailure};
            if !([_logic,"scomOpsAllowInstantJoin",false] call ALiVE_fnc_hashGet) exitWith {call _sendFailure};
            if (isNull _player) exitWith {};

            // Keep the real player body at its saved location. Force-spawn and
            // temporarily pin the profile instead of using player proximity as
            // an activation shortcut.
            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _previousPrep = [_logic,_prepKey,[]] call ALiVE_fnc_hashGet;
            if (count _previousPrep >= 2) then {
                [_logic,"opsReleaseProfilePin",[_playerID,_previousPrep select 1]] call MAINCLASS;
            };

            [_logic,"opsAcquireProfilePin",[_playerID,_profileID,_profile]] call MAINCLASS;
            [_logic,_prepKey,[_profile,_profileID]] call ALiVE_fnc_hashSet;
            _player hideObjectGlobal true;

            if !(_profile select 2 select 1) then {
                [_profile,"spawn"] call ALiVE_fnc_profileEntity;
            };

            // Activation can fail (for example a profile cannot spawn). Never
            // strand the player on an endless loading splash.
            private _deadline = diag_tickTime + 30;
            waitUntil {
                sleep 0.5;
                isNull _player || {[_logic,_cancelKey,false] call ALiVE_fnc_hashGet} || {_profile select 2 select 1} || {diag_tickTime >= _deadline}
            };

            if ([_logic,_cancelKey,false] call ALiVE_fnc_hashGet) exitWith {};
            if (isNull _player) exitWith {};
            if !(_profile select 2 select 1) exitWith {call _sendFailure};

            private _group = _profile select 2 select 13;
            private _availableUnits = [];
            private _unitDeadline = diag_tickTime + 20;
            waitUntil {
                sleep 0.25;
                _group = _profile select 2 select 13;
                if (!isNull _group) then {
                    _availableUnits = (units _group) select {alive _x && {!isPlayer _x} && {simulationEnabled _x}};
                };
                isNull _player || {[_logic,_cancelKey,false] call ALiVE_fnc_hashGet} || {!(_availableUnits isEqualTo [])} || {diag_tickTime >= _unitDeadline}
            };

            if ([_logic,_cancelKey,false] call ALiVE_fnc_hashGet) exitWith {};
            if (isNull _player) exitWith {};
            if (_availableUnits isEqualTo []) exitWith {call _sendFailure};

            ["OPS_GROUP_JOIN_READY",[_playerID,_availableUnits]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
        };

    };

    case "opsApplyGroupLeadership": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_targetGroup","_leader",["_forceFollow",false]];
            if (!isNull _targetGroup && {!isNull _leader} && {_leader in units _targetGroup}) then {
                if (local _targetGroup) then {
                    _targetGroup selectLeader _leader;
                    if (_forceFollow) then {
                        {
                            if (!(_x isEqualTo _leader) && {alive _x} && {!isPlayer _x}) then {
                                doStop _x;
                                _x doFollow _leader;
                            };
                        } forEach units _targetGroup;
                    };
                } else {
                    private _groupOwner = groupOwner _targetGroup;
                    if (_groupOwner < 2) then {_groupOwner = 2};
                    ["OPS_APPLY_GROUP_LEADERSHIP",[_targetGroup,_leader,_forceFollow]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_groupOwner];
                };
            };
        };

    };

    case "opsApplyTakeoverWaypoints": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_targetGroup","_mode",["_snapshot",[]]];
            if (!isNull _targetGroup) then {
                private _event = ["OPS_APPLY_TAKEOVER_WAYPOINTS",[_targetGroup,_mode,_snapshot]];
                if (local _targetGroup) then {
                    _event call ALiVE_fnc_SCOMTabletEventToClient;
                } else {
                    private _groupOwner = groupOwner _targetGroup;
                    if (_groupOwner < 2) then {_groupOwner = 2};
                    _event remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_groupOwner];
                };
            };
        };

    };

    case "opsSuspendProfileWaypoints": {

        _result = false;
        if (_args isEqualType [] && {count _args >= 4}) then {
            _args params ["_playerID","_profileID","_profile","_targetGroup"];
            if (_playerID != "" && {_profileID != ""} && {_profile isEqualType []} && {!(_profile isEqualTo [])} && {!isNull _targetGroup}) then {
                private _stateKey = format ["opsInstantJoinWaypoints_%1",_profileID];
                private _state = [_logic,_stateKey,[]] call ALiVE_fnc_hashGet;

                if (_state isEqualTo []) then {
                    private _engineWaypoints = waypoints _targetGroup;
                    private _snapshot = [];
                    private _waypointCount = count _engineWaypoints;
                    private _currentIndex = (currentWaypoint _targetGroup) max 1;
                    private _isCycling = (_engineWaypoints findIf {waypointType _x == "CYCLE"}) >= 0;
                    private _captureWaypoint = {
                        params ["_index"];
                        if (_index >= 0 && {_index < _waypointCount}) then {
                            private _waypoint = _engineWaypoints select _index;
                            private _position = waypointPosition _waypoint;
                            if (count _position >= 2 && {!((_position select [0,2]) isEqualTo [0,0])}) then {
                                _snapshot pushBack ([_waypoint] call ALiVE_fnc_waypointToProfileWaypoint);
                            };
                        };
                    };

                    if (_currentIndex < _waypointCount) then {
                        for "_i" from _currentIndex to (_waypointCount - 1) do {[_i] call _captureWaypoint};
                    };
                    if (_isCycling && {_currentIndex > 1}) then {
                        for "_i" from 1 to ((_currentIndex min _waypointCount) - 1) do {[_i] call _captureWaypoint};
                    };

                    _state = [_targetGroup,_snapshot,[]];
                    [_logic,"opsApplyTakeoverWaypoints",[_targetGroup,"CLEAR",[]]] call MAINCLASS;
                };

                private _owners = _state select 2;
                _owners pushBackUnique _playerID;
                _state set [2,_owners];
                [_logic,_stateKey,_state] call ALiVE_fnc_hashSet;
                [_profile,"isPlayer",true] call ALiVE_fnc_hashSet;
                _result = true;
            };
        };

    };

    case "opsResumeProfileWaypoints": {

        if (_args isEqualType [] && {count _args >= 4}) then {
            _args params ["_playerID","_profileID","_profile","_targetGroup"];
            if (_profileID != "") then {
                private _stateKey = format ["opsInstantJoinWaypoints_%1",_profileID];
                private _state = [_logic,_stateKey,[]] call ALiVE_fnc_hashGet;
                private _stateWasFound = !(_state isEqualTo []);
                private _stillPlayerControlled = false;
                if !(_state isEqualTo []) then {
                    private _owners = _state select 2;
                    private _ownerIndex = _owners find _playerID;
                    if (_ownerIndex >= 0) then {_owners deleteAt _ownerIndex};
                    _stillPlayerControlled = !(_owners isEqualTo []);

                    if (_owners isEqualTo []) then {
                        private _resumeGroup = _targetGroup;
                        if (isNull _resumeGroup && {_profile isEqualType []} && {!(_profile isEqualTo [])}) then {
                            _resumeGroup = [_profile,"group",grpNull] call ALiVE_fnc_hashGet;
                        };
                        if (isNull _resumeGroup) then {_resumeGroup = _state select 0};
                        if (!isNull _resumeGroup) then {
                            [_logic,"opsApplyTakeoverWaypoints",[_resumeGroup,"RESTORE",_state select 1]] call MAINCLASS;
                        };
                        [_logic,_stateKey,[]] call ALiVE_fnc_hashSet;
                    } else {
                        _state set [2,_owners];
                        [_logic,_stateKey,_state] call ALiVE_fnc_hashSet;
                    };
                };

                if (_stateWasFound && {_profile isEqualType []} && {!(_profile isEqualTo [])}) then {
                    [_profile,"isPlayer",_stillPlayerControlled] call ALiVE_fnc_hashSet;
                };
            };
        };

    };

    case "opsRecreateTakeoverUnit": {

        // Unit creation must execute wherever the AI group is local. Dispatch
        // through the already-global SCOM module, then wait for a narrowly
        // addressed public result from that owner (server, HC, or player client).
        _result = [false,"INVALID_RECREATE_REQUEST",objNull];
        if (_args isEqualType [] && {count _args >= 6}) then {
            _args params ["_playerID","_targetGroup","_snapshot","_profileID","_profileIndex","_wasLeader"];
            if (!isNull _targetGroup && {_snapshot isEqualType []} && {count _snapshot >= 11}) then {
                private _attempt = 0;
                while {_attempt < 3 && {!(_result select 0)}} do {
                    _attempt = _attempt + 1;
                    private _resultKey = format ["ALiVE_SCOMRecreate_%1_%2_%3",_playerID,floor (diag_tickTime * 1000),floor (random 1000000000)];
                    missionNamespace setVariable [_resultKey,nil];
                    private _owner = groupOwner _targetGroup;
                    if (_owner < 2) then {_owner = 2};
                    private _event = ["OPS_RECREATE_TAKEOVER_UNIT",[
                        _resultKey,_targetGroup,_snapshot,_profileID,_profileIndex,_wasLeader
                    ]];
                    if (local _targetGroup) then {
                        _event call ALiVE_fnc_SCOMTabletEventToClient;
                    } else {
                        _event remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_owner];
                    };

                    private _deadline = diag_tickTime + 6;
                    waitUntil {
                        sleep 0.05;
                        !isNil {missionNamespace getVariable _resultKey} || {diag_tickTime >= _deadline}
                    };
                    private _ownerResult = missionNamespace getVariable [_resultKey,[]];
                    missionNamespace setVariable [_resultKey,nil];
                    if (_ownerResult isEqualType [] && {count _ownerResult >= 3}) then {
                        private _candidate = _ownerResult param [2,objNull,[objNull]];
                        if ((_ownerResult select 0) && {!isNull _candidate} && {alive _candidate} && {!isPlayer _candidate} && {group _candidate isEqualTo _targetGroup}) then {
                            _result = [true,"",_candidate];
                        } else {
                            _result = [false,_ownerResult param [1,"RECREATE_REJECTED",[""]],objNull];
                        };
                    } else {
                        _result = [false,"RECREATE_OWNER_TIMEOUT",objNull];
                    };
                };
            };
        };

    };

    case "opsTakeoverUnit": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_playerID","_selected"];
            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _prep = [_logic,_prepKey,[]] call ALiVE_fnc_hashGet;

            private _sendFailure = {
                params ["_message"];
                if (!isNull _player) then {
                    _player hideObjectGlobal false;
                    ["OPS_JOIN_HANDOFF_RESULT",[false,_message]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
                };
            };

            if (isNull _player || {isNull _selected} || {!alive _selected} || {isPlayer _selected}) exitWith {
                ["INVALID_TARGET"] call _sendFailure;
            };
            if (count _prep < 2) exitWith {["PREPARATION_EXPIRED"] call _sendFailure};
            private _existingSession = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            private _continuing = !(_existingSession isEqualTo []) && {
                ([_existingSession,"status",""] call ALiVE_fnc_hashGet) == "CHOOSING_REPLACEMENT"
            };
            if (!(_existingSession isEqualTo []) && {!_continuing}) exitWith {
                ["SESSION_ALREADY_ACTIVE"] call _sendFailure;
            };

            private _profile = _prep select 0;
            private _profileID = _prep select 1;
            if (isNil "_profile") exitWith {["PROFILE_UNAVAILABLE"] call _sendFailure};
            private _targetGroup = _profile select 2 select 13;
            if (isNull _targetGroup || {!(_selected in units _targetGroup)}) exitWith {
                ["TARGET_NO_LONGER_IN_GROUP"] call _sendFailure;
            };
            private _reservation = _selected getVariable ["ALiVE_SCOMTakeoverUID",""];
            // A death continuation still owns this session. A stale reservation
            // from that same player must not lock them out of the promoted unit;
            // reservations belonging to anyone else are still respected.
            if (_continuing && {_reservation == _playerID}) then {
                _selected setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                _reservation = "";
            };
            if (_reservation != "") exitWith {
                ["TARGET_ALREADY_RESERVED"] call _sendFailure;
            };

            private _captureVehicleRole = {
                params ["_unit"];
                private _vehicle = vehicle _unit;
                if (_vehicle isEqualTo _unit) exitWith {[objNull,[]]};
                private _rowIndex = (fullCrew [_vehicle,"",false]) findIf {(_x select 0) isEqualTo _unit};
                if (_rowIndex < 0) exitWith {[_vehicle,[]]};
                private _row = (fullCrew [_vehicle,"",false]) select _rowIndex;
                [_vehicle,[toLower (_row param [1,"",[""]]),_row param [2,-1,[0]],_row param [3,[],[[]]]]]
            };

            private _targetVehicleRole = [_selected] call _captureVehicleRole;
            private _originalVehicleRole = [_player] call _captureVehicleRole;
            private _originalGroup = group _player;
            private _originalSide = if (isNull _originalGroup) then {side _player} else {side _originalGroup};
            private _session = if (_continuing) then {_existingSession} else {[] call ALiVE_fnc_hashCreate};
            [_session,"profile",_profile] call ALiVE_fnc_hashSet;
            [_session,"profileID",_profileID] call ALiVE_fnc_hashSet;
            [_session,"player",_player] call ALiVE_fnc_hashSet;
            [_session,"selected",_selected] call ALiVE_fnc_hashSet;
            [_session,"targetGroup",_targetGroup] call ALiVE_fnc_hashSet;
            private _profileLeader = if (_profile isEqualType []) then {[_profile,"leader",objNull] call ALiVE_fnc_hashGet} else {objNull};
            // Group leadership can take a network frame to settle after the
            // previous player leader respawns. The profile reference is the
            // authoritative fallback during that short locality transition.
            private _targetWasLeader = ((leader _targetGroup) isEqualTo _selected) || {_profileLeader isEqualTo _selected};
            [_session,"targetWasLeader",_targetWasLeader] call ALiVE_fnc_hashSet;
            private _profileUnits = [_profile,"units",[]] call ALiVE_fnc_hashGet;
            private _profileIndex = if (_profileUnits isEqualType []) then {_profileUnits find _selected} else {-1};
            if (_profileIndex < 0) then {_profileIndex = _selected getVariable ["profileIndex",-1]};
            [_session,"profileIndex",_profileIndex] call ALiVE_fnc_hashSet;
            [_session,"selectedDeleted",false] call ALiVE_fnc_hashSet;
            [_session,"targetState",[
                getPosATL _selected,
                getDir _selected,
                [rank _selected,name _selected,face _selected,speaker _selected,pitch _selected],
                getUnitLoadout _selected,
                damage _selected,
                _targetVehicleRole select 0,
                _targetVehicleRole select 1
            ]] call ALiVE_fnc_hashSet;
            [_session,"targetSnapshot",[
                typeOf _selected,
                getPosATL _selected,
                getDir _selected,
                [rank _selected,name _selected,face _selected,speaker _selected,pitch _selected],
                getUnitLoadout _selected,
                damage _selected,
                _targetVehicleRole select 0,
                _targetVehicleRole select 1,
                skill _selected,
                unitPos _selected,
                _selected getVariable ["ALiVE_ignore_HC",false]
            ]] call ALiVE_fnc_hashSet;
            [_session,"originalGroup",_originalGroup] call ALiVE_fnc_hashSet;
            [_session,"originalSide",_originalSide] call ALiVE_fnc_hashSet;
            [_session,"originalWasLeader",!isNull _originalGroup && {(leader _originalGroup) isEqualTo _player}] call ALiVE_fnc_hashSet;
            [_session,"originalState",[
                getPosATL _player,
                getDir _player,
                [rank _player,name _player,face _player,speaker _player,pitch _player],
                getUnitLoadout _player,
                damage _player,
                _originalVehicleRole select 0,
                _originalVehicleRole select 1
            ]] call ALiVE_fnc_hashSet;
            [_session,"status","PREPARING"] call ALiVE_fnc_hashSet;
            [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;

            // AI commanders commonly lock their assigned vehicles. A scripted
            // move-in can bypass the general lock, but the player would then be
            // unable to dismount or re-enter. Unlock the vehicle and every seat
            // while it is still local to the server-owned AI crew.
            private _targetVehicle = _targetVehicleRole select 0;
            if (!isNull _targetVehicle) then {
                _targetVehicle setVehicleLock "UNLOCKED";
                if (local _targetVehicle) then {
                    _targetVehicle lockDriver false;
                    _targetVehicle lockCargo false;
                    {_targetVehicle lockTurret [_x,false]} forEach (allTurrets [_targetVehicle,true]);
                };
            };

            _selected setVariable ["ALiVE_SCOMTakeoverUID",_playerID,true];
            moveOut _selected;
            unassignVehicle _selected;
            _selected allowDamage false;
            _selected enableSimulationGlobal false;
            _selected hideObjectGlobal true;

            [_player] joinSilent _targetGroup;
            private _joinDeadline = diag_tickTime + 8;
            waitUntil {
                sleep 0.1;
                (group _player isEqualTo _targetGroup) || {diag_tickTime >= _joinDeadline}
            };

            if !(group _player isEqualTo _targetGroup) exitWith {
                _selected hideObjectGlobal false;
                _selected enableSimulationGlobal true;
                _selected allowDamage true;
                _selected setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                private _targetState = [_session,"targetState"] call ALiVE_fnc_hashGet;
                _targetState params ["_position","_direction","_identity","_loadout","_damage","_vehicle","_vehicleRole"];
                _selected setDir _direction;
                _selected setPosATL _position;
                if (!isNull _vehicle && {alive _vehicle} && {count _vehicleRole > 0}) then {
                    switch (toLower (_vehicleRole param [0,"",[""]])) do {
                        case "driver": {_selected assignAsDriver _vehicle; _selected moveInDriver _vehicle};
                        case "gunner": {_selected assignAsGunner _vehicle; _selected moveInGunner _vehicle};
                        case "commander": {_selected assignAsCommander _vehicle; _selected moveInCommander _vehicle};
                        case "turret": {
                            private _turretPath = _vehicleRole param [2,[],[[]]];
                            _selected assignAsTurret [_vehicle,_turretPath];
                            _selected moveInTurret [_vehicle,_turretPath];
                        };
                        case "cargo": {
                            private _cargoIndex = _vehicleRole param [1,-1,[0]];
                            if (_cargoIndex >= 0) then {
                                _selected assignAsCargoIndex [_vehicle,_cargoIndex];
                                _selected moveInCargo [_vehicle,_cargoIndex];
                            } else {
                                _selected assignAsCargo _vehicle;
                                _selected moveInCargo _vehicle;
                            };
                        };
                    };
                };
                if ([_session,"targetWasLeader",false] call ALiVE_fnc_hashGet) then {
                    [_logic,"opsApplyGroupLeadership",[_targetGroup,_selected,true]] call MAINCLASS;
                };
                if (!isNull _originalGroup) then {[_player] joinSilent _originalGroup};
                [_logic,_sessionKey,[]] call ALiVE_fnc_hashSet;
                ["GROUP_JOIN_FAILED"] call _sendFailure;
            };

            ["OPS_JOIN_HANDOFF",[
                _playerID,_player,_selected,_targetGroup,[_session,"targetState"] call ALiVE_fnc_hashGet
            ]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
        };

    };

    case "opsJoinHandoffComplete": {

        if (_args isEqualType [] && {count _args >= 3}) then {
            _args params ["_playerID","_selected","_success",["_failureReason",""]];
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            if !(_session isEqualTo []) then {
                private _player = [_session,"player",objNull] call ALiVE_fnc_hashGet;
                private _reserved = [_session,"selected",objNull] call ALiVE_fnc_hashGet;
                private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
                if (!isNull _player && {_reserved isEqualTo _selected}) then {
                    private _applied = _success && {group _player isEqualTo _targetGroup};
                    private _profile = [_session,"profile",[]] call ALiVE_fnc_hashGet;
                    private _profileIndex = [_session,"profileIndex",-1] call ALiVE_fnc_hashGet;

                    // Commit the replacement only after the client confirms that
                    // its real player object has inherited the target state. The
                    // selected AI is then genuinely removed; there is no hidden
                    // formation member or parked proxy left behind.
                    if (_applied && {!isNull _reserved}) then {
                        private _profileUnits = if (_profile isEqualType []) then {[_profile,"units",[]] call ALiVE_fnc_hashGet} else {[]};
                        if (_profileUnits isEqualType []) then {
                            private _foundIndex = _profileUnits find _reserved;
                            if (_foundIndex >= 0) then {_profileIndex = _foundIndex};
                        };
                        // Never commit the destructive half of the exchange unless
                        // the selected object can be replaced in its exact profile
                        // slot. That keeps a stale profile from losing a unit.
                        _applied = _profileUnits isEqualType [] && {_profileIndex >= 0} && {_profileIndex < count _profileUnits} && {
                            (_profileUnits select _profileIndex) isEqualTo _reserved
                        };
                        // Transfer leadership while the reserved AI still exists.
                        // Deleting a local group leader first makes Arma promote a
                        // temporary successor and can leave a dedicated server
                        // unable to select the player as leader on the next pass.
                        if (_applied && {[_session,"targetWasLeader",false] call ALiVE_fnc_hashGet}) then {
                            private _leaderDeadline = diag_tickTime + 8;
                            private _nextLeaderAttempt = 0;
                            waitUntil {
                                sleep 0.1;
                                if (diag_tickTime >= _nextLeaderAttempt) then {
                                    [_logic,"opsApplyGroupLeadership",[_targetGroup,_player,true]] call MAINCLASS;
                                    _nextLeaderAttempt = diag_tickTime + 0.5;
                                };
                                (leader _targetGroup isEqualTo _player) || {diag_tickTime >= _leaderDeadline}
                            };
                            _applied = leader _targetGroup isEqualTo _player;
                        };
                        if (_applied) then {
                            _reserved allowDamage false;
                            _reserved hideObjectGlobal true;
                            deleteVehicle _reserved;
                            private _deleteDeadline = diag_tickTime + 3;
                            waitUntil {
                                sleep 0.05;
                                isNull _reserved || {isNull (group _reserved)} || {diag_tickTime >= _deleteDeadline}
                            };
                            _applied = isNull _reserved || {isNull (group _reserved)};
                        };

                        if (_applied) then {
                            _profileUnits set [_profileIndex,_player];
                            [_profile,"units",_profileUnits] call ALiVE_fnc_hashSet;
                            _player setVariable ["profileID",[_session,"profileID",""] call ALiVE_fnc_hashGet,true];
                            _player setVariable ["profileIndex",_profileIndex,true];
                            private _savedSnapshot = [_session,"targetSnapshot",[]] call ALiVE_fnc_hashGet;
                            _player setVariable ["ALiVE_ignore_HC",_savedSnapshot param [10,false,[true]],true];
                            [_session,"profileIndex",_profileIndex] call ALiVE_fnc_hashSet;
                            [_session,"selected",objNull] call ALiVE_fnc_hashSet;
                            [_session,"selectedDeleted",true] call ALiVE_fnc_hashSet;
                        };
                    };

                    if (_applied && {[_session,"targetWasLeader",false] call ALiVE_fnc_hashGet}) then {
                        private _leaderDeadline = diag_tickTime + 8;
                        private _nextLeaderAttempt = 0;
                        waitUntil {
                            sleep 0.1;
                            if (diag_tickTime >= _nextLeaderAttempt) then {
                                [_logic,"opsApplyGroupLeadership",[_targetGroup,_player,true]] call MAINCLASS;
                                _nextLeaderAttempt = diag_tickTime + 0.5;
                            };
                            (leader _targetGroup isEqualTo _player) || {diag_tickTime >= _leaderDeadline}
                        };
                        _applied = leader _targetGroup isEqualTo _player;
                        if (_applied && {_profile isEqualType []}) then {
                            [_profile,"leader",_player] call ALiVE_fnc_hashSet;
                        };
                    };

                    if (_applied) then {
                        private _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
                        [_logic,"opsSuspendProfileWaypoints",[_playerID,_profileID,_profile,_targetGroup]] call MAINCLASS;
                        _player hideObjectGlobal false;
                        [_session,"status","ACTIVE"] call ALiVE_fnc_hashSet;
                        [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                    } else {
                        [_session,"status","FAILED"] call ALiVE_fnc_hashSet;
                        [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                    };
                    ["OPS_JOIN_HANDOFF_RESULT",[_applied,if (_applied) then {"ACTIVE"} else {if (_failureReason != "") then {_failureReason} else {"HANDOFF_FAILED"}}]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
                };
            };
        };

    };

    case "opsJoinPlayerKilled": {

        if (_args isEqualType [] && {count _args >= 1}) then {
            private _playerID = _args select 0;
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            if !(_session isEqualTo []) then {
                private _status = [_session,"status",""] call ALiVE_fnc_hashGet;
                if !(_status in ["AWAITING_RESPAWN","CHOOSING_REPLACEMENT"]) then {
                    private _player = [_session,"player",objNull] call ALiVE_fnc_hashGet;
                    private _selected = [_session,"selected",objNull] call ALiVE_fnc_hashGet;
                    private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;

                    private _profile = [_session,"profile",[]] call ALiVE_fnc_hashGet;
                    private _selectedDeleted = [_session,"selectedDeleted",false] call ALiVE_fnc_hashGet;

                    // Once committed, the player occupies the selected AI's
                    // profile slot. A player death is therefore the one real role
                    // casualty; no second, hidden AI corpse needs to be manufactured.
                    if (_selectedDeleted && {!isNull _player} && {_profile isEqualType []}) then {
                        private _profileUnits = [_profile,"units",[]] call ALiVE_fnc_hashGet;
                        if (_profileUnits isEqualType [] && {_player in _profileUnits}) then {
                            [_profile,"handleDeath",_player] call ALiVE_fnc_profileEntity;
                        };
                        _player setVariable ["profileID",nil,true];
                        _player setVariable ["profileIndex",nil,true];
                        _player setVariable ["ALiVE_ignore_HC",nil,true];
                    } else {
                        // A pre-commit handoff failure still owns a real selected
                        // AI. Put it back into service rather than deleting it.
                        if (!isNull _selected) then {
                        _selected enableSimulationGlobal true;
                        _selected hideObjectGlobal false;
                        _selected allowDamage true;
                        _selected setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                        };
                    };

                    if (!isNull _targetGroup) then {
                        // Only remove a reservation left by this exact session.
                        // This also clears a stale value left by an interrupted
                        // handoff before the successor was promoted.
                        {
                            if ((_x getVariable ["ALiVE_SCOMTakeoverUID",""]) == _playerID) then {
                                _x setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                            };
                        } forEach units _targetGroup;

                        private _nextLeaderIndex = (units _targetGroup) findIf {
                            alive _x && {!isPlayer _x} && {simulationEnabled _x}
                        };
                        if (_nextLeaderIndex >= 0) then {
                            private _nextLeader = (units _targetGroup) select _nextLeaderIndex;
                            [_session,"replacementLeader",_nextLeader] call ALiVE_fnc_hashSet;
                            [_logic,"opsApplyGroupLeadership",[_targetGroup,_nextLeader,true]] call MAINCLASS;
                            if (_profile isEqualType []) then {[_profile,"leader",_nextLeader] call ALiVE_fnc_hashSet};
                        };
                    };

                    [_session,"selected",objNull] call ALiVE_fnc_hashSet;
                    [_session,"status","AWAITING_RESPAWN"] call ALiVE_fnc_hashSet;
                    [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                };
            };
        };

    };

    case "opsJoinPlayerRespawned": {

        if (_args isEqualType [] && {count _args >= 1}) then {
            private _playerID = _args select 0;
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _session = [];
            private _sessionDeadline = diag_tickTime + 10;

            waitUntil {
                sleep 0.05;
                _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
                !(_session isEqualTo []) || {diag_tickTime >= _sessionDeadline}
            };

            private _reportedPlayer = _args param [1,objNull,[objNull]];
            private _player = objNull;
            if (!isNull _reportedPlayer && {alive _reportedPlayer} && {getPlayerUID _reportedPlayer == _playerID}) then {
                _player = _reportedPlayer;
            } else {
                _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            };
            if (isNull _player) exitWith {};

            private _sendReplacementChooser = {
                params ["_session","_player"];
                private _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
                private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
                private _availableUnits = [];
                if (!isNull _targetGroup) then {
                    _availableUnits = (units _targetGroup) select {
                        alive _x && {!isPlayer _x} && {simulationEnabled _x} &&
                        {(_x getVariable ["ALiVE_SCOMTakeoverUID",""]) == ""}
                    };
                };
                _player hideObjectGlobal true;
                ["OPS_JOIN_RESPAWN_READY",[_playerID,_profileID,_player,_availableUnits]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            if (_session isEqualTo []) exitWith {
                _player hideObjectGlobal false;
                ["OPS_JOIN_RESPAWN_READY",[_playerID,"",_player,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            private _status = [_session,"status",""] call ALiVE_fnc_hashGet;
            if (_status == "CHOOSING_REPLACEMENT") exitWith {
                [_session,_player] call _sendReplacementChooser;
            };
            if (_status == "RESPAWN_PROCESSING") exitWith {};
            if (_status != "AWAITING_RESPAWN") then {
                private _previousPlayer = [_session,"player",objNull] call ALiVE_fnc_hashGet;
                if (isNull _previousPlayer || {!alive _previousPlayer}) then {
                    [_logic,"opsJoinPlayerKilled",[_playerID,_previousPlayer]] call MAINCLASS;
                    _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
                    _status = [_session,"status",""] call ALiVE_fnc_hashGet;
                };
            };

            if (_status != "AWAITING_RESPAWN") exitWith {
                _player hideObjectGlobal false;
                ["OPS_JOIN_RESPAWN_READY",[_playerID,"",_player,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            // Serialize the client Respawn EH and the dedicated-server
            // OnUserSelectedPlayer fallback. Whichever arrives first owns this
            // transition; a later duplicate can safely reuse the chooser state.
            [_session,"status","RESPAWN_PROCESSING"] call ALiVE_fnc_hashSet;
            [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;

            private _profile = [_session,"profile"] call ALiVE_fnc_hashGet;
            private _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
            private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
            private _originalGroup = [_session,"originalGroup",grpNull] call ALiVE_fnc_hashGet;
            private _originalSide = [_session,"originalSide",side _player] call ALiVE_fnc_hashGet;

            // A mission respawn can inherit the takeover group. Detach the new
            // body on the server before the chooser appears, while leaving the
            // exact ALiVE profile pinned and physical.
            if (isNull _originalGroup) then {
                _originalGroup = createGroup _originalSide;
            };
            [_player] joinSilent _originalGroup;
            private _joinDeadline = diag_tickTime + 8;
            waitUntil {
                sleep 0.1;
                (group _player isEqualTo _originalGroup) || {diag_tickTime >= _joinDeadline}
            };
            if !(group _player isEqualTo _originalGroup) then {
                _originalGroup = createGroup _originalSide;
                [_player] joinSilent _originalGroup;
                _joinDeadline = diag_tickTime + 8;
                waitUntil {
                    sleep 0.1;
                    (group _player isEqualTo _originalGroup) || {diag_tickTime >= _joinDeadline}
                };
            };

            if !(group _player isEqualTo _originalGroup) exitWith {
                [_session,"status","AWAITING_RESPAWN"] call ALiVE_fnc_hashSet;
                [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                _player hideObjectGlobal false;
                ["OPS_JOIN_RESPAWN_READY",[_playerID,"",_player,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            // The killed player may have owned the AI group when succession was
            // first requested. Once the respawn body has been detached, repeat
            // and verify the promotion before presenting the chooser. This makes
            // the successor stable on a dedicated server and keeps the profile's
            // leader reference in sync with the engine group.
            if (!isNull _targetGroup) then {
                {
                    if ((_x getVariable ["ALiVE_SCOMTakeoverUID",""]) == _playerID) then {
                        _x setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                    };
                } forEach units _targetGroup;

                private _replacementLeader = [_session,"replacementLeader",objNull] call ALiVE_fnc_hashGet;
                if (isNull _replacementLeader || {!alive _replacementLeader} || {!(_replacementLeader in units _targetGroup)} || {isPlayer _replacementLeader}) then {
                    private _currentLeader = leader _targetGroup;
                    if (!isNull _currentLeader && {alive _currentLeader} && {!isPlayer _currentLeader} && {_currentLeader in units _targetGroup}) then {
                        _replacementLeader = _currentLeader;
                    } else {
                        private _replacementIndex = (units _targetGroup) findIf {
                            alive _x && {!isPlayer _x} && {simulationEnabled _x}
                        };
                        _replacementLeader = if (_replacementIndex >= 0) then {(units _targetGroup) select _replacementIndex} else {objNull};
                    };
                };

                if (!isNull _replacementLeader) then {
                    private _leaderDeadline = diag_tickTime + 8;
                    private _nextLeaderAttempt = 0;
                    waitUntil {
                        sleep 0.1;
                        if (diag_tickTime >= _nextLeaderAttempt) then {
                            [_logic,"opsApplyGroupLeadership",[_targetGroup,_replacementLeader,true]] call MAINCLASS;
                            _nextLeaderAttempt = diag_tickTime + 0.5;
                        };
                        (leader _targetGroup isEqualTo _replacementLeader) || {diag_tickTime >= _leaderDeadline}
                    };

                    private _settledLeader = leader _targetGroup;
                    if (!isNull _settledLeader && {alive _settledLeader} && {!isPlayer _settledLeader}) then {
                        _replacementLeader = _settledLeader;
                    };
                    [_session,"replacementLeader",_replacementLeader] call ALiVE_fnc_hashSet;
                    if (_profile isEqualType []) then {[_profile,"leader",_replacementLeader] call ALiVE_fnc_hashSet};
                };
            };

            private _captureVehicleRole = {
                params ["_unit"];
                private _vehicle = vehicle _unit;
                if (_vehicle isEqualTo _unit) exitWith {[objNull,[]]};
                private _rowIndex = (fullCrew [_vehicle,"",false]) findIf {(_x select 0) isEqualTo _unit};
                if (_rowIndex < 0) exitWith {[_vehicle,[]]};
                private _row = (fullCrew [_vehicle,"",false]) select _rowIndex;
                [_vehicle,[toLower (_row param [1,"",[""]]),_row param [2,-1,[0]],_row param [3,[],[[]]]]]
            };
            private _originalVehicleRole = [_player] call _captureVehicleRole;

            _player hideObjectGlobal true;
            [_session,"player",_player] call ALiVE_fnc_hashSet;
            [_session,"selected",objNull] call ALiVE_fnc_hashSet;
            [_session,"originalGroup",_originalGroup] call ALiVE_fnc_hashSet;
            [_session,"originalSide",_originalSide] call ALiVE_fnc_hashSet;
            [_session,"originalState",[
                getPosATL _player,
                getDir _player,
                [rank _player,name _player,face _player,speaker _player,pitch _player],
                getUnitLoadout _player,
                damage _player,
                _originalVehicleRole select 0,
                _originalVehicleRole select 1
            ]] call ALiVE_fnc_hashSet;
            [_session,"status","CHOOSING_REPLACEMENT"] call ALiVE_fnc_hashSet;
            [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;

            [_session,_player] call _sendReplacementChooser;
        };

    };

    case "opsCleanupJoin": {

        if (_args isEqualType [] && {count _args >= 1}) then {
            private _playerID = _args select 0;
            private _disconnectUnit = _args param [1,objNull,[objNull]];
            private _disconnectState = _args param [2,[],[[]]];
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            private _profileID = "";
            private _cleanupComplete = true;

            if !(_session isEqualTo []) then {
                _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
                private _selected = [_session,"selected",objNull] call ALiVE_fnc_hashGet;
                private _source = [_session,"player",_disconnectUnit] call ALiVE_fnc_hashGet;
                private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
                private _profile = [_session,"profile",[]] call ALiVE_fnc_hashGet;
                private _status = [_session,"status",""] call ALiVE_fnc_hashGet;
                private _selectedDeleted = [_session,"selectedDeleted",false] call ALiVE_fnc_hashGet;
                private _currentState = [_session,"currentTargetState",[]] call ALiVE_fnc_hashGet;
                if (_status != "RESTORING" && {count _disconnectState >= 6}) then {
                    _currentState = _disconnectState select [0,6];
                };

                if (_selectedDeleted && {_status in ["ACTIVE","FAILED","RESTORING","RECREATE_FAILED"]}) then {
                    private _sourceAlive = if (count _disconnectState >= 7) then {_disconnectState select 6} else {!isNull _source && {alive _source}};
                    if (!_sourceAlive) then {
                        if (!isNull _source && {_profile isEqualType []}) then {
                            private _profileUnits = [_profile,"units",[]] call ALiVE_fnc_hashGet;
                            if (_profileUnits isEqualType [] && {_source in _profileUnits}) then {
                                [_profile,"handleDeath",_source] call ALiVE_fnc_profileEntity;
                            };
                        };
                    } else {
                        private _snapshot = +([_session,"targetSnapshot",[]] call ALiVE_fnc_hashGet);
                        if (count _snapshot >= 11 && {count _currentState >= 6}) then {
                            _snapshot set [1,_currentState select 0];
                            _snapshot set [2,_currentState select 1];
                            _snapshot set [4,_currentState select 2];
                            _snapshot set [5,_currentState select 3];
                            _snapshot set [6,_currentState select 4];
                            _snapshot set [7,_currentState select 5];
                        };
                        if (!isNull _source) then {moveOut _source; unassignVehicle _source};
                        private _profileUnits = if (_profile isEqualType []) then {[_profile,"units",[]] call ALiVE_fnc_hashGet} else {[]};
                        private _profileIndex = if (_profileUnits isEqualType []) then {_profileUnits find _source} else {-1};
                        if (_profileIndex < 0) then {_profileIndex = [_session,"profileIndex",-1] call ALiVE_fnc_hashGet};
                        private _recreate = [_logic,"opsRecreateTakeoverUnit",[
                            _playerID,_targetGroup,_snapshot,_profileID,_profileIndex,[_session,"targetWasLeader",false] call ALiVE_fnc_hashGet
                        ]] call MAINCLASS;
                        _cleanupComplete = _recreate select 0;
                        if (_cleanupComplete) then {
                            private _replacement = _recreate select 2;
                            if (_profileUnits isEqualType [] && {_profileIndex >= 0} && {_profileIndex < count _profileUnits}) then {
                                _profileUnits set [_profileIndex,_replacement];
                                [_profile,"units",_profileUnits] call ALiVE_fnc_hashSet;
                            };
                            if ([_session,"targetWasLeader",false] call ALiVE_fnc_hashGet && {_profile isEqualType []} && {!(_profile isEqualTo [])}) then {
                                [_profile,"leader",_replacement] call ALiVE_fnc_hashSet
                            };
                        } else {
                            [_session,"status","RECREATE_FAILED"] call ALiVE_fnc_hashSet;
                            [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                        };
                    };
                } else {
                    // The handoff had not committed yet, so the original object
                    // still exists and only needs to be made physical again.
                    if (!isNull _selected) then {
                        _selected enableSimulationGlobal true;
                        _selected hideObjectGlobal false;
                        _selected allowDamage true;
                        _selected setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                        if ([_session,"targetWasLeader",false] call ALiVE_fnc_hashGet) then {
                            [_logic,"opsApplyGroupLeadership",[_targetGroup,_selected,true]] call MAINCLASS;
                        };
                    };
                };

                if (!isNull _source) then {
                    _source setVariable ["profileID",nil,true];
                    _source setVariable ["profileIndex",nil,true];
                    _source setVariable ["ALiVE_ignore_HC",nil,true];
                };
                if (_cleanupComplete) then {
                    [_logic,"opsResumeProfileWaypoints",[_playerID,_profileID,_profile,_targetGroup]] call MAINCLASS;
                };
            } else {
                private _prep = [_logic,_prepKey,[]] call ALiVE_fnc_hashGet;
                if (count _prep >= 2) then {_profileID = _prep select 1};
            };

            if (_cleanupComplete && {_profileID != ""}) then {
                [_logic,"opsReleaseProfilePin",[_playerID,_profileID]] call MAINCLASS;
            };
            if (_cleanupComplete) then {
                [_logic,format ["opsInstantJoinCancelled_%1",_playerID],true] call ALiVE_fnc_hashSet;
                [_logic,_prepKey,[]] call ALiVE_fnc_hashSet;
                [_logic,_sessionKey,[]] call ALiVE_fnc_hashSet;
            };
        };

    };

    case "opsCancelJoinActive": {

        if (_args isEqualType [] && {count _args >= 1}) then {
            private _playerID = _args select 0;
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;

            if (_session isEqualTo []) exitWith {
                private _position = if (isNull _player) then {[]} else {getPosATL _player};
                [_logic,"opsCancelJoinPrep",[_playerID,_position]] call MAINCLASS;
                if (!isNull _player) then {
                    _player allowDamage true;
                    ["OPS_JOIN_RESTORE_RESULT",[true,"NO_ACTIVE_SESSION"]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
                };
            };

            _player = [_session,"player",_player] call ALiVE_fnc_hashGet;
            private _selected = [_session,"selected",objNull] call ALiVE_fnc_hashGet;

            if (isNull _player || {!alive _player}) exitWith {
                [_logic,"opsJoinPlayerKilled",[_playerID,_player]] call MAINCLASS;
            };

            private _status = [_session,"status",""] call ALiVE_fnc_hashGet;
            if (_status == "RESTORING") exitWith {};
            if (_status in ["AWAITING_RESPAWN","RESPAWN_PROCESSING","CHOOSING_REPLACEMENT"]) exitWith {
                private _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
                private _profile = [_session,"profile",[]] call ALiVE_fnc_hashGet;
                private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
                [_logic,"opsResumeProfileWaypoints",[_playerID,_profileID,_profile,_targetGroup]] call MAINCLASS;
                if (_profileID != "") then {[_logic,"opsReleaseProfilePin",[_playerID,_profileID]] call MAINCLASS};
                _player hideObjectGlobal false;
                _player allowDamage true;
                _player setVariable ["profileID",nil,true];
                _player setVariable ["profileIndex",nil,true];
                _player setVariable ["ALiVE_ignore_HC",nil,true];
                [_logic,_prepKey,[]] call ALiVE_fnc_hashSet;
                [_logic,_sessionKey,[]] call ALiVE_fnc_hashSet;
                ["OPS_JOIN_RESTORE_RESULT",[true,"CANCELLED_REPLACEMENT_SELECTION"]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            private _captureVehicleRole = {
                params ["_unit"];
                private _vehicle = vehicle _unit;
                if (_vehicle isEqualTo _unit) exitWith {[objNull,[]]};
                private _rowIndex = (fullCrew [_vehicle,"",false]) findIf {(_x select 0) isEqualTo _unit};
                if (_rowIndex < 0) exitWith {[_vehicle,[]]};
                private _row = (fullCrew [_vehicle,"",false]) select _rowIndex;
                [_vehicle,[toLower (_row param [1,"",[""]]),_row param [2,-1,[0]],_row param [3,[],[[]]]]]
            };
            private _currentVehicleRole = [_player] call _captureVehicleRole;
            [_session,"currentTargetState",[
                getPosATL _player,getDir _player,getUnitLoadout _player,damage _player,
                _currentVehicleRole select 0,_currentVehicleRole select 1
            ]] call ALiVE_fnc_hashSet;

            private _originalGroup = [_session,"originalGroup",grpNull] call ALiVE_fnc_hashGet;
            if (isNull _originalGroup) then {
                _originalGroup = createGroup ([_session,"originalSide",side _player] call ALiVE_fnc_hashGet);
                [_session,"originalGroup",_originalGroup] call ALiVE_fnc_hashSet;
            };

            [_player] joinSilent _originalGroup;
            private _joinDeadline = diag_tickTime + 8;
            waitUntil {
                sleep 0.1;
                (group _player isEqualTo _originalGroup) || {diag_tickTime >= _joinDeadline}
            };

            if !(group _player isEqualTo _originalGroup) exitWith {
                ["OPS_JOIN_RESTORE_RESULT",[false,"ORIGINAL_GROUP_JOIN_FAILED"]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
            };

            [_session,"status","RESTORING"] call ALiVE_fnc_hashSet;
            [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
            ["OPS_JOIN_RESTORE",[
                _playerID,_player,_originalGroup,[_session,"originalState"] call ALiVE_fnc_hashGet
            ]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
        };

    };

    case "opsJoinRestoreComplete": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_playerID","_success"];
            private _sessionKey = format ["opsInstantJoinSession_%1",_playerID];
            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _session = [_logic,_sessionKey,[]] call ALiVE_fnc_hashGet;
            if !(_session isEqualTo []) then {
                private _player = [_session,"player",objNull] call ALiVE_fnc_hashGet;
                private _selected = [_session,"selected",objNull] call ALiVE_fnc_hashGet;
                private _targetGroup = [_session,"targetGroup",grpNull] call ALiVE_fnc_hashGet;
                private _currentState = [_session,"currentTargetState",[]] call ALiVE_fnc_hashGet;
                private _profile = [_session,"profile",[]] call ALiVE_fnc_hashGet;
                private _profileID = [_session,"profileID",""] call ALiVE_fnc_hashGet;
                private _roleRestored = true;

                if ([_session,"selectedDeleted",false] call ALiVE_fnc_hashGet) then {
                    _roleRestored = count _currentState >= 6;
                    private _snapshot = +([_session,"targetSnapshot",[]] call ALiVE_fnc_hashGet);
                    if (_roleRestored && {count _snapshot >= 11}) then {
                        _snapshot set [1,_currentState select 0];
                        _snapshot set [2,_currentState select 1];
                        _snapshot set [4,_currentState select 2];
                        _snapshot set [5,_currentState select 3];
                        _snapshot set [6,_currentState select 4];
                        _snapshot set [7,_currentState select 5];

                        private _profileUnits = if (_profile isEqualType []) then {[_profile,"units",[]] call ALiVE_fnc_hashGet} else {[]};
                        private _profileIndex = if (_profileUnits isEqualType []) then {_profileUnits find _player} else {-1};
                        if (_profileIndex < 0) then {_profileIndex = [_session,"profileIndex",-1] call ALiVE_fnc_hashGet};
                        private _recreate = [_logic,"opsRecreateTakeoverUnit",[
                            _playerID,_targetGroup,_snapshot,_profileID,_profileIndex,[_session,"targetWasLeader",false] call ALiVE_fnc_hashGet
                        ]] call MAINCLASS;
                        _roleRestored = _recreate select 0;
                        if (_roleRestored) then {
                            _selected = _recreate select 2;
                            if (_profileUnits isEqualType [] && {_profileIndex >= 0} && {_profileIndex < count _profileUnits}) then {
                                _profileUnits set [_profileIndex,_selected];
                                [_profile,"units",_profileUnits] call ALiVE_fnc_hashSet;
                            };
                            if ([_session,"targetWasLeader",false] call ALiVE_fnc_hashGet && {_profile isEqualType []} && {!(_profile isEqualTo [])}) then {
                                [_profile,"leader",_selected] call ALiVE_fnc_hashSet
                            };
                            [_session,"selected",_selected] call ALiVE_fnc_hashSet;
                        };
                    } else {
                        _roleRestored = false;
                    };
                    _success = _success && _roleRestored;
                };

                if (!([_session,"selectedDeleted",false] call ALiVE_fnc_hashGet) && {!isNull _selected} && {count _currentState >= 6}) then {
                    if (!isNull _targetGroup && {!(_selected in units _targetGroup)}) then {
                        [_selected] joinSilent _targetGroup;
                        private _joinDeadline = diag_tickTime + 8;
                        waitUntil {
                            sleep 0.1;
                            (group _selected isEqualTo _targetGroup) || {diag_tickTime >= _joinDeadline}
                        };
                        _success = _success && {group _selected isEqualTo _targetGroup};
                    };
                    _currentState params ["_position","_direction","_loadout","_damage","_vehicle","_vehicleRole"];
                    _selected enableSimulationGlobal true;
                    moveOut _selected;
                    unassignVehicle _selected;
                    if (count _loadout > 0) then {_selected setUnitLoadout _loadout};
                    _selected setDir _direction;
                    _selected setPosATL _position;
                    _selected setDamage (_damage min 0.95);

                    if (!isNull _vehicle && {alive _vehicle} && {count _vehicleRole > 0}) then {
                        private _roleKind = toLower (_vehicleRole param [0,"",[""]]);
                        switch (_roleKind) do {
                            case "driver": {_selected assignAsDriver _vehicle; _selected moveInDriver _vehicle};
                            case "gunner": {_selected assignAsGunner _vehicle; _selected moveInGunner _vehicle};
                            case "commander": {_selected assignAsCommander _vehicle; _selected moveInCommander _vehicle};
                            case "turret": {
                                private _turretPath = _vehicleRole param [2,[],[[]]];
                                _selected assignAsTurret [_vehicle,_turretPath];
                                _selected moveInTurret [_vehicle,_turretPath];
                            };
                            case "cargo": {
                                private _cargoIndex = _vehicleRole param [1,-1,[0]];
                                if (_cargoIndex >= 0) then {
                                    _selected assignAsCargoIndex [_vehicle,_cargoIndex];
                                    _selected moveInCargo [_vehicle,_cargoIndex];
                                } else {
                                    _selected assignAsCargo _vehicle;
                                    _selected moveInCargo _vehicle;
                                };
                            };
                        };
                    };

                    _selected allowDamage true;
                    _selected hideObjectGlobal false;
                    _selected setVariable ["ALiVE_SCOMTakeoverUID",nil,true];
                    if (!isNull _targetGroup && {[_session,"targetWasLeader",false] call ALiVE_fnc_hashGet}) then {
                        [_logic,"opsApplyGroupLeadership",[_targetGroup,_selected,true]] call MAINCLASS;
                    };
                };

                private _originalGroup = [_session,"originalGroup",grpNull] call ALiVE_fnc_hashGet;
                if (!isNull _player) then {
                    _player hideObjectGlobal false;
                    if (_roleRestored) then {
                        _player setVariable ["profileID",nil,true];
                        _player setVariable ["profileIndex",nil,true];
                        _player setVariable ["ALiVE_ignore_HC",nil,true];
                    };
                    if (!isNull _originalGroup && {[_session,"originalWasLeader",false] call ALiVE_fnc_hashGet}) then {
                        [_logic,"opsApplyGroupLeadership",[_originalGroup,_player,true]] call MAINCLASS;
                    };
                };

                if (_roleRestored) then {
                    [_logic,"opsResumeProfileWaypoints",[_playerID,_profileID,_profile,_targetGroup]] call MAINCLASS;
                    if (_profileID != "") then {
                        [_logic,"opsReleaseProfilePin",[_playerID,_profileID]] call MAINCLASS;
                    };
                    [_logic,_prepKey,[]] call ALiVE_fnc_hashSet;
                    [_logic,_sessionKey,[]] call ALiVE_fnc_hashSet;
                } else {
                    [_session,"status","RECREATE_FAILED"] call ALiVE_fnc_hashSet;
                    [_logic,_sessionKey,_session] call ALiVE_fnc_hashSet;
                };

                if (!isNull _player) then {
                    ["OPS_JOIN_RESTORE_RESULT",[_success,if (_success) then {"RESTORED"} else {"RESTORE_FAILED"}]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient",_player];
                };
            };
        };

    };

    case "opsCancelJoinPrep": {

        if (_args isEqualType [] && {count _args >= 2}) then {
            _args params ["_playerID","_initialPosition"];
            [_logic,format ["opsInstantJoinCancelled_%1",_playerID],true] call ALiVE_fnc_hashSet;
            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;

            private _prepKey = format ["opsInstantJoinPrep_%1",_playerID];
            private _prep = [_logic,_prepKey,[]] call ALiVE_fnc_hashGet;
            if (count _prep >= 2) then {
                [_logic,"opsReleaseProfilePin",[_playerID,_prep select 1]] call MAINCLASS;
                [_logic,_prepKey,[]] call ALiVE_fnc_hashSet;
            };

            if (!isNull _player) then {
                if (_initialPosition isEqualType [] && {count _initialPosition >= 2}) then {
                    _player setPos _initialPosition;
                };
                _player hideObjectGlobal false;
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

                if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

                // enforce the Spectate toggle server-side, not just in the UI
                if !([_logic,"scomOpsAllowSpectate",false] call ALiVE_fnc_hashGet) exitwith {
                    private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                    ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                };

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

        if (_args isEqualType []) then {

            _args params [["_playerID","",[""]],["_profileID","",[""]],["_lock",false,[false]]];

            private _profile = [MOD(profileHandler),"getProfile", _profileID] call ALiVE_fnc_profileHandler;

            if (isnil "_profile") exitwith {
                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
            };

            if !([_logic,"opsCallerAuthorizedForProfile",[_playerID,_profile]] call MAINCLASS) exitwith {
                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPS_RESET", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
            };

            [_profile,"busy", _lock] call ALiVE_fnc_hashSet;

            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            ["OPS_GROUP_LOCK_UPDATED", [_playerID,[_profileID,_lock]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

        };

    };

    case "intelTypeSelected": {

        if (_args isEqualType []) then {

            _args params ["_playerID","_type","_limit","_side","_faction"];

            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // never trust the client-sent limit/side/faction - re-derive from the
            // caller against the authoritative Intel-tab limit

            _limit = [_logic,"intelLimit","SIDE"] call ALiVE_fnc_hashGet;
            private _callerPlayer = [_playerID] call ALiVE_fnc_getPlayerByUID;
            if (isNull _callerPlayer) exitWith {};
            _side = [_logic,"opsPlayerSideText",_callerPlayer] call MAINCLASS;
            _faction = faction _callerPlayer;

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

                    // enforce the Image Intelligence toggle server-side, not just in the UI
                    if !([_logic,"scomOpsAllowImageIntelligence",false] call ALiVE_fnc_hashGet) exitwith {
                        private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                        ["IMINT_SOURCES_AVAILABLE", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
                    };

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

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]]];

            if (count _selOpcom < 1) exitWith {};

            private _selOpcomID = (_selOpcom select 0);
            private _debug = [_logic,"debug"] call ALiVE_fnc_hashGet;

            // authorize the caller for this commander before returning objective intel
            private _authOpcom = [_logic,"opsFindOPCOM", _selOpcomID] call MAINCLASS;
            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_authOpcom,"intelLimit"]] call MAINCLASS) exitWith {
                private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
                ["OPCOM_OBJECTIVES", [_playerID,[]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];
            };

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

    case "opsFindOPCOM": {

        // resolve a selected-opcom ID to its live OPCOM handler, nil if gone

        private _selOpcomID = _args;

        if !(_selOpcomID isEqualType "") exitWith {};   // crafted non-string id - treat as not found

        if (!isnil "OPCOM_instances") then {
            private _index = OPCOM_instances findIf { ([_x,"opcomID",""] call ALiVE_fnc_hashGet) == _selOpcomID };
            if (_index != -1) then {
                _result = OPCOM_instances select _index;
            };
        };

    };

    case "opsPlayerSideText": {

        // ALiVE side text (EAST/WEST/GUER) for a player unit - server-side mirror
        // of the client chain in fnc_SCOM init (keep the two in sync)

        private _unit = _args;
        _result = "";

        if (isNull _unit) exitWith {};

        private _sideNumber = [side group _unit] call ALIVE_fnc_sideObjectToNumber;
        private _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;

        if (_sideText == "CIV") then {
            private _factionSide = (faction _unit) call ALiVE_fnc_factionSide;
            _sideNumber = [_factionSide] call ALIVE_fnc_sideObjectToNumber;
            _sideText = [_sideNumber] call ALIVE_fnc_sideNumberToText;
        };

        _result = _sideText;

    };

    case "opsCallerAuthorizedForOpcom": {

        // may the authenticated player direct or inspect this already-resolved
        // commander, under the server-side limit at _limitKey ("opsLimit" for the
        // Ops tab, "intelLimit" for the Intel tab). "ALL" is the GM cross-side mode

        _args params ["_playerID","_opcom",["_limitKey","opsLimit",[""]]];

        _result = true;

        if (isnil "_opcom") exitWith {};    // no commander to protect - the op's own missing path answers

        private _limit = [_logic,_limitKey,"SIDE"] call ALiVE_fnc_hashGet;
        if (_limit == "ALL") exitWith {};

        _result = false;

        private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
        if (isNull _player) exitWith {};

        if (_limit == "FACTION") then {
            _result = (faction _player) in ([_opcom,"factions",[]] call ALiVE_fnc_hashGet);
        } else {
            _result = ([_logic,"opsPlayerSideText",_player] call MAINCLASS) == ([_opcom,"side",""] call ALiVE_fnc_hashGet);
        };

    };

    case "opsCallerAuthorizedForProfile": {

        // gate for group/profile ops - honours the same limit the list builder used
        // (ALL passes, FACTION compares faction, otherwise side) so a crafted event
        // cannot reach a profile the tablet would never have listed

        _args params ["_playerID","_profile"];

        _result = false;

        if (isnil "_profile") exitWith {};

        private _limit = [_logic,"opsLimit","SIDE"] call ALiVE_fnc_hashGet;
        if (_limit == "ALL") exitWith {_result = true};

        private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
        if (isNull _player) exitWith {};

        if (_limit == "FACTION") then {
            _result = (faction _player) == (_profile select 2 select 29);
        } else {
            _result = ([_logic,"opsPlayerSideText",_player] call MAINCLASS) == (_profile select 2 select 3);
        };

    };

    case "opsSendObjectivesDenied": {

        // reply with an EMPTY objectives snapshot - never packs commander data

        _args params ["_playerID","_selOpcom"];

        private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
        ["OPS_OBJECTIVES", [_playerID,[_selOpcom,[],[false,0,false,"Not authorized for this commander"]]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

    };

    case "opsSendObjectives": {

        // pack the selected commander's objectives IN ARRAY ORDER (array order
        // is the commander's priority queue) and reply with a full snapshot -
        // every mutation op ends here so the client never tracks indices

        if (_args isEqualType []) then {

            _args params ["_playerID","_selOpcom",["_statusText","",[""]]];

            private _selOpcomID = _selOpcom select 0;
            private _opcom = [_logic,"opsFindOPCOM", _selOpcomID] call MAINCLASS;

            // single reply sink for the objectives flow - deny when the caller is not
            // authorized for a resolved commander, so no pre-gate reply path (e.g. the
            // "objectives disabled" branch of the mutation ops) can leak its objectives
            if (!isnil "_opcom" && {!([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS)}) exitwith {
                [_logic,"opsSendObjectivesDenied",[_playerID,_selOpcom]] call MAINCLASS;
            };

            private _objectiveData = [];

            if (isnil "_opcom") then {
                if (_statusText == "") then {_statusText = "Commander no longer available"};
            } else {
                // rebuild the selection tuple from the resolved commander so the quota
                // count and the echoed label are authoritative, not client-supplied
                _selOpcom = [
                    [_opcom,"opcomID",_selOpcomID] call ALiVE_fnc_hashGet,
                    [_opcom,"name",""] call ALiVE_fnc_hashGet,
                    [_opcom,"side",""] call ALiVE_fnc_hashGet
                ];

                if (([_opcom,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric") then {
                    if (_statusText == "") then {_statusText = "Objectives view not available for asymmetric commanders"};
                } else {
                    {
                        _objectiveData pushBack [
                            [_x,"objectiveID",""] call ALiVE_fnc_hashGet,
                            [_x,"center",[]] call ALiVE_fnc_hashGet,
                            [_x,"size",150] call ALiVE_fnc_hashGet,
                            [_x,"opcom_state","unassigned"] call ALiVE_fnc_hashGet,
                            [_x,"objectiveType","unknown"] call ALiVE_fnc_hashGet,
                            [_x,"playerCreated",false] call ALiVE_fnc_hashGet
                        ];
                    } foreach ([_opcom,"objectives",[]] call ALiVE_fnc_HashGet);
                };
            };

            private _enabled = [_logic,"playerObjectivesEnabled",false] call ALiVE_fnc_hashGet;
            private _cooldown = [_logic,"playerObjectiveCooldown",300] call ALiVE_fnc_hashGet;
            private _maxObjectives = [_logic,"maxPlayerObjectives",3] call ALiVE_fnc_hashGet;
            private _cooldowns = [_logic,"playerObjectiveCooldowns"] call ALiVE_fnc_hashGet;

            private _cooldownRemaining = 0;
            if (!isnil "_cooldowns") then {
                private _lastDesignation = [_cooldowns,_playerID,-999999] call ALiVE_fnc_hashGet;
                _cooldownRemaining = 0 max (_cooldown - (time - _lastDesignation));
            };

            // only count against a resolved commander's side - never a client-supplied one
            private _maxReached = false;
            if (!isnil "_opcom") then {
                _maxReached = ([_logic,"opsCountPlayerObjectives", _selOpcom select 2] call MAINCLASS) >= _maxObjectives;
            };

            private _player = [_playerID] call ALiVE_fnc_getPlayerByUID;
            ["OPS_OBJECTIVES", [_playerID,[_selOpcom,_objectiveData,[_enabled,_cooldownRemaining,_maxReached,_statusText]]]] remoteExecCall ["ALiVE_fnc_SCOMTabletEventToClient", _player];

        };

    };

    case "opsCountPlayerObjectives": {

        // player-designated objectives currently active across all commanders
        // of the given side

        private _side = _args;
        private _count = 0;

        if (!isnil "OPCOM_instances") then {
            {
                if (([_x,"side",""] call ALiVE_fnc_hashGet) == _side) then {
                    _count = _count + ({[_x,"playerCreated",false] call ALiVE_fnc_hashGet} count ([_x,"objectives",[]] call ALiVE_fnc_HashGet));
                };
            } foreach OPCOM_instances;
        };

        _result = _count;

    };

    case "opsGetObjectives": {

        if (_args isEqualType []) then {

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]]];

            if (count _selOpcom < 3) exitwith {};

            private _opcom = [_logic,"opsFindOPCOM", _selOpcom select 0] call MAINCLASS;

            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS) exitwith {
                [_logic,"opsSendObjectivesDenied",[_playerID,_selOpcom]] call MAINCLASS;
            };

            [_logic,"opsSendObjectives",[_playerID,_selOpcom,""]] call MAINCLASS;

        };

    };

    case "opsAddObjective": {

        if (_args isEqualType []) then {

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]],["_pos",[],[[]]]];

            if (count _selOpcom < 3 || {count _pos < 2}) exitwith {};

            // server-side enforcement - the client greying is cosmetic only

            private _enabled = [_logic,"playerObjectivesEnabled",false] call ALiVE_fnc_hashGet;
            if !(_enabled) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Player objectives are disabled"]] call MAINCLASS;
            };

            // resolve + authorize the commander first, so the quota and side used
            // below come from the real commander, not the client-supplied triple

            private _opcom = [_logic,"opsFindOPCOM", _selOpcom select 0] call MAINCLASS;

            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS) exitwith {
                [_logic,"opsSendObjectivesDenied",[_playerID,_selOpcom]] call MAINCLASS;
            };

            if (isnil "_opcom" || {([_opcom,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric"}) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,""]] call MAINCLASS;
            };

            private _opcomSide = [_opcom,"side",""] call ALiVE_fnc_hashGet;

            private _cooldown = [_logic,"playerObjectiveCooldown",300] call ALiVE_fnc_hashGet;
            private _cooldowns = [_logic,"playerObjectiveCooldowns"] call ALiVE_fnc_hashGet;
            private _lastDesignation = [_cooldowns,_playerID,-999999] call ALiVE_fnc_hashGet;

            if (time - _lastDesignation < _cooldown) exitwith {
                private _remaining = ceil (_cooldown - (time - _lastDesignation));
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,format ["Objective cooldown: %1s remaining", _remaining]]] call MAINCLASS;
            };

            private _maxObjectives = [_logic,"maxPlayerObjectives",3] call ALiVE_fnc_hashGet;
            private _playerObjectiveCount = [_logic,"opsCountPlayerObjectives", _opcomSide] call MAINCLASS;

            if (_playerObjectiveCount >= _maxObjectives) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Maximum player objectives reached"]] call MAINCLASS;
            };

            // front-insert as unassigned - OPCOM classifies it on the next
            // analysis cycle, and front array position makes it the first
            // pick within its state bucket

            // monotonic counter keeps IDs unique even when two designations
            // drain from the remoteExec queue in the same server frame

            private _counter = ([_logic,"playerObjectiveCounter",0] call ALiVE_fnc_hashGet) + 1;
            [_logic,"playerObjectiveCounter",_counter] call ALiVE_fnc_hashSet;

            private _opcomID = [_opcom,"opcomID",""] call ALiVE_fnc_hashGet;
            private _objectiveID = format ["%1_player_obj_%2", _opcomID, _counter];

            [_opcom,"addObjective",[_objectiveID,_pos,100,"custom",100,"unassigned","none",_opcomID,true,true]] call ALiVE_fnc_OPCOM;
            [_cooldowns,_playerID,time] call ALiVE_fnc_hashSet;

            [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objective designated"]] call MAINCLASS;

        };

    };

    case "opsCancelObjective": {

        if (_args isEqualType []) then {

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]],["_objectiveID","",[""]]];

            if (count _selOpcom < 3) exitwith {};

            // same server-side gate as opsAddObjective - the tablet UI is not
            // the only way to reach this op

            if !([_logic,"playerObjectivesEnabled",false] call ALiVE_fnc_hashGet) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Player objectives are disabled"]] call MAINCLASS;
            };

            private _opcom = [_logic,"opsFindOPCOM", _selOpcom select 0] call MAINCLASS;

            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS) exitwith {
                [_logic,"opsSendObjectivesDenied",[_playerID,_selOpcom]] call MAINCLASS;
            };

            if (isnil "_opcom") exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,""]] call MAINCLASS;
            };

            // parity with opsAddObjective/opsSendObjectives - asymmetric
            // commanders are scoped out of all player-objective interaction
            if (([_opcom,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric") exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objectives view not available for asymmetric commanders"]] call MAINCLASS;
            };

            private _objective = [_opcom,"getObjectiveByID",_objectiveID] call ALiVE_fnc_OPCOM;

            if (isnil "_objective") exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objective no longer exists"]] call MAINCLASS;
            };

            // only player-designated objectives may be cancelled

            if !([_objective,"playerCreated",false] call ALiVE_fnc_hashGet) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Only player-designated objectives can be cancelled"]] call MAINCLASS;
            };

            [_opcom,"removeObjective",_objectiveID] call ALiVE_fnc_OPCOM;

            [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objective cancelled"]] call MAINCLASS;

        };

    };

    case "opsMoveObjective": {

        if (_args isEqualType []) then {

            _args params [["_playerID","",[""]],["_selOpcom",[],[[]]],["_objectiveID","",[""]],["_direction",0,[0]]];

            if (count _selOpcom < 3) exitwith {};

            // same server-side gate as opsAddObjective - reordering the
            // commander's priority queue is exactly what the toggle gates

            if !([_logic,"playerObjectivesEnabled",false] call ALiVE_fnc_hashGet) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Player objectives are disabled"]] call MAINCLASS;
            };

            private _opcom = [_logic,"opsFindOPCOM", _selOpcom select 0] call MAINCLASS;

            if !([_logic,"opsCallerAuthorizedForOpcom",[_playerID,_opcom,"opsLimit"]] call MAINCLASS) exitwith {
                [_logic,"opsSendObjectivesDenied",[_playerID,_selOpcom]] call MAINCLASS;
            };

            if (isnil "_opcom") exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,""]] call MAINCLASS;
            };

            // parity with opsAddObjective/opsSendObjectives - asymmetric
            // commanders are scoped out of all player-objective interaction, so
            // a crafted event cannot reorder their objective queue
            if (([_opcom,"controltype",""] call ALiVE_fnc_hashGet) == "asymmetric") exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objectives view not available for asymmetric commanders"]] call MAINCLASS;
            };

            // recompute the index server-side - the FSM churns the array, a
            // client-held index may be stale by the time the event arrives

            private _objectives = [_opcom,"objectives",[]] call ALiVE_fnc_HashGet;
            private _index = _objectives findIf { ([_x,"objectiveID",""] call ALiVE_fnc_hashGet) == _objectiveID };

            if (_index == -1) exitwith {
                [_logic,"opsSendObjectives",[_playerID,_selOpcom,"Objective no longer exists"]] call MAINCLASS;
            };

            [_opcom,"reorderObjective",[_objectiveID,_index + _direction]] call ALiVE_fnc_OPCOM;

            [_logic,"opsSendObjectives",[_playerID,_selOpcom,""]] call MAINCLASS;

        };

    };

    default {
        _result = _this call SUPERCLASS;
    };

};

TRACE_1("commandHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};
