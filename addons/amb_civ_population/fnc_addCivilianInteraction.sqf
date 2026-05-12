/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_addCivilianInteraction
Description:
    Adds the ALiVE civilian interaction action to a unit. For civilians without
    AdvCiv active, attaches a standalone Interact action linked to the
    ALiVE_civInteractHandler. If the unit already has AdvCiv enabled, no action
    is added here as the Interact option is provided within the AdvCiv order menu.
Parameters:
    _this select 0: OBJECT - The civilian unit to add the interaction to
Returns:
    Nil
See Also:
    ALIVE_fnc_advciv_orderMenu
Author:
    Jman (advanced civs)
Peer Reviewed:
    nil
---------------------------------------------------------------------------- */

params ["_unit"];

// Only proceed if the global interaction handler has been initialised and
// the unit is actually a civilian
if (!isNil "ALiVE_civInteractHandler" && {side _unit == CIVILIAN} && {!(_unit getVariable ["ALiVE_advciv_blacklist", false])}) then {
    private _uiMode = missionNamespace getVariable ["ALiVE_amb_civ_population_UIMode", "AUTO"];
    private _hasAdvCiv = _unit getVariable ["ALiVE_advciv_active", false];

    // Match the range to ALiVE_advciv_orderMenuRange for visual consistency;
    // fall back to 4 m if AdvCiv hasn't set it (module not loaded).
    private _range = if (!isNil "ALiVE_advciv_orderMenuRange") then {
        ALiVE_advciv_orderMenuRange
    } else {
        4
    };
    private _cond = format ["alive _target && !(_target getVariable ['ALiVE_advciv_blacklist', false]) && _this distance _target < %1", _range];

    switch (_uiMode) do {

        // CLASSIC: preserve the pre-Phase-5 behaviour. Non-AdvCiv civilians
        // get a standalone "Interact" addAction; AdvCiv civilians get the
        // Interact option embedded in fnc_advciv_orderMenu's sprawl.
        case "CLASSIC": {
            if (!_hasAdvCiv) then {
                _unit addAction [
                    "Interact",
                    {[ALiVE_civInteractHandler, "openMenu", _this select 0] call ALiVE_fnc_civInteract},
                    "",
                    50,
                    true,
                    false,
                    "",
                    _cond,
                    _range
                ];
            };
        };

        // AUTO / DIALOG / ACE: add a single "Talk to Civilian" entry
        // regardless of AdvCiv state. This replaces the ~15-item scroll-
        // wheel sprawl from fnc_advciv_orderMenu + fnc_addCivilianActions
        // (both early-exit in non-CLASSIC modes) with one discoverable
        // entry point that opens the dialog.
        //   Skip the addAction only when UIMode is ACE (force ACE-only
        //   UX). AUTO keeps BOTH the addAction and the ACE branch
        //   available so players have a scroll-wheel fallback when the
        //   ACE interact menu is awkward to hold on a moving civilian.
        default {
            if (_uiMode != "ACE") then {
                _unit addAction [
                    "Talk to Civilian",
                    {[ALiVE_civInteractHandler, "openMenu", _this select 0] call ALiVE_fnc_civInteract},
                    "",
                    50,
                    true,
                    false,
                    "",
                    _cond,
                    _range
                ];
            };
        };
    };
};
