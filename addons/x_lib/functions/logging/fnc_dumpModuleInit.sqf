#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(dumpModuleInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpModuleInit

Description:
Dumps logo to RPT

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable 
[_logic] call ALIVE_fnc_dumpModuleInit;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_logic","_start","_moduleID","_message"];

_logic = _this select 0;
_start = if(count _this > 1) then {_this select 1} else {false};
_moduleID = if(count _this > 2) then {_this select 2} else {""};

if(isNil "ALIVE_firstModuleInit") then {

    ALiVE_SYS_DATA_DEBUG_ON = false;

    ALIVE_firstModuleInit = true;
    ALIVE_moduleCount = 0;
    [] call ALIVE_fnc_dumpLogo;
    ["ALiVE Global INIT"] call ALIVE_fnc_dump;
    [true,"ALiVE Global Init Timer Started","INIT"] call ALIVE_fnc_timer;
};

if(_start) then {
    _moduleID = format["m_%1", ALIVE_moduleCount];
    _message = format["ALiVE [%3|%1] Module %2 INIT",(getNumber(configfile >> "CfgVehicles" >>  typeOf _logic >> "functionPriority")), typeof _logic, _moduleID];
    [true, _message, _moduleID] call ALIVE_fnc_timer;
    ALIVE_moduleCount = ALIVE_moduleCount + 1;
}else{
    _message = format["ALiVE [%3|%1] Module %2 INIT COMPLETE TIME: ",(getNumber(configfile >> "CfgVehicles" >>  typeOf _logic >> "functionPriority")), typeof _logic, _moduleID];
    [false, _message, _moduleID] call ALIVE_fnc_timer;
};

_moduleID