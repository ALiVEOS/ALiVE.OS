#include <\x\alive\addons\sys_sitrep\script_component.hpp>
SCRIPT(sitrepSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_sitrepSaveData

Description:
Triggers Saving Data on for SYS sitrep, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger sitrep save to DB
call ALIVE_fnc_sitrepSaveData;
(end)

See Also:
ALIVE_fnc_sitrepSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS SITREP - Saving data", "sitrepper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

_data = [MOD(SYS_sitrep),"state"] call ALiVE_fnc_sitrep;

if (count (_data select 1) == 0) exitwith {
    //[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
};

_result = [false,[]];

_message = format["ALiVE SITREP - Preparing to save %1 reports..",count(_data select 1)];
_messages = _result select 1;
_messages set [count _messages,_message];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SAVE SYS SITREP DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
    _data call ALIVE_fnc_inspectHash;
};

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SAVE SYS SITREP, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_saveResult = [GVAR(DATAHANDLER), "bulkSave", ["sys_sitrep", _data, _missionName, _async]] call ALIVE_fnc_Data;
_result set [0,_saveResult];


_message = format["ALiVE SITREP - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages set [count _messages,_message];


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE SYS SITREP - Save data complete","sitrepper"] call ALIVE_fnc_timer;
    ["ALiVE SYS SITREP SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;
};


_result