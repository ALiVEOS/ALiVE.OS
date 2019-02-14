#include "\x\alive\addons\civ_placement\script_component.hpp"
ALIVE_clusterBuild = [CLUSTERBUILD];
ALIVE_clustersCiv = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivHQ = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivPower = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivComms = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivMarine = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivRail = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivFuel = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivConstruction = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersCivSettlement = [] call ALIVE_fnc_hashCreate;
