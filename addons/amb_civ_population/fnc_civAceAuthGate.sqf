#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civAceAuthGate);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civAceAuthGate
Description:
    Authorisation-gate predicate for ACE interact menu entries on civilians.
    Mirrors the same `_authorized` check the dialog runs at
    `fnc_civInteract.sqf:155` so the ACE menu cannot bypass the
    `limitInteraction` Eden attribute (#895).

    Reads the cached authorized list from the civInteractHandler hash
    (populated in case "create" from `_logic getVariable "limitInteraction"`)
    and tests the local player against each criterion the dialog uses
    (UID / classname / name / faction / rank).

    Behaviour:
      - When the authorized list is empty (no limit configured), returns
        true — all players see the ACE entries, matching the dialog's
        unconditional path.
      - When the list is set, returns true only when the local player
        matches any of the allowed entries — matching the dialog's
        "civilian can't understand what you are saying" gate.

    Companion to `fnc_civAceTierGate.sqf` which gates on hostility.

Parameters:
    None — reads the authorized list from the civInteractHandler hash and
    queries the local `player` directly.

Returns:
    BOOL - true if the local player is authorised to interact

See Also:
    ALIVE_fnc_civInteract case "openMenu", addons/sys_acemenu/fnc_aceMenuCiv.sqf

Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

if (isNil "ALiVE_civInteractHandler") exitWith { true };

private _authorized = [ALiVE_civInteractHandler, "authorized", []] call ALiVE_fnc_hashGet;

if (count _authorized == 0) exitWith { true };

(getPlayerUID player in _authorized)
    || {typeOf player in _authorized}
    || {name player in _authorized}
    || {faction player in _authorized}
    || {rank player in _authorized}
