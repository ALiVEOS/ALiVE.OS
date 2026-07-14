#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(doMoveRemote);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_doMoveRemote

Description:
Executes doMove on the units remote location automatically

Parameters:
Object - Given unit
Array - position

Returns:
Nothing

Examples:
[_unit, _pos] call ALiVE_fnc_doMoveRemote;

See Also:
-

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

params [
    ["_unit", objNull, [objNull]],
    ["_pos", [], [[]]]
];

// a dead unit or an invalid position is a routine outcome (a queued move
// firing on a unit combat killed in the meantime) - gate the trace behind the
// profile-system debug switch so it stops spamming the RPT. Code path unchanged
if (!(alive _unit) || {count _pos < 2}) exitwith {
    if (ALiVE_SYS_PROFILE_DEBUG_ON) then { ["domoveRemote failed - dead/empty unit"] call ALiVE_fnc_dump };
};

//Flag for usage with ALiVE_fnc_unitReadyRemote
_unit setvariable [QGVAR(MOVEDESTINATION),_pos];

if (local _unit) exitwith {
    // #921: Combat Support transport helis park with the engine off between orders;
    // the move order alone doesn't reliably restart it (reproduces on CBA+ALiVE - ACE
    // happened to mask it by starting engines), so the pilot takes the MOVE command but
    // sits with the engine off and never lifts. Force the engine on for CS helis.
    if (_unit getVariable ["ALIVE_CombatSupport", false]) then { _unit engineOn true; };
    _unit doMove _pos;
};

//if !local send to server to distribute
if !(isServer) then {
    _this remoteExecCall ["ALiVE_fnc_doMoveRemote",2];
} else {
    _this remoteExecCall ["ALiVE_fnc_doMoveRemote",owner _unit];
};
