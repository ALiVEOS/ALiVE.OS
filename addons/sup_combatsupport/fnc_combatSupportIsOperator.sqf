/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_combatSupportIsOperator

Description:
Returns whether the LOCAL player is allowed to operate (call) Combat Support.

The Combat Support module's "Support Access" attribute (combatsupport_singleoperator)
decides who may call support from the tablet:
  - "All players": every tablet-holder may -- always returns true.
  - "First player only" (default): one operator per side. The server owns the slot and keeps
    it filled (fnc_combatSupport.sqf); this returns true only for the player whose
    UID currently holds the slot for their side. If that player leaves, the server
    hands the slot to another same-side player, so this starts returning true for
    the new holder (#940 follow-up).

Runs on the client: used as both the tablet menu-visibility gate
(fnc_combatSupportMenuDef) and the confirm-button dispatch gate (fn_*ConfirmButton).

Parameters:
none

Returns:
Boolean - true if the local player may operate Combat Support

Examples:
(begin example)
if !(call ALIVE_fnc_combatSupportIsOperator) exitWith { hint localize "STR_ALIVE_CS_NOTOPERATOR"; };
(end)

Author:
Jman
---------------------------------------------------------------------------- */

if (isNil "NEO_radioLogic") exitWith { false };

private _singleOperator = NEO_radioLogic getVariable ["combatsupport_singleoperator", true];
// Combo attr: BOOL when binarised, "0"/"1" STRING on -packonly dev builds. Normalise.
if !(_singleOperator isEqualType true) then { _singleOperator = parseNumber format ["%1", _singleOperator] > 0; };

// All-players mode -- everyone may operate.
if (!_singleOperator) exitWith { true };

// First-player-only mode -- must currently hold the per-side operator slot.
private _ownerUID = NEO_radioLogic getVariable [format ["CS_operatorUID_%1", playerSide], ""];
(_ownerUID != "") && {getPlayerUID player == _ownerUID}
