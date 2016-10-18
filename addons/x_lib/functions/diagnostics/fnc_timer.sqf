#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(timer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_timer

Description:
Timer function

Parameters:
Boolean - start the timer

Returns:

Examples:
(begin example)
// timer start
[true] call ALIVE_fnc_timer;

// timer stop
[] call ALIVE_fnc_timer;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_timeStart","_timeEnd"];

params [
    ["_start", false],
    ["_message", ""],
    ["_id", ""]
];

if(isNil "ALIVE_timers") then {
    ALIVE_timers = [] call ALIVE_fnc_hashCreate;
};

if!(_id == "") then {
    if(_start) then {
        [ALIVE_timers, _id, diag_tickTime] call ALIVE_fnc_hashSet;
    }else{
        _timeStart = [ALIVE_timers, _id, 0] call ALIVE_fnc_hashGet;
        _timeEnd = diag_tickTime - _timeStart;
    };
}else{
    if(_start) then {
        ALIVE_timeStart = diag_tickTime;
    } else {
        _timeEnd = diag_tickTime - ALIVE_timeStart;
    };
};

if(_start) then {
    if!(_message == "") then {
        ["%1", _message] call ALIVE_fnc_dump;
    }else{
        ["[TIMER STARTED]"] call ALIVE_fnc_dump;
    };
} else {
    if!(_message == "") then {
        ["%1 %2", _message, _timeEnd] call ALIVE_fnc_dump;
    }else{
        ["[TIMER ENDED : %1]", _timeEnd] call ALIVE_fnc_dump;
    };
};