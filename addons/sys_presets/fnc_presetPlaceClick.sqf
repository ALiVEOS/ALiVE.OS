#include "script_component.hpp"
SCRIPT(presetPlaceClick);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetPlaceClick

Description:
Hands the person the preset and lets them put it where they want it, the way
placing anything else in the editor works.

Guessing where somebody is looking has two answers in the editor and neither is
reliable in both views, so it is not guessed. The window gets out of the way, the
next click says where, and that is the same gesture as placing a composition from
the asset browser. Right click, or a click that is not on the map, cancels.

Except on the map the preset was saved on. A preset remembers where it was made,
and back on that map it goes straight there with no click, and the view follows
it. Somebody who saves their setup and loads it into a fresh scenario on the same
map wants it where they built it; asking them to find that spot again by hand is
how a TAOR ends up a few hundred metres from the town it was drawn around. On any
other map, and for a preset saved before presets remembered, it is the click.

Parameters:
    _preset - ARRAY - a preset that has been through ALIVE_fnc_presetParse

Returns:
    BOOL - whether the preset has been dealt with: placed where it was saved, or
    waiting for a click

Examples:
    (begin example)
    [_preset] call ALIVE_fnc_presetPlaceClick;
    (end)

See Also:
    ALIVE_fnc_presetPlace, ALIVE_fnc_presetWorldAt, ALIVE_fnc_presetWindow

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_preset", [], [[]]]];

if (!is3DEN) exitWith { false };
if (!((count _preset) in [7, 8, 9])) exitWith {
    ["ALIVE_fnc_presetPlaceClick - a preset of %1 part(s) cannot be read; 7, 8 or 9 expected",
        count _preset] call ALiVE_fnc_dump;
    false
};

disableSerialization;
private _eden = findDisplay 313;
if (isNull _eden) exitWith { false };

// One at a time. Asking twice without clicking would leave the first ask armed
// and place two presets on the next click. Forgotten as well as removed: a preset
// that goes straight back where it was saved never arms a handler of its own, so
// the old number would still be here next time, and removing a handler by a
// number the engine has since given to something else removes the wrong one.
// Only ever removed from the editor it was added to, for the same reason: leave
// the editor with a click still waiting and the next one numbers its handlers
// from the start again, so the same number can belong to another addon.
private _armed = uiNamespace getVariable ["ALiVE_presetClickHandler", -1];
private _armedOn = uiNamespace getVariable ["ALiVE_presetClickDisplay", displayNull];
if (_armed >= 0 && {_armedOn isEqualTo _eden}) then {
    _eden displayRemoveEventHandler ["MouseButtonDown", _armed];
};
uiNamespace setVariable ["ALiVE_presetClickHandler", -1];
uiNamespace setVariable ["ALiVE_presetPending", nil];

// What gets said once a preset is down, wherever it went. Kept in uiNamespace
// because a click is answered by an event handler, which cannot see anything
// private to this file, and a preset that goes straight home has to say the same
// things. Set on every call, so the handler never finds it missing.
uiNamespace setVariable ["ALiVE_presetPlaceReport", {
    params ["_result", "_where"];
    _result params ["_placed", "_settings", "_links", "_skipped", ["_areas", 0], ["_renamed", []], ["_trims", []]];

    if (_placed == 0 && {_areas == 0}) exitWith {
        format ["Everything in that preset is already in this scenario: %1.", _skipped joinString ", "]
    };

    // Every module already here but the areas still went down, which is what
    // placing a preset twice on its own map does: the second copy of each area
    // lands exactly on the first. Said, because two identical areas in one spot
    // look like one.
    private _said = if (_placed == 0) then {
        format ["Every module in that preset is already in this scenario, so only its area%1 went down %2.",
            ["s", ""] select (_areas == 1), _where]
    } else {
        format ["Placed %1 module%2 with %3 setting%4 %5.", _placed, ["s", ""] select (_placed == 1),
            _settings, ["s", ""] select (_settings == 1), _where]
    };
    if (_placed > 0 && {_areas > 0}) then {
        _said = _said + format [" %1 area%2 came with it.", _areas, ["s", ""] select (_areas == 1)];
    };
    // A renamed area is worth saying out loud. The modules were pointed at the
    // new name, so it works, but the person would otherwise find an area in
    // their scenario under a name they never chose.
    if (count _renamed > 0) then {
        _said = _said + format [" That name was taken, so: %1.", _renamed joinString ", "];
    };
    // An area bigger than this map was cut down to fit it. The commander will
    // work inside a different shape than the one the preset was drawn with, so
    // this is not a detail to swallow.
    if (count _trims > 0) then {
        _said = _said + format [" Too big for this map, so trimmed to fit: %1.", _trims joinString ", "];
    };
    // Named, because a preset going back where it was saved lands exactly on top
    // of an earlier copy of itself, and two copies in one spot look like one.
    if (_placed > 0 && {count _skipped > 0}) then {
        _said = _said + format [" Already in this scenario, so not added again: %1.", _skipped joinString ", "];
    };
    _said
}];

// Is this the map the preset was saved on, and does it say where? The terrain is
// compared without regard to case, because it is the same terrain whatever case
// a config happens to report its name in.
private _meta = _preset param [2, []];
private _home = [];
private _world = "";
if (_meta isEqualType []) then {
    _home = _meta param [6, []];
    _world = _meta param [3, ""];
};
private _homeMap = (_world isEqualType "") && {(toLower _world) isEqualTo (toLower worldName)};
private _hasHome = (_home isEqualType []) && {count _home isEqualTo 2}
    && {(_home select 0) isEqualType 0} && {(_home select 1) isEqualType 0};
private _homeOnMap = _hasHome && {(_home select 0) > 0} && {(_home select 1) > 0}
    && {(_home select 0) < worldSize} && {(_home select 1) < worldSize};

if (_homeMap && {_homeOnMap}) exitWith {
    private _at = [_home select 0, _home select 1, 0];
    private _result = [_preset, _at] call ALIVE_fnc_presetPlace;
    private _msg = [_result, format ["where this preset was saved on %1", worldName]]
        call (uiNamespace getVariable ["ALiVE_presetPlaceReport", { "Preset placed." }]);
    [_msg, [0, 1] select ((_result select 0) == 0), 10] call BIS_fnc_3DENNotification;
    ["ALIVE_fnc_presetPlaceClick - placed at its saved spot %1 on %2", _at, worldName] call ALiVE_fnc_dump;

    // And the view goes with it, after the placement rather than before, so a
    // view that will not move can never cost anybody their preset. Placed off
    // screen with no click to say where, it would look exactly like nothing
    // happened. The map is moved when the map is showing, and the camera always,
    // so switching between the two views finds the preset either way. Both the
    // way the editor itself does it.
    private _map = ((allControls _eden) select {
        (ctrlType _x) in [100, 101] && {ctrlShown _x}
    }) param [0, controlNull];
    if (!isNull _map) then {
        _map ctrlMapAnimAdd [0.5, ctrlMapScale _map, _at];
        ctrlMapAnimCommit _map;
    };
    move3DENCamera [[_at select 0, _at select 1, getTerrainHeightASL _at], true];
    true
};

// Back on its own map, but the spot it remembers is off the edge of it: a map
// changed by an update, or a preset edited by hand. It is asked for with a click
// like any other, and the person is told why the click is back.
private _ask = "Click where you want the preset. Right click to cancel.";
if (_homeMap && {_hasHome}) then {
    _ask = format ["This preset was saved on %1, but the spot it remembers is off this map. Click where you want it. Right click to cancel.", worldName];
    ["ALIVE_fnc_presetPlaceClick - saved spot %1 is off %2, asking for a click", _home, worldName] call ALiVE_fnc_dump;
};

uiNamespace setVariable ["ALiVE_presetPending", _preset];

private _id = _eden displayAddEventHandler ["MouseButtonDown", {
    params ["_display", "_button", "_sx", "_sy"];

    private _handler = uiNamespace getVariable ["ALiVE_presetClickHandler", -1];
    if (_handler >= 0) then {
        _display displayRemoveEventHandler ["MouseButtonDown", _handler];
        uiNamespace setVariable ["ALiVE_presetClickHandler", -1];
    };

    if (_button != 0) exitWith {
        ["Nothing placed.", 1, 6] call BIS_fnc_3DENNotification;
        uiNamespace setVariable ["ALiVE_presetPending", nil];
        true
    };

    private _pos = [_display, _sx, _sy] call ALIVE_fnc_presetWorldAt;
    if (count _pos < 2) exitWith {
        ["That is not on the map. Nothing placed.", 2, 8] call BIS_fnc_3DENNotification;
        uiNamespace setVariable ["ALiVE_presetPending", nil];
        true
    };

    private _preset = uiNamespace getVariable ["ALiVE_presetPending", []];
    uiNamespace setVariable ["ALiVE_presetPending", nil];
    // Seven parts, eight once it carries areas, nine once it carries a mod
    // record. This one used to exit true and say nothing at all, so a preset
    // that got this far and failed looked exactly like a click that worked.
    if (!((count _preset) in [7, 8, 9])) exitWith {
        ["That preset could not be read, so nothing was placed.", 2, 10] call BIS_fnc_3DENNotification;
        true
    };

    private _result = [_preset, _pos] call ALIVE_fnc_presetPlace;
    private _msg = [_result, "here"] call (uiNamespace getVariable ["ALiVE_presetPlaceReport", { "Preset placed." }]);
    [_msg, [0, 1] select ((_result select 0) == 0), 10] call BIS_fnc_3DENNotification;

    // The click was for the preset, so the editor does not also get to act on
    // it: without this it deselects the modules that were just placed.
    true
}];

uiNamespace setVariable ["ALiVE_presetClickHandler", _id];
uiNamespace setVariable ["ALiVE_presetClickDisplay", _eden];
[_ask, 0, 12] call BIS_fnc_3DENNotification;

true
