#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerGetConfigFaction);

params [
    ["_factionId", ""]
];

if !(_factionId isEqualType "") exitWith {_factionId};
if (_factionId isEqualTo "") exitWith {""};
if (isNil "ALIVE_factionCustomMappings") exitWith {_factionId};
if !(_factionId in (ALIVE_factionCustomMappings select 1)) exitWith {_factionId};

private _mapping = [ALIVE_factionCustomMappings, _factionId] call ALIVE_fnc_hashGet;
private _configFaction = [_mapping, "ConfigFactionName", _factionId] call ALIVE_fnc_hashGet;

if (_configFaction isEqualTo "") then {
    _configFaction = [_mapping, "GroupFactionName", _factionId] call ALIVE_fnc_hashGet;
};

_configFaction

