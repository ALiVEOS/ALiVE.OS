#include "\x\alive\addons\sys_sitrep\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS SITREP - Saving data", "sitrepper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = ([""] call ALiVE_fnc_storeKeys) select 0; // group, mission and map

_data = [MOD(SYS_sitrep),"state"] call ALiVE_fnc_sitrep;

// An empty store is a result worth saving, not a reason to skip saving. This
// used to bail out, so deleting your last report wrote nothing and the report
// came back on the next load. (#1045)

_result = [false,[]];

_message = format["ALiVE SITREP - Preparing to save %1 reports..",count(_data select 1)];
_messages = _result select 1;
_messages pushback _message;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["SAVE SYS SITREP DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALiVE_fnc_dump;
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
_messages pushback _message;


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE SYS SITREP - Save data complete","sitrepper"] call ALIVE_fnc_timer;
    ["SYS SITREP SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_dump;
};


_result
