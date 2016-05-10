#include <\x\alive\addons\mil_cqb\script_component.hpp>
SCRIPT(removeCQBpositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeCQBpositions
Description:
Creates the server side object to store settings

Parameters:
_this select 0: ARRAY - position of center
_this select 1: NUMBER - radius

Returns:
Nil

See Also:
- <ALIVE_fnc_CQB>

Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_pos","_logics","_radius","_types","_instances","_houses"];

if (isnil "ALiVE_CQB") exitwith {};

PARAMS_3(_pos,_radius,_logics);

if (isnil "ALiVE_CQB") exitwith {};

_types = ["regular","strategic"];

if (!isnil "_logics") then {_instances = _logics} else {_instances = ALiVE_CQB getvariable ["instances",[]]};

if (count _instances > 0) then {

    {
        _instance = _x;
        _filtered = [];

        _instanceType = _x getvariable ["instancetype","regular"];
        _houses = _instance getvariable ["houses",[]];
        _housesPending = _instance getvariable ["houses_pending",[]];
        _debug = [_instance,"debug"] call ALiVE_fnc_CQB;
        _houses = _houses - _housesPending;
        _housesPending = _housesPending - _houses;
        _housesTotal = _housesPending + _houses;

        [_instance,"active",false] call ALiVE_fnc_CQB;
        [_instance,"debug",false] call ALiVE_fnc_CQB;

        waituntil {_script = _instance getvariable "process"; isnil "_script" || {scriptDone _script} || {time <= 0}};

        {
            if (_instanceType in _types && {_pos distance _x < _radius}) then {
                _filtered pushback _x;
            };
        } foreach _houses;

        _instance setvariable ["houses",_houses - _filtered];
        _instance setvariable ["houses_pending",_housesPending + _filtered];

        [_instance,"active",true] call ALiVE_fnc_CQB;
        [_instance,"debug",_debug] call ALiVE_fnc_CQB;
    } foreach _instances;
};

