#include "script_component.hpp"
SCRIPT(presetPlace);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetPlace

Description:
Puts a checked preset into the open scenario: one module per entry, its chosen
settings on it, and the sync lines between them.

The modules are laid out on a grid beside where the camera is looking, six to a
row, rather than where they happened to sit in the scenario they came from. Where
an ALiVE module sits means nothing, and a preset that dropped four modules on top
of each other would look broken.

A module class the scenario already has is left alone rather than added a second
time, and is named in the answer. ALiVE Required and the Virtual AI System are
one-per-scenario things, and quietly giving somebody two is worse than telling
them the preset had its own.

Areas the preset carries go down first, because the settings naming them have to
be pointed at whatever they ended up called. A marker IS its name in the editor,
and a name the scenario already uses is refused without a word, so an area can
arrive called something else; left alone, the module's setting would then name
the RECIPIENT's area of that name, which reads as working and is not. Placing the
same preset twice is enough to hit that, with no second author involved.

The whole placement is one history entry, so a preset that is not what somebody
expected goes away with a single undo.

Parameters:
    _preset - ARRAY - a preset that has been through ALIVE_fnc_presetParse

Returns:
    ARRAY [_placed, _settings, _links, _skipped, _areas, _renamed]
      _placed   - NUMBER of modules created
      _settings - NUMBER of settings applied
      _links    - NUMBER of sync lines drawn
      _skipped  - ARRAY of STRING, module classes the scenario already had
      _areas    - NUMBER of areas created
      _renamed  - ARRAY of STRING, areas that had to come in under another name

Examples:
    (begin example)
    ([_preset] call ALIVE_fnc_presetPlace) params ["_placed", "_settings", "_links", "_skipped"];
    (end)

See Also:
    ALIVE_fnc_presetParse, ALIVE_fnc_presetLoad

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_preset", [], [[]]], ["_where", [], [[]]]];

if (!is3DEN) exitWith { [0, 0, 0, [], 0, []] };
if (!(count _preset isEqualTo 7) && {!(count _preset isEqualTo 8)}) exitWith { [0, 0, 0, [], 0, []] };

_preset params ["_magic", "_version", "_meta", "_modules", "_links"];
// param, not select: every preset written before areas existed has seven parts,
// and this runs on all of them.
private _markers = _preset param [7, []];

// What the scenario already has, so nothing is doubled up.
private _have = [];
{
    if (_x isEqualType []) then {
        {
            if (_x isEqualType objNull && {!isNull _x} && {(typeOf _x) isKindOf "ModuleAliveBase"}) then {
                _have pushBackUnique (toLower (typeOf _x));
            };
        } forEach _x;
    };
} forEach all3DENEntities;

// In the middle of what the person is looking at, and ON THE MAP.
//
// Every candidate is checked against the world's own bounds, because the middle
// of the screen is not a place when the editor is showing the map: asked there
// it answers from the camera's forward ray and gives a point off the island
// entirely. Measured: a preset placed that way landed at 2500, 16650 on Stratis,
// which is 8192 m square, so the modules existed and nothing was visible
// anywhere. A position that is merely positive is not good enough.
private _fnc_onMap = {
    params ["_p"];
    if (!(_p isEqualType []) || {count _p < 2}) exitWith { false };
    private _px = _p select 0;
    private _py = _p select 1;
    _px isEqualType 0 && {_py isEqualType 0} && {_px > 0} && {_py > 0}
        && {_px < worldSize} && {_py < worldSize}
};

private _camera = get3DENCamera;
private _anchor = [];
private _source = "the middle of the map";
{
    _x params ["_candidate", "_name"];
    if (_anchor isEqualTo [] && {[_candidate] call _fnc_onMap}) then {
        _anchor = +_candidate;
        _source = _name;
    };
} forEach [
    [_where, "where the caller said"],
    [screenToWorld [0.5, 0.5], "the middle of the view"],
    [if (isNull _camera) then { [] } else { getPosATL _camera }, "the editor camera"]
];

if (_anchor isEqualTo []) then { _anchor = [worldSize / 2, worldSize / 2, 0] };
_anchor set [2, 0];

private _created = [];
private _skipped = [];
private _applied = 0;
private _drawn = 0;
private _areas = 0;
private _renamed = [];

// The areas go down first, because the settings that name them have to be
// rewritten before they are applied. A name already in use is taken by the
// scenario that is already here, and the marker would quietly end up called
// something else: left alone, the module's setting would then point at the
// RECIPIENT's area of that name, which reads as working and is not. Placing the
// same preset twice is enough to hit it, no second author needed.
private _renames = [];

collect3DENHistory {
    if (count _markers > 0) then {
        private _taken = ["find"] call ALIVE_fnc_presetMarkers;
        {
            (["make", [_x, _anchor, _taken]] call ALIVE_fnc_presetMarkers) params [["_wanted", ""], ["_actual", ""]];
            if !(_actual isEqualTo "") then {
                _areas = _areas + 1;
                _taken pushBackUnique _actual;
                if !(_actual isEqualTo _wanted) then {
                    _renames pushBack [toLower _wanted, _actual];
                    _renamed pushBack format ["%1 as %2", _wanted, _actual];
                };
            };
        } forEach _markers;
    };

    {
        _x params ["_class", "_settings"];
        if ((toLower _class) in _have) then {
            _skipped pushBackUnique _class;
            // A place is still kept in the list, so the sync lines further down
            // still point at the module the preset meant.
            _created pushBack objNull;
        } else {
            private _pos = _anchor vectorAdd [(_forEachIndex % 6) * 8, -8 * floor (_forEachIndex / 6), 0];
            private _entity = create3DENEntity ["Logic", _class, _pos];
            if (isNull _entity) then {
                _created pushBack objNull;
            } else {
                {
                    private _prop = _x select 0;
                    private _value = _x select 1;

                    // If an area had to come in under a different name, the setting
                    // that names it is pointed at the name that actually exists.
                    if (count _renames > 0 && {_value isEqualType ""}) then {
                        private _setting = ["setting", [_class, _prop]] call ALIVE_fnc_presetMarkers;
                        if !(_setting isEqualTo "") then {
                            private _named = ["names", [_setting, _value]] call ALIVE_fnc_presetMarkers;
                            {
                                private _name = _x;
                                private _at = _renames findIf { (_x select 0) isEqualTo (toLower _name) };
                                if (_at >= 0) then {
                                    _value = [_value, _name, (_renames select _at) select 1] call CBA_fnc_replace;
                                };
                            } forEach _named;
                        };
                    };

                    if (_entity set3DENAttribute [_prop, _value]) then { _applied = _applied + 1 };
                } forEach _settings;
                _created pushBack _entity;
            };
        };
    } forEach _modules;

    {
        _x params ["_a", "_b"];
        private _from = _created param [_a, objNull];
        private _to = _created param [_b, objNull];
        if (!isNull _from && {!isNull _to}) then {
            add3DENConnection ["Sync", [_from], _to];
            _drawn = _drawn + 1;
        };
    } forEach _links;
};

private _live = _created select { !isNull _x };
if (count _live > 0) then { set3DENSelected _live };

// Said out loud, with where they went. "Nothing happened" is the one report that
// cannot be acted on, and modules placed somewhere off screen look exactly like
// modules not placed at all.
["ALIVE_fnc_presetPlace - placed %1 module(s), %2 setting(s), %3 link(s), %4 area(s) at %5, taken from %6; already present: %7; renamed: %8",
    count _live, _applied, _drawn, _areas, _anchor apply { round _x }, _source, _skipped, _renamed] call ALiVE_fnc_dump;

[count _live, _applied, _drawn, _skipped, _areas, _renamed]
