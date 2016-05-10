#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(debugHandler);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_debugHandler

Description:
Toggles debug mode on modules

Parameters:
String Module type

Returns:

Examples:
(begin example)
// turn on debug for profile system
["profiles"] call ALIVE_fnc_debugHandler;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */
private ["_type"];
	
_type = _this select 0;

switch(_type) do {
    case "profiles": {
        if(!isNil 'ALIVE_profileHandler') then {
            if([ALIVE_profileHandler, "debug"] call ALIVE_fnc_profileHandler) then {
                [ALIVE_profileHandler, "debug", false] call ALIVE_fnc_profileHandler;
            }else{
                [ALIVE_profileHandler, "debug", true] call ALIVE_fnc_profileHandler;
            };
        };
    };
    case "agents": {
        if(!isNil 'ALIVE_agentHandler') then {
            if([ALIVE_agentHandler, "debug"] call ALIVE_fnc_agentHandler) then {
                [ALIVE_agentHandler, "debug", false] call ALIVE_fnc_agentHandler;
            }else{
                [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler;
            };
        };
    };
};