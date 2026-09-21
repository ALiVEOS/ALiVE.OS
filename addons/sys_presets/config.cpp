#include "script_component.hpp"

#include "CfgPatches.hpp"
#include "CfgFunctions.hpp"
// The presets that ship with ALiVE, as compositions the editor lists. Written
// from the .preset files beside this config rather than by hand; see the note at
// the top of that file.
#include "Compositions.hpp"

// Sharing an ALiVE setup as a preset: a line of plain text carrying every ALiVE
// module in the scenario, the settings that were actually chosen, and the sync
// lines between them.
//
// The entry goes in the ALiVE folder sys_classpicker puts at the root of the
// editor's right click menu, beside the class picker's own entries, because this
// is the same kind of thing: something you do to the scenario from the editor.
// The folder and the entry both carry the module condition, the pattern that
// folder already uses, so neither shows on anything that is not a module.

// Submitting a preset from the editor opens the submit page with the preset
// already in it. The engine refuses a link that is not whitelisted here and
// quietly leaves the control holding whatever it had before, saying nothing, so
// this is not optional and its absence would look like a broken button.
class CfgCommands {
    allowedHTMLLoadURIs[] += {
        "*.alivemod.com",
        "*.alivemod.com/*"
    };
};

class CfgALiVEPresets {
    // Settings a preset never carries, by the attribute's own name, whichever
    // module it belongs to. Read here by the editor side and by the tooling that
    // reviews a submission, so there is one list rather than two that drift.
    //
    // All three hold script rather than data, and a preset is read as data
    // precisely so that nothing in it can run. The per-spawn hook is the obvious
    // one. The two runway ends are not obvious at all: they look like place names
    // but they hold a position written as text, and mil_ato does
    // "call compile _runwayStartPos" with it at mission start, so carrying them
    // would hand a stranger's preset a way to run code. They are also absolute
    // coordinates, which no preset can honour on another map.
    skipAttributes[] = {
        "onEachSpawn",
        "runwaystartpos",
        "runwayendpos"
    };

    // Settings that name an area marker. These used to be refused outright, for
    // the good reason that a name meaning nothing on the recipient's map leaves a
    // module looking configured while doing nothing. They are carried now because
    // the marker itself travels with them: a preset that brings its own areas can
    // honour the name it carries.
    //
    // Each is split the way the module that reads it splits it, never with one
    // shared rule: taor and blacklist strip spaces and split on a comma
    // (mil_placement/fnc_MP.sqf), airspace splits on []"', ; (mil_ato), and
    // ingressMarker is a single name with its spaces removed.
    //
    // When a preset is taken without its areas, these go with them. Half of the
    // pair is worse than neither: the placement modules quietly widen to the whole
    // map and mil_ato does not start at all.
    markerAttributes[] = {
        "taor",
        "blacklist",
        "airspace",
        "ingressMarker"
    };

    // The presets that ship with ALiVE, as their own text, so the preset window
    // lists them beside the ones a mission maker has collected and places both
    // the same way. Written from the preset files; included here rather than
    // declared on its own because two declarations of one class at the root do
    // not rapify.
    #include "Shipped.hpp"
};

// The window that lists presets. Only the window is declared: its contents are
// made at run time from the game's own controls, which keeps a screenful of
// control boilerplate out of this config and the layout somewhere it can be read.
class ALiVE_PresetLibrary {
    idd = 88100;
    movingEnable = 1;
    enableSimulation = 1;
    class controls {};
};

class ctrlMenu;
class display3DEN {
    class ContextMenu: ctrlMenu {
        class Items {
            // The folder no longer needs a module under the cursor. Sharing does,
            // and keeps its own condition, but loading a preset is for a scenario
            // with nothing in it yet, and a folder gated on a module would put the
            // entry out of reach in the one case it exists for. The folder can
            // never be empty either way, because loading is always offered.
            //
            // An empty condition is how the editor's own entries say "always", and
            // the class picker's entries keep theirs, so they still only appear
            // when they can do something.
            class ALIVE_Menu {
                conditionShow = "";
                items[] += {"ALIVE_PresetLibrary", "ALIVE_SharePreset", "ALIVE_LoadPreset"};
            };

            class ALIVE_PresetLibrary {
                text = "$STR_ALIVE_PRESETS_LIBRARY";
                action = "[] call ALIVE_fnc_presetWindow;";
            };

            // Opens the chooser rather than copying straight away. A scenario
            // that has been worked on usually holds more than the one setup worth
            // passing on, and being shown what is about to be shared is worth the
            // extra click.
            class ALIVE_SharePreset {
                text = "$STR_ALIVE_PRESETS_SHARE";
                conditionShow = "selectedLogicModule";
                action = "[] call ALIVE_fnc_presetChoose;";
            };

            class ALIVE_LoadPreset {
                text = "$STR_ALIVE_PRESETS_LOAD";
                action = "[] call ALIVE_fnc_presetLoad;";
            };
        };
    };
};
