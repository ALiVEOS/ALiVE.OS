#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsAlivePreview);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsAlivePreview

Description:
What ALiVE will read from the faction's export, worked out from the model
through ALiVE_fnc_fsGenPlan on a snapshot; nothing is written and nothing in
the game is read but config:
    - per ALiVE category: its group count and how it stands (ALiVE_fnc_fsAliveCheck);
    - each list (supplies, supports, transport, airTransport, containers, aa) as
      the class names the export writes, and whether the studio works it out;
    - the mapping: none needed (the faction's own groups as they are), or a
      mapping with N redirects;
    - for a faction with no groups, that ALiVE will borrow its side's stock groups;
    - the exact CfgALiVEFactions block text, for adding it to another mod by hand.

Parameters:
    _faction - HASHMAP - the studio faction (a snapshot is taken here)

Returns:
    HASHMAP - hook (BOOL), rarity (BOOL), cats (ARRAY of [category, state, groups,
              redirectTo]), lists (ARRAY of [name, classes, automatic]),
              redirects (NUMBER), groups (NUMBER), crates (ARRAY of [class, name,
              rows]), text (STRING, empty when the hook is off)

Examples:
    (begin example)
    private _p = [_faction] call ALiVE_fnc_fsAlivePreview;
    (end)

See Also:
    ALiVE_fnc_fsAliveLive, ALiVE_fnc_fsGenAlive, ALiVE_fnc_fsStudioTabAlive

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"

params [["_faction", createHashMap, [createHashMap]]];

// a copy no edit can reach, through the same round trip the profile uses
([[_faction] call ALiVE_fnc_fsDataToPlain] call ALiVE_fnc_fsDataFromPlain) params ["_ok", "_snap"];
if (!_ok) then { _snap = _faction };

private _alive = _snap getOrDefault ["alive", createHashMap];
private _auto = _alive getOrDefault ["auto", FS_ALIVE_LISTS];
private _plan = [_snap] call ALiVE_fnc_fsGenPlan;
private _hook = _plan getOrDefault ["hook", false];
private _lists = _plan getOrDefault ["alive", createHashMap];

// supplies follow the crates; containers are never worked out
private _autoOf = createHashMapFromArray [
    ["supplies", "crates" in _auto],
    ["supports", "supports" in _auto],
    ["transport", "transport" in _auto],
    ["airTransport", "airTransport" in _auto],
    ["containers", false],
    ["aa", "aa" in _auto]
];
private _groupCount = count (_snap getOrDefault ["groups", createHashMap]);

createHashMapFromArray [
    ["hook", _hook],
    ["rarity", _alive getOrDefault ["rarity", true]],
    ["cats", [_snap] call ALiVE_fnc_fsAliveCheck],
    ["lists", ["supplies", "supports", "transport", "airTransport", "containers", "aa"] apply { [_x, _lists getOrDefault [_x, []], _autoOf get _x] }],
    ["redirects", count (_plan getOrDefault ["aliveTypes", []])],
    ["groups", _groupCount],
    ["crates", (_plan getOrDefault ["crates", []]) apply { [_x select 0, _x select 2, count (_x select 3)] }],
    ["text", ([_plan, _snap] call ALiVE_fnc_fsGenAlive) joinString toString [13, 10]]
]
