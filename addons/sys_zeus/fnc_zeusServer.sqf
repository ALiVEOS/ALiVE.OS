#include "\x\alive\addons\sys_zeus\script_component.hpp"
SCRIPT(zeusServer);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_zeusServer

Description:
Server: what each ALiVE Zeus module does. Reached only through ALiVE_fnc_zeusRequest, which
has checked the Zeus. Each module checks the ALiVE module it needs is in the mission and tells
the Zeus when it isn't, and replies with what it did.

Parameters:
String - the module
Array - its arguments
Object - the Zeus player

Returns:
nothing

Author:
Jman
---------------------------------------------------------------------------- */

// Only ALiVE_fnc_zeusRequest may call this, and it sets _ALiVE_zeusCaller first. No CfgRemoteExec
// ships, so a client could otherwise call it straight, or bounce it off the server with a
// remoteExec of remoteExec; checking where the call came from would let the bounce through
if (isNil "_ALiVE_zeusCaller") exitWith {};
if (!isServer) exitWith {};

params [
    ["_action", "", [""]],
    ["_args", [], [[]]],
    ["_caller", objNull, [objNull]]
];

if (isNull _caller) exitWith {};

private _reply = {
    params ["_key", ["_fmt", []]];
    [_key, _fmt] remoteExecCall ["ALiVE_fnc_zeusFeedback", _caller];
};

// The nearest living player within range who isn't a Zeus, or objNull. A Zeus is never a target:
// the IED module's own bomber leaves out anyone with Zeus and deletes itself with no one left
private _nearestVictim = {
    params ["_at", "_range"];
    private _near = allPlayers select {
        alive _x && {isNull (getAssignedCuratorLogic _x)} && {(vehicle _x) distance2D _at < _range}
    };
    if (_near isEqualTo []) exitWith { objNull };
    ([_near, [], { (vehicle _x) distance2D _at }, "ASCEND"] call BIS_fnc_sortBy) select 0
};

private _profilesReady = {
    (missionNamespace getVariable ["ALIVE_profileSystemInit", false]) && {!isNil "ALIVE_profileHandler"}
};

// "WEST", "EAST" or "GUER" (or "CIV") from a side or the name of one
private _sideText = {
    private _s = if (_this isEqualType west) then { str _this } else { toUpper _this };
    if (_s in ["RESISTANCE", "INDEPENDENT"]) then { "GUER" } else { _s }
};

private _sideName = {
    localize (switch (_this) do { case "WEST": {"STR_ALIVE_ZEUS_SIDE_WEST"}; case "EAST": {"STR_ALIVE_ZEUS_SIDE_EAST"}; case "CIV": {"STR_ALIVE_ZEUS_SIDE_CIV"}; default {"STR_ALIVE_ZEUS_SIDE_GUER"} })
};

// The side of the nearest player who isn't a Zeus or a civilian, or "" with none: who a plain
// module works for when it can't ask
private _playerSideNear = {
    params ["_at"];
    private _near = allPlayers select { alive _x && {isNull (getAssignedCuratorLogic _x)} && {side group _x != civilian} };
    if (_near isEqualTo []) exitWith { "" };
    (side group (([_near, [], { (vehicle _x) distance2D _at }, "ASCEND"] call BIS_fnc_sortBy) select 0)) call _sideText
};

switch (_action) do {

    // Saves once now, as the "now" autosave does; only with the Data module on local persistence
    case "save": {
        if (isNil "ALiVE_SYS_DATA_SOURCE" || {ALiVE_SYS_DATA_SOURCE != "pns"}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PNS"] call _reply;
        };
        "now" call ALiVE_fnc_AUTOSAVE_PNS;
        ["STR_ALIVE_ZEUS_SAVE_DONE"] call _reply;
    };

    // Profile debug markers on or off, for everyone, as the admin action does
    case "debug": {
        if (isNil "ALIVE_profileHandler") exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        ["profiles"] call ALIVE_fnc_debugHandler;
        private _on = [ALIVE_profileHandler, "debug"] call ALIVE_fnc_profileHandler;
        [["STR_ALIVE_ZEUS_DEBUG_OFF", "STR_ALIVE_ZEUS_DEBUG_ON"] select _on] call _reply;
    };

    // The enemy within 150 m of the spot become known to the side's AI Commanders for 30 minutes,
    // as a player's spot report does. An empty side tells every side with an AI Commander
    case "spotReport": {
        _args params [["_position", [], [[]]], ["_side", "", [""]]];
        if (count _position < 2) exitWith {};
        if !(call _profilesReady) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        private _sides = [];
        {
            private _s = [_x, "side", ""] call ALiVE_fnc_HashGet;
            if (_s in ["RESISTANCE", "INDEPENDENT"]) then { _s = "GUER" };
            if (_s != "" && {!(_s in _sides)} && {_side == "" || {_s == _side}}) then { _sides pushBack _s };
        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
        if (_sides isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_NEED_COMMANDER"] call _reply;
        };
        { ["report", _x, [_position]] call ALIVE_fnc_taskKnownEnemy } forEach _sides;
        private _names = _sides apply { localize (switch (_x) do { case "WEST": {"STR_ALIVE_ZEUS_SIDE_WEST"}; case "EAST": {"STR_ALIVE_ZEUS_SIDE_EAST"}; default {"STR_ALIVE_ZEUS_SIDE_GUER"} }) };
        ["STR_ALIVE_ZEUS_SPOTREPORT_DONE", [_names joinString ", ", mapGridPosition _position]] call _reply;
    };

    // The group becomes ALiVE profiles, so it spawns and despawns with the rest, and an AI
    // Commander with its faction takes it on. Its men are made again, so Zeus has to pick them
    // up anew
    case "handGroup": {
        _args params [["_group", grpNull, [grpNull]]];
        if (isNull _group || {(units _group) findIf {alive _x} == -1}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_UNIT"] call _reply;
        };
        if ((units _group) findIf {isPlayer _x} > -1) exitWith {
            ["STR_ALIVE_ZEUS_HANDGROUP_PLAYERS"] call _reply;
        };
        // Riding in a vehicle another group crews: profiling deletes the vehicle, and that crew
        // with it
        if ((units _group) findIf { vehicle _x != _x && {(crew vehicle _x) findIf {group _x != _group} > -1} } > -1) exitWith {
            ["STR_ALIVE_ZEUS_HANDGROUP_SHARED"] call _reply;
        };
        if ((leader _group) getVariable ["profileID", ""] != "") exitWith {
            ["STR_ALIVE_ZEUS_HANDGROUP_ALREADY"] call _reply;
        };
        if !(call _profilesReady) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        private _faction = faction (leader _group);
        private _created = ([false, [_group], []] call ALIVE_fnc_createProfilesFromUnitsRuntime) select 0;
        if (_created isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_HANDGROUP_FAILED"] call _reply;
        };
        private _hasCommander = (missionNamespace getVariable ["OPCOM_instances", []]) findIf {
            (toLower _faction) in (([_x, "factions", []] call ALiVE_fnc_HashGet) apply { toLower _x })
        } > -1;
        [["STR_ALIVE_ZEUS_HANDGROUP_NOCOMMANDER", "STR_ALIVE_ZEUS_HANDGROUP_DONE"] select _hasCommander, [_faction]] call _reply;
    };

    // An ALiVE suicide bomber, with the IED module's vest, goes for the nearest player within
    // 300 m who isn't a Zeus. With no one there it would be made and deleted, so it isn't made
    case "bomber": {
        _args params [["_position", [], [[]]], ["_faction", "", [""]], ["_radius", 50, [0]]];
        if (count _position < 2) exitWith {};
        if (isNil "ALiVE_mil_IED") exitWith {
            ["STR_ALIVE_ZEUS_NEED_IED"] call _reply;
        };
        if (_faction == "") then { _faction = ALiVE_mil_IED getVariable ["bomberFaction", "CIV_F"] };
        if !(isClass (configFile >> "CfgFactionClasses" >> _faction)) exitWith {
            ["STR_ALIVE_ZEUS_BAD_FACTION", [_faction]] call _reply;
        };
        _radius = (_radius max 20) min 200;
        private _victim = [_position, 300] call _nearestVictim;
        if (isNull _victim) exitWith {
            ["STR_ALIVE_ZEUS_BOMBER_NOVICTIM"] call _reply;
        };
        [[_position, _radius, _faction], [_victim], true] call ALIVE_fnc_createBomber;
        ["STR_ALIVE_ZEUS_BOMBER_DONE", [name _victim]] call _reply;
    };

    // The man the module was placed on becomes the bomber, vest and all, and goes for the nearest
    // player within 300 m who isn't a Zeus. A man the Zeus placed belongs to the Zeus's machine,
    // and the vest goes on only where he is local, so the server takes his group first
    case "convertBomber": {
        _args params [["_unit", objNull, [objNull]]];
        if (isNull _unit || {!alive _unit} || {!(_unit isKindOf "CAManBase")} || {isPlayer _unit} || {vehicle _unit != _unit}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PERSON"] call _reply;
        };
        if (isNil "ALiVE_mil_IED") exitWith {
            ["STR_ALIVE_ZEUS_NEED_IED"] call _reply;
        };
        private _victim = [getPosATL _unit, 300] call _nearestVictim;
        if (isNull _victim) exitWith {
            ["STR_ALIVE_ZEUS_BOMBER_NOVICTIM"] call _reply;
        };
        [_unit, _victim, _caller] spawn {
            params ["_unit", "_victim", "_caller"];
            if (!local _unit) then {
                (group _unit) setGroupOwner 2;
                private _until = time + 5;
                waitUntil { sleep 0.1; local _unit || {time > _until} };
            };
            if (!local _unit || {!alive _unit}) exitWith {
                ["STR_ALIVE_ZEUS_CONVERT_FAILED"] remoteExecCall ["ALiVE_fnc_zeusFeedback", _caller];
            };
            [_unit, [_victim], true] call ALIVE_fnc_createBomber;
            ["STR_ALIVE_ZEUS_CONVERT_DONE", [name _victim]] remoteExecCall ["ALiVE_fnc_zeusFeedback", _caller];
        };
    };

    // Placed on a car: it's rigged to go off when it's hit hard or blown up, whatever its side.
    // On the ground: a car bomb starts from a clear road within 300 m of the spot and drives at
    // the nearest player within 1.5 km who isn't a Zeus, the IED module's driven car bomb
    case "carBomb": {
        _args params [["_position", [], [[]]], ["_car", objNull, [objNull]], ["_faction", "", [""]]];
        if (count _position < 2) exitWith {};
        if (isNil "ALiVE_mil_IED") exitWith {
            ["STR_ALIVE_ZEUS_NEED_IED"] call _reply;
        };
        if (!isNull _car) exitWith {
            if (!alive _car || {!(_car isKindOf "LandVehicle")} || {(crew _car) findIf {isPlayer _x} > -1}) exitWith {
                ["STR_ALIVE_ZEUS_CARBOMB_BADCAR"] call _reply;
            };
            // The IED module marks a rigged car with this (QUOTE(ADDON(VBIED)) in mil_ied)
            if (_car getVariable ["ALiVE_mil_ied(VBIED)", false]) exitWith {
                ["STR_ALIVE_ZEUS_CARBOMB_ALREADY"] call _reply;
            };
            [_car, 100, true] call ALiVE_fnc_createVBIED;
            ["STR_ALIVE_ZEUS_CARBOMB_RIGGED"] call _reply;
        };
        if (_faction == "") then { _faction = ALiVE_mil_IED getVariable ["bomberFaction", "CIV_F"] };
        if !(isClass (configFile >> "CfgFactionClasses" >> _faction)) exitWith {
            ["STR_ALIVE_ZEUS_BAD_FACTION", [_faction]] call _reply;
        };
        private _victim = [_position, 1500] call _nearestVictim;
        if (isNull _victim) exitWith {
            ["STR_ALIVE_ZEUS_CARBOMB_NOVICTIM"] call _reply;
        };
        private _driver = [_position, _victim, _faction] call ALIVE_fnc_createDrivenVBIED;
        if (isNull _driver) exitWith {
            ["STR_ALIVE_ZEUS_CARBOMB_FAILED", [_faction]] call _reply;
        };
        ["STR_ALIVE_ZEUS_BOMBER_DONE", [name _victim]] call _reply;
    };

    // One IED exactly on the spot, or several spread over the radius where the IED module would
    // put them (roads, buildings), each armed as the module arms its own. Kept under a name of
    // their own in the module's store, so a disarm or removal finds them like any other
    case "ied": {
        _args params [["_position", [], [[]]], ["_count", 1, [0]], ["_radius", 0, [0]]];
        if (count _position < 2) exitWith {};
        if (isNil "ALiVE_mil_IED" || {isNil "ALiVE_mil_ied_STORE"}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_IED"] call _reply;
        };
        _count = (round _count max 1) min 10;
        // A name not already in the store: a persistent mission loads the earlier ones back
        // into it, and createIED rebuilds whatever a name already holds instead of placing anew
        private _stored = [ALiVE_mil_ied_STORE, "IEDs"] call ALiVE_fnc_hashGet;
        private _town = "";
        while {_town == "" || {_town in (_stored select 1)}} do {
            ALiVE_zeus_iedPlaced = (missionNamespace getVariable ["ALiVE_zeus_iedPlaced", 0]) + 1;
            _town = format ["ZEUS_%1", ALiVE_zeus_iedPlaced];
        };
        if (_count == 1) then {
            [_position, 20, _town, 1, [_position]] call ALIVE_fnc_createIED;
        } else {
            [_position, (_radius max 20) min 500, _town, _count] call ALIVE_fnc_createIED;
        };
        private _made = count (([[ALiVE_mil_ied_STORE, "IEDs"] call ALiVE_fnc_hashGet, _town, [] call ALiVE_fnc_hashCreate] call ALiVE_fnc_hashGet) select 1);
        if (_made == 0) exitWith {
            ["STR_ALIVE_ZEUS_IED_NONE"] call _reply;
        };
        ["STR_ALIVE_ZEUS_IED_DONE", [_made]] call _reply;
    };

    // A squad of the nearest hostile force comes in on the players within 300 m who aren't a
    // Zeus, as after an IED blast. It needs a hostile ALiVE group within 3 km to draw from
    case "iedAmbush": {
        _args params [["_position", [], [[]]]];
        if (count _position < 2) exitWith {};
        if (isNil "ALiVE_mil_IED") exitWith {
            ["STR_ALIVE_ZEUS_NEED_IED"] call _reply;
        };
        if !(call _profilesReady) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        private _targets = allPlayers select {
            alive _x && {isNull (getAssignedCuratorLogic _x)} && {(vehicle _x) distance2D _position < 300}
        };
        if (_targets isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_AMBUSH_NOTARGET"] call _reply;
        };
        [_position, _targets] call ALiVE_fnc_IEDAmbush;
        ["STR_ALIVE_ZEUS_AMBUSH_DONE"] call _reply;
    };

    // An ALiVE group of the chosen faction, made as a profile on the spot: it spawns and despawns
    // with the rest, and an AI Commander with its faction can give it orders
    case "spawnGroup": {
        _args params [["_position", [], [[]]], ["_faction", "", [""]], ["_group", "", [""]]];
        if (count _position < 2 || {_group == ""}) exitWith {};
        if !(call _profilesReady) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        // An unknown faction or group makes nothing and says so below
        private _created = [_group, _position, 0, false, _faction, false, false, "AWARE"] call ALIVE_fnc_createProfilesFromGroupConfig;
        if (_created isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_SPAWNGROUP_FAILED", [_group]] call _reply;
        };
        private _hasCommander = (missionNamespace getVariable ["OPCOM_instances", []]) findIf {
            (toLower _faction) in (([_x, "factions", []] call ALiVE_fnc_HashGet) apply { toLower _x })
        } > -1;
        [["STR_ALIVE_ZEUS_SPAWNGROUP_NOCOMMANDER", "STR_ALIVE_ZEUS_SPAWNGROUP_DONE"] select _hasCommander, [_faction]] call _reply;
    };

    // Despawn: the group goes back to being virtual, and comes back when a player or the Zeus
    // camera is near enough. Delete: the group and its profile are gone from the mission
    case "removeGroup": {
        _args params [["_unit", objNull, [objNull]], ["_how", "despawn", [""]]];
        if (isNull _unit) exitWith {
            ["STR_ALIVE_ZEUS_NEED_UNIT"] call _reply;
        };
        if !(call _profilesReady) exitWith {
            ["STR_ALIVE_ZEUS_NEED_PROFILES"] call _reply;
        };
        private _id = (leader group _unit) getVariable ["profileID", ""];
        if (_id == "") then { _id = _unit getVariable ["profileID", ""] };
        private _profile = if (_id == "") then { nil } else { [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler };
        if (isNil "_profile" || {([_profile, "type", ""] call ALIVE_fnc_hashGet) != "entity"} || {(units group _unit) findIf {isPlayer _x} > -1}) exitWith {
            ["STR_ALIVE_ZEUS_NOT_PROFILE"] call _reply;
        };
        // Delete takes the group's own vehicles too, unless another group rides in them
        if (_how == "delete") exitWith {
            private _linked = ([_profile] call ALIVE_fnc_vehicleAssignmentsGetLinkedProfiles) select 2;
            private _vehicles = _linked select { ([_x, "type", ""] call ALIVE_fnc_hashGet) == "vehicle" };
            private _others = _linked select { ([_x, "type", ""] call ALIVE_fnc_hashGet) == "entity" && {([_x, "profileID", ""] call ALIVE_fnc_hashGet) != _id} };
            [_profile, "destroy"] call ALIVE_fnc_profileEntity;
            if (_others isEqualTo []) then {
                { [_x, "destroy"] call ALIVE_fnc_profileVehicle } forEach _vehicles;
            };
            ["STR_ALIVE_ZEUS_REMOVE_DELETED"] call _reply;
        };
        [_profile, "despawn"] call ALIVE_fnc_profileEntity;
        ["STR_ALIVE_ZEUS_REMOVE_DESPAWNED"] call _reply;
    };

    // The side's AI Commanders take the spot as an objective, first in line, as when a player marks
    // one with Command: "take" sends them to attack it, "hold" to keep it. An insurgent commander
    // works from its towns, so it isn't given one
    case "objective": {
        _args params [["_position", [], [[]]], ["_side", "", [""]], ["_intent", "take", [""]]];
        if (count _position < 2) exitWith {};
        _intent = ["take", "hold"] select ((["take", "hold"] findIf { _x == _intent }) max 0);
        if (_side == "") then { _side = [_position] call _playerSideNear };
        if (_side == "") exitWith {
            ["STR_ALIVE_ZEUS_NEED_SIDE"] call _reply;
        };
        private _all = (missionNamespace getVariable ["OPCOM_instances", []]) select {
            (([_x, "side", ""] call ALiVE_fnc_HashGet) call _sideText) == _side
        };
        if (_all isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_NEED_COMMANDER"] call _reply;
        };
        private _opcoms = _all select { ([_x, "controltype", ""] call ALiVE_fnc_HashGet) != "asymmetric" };
        if (_opcoms isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_OBJECTIVE_ASYM"] call _reply;
        };
        ALiVE_zeus_objectiveCount = (missionNamespace getVariable ["ALiVE_zeus_objectiveCount", 0]) + 1;
        private _sides = [];
        {
            private _opcomID = [_x, "opcomID", ""] call ALiVE_fnc_HashGet;
            // Saved with the commander's objectives, so the time keeps it apart from the last session's
            private _id = format ["%1_zeus_obj_%2_%3", _opcomID, round serverTime, ALiVE_zeus_objectiveCount];
            private _objective = [_x, "addObjective", [_id, _position, 100, "custom", 100, ["unassigned", "attack"] select (_intent == "take"), "none", _opcomID, true, true]] call ALiVE_fnc_OPCOM;
            if (!isNil "_objective") then {
                [_objective, "playerIntent", _intent] call ALiVE_fnc_hashSet;
                private _s = ([_x, "side", ""] call ALiVE_fnc_HashGet) call _sideText;
                if !(_s in _sides) then { _sides pushBack _s };
            };
        } forEach _opcoms;
        if (_sides isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_OBJECTIVE_FAILED"] call _reply;
        };
        [["STR_ALIVE_ZEUS_OBJECTIVE_HOLD", "STR_ALIVE_ZEUS_OBJECTIVE_TAKE"] select (_intent == "take"), [(_sides apply { _x call _sideName }) joinString ", ", mapGridPosition _position]] call _reply;
    };

    // The insurgents' installations near the spot (recruitment HQs, depots, factories, roadblocks,
    // ambushes) are drawn on the map, as when a civilian gives them away, and go in the Intel Log of
    // the side chosen
    case "reveal": {
        _args params [["_position", [], [[]]], ["_radius", 1000, [0]], ["_side", "", [""]]];
        if (count _position < 2) exitWith {};
        _radius = (_radius max 100) min 5000;
        private _insurgents = (missionNamespace getVariable ["OPCOM_instances", []]) select { ([_x, "controltype", ""] call ALiVE_fnc_HashGet) == "asymmetric" };
        if (_insurgents isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_REVEAL_NOINSURGENTS"] call _reply;
        };
        private _found = 0;
        {
            {
                private _objective = _x;
                private _center = [_objective, "center", [0,0,0]] call ALiVE_fnc_HashGet;
                if (_center distance2D _position < _radius && {["factory", "HQ", "ambush", "depot", "sabotage", "ied", "suicide", "roadblocks"] findIf {
                    private _v = [_objective, _x, []] call ALiVE_fnc_HashGet;
                    (_v isEqualType [] && {count _v > 0}) || {_v isEqualType objNull && {!isNull _v}}
                } > -1}) then { _found = _found + 1 };
            } forEach ([_x, "objectives", []] call ALiVE_fnc_HashGet);
        } forEach _insurgents;
        if (_found == 0) exitWith {
            ["STR_ALIVE_ZEUS_REVEAL_NONE", [_radius]] call _reply;
        };
        // Once for each insurgent side, so only insurgent commanders' towns are drawn
        private _insurgentSides = [];
        {
            private _s = ([_x, "side", ""] call ALiVE_fnc_HashGet) call _sideText;
            if !(_s in _insurgentSides) then { _insurgentSides pushBack _s };
        } forEach _insurgents;
        { [_position, _radius, [_x] call ALiVE_fnc_sideTextToObject, _side, "Zeus", ""] call ALIVE_fnc_OPCOMToggleInstallations } forEach _insurgentSides;
        ["STR_ALIVE_ZEUS_REVEAL_DONE", [_found, _radius]] call _reply;
    };

    // A task for every player of the side, with its marker on the spot, as a player makes one on the
    // tablet. A plain module gives it to the side of the player nearest the spot
    case "createTask": {
        _args params [["_position", [], [[]]], ["_side", "", [""]], ["_title", "", [""]], ["_description", "", [""]]];
        if (count _position < 2) exitWith {};
        if (isNil "ALIVE_taskHandler") exitWith {
            ["STR_ALIVE_ZEUS_NEED_C2ISTAR"] call _reply;
        };
        if (_side == "") then { _side = [_position] call _playerSideNear };
        private _players = allPlayers select { isNull (getAssignedCuratorLogic _x) && {((side group _x) call _sideText) == _side} };
        if (_side == "" || {_players isEqualTo []}) exitWith {
            ["STR_ALIVE_ZEUS_TASK_NOPLAYERS"] call _reply;
        };
        if (_title == "") then { _title = "Zeus" };
        // Given to these players by name: "Side" would hand it only to groups taking automatic orders
        // A new name each time: a player's task list ignores a name it has seen deleted
        private _id = "";
        while { _id == "" || {!isNil {[ALIVE_taskHandler, "getTask", _id] call ALIVE_fnc_taskHandler}} } do {
            ALiVE_zeus_taskCount = (missionNamespace getVariable ["ALiVE_zeus_taskCount", 0]) + 1;
            _id = format ["ZEUS_TASK_%1", ALiVE_zeus_taskCount];
        };
        private _task = [_id, getPlayerUID _caller, _side, _position, faction (_players select 0), _title, _description,
            [_players apply { getPlayerUID _x }, _players apply { name _x }], "Assigned", "Individual", "Y", "None", "PLAYER", false, "", ""];
        [ALIVE_taskHandler, "TASK_CREATE", _task] call ALIVE_fnc_taskHandler;
        ["STR_ALIVE_ZEUS_TASK_DONE", [_title, _side call _sideName]] call _reply;
    };

    // Placed on a player: the task they're on. Placed on the ground: the open task nearest the spot,
    // within 500 m. It ends as the Zeus chose, and one the task generator made is cleared away so the
    // generator moves on, as when its players finish it
    case "closeTask": {
        _args params [["_position", [], [[]]], ["_unit", objNull, [objNull]], ["_state", "Succeeded", [""]]];
        private _outcome = (["Succeeded", "Failed", "Canceled"] findIf { _x == _state }) max 0;
        _state = ["Succeeded", "Failed", "Canceled"] select _outcome;
        if (isNil "ALIVE_taskHandler") exitWith {
            ["STR_ALIVE_ZEUS_NEED_C2ISTAR"] call _reply;
        };
        private _isOpen = { _x isEqualType [] && {count _x > 12} && {!((_x select 8) in ["Succeeded", "Failed", "Canceled"])} };
        private _task = [];
        if (!isNull _unit && {isPlayer _unit}) then {
            private _mine = [ALIVE_taskHandler, "getTasksByPlayer", getPlayerUID _unit] call ALIVE_fnc_taskHandler;
            if (isNil "_mine" || {!(_mine isEqualType [])}) then { _mine = [] };
            _mine = _mine select _isOpen;
            private _i = _mine findIf { (_x select 10) == "Y" };
            if (_i > -1) then { _task = _mine select _i } else { if (count _mine > 0) then { _task = _mine select 0 } };
        } else {
            if (count _position < 2) exitWith {};
            private _all = (([ALIVE_taskHandler, "tasks", ["", [], [], nil]] call ALiVE_fnc_hashGet) select 2) select _isOpen;
            _all = _all select { (_x select 3) isEqualType [] && {count (_x select 3) > 1} && {((_x select 3) distance2D _position) < 500} };
            if (_all isNotEqualTo []) then {
                _task = ([_all, [], { (_x select 3) distance2D _position }, "ASCEND"] call BIS_fnc_sortBy) select 0;
            };
        };
        if (_task isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_TASK_NONE"] call _reply;
        };
        private _managed = (_task select 12) != "PLAYER";
        // A generated task's steps hang off its first one, and the generator only lets go of that
        if (_managed) then {
            private _steps = 0;
            while { (_task select 11) != "None" && {_steps < 10} } do {
                private _parent = [ALIVE_taskHandler, "getTask", _task select 11] call ALIVE_fnc_taskHandler;
                if (isNil "_parent" || {!(_parent isEqualType [])}) exitWith {};
                _task = _parent;
                _steps = _steps + 1;
            };
        };
        private _id = _task select 0;
        _task set [8, _state];
        _task set [10, "N"];
        [ALIVE_taskHandler, "TASK_UPDATE", _task] call ALIVE_fnc_taskHandler;
        if (_managed) then {
            private _finished = missionNamespace getVariable ["ALiVE_c2istar_finishedTasks", createHashMap];
            _finished set [_id, _state];
            ALiVE_c2istar_finishedTasks = _finished;
            [ALIVE_taskHandler, "TASK_DELETE", [_id, _task select 1, _task select 2]] call ALIVE_fnc_taskHandler;
        };
        [["STR_ALIVE_ZEUS_TASK_SUCCEEDED", "STR_ALIVE_ZEUS_TASK_FAILED", "STR_ALIVE_ZEUS_TASK_CANCELED"] select _outcome, [_task select 5]] call _reply;
    };

    // The side's air commander flies a sortie on the spot, as when a player asks on the tablet: the
    // side hears the answer on the radio, and with no aircraft free it's turned down there
    case "airStrike": {
        _args params [["_position", [], [[]]], ["_side", "", [""]], ["_type", "CAS", [""]]];
        if (count _position < 2) exitWith {};
        _type = ["CAS", "Strike", "SEAD", "Recce"] select ((["CAS", "Strike", "SEAD", "Recce"] findIf { _x == _type }) max 0);
        private _commanders = (entities "Module_F") select {
            typeOf _x == "ALiVE_mil_ato" && {[_x getVariable ["ALiVE_mil_ato_kernel", []]] call ALIVE_fnc_isHash}
        };
        if (_commanders isEqualTo [] || {isNil "ALIVE_eventLog"}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_ATO"] call _reply;
        };
        if (_side == "") then { _side = [_position] call _playerSideNear };
        if (_side == "") exitWith {
            ["STR_ALIVE_ZEUS_NEED_SIDE"] call _reply;
        };
        private _ofSide = _commanders select { (([_x, "side"] call ALIVE_fnc_ATOKernel) call _sideText) == _side };
        if (_ofSide isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_AIRSTRIKE_NOSIDE", [_side call _sideName]] call _reply;
        };
        private _i = _ofSide findIf { private _types = [_x, "types"] call ALIVE_fnc_ATOKernel; _types isEqualType [] && {_type in _types} };
        if (_i < 0) exitWith {
            ["STR_ALIVE_ZEUS_AIRSTRIKE_NOTYPE", [_type]] call _reply;
        };
        private _m = _ofSide select _i;
        private _mSide = [_m, "side"] call ALIVE_fnc_ATOKernel;
        private _faction = ([_m, "factions"] call ALIVE_fnc_ATOKernel) param [0, [_m, "faction"] call ALIVE_fnc_ATOKernel];
        private _uid = getPlayerUID _caller;
        // As a player's request: always read out on the radio, and not held back by friendly players
        // near the target
        ALiVE_ATO_playerReqSeq = (missionNamespace getVariable ["ALiVE_ATO_playerReqSeq", 0]) + 1;
        private _requestId = format ["PLAYER_%1_%2_%3_%4", _type, _uid, round time, ALiVE_ATO_playerReqSeq];
        private _event = ["ATO_REQUEST", [_type, [_mSide] call ALiVE_fnc_sideTextToObject, _faction, [_position select 0, _position select 1, 0], [], _requestId, _uid], "PLAYER"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
        ["STR_ALIVE_ZEUS_AIRSTRIKE_DONE", [_type, _mSide call _sideName, mapGridPosition _position]] call _reply;
    };

    // The side's logistics sends reinforcements to the spot out of its force pool, as when the AI
    // Commander asks: by road, or with Zeus Enhanced dropped by air or flown in by helicopter. Kinds
    // the logistics module has switched off aren't sent
    case "resupply": {
        _args params [["_position", [], [[]]], ["_side", "", [""]], ["_makeup", [2,0,0,0,0,0], [[]]], ["_delivery", "STANDARD", [""]]];
        if (count _position < 2) exitWith {};
        _delivery = ["STANDARD", "AIRDROP", "HELI_INSERT"] select ((["STANDARD", "AIRDROP", "HELI_INSERT"] findIf { _x == _delivery }) max 0);
        // The logistics module sends at most 5 groups of each kind
        _makeup = (_makeup select [0, 6]) apply { if (_x isEqualType 0) then { ((round _x) max 0) min 5 } else { 0 } };
        while { count _makeup < 6 } do { _makeup pushBack 0 };
        private _total = 0;
        { _total = _total + _x } forEach _makeup;
        if (_total == 0) exitWith {
            ["STR_ALIVE_ZEUS_RESUPPLY_NOTHING"] call _reply;
        };
        private _logistics = (entities "Module_F") select {
            typeOf _x == "ALiVE_mil_logistics" && {_x getVariable ["initialAnalysisComplete", false]}
        };
        if (_logistics isEqualTo [] || {isNil "ALIVE_eventLog"} || {isNil "ALIVE_globalForcePool"}) exitWith {
            ["STR_ALIVE_ZEUS_NEED_LOGISTICS"] call _reply;
        };
        if (_side == "") then { _side = [_position] call _playerSideNear };
        if (_side == "") exitWith {
            ["STR_ALIVE_ZEUS_NEED_SIDE"] call _reply;
        };
        private _ofSide = _logistics select { (([_x, "side"] call ALIVE_fnc_ML) call _sideText) == _side };
        if (_ofSide isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_RESUPPLY_NOSIDE", [_side call _sideName]] call _reply;
        };
        // The first faction these serve with force pool left
        private _faction = "";
        private _mSide = "";
        {
            private _m = _x;
            {
                private _pair = _x;
                {
                    if (_faction == "" && {([ALIVE_globalForcePool, _x, 0] call ALIVE_fnc_hashGet) > 0}) then {
                        _faction = _x;
                        _mSide = [_m, "side"] call ALIVE_fnc_ML;
                    };
                } forEach (_pair param [1, []]);
            } forEach ([_m, "factions"] call ALIVE_fnc_ML);
        } forEach _ofSide;
        if (_faction == "") exitWith {
            ["STR_ALIVE_ZEUS_RESUPPLY_NOPOOL"] call _reply;
        };
        private _event = ["LOGCOM_REQUEST", [_position, _faction, _mSide, _makeup, _delivery], "OPCOM"] call ALIVE_fnc_event;
        [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
        private _factionName = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
        if (_factionName == "") then { _factionName = _faction };
        ["STR_ALIVE_ZEUS_RESUPPLY_DONE", [_total, _factionName, mapGridPosition _position]] call _reply;
    };
};
