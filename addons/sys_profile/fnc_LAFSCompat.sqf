#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(LAFSCompat);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_LAFSCompat

Description:
    Works alongside the Light AI Fire Support mod (LAFS, Steam Workshop
    3323604819) when it is loaded. ALiVE ships and changes no LAFS file: every
    LAFS name it reads (its CfgPatches class, module classes, module attributes,
    group and mission variables) is in the one list below, and is checked at run
    time. If a name is missing (a LAFS update renamed it), one line is logged
    and that part is left off.

    LAFS finds its support groups (artillery, spotters, drones, planes and the
    rest) by scanning the live groups a few seconds into the mission. A group
    the profile system has made virtual has no units, so LAFS never sees it, and
    a support group LAFS took would be deleted the next time the players moved
    away from it. So:

    "premark" (start of mission, called by createProfilesFromUnits before it
        takes the editor groups): every group LAFS will use is marked
        ALIVE_profileIgnore, with the vehicles it crews: groups synced to a LAFS
        module, groups LAFS has already flagged as its own, groups on a LAFS
        support side led from an artillery vehicle, and groups holding a class a
        LAFS spotter or detector module names. The mark keeps them out of every
        later profiling pass too (Virtualise In Radius, Zeus, recruitment, admin
        actions). Starts the "watch" loop.
        LAFS's own class lists (tank QRF, sniper, drone and the rest) are not
        read here: filled by a mod such as PHEN Automated Unit Definitions they
        name every armoured vehicle and marksman of a side, and every such
        group was kept out of the profile system. A group LAFS picks from those
        lists is released by "watch" once LAFS flags it.

    "watch" (server loop, every 30 s): a group LAFS marks as one of its own
        later (Scan After Start, a group ALiVE had spawned near the players) is
        released: its profile is forgotten, its units stay where they are as
        live AI, and it is marked as above. Logged once per group.

    "loaded": true when LAFS is loaded.

    A released group is live AI, so a persistent save does not keep it; an
    editor-placed one is marked again by "premark" on the next start.

Parameters:
    0: STRING - mode ("loaded", "premark", "watch", "release")
    1: ARRAY - groups (premark: default allGroups; release: the one group)

Returns:
    BOOL for "loaded", nothing otherwise

Author:
    Jman
---------------------------------------------------------------------------- */

params [["_mode", "loaded", [""]], ["_groups", [], [[]]]];

// every LAFS name ALiVE reads, in one place
private _N = createHashMapFromArray [
    ["patch", "LAFS_patches"],
    ["modules", ["LAFS_RunGroupScan", "LAFS_SpotterModule", "LAFS_DetectorModule", "LAFS_ManualGroupAssign",
                 "LAFS_FreezeGroup", "LAFS_SniperNoMove", "LAFS_MobileArtillery", "LAFS_ArtilleryHide"]],
    ["ignoreModule", "LAFS_IgnoreGroup"],
    ["classModules", ["LAFS_SpotterModule", "LAFS_DetectorModule"]],
    ["sideAttr", "LAFS_SupportSide"],
    ["grpIgnore", "LAFS_var_ignoreGroup"],
    ["grpSupport", "LAFS_var_isSupport"],
    ["grpSpotter", "LAFS_var_isSpotter"]
];

private _loaded = isClass (configFile >> "CfgPatches" >> (_N get "patch"));
if (_mode == "loaded") exitWith { _loaded };
if (!_loaded || {!isServer}) exitWith {};

// marks a group and the vehicles it crews so no profiling pass takes them
private _fnc_mark = {
    params ["_grp"];
    _grp setVariable ["ALIVE_profileIgnore", true];
    { if (vehicle _x != _x) then { (vehicle _x) setVariable ["ALIVE_profileIgnore", true] } } forEach units _grp;
};

switch (_mode) do {
    case "premark": {
        private _t0 = diag_tickTime;
        if (_groups isEqualTo []) then { _groups = allGroups };
        private _cfgV = configFile >> "CfgVehicles";
        private _missing = ((_N get "modules") + [_N get "ignoreModule"]) select { !isClass (_cfgV >> _x) };
        if (_missing isNotEqualTo []) then {
            ["ALiVE LAFS: these LAFS modules are not in this version of LAFS, so they are not looked for: %1", _missing] call ALiVE_fnc_dump;
        };
        private _modules = [];
        { _modules append (allMissionObjects _x) } forEach ((_N get "modules") - _missing);
        private _ignoredGroups = [];
        if !((_N get "ignoreModule") in _missing) then {
            { { if (!isNull group _x) then { _ignoredGroups pushBackUnique group _x } } forEach synchronizedObjects _x } forEach allMissionObjects (_N get "ignoreModule");
        };

        // the sides LAFS supports, and the classes its modules name for them
        private _sides = [];
        private _classes = createHashMap;
        {
            private _raw = _x getVariable [_N get "sideAttr", ""];
            private _side = if (_raw isEqualType "") then {
                switch (toUpper _raw) do { case "WEST": { west }; case "EAST": { east }; case "INDEPENDENT": { independent }; default { sideUnknown } }
            } else { [sideUnknown, _raw] select (_raw isEqualType west) };
            if (_side != sideUnknown) then { _sides pushBackUnique _side };
            if ((typeOf _x) in (_N get "classModules")) then {
                { _classes set [typeOf _x, true]; _classes set [typeOf vehicle _x, true] } forEach synchronizedObjects _x;
            };
        } forEach _modules;

        private _marked = [];
        private _why = [];
        // groups synced to a LAFS module are its own (manual assignment, spotter and detector templates)
        {
            private _mod = typeOf _x;
            { if (!isNull group _x && {!(group _x in _ignoredGroups)} && {!(group _x in _marked)}) then { _marked pushBack group _x; _why pushBack [group _x, "synced to " + _mod] } } forEach synchronizedObjects _x;
        } forEach _modules;
        // groups LAFS's scan will pick up
        {
            private _grp = _x;
            if (!isNull _grp && {side _grp in _sides} && {!(_grp in _ignoredGroups)} && {!(_grp getVariable [_N get "grpIgnore", false])}
                && {(units _grp) findIf { !isPlayer _x } > -1}) then {
                private _lv = vehicle leader _grp;
                if (!(_grp in _marked)) then {
                    if ((_grp getVariable [_N get "grpSupport", false]) || {_grp getVariable [_N get "grpSpotter", false]}) exitWith {
                        _marked pushBack _grp; _why pushBack [_grp, "flagged by LAFS"];
                    };
                    if (getNumber (_cfgV >> typeOf _lv >> "artilleryScanner") == 1) then {
                        _marked pushBack _grp; _why pushBack [_grp, "artillery " + typeOf _lv];
                    } else {
                        private _i = (units _grp) findIf { (typeOf _x) in _classes || {(typeOf vehicle _x) in _classes} };
                        if (_i > -1) then { private _u = (units _grp) select _i; _marked pushBack _grp; _why pushBack [_grp, "class " + typeOf _u + "/" + typeOf vehicle _u] };
                    };
                };
            };
        } forEach _groups;
        { [_x] call _fnc_mark } forEach _marked;
        ["ALiVE LAFS: LAFS is loaded (support sides %1); %2 group(s) it uses are left as live AI (%3 groups looked at in %4 ms)", _sides, count _marked, count _groups, round ((diag_tickTime - _t0) * 1000)] call ALiVE_fnc_dump;
        { ["ALiVE LAFS: left live %1 (%2) at %3, %4", _x select 0, side (_x select 0), mapGridPosition leader (_x select 0), _x select 1] call ALiVE_fnc_dump } forEach _why;

        if (isNil "ALiVE_LAFS_watching") then {
            ALiVE_LAFS_watching = true;
            ["watch"] spawn ALiVE_fnc_LAFSCompat;
        };
    };

    case "watch": {
        private _sup = _N get "grpSupport";
        private _spt = _N get "grpSpotter";
        while { true } do {
            sleep 30;
            {
                if (!(_x getVariable ["ALiVE_LAFS_released", false])
                    && {(_x getVariable [_sup, false]) || {_x getVariable [_spt, false]}}) then {
                    ["release", [_x]] call ALiVE_fnc_LAFSCompat;
                };
            } forEach allGroups;
        };
    };

    // a group LAFS has taken: its profile (and its vehicles') is forgotten, its units stay as live AI, and it is marked
    case "release": {
        private _grp = _groups param [0, grpNull];
        if (isNull _grp || {_grp getVariable ["ALiVE_LAFS_released", false]}) exitWith {};
        _grp setVariable ["ALiVE_LAFS_released", true];
        private _ids = [];
        if (!isNil "ALIVE_profileHandler") then {
            private _objs = units _grp;
            { if (vehicle _x != _x) then { _objs pushBackUnique vehicle _x } } forEach units _grp;
            {
                private _id = _x getVariable ["profileID", ""];
                if (_id isEqualType "" && {_id != ""}) then {
                    private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
                    if (!isNil "_profile") then {
                        [ALIVE_profileHandler, "unregisterProfile", _profile] call ALIVE_fnc_profileHandler;
                        _ids pushBackUnique _id;
                    };
                    _x setVariable ["profileID", nil];
                };
            } forEach _objs;
        };
        [_grp] call _fnc_mark;
        // the commanders let go at once, as for a group the War Room takes: otherwise the id sat in its
        // objective's section until the commander's next clean-up, and the objective waited on a group it no longer had
        {
            private _opcom = _x;
            if (_opcom isEqualType []) then { { [_opcom, "resetProfileOrders", _x] call ALiVE_fnc_OPCOM } forEach _ids };
        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);
        if (_ids isNotEqualTo []) then {
            ["ALiVE LAFS: %1 (%2) is now a LAFS support group: its profile %3 is let go and it stays live AI", _grp, side _grp, _ids] call ALiVE_fnc_dump;
        };
    };
};
