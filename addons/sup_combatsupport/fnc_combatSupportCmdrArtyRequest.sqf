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

if (isNil "ALIVE_profileHandler") exitWith { "refused: no Virtual AI System" call _say; ["STR_ALIVE_CS_MSG_CMDR_NOGUNS"] call _fnc_reply };

// the nearest ready battery of the caller's side, by the commander's own rules
private _best = [];
private _bestLogic = objNull;
private _bestDist = 1e9;
{
    private _inst = _x;
    private _prof = _inst getVariable ["intensityProfile", [420,120,75,6,2,1,90]];
    if ((_inst getVariable ["activeMissions", 0]) < (_prof select 5)) then {
        // an Insurgency commander answers with mortars only; a module not synced to its commander
        // knows that side only by looking the commander up, as its own requests do
        private _mortarsOnly = _mode == 1 || {_sideText in (_inst getVariable ["asymSides", []])} || {
            ((missionNamespace getVariable ["OPCOM_instances", []]) findIf {
                _x isEqualType [] && {toUpper ([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText} && {([_x, "controltype", ""] call ALiVE_fnc_hashGet) == "asymmetric"}
            }) >= 0
        };
        {
            private _rec = _x;
            private _recSide = [_rec, "side", ""] call ALiVE_fnc_hashGet;
            private _recSideText = if (_recSide isEqualType west) then { toUpper str _recSide } else { toUpper _recSide };
            if (_recSideText == _sideText
                && {([_rec, "state", ""] call ALiVE_fnc_hashGet) == "IDLE"}
                && {time > ([_rec, "cooldownUntil", 0] call ALiVE_fnc_hashGet)}
                && {([_rec, "rounds", 0] call ALiVE_fnc_hashGet) > 0}
                && {!_mortarsOnly || {([_rec, "kind", "gun"] call ALiVE_fnc_hashGet) == "mortar"}}) then {
                private _ep = [ALIVE_profileHandler, "getProfile", [_rec, "entityID", ""] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler;
                if (!isNil "_ep") then {
                    private _dist = ([_ep, "position"] call ALiVE_fnc_hashGet) distance2D _pos;
                    private _reach = ([_rec, "maxRange", 0] call ALiVE_fnc_hashGet) * ([1.25, 0.95] select ([_rec, "probed", false] call ALiVE_fnc_hashGet));
                    if (_dist < _reach && {_dist > (([_rec, "minRange", 300] call ALiVE_fnc_hashGet) max 300)} && {_dist < _bestDist}) then {
                        private _vClass = "";
                        private _veh = objNull;
                        private _vp = [ALIVE_profileHandler, "getProfile", ([_rec, "vehicleIDs", []] call ALiVE_fnc_hashGet) param [0, ""]] call ALIVE_fnc_profileHandler;
                        if (!isNil "_vp") then {
                            _vClass = [_vp, "vehicleClass", ""] call ALiVE_fnc_hashGet;
                            if ([_vp, "active", false] call ALiVE_fnc_hashGet) then { _veh = [_vp, "vehicle", objNull] call ALiVE_fnc_hashGet };
                        };
                        if (isNil "ALiVE_CS_fnc_cmdrOrdnance" || {_ord in ([_vClass, _veh] call ALiVE_CS_fnc_cmdrOrdnance)}) then {
                            _best = _rec; _bestLogic = _inst; _bestDist = _dist;
                        };
                    };
                };
            };
        } forEach (_inst getVariable ["batteryRegistry", []]);
    };
} forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]);

if (_best isEqualTo []) exitWith {
    format ["no ready %1 battery reaches %2 with %3 for %4", _sideText, _grid, _ord, name _caller] call _say;
    ["STR_ALIVE_CS_MSG_CMDR_NOGUNS"] call _fnc_reply;
};

// friendlies near the grid refuse the call before any cooldown is spent; the fire mission checks again
if !([_bestLogic, "dangerClose"] call ALIVE_fnc_MilArtillery) then {
    private _prof = _bestLogic getVariable ["intensityProfile", [420,120,75,6,2,1,90]];
    private _ffRadius = (_prof select 2) + 150;
    private _blocked = false;
    {
        if (!_blocked && {([_x, "type", ""] call ALiVE_fnc_hashGet) in ["entity", "vehicle"]}) then {
            private _pSide = [_x, "side", ""] call ALiVE_fnc_hashGet;
            if (_pSide isEqualType "" && {_pSide != ""}
                && {[([_pSide] call ALIVE_fnc_sideTextToObject), _side] call BIS_fnc_sideIsFriendly}
                && {([_x, "position"] call ALiVE_fnc_hashGet) distance2D _pos < _ffRadius}) then {
                _blocked = true;
            };
        };
    } forEach (([ALIVE_profileHandler, "profiles"] call ALiVE_fnc_hashGet) select 2);
    if (!_blocked) then {
        _blocked = ((allPlayers - entities "HeadlessClient_F") findIf { _x distance2D _pos < _ffRadius && {[side group _x, _side] call BIS_fnc_sideIsFriendly} }) > -1;
    };
    if (_blocked) then { _bestLogic = objNull };
};
if (isNull _bestLogic) exitWith {
    format ["refused %1: friendlies near %2", name _caller, _grid] call _say;
    ["STR_ALIVE_CS_MSG_CMDR_FRIENDLIES"] call _fnc_reply;
};

// unscheduled from the pick to here, so nothing else can take this battery in between
[_best, "state", "FIRING"] call ALiVE_fnc_hashSet;
_bestLogic setVariable ["activeMissions", (_bestLogic getVariable ["activeMissions", 0]) + 1];
[_bestLogic, _best, "", _pos, false, _ord, _count, _caller] spawn ALIVE_fnc_MilArtilleryFireMission;
format ["%1 asked for %2 %3 at %4: battery %5 (%6 m) fires", name _caller, _count, _ord, _grid, [_best, "entityID", ""] call ALiVE_fnc_hashGet, round _bestDist] call _say;
["STR_ALIVE_CS_MSG_CMDR_STANDBY"] call _fnc_reply;
