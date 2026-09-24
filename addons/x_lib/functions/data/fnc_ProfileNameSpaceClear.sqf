#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceClear);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceClear

Description:
Deletes this mission's saved data on this map from profileNamespace: every name
ALiVE_fnc_storeKeysOwned builds, under this map's names and the old ones. That
is the fixed names plus those the running modules registered this session, so a
save under a name nothing running builds, such as that of an air commander since
removed from the mission, is left. From the old name with the map after an
underscore only this mission's mission date and player saves are taken out.

Parameters:
String - who asked for it, for the RPT (optional)
String - their UID (optional)

Returns:
nothing

Examples:
(begin example)
_state = call ALiVE_fnc_ProfileNameSpaceClear
(end)

See Also:
ALiVE_fnc_storeKeysOwned, ALiVE_fnc_ProfileNameSpaceSave

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitwith {};

// Who asked for it. The admin menu logs on the machine the admin is sitting
// at, which on a dedicated server is a client, so the server kept no record
// of a destructive wipe at all and whoever runs it had nothing to go on.
// Optional, so an existing caller passing nothing still works. (#1041)
params [["_requestedBy", ""], ["_requestedByUID", ""]];
if (_requestedBy isNotEqualTo "") then {
    ["[ALiVE Data] Clearing this mission's saved data on %1, requested by %2 (UID %3)", worldName, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
} else {
    ["[ALiVE Data] Clearing this mission's saved data on %1", worldName] call ALiVE_fnc_dump;
};

// Every saved-data name is built from the group the Data module sets as it starts.
// Without one no name would match, and the line above would be the only record.
if (isNil "ALIVE_sys_data_GROUP_ID") exitWith {
    ["[ALiVE Data] Nothing cleared: ALiVE Data has not started on the local backend here"] call ALiVE_fnc_dump;
};

// This mission's saves on this map, under this map's names and the old ones: the list
// ALiVE_fnc_storeKeysOwned builds, which the move to per-map saves uses too, so the two
// always agree. The old mission date name, with the map after an underscore, is also a
// whole old save of a mission called <mission>_<map>, so only this mission's two slots
// are taken out of it.
{
    _x params ["_name", "_to", "_mode"];
    if (_mode == "slots") then {
        private _store = profileNamespace getVariable _name;
        if ([_store] call ALiVE_fnc_isHash) then {
            _store = +_store;
            private _had = count (_store select 1);
            { [_store, _x] call ALiVE_fnc_hashRem } forEach ["sys_data", "sys_player"];
            if (count (_store select 1) < _had) then {
                if ((_store select 1) isEqualTo []) then {
                    profileNamespace setVariable [_name, nil];
                } else {
                    profileNamespace setVariable [_name, _store];
                };
                ["[ALiVE Data] Removed this mission's date and player saves from %1", _name] call ALiVE_fnc_dump;
            };
        };
    } else {
        profileNamespace setVariable [_name, nil];
        ["[ALiVE Data] Removed %1", _name] call ALiVE_fnc_dump;
    };
} forEach ([] call ALiVE_fnc_storeKeysOwned);

private _allMissions = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];
profileNamespace setVariable [QMOD(SAVEDMISSIONS), _allMissions - [([""] call ALiVE_fnc_storeKeys) select 0, format ["ALiVE_%1_%2", missionName, worldName]]];

saveProfileNamespace
