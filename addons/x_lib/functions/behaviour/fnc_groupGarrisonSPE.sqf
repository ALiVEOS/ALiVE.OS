#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupGarrisonSPE);
/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupGarrisonSPE
Description:
Garrisons units in area and static weapons
Parameters:
Group - group
Array - position
Scalar - radius
Boolean - move to position instantly (no animation)
Boolean - optional, only profiled vehicles (to avoid garrisoning player vehicles)
Returns:
Examples:
(begin example)
[_group,_position,200,true] call ALIVE_fnc_groupGarrisonSPE;
(end)
See Also:
Author:
Jman
---------------------------------------------------------------------------- */

params ["_group","_position","_radius","_moveInstantly", ["_onlyProfiled", false], ["_cbaSearchRadius", 300]];

private _units = units _group;
_radius = 50;

[_group] call ALiVE_fnc_releaseGarrisonBuildings;

// A walk still under way from an earlier order leaves these men alone from here on: this pass
// decides where each of them goes, and a walk it starts tags its own walkers again.
{ _x setVariable ["ALiVE_garrisonWalk", 0] } forEach _units;

if (count _units < 2) exitwith {};

call ALiVE_fnc_staticDataHandler;

private _staticWeapons = nearestObjects [_position, ["StaticWeapon"], _radius];

// Add armed vehicles to list of static weapons to garrison
{
    if ([_x] call ALIVE_fnc_isArmed && { !_onlyProfiled || !isnil { _x getVariable "profileID" } }) then {
        _staticWeapons pushBack _x;
    };
} foreach (nearestObjects [_position, ["Car"], _radius]);

if (count _staticWeapons > 0) then
{
    {
        if (count _units == 0) exitWith {};

        private _weapon = _x;

        // Only a gun a man can actually take uses one up. A wreck, a vehicle locked against AI, or
        // a car whose gun was manned but had a free seat elsewhere, each took a man anyway, and he
        // then got no post at all. And a man walking to a gun isn't in it yet, so it still reads
        // empty: it's claimed for him for as long as the walk may take and isn't handed to another
        // group meanwhile. His own group garrisoning again gives it back to him, or to its next man
        // if he has a post already.
        (_weapon getVariable ["ALiVE_garrisonClaim", [objNull, 0]]) params ["_claimant", "_claimedUntil"];
        private _claimHeld = alive _claimant && {time < _claimedUntil};
        if (alive _weapon && {locked _weapon != 2} && {(_weapon emptyPositions "Gunner") > 0}
            && {!_claimHeld || {group _claimant == _group}}) then {
            private _unit = [_units select 0, _claimant] select (_claimHeld && {_claimant in _units});
            if (_moveInstantly) then {
                _unit assignAsGunner _weapon;
                _unit moveInGunner _weapon;
            } else {
                _unit assignAsGunner _weapon;
                [_unit] orderGetIn true;
                _weapon setVariable ["ALiVE_garrisonClaim", [_unit, time + 125]];
            };
            _units deleteAt (_units find _unit);
        };
    } forEach _staticWeapons;
};

// Every man went to a gun: nobody walks to a position.
if (count _units == 0) exitwith {};

// Garrison any remaining units onto CBA AI Building Positions (CBA_buildingPos objects) when
// the mission-maker has placed them, so a Garrison Objective mans custom positions such as
// trench slots. Sweep the whole objective (radius = the objective's Size, passed in), not just
// the 50 m static-weapon search above -- a trench / defensive line can span well beyond it. (#945)
private _movementAssignments = [_units, _position, _cbaSearchRadius, _moveInstantly] call ALIVE_fnc_garrisonUnitsOnCBAPositions;

if !(_movementAssignments isEqualTo []) then {
    // Walking men stay on this machine until they're in place: the AI distributor hands a server
    // group to a headless client, and one handed over mid-walk stops where it is. A second walk
    // given to the group before the first is over shares the hold: the first to start notes each
    // man's own setting and the last to finish puts it back and frees the waypoints. Each man is
    // marked with the walk he's on, so an earlier walk leaves alone a man a later one has sent
    // elsewhere. The count, the hold, the waypoint lock and the start of the walk all happen in one
    // unscheduled step: a new order ends this pass wherever it has got to, and caught between the
    // hold and the walk it would leave the group locked and held for good.
    private _walker = {
        params ["_movementGroup", "_assignments", "_unlock", "_walk"];
        // A man who can't reach his post mustn't hold the group's waypoints locked for as long as it's
        // spawned, so after two minutes the rest stop where they stand.
        private _giveUp = time + 120;
        private _ours = {
            params ["_unit"];
            !isNull _unit && {alive _unit} && {group _unit isEqualTo _movementGroup}
                && {(_unit getVariable ["ALiVE_garrisonWalk", _walk]) == _walk}
        };

        {
            _x params ["_unit", "_destination"];
            if ([_unit] call _ours) then {
                [_unit, _destination] call ALiVE_fnc_doMoveRemote;
            };
        } forEach _assignments;

        waitUntil {
            sleep 3;

            {
                _x params ["_unit", "_destination", ["_direction", -1]];
                private _stillAssigned = [_unit] call _ours;

                if (!_stillAssigned || {_unit call ALiVE_fnc_unitReadyRemote}) then {
                    if (_stillAssigned) then {
                        if (_direction >= 0) then {
                            _unit setDir _direction;
                        };
                        doStop _unit;
                    };
                    _assignments deleteAt _forEachIndex;
                };
            } forEachReversed _assignments;

            _assignments isEqualTo [] || {time > _giveUp}
        };
        {
            _x params ["_unit"];
            if (_unlock && {[_unit] call _ours}) then { doStop _unit };
        } forEach _assignments;
        if (_unlock) then {
            isNil {
                private _walks = (_movementGroup getVariable ["ALiVE_garrisonWalks", 1]) - 1;
                _movementGroup setVariable ["ALiVE_garrisonWalks", _walks max 0];
                if (_walks <= 0) then {
                    {
                        _x params ["_heldUnit", "_wasIgnored"];
                        if (!isNull _heldUnit) then { _heldUnit setVariable ["ALiVE_ignore_HC", _wasIgnored] };
                    } forEach (_movementGroup getVariable ["ALiVE_garrisonHCWas", []]);
                    _movementGroup setVariable ["ALiVE_garrisonHCWas", nil];
                    _movementGroup lockWP false;
                };
            };
        };
    };
    private _walk = 0;
    isNil {
        if (!_moveInstantly) then {
            private _walks = _group getVariable ["ALiVE_garrisonWalks", 0];
            if (_walks == 0) then {
                _group setVariable ["ALiVE_garrisonHCWas", (units _group) apply { [_x, _x getVariable ["ALiVE_ignore_HC", false]] }];
                { _x setVariable ["ALiVE_ignore_HC", true] } forEach (units _group);
            };
            _group setVariable ["ALiVE_garrisonWalks", _walks + 1];
            _group lockWP true;
            _walk = (missionNamespace getVariable ["ALiVE_garrisonWalkCount", 0]) + 1;
            missionNamespace setVariable ["ALiVE_garrisonWalkCount", _walk];
            { (_x select 0) setVariable ["ALiVE_garrisonWalk", _walk] } forEach _movementAssignments;
        };
        [_group, _movementAssignments, !_moveInstantly, _walk] spawn _walker;
    };
};
