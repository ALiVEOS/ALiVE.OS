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
        private _victims = allPlayers select {
            alive _x && {isNull (getAssignedCuratorLogic _x)} && {_x distance2D _position < 300}
        };
        if (_victims isEqualTo []) exitWith {
            ["STR_ALIVE_ZEUS_BOMBER_NOVICTIM"] call _reply;
        };
        _victims = [_victims, [], { _x distance2D _position }, "ASCEND"] call BIS_fnc_sortBy;
        private _victim = _victims select 0;
        [[_position, _radius, _faction], [_victim], true] call ALIVE_fnc_createBomber;
        ["STR_ALIVE_ZEUS_BOMBER_DONE", [name _victim]] call _reply;
    };
};
