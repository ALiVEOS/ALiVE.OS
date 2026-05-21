#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(removeActionIED);

params [
	"_object",
	"_actionID"
];

if (!(hasInterface)) exitWith {};

// Add action to IED
private _debug = (ADDON getVariable ["debug", false]);

if (_debug) then {["removeActionIED running."] call ALiVE_fnc_dump;};

_object removeAction _actionID;

_object call ALiVE_fnc_aceMenu_removeActionIED;
