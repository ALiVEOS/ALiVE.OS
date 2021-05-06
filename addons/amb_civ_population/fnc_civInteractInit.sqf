/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_civInteractInit

Description:
Initializes civilian interaction

Parameters:
Object - Module Object
Array - Synchronized units

Returns:
nil

Author:
SpyderBlack723

Peer Reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_moduleID"];
params ["_logic"];

if (count (allMissionObjects "SpyderAddons_civ_interact") > 0) exitWith {["[Civ Interact] Detected Spyders Addon, exiting..."] call ALiVE_fnc_dump};

_enable = call compile (_logic getvariable ["enableInteraction","false"]);
if !(_enable) exitWith {["[Civ Interact] Module has been disabled, exiting"] call ALiVE_fnc_dump};

// Confirm init function available
if (isNil "ALiVE_fnc_civInteract") exitWith {["[Civ Interact] Main function missing"] call ALiVE_fnc_dump};

["[Civ Interact] Initialization starting"] call ALiVE_fnc_dump;

[_logic,"init"] call ALiVE_fnc_civInteract;

["[Civ Interact] Initialization complete"] call ALiVE_fnc_dump;

true
