#include "\x\alive\addons\mil_cqb\script_component.hpp"
SCRIPT(resetCQB);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_resetCQB
Description:
Disables every registered house for the passed CQB handlers. Registration and
the position grid are retained so houses can be enabled again later.

Parameters:
_this select 0: ARRAY - optional CQB handlers

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

private _instances = _this param [0, ALiVE_CQB getVariable ["instances", []]];

{
    private _instance = _x;
    if ((_instance getVariable ["instancetype", "regular"]) in ["regular", "strategic"]) then {
        private _debug = [_instance, "debug"] call ALiVE_fnc_CQB;
        if (_debug) then {[_instance, "debug", false] call ALiVE_fnc_CQB};

        private _registry = [_instance, "houses"] call ALiVE_fnc_CQB;
        [_instance, "setHousesEnabled", (values _registry) apply {[_x select 0, false]}] call ALiVE_fnc_CQB;

        if (_debug) then {[_instance, "debug", true] call ALiVE_fnc_CQB};
    };
} forEach _instances;

