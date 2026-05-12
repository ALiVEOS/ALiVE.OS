#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerIsCompiledFaction);

params [
    ["_factionId", ""]
];

if !(_factionId isEqualType "") exitWith {false};
if (_factionId isEqualTo "") exitWith {false};

private _factionData = [_factionId] call ALIVE_fnc_factionCompilerGetFactionData;
!(isNil "_factionData")

