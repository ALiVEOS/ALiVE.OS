#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(getGlobalPosture);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_getGlobalPosture

Description:
Determine from hostility settings the global posture of civilian population

Parameters:

Returns:
Array - empty if none found, 1 unit within if found

Examples:
(begin example)
//
_result = [] call ALIVE_fnc_getGlobalPosture;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_activeClusters","_cluster","_position","_size","_clusterHostility","_nearUnits","_hostileSide","_hostileLevel"];

_activeClusters = [ALIVE_clusterHandler, "getActive"] call ALIVE_fnc_clusterHandler;
{
    _cluster = _x;
    _position = _cluster select 2 select 2;
    _size = _cluster select 2 select 3;
    _clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;

    _nearUnits = [_cluster,_position, (_size*2)] call ALIVE_fnc_getAgentEnemyNear;

    if(count _nearUnits > 0) then {
        _hostileSide = str(side (group(_nearUnits select 0)));
        _hostileLevel = [_clusterHostility, _hostileSide, 0] call ALIVE_fnc_hashGet;
        [_cluster, "posture", _hostileLevel] call ALIVE_fnc_hashSet;
    }else{
        [_cluster, "posture", 0] call ALIVE_fnc_hashSet;
    };

} forEach (_activeClusters select 2);