#include "\x\alive\addons\main\script_component.hpp"
SCRIPT(lambs);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_lambs

Description:
Everything ALiVE does with LAMBS Danger when the ALiVE (Required) module's "Other AI mods" setting is
Integrate. LAMBS fights (its tactics, tasks and radio net); ALiVE keeps the orders, the reserves, the
artillery and the intelligence. Every LAMBS function, variable and event name ALiVE uses is in this file,
so a LAMBS update is a change in one place. Written against LAMBS Danger 2.6.2.

With any other setting, or with LAMBS not loaded, every operation here does nothing.

Parameters:
String - operation
Array - arguments

Operations (callers outside this file):
"init"      [debug, artilleryPool]   - every machine, from the ALiVE (Required) module
"active"                             - true when Integrate is on and LAMBS is loaded here and on the server
"attach"    [group, profile]         - server, when a profile spawns; any machine, when a group becomes local
"detach"    [group, profile]         - server, when a profile despawns, before its waypoints are saved
"scrub"     [profile]                - server, after the despawn has saved the waypoints and vehicles: LAMBS' own
                                       waypoints are taken out, and a reserve out reinforcing is sent home
"reordered" [profile]                - server, when a profile's waypoints or commands are cleared for new orders
"sameOrders" [profile]               - server, before a clear that lays the same orders again (a route rebuild)
"order"     [profileID, kind, position, reference, expiry] - server, what the commander just ordered
"release"   [group]                  - owner, before the group moves to another machine
"creep"     [group, position]        - server, the IED ambush squad; true when LAMBS takes it
"stop"      [group, reason]          - owner, end the group's LAMBS task
"mayMove"   [group, owner id]        - server, false when the group is LAMBS' and that machine has not said it runs LAMBS
"stats"                              - log this machine's counters

Nothing here is called over the network. The machine that owns a group and the server talk through
ALiVE_fnc_lambsRemote, which checks who sent each call; a report sent straight to this function is refused.

LAMBS versions: everything under "LAMBS Danger names" is in the 2.6.2 release. The three names under
"LAMBS pull requests" are from two pull requests LAMBS has not merged or released (#501, #487). Each
is looked for before it is used and does nothing on 2.6.2, so the file works on the release as it is
and picks those changes up if they ship under the same names.

Examples:
(begin example)
["attach", [_group, _profile]] call ALiVE_fnc_lambs;
(end)

Author:
Goldwep
---------------------------------------------------------------------------- */

// LAMBS Danger names (2.6.2)
#define L_PATCH_DANGER       "lambs_danger"
#define L_PATCH_WP           "lambs_wp"
#define L_VERSION            "lambs_main_versionLoadedOnServer"
#define L_NOGROUP            "lambs_danger_disableGroupAI"
#define L_REINFORCE          "lambs_danger_enableGroupReinforce"
#define L_RADIO              "lambs_danger_dangerRadio"
#define L_NOUNIT             "lambs_danger_disableAI"
#define L_TACTIC             "lambs_danger_isExecutingTactic"
#define L_MEMORY             "lambs_main_groupMemory"
#define L_CURTACTIC          "lambs_main_currentTactic"
#define L_POOL               "lambs_wp_SideArtilleryHash"
#define L_CQBCLEARED         "lambs_main_CQB_cleared"
#define L_SHARERANGE         "lambs_main_combatShareRange"
#define L_RADIOBACKPACK      "lambs_main_radioBackpack"
#define L_FNC_ASSAULT        "lambs_wp_fnc_taskAssault"
#define L_FNC_CQB            "lambs_wp_fnc_taskCQB"
#define L_FNC_DEFEND         "lambs_wp_fnc_taskDefend"
#define L_FNC_HUNT           "lambs_wp_fnc_taskHunt"
#define L_FNC_CREEP          "lambs_wp_fnc_taskCreep"
#define L_FNC_RESET          "lambs_wp_fnc_taskReset"
#define L_FNC_OVERWATCH      "lambs_main_fnc_findOverwatch"
#define L_FNC_SHARE          "lambs_main_fnc_doShareInformation"
#define L_FNC_SHAREHANDLER   "lambs_main_fnc_addShareInformationHandler"
#define L_FNC_FRIENDLIES     "lambs_main_fnc_findNearbyFriendlies"
#define L_FNC_HASARTY        "lambs_wp_fnc_sideHasArtillery"
#define L_FNC_ARTYREGISTER   "lambs_wp_fnc_taskArtilleryRegister"
// CBA event names are not case sensitive: LAMBS raises the first as lambs_danger_onContact
#define L_EVENTS             [["lambs_danger_OnContact", "contact"], ["lambs_danger_OnAssess", "assess"], ["lambs_danger_OnReinforce", "reinforce"], ["lambs_danger_OnArtilleryCalled", "artycalled"], ["lambs_main_OnPanic", "panic"], ["lambs_main_OnFleeing", "fleeing"]]

// LAMBS pull requests, not merged or released at 2.6.2. Nothing below exists in the release: the function
// is looked for before use and the waypoint names match nothing, so on 2.6.2 these do nothing.
// #487 per-side reinforcement setting
#define L_FNC_SIDEREINFORCE  "lambs_danger_fnc_applySideReinforcementSetting"
// #501 named reinforce waypoints
#define L_WP_NAMES           ["LAMBS_Reinforce_SAD", "LAMBS_Reinforce_GUARD"]

// ALiVE's own names
#define A_DEFEND_WP          "ALiVE_lambs_defend"
// ACE's headless transfer, which moves groups itself: see "aceHold"
#define A_ACE_ON             "acex_headless_enabled"
#define A_ACE_BLACKLIST      "acex_headless_blacklist"
#define A_ACE_HELD           "ALiVE_lambs_aceHeld"

// Tuning. Distances in metres, times in seconds, budgets in counts.
// The owner's loop sees at least TICK_GROUPS groups a pass, and more when it owns so many that a
// group would otherwise wait longer than TICK_ROUND for its turn
#define TICK_SLEEP           5
#define TICK_GROUPS          10
#define TICK_ROUND           15
#define SERVERTICK_SLEEP     30
#define ASSAULT_DIST         300
#define ASSAULT_ENEMY        250
#define CQB_DIST             80
#define CQB_ENEMY            100
#define CQB_RADIUS           60
#define CQB_BUILDINGS        3
#define CQB_CAP              300
#define DEFEND_DIST          60
#define DEFEND_RADIUS        75
#define OVERWATCH_DIST       300
#define OVERWATCH_MAX        600
#define OVERWATCH_MIN        300
#define OVERWATCH_HEIGHT     8
#define HUNT_DIST            350
#define HUNT_RADIUS          300
#define HUNT_CAP             600
#define HUNT_RETARGET        150
#define SAD_DIST             200
#define SAD_RADIUS           150
#define CREEP_DIST           120
#define CREEP_RADIUS         300
#define TASK_CAP             900
#define QUIET_TIME           45
#define STUCK_TIME           300
#define RESTORE_GAP          60
#define REINFORCE_QUIET      180
#define REINFORCE_CAP        900
#define HANDOVER_TIME        60
#define SEND_CONTACT         10
#define SEND_ASSESS          20
#define SEND_MORALE          30
#define SEND_ARTY            180
#define ARTY_SIDE_GAP        60
#define ARTY_MIN_RANGE       220
#define ARTY_FRIENDLY        150
#define ARTY_COUNT_TIME      240
#define ARTY_POOL_COOLDOWN   240
#define INTEL_AGE            300
#define SHARE_PER_PASS       3
#define SHARE_PAIR_GAP       120
#define ASSESS_ENEMIES       8
#define FLEEING_DEFAULT      0.5

#define ACTIVE               (missionNamespace getVariable ["ALiVE_lambs_on", false])
#define LHAS(NAME)           (!isNil {missionNamespace getVariable NAME})
#define LFNC(NAME)           (missionNamespace getVariable [NAME, {}])
#define DEBUGON              (missionNamespace getVariable ["ALiVE_lambs_debug", false])
#define TALLY(KEY)           ALiVE_lambs_stats set [KEY, (ALiVE_lambs_stats getOrDefault [KEY, 0]) + 1]
#define OPCOMS               (missionNamespace getVariable ["OPCOM_instances", []])

params [["_operation", ""], ["_args", []]];
private _result = nil;

// The two operations a group's owner sends the server are only taken through ALiVE_fnc_lambsRemote, which
// sets _lambsDoor and names the sender. Neither is ever called from inside another remote call, so this
// turns away nothing but a direct network call. Every other operation is left open on purpose: they run on
// the server inside a client's remote call (a Zeus module, a commander tablet order).
if (_operation in ["report", "with"] && {isNil "_lambsDoor"} && {isRemoteExecuted} && {isMultiplayer}) exitWith {};

if (isNil "ALiVE_lambs_stats") then {
    ALiVE_lambs_urgent = [];                // keys of groups this machine sees to before their turn
    ALiVE_lambs_with = [];                  // server: owner ids of the other machines that run LAMBS
    ALiVE_lambs_sameOrders = createHashMap; // server: profileID -> true while its waypoints are about to be cleared and laid again
    ALiVE_lambs_stats = createHashMap;
    ALiVE_lambs_groups = createHashMap;     // key -> state of a group this machine owns
    ALiVE_lambs_active = createHashMap;     // server: profileID -> group
    ALiVE_lambs_orders = createHashMap;     // server: profileID -> [kind, position, reference, stamp, expiry, objective position]
    ALiVE_lambs_intel = createHashMap;      // server: profileID -> [time, [[enemy profileID, position], ...]]
    ALiVE_lambs_reinforcing = createHashMap; // server: profileID -> [time, position, objective centre, had a garrison]
    ALiVE_lambs_times = createHashMap;      // server: throttle key -> time
    ALiVE_lambs_firing = createHashMap;     // server: gun netId -> [battery record, time, gun]
    ALiVE_lambs_keys = 0;
    ALiVE_lambs_next = 0;
};

switch (_operation) do {

    case "active": {
        _result = ACTIVE && {LHAS(L_FNC_RESET)};
    };

    case "stats": {
        ["ALiVE LAMBS: counters on this machine: %1", ALiVE_lambs_stats toArray false] call ALiVE_fnc_dump;
        _result = +ALiVE_lambs_stats;
    };

    case "init": {
        _args params [["_debug", "false"], ["_pool", "false"]];
        if (_debug isEqualType "") then { _debug = _debug in ["true", "1"] };
        if (_pool isEqualType "") then { _pool = _pool in ["true", "1"] };

        // the mode is read by ALiVE_fnc_modConflicts, started just before this
        private _t = diag_tickTime;
        waitUntil { sleep 0.5; !isNil "ALiVE_MODCONFLICTS_MODE" || {diag_tickTime - _t > 60} };
        private _mode = missionNamespace getVariable ["ALiVE_MODCONFLICTS_MODE", "GUARD"];
        private _loaded = isClass (configFile >> "CfgPatches" >> L_PATCH_DANGER) && {isClass (configFile >> "CfgPatches" >> L_PATCH_WP)}
            && {LHAS(L_FNC_ASSAULT)} && {LHAS(L_FNC_RESET)};

        if (isServer) then {
            ALiVE_lambs_debug = _debug;
            publicVariable "ALiVE_lambs_debug";
            ALiVE_lambs_pool = _pool;
            publicVariable "ALiVE_lambs_pool";
            if (_mode == "INTEGRATE") then {
                private _why = switch (true) do {
                    case (!_loaded): { "LAMBS Danger (with its waypoints addon) is not loaded on the server" };
                    case (isNil L_VERSION): { "LAMBS Danger did not announce its version on the server" };
                    default { "" };
                };
                if (_why == "") then {
                    ALiVE_lambs_on = true;
                    publicVariable "ALiVE_lambs_on";
                    ["ALiVE LAMBS: Integrate is on with LAMBS Danger %1.", missionNamespace getVariable [L_VERSION, "?"]] call ALiVE_fnc_dump;
                } else {
                    ["ALiVE LAMBS: Integrate is set but %1, so ALiVE's groups are guarded as under Guard.", _why] call ALiVE_fnc_dump;
                };
            };
        } else {
            _t = diag_tickTime;
            waitUntil { sleep 1; !isNil "ALiVE_lambs_on" || {diag_tickTime - _t > 60} };
        };

        if (ACTIVE && {!_loaded}) exitWith {
            ["ALiVE LAMBS: the server runs LAMBS Danger and this machine does not, so the groups LAMBS runs are kept off it."] call ALiVE_fnc_dump;
        };
        if (!ACTIVE || {!isNil "ALiVE_lambs_started"}) exitWith {};
        ALiVE_lambs_started = true;
        // the server moves the groups LAMBS runs only to machines that have said they run LAMBS
        if (!isServer) then { ["with", []] remoteExecCall ["ALiVE_fnc_lambsRemote", 2] };

        // LAMBS raises its events on the machine that owns the unit
        {
            _x params ["_name", "_kind"];
            [_name, compile format ["['event', ['%1', _this]] call ALiVE_fnc_lambs", _kind]] call CBA_fnc_addEventHandler;
        } forEach L_EVENTS;

        // groups ALiVE wants quiet (recon in overwatch, ambushes, stalking teams) do not put contacts on the net
        if (LHAS(L_FNC_SHAREHANDLER)) then {
            [{
                params [["_unit", objNull]];
                private _mute = (group _unit) getVariable ["ALiVE_lambs_mute", false];
                if (_mute) then { ALiVE_lambs_stats set ["share_vetoed", (ALiVE_lambs_stats getOrDefault ["share_vetoed", 0]) + 1] };
                _mute
            }] call LFNC(L_FNC_SHAREHANDLER);
        };

        // a pass every TICK_SLEEP; a group the server flags (new orders) is seen to within a second
        [] spawn {
            private _n = 0;
            while { true } do {
                sleep 1;
                _n = _n + 1;
                if (ALiVE_lambs_urgent isNotEqualTo []) then {
                    private _urgent = ALiVE_lambs_urgent;
                    ALiVE_lambs_urgent = [];
                    { ["tick", [_x]] call ALiVE_fnc_lambs } forEach _urgent;
                };
                if (_n >= TICK_SLEEP) then { _n = 0; ["tick"] call ALiVE_fnc_lambs };
            };
        };
        if (isServer) then {
            [] spawn { while { true } do { sleep SERVERTICK_SLEEP; ["serverTick"] call ALiVE_fnc_lambs } };
        };
    };

    // ---------------------------------------------------------------------------------------------
    // Roles
    // ---------------------------------------------------------------------------------------------

    // server: [profileID] -> true when a commander holds the profile in reserve
    case "isReserve": {
        _args params [["_id", ""]];
        _result = _id != "" && {(OPCOMS findIf { _id in ([_x, "ProfileIDsReserve", []] call ALiVE_fnc_hashGet) }) > -1};
    };

    // server: [profile] -> "STATIC", "RESERVE" or "MANEUVER", from what the profile is, not what its men are doing
    case "classify": {
        _args params [["_profile", []]];
        _result = "MANEUVER";
        if (_profile isEqualTo []) exitWith {};
        private _id = [_profile, "profileID", ""] call ALiVE_fnc_hashGet;
        if (["fixed", [_profile]] call ALiVE_fnc_lambs) exitWith { _result = "STATIC" };
        if (["isReserve", [_id]] call ALiVE_fnc_lambs) exitWith { _result = "RESERVE" };
        // a garrison holds its posts under ALiVE; it is LAMBS' again once the commander moves it on
        if (["garrisoned", [_profile]] call ALiVE_fnc_lambs) then { _result = "STATIC" };
    };

    // server: [profile] -> true when the profile is ALiVE's alone for good (SPE, an artillery battery's crew,
    // aircraft, boats), as against a garrison, which is only ALiVE's until the commander moves it on
    case "fixed": {
        _args params [["_profile", []]];
        _result = false;
        if (_profile isEqualTo []) exitWith {};
        private _id = [_profile, "profileID", ""] call ALiVE_fnc_hashGet;
        private _static = [_profile, "isSPE", false] call ALiVE_fnc_hashGet;
        if (isNil "_static" || {!(_static isEqualType true)}) then { _static = false };
        // an artillery battery's crew stays under ALiVE's fire control
        if (!_static) then {
            _static = ((missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]) findIf {
                ((_x getVariable ["batteryRegistry", []]) findIf { ([_x, "entityID", ""] call ALiVE_fnc_hashGet) isEqualTo _id }) > -1
            }) > -1;
        };
        // aircraft and boats keep to ALiVE's orders alone
        if (!_static) then {
            _static = (([_profile, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet) findIf {
                private _vehicle = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                !isNil "_vehicle" && {
                    private _class = [_vehicle, "vehicleClass", ""] call ALiVE_fnc_hashGet;
                    _class isKindOf "Air" || {_class isKindOf "Ship"}
                }
            }) > -1;
        };
        _result = _static;
    };

    // server: [profile] -> true when the profile's command is a garrison
    case "garrisoned": {
        _args params [["_profile", []]];
        private _commands = [_profile, "activeCommands", []] call ALiVE_fnc_hashGet;
        _result = _commands isEqualType [] && {_commands isNotEqualTo []} && {((_commands select 0) param [0, ""]) == "ALIVE_fnc_garrison"};
    };

    // any machine: [group, role] the LAMBS switches for a role, public and explicit so they hold on any owner
    case "roleVars": {
        _args params [["_group", grpNull], ["_role", "MANEUVER"]];
        if (isNull _group) exitWith {};
        private _static = _role == "STATIC";
        _group setVariable [L_NOGROUP, _static, true];
        _group setVariable [L_REINFORCE, _role == "RESERVE", true];
        if (_role == "RESERVE") then { (leader _group) setVariable [L_RADIO, true, true] };
        if (!_static && {!(_group getVariable ["ALiVE_lambs_run", false])}) then {
            // a garrison moved on: LAMBS has it back
            _group setVariable ["ALiVE_lambs_run", true, true];
            { _x setVariable [L_NOUNIT, false, true] } forEach units _group;
            // Soldier Behaviour was put on it as a garrison: it comes off on the machine that has the group,
            // and is not put on again when the group changes machine
            if (_group getVariable ["ALiVE_AIB_eligible", false]) then {
                _group setVariable ["ALiVE_AIB_eligible", false, true];
                ["toOwner", [_group, "soldierBehaviour", [_group, false]]] call ALiVE_fnc_lambs;
                // a group that has just changed machine may have Soldier Behaviour's attach still on its way
                // (it waits 2 s after the men become local), so it is looked at once more after that
                [{
                    if (!isNull _this && {_this getVariable ["ALiVE_lambs_run", false]}) then {
                        ["toOwner", [_this, "soldierBehaviour", [_this, false]]] call ALiVE_fnc_lambs;
                    };
                }, _group, 4] call CBA_fnc_waitAndExecute;
            };
        };
        if (_static && {_group getVariable ["ALiVE_lambs_run", false]}) then {
            // not LAMBS' after all: the soldiers get what Guard gives them
            _group setVariable ["ALiVE_lambs_run", false, true];
            { ["unit", [_x]] call ALiVE_fnc_modConflicts } forEach units _group;
            // and Soldier Behaviour, as a garrison has under Guard
            if (!isNil "ALiVE_fnc_AIBehaviour" && {["setting", ["behaviourEnabled", false]] call ALiVE_fnc_AIBehaviour}) then {
                _group setVariable ["ALiVE_AIB_eligible", true, true];
                ["toOwner", [_group, "soldierBehaviour", [_group, true]]] call ALiVE_fnc_lambs;
            };
        };
    };

    // owner: [group, on] Soldier Behaviour follows a garrison out of LAMBS' hands and back
    case "soldierBehaviour": {
        _args params [["_group", grpNull], ["_on", false]];
        if (isNull _group || {!local _group} || {isNil "ALiVE_fnc_AIBehaviour"}) exitWith {};
        // in one go: the soldier behaviour tick must not act on the group half way through
        isNil {
            if (_on) then {
                ["attach", [_group]] call ALiVE_fnc_AIBehaviour;
            } else {
                if (_group getVariable ["ALiVE_AIB_attached", false]) then { ["release", [_group, "LAMBS has the group"]] call ALiVE_fnc_AIBehaviour };
            };
        };
    };

    // ---------------------------------------------------------------------------------------------
    // Spawn, despawn, change of owner
    // ---------------------------------------------------------------------------------------------

    case "attach": {
        _args params [["_group", grpNull], ["_profile", []], ["_role", ""]];
        if (!ACTIVE || {isNull _group} || {isPlayer leader _group}) exitWith {};
        private _info = _group getVariable ["ALiVE_lambs", []];

        // the server decides the role once; a new owner reads it
        if (_info isEqualTo [] && {isServer}) then {
            private _id = if (_profile isEqualTo []) then { "" } else { [_profile, "profileID", ""] call ALiVE_fnc_hashGet };
            if (_role == "") then { _role = ["classify", [_profile]] call ALiVE_fnc_lambs };
            // the garrison flag is for a group that is STATIC only because it is garrisoned
            if (_role == "STATIC" && {_profile isNotEqualTo []} && {["garrisoned", [_profile]] call ALiVE_fnc_lambs} && {!(["fixed", [_profile]] call ALiVE_fnc_lambs)}) then { _group setVariable ["ALiVE_lambs_garrison", true, true] };
            ALiVE_lambs_keys = ALiVE_lambs_keys + 1;
            _info = [_role, _id, str side _group];
            _group setVariable ["ALiVE_lambs", _info, true];
            _group setVariable ["ALiVE_lambs_key", format ["g%1", ALiVE_lambs_keys], true];
            _group setVariable ["ALiVE_lambs_stamp", 0, true];
            ["roleVars", [_group, _role]] call ALiVE_fnc_lambs;
            // under ACE's own transfer the group is held on the server from the start unless every headless
            // client runs LAMBS; "serverTick" lets it go once they all do
            ["aceHold", [_group]] call ALiVE_fnc_lambs;
            // LAMBS' per-side reinforcement setting (its PR #487) writes the flag a second after the group is made
            if (LHAS(L_FNC_SIDEREINFORCE)) then {
                [{ ["roleVars", [_this, (_this getVariable ["ALiVE_lambs", ["MANEUVER"]]) select 0]] call ALiVE_fnc_lambs }, _group, 2] call CBA_fnc_waitAndExecute;
            };
            if (_id != "") then {
                ALiVE_lambs_active set [_id, _group];
                // [machine it was last seen on, the one before, when it changed]: see "report"
                _group setVariable ["ALiVE_lambs_owners", [groupOwner _group, -1, 0]];
                _group setVariable ["ALiVE_lambs_cmd", ([_profile, "activeCommands", []] call ALiVE_fnc_hashGet) isNotEqualTo [], true];
                private _order = ALiVE_lambs_orders getOrDefault [_id, []];
                if (_order isNotEqualTo []) then {
                    _order set [3, 0];
                    _group setVariable ["ALiVE_lambs_order", _order, true];
                    if ((_order select 0) == "ambush") then { _group setVariable ["ALiVE_lambs_mute", true, true] };
                };
                // what the group knew before it went virtual
                (ALiVE_lambs_intel getOrDefault [_id, [0, []]]) params ["_at", "_enemies"];
                if (time - _at < INTEL_AGE) then {
                    { ["tell", [_group, _x select 0]] call ALiVE_fnc_lambs } forEach _enemies;
                };
            };
            TALLY("attached_" + _role);
            if (DEBUGON) then { ["ALiVE LAMBS: %1 (%2) spawned as %3.", _group, _id, _role] call ALiVE_fnc_dump };
        };
        if (_info isEqualTo [] || {!local _group}) exitWith {};

        private _key = _group getVariable ["ALiVE_lambs_key", ""];
        if (_key == "" || {_key in ALiVE_lambs_groups}) exitWith {};
        // a group that changed machine on its way to reinforce is still on its way
        private _reinforcing = _group getVariable ["ALiVE_lambs_reinf", false];
        ALiVE_lambs_groups set [_key, createHashMapFromArray [
            ["group", _group], ["task", ""], ["handle", scriptNull], ["stamp", _group getVariable ["ALiVE_lambs_stamp", 0]],
            ["started", 0], ["snap", []], ["starts", []], ["taskPos", []], ["lastEvent", [-1e6, time] select _reinforcing], ["tacticSince", -1],
            ["lastRestore", -1e6], ["reinforcing", [-1, time] select _reinforcing], ["sent", createHashMap], ["overwatch", []]
        ]];
        if (DEBUGON) then { ["ALiVE LAMBS: %1 is run from this machine.", _group] call ALiVE_fnc_dump };
    };

    // owner, before the group goes to another machine: put back what a task changed while the men can be reached
    case "release": {
        _args params [["_group", grpNull]];
        private _key = _group getVariable ["ALiVE_lambs_key", ""];
        if (_key == "" || {!(_key in ALiVE_lambs_groups)}) exitWith {};
        ["taskStop", [_key, "moving to another machine"]] call ALiVE_fnc_lambs;
        ALiVE_lambs_groups deleteAt _key;
        TALLY("released");
    };

    // server, at despawn
    case "detach": {
        _args params [["_group", grpNull], ["_profile", []]];
        if (!isServer || {!ACTIVE}) exitWith {};
        // the despawn clears the profile's waypoints next, to save them again from the group
        ["sameOrders", [_profile]] call ALiVE_fnc_lambs;
        if (isNull _group || {(_group getVariable ["ALiVE_lambs", []]) isEqualTo []}) exitWith {};
        private _key = _group getVariable ["ALiVE_lambs_key", ""];
        private _id = (_group getVariable ["ALiVE_lambs", ["", ""]]) select 1;
        // the profile keeps only the commander's waypoints: see "scrub"
        if (_profile isNotEqualTo []) then {
            [_profile, "lambsKeep", _group getVariable ["ALiVE_lambs_wpKeep", []]] call ALiVE_fnc_hashSet;
            // a reserve out reinforcing may be riding a vehicle LAMBS took: its own vehicles are noted, so
            // "scrub" can tell which links the despawn made are not its own
            if (_id in ALiVE_lambs_reinforcing) then {
                [_profile, "lambsOwn", ([_profile, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet) + ([_profile, "vehiclesInCargoOf", []] call ALiVE_fnc_hashGet)] call ALiVE_fnc_hashSet;
            };
        };
        ["toOwner", [_group, "detachLocal", [_key]]] call ALiVE_fnc_lambs;
        // a reserve still out reinforcing keeps its record: "scrub" puts its garrison back on the profile
        if (_id != "") then { ALiVE_lambs_active deleteAt _id };
        TALLY("detached");
        if (DEBUGON) then { ["ALiVE LAMBS: %1 (%2) despawned.", _group, _id] call ALiVE_fnc_dump };
    };

    // owner: the men are being deleted, so only the task thread and this machine's record go
    case "detachLocal": {
        _args params [["_key", ""]];
        private _state = ALiVE_lambs_groups getOrDefault [_key, createHashMap];
        if (count _state == 0) exitWith {};
        private _handle = _state get "handle";
        if (!isNull _handle && {(_state get "task") != "defend"}) then { terminate _handle };
        ALiVE_lambs_groups deleteAt _key;
    };

    // any machine: [group, operation, arguments] run an operation on the machine that owns the group
    case "toOwner": {
        _args params [["_group", grpNull], ["_op", ""], ["_opArgs", []]];
        if (isNull _group) exitWith {};
        if (local _group) then {
            [_op, _opArgs] call ALiVE_fnc_lambs;
        } else {
            [_op, _opArgs] remoteExecCall ["ALiVE_fnc_lambsRemote", groupOwner _group];
        };
    };

    // owner: [key] the server changed the group's orders, so it is seen to before its turn in the loop
    case "nudge": {
        _args params [["_key", ""]];
        if (_key in ALiVE_lambs_groups) then { ALiVE_lambs_urgent pushBackUnique _key };
    };

    // server: [owner id] a machine that runs LAMBS said so. A machine that has not (no LAMBS, or not ready
    // yet) is given none of the groups LAMBS runs.
    case "with": {
        _args params [["_owner", -1]];
        if (!isServer || {_owner < 0}) exitWith {};
        ALiVE_lambs_with pushBackUnique _owner;
        ["ALiVE LAMBS: machine %1 runs LAMBS Danger, so the groups LAMBS runs can be moved to it.", _owner] call ALiVE_fnc_dump;
    };

    // server: [group] with ACE's headless transfer on, ACE picks the machine a group goes to, so a group LAMBS
    // runs is put on ACE's blacklist while any headless client has not said it runs LAMBS, and taken off it
    // when they all have. Only a mark this set is ever lifted: one a mission or ALiVE's distributor set stays.
    case "aceHold": {
        _args params [["_group", grpNull]];
        if (!isServer || {isNull _group} || {!((missionNamespace getVariable [A_ACE_ON, false]) isEqualTo true)}) exitWith {};
        private _hold = !(["mayMove", [_group]] call ALiVE_fnc_lambs);
        {
            if (_hold) then {
                if !(_x getVariable [A_ACE_BLACKLIST, false]) then {
                    _x setVariable [A_ACE_BLACKLIST, true, true];
                    _x setVariable [A_ACE_HELD, true];
                };
            } else {
                // a man ALiVE itself keeps on the server for now (ALiVE_ignore_HC: a garrison walking to its
                // posts) stays held; he is looked at again on the next pass
                if (_x getVariable [A_ACE_HELD, false] && {!((_x getVariable ["ALiVE_ignore_HC", false]) isEqualTo true)}) then {
                    _x setVariable [A_ACE_BLACKLIST, nil, true];
                    _x setVariable [A_ACE_HELD, nil];
                };
            };
        } forEach units _group;
    };

    // server: [profile] at despawn, a reserve out reinforcing may be riding a vehicle LAMBS took, and the despawn
    // has just linked whatever the men ride to the profile. A link the profile did not have before ("lambsOwn",
    // noted by "detach") goes. Done on the profile data, so it holds whichever machine owns the men.
    case "unride": {
        _args params [["_profile", []]];
        if (_profile isEqualTo []) exitWith {};
        private _own = [_profile, "lambsOwn", false] call ALiVE_fnc_hashGet;
        [_profile, "lambsOwn", false] call ALiVE_fnc_hashSet;
        // no note, nothing to tell apart: every link stays
        if (isNil "_own" || {!(_own isEqualType [])}) exitWith {};
        private _inCommand = [_profile, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet;
        private _inCargo = [_profile, "vehiclesInCargoOf", []] call ALiVE_fnc_hashGet;
        private _assignments = [_profile, "vehicleAssignments", []] call ALiVE_fnc_hashGet;
        {
            private _vehicleID = _x;
            // both sides, where the vehicle's side is linked
            if (!isNil "ALIVE_profileHandler") then {
                private _vehicleProfile = [ALIVE_profileHandler, "getProfile", _vehicleID] call ALIVE_fnc_profileHandler;
                if (!isNil "_vehicleProfile") then { [_profile, _vehicleProfile] call ALIVE_fnc_removeProfileVehicleAssignment };
            };
            // the group's own side, which the despawn writes whether or not the vehicle despawned with it
            if (_assignments isEqualType [] && {count _assignments > 1} && {_vehicleID in (_assignments select 1)}) then {
                [_assignments, _vehicleID, nil] call ALiVE_fnc_hashSet;
            };
            {
                private _index = _x find _vehicleID;
                if (_index > -1) then { _x deleteAt _index };
            } forEach [_inCommand, _inCargo];
            TALLY("vehicle_returned");
        } forEach ((_inCommand + _inCargo) - _own);
        // on foot again, the virtual group moves at walking pace
        if ((_inCommand + _inCargo) isEqualTo []) then { [_profile, "speedPerSecond", "Man" call ALIVE_fnc_vehicleGetSpeedPerSecond] call ALiVE_fnc_hashSet };
    };

    // server: [group, owner id] -> false when LAMBS runs the group and that machine has not said it runs LAMBS.
    // Such a group has no Soldier Behaviour either, so there it would be left with neither.
    // [group] with no machine named (ACE's transfer picks it): true only when there is a headless client and
    // every one of them runs LAMBS, so a group is never free to go before the machines are known.
    case "mayMove": {
        _args params [["_group", grpNull], ["_owner", -1]];
        _result = true;
        // a garrison is ALiVE's for now and LAMBS' again once the commander moves it on, so it counts too
        if !(_group getVariable ["ALiVE_lambs_run", false] || {_group getVariable ["ALiVE_lambs_garrison", false]}) exitWith {};
        private _owners = if (_owner > -1) then { [_owner] } else { (allPlayers select { typeOf _x == "HeadlessClient_F" }) apply { owner _x } };
        _result = _owners isNotEqualTo [] && {(_owners findIf { !(_x in ALiVE_lambs_with) }) < 0};
        if (!_result && {_owner > -1}) then { TALLY("kept_off_machine_without_lambs") };
    };

    // server, after the despawn has saved the group's waypoints to the profile: a waypoint LAMBS made (its hunt
    // and reinforce moves, a defence's hold) must not come back as the commander's order on the next spawn
    case "scrub": {
        _args params [["_profile", []]];
        if (_profile isEqualTo []) exitWith {};
        private _keep = [_profile, "lambsKeep", []] call ALiVE_fnc_hashGet;
        [_profile, "lambsKeep", []] call ALiVE_fnc_hashSet;
        private _fnc_ours = {
            private _name = [_this, "name", ""] call ALiVE_fnc_hashGet;
            private _position = [_this, "position", [0,0,0]] call ALiVE_fnc_hashGet;
            private _type = [_this, "type", "MOVE"] call ALiVE_fnc_hashGet;
            !(!(_name in (L_WP_NAMES + [A_DEFEND_WP]))
            && {_keep isEqualTo [] || {(_keep findIf { (_x select 0) distance2D _position < 2 && {(_x select 1) == _type} }) > -1}})
        };
        // with the pathfinder on, saved waypoints wait in the pending list before they reach the profile
        private _pending = [_profile, "pendingWaypointPaths", []] call ALiVE_fnc_hashGet;
        if (_pending isEqualType [] && {_pending isNotEqualTo []}) then {
            private _kept = _pending select { !((_x param [3, []]) isEqualType []) || {(_x param [3, []]) isEqualTo []} || {!((_x select 3) call _fnc_ours)} };
            if (count _kept < count _pending) then {
                { if !(_x in _kept) then { _x set [1, "cancelled"] } } forEach _pending;
                [_profile, "pendingWaypointPaths", _kept] call ALiVE_fnc_hashSet;
                // the queue drains from its head; a ready head left behind a removed one is let through
                if (_kept isNotEqualTo [] && {(_kept select 0) select 0}) then { [_profile, "advancePendingWaypoints"] call ALIVE_fnc_profileEntity };
                TALLY("pending_scrubbed");
            };
        };
        private _waypoints = [_profile, "waypoints", []] call ALiVE_fnc_hashGet;
        private _before = count _waypoints;
        private _clean = _waypoints select { !(_x call _fnc_ours) };
        if (count _clean < _before) then {
            [_profile, "waypoints", _clean] call ALiVE_fnc_hashSet;
            TALLY("waypoints_scrubbed");
            if (DEBUGON) then { ["ALiVE LAMBS: %1 LAMBS waypoint(s) left off profile %2.", _before - count _clean, [_profile, "profileID", ""] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump };
        };
        // a reserve that despawned while out reinforcing gets its garrison, or its way home, on the profile
        private _id = [_profile, "profileID", ""] call ALiVE_fnc_hashGet;
        if (_id isEqualType "" && {_id in ALiVE_lambs_reinforcing}) then {
            ["unride", [_profile]] call ALiVE_fnc_lambs;
            ["reinforceBack", [_id, grpNull]] call ALiVE_fnc_lambs;
        };
    };

    // ---------------------------------------------------------------------------------------------
    // Orders
    // ---------------------------------------------------------------------------------------------

    // server: [profile] the profile's waypoints are about to be cleared and the same orders laid again (a
    // despawn saving them from the group, a route being rebuilt): the next "reordered" for it is not new orders
    case "sameOrders": {
        _args params [["_profile", []]];
        if (!ACTIVE || {!isServer} || {_profile isEqualTo []}) exitWith {};
        private _id = [_profile, "profileID", ""] call ALiVE_fnc_hashGet;
        if (_id isEqualType "" && {_id != ""}) then { ALiVE_lambs_sameOrders set [_id, true] };
    };

    // server: new orders are being written, so whatever LAMBS task served the old ones ends
    case "reordered": {
        _args params [["_profile", []]];
        if (!ACTIVE || {!isServer} || {_profile isEqualTo []}) exitWith {};
        private _id = [_profile, "profileID", ""] call ALiVE_fnc_hashGet;
        if !(_id isEqualType "") exitWith {};
        // a clear that lays the same orders again (see "sameOrders"): the order stands
        if (_id in ALiVE_lambs_sameOrders) exitWith { ALiVE_lambs_sameOrders deleteAt _id };
        // spawned or virtual: an order left here would come back on the next spawn
        ALiVE_lambs_orders deleteAt _id;
        private _group = ALiVE_lambs_active getOrDefault [_id, grpNull];
        if (isNull _group) exitWith {};
        _group setVariable ["ALiVE_lambs_stamp", (_group getVariable ["ALiVE_lambs_stamp", 0]) + 1, true];
        _group setVariable ["ALiVE_lambs_order", [], true];
        // the note of the old waypoints goes with them, or a despawn before the owner's next pass would
        // take the new ones off the profile
        _group setVariable ["ALiVE_lambs_wpKeep", nil, true];
        ["toOwner", [_group, "nudge", [_group getVariable ["ALiVE_lambs_key", ""]]]] call ALiVE_fnc_lambs;
    };

    // server: what the commander just ordered, so the owner can pick the LAMBS task that fits it
    case "order": {
        _args params [["_id", ""], ["_kind", ""], ["_position", []], ["_reference", ""], ["_expiry", -1]];
        if (!ACTIVE || {!isServer} || {!(_id isEqualType "")} || {count _position < 2}) exitWith {};
        private _objectivePos = +_position;
        if (_kind == "recon") then {
            {
                private _objectives = [_x, "objectivesByID"] call ALiVE_fnc_hashGet;
                if (!isNil "_objectives") then {
                    private _objective = _objectives get _reference;
                    if (!isNil "_objective") then { _objectivePos = [_objective, "center", _position] call ALiVE_fnc_hashGet };
                };
            } forEach OPCOMS;
        };
        private _group = ALiVE_lambs_active getOrDefault [_id, grpNull];
        // a new order is a new stamp, so a task serving the last one ends even where no waypoints were cleared
        if (!isNull _group) then {
            _group setVariable ["ALiVE_lambs_stamp", (_group getVariable ["ALiVE_lambs_stamp", 0]) + 1, true];
            _group setVariable ["ALiVE_lambs_wpKeep", nil, true];
            ["toOwner", [_group, "nudge", [_group getVariable ["ALiVE_lambs_key", ""]]]] call ALiVE_fnc_lambs;
        };
        private _order = [_kind, _position, _reference, [0, _group getVariable ["ALiVE_lambs_stamp", 0]] select (!isNull _group), _expiry, _objectivePos];
        ALiVE_lambs_orders set [_id, _order];
        if (!isNull _group) then {
            _group setVariable ["ALiVE_lambs_order", _order, true];
            // an ambush lies quiet
            if (_kind == "ambush") then { _group setVariable ["ALiVE_lambs_mute", true, true] };
        };
        TALLY("order_" + _kind);
    };

    // pure: which LAMBS task, if any, fits the order now
    // [kind, role, metres to the order, men on foot, anyone mounted, metres from the order to the nearest known enemy (-1: none),
    //  current waypoint is the order's, the order's waypoint is done, buildings at the order, LAMBS has taskDefend, tasks already started]
    case "taskFor": {
        _args params [["_kind", ""], ["_role", "MANEUVER"], ["_dist", 1e6], ["_foot", 0], ["_mounted", false], ["_enemy", -1],
            ["_atOrder", false], ["_done", false], ["_buildings", 0], ["_hasDefend", false], ["_starts", []]];
        _result = "";
        if (_role == "STATIC" || {_foot < 2}) exitWith {};
        private _enemyNear = { _enemy >= 0 && {_enemy <= _this} };
        _result = switch (_kind) do {
            case "capture": {
                if (!("assault" in _starts) && {_atOrder} && {_dist <= ASSAULT_DIST} && {ASSAULT_ENEMY call _enemyNear}) exitWith { "assault" };
                if (!("cqb" in _starts) && {_done} && {_dist <= CQB_DIST} && {_buildings >= CQB_BUILDINGS} && {CQB_ENEMY call _enemyNear}) exitWith { "cqb" };
                ""
            };
            case "defend": { ["", "defend"] select (!("defend" in _starts) && {_hasDefend} && {_done} && {_dist <= DEFEND_DIST}) };
            case "recon": { ["", "overwatch"] select (!("overwatch" in _starts) && {_atOrder} && {!_mounted} && {_dist <= OVERWATCH_DIST}) };
            case "attack": { ["", "hunt"] select (!("hunt" in _starts) && {_dist <= HUNT_DIST}) };
            case "sad": { ["", "sad"] select (!("sad" in _starts) && {_dist <= SAD_DIST}) };
            case "creep": { ["", "creep"] select (!("creep" in _starts) && {_dist <= CREEP_DIST}) };
            default { "" };
        };
    };

    // owner: [key, task, position, objective position]
    case "taskStart": {
        _args params [["_key", ""], ["_task", ""], ["_position", []], ["_objectivePos", []]];
        private _state = ALiVE_lambs_groups getOrDefault [_key, createHashMap];
        if (count _state == 0) exitWith {};
        private _group = _state get "group";
        if (isNull _group || {!local _group} || {(_state get "task") != ""}) exitWith {};
        (_state get "starts") pushBack _task;

        // a recon group takes high ground that looks onto the objective, and keeps quiet
        if (_task == "overwatch") exitWith {
            if (!LHAS(L_FNC_OVERWATCH)) exitWith {};
            private _spot = [_objectivePos, OVERWATCH_MAX, OVERWATCH_MIN, OVERWATCH_HEIGHT, _position] call LFNC(L_FNC_OVERWATCH);
            _state set ["overwatch", [behaviour leader _group, combatMode _group]];
            if (_spot isEqualType [] && {count _spot > 1} && {_spot distance2D _position > 5} && {!surfaceIsWater _spot}) then {
                [_group, currentWaypoint _group] setWaypointPosition [_spot, 0];
            };
            _group setBehaviour "STEALTH";
            _group setCombatMode "GREEN";
            _group setVariable ["ALiVE_lambs_mute", true, true];
            TALLY("overwatch");
            if (DEBUGON) then { ["ALiVE LAMBS: %1 takes overwatch at %2 for its recon order.", _group, _spot] call ALiVE_fnc_dump };
        };

        private _fnc = switch (_task) do {
            case "assault": { L_FNC_ASSAULT };
            case "cqb": { L_FNC_CQB };
            case "defend": { L_FNC_DEFEND };
            case "creep": { L_FNC_CREEP };
            default { L_FNC_HUNT };
        };
        if (!LHAS(_fnc)) exitWith { TALLY("task_missing_" + _task) };

        _state set ["snap", [behaviour leader _group, combatMode _group, speedMode _group, formation _group]];
        // LAMBS moves a hunting group with waypoints of its own; these are the commander's
        private _waypoints = waypoints _group;
        _group setVariable ["ALiVE_lambs_wpKeep", _waypoints apply { [waypointPosition _x, waypointType _x] }, true];

        private _callArgs = switch (_task) do {
            case "assault": { [_group, _position, false, 15, 3, true] };
            case "cqb": {
                // LAMBS marks a building cleared for good; a town taken a second time is cleared again
                { _x setVariable [format ["%1_%2", L_CQBCLEARED, str side _group], nil] } forEach (nearestObjects [_position, ["House", "Strategic", "Ruins"], CQB_RADIUS]);
                [_group, _position, CQB_RADIUS, 21, [], false]
            };
            case "defend": { [_group, _position, DEFEND_RADIUS, [], false, 0, false, false] };
            case "sad": { [_group, SAD_RADIUS, 30, [], _position, false, false] };
            case "creep": { [_group, CREEP_RADIUS, 20, [], _position, true] };
            default { [_group, HUNT_RADIUS, 30, [], _position, false, false] };
        };
        // spawned, never called: called from a scheduled script a LAMBS task holds its caller until it ends
        private _handle = _callArgs spawn LFNC(_fnc);
        if (_task == "defend") then {
            // the hold LAMBS adds is marked, so it can be found, deleted to end the defence, and kept off the profile
            // a HOLD that was not in the commander's waypoints when the defence started
            private _isNew = { params ["_wp", "_keep"]; waypointType _wp == "HOLD" && {(_keep findIf { (_x select 0) distance2D (waypointPosition _wp) < 2 && {(_x select 1) == "HOLD"} }) < 0} };
            [{ params ["_g", "_keep", "_isNew"]; isNull _g || {((waypoints _g) findIf { [_x, _keep] call _isNew }) > -1} },
             { params ["_g", "_keep", "_isNew"]; if (!isNull _g) then { { if ([_x, _keep] call _isNew) exitWith { _x setWaypointName A_DEFEND_WP } } forEach waypoints _g } },
             [_group, _group getVariable ["ALiVE_lambs_wpKeep", []], _isNew], 15] call CBA_fnc_waitUntilAndExecute;
        };
        _state set ["task", _task];
        _state set ["handle", _handle];
        _state set ["started", time];
        _state set ["taskPos", _position];
        _state set ["taskStamp", _group getVariable ["ALiVE_lambs_stamp", 0]];
        TALLY("task_start_" + _task);
        if (DEBUGON) then { ["ALiVE LAMBS: %1 starts %2 at %3.", _group, _task, _position] call ALiVE_fnc_dump };
    };

    // owner: [group, reason], for callers that hold the group and not its key
    case "stop": {
        _args params [["_group", grpNull], ["_why", "stopped"]];
        private _key = _group getVariable ["ALiVE_lambs_key", ""];
        if (_key == "") exitWith {};
        _group setVariable ["ALiVE_lambs_order", [], true];
        ["taskStop", [_key, _why]] call ALiVE_fnc_lambs;
    };

    // owner: [key, reason] end the task and give the group back as the commander left it
    case "taskStop": {
        _args params [["_key", ""], ["_why", ""]];
        private _state = ALiVE_lambs_groups getOrDefault [_key, createHashMap];
        if (count _state == 0) exitWith {};
        private _task = _state get "task";
        if (_task == "") exitWith {};
        private _group = _state get "group";
        private _handle = _state get "handle";
        // a defence is ended by deleting its hold, below: its own poll then removes its per-frame handler
        if (!isNull _handle && {_task != "defend"}) then { terminate _handle };
        _state set ["task", ""];
        _state set ["handle", scriptNull];
        if (isNull _group || {!local _group}) exitWith {};

        // a defence ends itself when its waypoint count changes, so its hold is deleted
        { if (waypointName _x == A_DEFEND_WP) then { deleteWaypoint _x } } forEach +(waypoints _group);
        // waypoints LAMBS added while it had the group
        private _keep = _group getVariable ["ALiVE_lambs_wpKeep", []];
        // after new orders the waypoints are the commander's new ones, not in the note
        private _sameOrders = (_group getVariable ["ALiVE_lambs_stamp", 0]) == (_state getOrDefault ["taskStamp", -1]);
        private _waypoints = waypoints _group;
        for "_i" from (count _waypoints - 1) to 1 step -1 do {
            private _wp = _waypoints select _i;
            private _position = waypointPosition _wp;
            private _type = waypointType _wp;
            if (waypointName _wp in L_WP_NAMES || {_keep isNotEqualTo [] && {_sameOrders} && {(_keep findIf { (_x select 0) distance2D _position < 2 && {(_x select 1) == _type} }) < 0}}) then {
                deleteWaypoint _wp;
            };
        };
        _group setVariable ["ALiVE_lambs_wpKeep", nil, true];

        // LAMBS' soft reset: the group and its waypoints stay
        if (LHAS(L_FNC_RESET)) then { [_group, true, false] call LFNC(L_FNC_RESET) };
        ["roleVars", [_group, (_group getVariable ["ALiVE_lambs", ["MANEUVER"]]) select 0]] call ALiVE_fnc_lambs;
        (_state get "snap") params [["_behaviour", "AWARE"], ["_combatMode", "YELLOW"], ["_speed", "NORMAL"], ["_formation", "WEDGE"]];
        _group setBehaviour _behaviour;
        _group setCombatMode _combatMode;
        _group setSpeedMode _speed;
        _group setFormation _formation;
        _group enableAttack true;
        _group allowFleeing FLEEING_DEFAULT;
        _group setVariable [L_MEMORY, []];
        _group setVariable [L_TACTIC, nil];
        {
            private _unit = _x;
            { _unit enableAI _x } forEach ["AUTOCOMBAT", "WEAPONAIM", "FIREWEAPON", "SUPPRESSION"];
        } forEach units _group;
        (units _group) allowGetIn true;
        if (currentWaypoint _group < count waypoints _group) then { _group setCurrentWaypoint [_group, currentWaypoint _group] };
        TALLY("task_stop_" + _task);
        if (DEBUGON) then { ["ALiVE LAMBS: %1 ends %2 (%3).", _group, _task, _why] call ALiVE_fnc_dump };
    };

    // ---------------------------------------------------------------------------------------------
    // The owner's loop: a count of groups per pass, never a time budget
    // ---------------------------------------------------------------------------------------------

    // [] a pass over the next groups in turn; [key] that one group now
    case "tick": {
        _args params [["_only", ""]];
        private _keys = keys ALiVE_lambs_groups;
        private _total = count _keys;
        if (_total == 0) exitWith {};
        private _visit = [];
        if (_only != "") then {
            if (_only in ALiVE_lambs_groups) then { _visit = [_only] };
        } else {
            _keys sort true;
            // with many groups the pass grows, so each still gets its turn inside TICK_ROUND
            for "_n" from 1 to ((TICK_GROUPS max ceil (_total * TICK_SLEEP / TICK_ROUND)) min _total) do {
                ALiVE_lambs_next = (ALiVE_lambs_next + 1) mod _total;
                _visit pushBack (_keys select ALiVE_lambs_next);
            };
        };
        {
            private _key = _x;
            private _state = ALiVE_lambs_groups getOrDefault [_key, createHashMap];
            if (count _state == 0) then { continue };
            private _group = _state get "group";

            if (isNull _group || {((units _group) findIf { alive _x }) < 0}) then {
                private _handle = _state get "handle";
                if (!isNull _handle && {(_state get "task") != "defend"}) then { terminate _handle };
                ALiVE_lambs_groups deleteAt _key;
                continue;
            };
            if (!local _group) then {
                // it left without the release; the task thread here can no longer reach the men
                private _handle = _state get "handle";
                if (!isNull _handle && {(_state get "task") != "defend"}) then { terminate _handle };
                ALiVE_lambs_groups deleteAt _key;
                TALLY("lost_to_another_machine");
                continue;
            };

            private _leader = leader _group;
            private _stamp = _group getVariable ["ALiVE_lambs_stamp", 0];
            private _order = _group getVariable ["ALiVE_lambs_order", []];
            _order params [["_kind", ""], ["_position", []], ["_reference", ""], ["_orderStamp", -1], ["_expiry", -1], ["_objectivePos", []]];
            private _task = _state get "task";

            // new orders: last order's task, starts and quiet all end with it
            if (_stamp != (_state get "stamp")) then {
                if (_task != "") then { ["taskStop", [_key, "new orders"]] call ALiVE_fnc_lambs; _task = "" };
                _state set ["stamp", _stamp];
                _state set ["starts", []];
                if (_group getVariable ["ALiVE_lambs_mute", false] && {!(_kind in ["creep", "ambush"])}) then { _group setVariable ["ALiVE_lambs_mute", false, true] };
                private _overwatch = _state get "overwatch";
                if (_overwatch isNotEqualTo []) then {
                    _group setBehaviour (_overwatch select 0);
                    _group setCombatMode (_overwatch select 1);
                    _state set ["overwatch", []];
                };
            };

            if (_task != "") then {
                private _age = time - (_state get "started");
                private _why = switch (true) do {
                    case (_kind == ""): { "order withdrawn" };
                    case (_expiry > 0 && {time > _expiry}): { "order ran out" };
                    case (_task == "cqb" && {_age > CQB_CAP}): { "time" };
                    case (_task == "hunt" && {_age > HUNT_CAP}): { "time" };
                    case (_task in ["assault", "sad", "creep"] && {_age > TASK_CAP}): { "time" };
                    case (_task == "hunt" && {count _position > 1} && {_position distance2D (_state get "taskPos") > HUNT_RETARGET}): { "target moved" };
                    case (_task == "defend" && {_age > 20} && {((waypoints _group) findIf { waypointName _x == A_DEFEND_WP }) < 0}): { "its hold is gone" };
                    case (scriptDone (_state get "handle")): { "finished" };
                    default { "" };
                };
                if (_why != "") then {
                    ["taskStop", [_key, _why]] call ALiVE_fnc_lambs;
                    if (_why == "target moved") then { _state set ["starts", (_state get "starts") - ["hunt"]] };
                };
                continue;
            };

            // a reinforcement LAMBS ordered is over once the group has been out of contact a while
            private _reinforcing = _state get "reinforcing";
            if (_reinforcing > 0) then {
                if (time - _reinforcing > REINFORCE_CAP || {time - (_state get "lastEvent") > REINFORCE_QUIET && {!(_group getVariable [L_TACTIC, false])}}) then {
                    _state set ["reinforcing", -1];
                    _group setVariable ["ALiVE_lambs_reinf", false, true];
                    private _wps = waypoints _group;
                    for "_i" from (count _wps - 1) to 0 step -1 do { if (waypointName (_wps select _i) in L_WP_NAMES) then { deleteWaypoint (_wps select _i) } };
                    (_group getVariable ["ALiVE_lambs", ["", "", ""]]) params ["", "_id", "_sideText"];
                    ["report", ["reinforceDone", _id, _sideText, getPosATL _leader, []]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                };
                continue;
            };

            // a LAMBS task for the order
            if (_kind != "" && {count _position > 1} && {_orderStamp == _stamp} && {_expiry < 0 || {time < _expiry}}) then {
                private _men = (units _group) select { alive _x && {!isPlayer _x} };
                private _foot = { isNull objectParent _x } count _men;
                private _cw = currentWaypoint _group;
                private _hasWp = _cw < count waypoints _group;
                private _atOrder = _hasWp && {(waypointPosition [_group, _cw]) distance2D _position < 60};
                private _nearest = _leader findNearestEnemy _position;
                private _dist = _leader distance2D _position;
                private _buildings = 0;
                if (_kind == "capture" && {!_atOrder} && {_dist <= CQB_DIST}) then {
                    _buildings = { (_x buildingPos -1) isNotEqualTo [] } count (nearestObjects [_position, ["House"], CQB_RADIUS]);
                };
                private _next = ["taskFor", [_kind, (_group getVariable ["ALiVE_lambs", ["MANEUVER"]]) select 0, _dist, _foot, _foot < count _men,
                    [_nearest distance2D _position, -1] select (isNull _nearest), _atOrder, !_atOrder, _buildings, LHAS(L_FNC_DEFEND), _state get "starts"]] call ALiVE_fnc_lambs;
                if (_next != "") then {
                    ["taskStart", [_key, _next, _position, _objectivePos]] call ALiVE_fnc_lambs;
                    continue;
                };
            };

            // a tactic flag LAMBS left set
            if (_group getVariable [L_TACTIC, false]) then {
                if ((_state get "tacticSince") < 0) then { _state set ["tacticSince", time] };
                if (time - (_state get "tacticSince") > STUCK_TIME && {time - (_state get "lastEvent") > STUCK_TIME}) then {
                    _group setVariable [L_TACTIC, nil];
                    _state set ["tacticSince", -1];
                    TALLY("flag_cleared");
                    if (DEBUGON) then { ["ALiVE LAMBS: %1 had a LAMBS tactic flag stuck on; cleared.", _group] call ALiVE_fnc_dump };
                };
                continue;
            };
            _state set ["tacticSince", -1];

            // aircraft, boats and gun crews are ALiVE's alone; a group a command runs follows the command
            if (((_group getVariable ["ALiVE_lambs", ["MANEUVER"]]) select 0) == "STATIC" || {_group getVariable ["ALiVE_lambs_cmd", false]}) then { continue };

            // the fight is over and the leader is standing about short of his waypoint: the commander's move is given again
            private _cw = currentWaypoint _group;
            if (_cw < count waypoints _group && {time - (_state get "lastEvent") > QUIET_TIME} && {time - (_state get "lastRestore") > RESTORE_GAP}) then {
                private _wp = [_group, _cw];
                if (waypointType _wp == "MOVE" && {((waypointStatements _wp) select 0) == "true"} && {alive _leader} && {unitReady _leader}
                    && {_leader distance2D (waypointPosition _wp) > ((waypointCompletionRadius _wp) max 30)}
                    && {((units _group) findIf { _x getVariable ["ALiVE_garrisonHeld", false] || {(_x getVariable ["ALiVE_garrisonPatrol", 0]) isNotEqualTo 0} }) < 0}) then {
                    _state set ["lastRestore", time];
                    _group setVariable [L_MEMORY, []];
                    _group enableAttack true;
                    (units _group) allowGetIn true;
                    { if (alive _x && {_x != _leader}) then { _x doFollow _leader } } forEach units _group;
                    _group setCurrentWaypoint _wp;
                    TALLY("restore_issued");
                    if (DEBUGON) then { ["ALiVE LAMBS: %1 is given its waypoint %2 again after a LAMBS tactic.", _group, _cw] call ALiVE_fnc_dump };
                };
            };
        } forEach _visit;
    };

    // ---------------------------------------------------------------------------------------------
    // LAMBS events, on the machine that owns the group
    // ---------------------------------------------------------------------------------------------

    case "event": {
        _args params [["_kind", ""], ["_data", []]];
        if (!ACTIVE) exitWith {};
        _data params [["_unit", objNull], ["_group", grpNull], ["_third", objNull], ["_fourth", []]];
        if !(_unit isEqualType objNull) exitWith {};
        if !(_group isEqualType grpNull) then { _group = group _unit };

        // a LAMBS fire mission on a gun: the server works out whether the gun is one of ALiVE's batteries
        if (_kind == "artycalled") exitWith {
            if !(missionNamespace getVariable ["ALiVE_lambs_pool", false]) exitWith {};
            private _gun = _third;
            if !(_gun isEqualType objNull) exitWith {};
            if (isNull _gun) exitWith {};
            ["report", ["artycalled", "", str side _group, _fourth, [_gun]]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
            [_gun, str side _group] spawn {
                params ["_gun", "_sideText"];
                _gun setVariable ["ALiVE_lambs_fired", 0];
                private _eh = _gun addEventHandler ["Fired", { params ["_gun"]; _gun setVariable ["ALiVE_lambs_fired", (_gun getVariable ["ALiVE_lambs_fired", 0]) + 1] }];
                private _until = time + ARTY_COUNT_TIME;
                sleep 20;
                waitUntil { sleep 5; !alive _gun || {time > _until} || {((group gunner _gun) getVariable [L_CURTACTIC, ""]) != "taskArtillery"} };
                _gun removeEventHandler ["Fired", _eh];
                ["report", ["artydone", "", _sideText, getPosATL _gun, [_gun, _gun getVariable ["ALiVE_lambs_fired", 0]]]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
            };
        };

        private _info = _group getVariable ["ALiVE_lambs", []];
        if (_info isEqualTo []) exitWith {};
        _info params ["_role", "_id", "_sideText"];
        private _key = _group getVariable ["ALiVE_lambs_key", ""];
        if !(_key in ALiVE_lambs_groups) then { ["attach", [_group]] call ALiVE_fnc_lambs };
        private _state = ALiVE_lambs_groups getOrDefault [_key, createHashMap];
        if (count _state == 0) exitWith {};
        private _sent = _state get "sent";
        // true when this kind has not been sent for the given time
        private _due = {
            params ["_what", "_gap"];
            if (time - (_sent getOrDefault [_what, -1e6]) < _gap) exitWith { ALiVE_lambs_stats set ["throttled_" + _what, (ALiVE_lambs_stats getOrDefault ["throttled_" + _what, 0]) + 1]; false };
            _sent set [_what, time];
            true
        };

        switch (_kind) do {
            case "contact": {
                _state set ["lastEvent", time];
                if (["contact", SEND_CONTACT] call _due) then {
                    TALLY("contact_seen");
                    ["report", ["contact", _id, _sideText, getPosATL _unit, [[_third] select { _x isEqualType objNull && {!isNull _x} }, 1]]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                };
            };
            case "assess": {
                _state set ["lastEvent", time];
                private _enemies = if (_third isEqualType []) then { _third select { _x isEqualType objNull && {alive _x} } } else { [] };
                if (_enemies isEqualTo []) exitWith {};
                if (["assess", SEND_ASSESS] call _due) then {
                    ["report", ["assess", _id, _sideText, getPosATL _unit, [_enemies select [0, ASSESS_ENEMIES], count _enemies, { alive _x } count units _group]]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                };
                // LAMBS' own rule for calling fire, sent to ALiVE's batteries when LAMBS has no gun of its own to call
                if (LHAS(L_FNC_FRIENDLIES) && {!(LHAS(L_FNC_HASARTY) && {[side _group] call LFNC(L_FNC_HASARTY)})}) then {
                    private _index = _enemies findIf { _unit distance2D _x > ARTY_MIN_RANGE && {([_unit, getPosATL _x, ARTY_FRIENDLY] call LFNC(L_FNC_FRIENDLIES)) isEqualTo []} };
                    if (_index > -1 && {["arty", SEND_ARTY] call _due}) then {
                        private _target = _enemies select _index;
                        ["report", ["arty", _id, _sideText, getPosATL _target, [_target, count _enemies]]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                    };
                };
            };
            case "panic";
            case "fleeing": {
                if (["morale", SEND_MORALE] call _due) then {
                    ["report", [_kind, _id, _sideText, getPosATL _unit, []]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                };
            };
            case "reinforce": {
                _state set ["lastEvent", time];
                // one reinforcement runs from its first call; the flag is public so it follows the group to another machine
                if ((_state get "reinforcing") < 0) then {
                    _state set ["reinforcing", time];
                    _group setVariable ["ALiVE_lambs_reinf", true, true];
                };
                if (["reinforce", SEND_MORALE] call _due) then {
                    ["report", ["reinforce", _id, _sideText, if (_third isEqualType [] && {count _third > 1}) then { _third } else { getPosATL _unit }, []]] remoteExecCall ["ALiVE_fnc_lambsRemote", 2];
                };
            };
        };
    };

    // ---------------------------------------------------------------------------------------------
    // The server's side
    // ---------------------------------------------------------------------------------------------

    case "report": {
        // the last is the machine it came from, set by ALiVE_fnc_lambsRemote (-1: this machine)
        _args params [["_kind", ""], ["_id", ""], ["_sideText", ""], ["_position", []], ["_payload", []], ["_sender", -1]];
        if (!isServer || {!ACTIVE}) exitWith {};
        private _group = ALiVE_lambs_active getOrDefault [_id, grpNull];
        // a report on a group comes from the machine that owns it, one on a gun from the machine that owns the gun
        private _refused = _sender > -1 && {
            if (_kind in ["artycalled", "artydone"]) then {
                private _gun = _payload param [0, objNull];
                !(_gun isEqualType objNull) || {isNull _gun} || {owner _gun != _sender}
            } else {
                // a report sent just before the group changed machine arrives after it: the machine it was on is
                // still heard for a short while, so a reserve's garrison does not wait for the expiry
                isNull _group || {
                    private _owners = _group getVariable ["ALiVE_lambs_owners", [-1, -1, 0]];
                    groupOwner _group != _sender
                    && {(_owners select 0) != _sender}
                    && {(_owners select 1) != _sender || {time - (_owners select 2) > HANDOVER_TIME}}
                }
            }
        };
        if (_refused) exitWith { TALLY("report_refused") };
        TALLY("report_" + _kind);
        private _opcoms = OPCOMS select { ([_x, "side", ""] call ALiVE_fnc_hashGet) == _sideText };

        switch (_kind) do {
            case "contact";
            case "assess": {
                _payload params [["_enemies", []], ["_count", 0], ["_own", 0]];
                private _ids = [];
                private _poss = [];
                {
                    private _enemyID = _x getVariable ["profileID", ""];
                    if (_enemyID isEqualType "" && {_enemyID != ""} && {!(_enemyID in _ids)}) then {
                        _ids pushBack _enemyID;
                        _poss pushBack (getPosATL _x);
                    };
                } forEach (_enemies select { _x isEqualType objNull && {!isNull _x} });
                if (_ids isEqualTo []) exitWith {};
                { [_x, "reportSeen", [_ids, _poss, []]] call ALiVE_fnc_OPCOM } forEach _opcoms;
                private _pairs = [];
                { _pairs pushBack [_x, _poss select _forEachIndex] } forEach _ids;
                ALiVE_lambs_intel set [_id, [time, _pairs]];
                if (DEBUGON) then { ["ALiVE LAMBS: %1 %2 reports %3 enemy group(s): %4.", _sideText, _id, count _ids, _ids] call ALiVE_fnc_dump };
            };

            // a group that is breaking marks the place for its commander
            case "panic";
            case "fleeing": {
                if (count _position > 1) then { { [_x, "reportSeen", [[], [], [_position]]] call ALiVE_fnc_OPCOM } forEach _opcoms };
                if (DEBUGON) then { ["ALiVE LAMBS: %1 %2 reports %3 at %4.", _sideText, _id, _kind, _position] call ALiVE_fnc_dump };
            };

            // a reserve group went to help on LAMBS' call: its garrison is let go, and noted so it can be put back
            case "reinforce": {
                // a second call for the same reinforcement: by now the garrison is released, so the first note stands
                private _running = ALiVE_lambs_reinforcing getOrDefault [_id, []];
                if (_running isNotEqualTo []) exitWith { _running set [0, time]; _running set [1, _position] };
                private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
                if (isNil "_profile") exitWith {};
                private _commands = [_profile, "activeCommands", []] call ALiVE_fnc_hashGet;
                private _hadGarrison = _commands isNotEqualTo [] && {((_commands select 0) param [0, ""]) == "ALIVE_fnc_garrison"};
                private _centre = [];
                {
                    private _assignment = [_x, "profileObjectiveAssignment"] call ALiVE_fnc_hashGet;
                    private _objectives = [_x, "objectivesByID"] call ALiVE_fnc_hashGet;
                    if (!isNil "_assignment" && {!isNil "_objectives"}) then {
                        private _objectiveID = _assignment get _id;
                        if (!isNil "_objectiveID") then {
                            private _objective = _objectives get _objectiveID;
                            if (!isNil "_objective") then { _centre = [_objective, "center", []] call ALiVE_fnc_hashGet };
                        };
                    };
                } forEach _opcoms;
                if (_centre isEqualTo []) then { _centre = [_profile, "position", _position] call ALiVE_fnc_hashGet };
                if (_hadGarrison) then { [_profile, "clearActiveCommands"] call ALIVE_fnc_profileEntity };
                ALiVE_lambs_reinforcing set [_id, [time, _position, _centre, _hadGarrison]];
                if (DEBUGON) then { ["ALiVE LAMBS: reserve %1 %2 goes to reinforce at %3 (garrison released: %4).", _sideText, _id, _position, _hadGarrison] call ALiVE_fnc_dump };
            };

            case "reinforceDone": { ["reinforceBack", [_id, _group]] call ALiVE_fnc_lambs };

            // a LAMBS-style call for fire, asked of ALiVE's artillery under ALiVE's own rules
            case "arty": {
                _payload params [["_target", objNull], ["_contacts", 1]];
                private _deny = switch (true) do {
                    case ((missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]) isEqualTo []): { "no Military Artillery module" };
                    case (isNull _target): { "the target is gone" };
                    case (!((_target getVariable ["profileID", ""]) isEqualType "") || {(_target getVariable ["profileID", ""]) == ""}): { "the target is not a profiled group" };
                    case (time - (ALiVE_lambs_times getOrDefault ["arty_" + _sideText, -1e6]) < ARTY_SIDE_GAP): { "the side asked a moment ago" };
                    default { "" };
                };
                if (_deny != "") exitWith {
                    TALLY("arty_denied");
                    if (DEBUGON) then { ["ALiVE LAMBS: fire asked by %1 %2 not passed on: %3.", _sideText, _id, _deny] call ALiVE_fnc_dump };
                };
                ALiVE_lambs_times set ["arty_" + _sideText, time];
                private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
                private _faction = if (isNil "_profile") then { "" } else { [_profile, "faction", ""] call ALiVE_fnc_hashGet };
                private _asym = (_opcoms findIf { ([_x, "controltype", ""] call ALiVE_fnc_hashGet) == "asymmetric" }) > -1;
                private _event = ['ARTY_REQUEST', [_target getVariable "profileID", _position, _contacts, [_sideText] call ALiVE_fnc_sideTextToObject, _faction, _asym], "LAMBS"] call ALIVE_fnc_event;
                [ALIVE_eventLog, "addEvent", _event] call ALIVE_fnc_eventLog;
                TALLY("arty_asked");
                if (DEBUGON) then { ["ALiVE LAMBS: fire asked by %1 %2 on %3 at %4 passed to ALiVE's artillery.", _sideText, _id, _target getVariable "profileID", _position] call ALiVE_fnc_dump };
            };

            // pool toggle: LAMBS took one of ALiVE's batteries, so ALiVE's own missions leave it alone meanwhile
            case "artycalled": {
                _payload params [["_gun", objNull]];
                private _record = ["batteryOf", [_gun]] call ALiVE_fnc_lambs;
                if (_record isEqualTo []) exitWith {};
                [_record, "state", "FIRING"] call ALiVE_fnc_hashSet;
                ALiVE_lambs_firing set [netId _gun, [_record, time, _gun]];
                if (DEBUGON) then { ["ALiVE LAMBS: LAMBS fires battery %1.", [_record, "entityID", ""] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump };
            };

            case "artydone": {
                _payload params [["_gun", objNull], ["_fired", 0]];
                private _record = (ALiVE_lambs_firing getOrDefault [netId _gun, []]) param [0, []];
                ALiVE_lambs_firing deleteAt (netId _gun);
                if (_record isEqualTo []) exitWith {};
                private _rounds = (([_record, "rounds", 0] call ALiVE_fnc_hashGet) - (_fired max 0)) max 0;
                [_record, "rounds", _rounds] call ALiVE_fnc_hashSet;
                [_record, "cooldownUntil", time + ARTY_POOL_COOLDOWN] call ALiVE_fnc_hashSet;
                [_record, "state", ["IDLE", "DRY"] select (_rounds <= 0)] call ALiVE_fnc_hashSet;
                // LAMBS puts a gun back in its pool after every mission; it comes out until ALiVE has it ready again
                ["unpool", [_gun]] call ALiVE_fnc_lambs;
                TALLY("pool_mission");
                if (DEBUGON) then { ["ALiVE LAMBS: battery %1 fired %2 round(s) for LAMBS, %3 left.", [_record, "entityID", ""] call ALiVE_fnc_hashGet, _fired, _rounds] call ALiVE_fnc_dump };
            };
        };
    };

    // server: [profileID, group] a reserve's reinforcement is over (its owner said so, it despawned, or the
    // word never came): its garrison is put back, or it is sent home. The group is null at despawn.
    case "reinforceBack": {
        _args params [["_id", ""], ["_group", grpNull]];
        if (!isServer) exitWith {};
        private _record = ALiVE_lambs_reinforcing getOrDefault [_id, []];
        ALiVE_lambs_reinforcing deleteAt _id;
        private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
        if (_record isEqualTo [] || {isNil "_profile"}) exitWith {};
        _record params ["", "", "_centre", "_hadGarrison"];
        // LAMBS takes an empty vehicle within 75 m for a group that has none; one that is not the profile's goes back
        if (!isNull _group) then {
            _group setVariable ["ALiVE_lambs_reinf", false, true];
            private _own = (([_profile, "vehiclesInCommandOf", []] call ALiVE_fnc_hashGet) + ([_profile, "vehiclesInCargoOf", []] call ALiVE_fnc_hashGet)) apply {
                private _vehicle = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                if (isNil "_vehicle") then { objNull } else { [_vehicle, "vehicle", objNull] call ALiVE_fnc_hashGet }
            };
            {
                if !(_x in _own) then {
                    ["toOwner", [_group, "unassign", [_group, _x]]] call ALiVE_fnc_lambs;
                    TALLY("vehicle_returned");
                };
            } forEach (assignedVehicles _group);
        };
        if (count _centre > 1) then {
            if (_hadGarrison) then {
                [_profile, "setActiveCommand", ["ALIVE_fnc_garrison", "spawn", [200, "true", _centre]]] call ALIVE_fnc_profileEntity;
            } else {
                [_profile, "addWaypoint", [_centre, 15] call ALIVE_fnc_createProfileWaypoint] call ALIVE_fnc_profileEntity;
            };
        };
        TALLY("reinforce_back");
        if (DEBUGON) then { ["ALiVE LAMBS: reserve %1 is sent back to %2 (garrison: %3).", _id, _centre, _hadGarrison] call ALiVE_fnc_dump };
    };

    // owner: the server found a vehicle LAMBS took that is not the profile's
    case "unassign": {
        _args params [["_group", grpNull], ["_vehicle", objNull]];
        if (isNull _group || {isNull _vehicle} || {!local _group}) exitWith {};
        _group leaveVehicle _vehicle;
    };

    // server: [group, enemy profileID] show the group an enemy the commander knows of, and let LAMBS pass it on
    case "tell": {
        _args params [["_group", grpNull], ["_enemyID", ""]];
        if (!isServer || {isNull _group}) exitWith {};
        private _enemy = [ALIVE_profileHandler, "getProfile", _enemyID] call ALIVE_fnc_profileHandler;
        if (isNil "_enemy" || {!([_enemy, "active", false] call ALiVE_fnc_hashGet)}) exitWith {};
        private _leader = [_enemy, "leader", objNull] call ALiVE_fnc_hashGet;
        if (!(_leader isEqualType objNull) || {isNull _leader} || {!alive _leader}) exitWith {};
        [_group, [_leader, 1.5]] remoteExecCall ["reveal", groupOwner _group];
        ["toOwner", [_group, "share", [_group, _leader]]] call ALiVE_fnc_lambs;
        TALLY("told");
    };

    // owner: a moment after the reveal, the leader puts it on the LAMBS net inside LAMBS' own ranges
    case "share": {
        _args params [["_group", grpNull], ["_enemy", objNull]];
        if (isNull _group || {isNull _enemy} || {!local _group} || {!LHAS(L_FNC_SHARE)}) exitWith {};
        [{
            params ["_group", "_enemy"];
            if (isNull _group || {isNull _enemy} || {!alive leader _group}) exitWith {};
            [leader _group, _enemy] call (missionNamespace getVariable [L_FNC_SHARE, {}]);
        }, [_group, _enemy], 1] call CBA_fnc_waitAndExecute;
        TALLY("shared");
    };

    // server: [gun] -> the ALiVE battery record the gun belongs to, or []
    case "batteryOf": {
        _args params [["_gun", objNull]];
        _result = [];
        if (isNull _gun) exitWith {};
        private _vehicleID = _gun getVariable ["profileID", ""];
        if (!(_vehicleID isEqualType "") || {_vehicleID == ""}) exitWith {};
        {
            {
                if (_vehicleID in ([_x, "vehicleIDs", []] call ALiVE_fnc_hashGet)) exitWith { _result = _x };
            } forEach (_x getVariable ["batteryRegistry", []]);
            if (_result isNotEqualTo []) exitWith {};
        } forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]);
    };

    // server: [gun] take a gun out of the LAMBS pool (LAMBS has no call for it)
    case "unpool": {
        _args params [["_gun", objNull]];
        if (!isServer) exitWith {};
        _gun setVariable ["ALiVE_lambs_pooled", false];
        private _pool = missionNamespace getVariable [L_POOL, createHashMap];
        private _changed = false;
        {
            if (_gun in _y) then { _pool set [_x, _y - [_gun]]; _changed = true };
        } forEach +_pool;
        if (_changed) then { publicVariable L_POOL };
    };

    case "serverTick": {
        if (!isServer || {!ACTIVE}) exitWith {};

        // roles follow the commander's reserve list; records of profiles that are gone are dropped
        {
            private _id = _x;
            private _group = _y;
            if (isNull _group) then { ALiVE_lambs_active deleteAt _id; continue };
            private _info = _group getVariable ["ALiVE_lambs", []];
            if (_info isEqualTo []) then { continue };
            // the machine the group is on is noted, with the one before it and when it changed: see "report"
            private _owners = _group getVariable ["ALiVE_lambs_owners", [-1, -1, 0]];
            private _ownerNow = groupOwner _group;
            if (_ownerNow != (_owners select 0)) then { _group setVariable ["ALiVE_lambs_owners", [_ownerNow, _owners select 0, time]] };
            // ACE's transfer: held or let go as the headless clients come and go
            ["aceHold", [_group]] call ALiVE_fnc_lambs;
            private _profile = [ALIVE_profileHandler, "getProfile", _id] call ALIVE_fnc_profileHandler;
            if (isNil "_profile") then { continue };
            // aircraft, boats, gun crews and SPE stay STATIC; only a garrison moves in and out of it
            private _role = ["classify", [_profile]] call ALiVE_fnc_lambs;
            if ((_info select 0) == "STATIC" && {_role == "STATIC" || {!(_group getVariable ["ALiVE_lambs_garrison", false])}}) then { continue };
            // a group that turns STATIC for good (a crew whose battery is listed after it spawned) is no garrison
            private _garrison = _role == "STATIC" && {!(["fixed", [_profile]] call ALiVE_fnc_lambs)};
            // a group a command runs (patrol and the like) is not given its waypoint again by the owner
            private _cmd = ([_profile, "activeCommands", []] call ALiVE_fnc_hashGet) isNotEqualTo [];
            if (_cmd isNotEqualTo (_group getVariable ["ALiVE_lambs_cmd", false])) then { _group setVariable ["ALiVE_lambs_cmd", _cmd, true] };
            // in one go: "mayMove" reads the garrison flag and the role's switches, and this loop is scheduled, so
            // the AI Distributor must not look at the group between the two being written
            isNil {
                if (_garrison isNotEqualTo (_group getVariable ["ALiVE_lambs_garrison", false])) then { _group setVariable ["ALiVE_lambs_garrison", _garrison, true] };
                if (_role != (_info select 0)) then {
                    _group setVariable ["ALiVE_lambs", [_role, _id, _info select 2], true];
                    ["roleVars", [_group, _role]] call ALiVE_fnc_lambs;
                    // the role decides whether ACE may move the group, so the hold is looked at again with the new one
                    ["aceHold", [_group]] call ALiVE_fnc_lambs;
                    if (DEBUGON) then { ["ALiVE LAMBS: %1 (%2) is now %3.", _group, _id, _role] call ALiVE_fnc_dump };
                };
            };
        } forEach +ALiVE_lambs_active;
        {
            private _map = _x;
            { if (isNil { [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler }) then { _map deleteAt _x } } forEach (keys _map);
        } forEach [ALiVE_lambs_orders, ALiVE_lambs_intel, ALiVE_lambs_reinforcing];

        // a reinforcement whose end was never reported (its owner dropped): the reserve goes back all the same
        {
            if (time - (_y select 0) > REINFORCE_CAP + 120) then {
                TALLY("reinforce_expired");
                ["reinforceBack", [_x, ALiVE_lambs_active getOrDefault [_x, grpNull]]] call ALiVE_fnc_lambs;
            };
        } forEach +ALiVE_lambs_reinforcing;

        // a battery LAMBS took whose mission never reported its end (the gun deleted, its owner dropped) is ALiVE's again
        {
            // read from the map itself: a copy of it would copy the battery record too
            (ALiVE_lambs_firing get _x) params ["_record", "_at", "_gun"];
            if (isNull _gun || {!alive _gun} || {time - _at > ARTY_COUNT_TIME + 60}) then {
                ALiVE_lambs_firing deleteAt _x;
                [_record, "cooldownUntil", time + ARTY_POOL_COOLDOWN] call ALiVE_fnc_hashSet;
                [_record, "state", ["IDLE", "DRY"] select (([_record, "rounds", 0] call ALiVE_fnc_hashGet) <= 0)] call ALiVE_fnc_hashSet;
                if (!isNull _gun) then { ["unpool", [_gun]] call ALiVE_fnc_lambs };
                TALLY("pool_expired");
                if (DEBUGON) then { ["ALiVE LAMBS: battery %1 taken back from a LAMBS mission that never reported its end.", [_record, "entityID", ""] call ALiVE_fnc_hashGet] call ALiVE_fnc_dump };
            };
        } forEach (keys ALiVE_lambs_firing);

        // an attack order follows its target; with the target gone the order goes too
        {
            _y params ["_kind", "_position", "_reference", "", "_expiry", "_objectivePos"];
            if (_kind != "attack") then { continue };
            private _group = ALiVE_lambs_active getOrDefault [_x, grpNull];
            private _target = [ALIVE_profileHandler, "getProfile", _reference] call ALIVE_fnc_profileHandler;
            if (isNil "_target") then {
                ALiVE_lambs_orders deleteAt _x;
                if (!isNull _group) then { _group setVariable ["ALiVE_lambs_order", [], true] };
                continue;
            };
            private _now = [_target, "position", _position] call ALiVE_fnc_hashGet;
            if (_now isEqualType [] && {count _now > 1} && {_now distance2D _position > HUNT_RETARGET}) then {
                private _order = ["attack", _now, _reference, [0, _group getVariable ["ALiVE_lambs_stamp", 0]] select (!isNull _group), _expiry, _now];
                ALiVE_lambs_orders set [_x, _order];
                if (!isNull _group) then { _group setVariable ["ALiVE_lambs_order", _order, true] };
            };
        } forEach +ALiVE_lambs_orders;

        // what a commander has newly been told of goes to the nearest of its spawned groups, a few a pass
        private _shareRange = (missionNamespace getVariable [L_SHARERANGE, 200]) + (missionNamespace getVariable [L_RADIOBACKPACK, 2000]);
        private _last = ALiVE_lambs_times getOrDefault ["knownSeen", time];
        ALiVE_lambs_times set ["knownSeen", time];
        private _shares = 0;
        {
            private _opcom = _x;
            private _sideText = [_opcom, "side", ""] call ALiVE_fnc_hashGet;
            private _seen = [_opcom, "knownSeen"] call ALiVE_fnc_hashGet;
            if (isNil "_seen") then { continue };
            {
                if (_shares >= SHARE_PER_PASS) exitWith {};
                _y params [["_position", [0,0,0]], ["_at", 0]];
                if (_at <= _last || {(_x select [0, 7]) == "report_"}) then { continue };
                private _enemyID = _x;
                private _best = grpNull;
                private _bestDist = _shareRange;
                {
                    private _info = _y getVariable ["ALiVE_lambs", ["STATIC", "", ""]];
                    if (!isNull _y && {(_info select 2) == _sideText} && {(_info select 0) != "STATIC"}) then {
                        private _dist = (leader _y) distance2D _position;
                        if (_dist < _bestDist) then { _bestDist = _dist; _best = _y };
                    };
                } forEach ALiVE_lambs_active;
                if (isNull _best) then { continue };
                private _pair = format ["tell_%1_%2", _best getVariable ["ALiVE_lambs_key", ""], _enemyID];
                if (time - (ALiVE_lambs_times getOrDefault [_pair, -1e6]) < SHARE_PAIR_GAP) then { continue };
                ALiVE_lambs_times set [_pair, time];
                ["tell", [_best, _enemyID]] call ALiVE_fnc_lambs;
                _shares = _shares + 1;
            } forEach _seen;
        } forEach OPCOMS;
        { if (time - _y > 1800) then { ALiVE_lambs_times deleteAt _x } } forEach +ALiVE_lambs_times;

        // pool toggle: ALiVE's idle batteries with rounds are offered to LAMBS, the rest are taken back
        if ((missionNamespace getVariable ["ALiVE_lambs_pool", false]) && {LHAS(L_FNC_ARTYREGISTER)}) then {
            {
                {
                    private _record = _x;
                    private _ready = ([_record, "state", ""] call ALiVE_fnc_hashGet) == "IDLE" && {([_record, "rounds", 0] call ALiVE_fnc_hashGet) > 0}
                        && {time > ([_record, "cooldownUntil", 0] call ALiVE_fnc_hashGet)};
                    {
                        private _vehicle = [ALIVE_profileHandler, "getProfile", _x] call ALIVE_fnc_profileHandler;
                        if (isNil "_vehicle") then { continue };
                        private _gun = [_vehicle, "vehicle", objNull] call ALiVE_fnc_hashGet;
                        if (!(_gun isEqualType objNull) || {isNull _gun}) then { continue };
                        private _pooled = _gun getVariable ["ALiVE_lambs_pooled", false];
                        if (_ready && {!_pooled} && {alive gunner _gun}) then {
                            _gun setVariable ["ALiVE_lambs_pooled", true];
                            [gunner _gun] call LFNC(L_FNC_ARTYREGISTER);
                            TALLY("pool_offered");
                        };
                        if (!_ready && {_pooled}) then { ["unpool", [_gun]] call ALiVE_fnc_lambs };
                    } forEach ([_record, "vehicleIDs", []] call ALiVE_fnc_hashGet);
                } forEach (_x getVariable ["batteryRegistry", []]);
            } forEach (missionNamespace getVariable ["ALIVE_MilArtilleryInstances", []]);
        };
    };

    // ---------------------------------------------------------------------------------------------
    // Asymmetric: the squad that comes in after an IED stalks the survivors
    // ---------------------------------------------------------------------------------------------

    case "creep": {
        _args params [["_group", grpNull], ["_position", []]];
        _result = false;
        if (!isServer || {!(["active"] call ALiVE_fnc_lambs)} || {!LHAS(L_FNC_CREEP)} || {isNull _group} || {count _position < 2}) exitWith {};
        // its thread runs on the server, so the group stays there
        { _x setVariable ["ALiVE_ignore_HC", true, true] } forEach units _group;
        _group setVariable ["ALiVE_lambs_run", true, true];
        ["attach", [_group, [], "MANEUVER"]] call ALiVE_fnc_lambs;
        _group setVariable ["ALiVE_lambs_mute", true, true];
        _group setVariable ["ALiVE_lambs_order", ["creep", _position, "", 0, -1, _position], true];
        _result = true;
    };
};

if (isNil "_result") then { nil } else { _result };
