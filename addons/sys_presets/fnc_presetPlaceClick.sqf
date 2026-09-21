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

Parameters:
    _preset - ARRAY - a preset that has been through ALIVE_fnc_presetParse

Returns:
    BOOL - whether the editor is now waiting for a click

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
// and place two presets on the next click.
private _armed = uiNamespace getVariable ["ALiVE_presetClickHandler", -1];
if (_armed >= 0) then {
    _eden displayRemoveEventHandler ["MouseButtonDown", _armed];
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
    // Seven parts, or eight once it carries areas. This one used to exit true and
    // say nothing at all, so a preset that got this far and failed looked exactly
    // like a click that worked.
    if (!((count _preset) in [7, 8, 9])) exitWith {
        ["That preset could not be read, so nothing was placed.", 2, 10] call BIS_fnc_3DENNotification;
        true
    };

    ([_preset, _pos] call ALIVE_fnc_presetPlace) params ["_placed", "_settings", "_links", "_skipped", ["_areas", 0], ["_renamed", []], ["_trims", []]];

    private _msg = if (_placed == 0) then {
        format ["Everything in that preset is already in this scenario: %1.", _skipped joinString ", "]
    } else {
        private _said = format ["Placed %1 module%2 with %3 setting%4 here.", _placed, ["s", ""] select (_placed == 1),
            _settings, ["s", ""] select (_settings == 1)];
        if (_areas > 0) then {
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
        _said
    };
    [_msg, [0, 1] select (_placed == 0), 10] call BIS_fnc_3DENNotification;

    // The click was for the preset, so the editor does not also get to act on
    // it: without this it deselects the modules that were just placed.
    true
}];

uiNamespace setVariable ["ALiVE_presetClickHandler", _id];
["Click where you want the preset. Right click to cancel.", 0, 12] call BIS_fnc_3DENNotification;

true
