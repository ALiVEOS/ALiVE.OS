// ALiVE 3 index v3.1, made 2026-10-06 by the ALiVE web indexer, building positions measured
#include "\x\alive\addons\civ_placement\script_component.hpp"
ALIVE_clusterBuild = [CLUSTERBUILD];
ALIVE_clustersMil = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersMilHQ = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersMilAir = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersMilHeli = [] call ALIVE_fnc_hashCreate;
