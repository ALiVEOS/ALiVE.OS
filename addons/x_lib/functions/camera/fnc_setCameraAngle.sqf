#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(setCameraAngle);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setCameraAngle

Description:
Set Camera Angle

Parameters:
Array - position
String - starting camera angle DEFAULT,LOW,EYE,HIGH,BIRDS_EYE,UAV,SATELITE

Returns:


Examples:
(begin example)
_camera = [_position,"HIGH"] call ALIVE_fnc_setCameraAngle;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_position", "_angle", "_y"];

_position = _this select 0;
_angle = _this select 1;

switch(_angle) do
{
    case "DEFAULT":
        {

        };
    case "LOW":
        {
            _y = _position select 2;
            _position set [2,_y+1];
        };
    case "EYE":
        {
            _y = _position select 2;
            _position set [2,_y+1.3];
        };
    case "HIGH":
        {
            _y = _position select 2;
            _position set [2,_y+2];
        };
    case "BIRDS_EYE":
        {
            _y = _position select 2;
            _position set [2,_y+20];
        };
    case "UAV":
        {
            _y = _position select 2;
            _position set [2,_y+100];
        };
    case "SATELITE":
        {
            _y = _position select 2;
            _position set [2,_y+500];
        };

};

_position