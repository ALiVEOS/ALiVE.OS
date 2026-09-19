#include "script_component.hpp"
SCRIPT(presetCollect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetCollect

Description:
Reads the ALiVE modules in the open editor scenario and builds a preset out of
them: every module, the settings that were actually chosen, and the sync lines
between them.

Every ALiVE module is taken, not a selection. A mission maker sharing a setup
should not have to know that leaving out ALiVE Required or the Virtual AI System
gives the recipient a scenario that quietly does nothing, so the question is not
asked.

Only settings that differ from the module's own default are carried. That keeps a
preset a few hundred characters instead of forty thousand, and it means a default
improved later reaches presets written today. The rest of the module's settings
are not missing from the preset so much as deliberately left to ALiVE.

Two kinds of setting are dropped even when they were chosen, and the caller is
told which, by name:
  - anything naming something that only exists in the mission it came from, such
    as an area marker for a commander's ground, because the name means nothing on
    another map and a silently empty area is worse than an obvious gap.
  - the one setting that holds script rather than data, the per-spawn hook, which
    would make a shared preset a way to run somebody else's code.

Both lists live in config, under CfgALiVEPresets, so the editor side and the
tooling that reviews a submission read the same list rather than two copies.

Parameters:
    None.

Returns:
    ARRAY [_preset, _report]
      _preset - the preset array, ready for ALIVE_fnc_presetSerialize
      _report - [_moduleCount, _settingCount, _linkCount, _dropped, _mods]

Examples:
    (begin example)
    ([] call ALIVE_fnc_presetCollect) params ["_preset", "_report"];
    (end)

See Also:
    ALIVE_fnc_presetSerialize, ALIVE_fnc_presetDefault, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

if (!is3DEN) exitWith {
    ["ALIVE_fnc_presetCollect - only the editor has a scenario to read"] call ALiVE_fnc_dump;
    [[], [0, 0, 0, [], []]]
};

private _skip = getArray (configFile >> "CfgALiVEPresets" >> "skipAttributes");
if (count _skip == 0) then { _skip = ["taor", "blacklist", "airspace", "ingressMarker", "runwaystartpos", "runwayendpos", "onEachSpawn"] };

// Everything the editor holds, whatever list it keeps it in. Asking by list
// index would tie this to an order the engine is free to change; asking each
// thing what it is cannot go stale.
private _modules = [];
{
    if (_x isEqualType []) then {
        {
            if (_x isEqualType objNull && {!isNull _x} && {(typeOf _x) isKindOf "ModuleAliveBase"}) then {
                _modules pushBackUnique _x;
            };
        } forEach _x;
    };
} forEach all3DENEntities;

if (count _modules == 0) exitWith {
    [[], [0, 0, 0, [], []]]
};

// A stable order, so the same scenario always writes the same preset and two
// presets can be compared as text.
_modules = [_modules, [], { get3DENEntityID _x }, "ASCEND"] call BIS_fnc_sortBy;

// Two values mean the same setting when they read the same written out: the
// editor hands back the text "false" for most, and a real true/false for the
// few that declare a type.
private _fnc_same = {
    params ["_a", "_b"];
    private _fnc_text = {
        if (isNil "_this") exitWith { "<nothing>" };
        if (_this isEqualType true) exitWith { if (_this) then { "true" } else { "false" } };
        if (_this isEqualType "") exitWith { _this };
        str _this
    };
    (_a call _fnc_text) isEqualTo (_b call _fnc_text)
};

private _out = [];
private _dropped = [];
private _mods = [];
private _settingCount = 0;

{
    private _entity = _x;
    private _type = typeOf _entity;
    private _attrs = configFile >> "CfgVehicles" >> _type >> "Attributes";
    private _kept = [];

    for "_i" from 0 to (count _attrs) - 1 do {
        private _a = _attrs select _i;
        if (isClass _a) then {
            private _prop = getText (_a >> "property");
            private _name = configName _a;
            // A heading is not a setting: it carries a property so the editor can
            // draw it, and no value at all.
            private _isHeading = (configName (inheritsFrom _a)) isEqualTo "ALiVE_ModuleSubTitle";
            // Neither is the game's own module description, which every module
            // inherits, has no default, and reads as true everywhere. Without
            // this it came out on all four modules of the first preset taken.
            private _isDescription = (_prop isEqualTo "ModuleInfo") || {_name isEqualTo "ModuleDescription"};
            if (!(_prop isEqualTo "") && {!_isHeading} && {!_isDescription}) then {
                private _read = _entity get3DENAttribute _prop;
                if (count _read > 0) then {
                    private _value = _read select 0;
                    ([_a, _entity] call ALIVE_fnc_presetDefault) params ["_known", "_default"];
                    private _chosen = !_known || {!([_value, _default] call _fnc_same)};
                    if (_chosen) then {
                        if (_name in _skip) then {
                            _dropped pushBackUnique _name;
                        } else {
                            // Carried as the editor holds it, so its type survives
                            // and the value goes back in exactly as it came out.
                            _kept pushBack [_prop, _value];
                            _settingCount = _settingCount + 1;
                            // A faction from another mod is worth recording, so a
                            // recipient is told what the preset expects rather than
                            // finding out from an empty battlefield.
                            if (_value isEqualType "") then {
                                {
                                    private _cfg = configFile >> "CfgFactionClasses" >> _x;
                                    if (isClass _cfg) then {
                                        {
                                            private _src = toLower _x;
                                            if (!(_src select [0, 3] isEqualTo "a3_") && {!(_src select [0, 6] isEqualTo "alive_")}) then {
                                                _mods pushBackUnique _src;
                                            };
                                        } forEach (configSourceAddonList _cfg);
                                    };
                                } forEach (_value splitString "[]"",' |");
                            };
                        };
                    };
                };
            };
        };
    };

    _out pushBack [_type, _kept];
} forEach _modules;

// The sync lines, as positions in the list above, so a preset carries no editor
// ids and can be placed anywhere. Each pair once: the editor reports a link from
// both ends.
private _links = [];
{
    private _from = _forEachIndex;
    {
        if ((_x select 0) isEqualTo "Sync") then {
            private _to = _modules find (_x select 1);
            if (_to >= 0 && {_to != _from}) then {
                private _pair = [_from min _to, _from max _to];
                _links pushBackUnique _pair;
            };
        };
    } forEach (get3DENConnections _x);
} forEach _modules;

private _preset = ["ALIVEPRESET", 1,
    ["", "", "", worldName, getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "version"), ""],
    _out, _links, _mods, _dropped];

[_preset, [count _modules, _settingCount, count _links, _dropped, _mods]]
