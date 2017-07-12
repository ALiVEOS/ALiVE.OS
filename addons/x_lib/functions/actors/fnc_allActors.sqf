#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_allActors

Description:
    Returns all actors in the current mission.

Parameters:
    0 - Actor group [group] (optional)

Returns:
    Actor list [array]

Attributes:
    N/A

Examples:
    N/A

See Also:
    - <ALIVE_fnc_createActor>
    - <ALIVE_fnc_sendActorMessage>

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

private "_return";

params [["_group", grpNull]];

if (isNull "_group") then {
    _group = ALiVE_actors_mainGroup;
    if (!isNil "_group") then {
        _return = units _group;
    } else {
        LOG_WARNING("ALiVE_fnc_allActors", "Attempted to list actors before the main actor group was created!");
        _return = [];
    };
} else {
    _return = units _group;
};

_return