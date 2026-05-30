#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(addActionIED);

if (!(hasInterface)) exitWith {};

// Add action to IED
private _debug = (MOD(mil_ied) getVariable ["debug", false]);

if (isServer && _debug) then {["addActionIED running."] call ALiVE_fnc_dump};

// Condition hides the action once the container has been disarmed (the
// container stays in the world but the charge has been recovered), and
// only offers it to qualifying engineers / EOD specialists. _this in an
// addAction condition is the caller; ALiVE_mil_ied is the client-side
// module logic carrying the configured detection device.
_this addAction [
    "<t color='#ff0000'>Disarm IED</t>",
    ALiVE_fnc_disarmIED,
    "",
    6,
    false,
    true,
    "",
    "!(_target getVariable ['ALiVE_IED_Disarmed', false]) && {[_this, (ALiVE_mil_ied getVariable ['IED_Detection_Device', 'MineDetector'])] call ALiVE_fnc_iedUnitQualifies}",
    3
];

_this call ALiVE_fnc_aceMenu_addActionIED;
