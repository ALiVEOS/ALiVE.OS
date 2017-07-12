#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_createActor

Description:
    Creates an actor unit with the specified message handler.

Parameters:
    0 - Message Handler Code [code]
    1 - Actor unit [object] (optional)
    2 - Actor group [group] (optional)

Returns:
    Actor [object]

Attributes:
    N/A

Examples:
    N/A

See Also:
    - <ALIVE_fnc_allActors>
    - <ALIVE_fnc_sendActorMessage>

Author:
    Naught, dixon13
---------------------------------------------------------------------------- */

params [["_code", {}, [{}]], ["_actor", objNull, [objNull]], ["_group", grpNull, [grpNull]]];

private "_return";

if (isNull "_group") then { _group = ALiVE_actors_mainGroup; };

if (!isNil "_group") then {
    if (isNull _actor) then {
        _actor = _group createUnit ["logic", [0,0,0], [], 0, "NONE"];
    } else {
        if (!(isNull _group) && {(group _actor) != _group}) then { [_actor] joinSilent _group; };
    };

    _actor setVariable ["ALiVE_actors_owner", ALiVE_clientId, true];
    _actor setVariable ["ALiVE_actors_messageHandler", _code, false];

    _return = _actor;
} else {
    LOG_WARNING("ALiVE_fnc_createActor", "Attempted to create actor before the main actor group was created!");
    _return = objNull;
};

_return