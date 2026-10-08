/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_advciv_saveStateToProfile
Description:
    Serialises the current AdvCiv runtime state of a civilian unit into a
    key-value array suitable for persistence via the ALiVE profile system.
    Captures the unit's behavioural state, home position, current hiding
    position, accumulated near-shot stress counter, and the timestamp of the
    last heard shot. The returned array can be stored against the unit's
    profile entry and restored on respawn or unit re-activation.
Parameters:
    _this select 0: OBJECT - The civilian unit whose state should be saved
Returns:
    ARRAY - Array of [key, value] pairs representing the saved state,
            or an empty array if the unit is null
See Also:
    ALIVE_fnc_advciv_initUnit
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params [["_unit", objNull]];

if (isNull _unit) exitWith {[]};

private _state = [
    ["ALiVE_advciv_state",          _unit getVariable ["ALiVE_advciv_state",          "CALM"]],
    ["ALiVE_advciv_homePos",        _unit getVariable ["ALiVE_advciv_homePos",        getPos _unit]],
    ["ALiVE_advciv_hidingPos",      _unit getVariable ["ALiVE_advciv_hidingPos",      []]],
    ["ALiVE_advciv_nearShots",      _unit getVariable ["ALiVE_advciv_nearShots",      0]],
    ["ALiVE_advciv_lastShotTime",   _unit getVariable ["ALiVE_advciv_lastShotTime",   0]]
];

// Per-civ perceived-hostility offset for the civHostilityIndicator attribute, rolled the first time
// someone talks to this civilian. Saved only once it has been rolled: saving a stand-in 0 for a civilian
// nobody has spoken to would bring it back as a real 0 and the roll would never happen. Read back by
// ALIVE_fnc_civilianAgent when the civilian is next spawned.
if !(isNil {_unit getVariable "ALiVE_CivPop_PerceivedOffset"}) then {
    _state pushBack ["ALiVE_CivPop_PerceivedOffset", _unit getVariable "ALiVE_CivPop_PerceivedOffset"];
};

_state
