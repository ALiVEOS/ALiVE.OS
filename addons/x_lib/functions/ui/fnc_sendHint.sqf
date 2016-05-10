/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sendHint

Description:
Displays a hint on screen

Parameters:
String - The module sending the hint (used for a title)
String - The message to be sent

Returns:
Nothing

Examples:
(begin example)
	[ _module, _msg] call ALIVE_fnc_sendHint;
(end)

Author:
Tupolov

Peer Reviewed:

---------------------------------------------------------------------------- */

#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(sendHint);

private ["_module","_message","_logText"];

// Send hint to player
_module = _this select 0;
_message = _this select 1;

_logText = "<br/><img size='7' image='\x\alive\addons\UI\logo_alive_crop.paa' /><br/><br/><t color='#ffff00' size='1.0' shadow='1' shadowColor='#000000' align='center'>" + _module + "</t><br/><br/><t align='left'>" + _message + "</t><br/><br/>";
hint parseText (_logText);