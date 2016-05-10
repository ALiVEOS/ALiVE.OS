#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(logger);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_logger

Description:
Message logger for ALiVE.

Output timestamped messages to RPT.

Parameters:
String - Message to log

Examples:
(begin example)
"Initialisation Completed" call ALiVE_fnc_logger;
(end)

See Also:
- <ALiVE_fnc_initialising>

Author:
Wolffy.au
---------------------------------------------------------------------------- */

private["_text","_message"];
PARAMS_1(_text);
_message = format["ALiVE-%1 %2", time, _text];
diag_log text _message;

