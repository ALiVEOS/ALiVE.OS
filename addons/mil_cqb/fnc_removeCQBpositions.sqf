#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(removeCQBpositions);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_removeCQBpositions
Description:
Disables registered CQB houses in a radius around a given position for the
passed CQB handlers.

Parameters:
_this select 0: ARRAY - position of center
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

        private _registry = [_instance, "houses"] call ALiVE_fnc_CQB;
        private _grid = [_instance, "positionGrid"] call ALiVE_fnc_CQB;
        private _candidates = _grid call ["findInRange", [_pos, _radius, false, true, true]];
        private _entries = _candidates apply {[(_registry get _x) select 0, false]};
        [_instance, "setHousesEnabled", _entries] call ALiVE_fnc_CQB;

        if (_debug) then {[_instance, "debug", true] call ALiVE_fnc_CQB};
    };
} forEach _instances;

