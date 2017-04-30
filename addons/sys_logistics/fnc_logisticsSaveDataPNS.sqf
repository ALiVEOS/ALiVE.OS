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

if !(isServer) exitwith {false};

if (MOD(SYS_LOGISTICS) getvariable ["DISABLEPERSISTENCE", false] || {MOD(SYS_LOGISTICS) getvariable ["DISABLELOG",false]}) exitWith {false};

[true, "ALiVE SYS LOGISTICS - Saving Data", "logisticsper"] call ALIVE_fnc_timer;

_missionName = missionName;

_data = [MOD(SYS_LOGISTICS),"state"] call ALiVE_fnc_logistics;

if (count (_data select 1) == 0) exitwith {false};

_result = [false,[]];

_message = format["ALiVE Player Logistics - Preparing to save %1 logistics items..",count(_data select 1)];
_messages = _result select 1;
_messages pushback _message;

["ALiVE SAVE SYS LOGISTICS DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;

_data = [MOD(SYS_LOGISTICS),"convertData",_data] call ALiVE_fnc_logistics;
_saveResult = [QMOD(SYS_LOGISTICS),_data] call ALiVE_fnc_profileNameSpaceSave;

_result set [0,_saveResult];

_message = format["ALiVE Player Logistics - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages pushback _message;

[false, "ALiVE SYS LOGISTICS - Save data complete","logisticsper"] call ALIVE_fnc_timer;
["ALiVE SYS LOGISTICS SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;

_result