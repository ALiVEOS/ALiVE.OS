#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(spawnDebugMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_spawnDebugMarker

Description:
Spawn a debug object

Parameters:
None

Returns:
Vehicle

Examples:
(begin example)
// create debug marker
_marker = [getPos Player] call ALIVE_fnc_spawnDebugMarker;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_indicators","_position","_type","_err","_class","_result"];

_indicators = ["Sign_Pointer_Green_F", "Sign_Pointer_Blue_F", "Sign_Pointer_Pink_F", "Sign_Pointer_Yellow_F", "Sign_Pointer_Cyan_F"];

_position = _this select 0;
_type = if(count _this > 1) then {_this select 1} else {0};

_err = format["spawn debug marker position not valid - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);

_class = _indicators select _type;
_result = _class createVehicle _position;
_result setPos _position;

_result