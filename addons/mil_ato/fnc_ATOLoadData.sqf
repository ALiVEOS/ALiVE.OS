#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATOLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOLoadData

Description:
Load mil air tasking orders persistence state via sys_data

Parameters:

Returns:

Examples:
(begin example)
// load air tasking orders data
_result = call ALIVE_fnc_ATOLoadData;
(end)

See Also:
ALIVE_fnc_ATOSaveData

Author:
ARJay
---------------------------------------------------------------------------- */

if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_result","_data","_async","_missionName"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE ATO persistence load data started", "atoper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2_ATO", ALIVE_sys_data_GROUP_ID, _missionName];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ATO DATAHANDLER: %1",QGVAR(DATAHANDLER)] call ALIVE_fnc_dump;
};

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD ATO, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_data = [GVAR(DATAHANDLER), "bulkLoad", ["mil_ato", _missionName, _async]] call ALIVE_fnc_Data;

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        [false, "ALiVE ATO persistence load data complete", "atoper"] call ALIVE_fnc_timer;
    };

    _data
};

if (typeName _data != "ARRAY" && ALiVE_SYS_DATA_DEBUG_ON) then {
   ["No ATO data loaded, either no data stored or data load failed."] call ALIVE_fnc_dump;
};

_data