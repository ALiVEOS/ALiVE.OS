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

// Does it even begin like a preset? Asked BEFORE parseSimpleArray, because that
// command does not politely hand back an empty array when the text is not an
// array: it raises a format error. Whatever is on somebody's clipboard is usually
// not a preset, so this was throwing an error into the log for every ordinary
// thing anyone had copied.
private _trimmed = trim _text;
if !((_trimmed select [0, 13]) isEqualTo "[""ALIVEPRESET") exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};

// Seven parts, eight once it carries areas, nine once it carries the record of
// which mods it needs. Anything else is not a preset, or is a preset that was cut
// short on its way here.
private _preset = parseSimpleArray _trimmed;

// It began like a preset and still would not parse, so it was cut short on the
// way here: a Discord message has a length limit and a preset is one long line.
// The engine logs its own complaint about that and hands back nothing useful, so
// the result is checked rather than trusted.
if (isNil "_preset" || {!(_preset isEqualType [])}) exitWith {
    ["This preset is damaged. It looks like it was cut short when it was copied."] call _no
};

if (!((count _preset) in [7, 8, 9])) exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};

_preset params ["_magic", "_version", "_meta", "_modules", "_links", "_mods", "_dropped"];
private _markers = _preset param [7, []];
// What the preset was told about its own mods when it was made, by name and
// Steam id. The only thing that can name a mod this machine does not have.
private _carried = _preset param [8, []];

if !(_magic isEqualTo "ALIVEPRESET") exitWith {
    ["That is not a preset. Copy the whole line, starting with [""ALIVEPRESET""."] call _no
};
if !(_version isEqualType 0) exitWith { ["This preset does not say which version it is."] call _no };
if (_version > 3) exitWith {
    [format ["This preset was written for a newer ALiVE (it says version %1, this build reads 3). Update ALiVE.", _version]] call _no
};
if (!(_modules isEqualType []) || {!(_links isEqualType [])} || {!(_meta isEqualType [])}) exitWith {
    ["This preset is damaged. It may have been cut short when it was copied."] call _no
};
if (count _modules == 0) exitWith { ["This preset has no modules in it."] call _no };

// Where the preset was saved, when it says: a pair of numbers or nothing. Whether
// the spot is on this map, and whether this is even the map it came from, is for
// whatever places it to decide. A damaged one is dropped rather than refused, the
// same trade as a damaged mod entry further down: without it the preset still
// places perfectly well, by a click, the way every preset used to.
private _home = _meta param [6, []];
if !(_home isEqualTo []) then {
    private _homeOk = (_home isEqualType []) && {count _home isEqualTo 2}
        && {(_home select 0) isEqualType 0} && {(_home select 1) isEqualType 0};
    if (!_homeOk) then {
        ["ALIVE_fnc_presetParse - dropped a saved position that is not a pair of numbers: %1", _home] call ALiVE_fnc_dump;
        _meta set [6, []];
    };
};

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
    // Two parts, or three once it remembers where the module sat. Most ALiVE
    // modules do not care where they are, but several read their own position and
    // act on it, so a preset that keeps the layout carries a third part per
    // module. A preset written before that stays two and still reads.
    if (!(_entry isEqualType []) || {!(count _entry in [2, 3])}) then {
        _problems pushBack format ["Module %1 in this preset is damaged.", _at];
    } else {
        _entry params ["_class", "_settings"];
        private _spot = _entry param [2, []];
        private _spotOk = (_spot isEqualTo []) || {
            (_spot isEqualType []) && {count _spot isEqualTo 2}
                && {(_spot select 0) isEqualType 0} && {(_spot select 1) isEqualType 0}
        };
        if (!(_class isEqualType "") || {!(_settings isEqualType [])} || {!_spotOk}) then {
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

// The mod record, checked only for shape. Its contents cannot be verified here
// and that is the point of it: it describes mods this machine may not have, so
// there is nothing to compare it against. A damaged entry is dropped rather than
// refused, because the preset's modules and areas are still perfectly placeable
// and losing the whole thing over a mod label would be the wrong trade.
if !(_carried isEqualType []) then {
    _problems pushBack "The mod list in this preset is damaged.";
} else {
    private _clean = [];
    {
        if (_x isEqualType [] && {count _x > 3}
            && {(_x select 0) isEqualType ""} && {!((_x select 0) isEqualTo "")}
            && {(_x select 1) isEqualType ""}
            && {(_x select 2) isEqualType true}
            && {(_x select 3) isEqualType []}) then {
            _clean pushBack _x;
        };
    } forEach _carried;
    if (count _clean != count _carried) then {
        ["ALIVE_fnc_presetParse - dropped %1 damaged mod entr(ies) of %2",
            (count _carried) - (count _clean), count _carried] call ALiVE_fnc_dump;
        if (count _preset > 8) then { _preset set [8, _clean] };
    };
};

if (count _problems > 0) exitWith { [false, [], _problems] };

[true, _preset, []]
