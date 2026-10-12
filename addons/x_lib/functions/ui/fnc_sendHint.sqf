/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sendHint

Description:
Displays a hint on screen: the ALiVE logo, the module's name as a yellow title, then the
message. Every message a module shows a player goes through here, so players can tell at a
glance it is ALiVE talking and which part of it.

The message is structured text: <br/> breaks a line, and so does \n, so a message written for
a plain hint shows the same here. The title is shown as plain text, so a player's name can be
used as one.

Parameters:
String - The module sending the hint (used for a title)
String - The message to be sent
Bool - (optional) true to show it without the hint sound, for a readout that changes often

Returns:
Nothing

Examples:
(begin example)
    [ _module, _msg] call ALIVE_fnc_sendHint;
    [localize "STR_ALIVE_MARKER", "Free Draw Mode", true] call ALIVE_fnc_sendHint;
(end)

Author:
Tupolov
Jman

Peer Reviewed:

---------------------------------------------------------------------------- */

#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(sendHint);

params [["_module", "", [""]], ["_message", "", [""]], ["_silent", false, [false]]];

_module = ((_module regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"];
_message = (_message regexReplace ["\\n", "<br/>"]) regexReplace [toString [10], "<br/>"];

private _logText = "<br/><img size='7' image='\x\alive\addons\UI\logo_alive_crop.paa' /><br/><br/><t color='#ffff00' size='1.0' shadow='1' shadowColor='#000000' align='center'>" + _module + "</t><br/><br/><t align='left'>" + _message + "</t><br/><br/>";
if (_silent) then { hintSilent parseText _logText } else { hint parseText _logText };
