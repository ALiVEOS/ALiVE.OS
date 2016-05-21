// rhsgref_faction_cdf_b_ground

rhsgref_faction_cdf_b_ground_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_b_ground_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_b_ground_mappings, "Side", "WEST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "GroupSideName", "WEST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "FactionName", "rhsgref_faction_cdf_b_ground"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_mappings, "GroupFactionName", "rhsgref_faction_cdf_b_ground"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_b_ground_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_b_ground_mappings, "GroupFactionTypes", rhsgref_faction_cdf_b_ground_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_b_ground_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_b_ground_mappings, "Groups", rhsgref_faction_cdf_b_ground_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_b_ground", rhsgref_faction_cdf_b_ground_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_b_ground", []] call ALIVE_fnc_hashSet;

// rhsgref_faction_chdkz

rhsgref_faction_chdkz_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_chdkz_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_mappings, "Side", "EAST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "GroupSideName", "EAST"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "FactionName", "rhsgref_faction_chdkz"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_mappings, "GroupFactionName", "rhsgref_faction_chdkz"] call ALIVE_fnc_hashSet;

rhsgref_faction_chdkz_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_mappings, "GroupFactionTypes", rhsgref_faction_chdkz_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_mappings, "Groups", rhsgref_faction_chdkz_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_chdkz", rhsgref_faction_chdkz_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_chdkz", []] call ALIVE_fnc_hashSet;

// rhsgref_faction_cdf_ground

rhsgref_faction_cdf_ground_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_ground_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ground_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "FactionName", "rhsgref_faction_cdf_ground"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_mappings, "GroupFactionName", "rhsgref_faction_cdf_ground"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_ground_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ground_mappings, "GroupFactionTypes", rhsgref_faction_cdf_ground_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ground_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ground_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ground_mappings, "Groups", rhsgref_faction_cdf_ground_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_ground", rhsgref_faction_cdf_ground_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_ground", []] call ALIVE_fnc_hashSet;

// rhsgref_faction_cdf_ng

rhsgref_faction_cdf_ng_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_cdf_ng_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ng_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "FactionName", "rhsgref_faction_cdf_ng"] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_mappings, "GroupFactionName", "rhsgref_faction_cdf_ng"] call ALIVE_fnc_hashSet;

rhsgref_faction_cdf_ng_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_cdf_ng_mappings, "GroupFactionTypes", rhsgref_faction_cdf_ng_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ng_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_cdf_ng_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_cdf_ng_mappings, "Groups", rhsgref_faction_cdf_ng_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_cdf_ng", rhsgref_faction_cdf_ng_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_cdf_ng", []] call ALIVE_fnc_hashSet;

// rhsgref_faction_chdkz_g

rhsgref_faction_chdkz_g_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_chdkz_g_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_g_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "FactionName", "rhsgref_faction_chdkz_g"] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_mappings, "GroupFactionName", "rhsgref_faction_chdkz_g"] call ALIVE_fnc_hashSet;

rhsgref_faction_chdkz_g_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_chdkz_g_mappings, "GroupFactionTypes", rhsgref_faction_chdkz_g_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_g_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_chdkz_g_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_chdkz_g_mappings, "Groups", rhsgref_faction_chdkz_g_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_chdkz_g", rhsgref_faction_chdkz_g_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_chdkz_g", []] call ALIVE_fnc_hashSet;

// rhsgref_faction_nationalist

rhsgref_faction_nationalist_mappings = [] call ALIVE_fnc_hashCreate;

rhsgref_faction_nationalist_factionCustomGroups = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_nationalist_mappings, "Side", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "GroupSideName", "GUER"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "FactionName", "rhsgref_faction_nationalist"] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_mappings, "GroupFactionName", "rhsgref_faction_nationalist"] call ALIVE_fnc_hashSet;

rhsgref_faction_nationalist_typeMappings = [] call ALIVE_fnc_hashCreate;

[rhsgref_faction_nationalist_mappings, "GroupFactionTypes", rhsgref_faction_nationalist_typeMappings] call ALIVE_fnc_hashSet;

[rhsgref_faction_nationalist_factionCustomGroups, "Infantry", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Motorized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Mechanized", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Armored", []] call ALIVE_fnc_hashSet;
[rhsgref_faction_nationalist_factionCustomGroups, "Artillery", []] call ALIVE_fnc_hashSet;

[rhsgref_faction_nationalist_mappings, "Groups", rhsgref_faction_nationalist_factionCustomGroups] call ALIVE_fnc_hashSet;

[ALIVE_factionCustomMappings, "rhsgref_faction_nationalist", rhsgref_faction_nationalist_mappings] call ALIVE_fnc_hashSet;

[ALIVE_factionDefaultSupports, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultTransport, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;
[ALIVE_factionDefaultAirTransport, "rhsgref_faction_nationalist", []] call ALIVE_fnc_hashSet;
