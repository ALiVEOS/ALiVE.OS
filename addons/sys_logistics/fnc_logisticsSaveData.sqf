#include "\x\alive\addons\sys_logistics\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if (MOD(SYS_LOGISTICS) getvariable ["DISABLEPERSISTENCE", false] || MOD(SYS_LOGISTICS) getvariable ["DISABLELOG",false]) exitWith {[false, []]};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS LOGISTICS - Saving Data", "logisticsper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = ([""] call ALiVE_fnc_storeKeys) select 0; // group, mission and map

_data = [MOD(SYS_LOGISTICS),"state"] call ALiVE_fnc_logistics;

if (count (_data select 1) == 0) exitwith {
    //[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
};

// Unchanged since this session's last save, and still in the local save: kept as it is. Rebuilding and
// storing every item again held a large mission's server for about 0.4 s on each autosave. Compared as
// text: every item is a hash whose empty default never counts as equal to itself, even in a true copy.
private _dataText = str _data;
if (
    (missionNamespace getVariable ["ALiVE_SYS_DATA_SOURCE", ""]) == "pns"
    && {(missionNamespace getVariable [QGVAR(SAVED), []]) isEqualTo [_missionName, _dataText]}
    && {
        private _store = missionProfileNamespace getVariable [_missionName, profileNamespace getVariable [_missionName, []]];
        [_store] call ALiVE_fnc_isHash && {!isNil {[_store, "sys_logistics"] call ALiVE_fnc_hashGet}}
    }
) exitWith {
    [true, [format ["ALiVE Player Logistics - %1 logistics items unchanged since the last save, kept as saved", count (_data select 1)]]]
};

_result = [false,[]];

_message = format["ALiVE Player Logistics - Preparing to save %1 logistics items..",count(_data select 1)];
_messages = _result select 1;
_messages pushback _message;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["SAVE SYS LOGISTICS DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALiVE_fnc_dump;
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
// what this save stored, so the next one can tell whether anything changed
GVAR(SAVED) = [_missionName, _dataText];


_message = format["ALiVE Player Logistics - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages pushback _message;


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE SYS LOGISTICS - Save data complete","logisticsper"] call ALIVE_fnc_timer;
    ["SYS LOGISTICS SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_dump;
};

_result
