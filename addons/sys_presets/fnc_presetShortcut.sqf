#include "script_component.hpp"
SCRIPT(presetShortcut);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_presetShortcut

Description:
Makes the preset window's keyboard shortcut work in the Eden editor, which is
the only place it is any use and the one place CBA cannot reach.

Read out of CBA's own source rather than guessed at: CBA installs its key
handlers on three displays and no others, in addons/events, being
fnc_initDisplayMission, fnc_initDisplayMainMap and fnc_initDisplayCurator. There
is no 3DEN equivalent, so a keybind registered with CBA_fnc_addKeybind exists,
appears in Configure Addons, saves what you set, and then never fires while you
are in the editor. Nothing is misconfigured; it is simply not wired there.

So the keybind stays registered, purely for the part CBA is good at: the UI to
choose a combination, and remembering it. The dispatch happens here instead, on
the editor's own display, reading whatever CBA has stored. Somebody who remaps
the key in that dialog gets what they chose without this needing to know.

The editor's display comes and goes as somebody enters and leaves Eden, so this
waits for it, hooks it, waits for it to go away, and waits again. One findDisplay
a second while idle, which is nothing.

Parameters:
    None.

Returns:
    Nothing.

Examples:
    (begin example)
    [] call ALIVE_fnc_presetShortcut;
    (end)

See Also:
    ALIVE_fnc_presetWindow

Author:
    Jman
---------------------------------------------------------------------------- */

if (!hasInterface) exitWith {};

// What the person has bound, asked for at the moment the key is pressed rather
// than remembered here, so remapping takes effect without a restart. Element 8
// of CBA's answer is every combination bound to the action, not just the first.
ALIVE_fnc_presetShortcutKey = {
    params ["", ["_key", -1], ["_shift", false], ["_ctrl", false], ["_alt", false]];

    private _entry = ["ALiVE", "presetWindow"] call CBA_fnc_getKeybind;
    if (isNil "_entry") exitWith { false };

    private _bound = _entry param [8, []];
    private _hit = _bound findIf {
        _x params [["_dik", -1], ["_mods", [false, false, false]]];
        _dik isEqualTo _key
            && {(_mods param [0, false]) isEqualTo _shift}
            && {(_mods param [1, false]) isEqualTo _ctrl}
            && {(_mods param [2, false]) isEqualTo _alt}
    };
    if (_hit < 0) exitWith { false };

    [] call ALIVE_fnc_presetWindow;
    // Swallowed, so the editor does not also act on a key that was meant for us.
    true
};

[] spawn {
    while { true } do {
        // uiSleep, not sleep: the editor is not running a mission, so mission
        // time does not move and a sleep here would wait on a clock that never
        // ticks.
        waitUntil { uiSleep 1; !isNull (findDisplay 313) };

        private _eden = findDisplay 313;
        _eden displayAddEventHandler ["KeyDown", { _this call ALIVE_fnc_presetShortcutKey }];
        ["ALIVE_fnc_presetShortcut - the editor shortcut is live on this session"] call ALiVE_fnc_dump;

        // Hooked once per visit to the editor. Waiting for the display to go
        // again is what stops a second handler being stacked on the same one.
        waitUntil { uiSleep 1; isNull (findDisplay 313) };
    };
};
