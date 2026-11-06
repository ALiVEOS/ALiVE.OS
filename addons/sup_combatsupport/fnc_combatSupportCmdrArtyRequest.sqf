#include "\x\alive\addons\sup_combatsupport\script_component.hpp"
SCRIPT(combatSupportCmdrArtyRequest);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupportCmdrArtyRequest

Description:
Commander's guns (F509). A Combat Support tablet operator asks the AI Commander's own batteries
(mil_artillery) to fire at a grid. Server side. The caller is found from the connection, never
from the request, and the side is the caller's. The setting on the Player Combat Support module
(Commander artillery on call) decides whether mortars only or every battery may answer; an
asymmetric commander answers with mortars only. The nearest ready battery of the caller's side
with the grid in reach fires a real mission (ALIVE_fnc_MilArtilleryFireMission), spending the
commander's rounds and cooldown. Friendlies near the grid refuse the call before anything is spent,
unless the commander's module has danger close on.

Called by the tablet with
    [position, "HE" / "SMOKE" / "ILLUM", rounds] remoteExecCall ["ALIVE_fnc_combatSupportCmdrArtyRequest", 2];
A mission that limits remoteExec through CfgRemoteExec must allow this function.

Parameters:
Array - grid position
String - ordnance: HE, SMOKE or ILLUM
Number - rounds asked for (clamped to the battery's own volley)

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
private _say = { ["ALiVE CS - commander's guns: %1", _this] call ALiVE_fnc_dump };
if !(_this isEqualType [] && {count _this in [3, 4]}) exitWith { "refused a request that is not [position, ordnance, rounds]" call _say };
_this params [["_pos", [], [[]]], ["_ord", "", [""]], ["_count", 1, [0]], ["_callerOverride", objNull, [objNull]]];
if !(count _pos in [2, 3] && {(_pos findIf { !(_x isEqualType 0) || {!finite _x} }) < 0}) exitWith { "refused a request without a usable grid" call _say };
_ord = toUpper _ord;
if !(_ord in ["HE", "SMOKE", "ILLUM"]) exitWith { format ["refused a request for %1 rounds", _ord] call _say };
_count = ((round _count) max 1) min 24;
_pos = [_pos select 0, _pos select 1, 0];

// Who is asking, from the connection. On a hosted server the host's own requests come from machine 0.
// The rig test may name a stand-in, but only in a call made on the server itself (never one a
// client sent) and only while its test flag is set.
private _owner = remoteExecutedOwner;
private _caller = objNull;
if (!isNull _callerOverride && {!isRemoteExecuted || {_owner == clientOwner}} && {missionNamespace getVariable ["ALiVE_CS_cmdrArtyProbe", false]}) then {
    _caller = _callerOverride;
} else {
    if (_owner == 0 || {_owner == clientOwner}) then {
        if (hasInterface) then { _caller = player };
    } else {
        private _i = allPlayers findIf { owner _x == _owner && {isPlayer _x} && {getPlayerUID _x != ""} };
        if (_i > -1) then { _caller = allPlayers select _i };
    };
};
if (isNull _caller) exitWith { format ["refused a request from machine %1: not a player", _owner] call _say };

private _side = _caller getVariable ["ALiVE_CS_playerSide", side group _caller];
private _sideText = toUpper str _side;
private _grid = mapGridPosition _pos;
private _fnc_reply = {
    params ["_key"];
    [[objNull, [_key, groupId group _caller, _grid], "side", _side], "NEO_fnc_messageBroadcast", true, false] spawn BIS_fnc_MP;
};

if (isNil "NEO_radioLogic") exitWith { "refused: no Player Combat Support module" call _say };
private _mode = NEO_radioLogic getVariable ["combatsupport_artycommander", 0];
if !(_mode in [1, 2]) exitWith { "refused: Commander artillery on call is Off" call _say };

// the same operator rule as the rest of the tablet
private _singleOperator = NEO_radioLogic getVariable ["combatsupport_singleoperator", true];
if !(_singleOperator isEqualType true) then { _singleOperator = parseNumber format ["%1", _singleOperator] > 0 };
if (_singleOperator && {(NEO_radioLogic getVariable [format ["CS_operatorUID_%1", _side], ""]) != getPlayerUID _caller}) exitWith {
    format ["refused %1: not the side's Combat Support operator", name _caller] call _say;
};

// one request every 5 s per player
if (isNil "ALiVE_CS_cmdrArtyInflight") then { ALiVE_CS_cmdrArtyInflight = createHashMap };
private _uid = [getPlayerUID _caller, str _caller] select (getPlayerUID _caller == "");
if (time - (ALiVE_CS_cmdrArtyInflight getOrDefault [_uid, -100]) < 5) exitWith { format ["refused %1: a request is already on its way", name _caller] call _say };
ALiVE_CS_cmdrArtyInflight set [_uid, time];

private _cmdrArtyFireAllowed = true;
private _r = [_side, _pos, _ord, _count, _mode == 1, _caller] call ALIVE_fnc_combatSupportCmdrArtyFire;
_r params ["_fired", "_what", "_dist"];
if (!_fired) exitWith {
    if (_what == "friendlies") then {
        format ["refused %1: friendlies near %2", name _caller, _grid] call _say;
        ["STR_ALIVE_CS_MSG_CMDR_FRIENDLIES"] call _fnc_reply;
    } else {
        format ["no ready %1 battery reaches %2 with %3 for %4", _sideText, _grid, _ord, name _caller] call _say;
        ["STR_ALIVE_CS_MSG_CMDR_NOGUNS"] call _fnc_reply;
    };
};
format ["%1 asked for %2 %3 at %4: battery %5 (%6 m) fires", name _caller, _count, _ord, _grid, _what, _dist] call _say;
["STR_ALIVE_CS_MSG_CMDR_STANDBY"] call _fnc_reply;
