#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateBombardment);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateBombardment

Description:
Create a bombardment directed at an object

Parameters:

Returns:

Examples:
(begin example)

// Spawns small explosions in a random area around the target
[player,"EXPLOSION_SMALL"] call ALIVE_fnc_taskCreateBombardment;

// Spawns missile strikes in a random area around the target, also with random timings
[player,"MISSILE_STRIKE_SMALL",10,30,true,10] call ALIVE_fnc_taskCreateBombardment;

// Spawns large bombs in a random area around the target, also with random timings
[player,"EXPLOSION_LARGE",10,30,true,20] call ALIVE_fnc_taskCreateBombardment;

// Spawns large bombs in a random area around the target, also with random timings
[player,"FLARE_SMALL",10,30,true,20] call ALIVE_fnc_taskCreateBombardment;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

[_this] spawn {

    private ["_args","_target","_type","_count","_distance","_randomTiming","_randomTimingMax","_position","_object"];

    _args = _this select 0;
    _target = _args select 0;
    _type = _args select 1;
    _count = if(count _args > 2) then {_args select 2} else {5};
    _distance = if(count _args > 3) then {_args select 3} else {100};
    _randomTiming = if(count _args > 4) then {_args select 4} else {false};
    _randomTimingMax = if(count _args > 5) then {_args select 5} else {10};

    for "_i" from 0 to _count-1 do
    {
        _object = [_target, _type] call ALIVE_fnc_taskCreateExplosiveProjectile;
        _position = [position _object, random _distance, random 360] call BIS_fnc_relPos;
        _object setPosATL _position;

        if(_randomTiming) then
        {
            sleep floor(5 + (random _randomTimingMax));
        };
    };

};