#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(placementSideNumber);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_placementSideNumber

Description:
The side number a placement module places a faction on: its config side (0 EAST, 1 WEST,
2 GUER, 3 CIV), except in the Outbreak game mode, where a faction listed as zombies on the
Virtual AI module goes on the zombie side, a civilian faction included.

Parameters:
String - faction class name

Returns:
Scalar - side number

Examples:
(begin example)
_sideNumber = "CIV_F" call ALiVE_fnc_placementSideNumber;
(end)

See Also:
ALiVE_fnc_factionSide

Author:
Jman
---------------------------------------------------------------------------- */

private _faction = _this;
if (_faction isEqualType []) then { _faction = _faction param [0, ""] };
if !(_faction isEqualType "") exitWith { 0 };

if ((missionNamespace getVariable ["ALiVE_GAMEMODE", ""]) == "outbreak" && {(toLower _faction) in (missionNamespace getVariable ["ALiVE_zombieFactions", []])}) exitWith {
    (["EAST", "WEST", "GUER"] find (toUpper (missionNamespace getVariable ["ALiVE_ZOMBIESIDE", "EAST"]))) max 0
};

getNumber ((_faction call ALiVE_fnc_configGetFactionClass) >> "side")
