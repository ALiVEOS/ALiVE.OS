#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATOSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOSaveData

Description:
Save the air commanders' campaign state.

Called by the save-and-exit button, which wants [wasItSaved, whatHappened] and
nothing else. Every air commander in the mission is asked to save its own
records under its own key; one that is not persistent says so and is skipped.

This used to hold the saving itself: it walked the ground commanders to find
out whether ANY air commander was persistent, and then wrote one shared blob
of every faction's aircraft. That is why two commanders of one faction wrote
over each other, and why a commander that was not persistent could still have
its aircraft saved by a neighbour that was.

Parameters:
Nil

Returns:
Array - [Boolean, Array of message strings]

Examples:
(begin example)
_result = [] call ALIVE_fnc_ATOSaveData;
(end)

See Also:
ALIVE_fnc_ATOLoadData
ALIVE_fnc_ATOKernel

Author:
ARJay, Jman
---------------------------------------------------------------------------- */

private _messages = [];

// Answered the same way on every path, so the caller never has to test the
// shape of what it got back.
if !(isServer) exitWith { [false, ["ALiVE Military air tasking orders - not the server"]] };
if (isNil "ALIVE_sys_data" || {isNil "ALIVE_sys_data_DISABLED"} || {ALIVE_sys_data_DISABLED}) exitWith {
    [false, ["ALiVE Military air tasking orders - persistence is off"]]
};
if (isNil "ALIVE_fnc_ATOKernel") exitWith {
    [false, ["ALiVE Military air tasking orders - the commander's kernel is missing"]]
};

if (!isNil "ALiVE_SYS_DATA_DEBUG_ON" && {ALiVE_SYS_DATA_DEBUG_ON}) then {
    [true, "ALiVE MIL air tasking orders - Saving data", "atoper"] call ALIVE_fnc_timer;
};

private _modules = (entities "Module_F") select { (typeOf _x) isEqualTo "ALiVE_mil_ato" };
if (count _modules == 0) exitWith {
    [false, ["ALiVE Military air tasking orders - no air commander in this mission"]]
};

private _saved = 0;
{
    private _logic = _x;
    ([_logic, "save"] call ALIVE_fnc_ATOKernel) params [["_ok", false, [false]], ["_why", "", [""]]];
    if (_ok) then { _saved = _saved + 1 };
    _messages pushBack format ["ALiVE Military air tasking orders - %1: %2",
        if (_ok) then { "saved" } else { "not saved" }, _why];
} forEach _modules;

private _result = [_saved > 0, _messages];

if (!isNil "ALiVE_SYS_DATA_DEBUG_ON" && {ALiVE_SYS_DATA_DEBUG_ON}) then {
    [false, "ALiVE MIL air tasking orders - Save data complete", "atoper"] call ALIVE_fnc_timer;
    ["MIL air tasking orders SAVE DATA RESULT: %1", _result] call ALiVE_fnc_dump;
};

_result
