#include <\x\alive\addons\sup_group_manager\script_component.hpp>
SCRIPT(taskHandler);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Server side group handling

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)
// create a task handler
_logic = [nil, "create"] call ALIVE_fnc_groupHandler;

// init task handler
_result = [_logic, "init"] call ALIVE_fnc_groupHandler;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_groupHandler

private ["_logic","_operation","_args","_result"];

TRACE_1("groupHandler - input",_this);

_logic = [_this, 0, objNull, [objNull,[]]] call BIS_fnc_param;
_operation = [_this, 1, "", [""]] call BIS_fnc_param;
_args = [_this, 2, objNull, [objNull,[],"",0,true,false]] call BIS_fnc_param;
//_result = true;

#define MTEMPLATE "ALiVE_GROUPHANDLER_%1"

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
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "init": {
        if (isServer) then {

            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;

            waituntil {!(isnil "ALIVE_profileSystemInit")};

            [_logic,"listen"] call MAINCLASS;
        };
    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, ["GROUP_JOIN","GROUP_LEAVE"]]] call ALIVE_fnc_eventLog;
        [_logic,"listenerID",_listenerID] call ALIVE_fnc_hashSet;
    };
    case "handleEvent": {
        private["_event","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            [_logic, _type, _eventData] call MAINCLASS;

        };
    };
    case "GROUP_JOIN": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Group Handler - Group Join event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "groupJoin", _eventData] call MAINCLASS;

    };
    case "GROUP_LEAVE": {
        private["_debug","_eventData"];

        _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

        _eventData = _args;

        // DEBUG -------------------------------------------------------------------------------------
        if(_debug) then {
            ["----------------------------------------------------------------------------------------"] call ALIVE_fnc_dump;
            ["ALiVE Group Handler - Leave Group event received"] call ALIVE_fnc_dump;
            _eventData call ALIVE_fnc_inspectArray;
        };
        // DEBUG -------------------------------------------------------------------------------------

        [_logic, "groupLeave", _eventData] call MAINCLASS;

    };
    case "groupJoin": {
        private["_join","_playerID","_debug","_unit","_group","_event"];

        if(typeName _args == "ARRAY") then {

            _join = _args;
            _playerID = _join select 1;
            _unit = _join select 2;
            _group = _join select 3;

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            _groupFrom = group _unit;
            _leaderGroupFrom = leader _groupFrom;
            _leaderGroupFromPID = _leaderGroupFrom getVariable ["profileID",""];
            _unitsGroupFrom = units _groupFrom;

            _groupTo = _group;
            _leaderGroupTo = leader _groupTo;
            _leaderGroupToPID = _leaderGroupTo getVariable ["profileID",""];
            _unitsGroupTo = units _groupTo;

            _unitIsPlayer = false;
            _unitPlayerUID = '0';

            if(isPlayer _unit) then {
                //["Unit is a player"] call ALIVE_fnc_dump;
                _unitIsPlayer = true;
                _unitPlayerUID = getPlayerUID _unit;
            }else{
                //["Unit is not a player"] call ALIVE_fnc_dump;
            };

            _groupFromIsProfiled = false;
            _groupFromProfile = nil;

            if(_leaderGroupFromPID == "") then {
                //["From group is not profiled"] call ALIVE_fnc_dump;
            }else{
                //["From group is profiled %1",_leaderGroupFromPID] call ALIVE_fnc_dump;
                _groupFromIsProfiled = true;
                _groupFromProfile = [ALIVE_profileHandler, "getProfile", _leaderGroupFromPID] call ALIVE_fnc_profileHandler;
            };

            _groupToIsProfiled = false;
            _groupToProfile = nil;

            if(_leaderGroupToPID == "") then {
                //["To group is not profiled"] call ALIVE_fnc_dump;
            }else{
                //["To group is profiled: %1",_leaderGroupToPID] call ALIVE_fnc_dump;
                _groupToIsProfiled = true;
                _groupToProfile = [ALIVE_profileHandler, "getProfile", _leaderGroupToPID] call ALIVE_fnc_profileHandler;
            };

            _anyPlayersInGroupFrom = false;

            {
                if(isPlayer _x) then {
                    _uuid = getPlayerUID _x;
                    if(_uuid != _unitPlayerUID) then {
                        _anyPlayersInGroupFrom = true;
                        //["From group has player: %1 %2",_uuid,_unitPlayerUID] call ALIVE_fnc_dump;
                    };
                };
            } forEach _unitsGroupFrom;

            _anyPlayersInGroupTo = false;

            {
                if(isPlayer _x) then {
                    _uuid = getPlayerUID _x;
                    if(_uuid != _unitPlayerUID) then {
                        _anyPlayersInGroupTo = true;
                        //["To group has player: %1 %2",_uuid,_unitPlayerUID] call ALIVE_fnc_dump;
                    };
                };
            } forEach _unitsGroupTo;


            if!(isNil "_groupToProfile") then {
                //["TO PROFILE IS NOT NIL"] call ALIVE_fnc_dump;
                //_groupToProfile call ALIVE_fnc_inspectHash;
                [_groupToProfile, "addUnit", [typeOf _unit,position _unit,0,rank _unit]] call ALIVE_fnc_profileEntity;
                //[ALIVE_profileHandler, "unregisterProfile", _groupToProfile] call ALIVE_fnc_profileHandler;
            }else{
                //["TO PROFILE IS NIL"] call ALIVE_fnc_dump;
            };

            if!(isNil "_groupFromProfile") then {
                //["FROM PROFILE IS NOT NIL"] call ALIVE_fnc_dump;
                //_groupFromProfile call ALIVE_fnc_inspectHash;
                _result = [_groupFromProfile,"handleDeath",_unit] call ALIVE_fnc_profileEntity;
                // all units in profile are killed
                if!(_result) then {

                    // not sure about this, it will remove the profile and the bodies will remain
                    // will need to have dead unit cleanup scripts
                    [ALIVE_profileHandler, "unregisterProfile", _groupFromProfile] call ALIVE_fnc_profileHandler;

                };
            }else{
                 //["FROM PROFILE IS NIL"] call ALIVE_fnc_dump;
            };

            _unit setVariable ["profileID",_leaderGroupToPID];

            [_unit] joinSilent _group;

            _event = ['GROUPS_UPDATED', [_playerID,[]], "GROUP_HANDLER"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

        };
    };
    case "groupLeave": {
        private["_join","_playerID","_unit","_newGroup","_debug","_event"];

        if(typeName _args == "ARRAY") then {

            _join = _args;
            _playerID = _join select 1;
            _unit = _join select 2;

            _debug = [_logic,"debug"] call ALIVE_fnc_hashGet;

            _groupFrom = group _unit;
            _leaderGroupFrom = leader _groupFrom;
            _leaderGroupFromPID = _leaderGroupFrom getVariable ["profileID",""];
            _unitsGroupFrom = units _groupFrom;

            _unitIsPlayer = false;
            _unitPlayerUID = '0';

            if(isPlayer _unit) then {
                //["Unit is a player"] call ALIVE_fnc_dump;
                _unitIsPlayer = true;
                _unitPlayerUID = getPlayerUID _unit;
            }else{
                //["Unit is not a player"] call ALIVE_fnc_dump;
            };

            _groupFromIsProfiled = false;
            _groupFromProfile = nil;

            if(_leaderGroupFromPID == "") then {
                //["From group is not profiled"] call ALIVE_fnc_dump;
            }else{
                //["From group is profiled %1",_leaderGroupFromPID] call ALIVE_fnc_dump;
                _groupFromIsProfiled = true;
                _groupFromProfile = [ALIVE_profileHandler, "getProfile", _leaderGroupFromPID] call ALIVE_fnc_profileHandler;
            };

            _anyPlayersInGroupFrom = false;

            {
                if(isPlayer _x) then {
                    _uuid = getPlayerUID _x;
                    if(_uuid != _unitPlayerUID) then {
                        _anyPlayersInGroupFrom = true;
                        //["From group has player: %1 %2",_uuid,_unitPlayerUID] call ALIVE_fnc_dump;
                    };
                };
            } forEach _unitsGroupFrom;

            if!(isNil "_groupFromProfile") then {
                //["FROM PROFILE IS NOT NIL"] call ALIVE_fnc_dump;
                //_groupFromProfile call ALIVE_fnc_inspectHash;
                _result = [_groupFromProfile,"handleDeath",_unit] call ALIVE_fnc_profileEntity;
                // all units in profile are killed
                if!(_result) then {

                    // not sure about this, it will remove the profile and the bodies will remain
                    // will need to have dead unit cleanup scripts
                    [ALIVE_profileHandler, "unregisterProfile", _groupFromProfile] call ALIVE_fnc_profileHandler;

                };
            }else{
                 //["FROM PROFILE IS NIL"] call ALIVE_fnc_dump;
            };

            _unit setVariable ["profileID",""];

            _newGroup = createGroup (side _unit);

            [_unit] joinSilent _newGroup;

            if(_unitIsPlayer) then {
                ["CONNECT","",_unit] call ALIVE_fnc_createProfilesFromPlayers;
            }else{
                [true, [_newGroup], []] call ALIVE_fnc_createProfilesFromUnitsRuntime;
            };

            _event = ['GROUPS_UPDATED', [_playerID,[]], "GROUP_HANDLER"] call ALIVE_fnc_event;
            [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

        };
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("groupHandler - output",_result);

if !(isnil "_result") then {_result} else {nil};