#include "script_component.hpp"
SCRIPT(presetMarkers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetMarkers

Description:
Everything a preset needs to know about editor markers, in one place, because
almost none of it is what you would guess and every part of it was measured in
the editor rather than read off the wiki.

What was measured, 2026-09-20:

  - A marker is a STRING, not an entity. The editor hands them back as their own
    names, so "the marker" and "its name" are the same thing, and anything that
    treats one as an object (typeOf, isNull) throws.

  - Numbers are written out to six significant digits. A preset is written with
    str and read back with parseSimpleArray, and it is refused unless the two
    match exactly, so a size of 2508.5478 comes back as 2508.55 and takes the
    whole preset down with it. Everything here is rounded to something that
    survives: whole metres, whole degrees, two decimals of alpha.

  - Setting a marker's name KILLS THE HANDLE you are holding. Every write after
    that returns false and is lost. So the name goes on last.

  - A name another marker already has is refused silently: the call returns true
    and the marker keeps the name it had. The only way to know is to read it back.

  - baseColor is a String ("ColorWEST"), not the array the wiki describes.

  - An icon marker cannot be made a shape: markerType reads -1 and setting it is
    ignored.

A marker in a preset is ten columns:

    [name, itemClass, markerType, position, size2, rotation, brush, baseColor, alpha, text]

"read" gives the position as it is; the caller turns it into an offset.

Parameters:
    _operation - STRING - "find", "read", "names", "make" or "setting"
    _arguments - ANY    - what that operation needs; a lone value is fine

    "find"    -                        -> ARRAY of STRING, every marker there is
    "read"    - name                   -> ARRAY, the ten columns, or []
    "names"   - [setting, value]       -> ARRAY of STRING, the areas value names
    "make"    - [row, anchor, taken]   -> ARRAY [wantedName, actualName, trimmed]
    "setting" - [moduleClass, property] -> STRING, the marker setting, or ""

Returns:
    ANY - per operation above

Examples:
    (begin example)
    private _all = ["find"] call ALIVE_fnc_presetMarkers;
    private _row = ["read", "BLUFOR_TAOR"] call ALIVE_fnc_presetMarkers;
    (end)

See Also:
    ALIVE_fnc_presetCollect, ALIVE_fnc_presetPlace

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_operation", "", [""]], "_arguments"];

// One operation takes a single name and the rest take a list, and demanding a
// list for all of them only bought ["read", ["NAME"]], which reads worse and was
// duly got wrong at both call sites. A lone value is wrapped here instead.
if (isNil "_arguments") then { _arguments = [] };
if !(_arguments isEqualType []) then { _arguments = [_arguments] };

// Only the three operations that touch the editor need the editor. Splitting a
// setting's value into names, and working out which setting a property is, are
// string and config work that a mission or a test can do perfectly well, and
// ALIVE_fnc_presetParse leans on both: gating the whole function on is3DEN made
// it answer "no areas named" everywhere outside the editor, which is the exact
// answer that lets an unchecked preset through.
if (!is3DEN && {(toLower _operation) in ["find", "read", "make"]}) exitWith { [] };

// Six significant digits is the ceiling, so these are the shapes that survive
// being written out and read back in.
private _fnc_metres = { round _this };
private _fnc_alpha = { (round (_this * 100)) / 100 };

// Anything a person typed, flattened to one line. toArray/fromArray rather than
// splitString, because splitString on a string of only separators returns an
// empty array and a label of one newline would come back as "".
private _fnc_oneLine = {
    if (!(_this isEqualType "") || {_this isEqualTo ""}) exitWith { "" };
    private _out = (toArray _this) apply { if (_x in [10, 13, 9]) then { 32 } else { _x } };
    trim (toString _out)
};

private _fnc_get = {
    // select 0 on an empty read is nil, str writes nil as "any", and an array
    // holding nil is never isEqualTo anything at all, including a copy of itself.
    // So every read lands on a value of the right type or a stated default.
    params ["_marker", "_property", "_default"];
    (_marker get3DENAttribute _property) param [0, _default]
};

switch (toLower _operation) do {

    // Markers are the only String-typed entries the editor hands back, so they
    // are found by asking what each thing is rather than by counting along the
    // list. The bucket they sit in has moved before and a comment in this repo
    // recorded the wrong one for long enough to mislead somebody.
    case "find": {
        private _found = [];
        {
            if (_x isEqualType []) then {
                {
                    if (_x isEqualType "" && {!(_x isEqualTo "")}) then { _found pushBackUnique _x };
                } forEach _x;
            };
        } forEach all3DENEntities;
        _found
    };

    case "read": {
        _arguments params [["_marker", "", [""]]];
        if (_marker isEqualTo "") exitWith { [] };

        private _name = [_marker, "markerName", ""] call _fnc_get;
        if (_name isEqualTo "") exitWith { [] };

        private _class = [_marker, "itemClass", ""] call _fnc_get;
        private _position = [_marker, "position", [0, 0, 0]] call _fnc_get;
        private _size = [_marker, "size2", [50, 50]] call _fnc_get;

        [
            _name,
            _class,
            [_marker, "markerType", 0] call _fnc_get,
            [(_position param [0, 0]) call _fnc_metres, (_position param [1, 0]) call _fnc_metres],
            [(_size param [0, 50]) call _fnc_metres, (_size param [1, 50]) call _fnc_metres],
            ([_marker, "rotation", 0] call _fnc_get) call _fnc_metres,
            [_marker, "brush", "Solid"] call _fnc_get,
            [_marker, "baseColor", "Default"] call _fnc_get,
            ([_marker, "alpha", 1] call _fnc_get) call _fnc_alpha,
            // A label is the one thing in a marker a person typed, so it is the
            // one thing that can hold a line break. A preset is one line of text
            // that travels through a chat message, a web form and a text box, and
            // a break in the middle of it makes it two presets, neither of which
            // reads. Turned into a space rather than refused: nobody should lose
            // a preset over a label.
            ([_marker, "text", ""] call _fnc_get) call _fnc_oneLine
        ]
    };

    // Each setting is split the way the module that reads it splits it. One
    // shared rule would be wrong three times out of four: an airspace of "a;b" is
    // two names to mil_ato and one name to anything splitting on commas.
    case "names": {
        _arguments params [["_setting", "", [""]], ["_value", "", [""]]];
        if !(_value isEqualType "") exitWith { [] };

        private _raw = switch (toLower _setting) do {
            case "ingressmarker": { [[_value, " ", ""] call CBA_fnc_replace] };
            case "airspace": { _value splitString "[]""', ;" };
            default { ([_value, " ", ""] call CBA_fnc_replace) splitString "[]""'," };
        };

        private _names = [];
        { if !(_x isEqualTo "") then { _names pushBackUnique _x } } forEach (_raw apply { trim _x });
        _names
    };

    // Make one, and say what it ended up called.
    //
    // A free name is chosen BEFORE anything is created, rather than asking for the
    // one we want and inspecting the wreckage. Asking cannot be made to work: a
    // rename that succeeds kills the handle, so reading the name back through it
    // gives nothing, and a rename that was refused leaves the handle alive and
    // answering. Both look the same from the caller's side unless you already know
    // which happened. Reading the wanted name instead is no better, because a
    // marker of that name existing is exactly the case being tested.
    //
    // The caller passes every name already spoken for, including ones it made a
    // moment ago in the same batch, because those are not in the scenario yet as
    // far as a fresh scan is concerned.
    case "make": {
        _arguments params [["_row", [], [[]]], ["_anchor", [0, 0, 0], [[]]], ["_taken", [], [[]]]];
        if (count _row < 10) exitWith { ["", ""] };

        _row params ["_wanted", "_class", "_shape", "_offset", "_size", "_rotation", "_brush", "_colour", "_alpha", "_text"];

        // An area written on a big map can be bigger than a small one. An Altis
        // TAOR of 10 km dropped on Stratis, which is 8192 m square, covers the
        // island, and the person believes they constrained the commander's ground
        // when they have done the opposite. Sizes are in real metres and have to
        // be, so the only honest thing is to trim one that cannot fit and say so.
        private _trimmed = false;
        private _half = worldSize / 2;
        private _size = [_size param [0, 50], _size param [1, 50]];
        {
            if (_x > _half) then {
                _size set [_forEachIndex, round _half];
                _trimmed = true;
            };
        } forEach +_size;

        // And on the map. The module grid is already bounds checked, because a
        // preset placed off the island once existed and looked exactly like a
        // preset that placed nothing. An area is worse: it would be carried in the
        // settings, so nothing would report it as dropped.
        private _at = [
            (((_anchor param [0, 0]) + (_offset param [0, 0])) max 1) min (worldSize - 1),
            (((_anchor param [1, 0]) + (_offset param [1, 0])) max 1) min (worldSize - 1),
            0
        ];

        // Marker names are not case sensitive, so "Taor_1" and "taor_1" are the
        // same name to the engine and have to be the same name here.
        private _lower = _taken apply { toLower _x };
        private _name = _wanted;
        private _n = 1;
        while { (toLower _name) in _lower && {_n < 100} } do {
            _n = _n + 1;
            _name = format ["%1_%2", _wanted, _n];
        };

        private _marker = create3DENEntity ["Marker", _class, _at];
        if (!(_marker isEqualType "") || {_marker isEqualTo ""}) exitWith { [_wanted, ""] };

        // An icon marker has no shape and no size of its own; setting them is
        // accepted and ignored, which would read as success in a log.
        if (_class isEqualTo "") then {
            _marker set3DENAttribute ["markerType", _shape];
            _marker set3DENAttribute ["size2", +_size];
            _marker set3DENAttribute ["brush", _brush];
        };
        _marker set3DENAttribute ["rotation", _rotation];
        _marker set3DENAttribute ["baseColor", _colour];
        _marker set3DENAttribute ["alpha", _alpha];
        _marker set3DENAttribute ["text", _text];

        // Last, because this is the write that invalidates the handle. The name
        // was free before we started, so it takes; the check is here because a
        // silent refusal is the one failure that would put a module's setting on
        // somebody else's area, and that is worth one read to rule out.
        _marker set3DENAttribute ["markerName", _name];
        private _stillAnswers = [_marker, "markerName", ""] call _fnc_get;
        if !(_stillAnswers isEqualTo "") exitWith {
            // The old handle still resolves, so the rename did not happen and the
            // marker is sitting there under the editor's own name. Say so with the
            // name it really has, and let the caller point the settings at that.
            ["ALIVE_fnc_presetMarkers - %1 would not take the name %2, it is still %3",
                _wanted, _name, _stillAnswers] call ALiVE_fnc_dump;
            [_wanted, _stillAnswers, _trimmed]
        };

        [_wanted, _name, _trimmed]
    };

    // Which marker-naming setting a module's property is, or "" for anything
    // else. Kept here rather than worked out again wherever it is needed, because
    // getting it wrong means a setting quietly keeps pointing at an area that is
    // not there.
    //
    // The setting is found by asking config which attribute carries that property
    // and taking its class name. The tempting shortcut, matching the end of the
    // property against the setting name, is wrong twice in fifteen: mil_cqb's
    // units_blacklist ends with "_blacklist" and lists unit classes, and
    // sys_logistics has a BLACKLIST that lists object types. Neither names an
    // area, and a preset that carried them as though they did would take them
    // away whenever areas were left out.
    //
    // The comparison is isEqualTo, which is case sensitive for text, because
    // BLACKLIST and blacklist are two different settings that mean two different
    // things and "in" cannot be relied on to tell them apart.
    case "setting": {
        _arguments params [["_class", "", [""]], ["_property", "", [""]]];
        private _settings = getArray (configFile >> "CfgALiVEPresets" >> "markerAttributes");
        if (count _settings == 0) then { _settings = ["taor", "blacklist", "airspace", "ingressMarker"] };

        private _found = "";
        private _attrs = configFile >> "CfgVehicles" >> _class >> "Attributes";
        for "_i" from 0 to (count _attrs) - 1 do {
            private _a = _attrs select _i;
            if (isClass _a && {(getText (_a >> "property")) isEqualTo _property}) exitWith {
                private _name = configName _a;
                if ((_settings findIf { _x isEqualTo _name }) >= 0) then { _found = _name };
            };
        };
        _found
    };

    default { [] };
};
