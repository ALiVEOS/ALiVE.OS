#include "\x\alive\addons\sys_marker\script_component.hpp"
SCRIPT(IEDSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_IEDSaveData

Description:
Triggers Saving Data on all IED instances
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
call ALIVE_fnc_IEDSaveData;
(end)

See Also:
ALIVE_fnc_IEDLoadData

Author:
Trapw0w
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if !(ALiVE_MIL_IED getVariable["persistence",false]) exitWith {["ALIVE IED - Persistence not enabled.. exiting"] call ALiVE_fnc_dump};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE IED - Save Data", "iedper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

_data = [MOD(MIL_IED),"state"] call ALiVE_fnc_IED;

if (count (_data select 1) == 0) exitwith {
    ["ALiVE SAVE IED DATA HAS NO ENTRIES: %1! DO NOT SAVE...",_data] call ALIVE_fnc_dump;
};

_result = [false,[]];

_message = format["ALiVE IED - Preparing to save %1 IEDs..",count(_data select 1)];
_messages = _result select 1;
_messages pushback _message;


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SAVE IED DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
    _data call ALIVE_fnc_inspectHash;
};


if (isNil QGVAR(DATAHANDLER)) then {
    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SAVE ALiVE IED, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_saveResult = [GVAR(DATAHANDLER), "bulkSave", ["mil_ied", _data, _missionName, _async]] call ALIVE_fnc_Data;
_result set [0,_saveResult];


_message = format["ALiVE IED - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages pushback _message;



if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE IED - Save data complete","iedper"] call ALIVE_fnc_timer;
    ["ALiVE IED SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;
};

_result