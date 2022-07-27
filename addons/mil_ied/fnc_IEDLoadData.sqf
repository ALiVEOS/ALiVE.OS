#include "\x\alive\addons\sys_marker\script_component.hpp"
SCRIPT(IEDLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_IEDLoadData

Description:
Triggers Loading Data of all IED instances
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
call ALIVE_fnc_IEDLoadData;
(end)

See Also:
ALIVE_fnc_IEDSaveData

Author:
Trapw0w
---------------------------------------------------------------------------- */
if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_data"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE IED persistence load data started", "iedper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD ALiVE IED, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_data = [GVAR(DATAHANDLER), "bulkLoad", ["mil_ied", _missionName, _async]] call ALIVE_fnc_Data;
if !(typeName _data == "BOOL") then {
    [ADDON, "convertData", _data] call ALiVE_fnc_IED;
};

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        [false, "ALiVE IED persistence load data complete", "iedper"] call ALIVE_fnc_timer;
    };

    _data
};

_data