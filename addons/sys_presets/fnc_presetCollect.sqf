#include "script_component.hpp"
SCRIPT(presetCollect);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetCollect

Description:
Reads the ALiVE modules in the open editor scenario and builds a preset out of
them: every module, the settings that were actually chosen, and the sync lines
between them.

By default every ALiVE module is taken. A caller can name which modules and which
areas it wants instead, which is what the window does when somebody ticks them,
but ALiVE Required and the Virtual AI System are taken whether they were ticked or
not: a preset without them places cleanly and then does nothing at all, with no
error to explain it, and that is the one failure a mission maker cannot debug.

A sync line to a module that was not taken goes with it, because there is nothing
left for it to point at.

Only settings that differ from the module's own default are carried. That keeps a
preset a few hundred characters instead of forty thousand, and it means a default
improved later reaches presets written today. The rest of the module's settings
are not missing from the preset so much as deliberately left to ALiVE.

Settings are dropped in two cases, and the caller is told which, by name:
  - the three that hold script rather than data: the per-spawn hook and the two
    runway ends, which mil_ato reads with call compile. Carrying any of them would
    make a shared preset a way to run somebody else's code.
  - a setting naming an area, when that area is not coming too. Keeping it would
    point a commander at ground that does not exist, which reads as configured and
    behaves as broken.

An area that IS coming travels with the preset, so the setting naming it can come
as well. That is the whole reason presets carry areas at all.

Both lists live in config, under CfgALiVEPresets, so the editor side and the
tooling that reviews a submission read the same list rather than two copies.

Parameters:
    _choice - ARRAY - optional [_modules, _markers]; nothing means everything
      _modules - ARRAY of the module entities to take
      _markers - ARRAY of STRING, the area names to take

Returns:
    ARRAY [_preset, _report]
      _preset - the preset array, ready for ALIVE_fnc_presetSerialize. Versioned
                by what is actually in it, so a preset gains a part only when it
                has something to put there and stays readable by older builds
                otherwise: seven parts and version 1 plain, eight and version 2
                once it carries areas, nine and version 3 once it carries the
                record of which mods it needs.
      _report - [_moduleCount, _settingCount, _linkCount, _dropped, _mods, _missing]

Examples:
    (begin example)
    ([] call ALIVE_fnc_presetCollect) params ["_preset", "_report"];
    ([[_someModules, ["BLUFOR_TAOR"]]] call ALIVE_fnc_presetCollect) params ["_preset"];
    (end)

See Also:
    ALIVE_fnc_presetSerialize, ALIVE_fnc_presetDefault, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_choice", [], [[]]]];

if (!is3DEN) exitWith {
    ["ALIVE_fnc_presetCollect - only the editor has a scenario to read"] call ALiVE_fnc_dump;
    [[], [0, 0, 0, [], [], []]]
};

// Nothing chosen means everything, which is what the right click entry does. The
// window passes two explicit lists instead: which modules, and which areas.
_choice params [["_pickModules", [], [[]]], ["_pickMarkers", [], [[]]], ["_keepLayout", true, [true]]];
private _choosing = count _choice > 0;

// Both lists live in config so the editor and the tooling that reviews a
// submission read the same thing. The fallbacks matter more than they look: a
// config read comes back empty until the addon is rebuilt, and a fallback that
// disagrees with config is a second source of truth that only bites later.
private _skip = getArray (configFile >> "CfgALiVEPresets" >> "skipAttributes");
if (count _skip == 0) then { _skip = ["onEachSpawn", "runwaystartpos", "runwayendpos"] };

private _markerSettings = getArray (configFile >> "CfgALiVEPresets" >> "markerAttributes");
if (count _markerSettings == 0) then { _markerSettings = ["taor", "blacklist", "airspace", "ingressMarker"] };

// A ticked area is carried because it was ticked, and for no other reason.
// Working it out from the settings instead meant ticking an area whose module
// was not also ticked carried nothing at all, which is not what the tick says.
private _here = ["find"] call ALIVE_fnc_presetMarkers;
private _wantedLower = _pickMarkers apply { toLower _x };
private _carry = if (_choosing) then {
    _here select { (toLower _x) in _wantedLower }
} else {
    +_here
};
private _carryLower = _carry apply { toLower _x };

// Without its area, a setting naming one is dropped too: a taor pointing at a
// marker that is not there widens the placement modules to the whole map and
// stops mil_ato starting at all, so half the pair is worse than neither.
private _missing = [];    // named by a setting, and not coming with it

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

// Only what was chosen, when a choice was made. ALiVE Required and the profile
// system are never dropped even if they were not ticked: a preset without them
// places cleanly and then does nothing at all, with no error to explain it, and
// that is the one failure a mission maker cannot debug.
if (_choosing) then {
    _modules = _modules select {
        _x in _pickModules || {(toLower (typeOf _x)) in ["alive_require", "alive_sys_profile"]}
    };
};

if (count _modules == 0) exitWith {
    [[], [0, 0, 0, [], [], []]]
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
                        // A setting that names an area is kept only if every area
                        // it names is coming too. Keeping it otherwise would point
                        // a commander at something that is not there.
                        private _namesAreas = (_markerSettings findIf { _x isEqualTo _name }) >= 0;
                        private _areasOk = false;
                        if (_namesAreas) then {
                            private _named = ["names", [_name, _value]] call ALIVE_fnc_presetMarkers;
                            private _all = count _named > 0;
                            {
                                if !((toLower _x) in _carryLower) then {
                                    _missing pushBackUnique _x;
                                    _all = false;
                                };
                            } forEach _named;
                            _areasOk = _all;
                        };

                        if ((_skip findIf { _x isEqualTo _name }) >= 0 || {_namesAreas && {!_areasOk}}) then {
                            _dropped pushBackUnique _name;
                        } else {
                            // Carried as the editor holds it, so its type survives
                            // and the value goes back in exactly as it came out.
                            _kept pushBack [_prop, _value];
                            _settingCount = _settingCount + 1;
                        };
                    };
                };
            };
        };
    };

    // Where the module sits, kept as an offset from the middle of the group, the
    // same way an area is kept. It is not decoration: mil_placement_custom,
    // civ_placement_custom and mil_placement_spe place their objective AT it,
    // mil_ato writes it into its own hash, mil_logistics uses it as the default
    // static source, and both placement modules centre their objective scenery
    // on it. Dropping it, which is what a preset did until now, leaves those
    // modules working off wherever a tidy grid happened to put them.
    if (_keepLayout) then {
        private _at = getPosATL _entity;
        _out pushBack [_type, _kept, [(_at param [0, 0]), (_at param [1, 0])]];
    } else {
        _out pushBack [_type, _kept];
    };
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

// Everything that has a place is placed relative to ONE middle, worked out from
// the modules and the areas together.
//
// Centring each kind on its own middle would be the obvious thing and would be
// wrong: a TAOR drawn around a custom objective would come out centred on the
// areas while the objective came out centred on the modules, and the objective
// would no longer be inside its own area. The arrangement is the thing being
// carried, so there is one origin for all of it.
//
// A preset carrying world coordinates would only mean anything on the map it came
// from. Carried as offsets, the whole arrangement lands wherever it is put and
// keeps its shape. Sizes stay in real metres, because an area's size is a thing
// the mission maker actually chose.
private _rows = [];
{
    private _row = ["read", _x] call ALIVE_fnc_presetMarkers;
    if (count _row >= 10) then { _rows pushBack _row };
} forEach _carry;

private _places = [];
if (_keepLayout) then {
    { _places pushBack (_x select 2) } forEach _out;
};
{ _places pushBack (_x select 3) } forEach _rows;

private _midX = 0;
private _midY = 0;
if (count _places > 0) then {
    private _sumX = 0;
    private _sumY = 0;
    {
        _sumX = _sumX + (_x param [0, 0]);
        _sumY = _sumY + (_x param [1, 0]);
    } forEach _places;
    _midX = _sumX / count _places;
    _midY = _sumY / count _places;
};

// Whole metres, because str writes six significant digits and the round trip
// check refuses anything that does not come back identical.
private _fnc_offset = {
    params ["_at"];
    [round ((_at param [0, 0]) - _midX), round ((_at param [1, 0]) - _midY)]
};

if (_keepLayout) then {
    { _x set [2, [_x select 2] call _fnc_offset] } forEach _out;
};

private _markers = [];
{
    private _row = +_x;
    _row set [3, [_row select 3] call _fnc_offset];
    _markers pushBack _row;
} forEach _rows;

// Seven parts and version 1 when there are no areas, so a preset that gains
// nothing from the new slot stays readable by every build that already ships.
// Eight and version 2 only when there is something in it.
// Who made it, when, and a name, rather than three empty strings. A preset used
// to come out of here with no title, no author and no date, so a copied one was
// anonymous and undated the moment it left the library.
//
// The author is the profile name, which is the handle the person is already known
// by in any game they join. It is put in the preset so credit travels with it,
// and the window shows it in a box they can edit or clear, because a name that
// travels invisibly is not a name anybody agreed to share.
//
// systemTime, not date: date is the SCENARIO's clock, which a mission maker sets
// to whatever suits the mission, so a preset made today would be filed under the
// year the editor happens to be showing.
private _now = systemTime;
private _fnc_pad = { if (_this < 10) then { "0" + str _this } else { str _this } };
private _stamp = format ["%1-%2-%3", _now select 0,
    (_now select 1) call _fnc_pad, (_now select 2) call _fnc_pad];

// What the preset needs loaded, worked out from the preset itself once it is
// finished rather than while it is being built. Done here it also sees the
// module classes, so a module from somewhere else counts, where the scan this
// replaced only ever looked at faction settings.
private _mods = [_out] call ALIVE_fnc_presetAddons;

// And the mod behind each of those addons, by NAME and Steam id, recorded now
// while this machine has them loaded.
//
// This is the whole point of the slot. A recipient who is MISSING a mod can work
// nothing out about it: none of its classes are in their config and it is not in
// their getLoadedModsInfo, so they cannot be told what it is called or where to
// get it. Whoever made the preset could. So it is written down here, once, and
// travels with the preset.
private _carried = [];
{
    _x params ["_name", "", "", "", "", "_id", "_isDLC", "_addons"];
    // Nothing worth carrying for a mod with no Steam id and nothing but its
    // addon name, which is what an unresolvable source looks like.
    if (!(_name isEqualTo "") && {count _addons > 0}) then {
        _carried pushBack [_name, _id, _isDLC, _addons];
    };
} forEach ([_out, [], "mods"] call ALIVE_fnc_presetAddons);

private _meta = [
    format ["%1 preset, %2", worldName, _stamp],
    "",
    profileName,
    worldName,
    getText (configFile >> "CfgPatches" >> "ALiVE_main" >> "version"),
    _stamp
];
// Version by what is actually in it, so a preset gains a slot only when it has
// something to put there and stays readable by older builds otherwise. Seven
// parts for the plainest preset, eight once it carries areas, nine once it
// carries a mod record. A version 3 preset always has the areas slot, empty if
// there are no areas, because the mod record sits after it.
private _preset = switch (true) do {
    case (count _carried > 0): {
        ["ALIVEPRESET", 3, _meta, _out, _links, _mods, _dropped, _markers, _carried]
    };
    case (count _markers > 0): {
        ["ALIVEPRESET", 2, _meta, _out, _links, _mods, _dropped, _markers]
    };
    default {
        ["ALIVEPRESET", 1, _meta, _out, _links, _mods, _dropped]
    };
};

[_preset, [count _modules, _settingCount, count _links, _dropped, _mods, _missing]]
