#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskGetStateOfEntityProfiles);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskGetStateOfEntityProfiles

Description:
Get the current state of some entity profiles

Parameters:

Returns:

Examples:
(begin example)
(end)

See Also:

Author:
ARJay
Jman
---------------------------------------------------------------------------- */

private ["_taskProfiles","_profiles","_state","_entityProfile","_active","_vehicle","_units"];

_taskProfiles = _this select 0;

_profiles = [];
_state = [] call ALIVE_fnc_hashCreate;
[_state,"allDestroyed",true] call ALIVE_fnc_hashSet;

{
    _entityProfile = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;

    if!(isNil "_entityProfile") then {

        _active = _entityProfile select 2 select 1;

        _profiles pushback _entityProfile;

        // DIAG-STRIP #942: log each checked profile's active/virtual + alive state so a
        // reporter RPT shows whether a kill is missed because the target is virtualised
        // (active=false forces allDestroyed=false) or the units are genuinely still alive.
        if (!isNil "ALiVE_c2istar_taskDiag" && {ALiVE_c2istar_taskDiag}) then {
            private _diagAlive = if (_active) then { {alive _x} count (_entityProfile select 2 select 21) } else { -1 };
            ["[C2ISTAR #942 DIAG] taskGetState profile=%1 active=%2 aliveUnits=%3 (-1 = profile virtual)", _x, _active, _diagAlive] call ALIVE_fnc_dump;
        };

        if(_active) then {

            _units = _entityProfile select 2 select 21;

            {

                if(alive _x) then {

                    [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

                };

            } forEach _units;

        }else{

            [_state,"allDestroyed",false] call ALIVE_fnc_hashSet;

        };

    };

} forEach _taskProfiles;

[_state,"profiles",_profiles] call ALIVE_fnc_hashSet;

_state
