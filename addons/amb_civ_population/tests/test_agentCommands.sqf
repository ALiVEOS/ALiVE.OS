// ----------------------------------------------------------------------------

#include <\x\alive\addons\amb_civ_population\script_component.hpp>
SCRIPT(test_agentHandler);

//execVM "\x\alive\addons\amb_civ_population\tests\test_agentCommands.sqf"

// ----------------------------------------------------------------------------

private ["_result","_err","_logic","_state","_result2"];

LOG("Testing Agent Handler Object");

ASSERT_DEFINED("ALIVE_fnc_agentHandler","");

#define STAT(msg) sleep 3; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define STAT1(msg) CONT = false; \
waitUntil{CONT}; \
diag_log ["TEST("+str player+": "+msg]; \
titleText [msg,"PLAIN"]

#define DEBUGON STAT("Setup debug parameters"); \
_result = [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler; \
_err = "enabled debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(_result, _err);

#define DEBUGOFF STAT("Disable debug"); \
_result = [ALIVE_agentHandler, "debug", true] call ALIVE_fnc_agentHandler; \
_err = "disable debug"; \
ASSERT_TRUE(typeName _result == "BOOL", _err); \
ASSERT_TRUE(!_result, _err);

#define TIMERSTART \
_timeStart = diag_tickTime; \
diag_log "Timer Start";

#define TIMEREND \
_timeEnd = diag_tickTime - _timeStart; \
diag_log format["Timer End %1",_timeEnd];

//========================================

_logic = nil;


private["_position","_sector","_sectors","_sectorData","_civClusters","_settlementClusters","_clusterID","_cluster","_clusterHostility","_clusterCasualties","_agents","_agent"];

// Get any active civilian agents

STAT("Get All Active Agents");

["ACTIVE AGENTS:"] call ALIVE_fnc_dump;

_agents = [ALIVE_agentHandler,"getActive"] call ALIVE_fnc_agentHandler;

_agents call ALIVE_fnc_inspectHash;


// Get the nearby civillian clusters and output debug info

STAT("Get Near Civ Clusters");

_position = getPos player;

_sector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
_sectors = [ALIVE_sectorGrid, "surroundingSectors", _position] call ALIVE_fnc_sectorGrid;

_sectors = _sectors + [_sector];

{
	_sectorData = [_x, "data"] call ALIVE_fnc_sector;
	if("clustersCiv" in (_sectorData select 1)) then {
		_civClusters = [_sectorData,"clustersCiv"] call ALIVE_fnc_hashGet;
		_settlementClusters = [_civClusters,"settlement"] call ALIVE_fnc_hashGet;
		{
			_clusterID = _x select 1;
			_cluster = [ALIVE_clusterHandler, "getCluster", _clusterID] call ALIVE_fnc_clusterHandler;

			if!(isNil "_cluster") then {

				_clusterHostility = [_cluster, "hostility"] call ALIVE_fnc_hashGet;
				_clusterCasualties = [_cluster, "casualties"] call ALIVE_fnc_hashGet;

				["CLUSTER ID: %1",_clusterID] call ALIVE_fnc_dump;
				["CLUSTER %1 Hostility: %2",_clusterID,_clusterHostility] call ALIVE_fnc_dump;
				["CLUSTER %1 Casualties: %2",_clusterID,_clusterCasualties] call ALIVE_fnc_dump;
				["CLUSTER DATA: %1",_clusterID] call ALIVE_fnc_dump;
				_cluster call ALIVE_fnc_inspectHash;

				["CLUSTER AGENTS: %1",_clusterID] call ALIVE_fnc_dump;

				_agents = [ALIVE_agentHandler,"getAgentsByCluster",_clusterID] call ALIVE_fnc_agentHandler;

				_agents call ALIVE_fnc_inspectHash;

			};

		} forEach _settlementClusters;
	};
} forEach _sectors;

// Get the nearest civ

private["_distance","_lowsetDistance","_currentDistance","_agentID","_agent"];

STAT("Get Nearest Civ");

_distance = 100;
_lowsetDistance = _distance;
closestMan = objNull;

// find nearest men who are agents

{
    _currentDistance = _position distance _x;
    _agentID = _x getVariable["agentID","0"];

	if!(_agentID == "0") then {
		["MAN AT DISTANCE: %1",_currentDistance] call ALIVE_fnc_dump;

		if(_currentDistance < _lowsetDistance) then {

			["MAN IS CLOSER!"] call ALIVE_fnc_dump;

			_lowsetDistance = _currentDistance;
			closestMan = _x;
		};
	};

} forEach (_position nearObjects ["CAManBase",100]);

if(isNull closestMan) exitWith {
	["NO AGENT FOUND WITHIN 100M"] call ALIVE_fnc_dump;
};

// output debug info about the agent

["CLOSEST MAN: %1",closestMan] call ALIVE_fnc_dump;

_agentID = closestMan getVariable "agentID";

["CLOSEST MAN AGENT ID: %1",_agentID] call ALIVE_fnc_dump;

_agent = [ALIVE_agentHandler,"getAgent",_agentID] call ALIVE_fnc_agentHandler;

["CLOSEST AGENT HASH:"] call ALIVE_fnc_dump;

_agent call ALIVE_fnc_inspectHash;
unit = _agent select 2 select 5;

// draw agent icon

[] spawn {
	private["_agentID","_agent"];
	waitUntil {
		sleep 1;
		drawIcon3D [
			"",
			[1,0,0,1],
			getPos unit,
			1,
			1,
			45,
			format["%1",unit],
			1,
			0.03,
			"PuristaMedium"
		];
		_agentID = unit getVariable "agentID";
		_agent = [ALIVE_agentHandler,"getAgent",_agentID] call ALIVE_fnc_agentHandler;
		_agent call ALIVE_fnc_inspectHash;
		not alive unit;
	};
};

// set command on the agent

[_agent, "setActiveCommand", ["ALIVE_fnc_cc_campfire", "managed", [30,90]]] call ALIVE_fnc_civilianAgent;

