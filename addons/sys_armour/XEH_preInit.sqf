#include "script_component.hpp"
/*
    sys_armour preInit: the ALiVE Addon Options for the armour sets.
    A set's options appear only when its mod is loaded, and a set is on by
    default once they do; a server forces them for all players. Changes apply
    on the next mission start, because ACE keeps the values for the whole
    mission.

    Author: Jman
*/

LOG(MSG_INIT);

if ((["rhs_main", "rhsusf_main", "rhsgref_main", "rhssaf_main"] findIf {isClass (configFile >> "CfgPatches" >> _x)}) > -1) then {
    private _category = [localize "STR_ALIVE_SETTINGS_CATEGORY", localize "STR_ALIVE_ARMOUR_CATEGORY"];

    [
        "ALiVE_armour_rhs", "CHECKBOX",
        [localize "STR_ALIVE_ARMOUR_RHS", localize "STR_ALIVE_ARMOUR_RHS_COMMENT"],
        _category, true, 1, {}, true
    ] call CBA_fnc_addSetting;

    [
        "ALiVE_armour_rhsAmmo", "CHECKBOX",
        [localize "STR_ALIVE_ARMOUR_RHSAMMO", localize "STR_ALIVE_ARMOUR_RHSAMMO_COMMENT"],
        _category, true, 1, {}, true
    ] call CBA_fnc_addSetting;

    [
        "ALiVE_armour_rhsAps", "LIST",
        [localize "STR_ALIVE_ARMOUR_RHSAPS", localize "STR_ALIVE_ARMOUR_RHSAPS_COMMENT"],
        _category,
        [["rhs", "limited", "off"], [localize "STR_ALIVE_ARMOUR_RHSAPS_RHS", localize "STR_ALIVE_ARMOUR_RHSAPS_LIMITED", localize "STR_ALIVE_ARMOUR_RHSAPS_OFF"], 0],
        1, {}, true
    ] call CBA_fnc_addSetting;

    [
        "ALiVE_armour_rhsApsCharges", "SLIDER",
        [localize "STR_ALIVE_ARMOUR_RHSAPSCHARGES", localize "STR_ALIVE_ARMOUR_RHSAPSCHARGES_COMMENT"],
        _category, [1, 10, 4, 0], 1, {}, true
    ] call CBA_fnc_addSetting;
};
