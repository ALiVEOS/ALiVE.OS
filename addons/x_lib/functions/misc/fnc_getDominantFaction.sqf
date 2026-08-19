#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(getDominantFaction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getDominantFaction

Description:
Returns the dominant faction within given radius, Takes into account profiles

Parameters:
Array - Position measuring from
Number - Distance being measured (optional)

Returns:
Number - Faction ConfigName ("BLU_F","OPF_F",etc.)

Examples:
(begin example)
[getposATL player, 500] call ALiVE_fnc_getDominantFaction
(end)

Author:
Highhead
Jman
---------------------------------------------------------------------------- */
private ["_pos","_radius","_fac","_facs","_profiles","_result","_noCiv","_weighted"];

PARAMS_1(_pos);
DEFAULT_PARAM(1,_radius,500);
DEFAULT_PARAM(2,_noCiv,false);
// #897 - optional: weight votes by unit count instead of one vote per
// profile/group, so a couple of two-man scout profiles can't outvote a
// full garrison. Default off preserves every existing caller.
DEFAULT_PARAM(3,_weighted,false);

//Virtual Profiles activated?
if !(isnil "ALIVE_profileHandler") then {
    _profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
} else {
    _profiles = [[],[],[]];
};

_facs = [];
{
    if (((_x select 2 select 5) == "entity") && {!(_x select 2 select 1)} && {!(_x select 2 select 30)} && {(_x select 2 select 2) distance _pos < _radius}) then {
        private _votes = 1;
        if (_weighted) then { _votes = (_x select 2 select 12) max 1; }; // unitCount
        for "_i" from 1 to _votes do {
            _facs pushback (_x select 2 select 29);
        };
    };
} foreach (_profiles select 2);

{
    if ((_pos distance (getposATL (leader _x)) < _radius) && {{isPlayer _x} count (units _x) < 1}) then {
        // Who HOLDS an area is decided by forces on the ground, not by aircrew. A pilot never
        // dismounts and never contests anything, and is very often not even of the same faction as
        // the aircraft: a modded or Creator DLC helicopter that does not define its own pilots
        // inherits the base game ones, so two vanilla pilots parked in a friendly helicopter were
        // outvoting a whole garrison and handing the area to a faction with no infantry there at
        // all. Ignore a group whose every living member is airborne crew. Deliberately limited to
        // aircraft: a static weapon gunner or troops holding a checkpoint from their vehicle are
        // still holding the ground, so they keep their say. Drone operators sit inside their
        // aircraft and are covered by the same test.
        // Troops under a canopy still count: a parachute reports as an aircraft, and men dropping
        // onto an objective are very much contesting it.
        private _grounded = (units _x) select {
            alive _x && {isNull (objectParent _x)
                || {!((objectParent _x) isKindOf "Air")}
                || {(objectParent _x) isKindOf "ParachuteBase"}}
        };
        if (count _grounded > 0) then {
            // Weight by the men on the ground, not by everyone aboard, or a full squad sitting in a
            // parked helicopter would still cast a vote each through the one crewman standing outside.
            private _votes = 1;
            if (_weighted) then { _votes = (count _grounded) max 1; };
            for "_i" from 1 to _votes do {
                _facs pushback (faction(leader _x));
            };
        };
    };
} foreach allgroups;

_result = [];
{
    private ["_fac","_cnt"];
    if (count _facs == 0) exitwith {};

    _fac = _x;
    _cnt = {_fac == _x} count _facs;

    if (_cnt > 0) then {
        _result pushback [_fac,_cnt];
        _facs = _facs - [_fac];
    };
} foreach _facs;

_result = [_result,[],{_x select 1},"DESCEND",{if (_noCiv) then {!(((_x select 0) call ALiVE_fnc_factionSide) == CIVILIAN)} else {true}}] call ALiVE_fnc_SortBy;

if ((count _result > 0) && {(_result select 0 select 1) > 0}) then {
    (_result select 0) select 0;
} else {nil};