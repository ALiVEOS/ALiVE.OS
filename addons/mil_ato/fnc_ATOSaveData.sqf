#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATOSaveData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOSaveData

Description:
Save mil air tasking orders persistence state via sys_data

Parameters:

Returns:
Boolean

Examples:
(begin example)
// save air tasking orders data
_result = call ALIVE_fnc_ATOSaveData;
(end)

See Also:
ALIVE_fnc_ATOLoadData

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_result","_data","_async","_missionName","_message","_messages","_saveResult"];

if !(isServer && {!(isNil "ALIVE_sys_data")} && {!(ALIVE_sys_data_DISABLED)}) exitwith {false};

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [true, "ALiVE MIL air tasking orders - Saving data", "atoper"] call ALIVE_fnc_timer;
};

_async = false;
_missionName = [missionName, "%20","-"] call CBA_fnc_replace;
_missionName = format["%1_%2_ATO", ALIVE_sys_data_GROUP_ID, _missionName];

_data = ALIVE_globalATO;

private _isPersistent = false;

{
    private _opcom = _x;
    private _module = [_opcom, "module"] call CBA_fnc_hashGet;

    {
        private _object = _x;

        if (_object isKindOf "alive_mil_ato") then {
            private _persistent = [_object, "persistent"] call ALiVE_fnc_ATO;

            if (_persistent) exitWith {
                _isPersistent = true;
            };
        };
    } forEach (synchronizedObjects _module);

    if (_isPersistent) exitWith {};
} forEach OPCOM_instances;

if (!_isPersistent || count (_data select 1) == 0) exitwith {
    //[["ALiVE_LOADINGSCREEN"],"BIS_fnc_endLoadingScreen",true,false] call BIS_fnc_MP;
    _result = [false,[]];
};

_result = [false,[]];

_message = format["ALiVE Military air tasking orders - Preparing to save ATO data for %1 factions ..",count(_data select 1)];
_messages = _result select 1;
_messages set [count _messages,_message];

if(ALiVE_SYS_DATA_DEBUG_ON) then {
    ["ALiVE SAVE MIL air tasking orders DATA NOW - MISSION NAME: %1! PLEASE WAIT...",_missionName] call ALIVE_fnc_dump;
    _data call ALIVE_fnc_inspectHash;
};


if (isNil QGVAR(DATAHANDLER)) then {

    if(ALiVE_SYS_DATA_DEBUG_ON) then {
        ["SAVE MIL air tasking orders, CREATE DATA HANDLER!"] call ALIVE_fnc_dump;
    };

    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER),"storeType",true] call ALIVE_fnc_Data;
};

_saveResult = [GVAR(DATAHANDLER), "bulkSave", ["mil_ato", _data, _missionName, _async]] call ALIVE_fnc_Data;
_result set [0,_saveResult];

_message = format["ALiVE Military air tasking orders - Save Result: %1",_saveResult];
_messages = _result select 1;
_messages set [count _messages,_message];


if(ALiVE_SYS_DATA_DEBUG_ON) then {
    [false, "ALiVE MIL air tasking orders - Save data complete","atoper"] call ALIVE_fnc_timer;
    ["ALiVE MIL air tasking orders SAVE DATA RESULT: %1",_saveResult] call ALiVE_fnc_Dump;
};

_result