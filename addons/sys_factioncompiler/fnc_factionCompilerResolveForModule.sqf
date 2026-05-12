#include "\x\alive\addons\sys_factioncompiler\script_component.hpp"
SCRIPT(factionCompilerResolveForModule);

params [
    ["_logic", objNull, [objNull]]
];

if (isNull _logic) exitWith {""};

private _result = "";
private _compilerModules = (synchronizedObjects _logic) select {(typeOf _x) isEqualTo "ALiVE_sys_factioncompiler"};

if (count _compilerModules > 1) exitWith {
    private _moduleDescriptions = _compilerModules apply {
        private _displayName = _x getVariable ["displayName", _x getVariable ["compiledFactionDisplayName", ""]];
        private _compiledFactionId = _x getVariable ["compiledFactionId", ""];
        private _configuredFactionId = _x getVariable ["factionId", ""];
        private _label = if (_displayName isEqualTo "") then {_configuredFactionId} else {_displayName};

        if (_compiledFactionId isEqualTo "") then {
            if (_configuredFactionId isEqualTo "") then {
                _label
            } else {
                format ["%1 [%2]", _label, _configuredFactionId]
            };
        } else {
            format ["%1 [%2]", _label, _compiledFactionId]
        };
    };

    ["Warning placement module %1 has multiple synced faction compiler modules (%2). Only one compiler sync is supported.", typeOf _logic, _moduleDescriptions joinString ", "] call ALIVE_fnc_dump;
    ""
};

{
    if (_result isEqualTo "") then {
        private _compiledFaction = _x getVariable ["compiledFactionId", ""];
        private _compilerError = _x getVariable ["compiledFactionError", ""];

        if (_compiledFaction isEqualTo "" && {_compilerError isEqualTo ""}) then {
            _compiledFaction = _x getVariable ["factionId", ""];
        };

        if !(_compiledFaction isEqualTo "") then {
            if ([_compiledFaction] call ALIVE_fnc_factionCompilerIsCompiledFaction) then {
                _result = _compiledFaction;
            };
        };
    };
} forEach _compilerModules;

_result
