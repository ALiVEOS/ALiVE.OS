#include <\x\alive\addons\mil_C2ISTAR\script_component.hpp>
SCRIPT(taskHandlerLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskHandlerLoadData

Description:
Load task persistence state via sys_data

Parameters:

Returns:

Examples:
(begin example)
// save logistics data
_result = call ALIVE_fnc_taskHandlerLoadData;
(end)

See Also:
ALIVE_fnc_taskHandlerSaveData

Author:
ARJay
---------------------------------------------------------------------------- */

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_result","_data","_async","_missionName"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE Task Handler persistence load data started", "taskHandlerper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2_TASK", ALIVE_sys_data_GROUP_ID, _missionName];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["Task Handler DATAHANDLER: %1",QGVAR(DATAHANDLER)] call ALIVE_fnc_dump;
};

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD Task Handler, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_data = [GVAR(DATAHANDLER), "bulkLoad", ["sys_tasks", _missionName, _async]] call ALIVE_fnc_Data;

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {
    [false, "ALiVE Task Handler persistence load data complete", "taskHandlerper"] call ALIVE_fnc_timer;
    _data
};

_data