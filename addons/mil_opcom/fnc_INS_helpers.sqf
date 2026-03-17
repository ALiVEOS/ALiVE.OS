//#define DEBUG_MODE_FULL
#include "\x\alive\addons\mil_opcom\script_component.hpp"
SCRIPT(INS_helpers);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_INS_helpers
Description:
Helper Function to keep transferred and stored code small

Base class for OPCOM objects to inherit from

Parameters:
Several
_timeTaken = _this select 0; //number
_pos = _this select 1; //array
_id = _this select 2; //string
_size = _this select 3; //number
_faction = _this select 4; //string
_factory = _this select 5; //array of [_pos,_class]
_target = _this select 6; //array of [_pos,_class]
_sides = _this select 7; //array of side as strings
_agents = _this select 8; //array of strings

Returns:
Any - The new instance or the result of the selected function and parameters

Attributes:
none

Examples:
(begin example)
// no example
(end)

See Also:

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */

ALiVE_fnc_INS_getOpcomByObjective = {
                params [["_objective",[]]];

                if (_objective isEqualTo []) exitwith {nil};

                private _opcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
                if (_opcomID == "") exitwith {nil};

                private _opcom = nil;

                {
                    if (([_x,"opcomID",""] call ALiVE_fnc_HashGet) == _opcomID) exitwith {
                        _opcom = _x;
                    };
                } foreach (missionNameSpace getVariable ["OPCOM_instances",[]]);

                _opcom
};

ALiVE_fnc_INS_getHostilitySetting = {
                params [["_objective",[]],["_key",""],["_default",0]];

                private _opcom = [_objective] call ALiVE_fnc_INS_getOpcomByObjective;
                if (isnil "_opcom") exitwith {_default};

                [_opcom,_key,_default] call ALiVE_fnc_HashGet
};

ALiVE_fnc_INS_getNearestObjectiveByPosition = {
                params [
                    ["_pos",[],[[]]],
                    ["_radius",2500,[0]],
                    ["_friendlySide","",["", east]],
                    ["_requiredControlType","",[""]]
                ];

                if (_pos isEqualTo []) exitwith {[]};

                private _friendlySideText = "";
                if (_friendlySide isEqualType east) then {
                    _friendlySideText = [[_friendlySide] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText;
                } else {
                    if (_friendlySide isEqualType "") then {
                        _friendlySideText = toUpper _friendlySide;
                        if (_friendlySideText == "RESISTANCE") then {_friendlySideText = "GUER"};
                    };
                };

                private _requiredControlTypeText = toLower _requiredControlType;
                private _nearestObjective = [];
                private _closestDistance = _radius max 0;

                {
                    private _opcom = _x;
                    private _controlType = toLower ([_opcom, "controltype", ""] call ALiVE_fnc_HashGet);
                    private _sidesEnemy = [[_opcom, "sidesenemy", []] call ALiVE_fnc_HashGet] call ALiVE_fnc_INS_normalizeHostilitySides;

                    if (
                        (_requiredControlTypeText == "" || {_controlType == _requiredControlTypeText})
                        && {(_friendlySideText == "") || {_friendlySideText in _sidesEnemy}}
                    ) then {
                        {
                            private _center = [_x,"center",[]] call ALiVE_fnc_HashGet;
                            if !(_center isEqualTo []) then {
                                private _distance = _pos distance2D _center;
                                if (_distance <= _closestDistance) then {
                                    _closestDistance = _distance;
                                    _nearestObjective = _x;
                                };
                            };
                        } foreach ([_opcom, "objectives", []] call ALIVE_fnc_HashGet);
                    };
                } foreach (missionNameSpace getVariable ["OPCOM_instances",[]]);

                _nearestObjective
};
ALiVE_fnc_INS_updateHostilityByPresence = {
                params ["_timeTaken","_pos","_insurgentSides",["_baseShift",20],["_allSides",["EAST","WEST","GUER"]],["_objective",[]]];

                _allSides = [_allSides] call ALiVE_fnc_INS_normalizeHostilitySides;
                _insurgentSides = [_insurgentSides] call ALiVE_fnc_INS_normalizeHostilitySides;

                if (count _insurgentSides == 0) exitwith {};

                private _elapsed = (time - _timeTaken) max 0;
                private _durationMultiplier = ((floor (_elapsed / 120)) max 1) min 4;
                private _presenceMultiplier = ([_objective,"hostilityPresenceMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
                private _shift = (_baseShift * _presenceMultiplier) * _durationMultiplier;

                // Sustained insurgent activity slowly normalizes support for the insurgency
                // and makes the remaining combatant sides less welcome in the same area.
                [_pos,_insurgentSides,-_shift] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _insurgentSides,_shift] call ALiVE_fnc_updateSectorHostility;
};

ALiVE_fnc_INS_normalizeHostilitySides = {
                params [["_sides",[]],["_validSides",["EAST","WEST","GUER"]]];

                if !(_sides isEqualType []) then {
                    _sides = [_sides];
                };

                private _normalized = [];

                {
                    private _sideText = "";

                    if (_x isEqualType east) then {
                        _sideText = ([[_x] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText);
                    } else {
                        if (_x isEqualType "") then {
                            _sideText = toUpper _x;
                            if (_sideText == "RESISTANCE") then {_sideText = "GUER"};
                        };
                    };

                    if (_sideText in _validSides) then {
                        _normalized pushBackUnique _sideText;
                    };
                } forEach _sides;

                _normalized
};

ALiVE_fnc_INS_getHostilityPhase = {
                params [["_hostility",0,[0]]];

                private _phase = "Stabilize";

                if (_hostility <= 0) then {
                    _phase = "Consolidate";
                } else {
                    if (_hostility <= 25) then {
                        _phase = "Build";
                    } else {
                        if (_hostility <= 65) then {
                            _phase = "Engage";
                        };
                    };
                };

                _phase
};

ALiVE_fnc_INS_getHeartsAndMindsPressure = {
                params [
                    ["_pos", [], [[]]],
                    ["_insurgentSide", "", ["", east]],
                    ["_radius", 1200, [0]]
                ];

                if (
                    _pos isEqualTo [] ||
                    {isNil "ALIVE_clusterHandler"} ||
                    {isNil "ALIVE_clustersCivSettlement"}
                ) exitwith {[0, "Stabilize", ""]};

                private _insurgentSideText = "";
                if (_insurgentSide isEqualType east) then {
                    _insurgentSideText = [[_insurgentSide] call ALiVE_fnc_sideObjectToNumber] call ALiVE_fnc_sideNumberToText;
                } else {
                    if (_insurgentSide isEqualType "") then {
                        _insurgentSideText = toUpper _insurgentSide;
                        if (_insurgentSideText == "RESISTANCE") then {_insurgentSideText = "GUER"};
                    };
                };

                if !(_insurgentSideText in ["EAST","WEST","GUER"]) then {
                    _insurgentSideText = "EAST";
                };

                private _cluster = nil;
                private _closestDistance = _radius max 0;

                {
                    private _candidateCluster = [ALIVE_clusterHandler, "getCluster", _x] call ALIVE_fnc_clusterHandler;

                    if !(isNil "_candidateCluster") then {
                        private _center = [_candidateCluster, "center", []] call ALIVE_fnc_hashGet;

                        if !(_center isEqualTo []) then {
                            private _distance = _pos distance2D _center;

                            if (_distance <= _closestDistance) then {
                                _closestDistance = _distance;
                                _cluster = _candidateCluster;
                            };
                        };
                    };
                } foreach (ALIVE_clustersCivSettlement select 1);

                if (isNil "_cluster") exitwith {[0, "Stabilize", ""]};

                private _heartsAndMinds = if ("heartsAndMinds" in (_cluster select 1)) then {
                    [_cluster, "heartsAndMinds", []] call ALIVE_fnc_hashGet
                } else {
                    []
                };

                private _hostilityHash = [_cluster, "hostility", []] call ALIVE_fnc_hashGet;
                private _bestPressure = 0;
                private _bestPhase = "Stabilize";

                {
                    if (_x != _insurgentSideText) then {
                        private _hostility = [_hostilityHash, _x, 0] call ALIVE_fnc_hashGet;
                                                private _phase = [_hostility] call ALiVE_fnc_INS_getHostilityPhase;
                        private _support = 0;
                        private _supportState = [];

                        if !(_heartsAndMinds isEqualTo []) then {
                            if (_x in (_heartsAndMinds select 1)) then {
                                _supportState = [_heartsAndMinds, _x, []] call ALIVE_fnc_hashGet;
                                if !(_supportState isEqualTo []) then {
                                    _phase = [_supportState, "phase", _phase] call ALIVE_fnc_hashGet;
                                    if (missionNamespace getVariable ["ALIVE_civicStateEnabled", false]) then {
                                        private _insurgentPressure = [_supportState, "insurgentPressure", 100] call ALIVE_fnc_hashGet;
                                        _support = 100 - ((_insurgentPressure max 0) min 100);
                                    } else {
                                        _support = [_supportState, "support", 0] call ALIVE_fnc_hashGet;
                                    };
                                };
                            };
                        };

                        _support = (_support max 0) min 100;

                        private _phaseWeight = switch (_phase) do {
                            case "Consolidate": {40};
                            case "Build": {28};
                            case "Engage": {14};
                            default {0};
                        };

                        private _pressure = ((_support * 0.6) + _phaseWeight) min 100;

                        if (_pressure > _bestPressure) then {
                            _bestPressure = _pressure;
                            _bestPhase = _phase;
                        };
                    };
                } foreach ["EAST","WEST","GUER"];

                [round _bestPressure, _bestPhase, [_cluster, "clusterID", ""] call ALIVE_fnc_hashGet]
};
ALiVE_fnc_INS_updateHostilityByInstallations = {
                params [
                    "_objective",
                    "_pos",
                    "_insurgentSides",
                    ["_installations",[]],
                    ["_currentHostility",0],
                    ["_interval",600],
                    ["_allSides",["EAST","WEST","GUER"]]
                ];

                _allSides = [_allSides] call ALiVE_fnc_INS_normalizeHostilitySides;
                _insurgentSides = [_insurgentSides] call ALiVE_fnc_INS_normalizeHostilitySides;

                if (count _insurgentSides == 0) exitwith {0};

                private _installationMultiplier = ([_objective,"hostilityInstallationMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
                private _effectiveInterval = ([_objective,"hostilityInstallationInterval",_interval] call ALiVE_fnc_INS_getHostilitySetting) max 0;

                private _covertWeight = 0;
                private _overtWeight = 0;

                {
                    _x params [["_type",""],["_installation",objNull]];

                    if (alive _installation) then {
                        switch (toLower _type) do {
                            case "factory": {_covertWeight = _covertWeight + 2;};
                            case "ied";
                            case "sabotage": {_covertWeight = _covertWeight + 1;};
                            case "hq": {_overtWeight = _overtWeight + 2;};
                            case "depot";
                            case "roadblocks": {_overtWeight = _overtWeight + 1;};
                        };
                    };
                } forEach _installations;

                if ((_covertWeight + _overtWeight) <= 0) exitwith {
                    [_objective,"presenceHostilityTick"] call ALiVE_fnc_HashRem;
                    0
                };

                private _lastUpdate = [_objective,"presenceHostilityTick",-1] call ALiVE_fnc_HashGet;
                if (_lastUpdate < 0) exitwith {
                    [_objective,"presenceHostilityTick",time] call ALiVE_fnc_HashSet;
                    0
                };

                if (time - _lastUpdate < _effectiveInterval) exitwith {0};

                [_objective,"presenceHostilityTick",time] call ALiVE_fnc_HashSet;

                                private _supportWeight = if (_currentHostility > 0) then {
                    // Hostile populations only soften through lower-signature insurgent activity.
                    (_covertWeight * 2) min 4
                } else {
                    (_covertWeight + _overtWeight) min 4
                };

                private _civicInstallationMultiplier = ([_objective,"civicInstallationMultiplier",1] call ALiVE_fnc_INS_getHostilitySetting) max 0;
                if (_civicInstallationMultiplier > 0) then {
                    private _pressureSide = if (count _insurgentSides > 0) then {_insurgentSides select 0} else {"EAST"};
                    private _hmPressureData = [_pos,_pressureSide,1200] call ALiVE_fnc_INS_getHeartsAndMindsPressure;
                    _hmPressureData params [["_hmPressure",0]];
                    private _civicDampening = ((_hmPressure / 100) * (0.8 * _civicInstallationMultiplier)) min 0.95;
                    _supportWeight = round (_supportWeight * ((1 - _civicDampening) max 0));
                };

                if (_supportWeight <= 0) exitwith {0};

                private _insurgentShift = -(_supportWeight * _installationMultiplier);
                private _otherShift = ((ceil (_supportWeight / 2)) min 2) * _installationMultiplier;

                [_pos,_insurgentSides,_insurgentShift] call ALiVE_fnc_updateSectorHostility;
                [_pos,_allSides - _insurgentSides,_otherShift] call ALiVE_fnc_updateSectorHostility;

                _insurgentShift
};

ALiVE_fnc_INS_assault = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_CAPTURE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_ambush = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_road","_roadObject","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _road = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _roadObject = [[],"convertObject",_road] call ALiVE_fnc_OPCOM;

                // Establish ambush position
                if (alive _roadObject) then {[_objective,"ambush",_road] call ALiVE_fnc_HashSet};

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Place ambient IED trigger
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",getposATL _roadObject];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",true];
                    _trg setTriggerStatements [
                        "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                            format["null = [getpos thisTrigger,%1,%2,%3] call ALIVE_fnc_createIED",100,text _id,ceil(random 2)],
                            format["null = [getpos thisTrigger,%1] call ALIVE_fnc_removeIED",text _id]
                    ];
                };

                _event = ['OPCOM_RECON',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                // Wait 15 minutes for any enemy vehicles to pass before reassigning
                _timeTaken = time; waituntil {time - _timeTaken > 900};

                // Remove ambush marker
                if (alive _roadObject) then {deletemarker format["Ambush_%1",getposATL _roadObject]; [_objective,"ambush"] call ALiVE_fnc_HashRem};
};

ALiVE_fnc_INS_retreat = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_objective","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _sides = _this select 5;
                _agents = _this select 6;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_allSides - _sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                //remove installations if existing
                {
                    _object = [[],"convertObject",[_objective,_x,[]] call ALiVE_fnc_HashGet] call ALiVE_fnc_OPCOM;

                    if (alive _object && {_x in ["ied","suicide"]}) then {deletevehicle _object};
                    if (alive _object) then {_object setdamage 1; deleteMarker format["%1_%2",_x,_id]};

                    [_objective,_x] call ALiVE_fnc_HashRem;
                } foreach ["factory","hq","ambush","depot","sabotage","ied","suicide"];

                // Reset all actions done on that objective so they can be performed again
                [_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashSet;

                // Reduce hostility level after retreat
                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                _event = ['OPCOM_DEFEND',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_factory = {
                private ["_timeTaken","_pos","_center","_id","_size","_faction","_sides","_agents","_building","_objective","_CQB","_event","_eventID"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Store center position
                _center = _pos;

                // Establish factory
                if (alive _factory) then {
                    // Get indoor Housepos
                    _pos = getposATL _factory;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create factory
                    [_factory,_id] call ALiVE_fnc_INS_spawnIEDfactory;

                    // Create virtual guards
                    {[_x,"addHouse",_factory] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set factory
                    [_objective,"factory",[[],"convertObject",_factory] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Reset to center position
                _pos = _center;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_ied = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_section","_objective", "_num"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // If IED module is used add IEDs and VBIEDs according to IED module settings
                if (!isnil "ALiVE_MIL_IED") then {
                    _trg = createTrigger ["EmptyDetector",_pos];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",true];
                    _num = ceil(_size/100);
                    _trg setTriggerStatements [
                        "this && {(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0",
                            format["null = [getpos thisTrigger,%1,'%2',%3] call ALIVE_fnc_createIED",_size,text _id,_num],
                            format["null = [getpos thisTrigger,'%1'] call ALIVE_fnc_removeIED",text _id]
                    ];

                    [MOD(MIL_IED), "storeTrigger", [_size,format["%1",_id],_pos,true,"IED",_num]] call ALiVE_fnc_IED;

                    [_pos,_size,1] call ALiVE_fnc_placeVBIED;

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"ied",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM rogue command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_suicide = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_objective","_civFactions"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _civFactions = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Place ambient suiciders trigger
                if (!isnil "ALiVE_mil_IED") then {
                    _trg = createTrigger ["EmptyDetector",_pos];
                    _trg setTriggerArea [_size + 250, _size + 250,0,false];
                    _trg setTriggerActivation ["ANY","PRESENT",false];
                    _trg setTriggerStatements [
                        "this && ({(vehicle _x in thisList) && ((getposATL _x) select 2 < 25)} count ([] call BIS_fnc_listPlayers) > 0)",
                        format ["null = [[getpos thisTrigger,%1,'%2'],thisList] call ALIVE_fnc_createBomber", _size, (selectRandom _civFactions)],
                         ""
                    ];

                    _placeholders = ((nearestobjects [_pos,["Static"],150]) + (_pos nearRoads 150));
                    if (!isnil "_placeholders" && {count _placeholders > 0}) then {_trg = _placeholders select 0};

                    [_objective,"suicide",[[],"convertObject",_trg] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM suicide command on one ambient civilian agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_suicideTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_sabotage = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_target","_profileID","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _factory = _this select 5;
                _target = _this select 6;
                _sides = _this select 7;
                _agents = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Convert to data that can be persistet
                _factory = [[],"convertObject",_factory] call ALiVE_fnc_OPCOM;
                _target = [[],"convertObject",_target] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Assign sabotage target
                if (alive _target) then {[_objective,"sabotage",[[],"convertObject",_target] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet};

                // Add TACOM Sabotage command on all selected agents
                {
                    private ["_agent"];
                     _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_sabotage", "managed", [getposATL _target]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                _event = ['OPCOM_TERRORIZE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                // Wait 15 minutes for Sabotage to happen
                _timeTaken = time; waituntil {time - _timeTaken > 900};
};

ALiVE_fnc_INS_getRoadblockActionObject = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                private _roadblockPos = if (_roadblockSource isEqualType objNull) then {
                    getPosATL _roadblockSource
                } else {
                    _roadblockSource
                };

                private _actionObject = objNull;
                private _barGates = nearestObjects [_roadblockPos, ["Land_BarGate_F"], 10];

                if !(_barGates isEqualTo []) then {
                    _actionObject = _barGates select 0;
                } else {
                    private _helpers = (nearestObjects [_roadblockPos, ["Box_FIA_Wps_F"], 12]) select {
                        _x getVariable [QGVAR(ROADBLOCK_HELPER), false]
                    };

                    if !(_helpers isEqualTo []) then {
                        _actionObject = _helpers select 0;
                    } else {
                        private _nearRoads = _roadblockPos nearRoads 10;
                        private _anchorPos = +_roadblockPos;
                        private _direction = 0;

                        if !(_nearRoads isEqualTo []) then {
                            private _road = _nearRoads select 0;
                            private _connectedRoads = roadsConnectedTo _road;

                            if !(_connectedRoads isEqualTo []) then {
                                _direction = _road getDir (_connectedRoads select 0);
                            };

                            _anchorPos = getPosATL _road;
                        };

                        _actionObject = createVehicle ["Box_FIA_Wps_F", _anchorPos, [], 0, "CAN_COLLIDE"];
                        _actionObject allowDamage false;
                        _actionObject setDir _direction;
                        _actionObject setPosATL (_anchorPos getPos [6, _direction + 90]);
                        _actionObject setVectorUp (surfaceNormal (getPosWorld _actionObject));
                        _actionObject setVariable [QGVAR(ROADBLOCK_HELPER), true, true];
                    };
                };

                _actionObject
};

ALiVE_fnc_INS_addRoadblockHoldAction = {
                params [["_roadblockSource", objNull, [objNull, []]]];

                private _actionObject = [_roadblockSource] call ALiVE_fnc_INS_getRoadblockActionObject;
                if (isNull _actionObject) exitwith {};

                if (_actionObject getVariable [QGVAR(ROADBLOCK_DISABLED), false]) exitwith {};

                private _chargePos = if (_roadblockSource isEqualType objNull) then {
                    getPosATL _roadblockSource
                } else {
                    _roadblockSource
                };

                private _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo", _chargePos, [], 0, "CAN_COLLIDE"];
                _charge hideObjectGlobal true;
                _charge allowDamage false;

                [
                    _actionObject,
                    "disable the roadblock!",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                    "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
                    "_this distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_ROADBLOCK_DISABLED', false])}",
                    "_caller distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_ROADBLOCK_DISABLED', false])}",
                    {},
                    {},
                    {
                        params ["_target", "_caller", "_ID", "_arguments"];

                        private _charge = _arguments select 0;

                        _target setVariable [QGVAR(ROADBLOCK_DISABLED), true, true];
                        [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];

                        [getPosATL _charge, 30] remoteExec ["ALiVE_fnc_RemoveComposition", 2];

                        ["Nice Job", format ["%1 disabled the roadblock at grid %2!", name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle", side (group _caller)];

                        if (_target getVariable [QGVAR(ROADBLOCK_HELPER), false]) then {
                            deleteVehicle _target;
                        };

                        deleteVehicle _charge;
                    },
                    {},
                    [_charge],
                    15
                ] remoteExec ["BIS_fnc_holdActionAdd", 0, _actionObject];
};

ALiVE_fnc_INS_roadblocks = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_building","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _handle = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;

                    if (!isnil "_agent" && {([_agent,"type",""] call ALiVE_fnc_HashGet) == "agent"}) exitwith {
                        [_agent, "setActiveCommand", ["ALIVE_fnc_cc_rogueTarget", "managed", [_sides]]] call ALIVE_fnc_civilianAgent;
                    };
                } foreach _agents;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Spawn roadblock only until a max amount of roadblocks per objective is reached (size 600 will allow for 3 roadblocks)
                if (isnil "ALiVE_CIV_PLACEMENT_ROADBLOCKS" || {{_pos distance _x < _size} count ALiVE_CIV_PLACEMENT_ROADBLOCKS < ceil(_size/200)}) then {
                    private _roads = [_pos, _size, ceil(_size/200), false] call ALiVE_fnc_createRoadblock;

                    // Create disable action on newly created roadblocks
                    {
                        [_x] call ALiVE_fnc_INS_addRoadblockHoldAction;
                    } foreach _roads;
                };

                // Identify location
                [_objective,"roadblocks",[[],"convertObject",_pos nearestObject "building"] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_depot = {
                private ["_timeTaken","_center","_id","_size","_faction","_sides","_agents","_depot","_CQB","_objective"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _depot = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;

                // Store center position
                _center = _pos;

                // Convert to data that can be persistet
                _depot = [[],"convertObject",_depot] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Establish Depot
                if (alive _depot) then {
                    [_depot,_id] call ALiVE_fnc_INS_spawnDepot;

                    // Create virtual guards
                    {[_x,"addHouse",_depot] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set depot
                    [_objective,"depot",[[],"convertObject",_depot] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM get weapons command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Spawn CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;

                [_timeTaken,_pos,[_side],20,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;
};

ALiVE_fnc_INS_recruit = {
                private ["_timeTaken","_pos","_id","_size","_faction","_sides","_agents","_HQ","_CQB","_objective","_center","_opcom","_forceLimit","_recruitCycleMin","_recruitCycleMax","_recruitAttemptLimit","_recruitSuccessChance","_opcomFactions","_civicRecruitmentMultiplier"];

                _timeTaken = _this select 0;
                _pos = _this select 1;
                _id = _this select 2;
                _size = _this select 3;
                _faction = _this select 4;
                _HQ = _this select 5;
                _sides = _this select 6;
                _agents = _this select 7;
                _CQB = _this select 8;
                _side = _faction call ALiVE_fnc_factionSide;
                _allSides = ["EAST","WEST","GUER"];
                _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
                _opcom = [_objective] call ALiVE_fnc_INS_getOpcomByObjective;
                _forceLimit = -1;
                _recruitCycleMin = 1800;
                _recruitCycleMax = 3600;
                _recruitAttemptLimit = 0;
                _recruitSuccessChance = 0.5;
                _opcomFactions = [_faction];
                _civicRecruitmentMultiplier = 1;

                if !(isnil "_opcom") then {
                    _forceLimit = floor ([_opcom,"asymForceLimit",-1] call ALiVE_fnc_HashGet);
                    _recruitCycleMin = (([_opcom,"recruitCycleMin",30] call ALiVE_fnc_HashGet) max 0) * 60;
                    _recruitCycleMax = (([_opcom,"recruitCycleMax",60] call ALiVE_fnc_HashGet) max 0) * 60;
                    _recruitAttemptLimit = floor ([_opcom,"recruitAttemptLimit",0] call ALiVE_fnc_HashGet);
                    _recruitAttemptLimit = _recruitAttemptLimit max -1;
                    _recruitSuccessChance = ((([_opcom,"recruitSuccessChance",50] call ALiVE_fnc_HashGet) max 0) min 100) / 100;
                    _opcomFactions = [_opcom,"factions",[_faction]] call ALiVE_fnc_HashGet;
                    _civicRecruitmentMultiplier = ([_opcom,"civicRecruitmentMultiplier",1] call ALiVE_fnc_HashGet) max 0;
                };

                if (_recruitCycleMax < _recruitCycleMin) then {_recruitCycleMax = _recruitCycleMin};

                // Store center position
                _center = _pos;

                // Convert to data that can be persistet
                _HQ = [[],"convertObject",_HQ] call ALiVE_fnc_OPCOM;

                // Convert CQB modules
                {_CQB set [_foreachIndex,[[],"convertObject",_x] call ALiVE_fnc_OPCOM]} foreach _CQB;

                // Timeout
                waituntil {time - _timeTaken > 120};

                // Establish HQ
                if (alive _HQ) then {
                    // Create HQ
                    [_HQ,_id] call ALiVE_fnc_INS_spawnHQ;

                    // Get indoor Housepos
                    _pos = getposATL _HQ;
                    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;
                    _pos = if (count _positions > 0) then {(selectRandom _positions)} else {_pos};

                    // Create virtual guards
                    {[_x,"addHouse",_HQ] call ALiVE_fnc_CQB} foreach _CQB;

                    // Set HQ
                    [_objective,"HQ",[[],"convertObject",_HQ] call ALiVE_fnc_OPCOM] call ALiVE_fnc_HashSet;
                };

                // Add TACOM IED command on all selected agents
                {
                    private ["_agent"];
                    _agent = [ALiVE_AgentHandler,"getAgent",_x] call ALiVE_fnc_AgentHandler;
                    if (!isnil "_agent" && {_foreachIndex < 3}) then {[_agent, "setActiveCommand", ["ALIVE_fnc_cc_getWeapons", "managed", [_pos]]] call ALIVE_fnc_civilianAgent};
                } foreach _agents;

                // Restore center position
                _pos = _center;

                // Add CQB
                [_pos,_size,_CQB] call ALiVE_fnc_addCQBpositions;

                // Run recruitment attempts while the HQ survives.
                [_timeTaken,_pos,_size,_id,_faction,_HQ,_sides,_agents,_forceLimit,_recruitCycleMin,_recruitCycleMax,_recruitAttemptLimit,_recruitSuccessChance,_opcomFactions,_civicRecruitmentMultiplier,_side,_objective] spawn {
                    private ["_timeTaken","_pos","_size","_id","_faction","_targetBuilding","_sides","_agents","_forceLimit","_recruitCycleMin","_recruitCycleMax","_recruitAttemptLimit","_recruitSuccessChance","_opcomFactions","_civicRecruitmentMultiplier","_currentForce","_attemptsRemaining","_side","_objective"];

                    _timeTaken = _this select 0;
                    _pos = _this select 1;
                    _size = _this select 2;
                    _id = _this select 3;
                    _faction = _this select 4;
                    _HQ = _this select 5;
                    _sides = _this select 6;
                    _agents = _this select 7;
                    _forceLimit = _this select 8;
                    _recruitCycleMin = _this select 9;
                    _recruitCycleMax = _this select 10;
                    _recruitAttemptLimit = _this select 11;
                    _recruitSuccessChance = _this select 12;
                    _opcomFactions = _this select 13;
                    _civicRecruitmentMultiplier = _this select 14;
                    _side = _this select 15;
                    _objective = _this select 16;
                    _allSides = ["EAST","WEST","GUER"];

                    _attemptsRemaining = if (_recruitAttemptLimit == 0) then {count _agents} else {_recruitAttemptLimit};

                    while {alive _HQ && {_attemptsRemaining != 0}} do {

                        private _hmPressureData = [_pos,_side,(_size + 600) max 900] call ALiVE_fnc_INS_getHeartsAndMindsPressure;
                        _hmPressureData params [["_hmPressure",0],["_hmPhase","Stabilize"]];

                        private _effectivePressure = ((_hmPressure * _civicRecruitmentMultiplier) max 0) min 100;
                        private _delayMultiplier = 1 + (0.01 * _effectivePressure);
                        private _adjustedCycleMin = _recruitCycleMin * _delayMultiplier;
                        private _adjustedCycleMax = _recruitCycleMax * _delayMultiplier;

                        // Delay between recruitment attempts.
                        sleep (_adjustedCycleMin + random ((_adjustedCycleMax - _adjustedCycleMin) max 0));

                        // Only recruit while the HQ still exists.
                        if (!alive _HQ) exitwith {};

                        // Positive values are finite attempt counts, negative values are unlimited.
                        if (_attemptsRemaining > 0) then {
                            _attemptsRemaining = _attemptsRemaining - 1;
                        };

                        _currentForce = -1;
                        if (_forceLimit > -1 && {!isnil "ALIVE_profileHandler"}) then {
                            _currentForce = 0;
                            {
                                _currentForce = _currentForce + count ([ALIVE_profileHandler, "getProfilesByFaction",_x] call ALIVE_fnc_profileHandler);
                            } foreach _opcomFactions;
                        };

                        if !(_forceLimit > -1 && {_currentForce >= _forceLimit}) then {
                            private _phaseChanceMultiplier = switch (_hmPhase) do {
                                case "Consolidate": {0.35};
                                case "Build": {0.5};
                                case "Engage": {0.75};
                                default {1};
                            };
                            private _pressureChanceMultiplier = (1 - (0.007 * _effectivePressure)) max 0.2;
                            private _effectiveRecruitChance = (_recruitSuccessChance * _phaseChanceMultiplier * _pressureChanceMultiplier) min 1;

                            // Use the configured chance for a successful recruitment spawn.
                            if (random 1 < _effectiveRecruitChance) then {
	                            _group = ["Infantry",_faction] call ALIVE_fnc_configGetRandomGroup;
	                            _recruits = [_group, [_pos,10,_size,1,0,0,0,[],[_pos]] call BIS_fnc_findSafePos, random(360), true, _faction] call ALIVE_fnc_createProfilesFromGroupConfig;
	                            {[_x, "setActiveCommand", ["ALIVE_fnc_ambientMovement","spawn",[_size + 200,"SAFE",[0,0,0]]]] call ALIVE_fnc_profileEntity} foreach _recruits;

	                            [_timeTaken,_pos,[_side],10,_allSides,_objective] call ALiVE_fnc_INS_updateHostilityByPresence;

                            };
                        };
                    };
                };

                _event = ['OPCOM_RESERVE',[_side,_objective],"OPCOM"] call ALIVE_fnc_event;
                _eventID = [ALIVE_eventLog, "addEvent",_event] call ALIVE_fnc_eventLog;
};

ALiVE_fnc_INS_idle = {
    private ["_time"];

    _time = time;

    waituntil {time - _time > _this};
};

ALiVE_fnc_spawnFurniture = {

    private ["_pos","_furniture","_bomb","_box","_created"];

    _building = _this select 0;
    _ieds = _this select 1;
    _add = _this select 2;
    _ammo = _this select 3;

    if (!(alive _building) || {count (_building getvariable [QGVAR(furnitured),[]]) > 0}) exitwith {[]};

    _furnitures = ["Land_RattanTable_01_F"];
    _bombs = ["ALIVE_IEDUrbanSmall_Remote_Ammo","ALIVE_IEDLandSmall_Remote_Ammo","ALIVE_IEDLandBig_Remote_Ammo"];
    _objects = ["Land_Canteen_F","Land_TinContainer_F"];
    _boxes = ["VirtualReammoBox_small_F"];
    _created = [];

    _pos = getposATL _building;
    _positions = [_pos,15] call ALIVE_fnc_findIndoorHousePositions;

    if (count _positions == 0) exitwith {
        ["ALiVE MIL OPCOM Insurgency has not found indoor Houspositions to place IED Factory/HQ/depot objects for building %1 at %2",_building, getposATL _building] call ALiVE_fnc_Dump;
        [];
    };

    {
        private ["_pos"];

        _pos = _x;

        if ({(_pos select 2) - (_x select 2) < 0.5} count _positions > 1) then {
            if (random 1 < 0.3) then {
                _furniture = createVehicle [(selectRandom _furnitures), _pos, [], 0, "CAN_COLLIDE"];
                _furniture setposATL _pos;
                _furniture setdir getdir _building;

                // Disable sim to avoid flipping furniture. Bombs are not affected and still exploding.
                // Once building is destroyed or site is disabled, the furniture gets deleted.
                _furniture enableSimulation false;

                _created pushback _furniture;

                if (_ieds) then {
                    _bomb = createVehicle [(selectRandom _bombs), getposATL _furniture, [], 0, "CAN_COLLIDE"];
                    _charge = createVehicle ["ALIVE_DemoCharge_Remote_Ammo",getposATL _bomb, [], 0, "CAN_COLLIDE"];

                    _bomb attachTo [_furniture, [0,0,_furniture call ALiVE_fnc_getRelativeTop]];
                    _charge attachTo [_bomb, [0,0,0]];

                    // Add damage handler
                    _ehID = _charge addeventhandler ["HandleDamage",{
                        private ["_trgr","_IED"];

                        if (isPlayer (_this select 3)) then {
                            _bomb = attachedTo (_this select 0);
                            _ehID = _bomb getVariable "ehID";

                            "M_Mo_120mm_AT" createVehicle [(getpos (_this select 0)) select 0, (getpos (_this select 0)) select 1,0];

                            _bomb removeEventhandler ["HandleDamage",_ehID];

                            deletevehicle (_this select 0);
                            deleteVehicle _bomb;
                        };
                    }];

                    _bomb setVariable ["ehID",_ehID, true];
                    _bomb setvariable ["charge", _charge, true];

                    _created pushback _bomb;
                    _created pushback _charge;
                };
            } else {
                if (_add && {random 1 < 0.5}) then {
                    _furniture = createVehicle [(selectRandom _furnitures), _pos, [], 0, "CAN_COLLIDE"];
                    _furniture setdir getdir _building;

                    _object = createVehicle [(selectRandom _objects), _pos, [], 0, "CAN_COLLIDE"];
                    _object attachTo [_furniture, [0,0,(_furniture call ALiVE_fnc_getRelativeTop) + 0.15]];
 
                    _created pushback _furniture;
                    _created pushback _object;
                } else {
                    if (_ammo && {random 1 < 0.5}) then {
                        _box = createVehicle [(selectRandom _boxes), _pos, [], 0, "CAN_COLLIDE"];
                        _box setdir (_building getDir _box);

                        _created pushback _box;
                    };
                };
            };
        };
    } foreach _positions;

    _building setvariable [QGVAR(furnitured),_created];

    _created
};

ALiVE_fnc_INS_spawnIEDfactory = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(factory),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the IED factory!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_FACTORY_DISABLED', false])}",
        "_caller distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_FACTORY_DISABLED', false])}",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(FACTORY_DISABLED),true,true];
            [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];

            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Nice Job", format ["%1 disabled the IED factory at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0, _building];

    [_building,true,false,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnHQ = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(HQ),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the Recruitment HQ!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_HQ_DISABLED', false])}",
        "_caller distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_HQ_DISABLED', false])}",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(HQ_DISABLED),true,true];
            [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];
            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Congratulations", format ["%1 disabled the Recruitment HQ at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0, _building];

    [_building,true,false,false] call ALiVE_fnc_spawnFurniture;
    [_building,true,true,false] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_INS_spawnDepot = {
    private ["_building","_id"];

    _building = _this select 0;
    _id = _this select 1;

    if !(alive _building) exitwith {};

    _building setvariable [QGVAR(depot),_id];
    _building addEventHandler["killed", ALIVE_fnc_INS_buildingKilledEH];

    [
        _building,
        "disable the weapons depot!",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
        "_this distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_DEPOT_DISABLED', false])}",
        "_caller distance2D _target < 3 && {!(_target getVariable ['ALiVE_MIL_OPCOM_DEPOT_DISABLED', false])}",
        {},
        {},
        {
            params ["_target", "_caller", "_ID", "_arguments"];

            _target setVariable [QGVAR(DEPOT_DISABLED),true,true];
            [_target, _ID] remoteExec ["BIS_fnc_holdActionRemove", 0, _target];
            [_target, _caller] remoteExec ["ALIVE_fnc_INS_buildingKilledEH",2];

            ["Good work", format ["%1 disabled the weapons depot at grid %2!",name _caller, mapGridPosition _target]] remoteExec ["BIS_fnc_showSubtitle",side (group _caller)];
        },
        {},
        [],
        10 + ((count (_building getvariable [QGVAR(furnitured),[]]))*4)
    ] remoteExec ["BIS_fnc_holdActionAdd", 0, _building];

    [_building,true,false,true] call ALiVE_fnc_spawnFurniture;
};

ALiVE_fnc_getRelativeTop = {

    _object = _this;

    _bbr = boundingBoxReal _object;
    _p1 = _bbr select 0; _p2 = _bbr select 1;
    _height = abs((_p2 select 2)-(_p1 select 2));
    _height/2;
};

ALIVE_fnc_INS_buildingKilledEH = {

    private ["_building","_killer","_id","_opcom","_pos"];

    _building = _this select 0;
    _killer = _this select 1;
    _pos = getposATL _building;

    private _factory = _building getvariable QGVAR(factory);
    private _depot = _building getvariable QGVAR(depot);
    private _HQ = _building getvariable QGVAR(HQ);
    private _furniture = _building getvariable [QGVAR(furnitured),[]];

    private _installationType = "";
    if !(isnil "_factory") then {
        _id = _factory;
        _installationType = "factory";
    };
    if !(isnil "_depot") then {
        _id = _depot;
        _installationType = "depot";
    };
    if !(isnil "_HQ") then {
        _id = _HQ;
        _installationType = "hq";
    };

    if (isnil "_id") exitwith {};

    // fire event
    // TODO: cba events should be fired from core event loop, not here

    ["ASYMM_INSTALLATION_DESTROYED", [_installationType,_building,_killer]] call CBA_fnc_globalEvent;

    private _event = ['ASYMM_INSTALLATION_DESTROYED', [_installationType,_building,_killer],"OPCOM"] call ALIVE_fnc_event;
    [ALiVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;

    private _objective = [[],"getobjectivebyid",_id] call ALiVE_fnc_OPCOM;
    private _opcomID = [_objective,"opcomID",""] call ALiVE_fnc_HashGet;
    _pos = [_objective,"center",_pos] call ALiVE_fnc_HashGet;

    if !(isnil "_factory") then {
        [_objective,"factory"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["factory"]] call ALiVE_fnc_HashSet;
    };
    if !(isnil "_depot") then {
        [_objective,"depot"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["depot"]] call ALiVE_fnc_HashSet;
    };
    if !(isnil "_HQ") then {
        [_objective,"HQ"] call ALiVE_fnc_HashRem;
        [_objective,"actionsFulfilled",([_objective,"actionsFulfilled",[]] call ALiVE_fnc_HashGet) - ["recruit"]] call ALiVE_fnc_HashSet;
    };

    {deleteVehicle _x} foreach _furniture;
    _building setvariable [QGVAR(furnitured),[]];

    {
        if (([_x,"opcomID"," "] call ALiVE_fnc_HashGet) == _opcomID) exitwith {
            _opcom = _x
        }
    } foreach OPCOM_instances;

    if !(isnil "_opcom") then {
        private _opcomSide = [_opcom,"side",""] call ALiVE_fnc_HashGet;
        private _allSides = ["EAST","WEST","GUER"];

        [_pos,[_opcomSide], 50] call ALiVE_fnc_updateSectorHostility;
        [_pos,_allSides - [_opcomSide], -50] call ALiVE_fnc_updateSectorHostility;
    };
};

ALiVE_fnc_INS_compileList = {
            private ["_list"];

            _list = str(_this);
            _list = [_list, "[", ""] call CBA_fnc_replace;
            _list = [_list, "]", ""] call CBA_fnc_replace;
            _list = [_list, "'", ""] call CBA_fnc_replace;
            _list = [_list, """", ""] call CBA_fnc_replace;
            _list = [_list, ",", ", "] call CBA_fnc_replace;
            _list;
};

ALiVE_fnc_INS_filterObjectiveBuildings = {

    params ["_center","_size"];

    private _buildings = [_center, _size] call ALiVE_fnc_getEnterableHouses;

    //["Enterable buildings total: %1",_buildings] call ALiVE_fnc_DumpR;

    {
        private _h = _x;
        private _type = typeOf _h;
        private _index = _foreachIndex;
        private _blacklist = ["tower","cage","platform","trench","bridge"];

        //["Building selected: %1 | %2",typeOf _h, _h] call ALiVE_fnc_DumpR;

        private _buildingPositions = [getposATL _h,5] call ALIVE_fnc_findIndoorHousePositions;
        
        if (count _buildingPositions == 0) then {
            //["Deleted buildingtype %1! No indoor houseposition!",typeof _h] call ALiVE_fnc_DumpR;
            _buildings set [_index,objNull];
        } else {          
            private _dimensions = _h call BIS_fnc_boundingBoxDimensions;

            // too small
            if (((_dimensions select 0) + (_dimensions select 1)) < 10) then {
                //["Deleted buildingtype %1! Building is too small!",typeof _h] call ALiVE_fnc_DumpR;

                _buildings set [_index,objNull];
            } else {
                if (
                    //Building is double as high as broad and is very likely a tower, or contains a blacklisted class
                    (((_dimensions select 2)/2) > (_dimensions select 0) && {((_dimensions select 2)/2) > (_dimensions select 1)})
                    ||
                    {{[_type , _x] call CBA_fnc_find != -1} count _blacklist > 0}
                ) then {
                    //["Deleted buildingtype %1! Building is a tower or blacklisted!",typeof _h] call ALiVE_fnc_DumpR;
                    _buildings set [_index,objNull];
                };
            };
        };
    } foreach _buildings;

    _buildings = _buildings - [objNull];

    //["Enterable buildings filtered: %1",_buildings] call ALiVE_fnc_DumpR;

    _buildings;
};
