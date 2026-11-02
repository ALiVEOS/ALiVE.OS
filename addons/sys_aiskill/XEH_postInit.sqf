#include "script_component.hpp"

LOG(MSG_INIT);

// Soldier behaviour follows a group to whichever machine runs it. When a group
// becomes local here (handed to a headless client, or back to the server when
// one drops out), take it on a moment later once all its men have arrived.
// Only groups ALiVE spawned from a profile are marked eligible.
["CAManBase", "Local", {
    params ["_unit", "_local"];
    if (_local && {(group _unit) getVariable ["ALiVE_AIB_eligible", false]} && {!isNil "ALiVE_fnc_AIBehaviour"}) then {
        [{ ["attach", [_this]] call ALiVE_fnc_AIBehaviour }, group _unit, 2] call CBA_fnc_waitAndExecute;
    };
}, true] call CBA_fnc_addClassEventHandler;
