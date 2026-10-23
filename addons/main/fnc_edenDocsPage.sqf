#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(edenDocsPage);

/* ----------------------------------------------------------------------------
Function: fnc_edenDocsPage

Description:
The online docs page for an ALiVE module, for the help button in the header of its Eden attributes
window (fnc_edenSectionCollapse.sqf). A module can name its own page with ALiVE_docsPage in its
CfgVehicles class; otherwise the page comes from the table below, which follows the docs site's own
pages (one per module, and a few modules that share one). A module with no page gets "" and no button.

Parameters:
    STRING - the module's class (typeOf)

Returns:
    STRING - the page's address, or "" when the module has no page

Examples:
    ["ALiVE_mil_opcom"] call compile preprocessFileLineNumbers '\x\alive\addons\main\fnc_edenDocsPage.sqf';
    // "https://www.alivemod.com/alive3/mil_opcom.htm"

Author:
Jman
---------------------------------------------------------------------------- */

params [["_class", "", [""]]];

// the docs address is written out where it is used: a "//" inside a #define is read as a comment

private _page = getText (configFile >> "CfgVehicles" >> _class >> "ALiVE_docsPage");

if (_page isEqualTo "") then {
    private _pages = createHashMapFromArray [
        // every mission
        ["alive_require",                       "alive_required"],
        ["alive_sys_profile",                   "sys_profile_spawner"],
        ["alive_modulevirtualise",              "sys_profile_spawner"],
        // placement
        ["alive_mil_placement",                 "mil_placement"],
        ["alive_civ_placement",                 "civ_placement"],
        ["alive_mil_placement_custom",          "mil_placement_custom"],
        ["alive_civ_placement_custom",          "civ_placement_custom"],
        ["alive_mil_placement_spe",             "mil_placement_spe"],
        // commanders and what serves them
        ["alive_mil_opcom",                     "mil_opcom"],
        ["alive_mil_logistics",                 "mil_logistics"],
        ["alive_mil_artillery",                 "mil_artillery"],
        ["alive_mil_ato",                       "mil_ato"],
        ["alive_mil_cqb",                       "mil_cqb"],
        ["alive_mil_ied",                       "mil_ied"],
        ["alive_mil_c2istar",                   "mil_c2istar"],
        // the old intelligence modules, hidden from the editor, are covered on the Intelligence page
        ["alive_mil_intelligence",              "mil_intelligence"],
        ["addon2",                              "mil_intelligence"],
        ["addon3",                              "mil_intelligence"],
        // civilians
        ["alive_amb_civ_placement",             "amb_civ_placement"],
        ["alive_amb_civ_population",            "amb_civ_population"],
        // player support
        ["alive_sup_combatsupport",             "sup_combatsupport"],
        ["alive_sup_cas",                       "sup_cas"],
        ["alive_sup_transport",                 "sup_transport"],
        ["alive_sup_ground",                    "sup_ground"],
        ["alive_sup_artillery",                 "sup_artillery"],
        ["alive_sup_player_resupply",           "sup_player_resupply"],
        ["alive_sup_fob",                       "sup_fob"],
        ["alive_sup_fob_types",                 "sup_fob_types"],
        ["alive_sup_recruit",                   "sup_recruit"],
        ["alive_sup_rally",                     "sup_rally"],
        ["alive_sup_group_manager",             "sup_group_manager"],
        ["alive_sup_multispawn",                "sup_multispawn"],
        ["alive_sup_command",                   "sup_command"],
        // system
        ["alive_sys_logistics",                 "sys_logistics"],
        ["alive_sys_logisticsdisable",          "sys_logistics"],
        ["alive_sys_playeroptions",             "sys_playeroptions"],
        ["alive_sys_tour",                      "sys_tour"],
        ["alive_sys_aiskill",                   "sys_aiskill"],
        ["alive_sys_weather",                   "sys_weather"],
        ["alive_sys_data",                      "sys_data"],
        ["alive_sys_indexer",                   "sys_indexer"],
        ["alive_sys_orbatcreator",              "sys_orbatcreator"],
        ["alive_sys_factioncompiler",           "sys_factioncompiler"],
        ["alive_sys_factioncompiler_category",  "sys_factioncompiler"],
        ["alive_sys_classpicker",               "sys_classpicker"],
        ["alive_sys_adminactions",              "sys_adminactions"],
        ["alive_sys_crewinfo",                  "sys_crewinfo"],
        ["alive_sys_gc",                        "sys_gc"],
        ["alive_sys_marker",                    "sys_marker"],
        ["alive_sys_newsfeed",                  "sys_newsfeed"],
        ["alive_sys_patrolrep",                 "sys_patrolrep"],
        ["alive_sys_player",                    "sys_player"],
        ["alive_sys_playertags",                "sys_playertags"],
        ["alive_sys_sitrep",                    "sys_sitrep"],
        ["alive_sys_spotrep",                   "sys_spotrep"],
        ["alive_sys_statistics",                "sys_statistics"],
        ["alive_sys_viewdistance",              "sys_viewdistance"],
        ["alive_sys_xstream",                   "sys_xstream"],
        // the Quick Start module's class is plain "ALiVE"
        ["alive",                               "sys_quickstart"]
    ];
    _page = _pages getOrDefault [toLower _class, ""];
};

if (_page isEqualTo "") exitWith { "" };
"https://www.alivemod.com/alive3/" + _page + ".htm"
