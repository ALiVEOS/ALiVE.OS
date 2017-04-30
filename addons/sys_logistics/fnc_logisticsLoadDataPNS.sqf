#include <\x\alive\addons\sys_logistics\script_component.hpp>
SCRIPT(logisticsLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_logisticsLoadData

Description:
Triggers Loading Data on all running SYS LOGISTICS instances, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger SYS LOGISTICS load from DB
call ALIVE_fnc_logisticsLoadData;
(end)

See Also:
ALIVE_fnc_logisticsSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isServer) exitwith {false};

[true, "ALiVE SYS LOGISTICS persistence load data started", "logisticsper"] call ALIVE_fnc_timer;

private _data = QMOD(SYS_LOGISTICS) call ALiVE_fnc_profileNameSpaceLoad;

if (typeName _data == "BOOL") exitwith {_data};

_data = [MOD(SYS_LOGISTICS),"convertData",_data] call ALiVE_fnc_logistics;

[false, "ALiVE SYS LOGISTICS persistence load data complete", "logisticsper"] call ALIVE_fnc_timer;

_data