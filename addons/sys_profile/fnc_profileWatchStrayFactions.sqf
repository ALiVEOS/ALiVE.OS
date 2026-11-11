#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(profileWatchStrayFactions);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_profileWatchStrayFactions

Description:
    Server only, started once by the profile system. Writes a line to the server
    RPT when AI of a faction that no ALiVE module in the mission is set to turns
    up, naming the faction, the men, where they were and the variables on their
    group and leader. ALiVE's spawners mark their groups (CQB a "house", the
    profile system a profile id, and so on), so those variables tell which
    module made them, with every module's debug left off (#1105).

    New men are queued from an EntityCreated handler and checked every 15 s.
    At most 5 lines per faction per mission.

Parameters:
    None

Returns:
    Nothing

Author:
    Jman
---------------------------------------------------------------------------- */

if (!isServer) exitWith {};
if (!isNil "ALiVE_strayFactionQueue") exitWith {};

ALiVE_strayFactionQueue = [];
ALiVE_strayFactionLogged = createHashMap;

addMissionEventHandler ["EntityCreated", {
    params ["_entity"];
    if (_entity isKindOf "CAManBase") then { ALiVE_strayFactionQueue pushBack _entity };
}];

[] spawn {
    // The factions the mission's ALiVE modules are set to: every module variable
    // with "faction" in its name, as a name, a list, or a list written as text.
    private _fnc_expected = {
        private _expected = createHashMap;
        private _fnc_add = {
            params ["_value"];
            if (_value isEqualType []) exitWith { { [_x] call _fnc_add } forEach _value };
            if (_value isEqualType "") then {
                {
                    private _name = toLower ((_x splitString " """"'[]") joinString "");
                    if (_name != "") then { _expected set [_name, true] };
                } forEach (_value splitString ",");
            };
        };
        {
            private _module = _x;
            if ((toLower typeOf _module) find "alive_" == 0) then {
                {
                    // An enemy-faction setting (C2ISTAR's task slots, which default to CSAT) names
                    // whom tasks are made against, so its groups are among the ones worth naming.
                    if ((_x find "faction") >= 0 && {(_x find "enemy") < 0}) then { [_module getVariable _x] call _fnc_add };
                } forEach allVariables _module;
            };
        } forEach (entities "Logic");
        { _expected set [toLower faction _x, true] } forEach allPlayers;
        _expected
    };

    private _fnc_aliveVars = {
        params ["_object"];
        (allVariables _object) select {
            (_x find "alive") >= 0 || {(_x find "profile") >= 0} || {_x in ["house", "faction", "unittypes"]}
        }
    };

    while {true} do {
        sleep 15;
        if (ALiVE_strayFactionQueue isNotEqualTo []) then {
            private _men = ALiVE_strayFactionQueue;
            ALiVE_strayFactionQueue = [];
            private _groups = [];
            { if (alive _x && {!isPlayer _x}) then { _groups pushBackUnique group _x } } forEach _men;
            _groups = _groups select { !isNull _x && {side _x != civilian} };

            if (_groups isNotEqualTo []) then {
                private _expected = call _fnc_expected;
                {
                    private _group = _x;
                    private _leader = leader _group;
                    private _faction = faction _leader;
                    private _key = toLower _faction;
                    private _count = ALiVE_strayFactionLogged getOrDefault [_key, 0];
                    if (!(_key in _expected) && {_count < 5}) then {
                        ALiVE_strayFactionLogged set [_key, _count + 1];
                        private _near = allPlayers select { !(_x isKindOf "HeadlessClient_F") } apply { round (_x distance _leader) };
                        _near sort true;
                        ["ALiVE - AI of a faction no ALiVE module here is set to: %1 (%2) group %3 at grid %4, nearest player %5 m, men %6. Group variables %7, leader variables %8. Factions the modules are set to: %9",
                            _faction, side _group, groupId _group, mapGridPosition _leader, _near param [0, -1],
                            (units _group) apply { typeOf _x },
                            [_group] call _fnc_aliveVars, [_leader] call _fnc_aliveVars,
                            keys _expected] call ALiVE_fnc_dump;
                    };
                } forEach _groups;
            };
        };
    };
};
