#include "\x\alive\addons\fnc_strategic\script_component.hpp"
SCRIPT(cluster);

/* ----------------------------------------------------------------------------
Function: MAINCLASS
Description:
Creates the server side object to cluster information

Parameters:
Nil or Object - If Nil, return a new instance. If Object, reference an existing instance.
String - The selected function
Array - The selected parameters

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
Boolean - debug - Debug enable, disable or refresh
Boolean - state - Store or restore state of cluster
Array - nodes - Array of object nodes within cluster
Object - addNode - Add object to node array of cluster
Object - delNode - Delete object from node array of cluster
Array - center - (Read only) - Recalculate, set and return centre position of cluster
Number - size - (Read only) - Maximum distance of an object from the centre

Examples:
(begin example)
//
(end)

See Also:
- <ALIVE_fnc_findClusters>
- <ALIVE_fnc_consolidateClusters>

Author:
Wolffy.au
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

#define SUPERCLASS ALIVE_fnc_baseClassHash
#define MAINCLASS ALIVE_fnc_cluster
#define MTEMPLATE "ALiVE_CLUSTER_%1_%2"

private ["_createMarkers","_deleteMarkers","_positionIsUsable","_nodes","_center","_result"];

params [
    ["_logic", objNull, [objNull,[]]],
    ["_operation", "", [""]],
    ["_args", objNull, [objNull,[],"",0,true,false]]
];

TRACE_2("cluster - input",_operation,_args);

_result = true;



// Could this position be somewhere on a map at all.
//
// Terrain indexing can hand back a LIVE object for a placement it failed to locate, so neither
// isNil nor isNull notices anything wrong: the object is real, its position is not. One terrain
// ships three such placements, held in its index with a stand-in position, and asking the object
// that came back where it was gave a point far off the map with a height that is not a number.
// Saved, that put nodes into the cluster files that nothing can use, and a height that is not a
// number poisons every distance and comparison it touches without ever raising a complaint.
//
// Asked the way round that makes a good position prove itself, deliberately. Every comparison
// against a value that is not a number answers no, so a test asking whether a position is BAD
// answers no as well and waves it through. Do not turn this into a negation.
//
// The lower limit is loose on purpose. Real objects do sit a little way past zero on some maps,
// including the one this was found on, so anything near the edge has to pass.
_positionIsUsable = {
    private ["_p","_ok"];
    _p = _this;

    if !(_p isEqualType []) exitWith { false };
    if (count _p < 2) exitWith { false };

    _ok = ((_p select 0) isEqualType 0)
        && {(_p select 1) isEqualType 0}
        && {(_p select 0) > -5000}
        && {(_p select 0) < 100000}
        && {(_p select 1) > -5000}
        && {(_p select 1) < 100000};

    // Height only where there is one. This is the part that catches a height that is not a
    // number, since it sits within limits no real terrain approaches.
    if (_ok && {count _p > 2}) then {
        _ok = ((_p select 2) isEqualType 0)
            && {(_p select 2) > -100000}
            && {(_p select 2) < 100000};
    };

    _ok
};

_deleteMarkers = {
    private ["_logic"];
    _logic = _this;
    {
        deleteMarkerLocal _x;
    } forEach ([_logic, "debugMarkers", []] call ALIVE_fnc_hashGet);
};

_createMarkers = {
    private ["_logic","_markers","_m","_size","_priority","_type","_id","_nodes","_center","_random"];
    _logic = _this;
    _markers = [];
    _nodes = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
    _random = floor(random 10000);

    if(count _nodes > 0) then {
        // mark all nodes
        {
            _m = format[MTEMPLATE, _random, count _markers];
            if(str getMarkerPos _m == "[0,0,0]") then {
                _m = createMarker [_m, getPosATL _x];
                _m setMarkerShape "Icon";
                _m setMarkerSize [0.5,0.5];
                _m setMarkerType "mil_dot";
                _markers pushback _m;
            } else {
                _m setMarkerPos (getPosATL _x);
            };
            _m setMarkerColor ([_logic, "debugColor","ColorYellow"] call ALIVE_fnc_hashGet);
        } forEach _nodes;

        _center = [_logic, "center"] call MAINCLASS;
        _size = [_logic, "size"] call MAINCLASS;
        _priority = [_logic, "priority"] call MAINCLASS;
        _type = [_logic, "type"] call MAINCLASS;
        _id = [_logic, "clusterID", ""] call ALIVE_fnc_hashGet;
        private _color = [_logic, "debugColor", "ColorYellow"] call ALIVE_fnc_hashGet;
        // Derive a human-readable cluster sub-type from the debugColor
        // when the cluster is civilian. Civ generators (auto-gen +
        // per-map pre-gen + civ_placement_custom) all set debugColor
        // 1:1 with the civilian sub-type (HQ=Black, Power=Yellow,
        // Comms=White, Marine=Blue, Rail=Khaki, Fuel=Orange,
        // Construction=Pink, Settlement=Green, Custom=Red). Reading
        // the colour at render time avoids touching every per-map
        // cluster file to thread a separate sub-type field through.
        // Mil / other cluster types skip the prefix - their colours
        // don't carry the same convention.
        private _subType = "";
        if (_type == "CIV") then {
            _subType = switch (_color) do {
                case "ColorBlack":  { "HQ" };
                case "ColorYellow": { "Power" };
                case "ColorWhite":  { "Comms" };
                case "ColorBlue":   { "Marine" };
                case "ColorKhaki":  { "Rail" };
                case "ColorOrange": { "Fuel" };
                case "ColorPink":   { "Construction" };
                case "ColorGreen":  { "Settlement" };
                case "ColorRed":    { "Custom" };
                default             { "" };
            };
        };
        // Anchor slot in the shared debug-marker offset registry -
        // other emitters (mil_opcom, fnc_analysis) fan out around the
        // cluster centre so their labels don't overlap this one.
        _m = createMarker [format[MTEMPLATE, _random, count _markers], ["strategic", _center] call ALiVE_fnc_debugMarkerOffset];
        _m setMarkerShape "Icon";
        _m setMarkerSize [0.75, 0.75];
        _m setMarkerType "mil_dot";
        _m setMarkerColor _color;
        if (_subType == "") then {
            _m setMarkerText format["%1|%2|%3|%4", _id, _type, _priority, floor _size];
        } else {
            _m setMarkerText format["%1: %2|%3|%4|%5", _subType, _id, _type, _priority, floor _size];
        };
        _markers pushback _m;

        _m = createMarker [_m + "_size", _center];
        _m setMarkerShape "Ellipse";
        _m setMarkerSize [_size, _size];
        _m setMarkerColor ([_logic, "debugColor","ColorYellow"] call ALIVE_fnc_hashGet);
        _m setMarkerAlpha 0.5;
        _markers pushback _m;

        [_logic, "debugMarkers", _markers] call ALIVE_fnc_hashSet;
    };
};

switch(_operation) do {
    case "create": {
        /*
        MODEL - no visual just reference data
        - nodes
        - center
        - size
        */

        if (isServer) then {
            // if server, initialise module game logic
            _logic = [nil, "create"] call SUPERCLASS;
            [_logic,"super"] call ALIVE_fnc_hashRem;
            [_logic,"class"] call ALIVE_fnc_hashRem;

            TRACE_1("After module init",_logic);
            _result = _logic;
        };


        /*
        VIEW - purely visual
        */

        /*
        CONTROLLER  - coordination
        */
    };
    case "destroy": {
        [_logic, "debug", false] call MAINCLASS;
        if (isServer) then {
            // if server
            [_logic, "destroy"] call SUPERCLASS;
        };

        _logic = nil;
    };
    case "debug": {
        if(typeName _args != "BOOL") then {
            _args = [_logic, "debug", false] call ALIVE_fnc_hashGet;
        } else {
            [_logic, "debug", _args] call ALIVE_fnc_hashSet;
        };
        ASSERT_TRUE(typeName _args == "BOOL",str _args);
        _logic call _deleteMarkers;

        if(_args) then {
            _logic call _createMarkers;
        };
        _result = _args;
    };
    case "state": {
        private["_state","_data","_nodes","_objID"];

        if(typeName _args != "ARRAY") then {
            _state = [] call ALIVE_fnc_hashCreate;
            // Save state

            // nodes
            _data = [];
            private _dropped = 0;
            {
                if!(isNil "_x") then {
                    private _nodePos = position _x;

                    if (_nodePos call _positionIsUsable) then {
                        _data set [count _data, [
                            _x call ALIVE_fnc_findObjectIDString,
                            _nodePos
                        ]];
                    } else {
                        _dropped = _dropped + 1;
                    };
                };
            } forEach ([_logic, "nodes",[]] call ALIVE_fnc_hashGet);

            // Said once for the cluster rather than once per node. A terrain whose index is
            // genuinely broken produces these by the dozen, and saying so every time is how a
            // real signal gets buried.
            if (_dropped > 0) then {
                ["CLUSTER %1 - %2 node(s) left out of the saved data, their position was not somewhere on the map. The terrain index is likely at fault for those objects.",
                    [_logic, "clusterID", "?"] call ALIVE_fnc_hashGet, _dropped] call ALIVE_fnc_dump;
            };

            _result = [_state, "nodes", _data] call ALIVE_fnc_hashSet;
        } else {
            ASSERT_TRUE([_args] call ALIVE_fnc_isHash,str _args);

            // Restore state

            // nodes
            _data = [];
            _nodes = [_args, "nodes"] call ALIVE_fnc_hashGet;
            // The same test on the way back in, so a cluster file written before this existed
            // cannot put a node nothing can use back into play.
            private _droppedOnLoad = 0;
            {
                private["_node"];
                _objID = parseNumber(_x select 0);
                if(_objID > 0 && {(_x select 1) call _positionIsUsable}) then {
                    _node = (_x select 1) nearestObject (parseNumber(_x select 0));
                    _data pushback _node;
                } else {
                    _droppedOnLoad = _droppedOnLoad + 1;
                };
            } forEach _nodes;

            if (_droppedOnLoad > 0) then {
                ["CLUSTER %1 - %2 stored node(s) skipped, their position was not somewhere on the map.",
                    [_logic, "clusterID", "?"] call ALIVE_fnc_hashGet, _droppedOnLoad] call ALIVE_fnc_dump;
            };
            [_logic, "nodes", _data] call MAINCLASS;
        };
    };
    case "center": {
        // Read Only - return centre of clustered nodes
        _args = [_logic, _operation, []] call ALIVE_fnc_hashGet;
        if(count _args == 0) then {
            _result = [[_logic, "nodes",[]] call ALIVE_fnc_hashGet] call ALIVE_fnc_findClusterCenter;
            [_logic, _operation, _result] call ALIVE_fnc_hashSet;
        } else {
            _result = _args;
        };
    };
    case "size": {
        // Read Only - return distance from centre to furthest node
        _args = [_logic, _operation, 0] call ALIVE_fnc_hashGet;
        if(_args == 0) then {
            private ["_max"];
            _nodes = [_logic, "nodes",[]] call ALIVE_fnc_hashGet;
            _result = MIN_CLUSTER_SIZE;
            _center = [_logic, "center"] call MAINCLASS;
            if(count _center > 0) then {
                {
                    if(_x distance _center > _result && _x distance _center < (worldSize / 2) ) then {_result = _x distance _center;};
                } forEach _nodes;
            };
            [_logic, _operation, _result] call ALIVE_fnc_hashSet;
        } else {
            _result = _args;
        };
    };
    case "nodes": {
        if(typeName _args == "ARRAY") then {
            [_logic, "nodes", _args] call ALIVE_fnc_hashSet;
        };

        if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
            [_logic, "debug"] call MAINCLASS;
        };
        [_logic, "center", []] call ALIVE_fnc_hashSet;
        [_logic, "size", 0] call ALIVE_fnc_hashSet;
        _result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
    };
    case "addNode": {
        if(typeName _args == "OBJECT") then {
            _result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
            [_logic, "nodes", _result + [_args]] call ALIVE_fnc_hashSet;

            if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
                [_logic, "debug"] call MAINCLASS;
            };
        };
        [_logic, "center", []] call ALIVE_fnc_hashSet;
        [_logic, "size", 0] call ALIVE_fnc_hashSet;
        _result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
    };
    case "delNode": {
        if(typeName _args == "OBJECT") then {
            _result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
            [_logic, "nodes", _result - [_args]] call ALIVE_fnc_hashSet;

            if ([_logic, "debug", false] call ALIVE_fnc_hashGet) then {
                [_logic, "debug"] call MAINCLASS;
            };
        };
        [_logic, "center", []] call ALIVE_fnc_hashSet;
        [_logic, "size", 0] call ALIVE_fnc_hashSet;
        _result = [_logic, "nodes", []] call ALIVE_fnc_hashGet;
    };
    // Determine cluster type - valid values are: military, infrastructure and civilian
    case "type": {
        _result = [
            _logic,_operation,_args,
            "CIV",
            ["MIL","INF","CIV"]
        ] call ALIVE_fnc_OOsimpleOperation;
    };
    // Determine cluster priority - valid values are any integer, higher numbers higher priority
    case "priority": {
        _result = [
            _logic,_operation,_args,
            0
        ] call ALIVE_fnc_OOsimpleOperation;
    };
    // Determine cluster priority - valid values are any integer, higher numbers higher priority
    case "clusterID": {
        _result = [
            _logic,_operation,_args,
            0
        ] call ALIVE_fnc_OOsimpleOperation;
    };
    default {
        _result = [_logic, _operation, _args] call SUPERCLASS;
    };
};
TRACE_1("cluster - output",_result);
_result;
