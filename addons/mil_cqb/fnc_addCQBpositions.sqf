#include <\x\alive\addons\mil_cqb\script_component.hpp>
SCRIPT(addCQBpositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCQBpositions
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

private ["_pos","_logics","_radius","_types","_instances"];

if (isnil "ALiVE_CQB") exitwith {};

PARAMS_3(_pos,_radius,_logics);

_types = ["regular","strategic"];

if (!isnil "_logics") then {_instances = _logics} else {_instances = ALiVE_CQB getvariable ["instances",[]]};

if (count _instances > 0) then {

    {
        private _instance = _x;
        private _filtered = [];

        private _instanceType = _x getvariable ["instancetype","regular"];
        private _houses = _instance getvariable ["houses",[]];
        private _housesPending = _instance getvariable ["houses_pending",[]];
        private _debug = [_instance,"debug"] call ALiVE_fnc_CQB;
        _houses = _houses - _housesPending;
        _housesPending = _housesPending - _houses;
        private _housesTotal = _housesPending + _houses;

        [_instance,"debug",false] call ALiVE_fnc_CQB;

        {
            if (_instanceType in _types && {_pos distance _x < _radius}) then {
                _filtered pushback _x;
            };
        } foreach _housesPending;

        _instance setvariable ["houses",_houses + _filtered];
        _instance setvariable ["houses_pending",_housesPending - _filtered];

        [_instance,"debug",_debug] call ALiVE_fnc_CQB;
    } foreach _instances;
};

