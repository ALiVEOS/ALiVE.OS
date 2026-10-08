// ALiVE 3 index v3.1, made 2026-10-08 by the ALiVE web indexer, building positions measured
#include "\x\alive\addons\civ_placement\script_component.hpp"
ALIVE_clusterBuild = [CLUSTERBUILD];
ALIVE_clustersMil = [] call ALIVE_fnc_hashCreate;
_cluster = [nil, "create"] call ALIVE_fnc_cluster;
_nodes = [];
_nodes set [count _nodes, ["909",[16185.7,4433.87,-0.00131226]]];
[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;
[_cluster, "state", _cluster] call ALIVE_fnc_cluster;
[_cluster,"clusterID","c_0"] call ALIVE_fnc_hashSet;
[_cluster,"center",[16185.7,4433.79]] call ALIVE_fnc_hashSet;
[_cluster,"size",150] call ALIVE_fnc_hashSet;
[_cluster,"type","MIL"] call ALIVE_fnc_hashSet;
[_cluster,"priority",0] call ALIVE_fnc_hashSet;
[_cluster,"debugColor","ColorGreen"] call ALIVE_fnc_hashSet;
[ALIVE_clustersMil,"c_0",_cluster] call ALIVE_fnc_hashSet;
_cluster = [nil, "create"] call ALIVE_fnc_cluster;
_nodes = [];
_nodes set [count _nodes, ["24",[11094.3,8910.04,0.000183105]]];
_nodes set [count _nodes, ["19",[11227.4,9035.8,0.119637]]];
[_cluster,"nodes",_nodes] call ALIVE_fnc_hashSet;
[_cluster, "state", _cluster] call ALIVE_fnc_cluster;
[_cluster,"clusterID","c_1"] call ALIVE_fnc_hashSet;
[_cluster,"center",[11161,8972.39]] call ALIVE_fnc_hashSet;
[_cluster,"size",150] call ALIVE_fnc_hashSet;
[_cluster,"type","MIL"] call ALIVE_fnc_hashSet;
[_cluster,"priority",0] call ALIVE_fnc_hashSet;
[_cluster,"debugColor","ColorGreen"] call ALIVE_fnc_hashSet;
[ALIVE_clustersMil,"c_1",_cluster] call ALIVE_fnc_hashSet;
ALIVE_clustersMilHQ = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersMilAir = [] call ALIVE_fnc_hashCreate;
ALIVE_clustersMilHeli = [] call ALIVE_fnc_hashCreate;
// fieldworks: used only when Military Placement's Fieldworks setting asks for them
ALIVE_clustersMilFieldwork = [] call ALIVE_fnc_hashCreate;
