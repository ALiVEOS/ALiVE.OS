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
};
