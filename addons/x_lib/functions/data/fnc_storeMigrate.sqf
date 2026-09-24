#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(storeMigrate);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_storeMigrate

Description:
Moves this mission's saves from the names older builds used to this map's
names. The module saves had no map in their names; the mission date, player
and compositions saves since May 2026 had it after an underscore. An old name
is removed once its saves have moved, unless it still holds another mission's.
The Data module runs this on the local backend as it starts, before any module
loads its saves.

A module that saves under a name only it can build, such as an air commander's
own key, passes that part of the name before it loads. The name is then known
to Clear Current Mission's Data, and a save under its old form is moved too.
Every run checks every name, so a later run moves only what an earlier one
could not see. Saved-data names cannot be listed on a dedicated server
(allVariables returns nothing for profileNamespace there), so a name nobody
builds cannot be found.

A save made before saves were split by map carries no record of which map it
came from. Whichever same-named copy of a mission is launched first takes it,
and any other copy then finds nothing and starts fresh. Removing the old names
is what stops every later copy from picking the same campaign up again.

Where the new name already holds a slot, that copy is kept and the one being
moved is dropped, with a line in the RPT naming both.

Parameters:
String - the part of a module's save name after the mission's name, such as
         "_ATO_BLU_F_0" (optional)

Returns:
Number - how many old names it took saves from

See Also:
ALiVE_fnc_storeKeys, ALiVE_fnc_storeKeysOwned

Author:
Jman
---------------------------------------------------------------------------- */

params [["_suffix", "", [""]]];

if !(isServer) exitWith {0};

if !(_suffix isEqualTo "") then {
    if (isNil "ALiVE_storeSuffixes") then { ALiVE_storeSuffixes = [] };
    ALiVE_storeSuffixes pushBackUnique _suffix;
};

// Only the local backend keeps saves in profileNamespace, and every name needs
// the group the Data module sets first.
if ((missionNamespace getVariable ["ALiVE_sys_data_source", ""]) != "pns" || {isNil "ALIVE_sys_data_GROUP_ID"}) exitWith {0};

// Always unscheduled, so no module's load can read a store halfway through a move.
if (canSuspend) exitWith {
    private _n = 0;
    isNil { _n = [] call ALiVE_fnc_storeMigrate };
    _n
};

private _base = ([""] call ALiVE_fnc_storeKeys) select 0;
private _data = _base + "_DATA";
private _changed = 0;
private _adoptedBase = false;

// Copies the named slots of _from into the store called _to. A slot _to already
// holds is kept and the one from _from is dropped, with a line in the RPT. The
// newer names are listed first, so the copy kept is normally the newer one.
private _fnc_merge = {
    params ["_from", "_slots", "_to", "_fromName"];
    if (_slots isEqualTo []) exitWith {};
    private _target = +(profileNamespace getVariable [_to, [] call ALiVE_fnc_hashCreate]);
    {
        if ([_target, _x] call CBA_fnc_hashHasKey) then {
            ["[ALiVE Data] Kept the copy already in %1 / %2, dropped the one from %3", _to, _x, _fromName] call ALiVE_fnc_dump;
        } else {
            [_target, _x, [_from, _x] call ALiVE_fnc_hashGet] call ALiVE_fnc_hashSet;
        };
    } forEach _slots;
    profileNamespace setVariable [_to, _target];
};

{
    _x params ["_name", "_to", "_mode"];
    // Only what is moved gets copied: the "self" entries are this mission's whole
    // current campaign, and copying that on every start would be wasted work.
    private _old = if (_mode in ["move", "slots"]) then { profileNamespace getVariable _name } else { nil };
    if (!isNil "_old" && {_old isEqualType []}) then { _old = +_old };

    switch (_mode) do {
        case "move": {
            if !([_old] call ALiVE_fnc_isHash) exitWith {
                ["[ALiVE Data] Left %1 where it is: it does not hold saved data in the expected form. Clear Current Mission's Data removes it", _name] call ALiVE_fnc_dump;
            };
            private _slots = +(_old select 1);
            private _where = _to;
            if (_to == _base) then {
                // The old module base also held the mission date and player
                // saves, which are now kept apart from the module saves.
                private _own = _slots select {_x in ["sys_data", "sys_player"]};
                [_old, _own, _data, _name] call _fnc_merge;
                [_old, _slots - _own, _base, _name] call _fnc_merge;
                if !(_own isEqualTo []) then { _where = format ["%1, its mission date and player saves to %2", _base, _data] };
                _adoptedBase = true;
            } else {
                [_old, _slots, _to, _name] call _fnc_merge;
            };
            profileNamespace setVariable [_name, nil];
            _changed = _changed + 1;
            ["[ALiVE Data] Moved saved data %1 to %2 (saved data is now kept per map)", _name, _where] call ALiVE_fnc_dump;
        };
        case "slots": {
            if !([_old] call ALiVE_fnc_isHash) exitWith {
                ["[ALiVE Data] Left %1 where it is: it does not hold saved data in the expected form. Clear Current Mission's Data removes it", _name] call ALiVE_fnc_dump;
            };
            private _own = (_old select 1) select {_x in ["sys_data", "sys_player"]};
            if (_own isEqualTo []) exitWith {};
            [_old, _own, _to, _name] call _fnc_merge;
            { [_old, _x] call ALiVE_fnc_hashRem } forEach _own;
            if ((_old select 1) isEqualTo []) then {
                profileNamespace setVariable [_name, nil];
            } else {
                profileNamespace setVariable [_name, _old];
                ["[ALiVE Data] Left the rest of %1: it still holds %2, which belong to another mission", _name, _old select 1] call ALiVE_fnc_dump;
            };
            _changed = _changed + 1;
            ["[ALiVE Data] Moved the mission date and player saves in %1 to %2 (saved data is now kept per map)", _name, _to] call ALiVE_fnc_dump;
        };
    };
} forEach ([] call ALiVE_fnc_storeKeysOwned);

if (_changed > 0) then {
    saveProfileNamespace;
    ["[ALiVE Data] Moved %1 saved-data variables to this map's names", _changed] call ALiVE_fnc_dump;
};

// The old campaign just taken may have been saved by a copy of this mission on
// another map. That cannot be told apart, but a copy that ran on another map
// left its own mission date or player save behind, so say where.
if (_adoptedBase) then {
    // Both spellings of the mission name, as the old names used both.
    private _missions = [[missionName, "%20", "-"] call CBA_fnc_replace];
    _missions pushBackUnique missionName;
    {
        private _w = configName _x;
        if (_w != worldName && {(_missions findIf {
            !(isNil {profileNamespace getVariable format ["%1_%2_%3", ALIVE_sys_data_GROUP_ID, _x, _w]})
            || {!(isNil {profileNamespace getVariable format ["%1_%2:%3", ALIVE_sys_data_GROUP_ID, _x, _w]})}
        }) >= 0}) then {
            ["[ALiVE Data] The campaign just moved to this map may belong to the copy of this mission on %1. It cannot be moved there now, and Clear Current Mission's Data here would delete it", _w] call ALiVE_fnc_dump;
        };
    } forEach ("true" configClasses (configFile >> "CfgWorlds"));
};

_changed
