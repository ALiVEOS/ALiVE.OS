#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(ProfileNameSpaceWipe);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_ProfileNameSpaceWipe

Description:
Deletes every mission's saved ALiVE data from profileNamespace. The player's
saved presets are kept.

A dedicated server's profile cannot list its own variables (allVariables returns
nothing for profileNamespace there), so saves are found by name: the list every
local save adds itself to (ALiVE_SAVEDMISSIONS), and this mission's own names on
every map, built by ALiVE_fnc_storeKeysOwned. Where the engine can list the
variables, anything with alive_ in its name goes too. On a dedicated server a save
an older build made for another mission is on no list, so it stays until that
mission has saved once on this build, or is cleared from inside it.

Only the machines the admin menu offers this to may ask for it, and the one that
asked is told what was removed.

Parameters:
String - who asked for it, for the RPT (optional)
String - their UID (optional)

Returns:
nothing

Examples:
(begin example)
call ALiVE_fnc_ProfileNameSpaceWipe
(end)

See Also:
ALiVE_fnc_ProfileNameSpaceClear, ALiVE_fnc_storeKeysOwned

Author:
Highhead
Jman
---------------------------------------------------------------------------- */

if !(isServer) exitWith {};

// Who asked for it. The admin menu logs on the machine the admin is sitting
// at, which on a dedicated server is a client, so the server kept no record
// of a destructive wipe at all and whoever runs it had nothing to go on.
// Optional, so an existing caller passing nothing still works. (#1041)
params [["_requestedBy", ""], ["_requestedByUID", ""]];

// Anyone can send a remoteExec, so the server asks again about the machine that sent
// this one, by the rule the admin menu offers the entry by (ALIVE_fnc_isServerAdmin or
// BIS_fnc_isDebugConsoleAllowed on that machine): this machine or the host's, a logged-in
// or voted admin, or a player the mission's debug console setting lets in. It is read
// first, because the sender is only known in this call.
private _owner = remoteExecutedOwner;
private _refused = false;
if (isRemoteExecuted && {_owner > 0} && {_owner != clientOwner} && {(admin _owner) == 0}) then {
    private _i = allPlayers findIf {owner _x == _owner};
    private _uid = if (_i > -1) then {getPlayerUID (allPlayers select _i)} else {""};
    private _console = getMissionConfigValue ["enableDebugConsole", 0];
    _refused = !((_console isEqualTo 2) || {_console isEqualType [] && {_uid != ""} && {_uid in _console}});
};
if (_refused) exitWith {
    ["[ALiVE Data] Refused to clear ALL ALiVE saved data for machine %1 (%2, UID %3): not an admin", _owner, _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
};

if (_requestedBy isNotEqualTo "") then {
    ["[ALiVE Data] Clearing ALL ALiVE saved data, requested by %1 (UID %2)", _requestedBy, _requestedByUID] call ALiVE_fnc_dump;
} else {
    ["[ALiVE Data] Clearing ALL ALiVE saved data"] call ALiVE_fnc_dump;
};

// Unscheduled, so a save that lands during the wipe can't lose its place on the list.
private _fnc_wipe = {
    // The saved presets are the player's own collection, not saved mission data, and the
    // list itself is cleared on its own below.
    private _keep = ["alive_presetlibrary", toLower QMOD(SAVEDMISSIONS)];

    // Every name to remove: the saves recorded by name, this mission's own names on every
    // map (built, never searched for, and only the ones that exist come back), and, where
    // the engine can list them, every variable with alive_ in its name.
    private _names = profileNamespace getVariable [QMOD(SAVEDMISSIONS), []];
    _names = if (_names isEqualType []) then { _names select {_x isEqualType ""} } else { [] };
    if (!isNil "ALIVE_sys_data_GROUP_ID") then {
        private _worlds = ("true" configClasses (configFile >> "CfgWorlds")) apply {configName _x};
        _worlds pushBackUnique worldName;
        {
            { _names pushBack (_x select 0) } forEach ([_x] call ALiVE_fnc_storeKeysOwned);
        } forEach _worlds;
    };
    private _listed = allVariables profileNamespace;
    {
        if ([toLower _x, "alive_"] call CBA_fnc_find != -1) then { _names pushBack _x };
    } forEach _listed;

    private _wiped = 0;
    {
        if !((toLower _x) in _keep) then {
            if (!isNil {profileNamespace getVariable _x}) then {
                _wiped = _wiped + 1;
                ["[ALiVE Data] Removed %1", _x] call ALiVE_fnc_dump;
            };
            profileNamespace setVariable [_x, nil];
        };
    } forEach (_names arrayIntersect _names);

    profileNamespace setVariable [QMOD(SAVEDMISSIONS), nil];
    saveProfileNamespace;

    ["[ALiVE Data] Removed %1 saved-data entries", _wiped] call ALiVE_fnc_dump;
    private _report = [format [localize "STR_ALIVE_DATA_WIPE_DONE", _wiped]];
    if (_listed isEqualTo []) then {
        ["[ALiVE Data] This profile cannot list its own variables, so a save an older build made for another mission is on no list and stays: start and save that mission once on this build, or clear it from inside the mission"] call ALiVE_fnc_dump;
        _report pushBack (localize "STR_ALIVE_DATA_WIPE_DONE_OLDER");
    };

    // Told to whoever asked, once it's done: the admin menu runs on their machine.
    if (_owner > 0) then {
        _report remoteExec ["CBA_fnc_notify", _owner];
    } else {
        if (hasInterface) then { _report call CBA_fnc_notify };
    };
};
if (canSuspend) then { isNil _fnc_wipe } else { call _fnc_wipe };