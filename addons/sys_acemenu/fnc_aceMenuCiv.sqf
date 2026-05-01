#include "\x\alive\addons\sys_acemenu\script_component.hpp"

SCRIPT(aceMenuCiv);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_aceMenuCiv
Description:
    Registers the civilian-interaction ACE interact menu branch on
    CAManBase, filtered to civilian targets. Verbs mirror the dialog's
    consolidated verb surface in ALiVE_fnc_civInteract. The branch is
    arranged as a shallow hierarchy so it fits within ACE's vertical
    cursor-reach limit:

        ALiVE
          |-- Talk                 (opens the dialog)
          |-- Commands
          |    |-- Follow Me
          |    |-- Stay Here
          |    |-- Go Home
          |    |-- Get In Vehicle
          |    |-- Go Away
          |    `-- Stop
          |-- Coercion
          |    |-- Hands Up
          |    |-- Calm Down
          |    |-- Kneel
          |    |-- Get Down
          |    `-- Detain / Release
          `-- Intel
               |-- Negotiate
               `-- Gather Intel

    Civilian identification uses the class CONFIG side (CfgVehicles side
    == 3) rather than the unit's runtime side. This matters because
    Follow / Detain join the civilian to the player's group, which
    reassigns the runtime side to the player's faction and would
    otherwise hide the branch on any subsequent ACE open against the
    same civilian.

    Registration is gated on the amb_civ_population civilianInteractionUI
    attribute. Only fires when the resolved mode is AUTO or ACE - in
    DIALOG / CLASSIC modes the scroll-wheel addAction path in
    fnc_addCivilianInteraction handles player access.

Parameters:
    None

See Also:
    addons/amb_civ_population/fnc_civInteract.sqf (shared verb surface
        that every action here dispatches through)

Author:
    Jman
---------------------------------------------------------------------------- */

// Wait for the amb_civ_population civilian interaction handler to come up.
// Bail if it never arrives - there is nothing to wire into.
private _waitStart = diag_tickTime;
waitUntil {
    !isNil "ALiVE_civInteractHandler" || {diag_tickTime - _waitStart > 120}
};
if (isNil "ALiVE_civInteractHandler") exitWith {
    ["ALiVE_sys_acemenu Civilian: civInteractHandler not found after 120s; skipping ACE branch"] call ALiVE_fnc_dump;
};

// Gate on the UI mode attribute. AUTO + ACE proceed; CLASSIC + DIALOG
// leave the addAction path in fnc_addCivilianInteraction in charge.
private _uiMode = missionNamespace getVariable ["ALiVE_amb_civ_population_UIMode", "AUTO"];
if !(_uiMode in ["AUTO", "ACE"]) exitWith {
    ["ALiVE_sys_acemenu Civilian: UI mode is %1; skipping ACE branch", _uiMode] call ALiVE_fnc_dump;
};

// Base condition: alive + CONFIG side is civilian (side 3) + not advciv-
// blacklisted. Config side is used instead of runtime side because Follow
// and Detain reassign the civilian to the player's group at runtime, which
// would otherwise hide the branch for that unit on subsequent opens.
private _baseCond = {
    alive _target &&
    {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
    {!(_target getVariable ["ALiVE_advciv_blacklist", false])}
};

// Hostility-tier gate: hide actions whose effective hostility band has
// the civ refusing the interaction. Mirrors the dialog's tier-driven
// grey-out (case "loadData" in fnc_civInteract) so the same civ shows
// the same available actions whether the player uses ACE or the dialog.
//   _condBelowDefiant: visible only when h < 60 - hidden at Defiant+.
//                      Used for cooperative / order-style actions.
//   _condBelowHostile: visible only when h < 80 - hidden only at Hostile.
//                      Used for Calm Down (Defiant still allows the
//                      de-escalation attempt; Hostile locks it out).
// Talk, Go Away, Go Home, and Detain stay on the base condition only -
// they are the always-available exits / coercive actions.
private _condBelowDefiant = {
    alive _target &&
    {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
    {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
    {[_target, 60] call ALiVE_fnc_civAceTierGate}
};
private _condBelowHostile = {
    alive _target &&
    {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
    {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
    {[_target, 80] call ALiVE_fnc_civAceTierGate}
};

// ------------------------------------------------------------------------
// Root: ALiVE submenu on civilian targets, under ACE's standard target-
// action parent (ACE_MainActions). Inheritance flag (true) is essential
// so the action propagates from CAManBase down to the concrete civilian
// classnames players actually interact with (C_man_1, C_Driver_1_F, ...).
// ------------------------------------------------------------------------
private _root = [
    "ALiVE_Civilian", "ALiVE", QMENUICON(main), {}, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, ["ACE_MainActions"], _root, true] call ace_interact_menu_fnc_addActionToClass;

private _pAlive    = ["ACE_MainActions", "ALiVE_Civilian"];
private _pCmd      = _pAlive + ["ALiVE_Civ_Commands"];
private _pCoercion = _pAlive + ["ALiVE_Civ_Coercion"];
private _pIntel    = _pAlive + ["ALiVE_Civ_Intel"];

// ------------------------------------------------------------------------
// Submenu containers (empty-action nodes that group verbs below them).
// ------------------------------------------------------------------------
private _cmdRoot = [
    "ALiVE_Civ_Commands", "Commands", "", {}, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pAlive, _cmdRoot, true] call ace_interact_menu_fnc_addActionToClass;

private _coercionRoot = [
    "ALiVE_Civ_Coercion", "Coercion", "", {}, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pAlive, _coercionRoot, true] call ace_interact_menu_fnc_addActionToClass;

private _intelRoot = [
    "ALiVE_Civ_Intel", "Intel", "", {}, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pAlive, _intelRoot, true] call ace_interact_menu_fnc_addActionToClass;

// ------------------------------------------------------------------------
// Top-level leaf: Talk (opens the dialog). Mirrors fnc_addCivilianInteraction's
// non-classic behaviour so ACE users land in the same dialog UI.
// ------------------------------------------------------------------------
private _a = [
    "ALiVE_Civ_Talk", "Talk", "",
    { [ALiVE_civInteractHandler, "openMenu", _target] call ALiVE_fnc_civInteract },
    _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pAlive, _a, true] call ace_interact_menu_fnc_addActionToClass;

// ------------------------------------------------------------------------
// Commands submenu
// ------------------------------------------------------------------------
_a = ["ALiVE_Civ_Follow", "Follow Me", "",
    { [ALiVE_civInteractHandler, "Follow", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

_a = ["ALiVE_Civ_Stay", "Stay Here", "",
    { [ALiVE_civInteractHandler, "StayHere", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Go Home stays on the base condition - always-available exit (sends
// civ back to home pos), part of the Hostile / Defiant active set.
_a = ["ALiVE_Civ_GoHome", "Go Home", "",
    { [ALiVE_civInteractHandler, "GoHome", _target] call ALiVE_fnc_civInteract }, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Get In - visible only when the civ is on foot AND an empty unlocked
// LandVehicle is within 50 m. Below-Defiant tier-gated. The two
// context conditions are merged into one closure so ACE can re-evaluate
// each menu open as the civ / nearby vehicles move.
_a = ["ALiVE_Civ_GetIn", "Get In Vehicle", "",
    { [ALiVE_civInteractHandler, "GetInVehicle", _target] call ALiVE_fnc_civInteract },
    {
        alive _target &&
        {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
        {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
        {[_target, 60] call ALiVE_fnc_civAceTierGate} &&
        {vehicle _target == _target} &&
        {
            // Match the react GETIN target search - any alive movable
            // LandVehicle in range. Locked / full filtering is handled
            // by the brain-tick GETIN cancel path, not here.
            (count (nearestObjects [_target, ["LandVehicle"], 50] select {
                alive _x && {canMove _x}
            })) > 0
        }
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Get Out - visible only when the civ is in a vehicle. Below-Defiant
// tier-gated. Same dispatch endpoint as Get In; case "GetInVehicle"
// in fnc_civInteract toggles between GETIN / GETOUT based on the
// civ's vehicle state.
_a = ["ALiVE_Civ_GetOut", "Get Out Vehicle", "",
    { [ALiVE_civInteractHandler, "GetInVehicle", _target] call ALiVE_fnc_civInteract },
    {
        alive _target &&
        {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
        {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
        {[_target, 60] call ALiVE_fnc_civAceTierGate} &&
        {vehicle _target != _target}
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Go Away stays on the base condition - always-available exit (dismiss
// civ), part of the Hostile / Defiant active set.
_a = ["ALiVE_Civ_GoAway", "Go Away", "",
    { [ALiVE_civInteractHandler, "goAway", _target] call ALiVE_fnc_civInteract }, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

_a = ["ALiVE_Civ_Stop", "Stop", "",
    { [ALiVE_civInteractHandler, "Stop", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCmd, _a, true] call ace_interact_menu_fnc_addActionToClass;

// ------------------------------------------------------------------------
// Coercion submenu
// ------------------------------------------------------------------------
_a = ["ALiVE_Civ_HandsUp", "Hands Up", "",
    { [ALiVE_civInteractHandler, "HandsUp", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCoercion, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Calm Down is hidden only at Hostile - Defiant still allows the
// de-escalation attempt.
_a = ["ALiVE_Civ_Calm", "Calm Down", "",
    { [ALiVE_civInteractHandler, "CalmDown", _target] call ALiVE_fnc_civInteract }, _condBelowHostile
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCoercion, _a, true] call ace_interact_menu_fnc_addActionToClass;

_a = ["ALiVE_Civ_Kneel", "Kneel", "",
    { [ALiVE_civInteractHandler, "Kneel", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCoercion, _a, true] call ace_interact_menu_fnc_addActionToClass;

_a = ["ALiVE_Civ_GetDown", "Get Down", "",
    { [ALiVE_civInteractHandler, "getDown", _target] call ALiVE_fnc_civInteract }, _condBelowDefiant
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCoercion, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Detain stays on the base condition - always-available coercive
// action, part of both Defiant and Hostile active sets.
_a = ["ALiVE_Civ_Detain", "Detain / Release", "",
    { [ALiVE_civInteractHandler, "Detain", _target] call ALiVE_fnc_civInteract }, _baseCond
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pCoercion, _a, true] call ace_interact_menu_fnc_addActionToClass;

// ------------------------------------------------------------------------
// Intel submenu
// ------------------------------------------------------------------------
// Negotiate - role-gated AND tier-gated. Hidden at Defiant+ (h>=60).
_a = ["ALiVE_Civ_Negotiate", "Negotiate", "",
    { [ALiVE_civInteractHandler, "Negotiate", _target] call ALiVE_fnc_civInteract },
    {
        alive _target &&
        {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
        {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
        {[_target, 60] call ALiVE_fnc_civAceTierGate} &&
        {
            (_target getVariable ["townelder", false]) ||
            {_target getVariable ["major", false]} ||
            {_target getVariable ["priest", false]} ||
            {_target getVariable ["muezzin", false]} ||
            {_target getVariable ["politician", false]}
        }
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pIntel, _a, true] call ace_interact_menu_fnc_addActionToClass;

// Gather Intel - one-shot per civilian (mirrors the original 10%
// addAction's intelGathered flag) AND tier-gated. Hidden at Defiant+.
_a = ["ALiVE_Civ_GatherIntel", "Gather Intel", "",
    { [ALiVE_civInteractHandler, "GatherIntel", _target] call ALiVE_fnc_civInteract },
    {
        alive _target &&
        {(getNumber (configFile >> "CfgVehicles" >> typeOf _target >> "side")) == 3} &&
        {!(_target getVariable ["ALiVE_advciv_blacklist", false])} &&
        {[_target, 60] call ALiVE_fnc_civAceTierGate} &&
        {isNil {_target getVariable "intelGathered"}}
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, _pIntel, _a, true] call ace_interact_menu_fnc_addActionToClass;

["ALiVE_sys_acemenu Civilian: registered hierarchical branch on CAManBase (UIMode=%1)", _uiMode] call ALiVE_fnc_dump;
