#include "script_component.hpp"

#include "CfgPatches.hpp"
#include "CfgFunctions.hpp"

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
};

class ctrlMenu;
class display3DEN {
    class ContextMenu: ctrlMenu {
        class Items {
            class ALIVE_Menu {
                items[] += {"ALIVE_SharePreset"};
            };

            class ALIVE_SharePreset {
                text = "$STR_ALIVE_PRESETS_SHARE";
                conditionShow = "selectedLogicModule";
                action = "[] call ALIVE_fnc_presetShare;";
            };
        };
    };
};
