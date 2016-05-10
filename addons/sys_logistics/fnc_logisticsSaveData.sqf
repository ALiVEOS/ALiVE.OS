#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(logisticsSaveSata);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_logisticsSaveSata

Description:
Triggers Saving Data on for SYS LOGISTICS, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger logistics save to DB
call ALIVE_fnc_logisticsSaveSata;
(end)

See Also:
ALIVE_fnc_logisticsSaveSata

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if (MOD(SYS_LOGISTICS) getvariable ["DISABLEPERSISTENCE", false] || MOD(SYS_LOGISTICS) getvariable ["DISABLELOG",false]) exitWith {false};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS LOGISTICS - Saving Data", "logisticsper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

_data = [MOD(SYS_LOGISTICS),"state"] call ALiVE_fnc_logistics;

if (count (_data select 1) == 0) exitwith {
    //[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
};

_result = [false,[]];

_message = format["ALiVE Player Logistics - Preparing to save %1 logistics items..",count(_data select 1)];
_messages = _result select 1;
_messages set [count _messages,_message];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SAVE SYS LOGISTICS DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
};

_data = [MOD(SYS_LOGISTICS),"convertData",_data] call ALiVE_fnc_logistics;

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SAVE SYS LOGISTICS, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_saveResult = [GVAR(DATAHANDLER), "bulkSave", ["sys_logistics", _data, _missionName, _async]] call ALIVE_fnc_Data;
_result set [0,_saveResult];


_message = format["ALiVE Player Logistics - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages set [count _messages,_message];


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE SYS LOGISTICS - Save data complete","logisticsper"] call ALIVE_fnc_timer;
    ["ALiVE SYS LOGISTICS SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;
};

_result