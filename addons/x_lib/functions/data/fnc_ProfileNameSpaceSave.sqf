#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceSave);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceSave

Description:
Saves a Hash with given Data to ProfileNameSpace

Parameters:
Array select 0: ID (f.e. "ALiVE_SYS_LOGISTICS")
Array select 1: data

Returns:
true 

Examples:
(begin example)
_result = ["ALiVE_SYS_LOGISTICS",_state] call ALiVE_fnc_ProfileNameSpaceSave
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceLoad

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

private _id = _this select 0;
private _data = _this select 1;

// Storage key includes `worldName` so copies of `mission.sqm` across
// map folders don't collide on the same profileNamespace entry. See
// 4990aaad for the parallel fix in sys_data + sys_player.
private _mission = format["ALiVE_%1_%2",missionName,worldName];
private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS),[]];

if (isNil QMOD(PNS_STORE)) then {
    MOD(PNS_STORE) = +(["get", _mission] call ALiVE_fnc_storeFile);
    if (isNil QMOD(PNS_STORE)) then { MOD(PNS_STORE) = [] call ALiVE_fnc_HashCreate };
};

[MOD(PNS_STORE),_id,_data] call ALiVE_fnc_HashSet;

["set", _mission, MOD(PNS_STORE)] call ALiVE_fnc_storeFile;

if !(_mission in _allmissions) then {
    _allMissions set [count _allmissions,_mission];
    
    profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions];
    ALiVE_storeFile_dirtyShared = true;
};    

// Saved outside an autosave, the file is written straight away (storeFile "save"). Said in the RPT so a
// write can be traced to what made it: once a minute per ID at most, as in sys_data_pns fnc_writeData.
if ((missionNamespace getVariable ["ALIVE_PNS_HOLD_FRAME", -1]) != diag_frameNo) then {
    private _flushLog = missionNamespace getVariable ["ALIVE_PNS_FLUSH_LOG", createHashMap];
    (_flushLog getOrDefault [_id, [-1e9, 0]]) params ["_loggedAt", "_quiet"];
    if ((diag_tickTime - _loggedAt) >= 60) then {
        ["[ALiVE Data] %1 saved on its own, so the save file was written now%2", _id, ["", format [" (%1 more since the last line)", _quiet]] select (_quiet > 0)] call ALiVE_fnc_dump;
        _flushLog set [_id, [diag_tickTime, 0]];
    } else {
        _flushLog set [_id, [_loggedAt, _quiet + 1]];
    };
    missionNamespace setVariable ["ALIVE_PNS_FLUSH_LOG", _flushLog];
};

["save"] call ALiVE_fnc_storeFile;

true;