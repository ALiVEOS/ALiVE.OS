#include "script_component.hpp"

LOG(MSG_INIT);

// A shortcut for the preset window, remappable in Configure Addons under
// Keybinds like every other ALiVE key. 25 is P, and the flags are
// [shift, ctrl, alt] in that order, so this is Ctrl-Alt-P.
//
// NOT Ctrl-Shift-P, which was the first choice and which Arma already uses for
// its own DLC window. That conflict also wasted a test: the key did something,
// so it looked like a result, when in fact Arma had taken the press before
// anything of ours saw it.
//
// The window is where almost everything about presets happens, and the entry
// that opens it sits inside a submenu of the editor's right click menu, which is
// two clicks and a hunt. The menu cannot be reordered without pinning Arma's own
// list of entries into our config, so the key is the honest way to make it quick.
//
// Registered here rather than in the editor, because a keybind has to exist
// before anything can be bound to it and preInit is the only thing that runs
// early enough.
//
// MEASURED: CBA does NOT dispatch a keybind inside the editor, and cannot.
// Reading its source, it installs key handlers on three displays and no others
// (addons/events: initDisplayMission, initDisplayMainMap, initDisplayCurator).
// There is no 3DEN one. So this registration does the half CBA is good at, the
// dialog to choose a combination and remembering it, and ALIVE_fnc_presetShortcut
// does the dispatch on the editor's own display, reading back whatever was set
// here. Remapping in that dialog works without either of them being told.
["ALiVE", "presetWindow", "Open the ALiVE preset window (editor only)", {
    // The editor only. In a mission there is no scenario to place into and no
    // editor display to open a window on, so the key does nothing rather than
    // failing at somebody mid-game.
    if (!is3DEN) exitWith { false };
    [] call ALIVE_fnc_presetWindow;
    true
}, {false}, [25, [false, true, true]]] call CBA_fnc_addKeybind;

// The dispatch half, for the editor. See the note above: the keybind above is
// where the combination is chosen, and this is what makes it fire.
//
// Guarded twice on purpose. preInit runs for an ordinary mission as well as for
// the editor, and the editor-only functions are only compiled in the editor, so
// calling this unguarded would be an undefined function every time anybody
// started a mission.
if (is3DEN && {!isNil "ALIVE_fnc_presetShortcut"}) then {
    [] call ALIVE_fnc_presetShortcut;
};
