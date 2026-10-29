#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusRequest);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusRequest

Description:
Server: the only way a Zeus's machine reaches the ALiVE Zeus modules. Works out who is asking
from the machine the call came from (never from anything the call carries), checks that player
has Zeus, and lets one request through per second per player. Then runs the module with
_ALiVE_zeusCaller set, which ALiVE_fnc_zeusServer requires.

Parameters:
String - the module
Array - its arguments

Returns:
nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if !(_this isEqualType [] && {count _this == 2} && {(_this select 0) isEqualType ""} && {(_this select 1) isEqualType []}) exitWith {};
params ["_action", "_args"];

if !(_action in ["save", "debug", "spotReport", "handGroup", "bomber", "convertBomber", "carBomb", "ied", "iedAmbush", "spawnGroup", "removeGroup", "objective", "reveal", "createTask", "closeTask", "airStrike", "resupply", "townMood", "tipOff", "angryCrowd"]) exitWith {
    ["ALiVE Zeus - refused a request for %1 from machine %2: not a Zeus module", _action, remoteExecutedOwner] call ALiVE_fnc_dump;
};

// Who is asking. On a hosted server or in single player the host's own requests come from its
// own machine; anyone else is matched to the player on the machine the call came from. (On a
// hosted server a client can bounce a call off the host so it looks like the host's own; the
// host's Zeus is then the one checked, as with ALiVE_fnc_virtualiseInRadius.)
private _owner = remoteExecutedOwner;
private _caller = objNull;
if (_owner == 0 || {_owner == clientOwner}) then {
    if (hasInterface) then { _caller = player };
} else {
    private _i = allPlayers findIf { owner _x == _owner && {isPlayer _x} };
    if (_i > -1) then { _caller = allPlayers select _i };
};

if (isNull _caller || {isNull (getAssignedCuratorLogic _caller)}) exitWith {
    ["ALiVE Zeus - refused a request (%1) from machine %2: not a player with Zeus", _action, _owner] call ALiVE_fnc_dump;
};

// No faster than two requests a second per player, and the Zeus is told when one is dropped
if (isNil "ALiVE_zeus_lastRequest") then { ALiVE_zeus_lastRequest = createHashMap };
private _uid = getPlayerUID _caller;
if (time - (ALiVE_zeus_lastRequest getOrDefault [_uid, -10]) < 0.5) exitWith {
    ["STR_ALIVE_ZEUS_TOO_FAST"] remoteExecCall ["ALiVE_fnc_zeusFeedback", _caller];
};
ALiVE_zeus_lastRequest set [_uid, time];

// ALiVE_fnc_zeusServer only accepts a call that comes through here: this name is visible down
// the call chain and nowhere else
private _ALiVE_zeusCaller = _caller;
[_action, _args, _caller] call ALiVE_fnc_zeusServer;
