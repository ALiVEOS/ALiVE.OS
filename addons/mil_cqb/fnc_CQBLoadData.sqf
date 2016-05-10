#include <\x\alive\addons\mil_CQB\script_component.hpp>
SCRIPT(CQBLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_CQBLoadData

Description:
Triggers Loading Data on all running CQB instances, triggers and ends Loadingscreen
Needs to run serverside

Parameters:
none

Returns:
Boolean

Examples:
(begin example)
//trigger CQB load from DB
call ALIVE_fnc_CQBLoadData;
(end)

See Also:
ALIVE_fnc_CQBSaveData

Author:
Highhead
---------------------------------------------------------------------------- */

if !(isDedicated && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {};

private ["_data","_instances"];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE CQB persistence load data started", "cqbper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2", ALIVE_sys_data_GROUP_ID, _missionName];

if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["LOAD CQB, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};
_data = [GVAR(DATAHANDLER), "bulkLoad", ["mil_cqb", _missionName, _async]] call ALIVE_fnc_Data;

if (!(isnil "_this") && {typeName _this == "BOOL"} && {!_this}) exitwith {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        [false, "ALiVE CQB persistence load data complete", "cqbper"] call ALIVE_fnc_timer;
    };

    _data
};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    _data call ALIVE_fnc_inspectHash;
};

_instances = (MOD(CQB) getVariable ["instances",[]]);

{[_x,"active",false] call ALiVE_fnc_CQB} foreach _instances;
{
	private ["_state","_logic","_CQB_instance"];
	_logic  = _x;
    
    if (call compile (_logic getvariable ["CQB_persistent","false"])) then {

        if(ALiVE_SYS_DATA_DEBUG_ON) then {
		    ["ALiVE LOAD CQB DATA APPLYING STATE!"] call ALIVE_fnc_dump;
        };

	    {[_logic,"state",_x] call ALiVE_fnc_CQB} foreach (_data select 2);
	
		//([_logic,"state"] call ALiVE_fnc_CQB) call ALIVE_fnc_inspectHash;
    };
} foreach _instances;
{[_x,"active",true] call ALiVE_fnc_CQB} foreach _instances;

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE CQB persistence load data completed and applied","cqbper"] call ALIVE_fnc_timer;
};

_data