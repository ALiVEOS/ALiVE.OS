#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(COPApplyTier);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_COPApplyTier

Description:
    Applies a COP feature/layer preset based on the commanderIntelMode Eden
    attribute. Each preset uses `if (isNil ...)` guards so any ALIVE_COP_*
    override set by the mission's init.sqf BEFORE module init is preserved
    — the tier presets only fill in defaults for unset globals.

    Tiers (most → least visibility):
      Advanced — no overrides; honours every default from fnc_COPConfig.sqf.
      Full     — disables Tier-3 features (TRAIL, THREAT, CONFIDENCE, COMPOSITION)
                 and the OBJ axis arrows. Movement vector + threat ring stay on.
      Partial  — disables BFT layer entirely + everything Full disables + MOVEMENT.
                 Only enemy clusters + objective circles remain.
      Basic    — disables ENEMIES + BFT layers + OBJ axis arrows; only objective
                 circles remain (commander's intent without ground truth).
      Off      — master kill switch handled in fnc_C2ISTAR.sqf BEFORE dispatch.
                 If reached here defensively, all four master-layer toggles are
                 forced to false.

Parameters:
    0: STRING - One of "Off" / "Basic" / "Partial" / "Full" / "Advanced".
                Unknown values are treated as Advanced with a warn log.

Returns:
    BOOL - true

Author:
    Goldwep (ALiVE Mod Team)
---------------------------------------------------------------------------- */

params [["_mode", "Off", [""]]];

switch (_mode) do {
    case "Off": {
        // Master kill switch is handled upstream — Off should never reach here.
        // If it does, kill all layers defensively.
        if (isNil "ALIVE_COP_LAYER_ENEMIES")    then { ALIVE_COP_LAYER_ENEMIES    = false };
        if (isNil "ALIVE_COP_LAYER_BFT")        then { ALIVE_COP_LAYER_BFT        = false };
        if (isNil "ALIVE_COP_LAYER_OBJECTIVES") then { ALIVE_COP_LAYER_OBJECTIVES = false };
        if (isNil "ALIVE_COP_LAYER_ASYMMETRIC") then { ALIVE_COP_LAYER_ASYMMETRIC = false };
    };
    case "Basic": {
        if (isNil "ALIVE_COP_LAYER_ENEMIES")    then { ALIVE_COP_LAYER_ENEMIES    = false };
        if (isNil "ALIVE_COP_LAYER_BFT")        then { ALIVE_COP_LAYER_BFT        = false };
        if (isNil "ALIVE_COP_OBJ_AXIS_ARROWS")  then { ALIVE_COP_OBJ_AXIS_ARROWS  = false };
    };
    case "Partial": {
        if (isNil "ALIVE_COP_LAYER_BFT")        then { ALIVE_COP_LAYER_BFT        = false };
        if (isNil "ALIVE_COP_FEAT_TRAIL")       then { ALIVE_COP_FEAT_TRAIL       = false };
        if (isNil "ALIVE_COP_FEAT_THREAT")      then { ALIVE_COP_FEAT_THREAT      = false };
        if (isNil "ALIVE_COP_FEAT_CONFIDENCE")  then { ALIVE_COP_FEAT_CONFIDENCE  = false };
        if (isNil "ALIVE_COP_FEAT_COMPOSITION") then { ALIVE_COP_FEAT_COMPOSITION = false };
        if (isNil "ALIVE_COP_FEAT_MOVEMENT")    then { ALIVE_COP_FEAT_MOVEMENT    = false };
        if (isNil "ALIVE_COP_OBJ_AXIS_ARROWS")  then { ALIVE_COP_OBJ_AXIS_ARROWS  = false };
    };
    case "Full": {
        if (isNil "ALIVE_COP_FEAT_TRAIL")       then { ALIVE_COP_FEAT_TRAIL       = false };
        if (isNil "ALIVE_COP_FEAT_THREAT")      then { ALIVE_COP_FEAT_THREAT      = false };
        if (isNil "ALIVE_COP_FEAT_CONFIDENCE")  then { ALIVE_COP_FEAT_CONFIDENCE  = false };
        if (isNil "ALIVE_COP_FEAT_COMPOSITION") then { ALIVE_COP_FEAT_COMPOSITION = false };
        if (isNil "ALIVE_COP_OBJ_AXIS_ARROWS")  then { ALIVE_COP_OBJ_AXIS_ARROWS  = false };
    };
    case "Advanced": {
        // No overrides — all isNil guards in fnc_COPConfig.sqf preserve current master defaults.
    };
    default {
        ["warn", "config", "COPApplyTier received unknown mode '%1' — treating as Advanced", [_mode]] call ALiVE_fnc_COPLog;
    };
};

true
