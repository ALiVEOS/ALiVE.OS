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

[
    ["ALiVE_advciv_state",          _unit getVariable ["ALiVE_advciv_state",          "CALM"]],
    ["ALiVE_advciv_homePos",        _unit getVariable ["ALiVE_advciv_homePos",        getPos _unit]],
    ["ALiVE_advciv_hidingPos",      _unit getVariable ["ALiVE_advciv_hidingPos",      []]],
    ["ALiVE_advciv_nearShots",      _unit getVariable ["ALiVE_advciv_nearShots",      0]],
    ["ALiVE_advciv_lastShotTime",   _unit getVariable ["ALiVE_advciv_lastShotTime",   0]],
    // Per-civ perceived-hostility offset for the civHostilityIndicator
    // attribute. Lazy-initialised on first dialog open against this civ;
    // persists for the lifetime of the unit object so re-opening shows
    // the same perceived value until actual hostility shifts the bucket.
    // Saved via this function for future cross-cycle persistence; the
    // restore-side currently doesn't read advcivState back (pre-existing
    // gap, not blocking Phase 1 - the offset re-initialises on respawn).
    ["ALiVE_CivPop_PerceivedOffset", _unit getVariable ["ALiVE_CivPop_PerceivedOffset", 0]]
]
