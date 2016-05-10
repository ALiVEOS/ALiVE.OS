#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(eventLog);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Event log

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of analysis

Examples:
(begin example)
// create the command router
_logic = [nil, "create"] call ALIVE_fnc_eventLog;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_eventLog

private ["_result"];

TRACE_1("event log - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
_result = true;

#define MTEMPLATE "ALiVE_EVENT_%1"

switch(_operation) do {
        case "init": {

            private ["_listenersByFilter","_eventsByType"];

            if (isServer) then {
                // if server, initialise listener game logic
                [_logic,"super"] call ALIVE_fnc_hashRem;
                [_logic,"class"] call ALIVE_fnc_hashRem;
                TRACE_1("After listener init",_logic);

                // set defaults
                [_logic,"debug",false] call ALIVE_fnc_hashSet; // select 2 select 0
                [_logic,"listenerCount",0] call ALIVE_fnc_hashSet;
                [_logic,"eventCount",0] call ALIVE_fnc_hashSet;
                [_logic,"firstEvent",0] call ALIVE_fnc_hashSet;
                [_logic,"maxEvents",5] call ALIVE_fnc_hashSet;
                [_logic,"events",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
                [_logic,"listeners",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;

                _listenersByFilter = [] call ALIVE_fnc_hashCreate;
                [_logic,"listenersByFilter",_listenersByFilter] call ALIVE_fnc_hashSet;

                _eventsByType = [] call ALIVE_fnc_hashCreate;
                [_logic,"eventsByType",_eventsByType] call ALIVE_fnc_hashSet;
            };
        };
        case "destroy": {
            [_logic, "debug", false] call MAINCLASS;
            if (isServer) then {
                // if server
                [_logic,"super"] call ALIVE_fnc_hashRem;
                [_logic,"class"] call ALIVE_fnc_hashRem;

                [_logic, "destroy"] call SUPERCLASS;
            };
        };
        case "debug": {
            if(typeName _args != "BOOL") then {
                _args = [_logic,"debug", false] call ALIVE_fnc_hashGet;
            } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
            };
            _result = _args;
        };
        case "addListener": {
            private["_listener","_filter","_debug","_listeners","_filteredListeners","_listenerID","_filters"];

            if(typeName _args == "ARRAY") then {

                _listener = _args select 0;
                _filters = _args select 1; // event type, all

                _debug = [_logic,"debug"] call MAINCLASS;
                _listeners = [_logic,"listeners"] call ALIVE_fnc_hashGet;
                _filteredListeners = [_logic,"listenersByFilter"] call ALIVE_fnc_hashGet;

                _listenerID = [_logic, "getNextListenerInsertID"] call MAINCLASS;

                // store the listener in a hash by filter type

                {
                    _filter = _x;

                    if!(_filter in (_filteredListeners select 1)) then {
                        _filters = [] call ALIVE_fnc_hashCreate;
                        [_filters, _listenerID, _args] call ALIVE_fnc_hashSet;
                        [_filteredListeners,_filter,_filters] call ALIVE_fnc_hashSet;
                    }else{
                        _filters = [_filteredListeners,_filter] call ALIVE_fnc_hashGet;
                        [_filters, _listenerID, _args] call ALIVE_fnc_hashSet;
                        [_filteredListeners, _filter, _filters] call ALIVE_fnc_hashSet;
                    };

                } forEach _filters;

                // store the listener in the main hash

                [_listeners, _listenerID, _args] call ALIVE_fnc_hashSet;
                [_logic,"listeners",_listeners] call ALIVE_fnc_hashSet;

                if(_debug) then {
                    _listeners call ALIVE_fnc_inspectHash;
                    _filteredListeners call ALIVE_fnc_inspectHash;
                };

                _result = _listenerID;

            };
        };
        case "removeListener": {
            private["_listenerID","_listeners","_filteredListeners","_filterListeners","_listener","_filter","_filters"];

            if(typeName _args == "STRING") then {
                _listenerID = _args;
                _listeners = [_logic,"listeners"] call ALIVE_fnc_hashGet;
                _filteredListeners = [_logic,"listenersByFilter"] call ALIVE_fnc_hashGet;

                _listener = [_listeners,_listenerID] call ALIVE_fnc_hashGet;
                _filters = _listener select 1;

                // remove the event from the hash by type

                {
                    _filter = _x;

                    _filterListeners = [_filteredListeners,_filter] call ALIVE_fnc_hashGet;
                    [_filterListeners,_listenerID] call ALIVE_fnc_hashRem;

                } forEach _filters;

                // remove the event from the main hash

                [_listeners, _listenerID] call ALIVE_fnc_hashRem;
                [_logic,"listeners",_listeners] call ALIVE_fnc_hashSet;
            };
        };
        case "getListeners": {
            _result = [_logic,"listeners"] call ALIVE_fnc_hashGet;
        };
        case "clearListeners": {
            private["_listenersByFilter"];

            _result = [_logic,"listeners",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            _listenersByFilter = [] call ALIVE_fnc_hashCreate;
            [_logic,"listenersByFilter",_listenersByFilter] call ALIVE_fnc_hashSet;
        };
        case "getListenersByFilter": {
            private["_filteredListeners","_filter","_filters"];

            if(typeName _args == "STRING") then {
                _filter = _args;
                _filteredListeners = [_logic,"listenersByFilter"] call ALIVE_fnc_hashGet;
                if(_filter in (_filteredListeners select 1)) then {
                    _result = [_filteredListeners,_filter] call ALIVE_fnc_hashGet;
                }else{
                     _result = [] call ALIVE_fnc_hashCreate;
                };
            };
        };
        case "maxEvents": {
            if(typeName _args == "SCALAR") then {
                [_logic,"maxEvents",_args] call ALIVE_fnc_hashSet;
            };
            _result = [_logic,"maxEvents"] call ALIVE_fnc_hashGet;
        };
		case "addEvent": {
            private["_event","_debug","_firstEvent","_maxEvents","_events","_eventsByType","_eventID","_type","_eventTypes",
            "_filteredListeners","_listeners","_listener","_class"];

            if(typeName _args == "ARRAY") then {
                _event = _args;

                //_event call ALIVE_fnc_inspectHash;

                _debug = [_logic,"debug"] call MAINCLASS;
                _events = [_logic,"events"] call ALIVE_fnc_hashGet;
                _eventsByType = [_logic,"eventsByType"] call ALIVE_fnc_hashGet;
                _firstEvent = [_logic,"firstEvent"] call ALIVE_fnc_hashGet;
                _maxEvents = [_logic,"maxEvents"] call ALIVE_fnc_hashGet;

                _eventID = [_logic, "getNextEventInsertID"] call MAINCLASS;

                [_event,"id",_eventID] call ALIVE_fnc_hashSet;

                _type = [_event,"type"] call ALIVE_fnc_hashGet;

                // store the event in a hash by type

                if!(_type in (_eventsByType select 1)) then {
                    _eventTypes = [] call ALIVE_fnc_hashCreate;
                    [_eventTypes, _eventID, _event] call ALIVE_fnc_hashSet;
                    [_eventsByType,_type,_eventTypes] call ALIVE_fnc_hashSet;
                }else{
                    _eventTypes = [_eventsByType,_type] call ALIVE_fnc_hashGet;
                    [_eventTypes, _eventID, _event] call ALIVE_fnc_hashSet;
                    [_eventsByType, _type, _eventTypes] call ALIVE_fnc_hashSet;
                };

                // remove first event if over the max limit

                if(count (_events select 1) > _maxEvents) then {
                    [_logic, "removeEvent", format["event_%1",_firstEvent]] call MAINCLASS;
                    _firstEvent = _firstEvent + 1;
                    [_logic,"firstEvent",_firstEvent] call ALIVE_fnc_hashSet;
                };

                // store the event in the main hash

                [_events, _eventID, _event] call ALIVE_fnc_hashSet;
                [_logic,"events",_events] call ALIVE_fnc_hashSet;

                if(_debug) then {
                    _event call ALIVE_fnc_inspectHash;
                    _events call ALIVE_fnc_inspectHash;
                    _eventsByType call ALIVE_fnc_inspectHash;
                };

                // spawn the event dispatch

                [_logic, _type, _event] spawn {

                    private["_logic","_type","_event","_filteredListeners","_listeners","_listener","_class"];

                    _logic = _this select 0;
                    _type = _this select 1;
                    _event = _this select 2;

                    // notify filtered listeners

                    _filteredListeners = [_logic,"listenersByFilter"] call ALIVE_fnc_hashGet;
                    if(_type in (_filteredListeners select 1)) then {
                        _listeners = [_filteredListeners,_type] call ALIVE_fnc_hashGet;
                        {
                            _listener = _x select 0;
                            if(typeName _listener == "OBJECT") then {
                                _class = _listener getVariable "class";
                            }else{
                                _class = [_listener,"class"] call ALIVE_fnc_hashGet;
                            };

                            [_listener,"handleEvent",_event] call _class;
                        } forEach (_listeners select 2);
                    };

                    // notify all filter listeners

                    _filteredListeners = [_logic,"listenersByFilter"] call ALIVE_fnc_hashGet;
                    if('ALL' in (_filteredListeners select 1)) then {
                        _listeners = [_filteredListeners,'ALL'] call ALIVE_fnc_hashGet;
                        {
                            _listener = _x select 0;

                            if(typeName _listener == "OBJECT") then {
                                _class = _listener getVariable "class";
                            }else{
                                _class = [_listener,"class"] call ALIVE_fnc_hashGet;
                            };

                            [_listener,"handleEvent",_event] call _class;
                        } forEach (_listeners select 2);
                    };
                };

                _result = _eventID;

            };
        };
        case "removeEvent": {
            private["_eventID","_events","_eventsByType","_event","_type","_eventTypes"];

            if(typeName _args == "STRING") then {
                _eventID = _args;
                _events = [_logic,"events"] call ALIVE_fnc_hashGet;
                _eventsByType = [_logic,"eventsByType"] call ALIVE_fnc_hashGet;

                if(_eventID in (_events select 1)) then {
                    _event = [_events,_eventID] call ALIVE_fnc_hashGet;
                    _type = [_event,"type"] call ALIVE_fnc_hashGet;

                    // remove the event from the hash by type

                    _eventTypes = [_eventsByType,_type] call ALIVE_fnc_hashGet;
                    [_eventTypes,_eventID] call ALIVE_fnc_hashRem;

                    // remove the event from the main hash

                    [_events, _eventID] call ALIVE_fnc_hashRem;
                    [_logic,"events",_events] call ALIVE_fnc_hashSet;
                };
            };
        };
        case "getEventsByType": {
            private["_eventsByType","_type","_eventTypes"];

            if(typeName _args == "STRING") then {
                _type = _args;
                _eventsByType = [_logic,"eventsByType"] call ALIVE_fnc_hashGet;
                if(_type in (_eventsByType select 1)) then {
                    _result = [_eventsByType,_type] call ALIVE_fnc_hashGet;
                }else{
                    _result = [] call ALIVE_fnc_hashCreate;
                };
            };
        };
        case "getEvents": {
            _result = [_logic,"events"] call ALIVE_fnc_hashGet;
        };
        case "clearEvents": {
            private["_eventsByType"];

            [_logic,"events",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            _eventsByType = [] call ALIVE_fnc_hashCreate;
            [_logic,"eventsByType",_eventsByType] call ALIVE_fnc_hashSet;
        };
        case "getNextListenerInsertID": {
            private["_listenerCount"];

            _listenerCount = [_logic, "listenerCount"] call ALIVE_fnc_hashGet;
            _result = format["listener_%1",_listenerCount];
            _listenerCount = _listenerCount + 1;
            [_logic, "listenerCount", _listenerCount] call ALIVE_fnc_hashSet;
        };
        case "getNextEventInsertID": {
            private["_eventCount"];

            _eventCount = [_logic, "eventCount"] call ALIVE_fnc_hashGet;
            _result = format["event_%1",_eventCount];
            _eventCount = _eventCount + 1;
            [_logic, "eventCount", _eventCount] call ALIVE_fnc_hashSet;
        };
        default {
            _result = [_logic, _operation, _args] call SUPERCLASS;
        };
};
TRACE_1("event log - output",_result);
_result;