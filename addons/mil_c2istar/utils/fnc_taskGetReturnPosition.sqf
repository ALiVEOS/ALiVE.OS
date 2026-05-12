#include "\x\alive\addons\mil_C2ISTAR\script_component.hpp"
SCRIPT(taskGetReturnPosition);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetReturnPosition

Description:
    Resolves the "return location" for tasks that need players to bring
    a hostage / pilot / package back to friendly territory (Rescue,
    CSAR, future similar tasks). Returns the friendly side's OPCOM
    main HQ position - i.e. wherever the mission-maker placed that
    side's ALiVE_mil_OPCOM module in Eden.

    Falls back to an empty array when no friendly OPCOM is placed,
    letting the caller use its legacy random-composition fallback.

    Side comparison normalises "RESISTANCE" -> "GUER" so the
    mil_opcom internal naming (RESISTANCE for the GUER side string)
    matches the task-side naming convention.

Parameters:
    0: STRING - friendly side as "EAST" / "WEST" / "GUER" (task-side
                convention)

Returns:
    ARRAY - position [x, y, z], or [] if no friendly OPCOM placed

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_taskSide", "", [""]]];

private _result = [];

if (_taskSide == "") exitWith { _result };

{
    private _handler = _x getVariable "handler";
    if (typeName _handler == "ARRAY") then {
        private _opcomSide = [_handler, "side"] call ALiVE_fnc_HashGet;
        if (typeName _opcomSide == "STRING") then {
            // Normalise the mil_opcom internal "RESISTANCE" alias to
            // the task-side "GUER" before comparing.
            if (_opcomSide == "RESISTANCE") then { _opcomSide = "GUER"; };
            if (_opcomSide == _taskSide) exitWith {
                _result = getPos _x;
            };
        };
    };
} forEach (allMissionObjects "ALiVE_mil_OPCOM");

_result
