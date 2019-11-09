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
---------------------------------------------------------------------------- */
params [
    "_pos",
    ["_radius",500],
    ["_noCiv",false],
    ["_includePlayers", false]
];

//Virtual Profiles activated?
if !(isnil "ALIVE_profileHandler") then {
    _profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
} else {
    _profiles = [[],[],[]];
};

private _facs = [];

// count near inactive profiles

private _nearEntities = [_pos,_radius,["all","entity"]] call ALiVE_fnc_getNearProfiles;
{
    private _active = _x select 2 select 1;
    private _isPlayer = _x select 2 select 30;

    if (!_active && { !_includePlayers && !_isPlayer }) then {
        private _faction = _x select 2 select 29;
        _facs pushback _factions;
    };
} foreach _nearEntities;

// count near spawned units

{
    private _leader = leader _x;
    private _groupPos = getposatl _leader;

    if (
        _groupPos distance _pos < _radius &&
        { !_includePlayers && { ({!isPlayer _x} count (units _x)) < 1 } }
    ) then {
        private _faction = faction _leader;
        if (!_noCiv) then {
            _facs pushback _faction;
        } else {
            if !((_faction call ALiVE_fnc_factionSide) != CIVILIAN) then {
                _facs pushback _faction;
            };
        };
    };
} foreach allgroups;

// condense factions

private _result = [];
{
    if (_facs isequalto[]) exitwith {};

    private _fac = _x;
    private _count = {_fac == _x} count _facs;

    _result pushback [_fac,_count];
    _facs = _facs - [_fac];
} foreach _facs;

// determine which faction occurred the most

_result sort true;

if !(_result isequalto []) then {
    (_result select 0) select 0
} else {
    nil
};