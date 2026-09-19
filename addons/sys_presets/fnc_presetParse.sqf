#include "script_component.hpp"
SCRIPT(presetParse);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetParse

Description:
Reads a preset somebody else wrote and decides whether it can be trusted enough
to place.

A preset arrives as text from a stranger, so it is read with parseSimpleArray,
which returns data and cannot run what it reads. That stops anything executing,
but it does not stop nonsense: a setting that belongs to another module, a module
class this game has never heard of, a link pointing at nothing, or a setting this
build refuses to carry. Each of those is checked here against the live config, so
placing a preset later is a matter of doing what it says rather than hoping.

Every problem found is reported in plain words. A preset is either wholly good or
not placed: half a preset would leave a scenario looking configured while doing
something nobody asked for.

Parameters:
    _text - STRING - the preset as one line, from the clipboard or anywhere else

Returns:
    ARRAY [_ok, _preset, _problems]
      _ok       - BOOL, whether it can be placed
      _preset   - the preset array, or [] when it cannot
      _problems - ARRAY of STRING, in the order they were found

Examples:
    (begin example)
    ([copyFromClipboard] call ALIVE_fnc_presetParse) params ["_ok", "_preset", "_problems"];
    (end)

See Also:
    ALIVE_fnc_presetPlace, ALIVE_fnc_presetLoad, ALIVE_fnc_presetSerialize

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_text", "", [""]]];

private _no = { [false, [], _this] };

if (_text isEqualTo "") exitWith { ["There is nothing on the clipboard."] call _no };

private _preset = parseSimpleArray _text;
if (count _preset != 7) exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};

_preset params ["_magic", "_version", "_meta", "_modules", "_links", "_mods", "_dropped"];

if !(_magic isEqualTo "ALIVEPRESET") exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};
if !(_version isEqualType 0) exitWith { ["This preset does not say which version it is."] call _no };
if (_version > 1) exitWith {
    [format ["This preset was written for a newer ALiVE (it says version %1, this build reads 1). Update ALiVE.", _version]] call _no
};
if (!(_modules isEqualType []) || {!(_links isEqualType [])} || {!(_meta isEqualType [])}) exitWith {
    ["This preset is damaged. It may have been cut short when it was copied."] call _no
};
if (count _modules == 0) exitWith { ["This preset has no modules in it."] call _no };

private _skip = getArray (configFile >> "CfgALiVEPresets" >> "skipAttributes");
private _problems = [];

{
    private _entry = _x;
    private _at = _forEachIndex + 1;
    if (!(_entry isEqualType []) || {count _entry != 2}) then {
        _problems pushBack format ["Module %1 in this preset is damaged.", _at];
    } else {
        _entry params ["_class", "_settings"];
        if (!(_class isEqualType "") || {!(_settings isEqualType [])}) then {
            _problems pushBack format ["Module %1 in this preset is damaged.", _at];
        } else {
            private _cfg = configFile >> "CfgVehicles" >> _class;
            if (!isClass _cfg) then {
                _problems pushBack format ["This game does not have the module %1. It may come from a mod you are not running.", _class];
            } else {
                if !(_class isKindOf "ModuleAliveBase") then {
                    _problems pushBack format ["%1 is not an ALiVE module.", _class];
                } else {
                    // Which settings this module actually has, by the name a preset
                    // uses for them, and what each one is called in config so the
                    // never-carried list can be applied. Two lists rather than a
                    // hash: this runs in the editor, where the fewer ALiVE parts
                    // it leans on the better.
                    private _props = [];
                    private _names = [];
                    private _attrs = _cfg >> "Attributes";
                    for "_i" from 0 to (count _attrs) - 1 do {
                        private _a = _attrs select _i;
                        if (isClass _a) then {
                            private _p = getText (_a >> "property");
                            if !(_p isEqualTo "") then {
                                _props pushBack _p;
                                _names pushBack (configName _a);
                            };
                        };
                    };

                    {
                        if (!(_x isEqualType []) || {count _x != 2} || {!((_x select 0) isEqualType "")}) then {
                            _problems pushBack format ["A setting on %1 is damaged.", _class];
                        } else {
                            _x params ["_prop", "_value"];
                            private _at = _props find _prop;
                            private _name = if (_at < 0) then { "" } else { _names select _at };
                            if (_at < 0) then {
                                _problems pushBack format ["%1 has no setting called %2 in this build of ALiVE.", _class, _prop];
                            } else {
                                if (_name in _skip) then {
                                    _problems pushBack format ["This preset carries %1, which ALiVE never shares.", _prop];
                                } else {
                                    if (!(_value isEqualType "") && {!(_value isEqualType 0)} && {!(_value isEqualType true)}) then {
                                        _problems pushBack format ["The value of %1 is not something a setting can hold.", _prop];
                                    };
                                };
                            };
                        };
                    } forEach _settings;
                };
            };
        };
    };
} forEach _modules;

{
    if (!(_x isEqualType []) || {count _x != 2} || {!((_x select 0) isEqualType 0)} || {!((_x select 1) isEqualType 0)}) then {
        _problems pushBack "A sync line in this preset is damaged.";
    } else {
        _x params ["_a", "_b"];
        if (_a < 0 || {_b < 0} || {_a >= count _modules} || {_b >= count _modules} || {_a isEqualTo _b}) then {
            _problems pushBack "A sync line in this preset points at a module that is not in it.";
        };
    };
} forEach _links;

if (count _problems > 0) exitWith { [false, [], _problems] };

[true, _preset, []]
