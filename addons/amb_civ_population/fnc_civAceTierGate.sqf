#include "\x\alive\addons\amb_civ_population\script_component.hpp"
SCRIPT(civAceTierGate);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_civAceTierGate
Description:
    Tier-gate predicate for ACE interact menu entries on civilians.
    Returns true when the civilian's effective hostility is BELOW the
    given threshold, i.e. when the entry should remain visible.

    Reads the same source-of-truth the dialog (case "loadData") and the
    approach gesture both use: the higher of per-civ `ALiVE_CivPop_
    Hostility` and the module's per-side baseline from
    `ALIVE_civilianHostility` for the player's side. So whichever access
    path the player uses, the same civilian shows the same available
    actions.

    The companion ACE menu in addons/sys_acemenu/fnc_aceMenuCiv.sqf
    gates each restricted entry with `&& {[_target, N] call
    ALiVE_fnc_civAceTierGate}` where N is the tier ceiling (60 for
    actions hidden at Defiant+, 80 for Calm Down which is hidden only
    at Hostile). Talk remains always visible because the dialog it
    opens is itself tier-gated.

Parameters:
    _this select 0: OBJECT - civilian
    _this select 1: NUMBER - exclusive maximum hostility for visibility
                             (60 = hide at Defiant+, 80 = hide at Hostile)
Returns:
    BOOL - true if civ's effective hostility is < threshold
See Also:
    ALIVE_fnc_civInteract case "loadData", addons/sys_acemenu/fnc_aceMenuCiv.sqf
Author:
    Jman
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_civ", objNull, [objNull]], ["_threshold", 60, [0]]];

if (isNull _civ) exitWith { false };

private _civHostility = _civ getVariable ["ALiVE_CivPop_Hostility", 30];
private _playerSide = str (side (group player));
private _sideBaseline = if (!isNil "ALIVE_civilianHostility") then {
    [ALIVE_civilianHostility, _playerSide, 0] call ALiVE_fnc_hashGet
} else { 0 };
private _h = (_civHostility max _sideBaseline) max 0 min 100;

_h < _threshold
