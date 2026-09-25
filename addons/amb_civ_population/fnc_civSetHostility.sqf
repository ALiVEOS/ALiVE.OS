#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civSetHostility);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civSetHostility
Description:
    Moves a civilian's hostility by an amount and keeps its two copies in
    step. Aid, irritation, a wound and a weapon held on a Hostile civilian
    all come through here, so every reader of hostility sees one number.

    The two copies:
    - the agent record's "posture", kept on the server and carried across
      despawn, for civilians from Civilian Placement;
    - the unit variable ALiVE_CivPop_Hostility, broadcast, which is the only
      one a player's machine can read (the ACE menu tiers, the approach
      gesture, the aim reactions, the vehicle stop and Gather Intel).

    The rule for every writer: set both copies. Spawn copies the record onto
    the unit (fnc_civilianAgent), and decay moves both toward the resting
    value 30 (fnc_civilianPopulationSystem).

    The change starts from the record when the civilian is an agent whose
    record still exists, otherwise from the unit variable, which reads 30
    until something writes it. The result is kept between 0 and 100. A
    civilian car is left alone: its record keeps fuel where a person keeps
    posture.

    The records are kept on the server, so a call on any other machine is
    handed to the server and returns nothing there. A mission that limits
    remoteExec with CfgRemoteExec must allow this function for that.

Parameters:
    _this select 0: OBJECT - civilian
    _this select 1: NUMBER - amount to add (negative calms, positive angers)
Returns:
    NUMBER - the value after the change, on the server. Nothing on any
             other machine, for a null object, for 0, or for a car.
See Also:
    ALIVE_fnc_civInteract case "UpdateHostility", ALIVE_fnc_advciv_initUnit,
    ALIVE_fnc_advciv_civAimReact
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_civ", objNull, [objNull]], ["_delta", 0, [0]]];

if (isNull _civ || {_delta == 0}) exitWith {};

// The records are kept on the server alone, so any other machine hands the change over.
if (!isServer) exitWith {
    [_civ, _delta] remoteExecCall ["ALiVE_fnc_civSetHostility", 2];
    nil
};

// The record, when this civilian is an agent whose record still exists. The lookup answers
// with nothing for an id it no longer holds (the record goes on death while the body keeps
// its id), and nothing assigned to a variable removes it, so a flag is kept instead.
private _hasProfile = false;
private _profile = [];
private _civID = _civ getVariable ["agentID", ""];
if (_civID != "" && {!isNil "ALIVE_agentHandler"}) then {
    private _p = [ALIVE_agentHandler, "getAgent", _civID] call ALIVE_fnc_agentHandler;
    if (!isNil "_p") then {
        _profile = _p;
        _hasProfile = true;
    };
};

// Cars are agents too, with fuel where a person keeps posture.
if (_hasProfile && {((_profile select 2) select 4) != "agent"}) exitWith {};

private _base = if (_hasProfile) then {
    (_profile select 2) select 12
} else {
    _civ getVariable ["ALiVE_CivPop_Hostility", 30]
};
private _new = ((_base + _delta) max 0) min 100;

if (_hasProfile && {_new != _base}) then {
    [_profile, "posture", _new] call ALiVE_fnc_hashSet;
};
// Written whenever it differs, which also brings a unit back in step with its record.
if !((_civ getVariable ["ALiVE_CivPop_Hostility", -1]) isEqualTo _new) then {
    _civ setVariable ["ALiVE_CivPop_Hostility", _new, true];
};

_new
