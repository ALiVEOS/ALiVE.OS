#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(IEDAmbush);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_IEDAmbush

Description:
A squad that comes in after an IED goes off, to finish the survivors (Ambush Chance After a
Blast; Will501 on Discord, 15 Oct). It is the nearest hostile force's: the unit classes of
the nearest virtual group hostile to the players' side within 3 km, so it matches whoever
holds the area, a mod faction included. With no such group, or no player near the blast,
there is no ambush.

The squad appears 150-300 m away where no player near the blast can see it, searches and
destroys round the blast, then pulls back after 3 to 5 minutes or once half of it is down,
and is removed once no player is within 800 m. It costs no commander anything and is kept out
of the profile system, so it never joins anyone's forces.

Parameters:
Array - the blast position
Array - optional: who it is after, in place of the players within 300 m (tests)

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
params [["_pos", [0,0,0], [[]]], ["_targets", [], [[]]]];

private _debug = ADDON getVariable ["debug", false];
if (_debug isEqualType "") then { _debug = _debug in ["true", "1"] };
private _say = { if (_debug) then { ["ALIVE-%1 IED ambush: %2", time, _this] call ALiVE_fnc_dump } };

private _players = if (_targets isNotEqualTo []) then { _targets } else { allPlayers select { alive _x && {(vehicle _x) distance2D _pos < 300} } };
if (_players isEqualTo []) exitWith { "no player within 300 m of the blast, no ambush" call _say };
if (isNil "ALiVE_profileHandler") exitWith { "no profile system to find a hostile force from, no ambush" call _say };

// the nearest virtual group hostile to the players' side
private _pSide = side group (_players select 0);
private _best = [];
private _bestD = 1e9;
{
    _x params ["_sideObj", "_sideText"];
    if ((_pSide getFriend _sideObj) < 0.6) then {
        {
            private _d = (_x select 2 select 2) distance2D _pos;
            if (_d < _bestD) then { _bestD = _d; _best = _x };
        } forEach ([_pos, 3000, [_sideText, "entity"]] call ALIVE_fnc_getNearProfiles);
    };
} forEach [[east, "EAST"], [west, "WEST"], [resistance, "GUER"]];
if (_best isEqualTo []) exitWith { "no hostile force within 3 km, no ambush" call _say };

private _classes = ([_best, "unitClasses", []] call ALIVE_fnc_hashGet) select { isClass (configFile >> "CfgVehicles" >> _x) && {_x isKindOf "CAManBase"} };
if (_classes isEqualTo []) exitWith { "the nearest hostile force has no infantry classes, no ambush" call _say };
_classes = _classes select [0, 6];
private _side = [[_best, "side", "EAST"] call ALIVE_fnc_hashGet] call ALiVE_fnc_sideTextToObject;

// 150-300 m out, on land, where no player near the blast can see it
private _spot = [];
for "_i" from 1 to 40 do {
    private _p = _pos getPos [150 + random 150, random 360];
    _p set [2, 0];
    private _eye = (ATLToASL _p) vectorAdd [0, 0, 1.6];
    if (!surfaceIsWater _p && {([_p, 120] call ALiVE_fnc_anyPlayersInRange) == 0}
        && {(_players findIf {
            private _pe = eyePos _x;
            !(terrainIntersectASL [_pe, _eye]) && {(lineIntersectsSurfaces [_pe, _eye, vehicle _x, objNull, true, 1, "VIEW", "FIRE"]) isEqualTo []}
        }) < 0}) exitWith { _spot = _p };
};
if (_spot isEqualTo []) exitWith { "no spot out of sight 150-300 m from the blast, no ambush" call _say };

private _grp = createGroup [_side, true];
_grp setVariable ["ALIVE_profileIgnore", true, true];
{ _grp createUnit [_x, _spot, [], 5, "FORM"] } forEach _classes;
private _units = units _grp;
{ _x setVariable ["ALIVE_profileIgnore", true, true] } forEach _units;
// in fast to the blast, then search and destroy round it; told nothing about the players, so it
// closes in rather than starting a long-range firefight from where it appears
_grp setCombatMode "RED";
private _in = _grp addWaypoint [_pos getPos [40, _pos getDir _spot], 0];
_in setWaypointType "MOVE";
_in setWaypointBehaviour "AWARE";
_in setWaypointSpeed "FULL";
_grp setCurrentWaypoint _in;
private _wp = _grp addWaypoint [_pos, 30];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "COMBAT";
format ["%1 men of %2 (%3) %4 m from the blast at %5", count _units, [_best, "faction", ""] call ALIVE_fnc_hashGet, _side, round (_spot distance2D _pos), _pos] call _say;

[_grp, _pos, count _units, _debug] spawn {
    params ["_grp", "_pos", "_size", "_debug"];
    private _say = { if (_debug) then { ["ALIVE-%1 IED ambush: %2", time, _this] call ALiVE_fnc_dump } };
    private _pullAt = time + 180 + random 120;
    waitUntil { sleep 5; isNull _grp || {({ alive _x } count units _grp) <= _size / 2} || {time > _pullAt} };
    if (isNull _grp || {({ alive _x } count units _grp) == 0}) exitWith {};
    // back the way it came, away from the blast
    private _leader = leader _grp;
    while { (count waypoints _grp) > 0 } do { deleteWaypoint ((waypoints _grp) select 0) };
    _grp setBehaviour "AWARE";
    _grp addWaypoint [_pos getPos [700, _pos getDir _leader], 50];
    "pulling back" call _say;
    waitUntil { sleep 10; isNull _grp || {({ alive _x } count units _grp) == 0} || {(units _grp) findIf { alive _x && {([getPosATL _x, 800] call ALiVE_fnc_anyPlayersInRange) > 0} } < 0} };
    if (!isNull _grp) then {
        { if (alive _x) then { deleteVehicle _x } } forEach units _grp;
        "removed, out of every player's reach" call _say;
    };
};
