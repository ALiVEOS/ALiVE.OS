#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskCreateExplosiveProjectile);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCreateExplosiveProjectile

Description:
Create an explosive projectile and orientate it towards a target object

Parameters:

Returns:

Examples:
(begin example)
[player,"EXPLOSION_SMALL"] call ALIVE_fnc_taskCreateExplosiveProjectile;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_target","_type","_object"];

_target = _this select 0;
_type = _this select 1;

switch(_type) do {
    case "EXPLOSION_SMALL": {
        _object = "GrenadeHand" createVehicle ((_target) modelToWorld [0,0,1]);
        _object setVelocity [0,0,-10];
    };
    case "EXPLOSION_MEDIUM": {
        _object = "Sh_82mm_AMOS" createVehicle ((_target) modelToWorld [0,0,1]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
    case "EXPLOSION_LARGE": {
        _object = "Sh_120mm_AMOS_LG" createVehicle ((_target) modelToWorld [0,0,1]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
    case "BOMB_SMALL": {
        _object = "G_20mm_HE" createVehicle ((_target) modelToWorld [0,0,100]);
        _object setVelocity [0,0,-10];
    };
    case "BOMB_MEDIUM": {
        _object = "Sh_82mm_AMOS" createVehicle ((_target) modelToWorld [0,0,100]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
    case "BOMB_LARGE": {
        _object = "Sh_120mm_AMOS_LG" createVehicle ((_target) modelToWorld [0,0,100]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
    case "MISSILE_STRIKE_SMALL": {
        _object = "M_NLAW_AT_F" createVehicle ((_target) modelToWorld [0,400,400]);
        [_object,_target] call ALIVE_fnc_pointAt;
    };
    case "MISSILE_STRIKE_MEDIUM": {
        _object = "M_Mo_82mm_AT_LG" createVehicle ((_target) modelToWorld [0,400,400]);
        [_object,_target] call ALIVE_fnc_pointAt;
    };
    case "MISSILE_STRIKE_LARGE": {
        _object = "M_Mo_120mm_AT_LG" createVehicle ((_target) modelToWorld [0,400,400]);
        [_object,_target] call ALIVE_fnc_pointAt;
    };
    case "FLARE_SMALL": {
        _object = "F_20mm_White" createVehicle ((_target) modelToWorld [0,0,200]);
        _object setVelocity [0,0,-1];
    };
    case "FLARE_LARGE": {
        _object = "F_40mm_White" createVehicle ((_target) modelToWorld [0,0,200]);
        _object setVelocity [0,0,-1];
    };
    case "SMOKE_SMALL": {
        _object = "G_40mm_Smoke" createVehicle ((_target) modelToWorld [0,0,300]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
    case "SMOKE_LARGE": {
        _object = "Smoke_120mm_AMOS_White" createVehicle ((_target) modelToWorld [0,0,100]);
        [_object,_target] call ALIVE_fnc_pointAt;
        _object setVelocity [0,0,-10];
    };
};

_object
