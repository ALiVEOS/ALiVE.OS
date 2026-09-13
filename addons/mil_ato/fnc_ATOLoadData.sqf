#include "\x\alive\addons\mil_ato\script_component.hpp"
SCRIPT(ATOLoadData);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_ATOLoadData

Description:
Read the air commanders' campaign state out of the store.

A plain read, and nothing else. Each commander loads its own records itself as
it starts up, under its own key, so nothing here decides what to do with what
comes back. The name and the answer are kept because they are public: the
answer is the stored hash, or false when there is nothing to read.

An instance key may be passed to read one commander's own store. With no
argument it reads the one shared entry the old module wrote for every
commander together, which is what a mission saved before the rewrite has.

Parameters:
String (optional) - the instance key to read; omitted for the old shared entry

Returns:
Array or Boolean - the stored hash, or false

Examples:
(begin example)
_data = [] call ALIVE_fnc_ATOLoadData;
_mine = ["OPF_F_0"] call ALIVE_fnc_ATOLoadData;
(end)

See Also:
ALIVE_fnc_ATOSaveData
ALIVE_fnc_ATOKernel

Author:
ARJay, Jman
---------------------------------------------------------------------------- */

if !(isServer) exitWith { false };
if (isNil "ALIVE_sys_data" || {isNil "ALIVE_sys_data_DISABLED"} || {ALIVE_sys_data_DISABLED}) exitWith { false };

private _key = "";
if (!isNil "_this") then {
    if (_this isEqualType "") then { _key = _this };
    if (_this isEqualType [] && {count _this > 0} && {(_this select 0) isEqualType ""}) then { _key = _this select 0 };
};

private _mission = [missionName, "%20", "-"] call CBA_fnc_replace;
private _group = missionNamespace getVariable ["ALIVE_sys_data_GROUP_ID", ""];
private _store = if (_key isEqualTo "") then {
    format ["%1_%2_ATO", _group, _mission]
} else {
    format ["%1_%2_ATO_%3", _group, _mission, _key]
};

if (isNil QGVAR(DATAHANDLER)) then {
    GVAR(DATAHANDLER) = [nil, "create"] call ALIVE_fnc_Data;
    [GVAR(DATAHANDLER), "storeType", true] call ALIVE_fnc_Data;
};

private _data = [GVAR(DATAHANDLER), "bulkLoad", ["mil_ato", _store, false]] call ALIVE_fnc_Data;

if (!isNil "ALiVE_SYS_DATA_DEBUG_ON" && {ALiVE_SYS_DATA_DEBUG_ON}) then {
    ["ALIVE_fnc_ATOLoadData - %1: %2", _store,
        if (_data isEqualType []) then { "read" } else { "nothing stored" }] call ALiVE_fnc_dump;
};

_data
