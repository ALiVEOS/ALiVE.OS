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

// Seven parts, or eight once it carries areas. Anything else is not a preset, or
// is a preset that was cut short on its way here.
private _preset = parseSimpleArray _text;
if (!(count _preset isEqualTo 7) && {!(count _preset isEqualTo 8)}) exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};

_preset params ["_magic", "_version", "_meta", "_modules", "_links", "_mods", "_dropped"];
private _markers = _preset param [7, []];

if !(_magic isEqualTo "ALIVEPRESET") exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};
if !(_version isEqualType 0) exitWith { ["This preset does not say which version it is."] call _no };
if (_version > 2) exitWith {
    [format ["This preset was written for a newer ALiVE (it says version %1, this build reads 2). Update ALiVE.", _version]] call _no
};
if (!(_modules isEqualType []) || {!(_links isEqualType [])} || {!(_meta isEqualType [])}) exitWith {
    ["This preset is damaged. It may have been cut short when it was copied."] call _no
};
if (count _modules == 0) exitWith { ["This preset has no modules in it."] call _no };

private _skip = getArray (configFile >> "CfgALiVEPresets" >> "skipAttributes");
if (count _skip == 0) then { _skip = ["onEachSpawn", "runwaystartpos", "runwayendpos"] };

private _markerSettings = getArray (configFile >> "CfgALiVEPresets" >> "markerAttributes");
if (count _markerSettings == 0) then { _markerSettings = ["taor", "blacklist", "airspace", "ingressMarker"] };

// The names this preset actually brings, to check its settings against. A setting
// naming an area the preset does not carry is the failure this whole check exists
// for: it places without complaint and then behaves as though it were never set.
private _have = [];
{
    if (_x isEqualType [] && {count _x > 0} && {(_x select 0) isEqualType ""}) then {
        _have pushBackUnique (toLower (_x select 0));
    };
} forEach _markers;

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
                                if ((_skip findIf { _x isEqualTo _name }) >= 0) then {
                                    _problems pushBack format ["This preset carries %1, which ALiVE never shares.", _prop];
                                } else {
                                    if ((_markerSettings findIf { _x isEqualTo _name }) >= 0) then {
                                        {
                                            if !((toLower _x) in _have) then {
                                                _problems pushBack format
                                                    ["%1 names the area %2, which this preset does not carry.", _prop, _x];
                                            };
                                        } forEach (["names", [_name, _value]] call ALIVE_fnc_presetMarkers);
                                    };
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

// The areas. Ten columns, each of a type the editor will accept back: a name and
// a class, a shape number, an offset and a size as pairs of numbers, a rotation,
// a brush, a colour, an alpha and a label. The colour is checked for being text
// and nothing more, because it is carried exactly as the editor gave it and the
// editor gives a name like ColorWEST, not the array the wiki describes.
if !(_markers isEqualType []) then {
    _problems pushBack "The areas in this preset are damaged.";
} else {
    {
        private _at = _forEachIndex + 1;
        if (!(_x isEqualType []) || {count _x != 10}) then {
            _problems pushBack format ["Area %1 in this preset is damaged.", _at];
        } else {
            _x params ["_name", "_class", "_shape", "_offset", "_size", "_rotation", "_brush", "_colour", "_alpha", "_label"];
            private _pair = {
                (_this isEqualType []) && {count _this isEqualTo 2}
                    && {(_this select 0) isEqualType 0} && {(_this select 1) isEqualType 0}
            };
            switch (false) do {
                case (_name isEqualType "" && {!(_name isEqualTo "")}): {
                    _problems pushBack format ["Area %1 has no name.", _at];
                };
                case (_class isEqualType "" && {_brush isEqualType ""} && {_colour isEqualType ""} && {_label isEqualType ""}): {
                    _problems pushBack format ["Area %1 has something in it that is not text.", _at];
                };
                case (_shape isEqualType 0 && {_rotation isEqualType 0} && {_alpha isEqualType 0}): {
                    _problems pushBack format ["Area %1 has a shape, angle or fade that is not a number.", _at];
                };
                case (_offset call _pair && {_size call _pair}): {
                    _problems pushBack format ["Area %1 has a position or size that is not a pair of numbers.", _at];
                };
                default {};
            };
        };
    } forEach _markers;
};

if (count _problems > 0) exitWith { [false, [], _problems] };

[true, _preset, []]
