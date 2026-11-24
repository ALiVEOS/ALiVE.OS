#include "\x\alive\addons\sys_player\script_component.hpp"
SCRIPT(playerKey);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_playerKey

Description:
The key a player's saved state is kept under. By player (the default) it is his
player ID, as it always was. By slot (Player Options' Persist By, NeisAEL on
Discord, 17 Oct) it is the slot he plays, by the unit's Eden variable name, so
whoever takes that slot next session gets its kit, place and health. A slot
with no name falls back to the player's ID, said once in the log. Only the
name: a role description can be shared between slots, and which of them was
filled would change the key from one moment to the next. By player and side
(arismagicgr on GitHub, #1144) it is his player ID and the side of the unit's
class, so a player who plays both sides of a TvT campaign has one save for each.
The side comes from the class's config, which stays the same while the unit is
dead or the player is dropping.

Parameters:
Object - the player's unit
String - his player ID, when the unit no longer gives it (a player dropping)

Returns:
String - the key

Author:
Jman
---------------------------------------------------------------------------- */

params [["_unit", objNull], ["_uid", ""]];

if (_uid isEqualTo "" && {!isNull _unit}) then { _uid = getPlayerUID _unit };
private _mode = if (isNil QMOD(sys_player)) then { "player" } else { MOD(sys_player) getVariable ["persistBy", "player"] };
if (isNull _unit || {!(_mode in ["slot", "side"])}) exitWith { _uid };

if (_mode == "side") exitWith {
    if (_uid isEqualTo "") exitWith { _uid };
    _uid + ":" + (["east", "west", "guer", "civ"] param [getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side"), "civ"])
};

private _name = vehicleVarName _unit;
if (_name != "") exitWith { "slot:" + _name };

if !(_unit getVariable [QGVAR(slotKeyWarned), false]) then {
    _unit setVariable [QGVAR(slotKeyWarned), true];
    ["SYS_PLAYER - persisting by slot, but %1's slot has no variable name, so it is saved by player instead. Name the playable units in Eden.", name _unit] call ALiVE_fnc_dump;
};
_uid
