#include "\x\alive\addons\x_lib\script_component.hpp"
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

#define SUPERCLASS  ALIVE_fnc_baseClass
#define MAINCLASS   ALIVE_fnc_eventLog

#define MTEMPLATE   "ALiVE_EVENT_%1"
#define DISPATCH_EVENTS_PER_FRAME 4

TRACE_1("event log - input", _this);

params ["_logic","_operation","_args"];

private _result = true;

switch(_operation) do {
    case "init": {
        if (isServer) then {
            _logic setvariable ["super", QUOTE(SUPERCLASS)];
            _logic setvariable ["class", QUOTE(MAINCLASS)];

            _logic setvariable ["debug", false];
            _logic setvariable ["listenerCount", 0];
            _logic setvariable ["eventCount", 0];
            _logic setvariable ["listeners", createHashMap];
            _logic setvariable ["listenersByFilter", createHashMap];
            _logic setvariable ["dispatchQueue", []];
            _logic setvariable ["listenerDispatchStates", createHashMap];
            _logic setvariable ["destroyed", false];

            private _dispatchPFH = [{
                _this params ["_logic"];

                [_logic,"dispatchEvents"] call MAINCLASS;
            }, 0, _logic] call CBA_fnc_addPerFrameHandler;

            _logic setvariable ["dispatchPFH", _dispatchPFH];
        };
    };

    case "destroy": {
        [_logic,"debug", false] call MAINCLASS;

        if (isServer) then {
            _logic setvariable ["destroyed", true];

            private _dispatchPFH = _logic getvariable ["dispatchPFH", -1];
            if (_dispatchPFH >= 0) then {
                [_dispatchPFH] call CBA_fnc_removePerFrameHandler;
            };

            (_logic getvariable ["dispatchQueue", []]) resize 0;

            {
                (_y select 1) resize 0;
            } foreach (_logic getvariable ["listenerDispatchStates", createHashMap]);

            _logic setvariable ["dispatchPFH", -1];
            _logic setvariable ["listenerDispatchStates", createHashMap];

            _logic setvariable ["super", nil];
            _logic setvariable ["class", nil];

            [_logic,"destroy"] call SUPERCLASS;
        };
    };

    case "debug": {
        if(!isnil "_args") then {
            _logic setvariable ["debug", _args];
        } else {
            _result = _logic getvariable "debug";
        };
    };

    case "addListener": {
        _args params ["_listener","_filters"];

        private _debug = _logic getvariable "debug";
        private _listeners = _logic getvariable "listeners";
        private _filteredListeners = _logic getvariable "listenersByFilter";

        private _listenerID = [_logic,"getNextListenerInsertID"] call MAINCLASS;
        private _class = if (_listener isEqualType objNull) then {
            _listener getVariable "class"
        } else {
            [_listener,"class"] call ALIVE_fnc_hashGet
        };

        if (_class isEqualType "") then {
            _class = missionnamespace getvariable _class;
        };

        private _resolvedListener = [_listener, _class];

        // store the listener in a hash by filter type

        {
            if !(_x in _filteredListeners) then {
                _filteredListeners set [_x, createHashMapFromArray [
                    [_listenerID, _resolvedListener]
                ]];
            }else{
                (_filteredListeners get _x) set [_listenerID, _resolvedListener];
            };
        } forEach _filters;

        // store the listener in the main hash

        _listeners set [_listenerID, _args];

        if (_debug) then {
            //_listeners call ALIVE_fnc_inspectHash;
            //_filteredListeners call ALIVE_fnc_inspectHash;
        };

        _result = _listenerID;
    };

    case "removeListener": {
        private _listenerID = _args;
        private _listeners = _logic getvariable "listeners";
        private _filteredListeners = _logic getvariable "listenersByFilter";

        private _listener = _listeners get _listenerID;
        if (isnil "_listener") exitwith {
            _result = false;
        };

        private _filters = _listener select 1;

        {
            (_filteredListeners get _x) deleteat _listenerID;
        } forEach _filters;

        _listeners deleteat _listenerID;
    };

    case "getListeners": {
        _result = _logic getvariable "listeners";
    };

    case "clearListeners": {
        _logic setvariable ["listeners", createHashMap];
        _logic setvariable ["listenersByFilter", createHashMap];
    };

    case "getListenersByFilter": {
        private _filter = _args;
        private _filteredListeners = _logic getvariable "listenersByFilter";

        _result = _filteredListeners get _filter;
    };

    case "addEvent";
    case "addEvents": {
        PROFILE_SCOPE(EVENTLOGADDEVENT, "ALiVE eventLog: addEvent")
        PROFILE_SCOPE(EVENTLOGBOOKKEEPING, "ALiVE eventLog addEvent: bookkeeping")

        private _debug = _logic getvariable "debug";
        private _isSingleEvent = _args isEqualType [] && { _args isnotequalto [] } && { (_args select 0) isequalto "#CBA_HASH#" };

        private _events = if (_isSingleEvent) then {[_args]} else {_args};
        private _eventIDs = [];

        private _eventID = _logic getvariable "eventCount";

        {
            [_x,"id", _eventID] call ALIVE_fnc_hashSet;
            _eventIDs pushback _eventID;
            _eventID = _eventID + 1;

            if (_debug) then {
                _x call ALIVE_fnc_inspectHash;
            };
        } foreach _events;

        _logic setvariable ["eventCount", _eventID];
        (_logic getvariable "dispatchQueue") append _events;

        PROFILE_SCOPE_END(EVENTLOGBOOKKEEPING)

        _result = if (_operation isEqualTo "addEvent") then {
            _eventIDs param [0, -1]
        } else {
            _eventIDs
        };

        PROFILE_SCOPE_END(EVENTLOGADDEVENT)
    };

    case "dispatchEvents": {
        PROFILE_SCOPE(EVENTLOGDISPATCH, "ALiVE eventLog: per-frame dispatch")

        private _dispatchQueue = _logic getvariable "dispatchQueue";
        private _filteredListeners = _logic getvariable "listenersByFilter";
        private _dispatchStates = _logic getvariable "listenerDispatchStates";
        private _batchSize = DISPATCH_EVENTS_PER_FRAME min count _dispatchQueue;

        #ifdef DEBUG_MODE_FULL
        private _queuedAtStart = count _dispatchQueue;
        private _dispatchStartedAt = diag_tickTime;
        private _listenerDeliveries = 0;
        private _workersStarted = 0;
        #endif

        if (_batchSize > 0) then {
            private _batch = _dispatchQueue select [0, _batchSize];
            private _remainingCount = count _dispatchQueue - _batchSize;
            _logic setvariable ["dispatchQueue", _dispatchQueue select [_batchSize, _remainingCount]];

            private _enqueueForListener = {
                params ["_listenerID","_resolvedListener","_event"];

                private _state = _dispatchStates get _listenerID;
                if (isnil "_state") then {
                    _state = [_resolvedListener, [], false, scriptNull];
                    _dispatchStates set [_listenerID, _state];
                };

                (_state select 1) pushback _event;

                #ifdef DEBUG_MODE_FULL
                _listenerDeliveries = _listenerDeliveries + 1;
                #endif
            };

            {
                private _event = _x;
                private _type = [_event,"type"] call ALIVE_fnc_hashGet;
                private _typeListeners = _filteredListeners getOrDefault [_type, []];
                private _globalListeners = _filteredListeners getOrDefault ["ALL", []];

                {
                    [_x, _y, _event] call _enqueueForListener;
                } foreach _typeListeners;

                {
                    if !(_x in _typeListeners) then {
                        [_x, _y, _event] call _enqueueForListener;
                    };
                } foreach _globalListeners;
            } foreach _batch;
        };

        private _listeners = _logic getvariable "listeners";
        private _statesToRemove = [];

        {
            private _listenerID = _x;
            private _state = _y;
            _state params ["_resolvedListener","_listenerQueue","_running","_worker"];

            if (_running && {scriptDone _worker}) then {
                _running = false;
                _state set [2, false];
            };

            if (!_running && {_listenerQueue isNotEqualTo []}) then {
                _state set [2, true];

                #ifdef DEBUG_MODE_FULL
                _workersStarted = _workersStarted + 1;
                #endif

                private _worker = [_logic, _listenerID, _state] spawn {
                    PROFILE_SCOPE(EVENTLOGLISTENERWORKER, "ALiVE eventLog: listener worker")

                    params ["_logic","_listenerID","_state"];
                    _state params ["_resolvedListener","_listenerQueue"];
                    _resolvedListener params ["_listener","_class"];

                    #ifdef DEBUG_MODE_FULL
                    private _queuedAtStart = count _listenerQueue;
                    private _processedEvents = 0;
                    private _workerStartedAt = diag_tickTime;
                    #endif

                    while {
                        !(_logic getvariable ["destroyed", true]) && {
                            _listenerQueue isNotEqualTo []
                        }
                    } do {
                        private _listenerBatch = +_listenerQueue;
                        _listenerQueue resize 0;

                        #ifdef DEBUG_MODE_FULL
                        _processedEvents = _processedEvents + count _listenerBatch;
                        #endif

                        {
                            [_listener,"handleEvent", _x] call _class;
                        } foreach _listenerBatch;
                    };

                    _state set [2, false];

                    #ifdef DEBUG_MODE_FULL
                    private _workerElapsed = diag_tickTime - _workerStartedAt;
                    TRACE_4("eventLog listener drain: listener ID, initially queued events, processed events, elapsed seconds",_listenerID,_queuedAtStart,_processedEvents,_workerElapsed);
                    #endif

                    PROFILE_SCOPE_END(EVENTLOGLISTENERWORKER)
                };

                _state set [3, _worker];
            };

            if (
                !_running && {
                    _listenerQueue isEqualTo [] && {
                        isnil {_listeners get _listenerID}
                    }
                }
            ) then {
                _statesToRemove pushback _listenerID;
            };
        } foreach _dispatchStates;

        {
            _dispatchStates deleteat _x;
        } foreach _statesToRemove;

        #ifdef DEBUG_MODE_FULL
        if (_batchSize > 0) then {
            private _remainingEvents = count (_logic getvariable "dispatchQueue");
            private _dispatchElapsed = diag_tickTime - _dispatchStartedAt;
            TRACE_6("eventLog PFH drain: initially queued events, routed events, remaining events, listener deliveries, workers started, elapsed seconds",_queuedAtStart,_batchSize,_remainingEvents,_listenerDeliveries,_workersStarted,_dispatchElapsed);
        };
        #endif

        PROFILE_SCOPE_END(EVENTLOGDISPATCH)
    };

    case "getNextListenerInsertID": {
        private _listenerCount = _logic getvariable "listenerCount";
        _result = format ["listener_%1", _listenerCount];

        _logic setvariable ["listenerCount", _listenerCount + 1];
    };

    default {
        _result = _this call SUPERCLASS;
    };
};

TRACE_1("event log - output",_result);

_result
