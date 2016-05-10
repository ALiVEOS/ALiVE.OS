#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(placeDebugMarker);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_placeDebugMarker

Description:
Place a debug marker

Parameters:
None

Returns:
Vehicle

Examples:
(begin example)
// create debug marker
_marker = [getPos Player] call ALIVE_fnc_placeDebugMarker;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_indicators","_position","_type","_err","_class","_result","_m"];

_indicators = ["waypoint","mil_dot","mil_box","mil_triangle","mil_flag"];
	
_position = _this select 0;
_type = if(count _this > 1) then {_this select 1} else {0};

_err = format["spawn debug marker position not valid - %1",_position];
ASSERT_TRUE(typeName _position == "ARRAY",_err);

_m = createMarker [format["%1_debug",(time + random 10000)], _position];
_m setMarkerShape "ICON";
_m setMarkerSize [.65, .65];
_m setMarkerType (_indicators select _type);
_m setMarkerColor "ColorGreen";
_m setMarkerAlpha 1;