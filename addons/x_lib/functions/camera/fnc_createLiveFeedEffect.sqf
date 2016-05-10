#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(createLiveFeedEffect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createLiveFeedEffect

Description:
Create Live Feed Effect

Parameters:
String - type NIGHT_VISION,THERMAL,DEFAULT

Returns:


Examples:
(begin example)
_camera = [_source,_target,false,"HIGH"] call ALIVE_fnc_createLiveFeedEffect;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_type"];

_type = _this select 0;

switch(_type) do
{
    case "NIGHT_VISION":
        {
            1 call BIS_fnc_liveFeedEffects;
        };
    case "THERMAL":
        {
            2 call BIS_fnc_liveFeedEffects;
        };
    case "DEFAULT":
        {
            [] call BIS_fnc_liveFeedEffects;
        };
};