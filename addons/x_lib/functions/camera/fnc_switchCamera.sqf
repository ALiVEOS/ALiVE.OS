#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(switchCamera);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_switchCamera

Description:
Switches camera to another objects perspective

Parameters:
Object - target
String - perspective type: FIRST_PERSON, OPTICS, THIRD_PERSON, FIRST_PERSON_REAL
Boolean - disable player movement

Returns:


Examples:
(begin example)
[_camera,"FIRST_PERSON"] call ALIVE_fnc_switchCamera;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

params ["_target", ["_type", "FIRST_PERSON"], ["_disablePlayer", false]];

if(_disablePlayer) then { disableUserInput true; };

ALIVE_cameraTakenFrom = cameraOn;
ALIVE_cameraTakenFromView = cameraView;

switch(_type) do {
    case "FIRST_PERSON": {      _target switchCamera "INTERNAL"; };
    case "OPTICS": {            _target switchCamera "GUNNER";   };
    case "THIRD_PERSON": {      _target switchCamera "EXTERNAL"; };
    case "FIRST_PERSON_REAL": { _target switchCamera "VIEW";     };
};