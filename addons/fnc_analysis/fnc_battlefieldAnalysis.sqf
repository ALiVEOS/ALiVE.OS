#include <\x\alive\addons\fnc_analysis\script_component.hpp>
SCRIPT(battlefieldAnalysis);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Battlefield analysis

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:


Examples:
(begin example)
// create the battlefield analysis
_logic = [nil, "create"] call ALIVE_fnc_battlefieldAnalysis;

// init battlefield analysis
_result = [_logic, "init"] call ALIVE_fnc_battlefieldAnalysis;

(end)

See Also:

Author:
ARJay

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_battlefieldAnalysis

private ["_result"];

TRACE_1("battlefieldAnalysis - input",_this);

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];
//_result = true;

#define MTEMPLATE "ALiVE_BATTLEFIELDANALYSIS_%1"

switch(_operation) do {
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
                [_logic, "destroy"] call SUPERCLASS;
        };
    };
    case "debug": {
        private["_tasks"];

        if(typeName _args != "BOOL") then {
                _args = [_logic,"debug"] call ALIVE_fnc_hashGet;
        } else {
                [_logic,"debug",_args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);

        _result = _args;
    };
    case "init": {
        if (isServer) then {

            // if server, initialise module game logic
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class",MAINCLASS] call ALIVE_fnc_hashSet;
            TRACE_1("After module init",_logic);

            // set defaults
            [_logic,"debug",false] call ALIVE_fnc_hashSet;
            [_logic,"eventsInProgress",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"activeSectors",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"casualtySectors",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_logic,"listenerID",""] call ALIVE_fnc_hashSet;

            [_logic,"listen"] call MAINCLASS;
        };
    };
    case "listen": {
        private["_listenerID"];

        _listenerID = [ALIVE_eventLog, "addListener",[_logic, [
            "LOGISTICS_INSERTION",
            "LOGISTICS_DESTINATION",
            "LOGISTICS_COMPLETE",
            "PROFILE_KILLED",
            "AGENT_KILLED",
            "OPCOM_RECON",
            "OPCOM_CAPTURE",
            "OPCOM_DEFEND",
            "OPCOM_RESERVE",
            "OPCOM_TERRORIZE"
        ]]] call ALIVE_fnc_eventLog;

        [_logic,"listenerID",_listenerID] call ALIVE_fnc_hashSet;
    };
    case "handleEvent": {
        private["_event","_id","_type","_eventData"];

        if(typeName _args == "ARRAY") then {

            _event = _args;

            _id = [_event, "id"] call ALIVE_fnc_hashGet;
            _type = [_event, "type"] call ALIVE_fnc_hashGet;
            _eventData = [_event, "data"] call ALIVE_fnc_hashGet;

            [_logic, _type, [_id,_eventData]] call MAINCLASS;

        };
    };
    case "LOGISTICS_INSERTION": {
        private["_eventID","_eventData","_position","_side","_faction","_logEventID","_eventsInProgress","_logisticsEvent"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;
        _logEventID = _eventData select 3;

        _eventsInProgress = [_logic, "eventsInProgress"] call ALIVE_fnc_hashGet;

        _logisticsEvent = [] call ALIVE_fnc_hashCreate;
        [_logisticsEvent,"insertion",_position] call ALIVE_fnc_hashSet;
        [_logisticsEvent,"destination",[]] call ALIVE_fnc_hashSet;
        [_logisticsEvent,"side",_side] call ALIVE_fnc_hashSet;
        [_logisticsEvent,"faction",_faction] call ALIVE_fnc_hashSet;

        [_eventsInProgress, _logEventID, _logisticsEvent] call ALIVE_fnc_hashSet;

        //_eventsInProgress call ALIVE_fnc_inspectHash;

    };
    case "LOGISTICS_DESTINATION": {
        private["_eventID","_eventData","_position","_side","_faction","_logEventID","_eventsInProgress","_logisticsEvent"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;
        _logEventID = _eventData select 3;

        _eventsInProgress = [_logic, "eventsInProgress"] call ALIVE_fnc_hashGet;

        if(_logEventID in (_eventsInProgress select 1)) then {
            _logisticsEvent = [_eventsInProgress,_logEventID] call ALIVE_fnc_hashGet;
            [_logisticsEvent,"destination",_position] call ALIVE_fnc_hashSet;
        };

        //_eventsInProgress call ALIVE_fnc_inspectHash;

    };
    case "LOGISTICS_COMPLETE": {
        private["_eventID","_eventData","_position","_side","_faction","_logEventID","_eventsInProgress","_logisticsEvent"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;
        _logEventID = _eventData select 3;

        _eventsInProgress = [_logic, "eventsInProgress"] call ALIVE_fnc_hashGet;

        if(_logEventID in (_eventsInProgress select 1)) then {
            [_eventsInProgress, _logEventID] call ALIVE_fnc_hashRem;
        };

        //_eventsInProgress call ALIVE_fnc_inspectHash;

    };
    case "PROFILE_KILLED": {
        private["_eventID","_eventData","_position","_side","_faction","_eventSector","_eventSectorID",
        "_sectorData","_casualties","_factionCasualties","_sideCasualties","_casualtySectors",
        "_factionCasualtyCount","_sideCasualtyCount"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;

        _eventSector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
        _eventSectorID = [_eventSector,"id"] call ALIVE_fnc_hashGet;

        _sectorData = [_eventSector,"data"] call ALIVE_fnc_hashGet;
        
        if (isnil "_sectorData") exitwith {};

        if!("casualties" in (_sectorData select 1)) then {
            _casualties = [] call ALIVE_fnc_hashCreate;
            [_casualties,"side",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_casualties,"faction",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_casualties,"lastEvent",[]] call ALIVE_fnc_hashSet;
            [_sectorData,"casualties",_casualties] call ALIVE_fnc_hashSet;
        };

        _casualties = [_sectorData,"casualties"] call ALIVE_fnc_hashGet;
        _factionCasualties = [_casualties,"faction"] call ALIVE_fnc_hashGet;
        _sideCasualties = [_casualties,"side"] call ALIVE_fnc_hashGet;

        if!(_side in (_sideCasualties select 1)) then {
            [_sideCasualties,_side,0] call ALIVE_fnc_hashSet;
        };

        if!(_faction in (_factionCasualties select 1)) then {
            [_factionCasualties,_faction,0] call ALIVE_fnc_hashSet;
        };

        _factionCasualtyCount = [_factionCasualties,_faction] call ALIVE_fnc_hashGet;
        _factionCasualtyCount = _factionCasualtyCount + 1;
        [_factionCasualties,_faction,_factionCasualtyCount] call ALIVE_fnc_hashSet;

        _sideCasualtyCount = [_sideCasualties,_side] call ALIVE_fnc_hashGet;
        _sideCasualtyCount = _sideCasualtyCount + 1;
        [_sideCasualties,_side,_sideCasualtyCount] call ALIVE_fnc_hashSet;

        [_casualties,"lastEvent",[time,_faction,_side]] call ALIVE_fnc_hashSet;

        _casualtySectors = [_logic, "casualtySectors"] call ALIVE_fnc_hashGet;
        [_casualtySectors,_eventSectorID,_eventSector] call ALIVE_fnc_hashSet;

    };
    case "AGENT_KILLED": {
        private["_eventID","_eventData","_position","_side","_faction","_eventSector","_eventSectorID",
        "_sectorData","_casualties","_factionCasualties","_sideCasualties","_casualtySectors",
        "_factionCasualtyCount","_sideCasualtyCount"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _position = _eventData select 0;
        _side = _eventData select 2;
        _faction = _eventData select 1;

        _eventSector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
        _eventSectorID = [_eventSector,"id"] call ALIVE_fnc_hashGet;

        _sectorData = [_eventSector,"data"] call ALIVE_fnc_hashGet;
        

        if (isnil "_sectorData") exitwith {};

        if!("casualties" in (_sectorData select 1)) then {
            _casualties = [] call ALIVE_fnc_hashCreate;
            [_casualties,"side",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_casualties,"faction",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
            [_casualties,"lastEvent",[]] call ALIVE_fnc_hashSet;
            [_sectorData,"casualties",_casualties] call ALIVE_fnc_hashSet;
        };

        _casualties = [_sectorData,"casualties"] call ALIVE_fnc_hashGet;
        _factionCasualties = [_casualties,"faction"] call ALIVE_fnc_hashGet;
        _sideCasualties = [_casualties,"side"] call ALIVE_fnc_hashGet;

        if!(_side in (_sideCasualties select 1)) then {
            [_sideCasualties,_side,0] call ALIVE_fnc_hashSet;
        };

        if!(_faction in (_factionCasualties select 1)) then {
            [_factionCasualties,_faction,0] call ALIVE_fnc_hashSet;
        };

        _factionCasualtyCount = [_factionCasualties,_faction] call ALIVE_fnc_hashGet;
        _factionCasualtyCount = _factionCasualtyCount + 1;
        [_factionCasualties,_faction,_factionCasualtyCount] call ALIVE_fnc_hashSet;

        _sideCasualtyCount = [_sideCasualties,_side] call ALIVE_fnc_hashGet;
        _sideCasualtyCount = _sideCasualtyCount + 1;
        [_sideCasualties,_side,_sideCasualtyCount] call ALIVE_fnc_hashSet;

        [_casualties,"lastEvent",[time,_faction,_side]] call ALIVE_fnc_hashSet;

        _casualtySectors = [_logic, "casualtySectors"] call ALIVE_fnc_hashGet;
        [_casualtySectors,_eventSectorID,_eventSector] call ALIVE_fnc_hashSet;

    };
    case "OPCOM_RECON": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        [_logic,"storeClusterEventToSector",[_clusterID,[_operation,floor(time),_position,_side,_type,_size,_priority]]] call MAINCLASS;

    };
    case "OPCOM_CAPTURE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        [_logic,"storeClusterEventToSector",[_clusterID,[_operation,floor(time),_position,_side,_type,_size,_priority]]] call MAINCLASS;

    };
    case "OPCOM_DEFEND": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        [_logic,"storeClusterEventToSector",[_clusterID,[_operation,floor(time),_position,_side,_type,_size,_priority]]] call MAINCLASS;

    };
    case "OPCOM_RESERVE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        [_logic,"storeClusterEventToSector",[_clusterID,[_operation,floor(time),_position,_side,_type,_size,_priority]]] call MAINCLASS;

    };
    case "OPCOM_TERRORIZE": {
        private["_eventID","_eventData","_side","_position","_size","_type","_priority","_clusterID"];

        _eventID = _args select 0;
        _eventData = _args select 1;

        _side = _eventData select 0;
        _position = _eventData select 1 select 2 select 1;
        _size = _eventData select 1 select 2 select 2;
        _type = _eventData select 1 select 2 select 3;
        _priority = _eventData select 1 select 2 select 4;
        _clusterID = _eventData select 1 select 2 select 6;

        [_logic,"storeClusterEventToSector",[_clusterID,[_operation,floor(time),_position,_side,_type,_size,_priority]]] call MAINCLASS;

    };
    case "storeClusterEventToSector": {
        private["_clusterID","_eventData","_type","_position","_side","_clusterType","_size","_priority","_eventSector","_eventSectorID",
        "_sectorData","_activeClusters","_activeCluster","_activeSectors"];

        _clusterID = _args select 0;
        _eventData = _args select 1;

        _type = _eventData select 0;
        _position = _eventData select 2;
        _side = _eventData select 3;
        _clusterType = _eventData select 4;
        _size = _eventData select 5;
        _priority = _eventData select 6;

        _eventSector = [ALIVE_sectorGrid, "positionToSector", _position] call ALIVE_fnc_sectorGrid;
        _eventSectorID = [_eventSector,"id"] call ALIVE_fnc_hashGet;

        _sectorData = [_eventSector,"data"] call ALIVE_fnc_hashGet;
        
        if (isnil "_sectorData") exitwith {};

        if!("activeClusters" in (_sectorData select 1)) then {
            [_sectorData,"activeClusters",[] call ALIVE_fnc_hashCreate] call ALIVE_fnc_hashSet;
        };

        _activeClusters = [_sectorData,"activeClusters"] call ALIVE_fnc_hashGet;

        if!(_clusterID in (_activeClusters select 1)) then {
            _activeCluster = [] call ALIVE_fnc_hashCreate;
            _activeCluster = [_activeCluster,"position",_position] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"type",_clusterType] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"size",_size] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"priority",_priority] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"owner",""] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"lastEvent",""] call ALIVE_fnc_hashSet;
            _activeCluster = [_activeCluster,"lastEventTime",time] call ALIVE_fnc_hashSet;
            [_activeClusters,_clusterID,_activeCluster] call ALIVE_fnc_hashSet;
        };

        _activeCluster = [_activeClusters,_clusterID] call ALIVE_fnc_hashGet;

        switch(_type) do {
            case "OPCOM_RECON": {
                _activeCluster = [_activeCluster,"lastEvent","recon"] call ALIVE_fnc_hashSet;
            };
            case "OPCOM_CAPTURE": {
                _activeCluster = [_activeCluster,"lastEvent","capture"] call ALIVE_fnc_hashSet;
                _activeCluster = [_activeCluster,"owner",_side] call ALIVE_fnc_hashSet;
            };
            case "OPCOM_DEFEND": {
                _activeCluster = [_activeCluster,"lastEvent","defend"] call ALIVE_fnc_hashSet;
            };
            case "OPCOM_RESERVE": {
                _activeCluster = [_activeCluster,"lastEvent","reserve"] call ALIVE_fnc_hashSet;
                _activeCluster = [_activeCluster,"owner",_side] call ALIVE_fnc_hashSet;
            };
            case "OPCOM_TERRORIZE": {
                _activeCluster = [_activeCluster,"lastEvent","terrorize"] call ALIVE_fnc_hashSet;
                _activeCluster = [_activeCluster,"owner",_side] call ALIVE_fnc_hashSet;
            };
        };

        [_activeClusters,_clusterID,_activeCluster] call ALIVE_fnc_hashSet;
        [_sectorData,"activeClusters",_activeClusters] call ALIVE_fnc_hashSet;
        [_eventSector,"data",_sectorData] call ALIVE_fnc_hashSet;

        _activeSectors = [_logic, "activeSectors"] call ALIVE_fnc_hashGet;
        [_activeSectors,_eventSectorID,_eventSector] call ALIVE_fnc_hashSet;

        //_eventSector call ALIVE_fnc_inspectHash;

    };
    case "getActiveSectors": {
        _result = [_logic, "activeSectors"] call ALIVE_fnc_hashGet;
    };
    case "getCasualtySectors": {
        _result = [_logic, "casualtySectors"] call ALIVE_fnc_hashGet;
    };
    case "getClustersOwnedBySide": {
        private["_side","_clustersOwnedBySide","_activeSectors","_clusters","_owner","_sectorData"];

        _side = _args select 0;
        _clustersOwnedBySide = [];

        _side = if (typeName _side == "SIDE") then {str(_side)} else {_side};
        
        if (_side == "GUER") then {_side = "INDEP"};

        _activeSectors = [_logic, "activeSectors"] call ALIVE_fnc_hashGet;

        {
            _sectorData = [_x,"data"] call ALIVE_fnc_hashGet;
            
            if !(isnil "_sectorData") then {
	            _clusters = [_sectorData,"activeClusters"] call ALIVE_fnc_hashGet;
	
	            {
                    
	                _owner = [_x,"owner"] call ALIVE_fnc_hashGet;
                    _owner = if (typeName _owner == "SIDE") then {str(_owner)} else {_owner};
                    if (_owner == "GUER") then {_owner = "INDEP"};
                    
	                if (_owner == _side) then {
	                    _clustersOwnedBySide set [count _clustersOwnedBySide, _x];
	                };
	            } forEach (_clusters select 2);
            };
        } forEach (_activeSectors select 2);

        _result = _clustersOwnedBySide;
    };
    case "getClustersOwnedBySideAndType": {
        private["_side","_type","_clustersOwnedBySide","_activeSectors","_clusters","_owner","_clusterType","_sectorData"];

        _side = _args select 0;
        _type = _args select 1;
        _clustersOwnedBySide = [];
        
        _side = if (typeName _side == "SIDE") then {str(_side)} else {_side};
        
        if (_side == "GUER") then {_side = "INDEP"};

        _activeSectors = [_logic, "activeSectors"] call ALIVE_fnc_hashGet;

        {
            _sectorData = [_x,"data"] call ALIVE_fnc_hashGet;
            
            if !(isnil "_sectorData") then {
	            _clusters = [_sectorData,"activeClusters"] call ALIVE_fnc_hashGet;
	
	            {
	                _owner = [_x,"owner"] call ALIVE_fnc_hashGet;
                    _owner = if (typeName _owner == "SIDE") then {str(_owner)} else {_owner};
	                _clusterType = [_x,"type"] call ALIVE_fnc_hashGet;
                    
                    if (_owner == "GUER") then {_owner = "INDEP"};

	                if (_owner == _side && {_type == _clusterType}) then {
	                    _clustersOwnedBySide set [count _clustersOwnedBySide, _x];
	                };
	            } forEach (_clusters select 2);
            
            };
        } forEach (_activeSectors select 2);

        _result = _clustersOwnedBySide;
    };
    case "getSectorsContainingSide": {
        private["_side","_sectorsContainingSide","_allSectors","_landSectors","_sectorData","_entities","_sideEntities"];

        _side = _args select 0;
        _sectorsContainingSide = [];

        [ALIVE_sectorGrid] call ALIVE_fnc_gridAnalysisProfileEntity;
        _allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
        _landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;

        {
            _sectorData = [_x,"data"] call ALIVE_fnc_hashGet;
            
            if (!isnil "_sectorData" && {"entitiesBySide" in (_sectorData select 1)}) then {
                _entities = [_sectorData,"entitiesBySide"] call ALIVE_fnc_hashGet;
                _sideEntities = [_entities,_side] call ALIVE_fnc_hashGet;
                if(count _sideEntities > 0) then {
                    _sectorsContainingSide set [count _sectorsContainingSide,_x];
                };
            };
        } forEach _landSectors;

        _result = _sectorsContainingSide;
    };
    case "getSectorsContainingSideVehicles": {
        private["_side","_sectorsContainingSide","_allSectors","_landSectors","_sectorData","_vehicles","_sideVehicles"];

        _side = _args select 0;
        _sectorsContainingSide = [];

        [ALIVE_sectorGrid] call ALIVE_fnc_gridAnalysisProfileVehicle;
        _allSectors = [ALIVE_sectorGrid, "sectors"] call ALIVE_fnc_sectorGrid;
        _landSectors = [_allSectors, "SEA"] call ALIVE_fnc_sectorFilterTerrain;

        {
            _sectorData = [_x,"data"] call ALIVE_fnc_hashGet;

            if (!isnil "_sectorData" && {"vehiclesBySide" in (_sectorData select 1)}) then {
                _vehicles = [_sectorData,"vehiclesBySide"] call ALIVE_fnc_hashGet;
                _sideVehicles = [_vehicles,_side] call ALIVE_fnc_hashGet;
                if(count _sideVehicles > 0) then {
                    _sectorsContainingSide set [count _sectorsContainingSide,_x];
                };
            };
        } forEach _landSectors;

        _result = _sectorsContainingSide;
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("battlefieldAnalysis - output",_result);

if !(isnil "_result") then {_result} else {nil};
