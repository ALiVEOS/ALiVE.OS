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

class CfgALiVEPresets {
    // Settings a preset never carries, by the attribute's own name, whichever
    // module it belongs to. Read here by the editor side and by the tooling that
    // reviews a submission, so there is one list rather than two that drift.
    //
    // The first six name something that exists only in the scenario they came
    // from: an area marker, a blacklist marker, an airspace, an ingress point,
    // the two ends of a hand-typed runway. A name that means nothing on the
    // recipient's map is worse than an obvious gap, because the module comes up
    // looking configured and does nothing.
    //
    // The last is the one setting that holds script rather than data. A preset is
    // read as data and nothing in it can run, and carrying a per-spawn hook would
    // hand that property away.
    skipAttributes[] = {
        "taor",
        "blacklist",
        "airspace",
        "ingressMarker",
        "runwaystartpos",
        "runwayendpos",
        "onEachSpawn"
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

            class ALIVE_SharePreset {
                text = "$STR_ALIVE_PRESETS_SHARE";
                conditionShow = "selectedLogicModule";
                action = "[] call ALIVE_fnc_presetShare;";
            };

            class ALIVE_LoadPreset {
                text = "$STR_ALIVE_PRESETS_LOAD";
                action = "[] call ALIVE_fnc_presetLoad;";
            };
        };
    };
};
