#include <\x\alive\addons\mil_ied\script_component.hpp>
SCRIPT(addActionIED);

// Add action to IED
private ["_debug"];

_debug = MOD(mil_ied) getVariable ["debug", 0];

if (isServer && _debug) exitWith {diag_log "AddAction running on server!";};

_this addAction ["<t color='#ff0000'>Disarm IED</t>",ALiVE_fnc_disarmIED, "", 6, false, true,"", "_target distance _this < 3"];



