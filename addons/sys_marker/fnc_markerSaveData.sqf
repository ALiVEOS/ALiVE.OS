#include <\x\alive\addons\sys_marker\script_component.hpp>
SCRIPT(markerSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerSaveData

Description:
Triggers Saving Data on for SYS marker, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger marker save to DB
call ALIVE_fnc_markerSaveData;
(end)

See Also:
ALIVE_fnc_markerSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS MARKER - Save Data", "markerper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

_data = [MOD(SYS_marker),"state"] call ALiVE_fnc_marker;

if (count (_data select 1) == 0) exitwith {
    //[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
};

_result = [false,[]];

_message = format["ALiVE Markers - Preparing to save %1 markers..",count(_data select 1)];
_messages = _result select 1;
_messages set [count _messages,_message];


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SAVE SYS MARKER DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
    _data call ALIVE_fnc_inspectHash;
};


if (isNil QGVAR(DATAHANDLER)) then {
    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SAVE SYS marker, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_saveResult = [GVAR(DATAHANDLER), "bulkSave", ["sys_marker", _data, _missionName, _async]] call ALIVE_fnc_Data;
_result set [0,_saveResult];


_message = format["ALiVE Markers - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages set [count _messages,_message];



if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE SYS MARKER - Save data complete","markerper"] call ALIVE_fnc_timer;
    ["ALiVE SYS MARKER SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;
};

_result