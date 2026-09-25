/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_convertAgentAndFollow
Description:
    Server-side handler for the Smart Hybrid agent conversion path. Called
    via remoteExecCall from fnc_advciv_react when a FOLLOW order is issued on
    a createAgent-spawned crowd civilian that has no group (isNull group _unit).

    createGroup and createUnit are server-authoritative commands and must not
    be called on a client. This function isolates the conversion so the calling
    react function (which runs on the action-triggering client) stays safe.

    Steps:
      1. Spawn a replacement unit in a new auto-deleting group at the same
         position and facing, copying key AdvCiv state variables.
      2. Swap the agent for the new unit in ALiVE_advciv_activeUnits.
      3. Delete the original agent.
      4. Join the replacement unit silently into the requesting player's group.
      5. Add the order menu to the new unit.

Parameters:
    _this select 0: OBJECT - The createAgent crowd civilian to convert
    _this select 1: OBJECT - The player who issued the FOLLOW order
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_react, ALIVE_fnc_advciv_orderMenu
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [
    ["_unit",   objNull, [objNull]],
    ["_player", objNull, [objNull]]
];

if (!isServer) exitWith {};
if (isNull _unit || {!alive _unit}) exitWith {};
if (isNull _player) exitWith {};

if (ALiVE_advciv_debug) then {
    ["ALiVE Advanced Civilians - convertAgentAndFollow: converting %1 for player %2", _unit, _player] call ALIVE_fnc_dump;
};

private _pos   = getPosATL _unit;
private _dir   = direction _unit;
private _class = typeOf _unit;

// Capture AdvCiv state variables to transfer to the replacement unit
private _homePos    = _unit getVariable ["ALiVE_advciv_homePos",  getPosATL _unit];
private _nearShots  = _unit getVariable ["ALiVE_advciv_nearShots", 0];
private _panicLevel = _unit getVariable ["ALiVE_advciv_panicLevel", 0];

// Create the replacement unit in a new auto-deleting civilian group
private _grp     = createGroup [civilian, true];
private _newUnit = _grp createUnit [_class, _pos, [], 0, "NONE"];
_newUnit setDir _dir;
_newUnit setPosATL _pos;

_newUnit disableAI "FSM";
_newUnit setBehaviour "CARELESS";
_newUnit setSpeedMode "LIMITED";

// Restore AdvCiv state on the replacement unit
_newUnit setVariable ["ALiVE_advciv_active",      true,       true];
_newUnit setVariable ["ALiVE_advciv_state",        "ORDERED",  true];
_newUnit setVariable ["ALiVE_advciv_order",        "FOLLOW",   true];
_newUnit setVariable ["ALiVE_advciv_orderTarget",  _player,    true];
_newUnit setVariable ["ALiVE_advciv_homePos",      _homePos,   true];
_newUnit setVariable ["ALiVE_advciv_nearShots",    0,          true];
_newUnit setVariable ["ALiVE_advciv_hidingPos",    [],         true];
_newUnit setVariable ["ALiVE_advciv_panicLevel",   _panicLevel];
// Hostility goes with them too, broadcast like every other write of it.
_newUnit setVariable ["ALiVE_CivPop_Hostility", _unit getVariable ["ALiVE_CivPop_Hostility", 30], true];

// Swap the original agent for the new unit in the active units array
private _idx = ALiVE_advciv_activeUnits find _unit;
if (_idx >= 0) then {
    ALiVE_advciv_activeUnits set [_idx, _newUnit];
} else {
    ALiVE_advciv_activeUnits pushBack _newUnit;
};

deleteVehicle _unit;   // Remove the original createAgent unit

// Join the replacement unit into the requesting player's group and enable movement
[_newUnit] joinSilent (group _player);
_newUnit setUnitPos "AUTO";
_newUnit enableAI "MOVE";
_newUnit enableAI "PATH";
_newUnit setSpeedMode "NORMAL";

// Add the order menu so the player can issue further commands
[_newUnit] call ALiVE_fnc_advciv_orderMenu;

if (ALiVE_advciv_debug) then {
    ["ALiVE Advanced Civilians - convertAgentAndFollow: %1 now following in group %2", _newUnit, group _newUnit] call ALIVE_fnc_dump;
};
