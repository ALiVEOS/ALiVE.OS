#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(zombieHunt);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zombieHunt

Description:
Outbreak game mode: spawned zombie groups go after civilians, a player in a civilian
slot included. The zombie mod only ever attacks units the engine calls enemies, and no
side is the civilians' enemy, so ALiVE drives the zombies at the nearest civilian and
lands the bite itself. Soldiers stay the priority: while the group knows of an enemy in
range, the zombie mod has it and this loop leaves the group alone.

Runs on the server and on each headless client, over the zombie groups local to that
machine (groups tagged ALiVE_zombieHunt at spawn), so a group the AI distributor hands
to a headless client keeps hunting there. Players' machines do nothing.

Called once with no arguments to start the loop; called with a group by the loop itself.

Parameters:
Group - (optional) a zombie group to run one hunt step for
Scalar - (optional) time of this step

Returns:
Nothing

Examples:
(begin example)
// start the hunt on this machine (the Virtual AI module does it on every machine)
[] call ALiVE_fnc_zombieHunt;
(end)

See Also:
ALiVE_fnc_profileEntity, ALiVE_fnc_profileSystemInit

Author:
Jman
---------------------------------------------------------------------------- */

params [["_group", grpNull], ["_now", 0]];

// ---- start: one loop per machine ------------------------------------------------
if (isNull _group) exitWith {
    if (hasInterface && {!isServer}) exitWith {};
    if (!isNil "ALiVE_zombieHuntPFH") exitWith {};
    if ((missionNamespace getVariable ["ALiVE_zombieHuntRange", 0]) <= 0) exitWith {};

    ALiVE_zombieHuntGroups = [];
    ALiVE_zombieHuntListed = -1;
    ALiVE_zombieHuntCursor = 0;

    // Five times a second, with at most eight groups each time, so a big horde is spread
    // over frames instead of landing in one. Each group is looked at once a second while
    // it has a target and every five seconds while it has none.
    ALiVE_zombieHuntPFH = [{
        private _now = time;
        if (_now > ALiVE_zombieHuntListed + 2) then {
            ALiVE_zombieHuntListed = _now;
            ALiVE_zombieHuntGroups = allGroups select { local _x && {_x getVariable ["ALiVE_zombieHunt", false]} };
        };
        // Start where the last tick stopped, so with a big horde nobody at the back of the list waits forever.
        private _list = ALiVE_zombieHuntGroups;
        private _count = count _list;
        private _done = 0;
        private _seen = 0;
        while { _done < 8 && {_seen < _count} } do {
            private _grp = _list select ((ALiVE_zombieHuntCursor + _seen) % _count);
            _seen = _seen + 1;
            if (!isNull _grp && {_now >= (_grp getVariable ["ALiVE_zombieHuntNext", 0])}) then {
                _done = _done + 1;
                [_grp, _now] call ALiVE_fnc_zombieHunt;
            };
        };
        if (_count > 0) then { ALiVE_zombieHuntCursor = (ALiVE_zombieHuntCursor + _seen) % _count };
    }, 0.2, []] call CBA_fnc_addPerFrameHandler;

    ["ALiVE Zombie Hunt - zombies hunt civilians within %1 m on this machine", ALiVE_zombieHuntRange] call ALiVE_fnc_dump;
};

// ---- one step for one group -----------------------------------------------------
if (!local _group) exitWith {};

private _range = ALiVE_zombieHuntRange;
private _units = (units _group) select { alive _x && {isNull objectParent _x} };
if (_units isEqualTo []) exitWith { _group setVariable ["ALiVE_zombieHuntNext", _now + 5] };

private _lead = leader _group;
if !(_lead in _units) then { _lead = _units select 0 };

// A soldier the group knows about is the zombie mod's job, and it wins over any civilian.
private _enemy = _lead findNearestEnemy _lead;
if (!isNull _enemy && {_lead distance _enemy < _range}) exitWith {
    _group setVariable ["ALiVE_zombieHuntTarget", objNull];
    _group setVariable ["ALiVE_zombieHuntNext", _now + 2];
};

// Nearest civilian, and any hostile soldier close enough to hear. The zombie mod ignores a
// soldier it has not been told about, so without this a horde walks past a rifleman to
// reach a farmer.
private _zombieSide = side _group;
private _target = objNull;
private _targetDist = 1e9;
private _heard = false;
{
    if (alive _x && {isNull objectParent _x} && {!(_x getVariable ["ALiVE_zombie", false])} && {!(_x getVariable ["WBK_AI_isZombie", false])} && {(_x getVariable ["WBK_AI_ZombieMoveSet", ""]) isEqualTo ""}) then {
        private _dist = _lead distance _x;
        // A captive soldier also reads as civilian, so the group's side decides. Agents have no group.
        if (side _x == civilian && {isNull group _x || {side group _x == civilian}}) then {
            if (_dist < _targetDist) then { _target = _x; _targetDist = _dist };
        } else {
            // A captive is left alone: nobody fights him, and knowing about him would stall the group.
            if (_dist < 30 && {!captive _x} && {(_zombieSide getFriend (side group _x)) < 0.6}) then {
                _group reveal [_x, 1.5];
                _heard = true;
            };
        };
    };
} forEach (_lead nearEntities [["CAManBase"], _range]);

if (_heard) exitWith {
    _group setVariable ["ALiVE_zombieHuntTarget", objNull];
    _group setVariable ["ALiVE_zombieHuntNext", _now + 1];
};

if (isNull _target) exitWith {
    // The chase is over: back into formation, so the group picks up its own route again.
    if ((_group getVariable ["ALiVE_zombieHuntIssued", -1]) >= 0) then {
        { if !(_x getVariable ["ALiVE_garrisonHeld", false]) then { _x doFollow (leader _group) } } forEach _units;
        _group setVariable ["ALiVE_zombieHuntIssued", -1];
    };
    _group setVariable ["ALiVE_zombieHuntTarget", objNull];
    _group setVariable ["ALiVE_zombieHuntNext", _now + 5];
};

_group setVariable ["ALiVE_zombieHuntNext", _now + 1];

// Chase. The zombie mod leaves movement alone while it has no enemy, so doMove holds: a
// Runner closes 40 m in about 15 s. Re-issued when the target moves or every 5 seconds.
private _targetPos = getPosATL _target;
if (
    _target != (_group getVariable ["ALiVE_zombieHuntTarget", objNull])
    || {_targetPos distance2D (_group getVariable ["ALiVE_zombieHuntPos", [0,0,0]]) > 3}
    || {_now > (_group getVariable ["ALiVE_zombieHuntIssued", 0]) + 5}
) then {
    // A garrison the profile holds in place stays put.
    { if !(_x getVariable ["ALiVE_garrisonHeld", false]) then { _x doMove _targetPos } } forEach _units;
    _group setVariable ["ALiVE_zombieHuntTarget", _target];
    _group setVariable ["ALiVE_zombieHuntPos", _targetPos];
    _group setVariable ["ALiVE_zombieHuntIssued", _now];
};

// Bite. The zombie is named as the killer, so kill credit, the Killed and MPKilled events
// and anything reading the killer see a zombie. Bites take effect on every machine.
private _bite = ALiVE_zombieBiteDamage;
if (_bite > 0) then {
    {
        if (alive _target && {_x distance _target < 2.2} && {_now >= (_x getVariable ["ALiVE_zombieBiteNext", 0])}) then {
            _x setVariable ["ALiVE_zombieBiteNext", _now + 1.5];
            _target setDamage [((damage _target) + _bite) min 1, true, _x];
        };
    } forEach _units;
};

// The civilian runs: one dash of 40 m directly away, then not again for 30 seconds, so the
// zombie gets its chance. Sent every few seconds, a crowd agent outran a Runner for good.
// A player moves themselves. The order goes to the machine that owns the civilian; crowd
// agents ignore doMove and take setDestination.
if (alive _target && {!isPlayer _target} && {_now >= (_target getVariable ["ALiVE_zombieFleeNext", 0])}) then {
    _target setVariable ["ALiVE_zombieFleeNext", _now + 30];
    private _away = _target getPos [40, _lead getDir _target];
    if (isAgent teamMember _target) then {
        if (local _target) then { _target setDestination [_away, "LEADER PLANNED", true] } else { [_target, [_away, "LEADER PLANNED", true]] remoteExecCall ["setDestination", _target] };
    } else {
        if (local _target) then { _target doMove _away } else { [_target, _away] remoteExecCall ["doMove", _target] };
    };
};
