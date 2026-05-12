#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerGetFactionData);

params [
    ["_factionId", ""]
];

if !(_factionId isEqualType "") exitWith {nil};
if (_factionId isEqualTo "") exitWith {nil};
if (isNil "ALIVE_compiledFactions") exitWith {nil};

[ALIVE_compiledFactions, _factionId] call ALIVE_fnc_hashGet

