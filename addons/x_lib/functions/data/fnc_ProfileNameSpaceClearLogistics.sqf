#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceClearLogistics);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceClearLogistics

Description:
Deletes only this mission's saved vehicles and buildings on this map (the
Player Logistics save) from profileNamespace, and keeps everything else: the
AI Commanders' objectives, installations and roadblocks, the profiles, tasks,
the mission date and the player saves.

The vehicles and buildings already in the game stay where they are, so Player
Logistics stops saving for the rest of this session; otherwise the next save
would write them all back. Restarting the mission brings it up without them,
and it saves as normal from then on.

Only the machines the admin menu offers this to may ask for it, as for
ALiVE_fnc_ProfileNameSpaceClear.

Parameters:
String - who asked for it, for the RPT (optional)
String - their UID (optional)

Returns:
nothing

See Also:
ALiVE_fnc_ProfileNameSpaceClear, ALiVE_fnc_storeKeysOwned

Author:
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

params [["_requestedBy", ""], ["_requestedByUID", ""]];

// The same check as Clear Current Mission's Data: the server asks again about the machine
// that sent this, by the rule the admin menu offers the entry by.
private _owner = remoteExecutedOwner;
private _refused = false;
if (isRemoteExecuted && {_owner > 0} && {_owner != clientOwner} && {(admin _owner) == 0}) then {
    private _i = allPlayers findIf {owner _x == _owner};
    private _uid = if (_i > -1) then {getPlayerUID (allPlayers select _i)} else {""};
    private _console = getMissionConfigValue ["enableDebugConsole", 0];
    _refused = !((_console isEqualTo 2) || {_console isEqualType [] && {_uid != ""} && {_uid in _console}});
};
if (_refused) exitWith {
    ["[ALiVE Data] Refused to clear this mission's saved vehicles and buildings for machine %1 (%2, UID %3): not an admin", _owner, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
};

["[ALiVE Data] Clearing this mission's saved vehicles and buildings on %1, requested by %2 (UID %3)", worldName, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;

private _fnc_report = {
    private _report = [[_this]];
    if (_owner > 0 && {_owner != clientOwner}) then {
        _report remoteExec ["CBA_fnc_notify", _owner];
    } else {
        if (hasInterface) then { _report call CBA_fnc_notify };
    };
};

if (isNil "ALIVE_sys_data_GROUP_ID") exitWith {
    ["[ALiVE Data] Nothing cleared: ALiVE Data has not started on the local backend here"] call ALiVE_fnc_dump;
};

// Player Logistics saves into the "sys_logistics" slot of the mission's base name. An old
// base name not yet moved to this map's one can hold the slot too, and the oldest Player
// Logistics save used ALiVE_<mission>_<map> with its own slot name.
private _base = (["", worldName] call ALiVE_fnc_storeKeys) select 0;
private _stores = [];
{
    _x params ["_name", "_to", "_mode"];
    if ((_mode == "self" && {_name == _base}) || {_mode == "move" && {_to == _base}}) then {
        _stores pushBack [_name, "sys_logistics"];
    };
} forEach ([] call ALiVE_fnc_storeKeysOwned);
_stores pushBack [format ["ALiVE_%1_%2", missionName, worldName], QMOD(SYS_LOGISTICS)];

private _removed = 0;
private _deleted = [];
{
    _x params ["_name", "_slot"];
    // from whichever file holds it (ALiVE_fnc_storeFile): the shared profile file or the mission's own
    private _store = ["get", _name] call ALiVE_fnc_storeFile;
    if (isNil "_store") then { _store = [] };
    if ([_store] call ALiVE_fnc_isHash && {_slot in (_store select 1)}) then {
        _store = +_store;
        private _items = [_store, _slot, []] call ALiVE_fnc_hashGet;
        if ([_items] call ALiVE_fnc_isHash) then { _removed = _removed + count (_items select 1) };
        [_store, _slot] call ALiVE_fnc_hashRem;
        if ((_store select 1) isEqualTo []) then {
            ["delete", _name] call ALiVE_fnc_storeFile;
            _deleted pushBack _name;
        } else {
            ["set", _name, _store] call ALiVE_fnc_storeFile;
        };
        ["[ALiVE Data] Removed the saved vehicles and buildings from %1", _name] call ALiVE_fnc_dump;
    };
} forEach _stores;

// A name left with nothing in it comes off the list Wipe ALL reads.
if (_deleted isNotEqualTo []) then {
    private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];
    if !(_allMissions isEqualType []) then { _allMissions = [] };
    profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - _deleted];
    ALiVE_storeFile_dirtyShared = true;
};
["flush"] call ALiVE_fnc_storeFile;

// What is in the game now would be saved straight back, so Player Logistics saves
// nothing more until the mission restarts.
if !(isNil QMOD(SYS_LOGISTICS)) then {
    MOD(SYS_LOGISTICS) setVariable ["DISABLEPERSISTENCE", true, true];
};

["[ALiVE Data] Cleared %1 saved vehicles and buildings; Player Logistics saves nothing more until the mission restarts", _removed] call ALiVE_fnc_dump;
(format [localize "STR_ALIVE_DATA_CLEAR_LOGI_DONE", _removed]) call _fnc_report;
