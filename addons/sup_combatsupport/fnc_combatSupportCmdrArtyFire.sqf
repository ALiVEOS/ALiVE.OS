#include "\x\alive\addons\sup_combatsupport\script_component.hpp"
SCRIPT(combatSupportCmdrArtyFire);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupportCmdrArtyFire

Description:
Commander's guns, the part every way of asking shares: picks the nearest ready battery of a side
with the grid in reach, refuses when friendlies are near the grid (unless the commander's module has
danger close on), and starts the fire mission. Server side, called by
ALIVE_fnc_combatSupportCmdrArtyRequest (the tablet) and ALIVE_fnc_combatSupportCmdrArtyOrder
(an order from outside the game), which set _cmdrArtyFireAllowed first. Never remoteExec'd.

Parameters:
Side - whose guns
Array - grid position [x, y, 0]
String - ordnance: HE, SMOKE or ILLUM
Number - rounds, 1 to 24
Boolean - mortars only
Object - the player who asked, or objNull for an order from outside the game

Returns:
Array - [true, battery entity id, metres] when a battery fires, or [false, "noguns" / "nobattery" / "friendlies"]
("nobattery": the side has no batteries left at all)

Author:
Jman
---------------------------------------------------------------------------- */

// only through the two entries above, which set this local first: a client that remoteExecs this
// function directly has no such variable and is refused
if (!isServer || {isNil "_cmdrArtyFireAllowed"}) exitWith { [false, "refused"] };
params ["_side", "_pos", "_ord", "_count", ["_mortarsOnlyAll", false], ["_caller", objNull]];
private _sideText = toUpper str _side;

if (isNil "ALIVE_profileHandler") exitWith { [false, "noguns"] };

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
        private _mortarsOnly = _mortarsOnlyAll || {_sideText in (_inst getVariable ["asymSides", []])} || {
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

// none reaches it, or the side has none left at all: a commander whose batteries were all destroyed refused every
// grid as out of reach (RSS7, 13 Nov), and the player read it as a range problem
if (_best isEqualTo []) exitWith {
    private _have = ((missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]) findIf {
        ((_x getVariable ["batteryRegistry", []]) findIf {
            private _s = [_x, "side", ""] call ALiVE_fnc_hashGet;
            ((if (_s isEqualType west) then { toUpper str _s } else { toUpper _s }) == _sideText)
                && {!isNil { [ALIVE_profileHandler, "getProfile", [_x, "entityID", ""] call ALiVE_fnc_hashGet] call ALIVE_fnc_profileHandler }}
        }) >= 0
    }) >= 0;
    [false, ["nobattery", "noguns"] select _have]
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
if (isNull _bestLogic) exitWith { [false, "friendlies"] };

// unscheduled from the pick to here, so nothing else can take this battery in between
[_best, "state", "FIRING"] call ALiVE_fnc_hashSet;
_bestLogic setVariable ["activeMissions", (_bestLogic getVariable ["activeMissions", 0]) + 1];
[_bestLogic, _best, "", _pos, false, _ord, _count, _caller] spawn ALIVE_fnc_MilArtilleryFireMission;
[true, [_best, "entityID", ""] call ALiVE_fnc_hashGet, round _bestDist]
