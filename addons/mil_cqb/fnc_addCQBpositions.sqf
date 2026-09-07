#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(addCQBpositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCQBpositions
Description:
Enables registered CQB houses in a radius around a given position for the
passed CQB handlers.

Parameters:
_this select 0: ARRAY - position of center in [0,0,0] format
_this select 1: NUMBER - radius
_this select 2: ARRAY - optional CQB handlers

Returns:
Nil

See Also:
- <ALIVE_fnc_CQB>

Author:
Highhead
Peer Reviewed:
nil
---------------------------------------------------------------------------- */

if (isNil "ALiVE_CQB") exitWith {};

params ["_pos", "_radius"];
private _instances = _this param [2, ALiVE_CQB getVariable ["instances", []]];

{
    private _instance = _x;
    if ((_instance getVariable ["instancetype", "regular"]) in ["regular", "strategic"]) then {
        private _debug = [_instance, "debug"] call ALiVE_fnc_CQB;
        if (_debug) then {[_instance, "debug", false] call ALiVE_fnc_CQB};

        private _grid = [_instance, "positionGrid"] call ALiVE_fnc_CQB;
        private _candidates = _grid call ["findInRange", [_pos, _radius, false, true, true]];
        private _entries = _candidates apply { [_x select 0, true] };
        [_instance,"setHousesEnabled", _entries] call ALiVE_fnc_CQB;

        if (_debug) then {[_instance,"debug", true] call ALiVE_fnc_CQB};
    };
} forEach _instances;
