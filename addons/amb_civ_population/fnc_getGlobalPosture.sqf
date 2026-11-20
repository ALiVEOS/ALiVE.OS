#include "\x\alive\addons\amb_civ_population\script_component.hpp"
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
Jman
---------------------------------------------------------------------------- */

private _activeClusters = [ALIVE_clusterHandler, "getActive"] call ALIVE_fnc_clusterHandler;

// The towns under threat now, [clusterID, level], published for the players' machines: the gestures, aim reactions,
// ACE menu tiers and Gather Intel there read the same town threat the dialog does. Sent only when it changes.
private _threat = [];

{
    private _cluster = _x;
    private _position = _cluster select 2 select 2;
    private _size = _cluster select 2 select 3;
    private _clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;

    private _nearUnits = [_cluster,_position, (_size*2)] call ALIVE_fnc_getAgentEnemyNear;

    if(count _nearUnits > 0) then {
        private _hostileSide = str(side (group(_nearUnits select 0)));
        private _hostileLevel = [_clusterHostility, _hostileSide, 0] call ALIVE_fnc_hashGet;
        [_cluster, "posture", _hostileLevel] call ALIVE_fnc_hashSet;
        if (_hostileLevel isEqualType 0 && {_hostileLevel > 0}) then {
            _threat pushBack [[_cluster, "clusterID", ""] call ALIVE_fnc_hashGet, _hostileLevel];
        };
    }else{
        [_cluster, "posture", 0] call ALIVE_fnc_hashSet;
    };

} forEach (_activeClusters select 2);

if !(_threat isEqualTo (missionNamespace getVariable ["ALiVE_CivPop_TownThreat", []])) then {
    missionNamespace setVariable ["ALiVE_CivPop_TownThreat", _threat, true];
};