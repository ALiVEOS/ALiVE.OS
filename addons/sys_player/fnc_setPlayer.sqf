#include "\x\alive\addons\sys_player\script_component.hpp"
SCRIPT(setPlayer);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_setPlayer
Description:
Get current player object data and save to in memory store

Parameters:
Object - If Nil, return a new instance. If Object, reference an existing instance.
Array - The selected parameters

Returns:
Hash - Array of player data

Examples:
(begin example)
//
(end)

See Also:
- <ALIVE_fnc_playerInit>
- <ALIVE_fnc_playerMenuDef>

Author:
Tupolov
Goldwep
Jman

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private ["_logic","_args","_player","_puid","_find","_saveLoadout","_saveHealth","_savePosition","_saveScores","_saveAmmo","_data","_playerHash","_result"];

_logic = _this param [0, objNull, [objNull,[]]];
_args = _this param [1, objNull, [objNull,[],"",0,true,false]];

_data =  [];

_player = _args select 0;

// Optional explicit UID. Only the HandleDisconnect save in ALiVE_fnc_player
// supplies it, because getPlayerUID returns "" once the engine has detached
// the dropping player (Inferno #885). Every other caller - the Abort button
// and the sys_data_pns autosave, both of which run with the unit still in
// play - omits it and gets the old getPlayerUID behaviour.
_puid = _args param [1, getPlayerUID _player, [""]];

_playerHash = [] call CBA_fnc_hashCreate;

TRACE_1("SET PLAYER",_this);

// ensure last document revision is passed with the new player record if it exists
if (_player getVariable ["_rev","MISSING"] != "MISSING") then {
    [_playerHash, "_rev", _player getVariable "_rev"] call CBA_fnc_hashSet;
};

    // Get save options
    _saveLoadout = _logic getvariable ["saveLoadout",true];
    _saveHealth = _logic getvariable ["saveHealth",true];
    _savePosition = _logic getvariable ["savePosition",true];
    _saveScores = _logic getvariable ["saveScores",true];
    _saveAmmo = _logic getvariable ["saveAmmo",false];

// Create Data Command Array
_data = GVAR(UNIT_DATA);

if ( _savePosition) then {
    _data = _data + GVAR(POSITION_DATA);
};

if ( _saveHealth) then {
    _data = _data + GVAR(HEALTH_DATA);
};

/* LOADOUT IS NOW UPDATED VIA CLIENT UPDATES NOT FROM SERVER, need to incorp GVAR(gear_data)
if ( _saveLoadout) then {
    _data =_data + GVAR(LOADOUT_DATA);
};*/

if ( _saveScores) then {
    _data =_data + GVAR(SCORE_DATA);
};

TRACE_5("SYS_PLAYER SET",_saveLoadout,_saveHealth,_savePosition,_saveScores, count _data);

// Run data collection commands
{
    private ["_key","_cmd","_value"];
    _key = _x select 0;
    _cmd = _x select 1;
    _value = [_player] call _cmd;
    if (isNil "_value") then {
        TRACE_2("SYS_PLAYER ERROR TRYING TO COLLECT PLAYER DATA",_player, _cmd);
        _value = "";
    } else {
        TRACE_3("SYS_PLAYER SET PLAYER DATA",_player, _key, _value);
    };
    [_playerHash, _key, _value] call CBA_fnc_hashSet;
} foreach _data;

// UNIT_DATA reads puid off the unit, which is already blank on a
// HandleDisconnect save - stamp the UID we were given so the stored record
// stays identifiable. Only when we actually got one, so callers that rely
// on the unit-derived puid are unaffected.
if (_puid != "") then {
    [_playerHash, "puid", _puid] call CBA_fnc_hashSet;
};

// The AI squad of a player who leads their group (Helios on Discord, 8 Nov): each living AI member's slot in
// the group, class, kit, place, health and seat, so a load puts them back where they were and leaves out the
// ones who were dead. A member who joined during play gets a slot of 100 up and is made again on load.
// "NONE" when the player does not lead or positions are not saved, so the old behaviour stands.
private _membersOf = {
    params ["_grp"];
    private _out = [];
    private _next = 100;
    { _next = _next max (1 + (_x getVariable ["ALiVE_squadSlot", -1])) } forEach (units _grp);
    {
        if (!isPlayer _x && {alive _x}) then {
            private _slot = _x getVariable ["ALiVE_squadSlot", -1];
            if (_slot < 0) then { _slot = _next; _next = _next + 1; _x setVariable ["ALiVE_squadSlot", _slot, true] };
            private _unit = _x;
            private _veh = vehicle _unit;
            private _vehID = "NONE";
            private _role = [];
            if (_veh != _unit) then {
                _vehID = _veh getVariable ["vehicleID", vehicleVarName _veh];
                // the seat: [role, cargo index, turret path] from the crew list
                private _row = ((fullCrew _veh) select { (_x select 0) isEqualTo _unit }) param [0, []];
                if (_row isNotEqualTo []) then { _role = [toLower (_row select 1), _row select 2, _row select 3] };
            };
            _out pushBack [_slot, typeOf _unit, getUnitLoadout _unit, getPosATL _unit, getDir _unit, damage _unit, _vehID, _role];
        };
    } forEach (units _grp);
    _out
};
private _squad = "NONE";
if (_savePosition && {!isNull _player} && {leader group _player == _player}) then {
    _squad = [group _player] call _membersOf;
};
[_playerHash, "squad", _squad] call CBA_fnc_hashSet;

// The High Command teams the player commands (Helios on Discord, 8 Nov), each as [callsign, members], the members
// saved as the squad's are. Every team seen under their command this session is saved (fnc_player "getPlayer"
// keeps the list), so one wiped out since is saved with no members and a load takes its men out too. "NONE" when
// the player commands none or positions are not saved.
private _hcTeams = "NONE";
if (_savePosition && {!isNull _player}) then {
    private _seenKey = ([_player, _puid] call ALiVE_fnc_playerKey) + "_hcSeen";
    private _seen = MOD(sys_player) getVariable [_seenKey, []];
    {
        private _grp = _x;
        if ((_seen findIf { (_x select 1) isEqualTo _grp }) < 0) then {
            if ((_grp getVariable ["ALiVE_hcTeam", ""]) == "") then { _grp setVariable ["ALiVE_hcTeam", groupId _grp, true] };
            _seen pushBack [_grp getVariable "ALiVE_hcTeam", _grp];
        };
    } forEach ((hcAllGroups _player) - [group _player]);
    MOD(sys_player) setVariable [_seenKey, _seen];
    if (_seen isNotEqualTo []) then {
        _hcTeams = _seen apply {
            _x params ["_team", "_grp"];
            [_team, if (isNull _grp) then { [] } else { [_grp] call _membersOf }]
        };
    };
};
[_playerHash, "hcTeams", _hcTeams] call CBA_fnc_hashSet;

// Persisting by slot, the record is the slot's: the occupant's name, voice, face, rank and rating aren't kept in it
// (they are never put back by slot either)
if ((MOD(sys_player) getVariable ["persistBy", "player"]) == "slot") then {
    { [_playerHash, _x] call CBA_fnc_hashRem } forEach ["name","speaker","nameSound","pitch","face","rating","rank"];
};

// Add gear data to player's hash
private ["_gearHash","_addGear"];
_gearHash = [GVAR(gear_data), [_player, _puid] call ALiVE_fnc_playerKey, "NONE"] call ALIVE_fnc_hashGet;

_addGear = {
    [_playerHash, _key, _value] call ALIVE_fnc_hashSet;
    TRACE_3("SYS_PLAYER SET PLAYER DATA",_player, _key, _value);
};

if ([_gearHash] call ALIVE_fnc_isHash) then {
    [_gearHash, _addGear] call CBA_fnc_hashEachPair;
} else {
    ["No gear found for %1", _player] call ALivE_fnc_dump;
//    _playerHash call ALIVE_fnc_inspectHash;
};


// Add player hash to player data
_result = _playerHash;

_result;




