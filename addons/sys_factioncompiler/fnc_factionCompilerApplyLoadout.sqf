#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerApplyLoadout);

params [
    ["_unit", objNull, [objNull]],
    ["_factionId", "", [""]],
    ["_groupId", "", [""]]
];

if (isNull _unit || {_factionId isEqualTo ""} || {_groupId isEqualTo ""}) exitWith {false};

private _factionData = [_factionId] call ALIVE_fnc_factionCompilerGetFactionData;
if (isNil "_factionData") exitWith {false};

private _compiledGroups = [_factionData, "compiledGroups"] call ALIVE_fnc_hashGet;
private _groupData = [_compiledGroups, _groupId] call ALIVE_fnc_hashGet;
if (isNil "_groupData") exitWith {false};

private _units = [_groupData, "units", []] call ALIVE_fnc_hashGet;
private _unitIndex = _unit getVariable ["profileIndex", -1];
if (_unitIndex < 0 || {_unitIndex >= count _units}) exitWith {false};

private _unitData = _units select _unitIndex;
private _loadout = [_unitData, "loadout", []] call ALIVE_fnc_hashGet;
if (_loadout isEqualTo []) exitWith {false};

_unit setUnitLoadout _loadout;
true

