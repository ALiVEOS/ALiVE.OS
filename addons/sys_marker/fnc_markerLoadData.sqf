#include <\x\alive\addons\sys_marker\script_component.hpp>
SCRIPT(markerLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_markerLoadData

Description:
Triggers Loading Data on all running SYS marker instances, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger SYS marker load from DB
call ALIVE_fnc_markerLoadData;
(end)

See Also:
ALIVE_fnc_markerSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

private ["_data"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE SYS marker persistence load data started", "markerper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD SYS marker, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_data = [GVAR(DATAHANDLER), "bulkLoad", ["sys_marker", _missionName, _async]] call ALIVE_fnc_Data;

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        [false, "ALiVE SYS marker persistence load data complete", "markerper"] call ALIVE_fnc_timer;
    };

    _data
};

_data