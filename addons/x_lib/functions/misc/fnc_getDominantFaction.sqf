#include <\x\alive\addons\x_lib\script_component.hpp>
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
private ["_pos","_radius","_fac","_facs","_profiles","_result","_noCiv"];

PARAMS_1(_pos);
DEFAULT_PARAM(1,_radius,500);
DEFAULT_PARAM(2,_noCiv,false);

//Virtual Profiles activated?
if !(isnil "ALIVE_profileHandler") then {
	_profiles = [ALIVE_profileHandler, "profiles"] call ALIVE_fnc_hashGet;
} else {
	_profiles = [[],[],[]];
};

_facs = [];
{
    if (((_x select 2 select 5) == "entity") && {!(_x select 2 select 1)} && {!(_x select 2 select 30)} && {(_x select 2 select 2) distance _pos < _radius}) then {
        _facs pushback (_x select 2 select 29);
    };
} foreach (_profiles select 2);

{
    if ((_pos distance (getposATL (leader _x)) < _radius) && {{isPlayer _x} count (units _x) < 1}) then {
        _facs pushback (faction(leader _x));
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