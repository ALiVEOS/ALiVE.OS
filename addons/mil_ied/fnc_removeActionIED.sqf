#include <\x\alive\addons\mil_ied\script_component.hpp>
SCRIPT(removeActionIED);

// Add action to IED
private ["_debug"];

_debug = ADDON getVariable ["debug", 0];

if (_debug) then {diag_log "RemoveActionIED running.";};

(_this select 0) removeAction (_this select 1);



