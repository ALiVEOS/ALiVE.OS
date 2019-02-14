#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(addActionIED);

if (!(hasInterface)) exitWith {};

// Add action to IED
private _debug = (MOD(mil_ied) getVariable ["debug", 0]);

if (isServer && _debug) then {["addActionIED running."] call ALiVE_fnc_dump};

_this addAction ["<t color='#ff0000'>Disarm IED</t>",ALiVE_fnc_disarmIED, "", 6, false, true,"", "_target distance _this < 3"];

_this call ALiVE_fnc_aceMenu_addActionIED;
