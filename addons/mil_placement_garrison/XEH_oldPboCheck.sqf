#include "script_component.hpp"

// This addon used to be mil_placement_spe.pbo. An install updated by hand can still hold the old
// PBO beside this one, and its older config then mixes with this addon's. That old PBO is the only
// place this file can come from, so finding it means the old PBO is loaded.
if !(fileExists "\x\alive\addons\mil_placement_spe\fnc_SPEMP.sqf") exitWith {};

private _msg = "ALiVE: the old mil_placement_spe.pbo is still installed beside mil_placement_garrison.pbo. Close Arma and delete mil_placement_spe.pbo (and its .bisign) from the ALiVE addons folder.";
diag_log format ["ALiVE WARNING: %1", _msg];
if (hasInterface) then {
    _msg spawn {
        sleep 15;
        systemChat _this;
        hint _this;
    };
};
