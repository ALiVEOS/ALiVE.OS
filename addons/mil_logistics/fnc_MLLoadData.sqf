#include <\x\alive\addons\mil_logistics\script_component.hpp>
SCRIPT(MLLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_MLLoadData

Description:
Load mil logistics persistence state via sys_data

Parameters:

Returns:

Examples:
(begin example)
// save logistics data
_result = call ALIVE_fnc_MLLoadData;
(end)

See Also:
ALIVE_fnc_MLSaveData

Author:
ARJay
---------------------------------------------------------------------------- */

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_result","_data","_async","_missionName"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE ML persistence load data started", "mlper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2_FORCE_POOL", ALIVE_sys_data_GROUP_ID, _missionName];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ML DATAHANDLER: %1",QGVAR(DATAHANDLER)] call ALIVE_fnc_dump;
};

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD ML, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_data = [GVAR(DATAHANDLER), "read", ["mil_logistics", [], _missionName]] call ALIVE_fnc_Data;

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        [false, "ALiVE ML persistence load data complete", "mlper"] call ALIVE_fnc_timer;
    };

    _data
};

_data