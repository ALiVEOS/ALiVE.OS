#include "script_component.hpp"
SCRIPT(presetLoad);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetLoad

Description:
Takes a preset off the clipboard and puts it in the scenario, or says why it
cannot.

This is the other half of sharing: somebody pastes you a line in Discord, you
copy it, and ALiVE builds the setup it describes. Nothing in the text runs; it is
read as data, checked against this build, and only then placed.

When it cannot be placed the reason is said in full rather than reduced to a
refusal, because the likely causes are things the person can act on: a line that
was cut short when it was copied, a module from a mod they are not running, or a
preset written for a newer ALiVE.

Parameters:
    None.

Returns:
    BOOL - whether anything was placed

Examples:
    (begin example)
    [] call ALIVE_fnc_presetLoad;
    (end)

See Also:
    ALIVE_fnc_presetParse, ALIVE_fnc_presetPlace, ALIVE_fnc_presetShare

Author:
    Jman
---------------------------------------------------------------------------- */

if (!is3DEN) exitWith { false };

private _text = copyFromClipboard;

([_text] call ALIVE_fnc_presetParse) params ["_ok", "_preset", "_problems"];

if (!_ok) exitWith {
    private _first = if (count _problems > 0) then { _problems select 0 } else { "That preset cannot be read." };
    [_first, 2, 12] call BIS_fnc_3DENNotification;
    {
        ["ALIVE_fnc_presetLoad - refused: %1", _x] call ALiVE_fnc_dump;
    } forEach _problems;
    false
};

// The next click says where it goes, the same as placing one from the preset
// window, so a preset lands where it was asked for rather than where something
// guessed. Back on the map it was saved on it goes straight to where it was
// saved instead, which is also where it was asked for.
if ([_preset] call ALIVE_fnc_presetPlaceClick) exitWith { true };

// No editor display to click on, which should not happen, but placing it
// somewhere beats refusing with nothing said.
([_preset] call ALIVE_fnc_presetPlace) params ["_placed", "_settings", "_links", "_skipped", ["_areas", 0], ["_renamed", []], ["_trims", []]];

if (_placed == 0) exitWith {
    private _none = format ["Everything in that preset is already in this scenario, so nothing was added: %1.", _skipped joinString ", "];
    [_none, 1, 10] call BIS_fnc_3DENNotification;
    // Logged like every other outcome. Without this the one case that does
    // nothing is also the one case that leaves no trace, which is exactly the
    // case somebody reporting "it did nothing" will be in.
    ["ALIVE_fnc_presetLoad - %1", _none] call ALiVE_fnc_dump;
    false
};

private _msg = format ["Preset placed: %1 module%2, %3 setting%4, %5 sync line%6.",
    _placed, ["s", ""] select (_placed == 1),
    _settings, ["s", ""] select (_settings == 1),
    _links, ["s", ""] select (_links == 1)];
if (_areas > 0) then {
    _msg = _msg + format [" %1 area%2 came with it.", _areas, ["s", ""] select (_areas == 1)];
};
// An area that had to come in under another name is worth saying. It works,
// because the modules were pointed at the new name, but the person would
// otherwise find something in their scenario called what they never called it.
if (count _renamed > 0) then {
    _msg = _msg + format [" That name was taken, so: %1.", _renamed joinString ", "];
};
// Cut down because it was drawn on a bigger map than this one.
if (count _trims > 0) then {
    _msg = _msg + format [" Too big for this map, so trimmed to fit: %1.", _trims joinString ", "];
};

if (count _skipped > 0) then {
    _msg = _msg + format [" Already in this scenario, so not added again: %1.", _skipped joinString ", "];
};

private _mods = _preset select 5;
if (_mods isEqualType [] && {count _mods > 0}) then {
    private _running = activatedAddons apply { toLower _x };
    private _missing = _mods select { !((toLower _x) in _running) };
    if (count _missing > 0) then {
        // Named by the MOD where the preset recorded one, because "rhsusf_c_weapons
        // is not loaded" tells somebody nothing they can act on, and "RHS: United
        // States Forces" tells them exactly what to go and get. The record was
        // written by whoever made the preset, on a machine that had it, which is
        // why it can be named here at all.
        private _said = [];
        {
            private _addons = (_x param [3, []]) apply { toLower _x };
            if ((_addons arrayIntersect (_missing apply { toLower _x })) isNotEqualTo []) then {
                _said pushBackUnique (_x select 0);
            };
        } forEach (_preset param [8, []]);

        // Anything the record could not account for still gets said, under its
        // addon name. Half an answer beats dropping the other half silently.
        private _named = [];
        { _named append ((_x param [3, []]) apply { toLower _x }) } forEach (_preset param [8, []]);
        private _rest = _missing select { !((toLower _x) in _named) };

        _msg = _msg + format [" This preset expects %1, which is not loaded.",
            (_said + _rest) joinString ", "];
    };
};

[_msg, 0, 12] call BIS_fnc_3DENNotification;
["ALIVE_fnc_presetLoad - %1", _msg] call ALiVE_fnc_dump;

true
