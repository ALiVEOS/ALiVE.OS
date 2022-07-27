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
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

private _id = _this select 0;
private _data = _this select 1;

private _mission = format["ALiVE_%1",missionName];
private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS),[]];

if (isNil QMOD(PNS_STORE)) then {
    MOD(PNS_STORE) = +(profileNamespace getVariable [_mission, [] call ALiVE_fnc_HashCreate]);
};

[MOD(PNS_STORE),_id,_data] call ALiVE_fnc_HashSet;

profileNamespace setVariable [_mission, MOD(PNS_STORE)];

if !(_mission in _allmissions) then {
    _allMissions set [count _allmissions,_mission];
    
    profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions];
};    

saveProfileNamespace;

true;