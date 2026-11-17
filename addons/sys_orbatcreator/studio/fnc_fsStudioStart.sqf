#include "\x\alive\addons\sys_orbatcreator\script_component.hpp"
SCRIPT(fsStudioStart);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fsStudioStart

Description:
Starts the studio once per mission. Always spawned: it waits.
    1. In one isNil block, so two starts cannot both pass: when a session
       exists, it calls ALiVE_fnc_fsStudioReopen and ends; else it makes the
       session with starting = true.
    2. Waits for the mission to run, the player and the main display.
    3. Picks the Arsenal: the module's arsenalType in module mode, else the
       "arsenal" pref, else BIS; BIS with S_ACE_MISSING when ACE's is not loaded.
    4. Loads the working faction ("ok"), or starts a new one ("none", tagged
       from the module's prefix when it passes the tag rule), or shows an empty
       one with S_LOAD_REFUSED ("refused"; nothing is saved over the old one).
    5. Stage, camera (only when those functions are loaded), display; then
       starting = false.
    6. Module mode: Virtual Arsenal preload, and the ALiVE menu row once per
       logic (ALiVE_FS_menuAdded, the same guard as the classic start).
    7. With the studio on screen: static data, then the class index unless one
       exists or is being built.

Parameters:
    _mode  - STRING - "scene" or "module"
    _logic - OBJECT - the module logic in module mode, else objNull

Returns:
    Nothing

Examples:
    (begin example)
    ["module", _logic] spawn ALiVE_fnc_fsStudioStart;
    ["scene", objNull] spawn ALiVE_fnc_fsStudioStart;
    (end)

See Also:
    ALiVE_fnc_fsStudioReopen, ALiVE_fnc_fsStudioOpen, ALiVE_fnc_fsDataStore

Author:
    Jman
---------------------------------------------------------------------------- */

#include "\x\alive\addons\sys_orbatcreator\fs_defines.hpp"
#include "\x\alive\addons\sys_orbatcreator\data\ui\studio\idc.hpp"

if (!hasInterface) exitWith {};

params [["_mode", "scene", [""]], ["_logic", objNull, [objNull]]];

if !(_mode in ["scene", "module"]) then { _mode = "scene" };
if (isNull _logic) then { _mode = "scene" };

// 1. one start per mission
private _first = false;
isNil {
    if (isNil "ALiVE_FS_session") then {
        private _new = createHashMapFromArray [
            ["mode", _mode], ["logic", _logic], ["starting", true], ["display", displayNull],
            ["tab", "faction"], ["selUnit", ""], ["selVehicle", ""], ["selGroup", ""], ["groupCategory", "Infantry"],
            ["body", objNull], ["bodyRef", ""], ["bodyGen", 0], ["stagePos", []], ["backdrop", []],
            ["camera", objNull], ["cam", []], ["drag", []],
            ["arsenal", "BIS"], ["arsenalBusy", false], ["arsenalUnit", ""], ["arsenalUndo", []], ["arsenalHandlers", []],
            ["exportBusy", false], ["exportAbort", false], ["exiting", false], ["suspended", false],
            ["log", []], ["missing", createHashMap]
        ];
        missionNamespace setVariable ["ALiVE_FS_session", _new];
        _first = true;
    };
};
if (!_first) exitWith { [] call ALiVE_fnc_fsStudioReopen };

private _session = missionNamespace getVariable "ALiVE_FS_session";

// 2.
waitUntil { time > 0 && {!isNull player} && {!isNull (findDisplay 46)} };

// the last tab used, when it is still a tab
private _tab = ["prefGet", ["tab", "faction"]] call ALiVE_fnc_fsDataStore;
if (_tab isEqualType "" && {_tab in ["faction", "units", "vehicles", "groups", "export"]}) then { _session set ["tab", _tab] };

// 3. Arsenal
private _arsenal = if (_mode == "module") then {
    _logic getVariable ["arsenalType", "BIS"]
} else {
    ["prefGet", ["arsenal", "BIS"]] call ALiVE_fnc_fsDataStore
};
if !(_arsenal isEqualType "") then { _arsenal = "BIS" };
_arsenal = toUpper _arsenal;
if !(_arsenal in ["BIS", "ACE"]) then { _arsenal = "BIS" };

private _aceMissing = false;
if (_arsenal == "ACE") then {
    // the same test as the classic isACEArsenalAvailable, until fsStudioArsenal is loaded
    private _ace = if (isNil "ALiVE_fnc_fsStudioArsenal") then {
        isClass (configFile >> "CfgPatches" >> "ace_arsenal") && {!isNil "ace_arsenal_fnc_openBox"}
    } else {
        ["available"] call ALiVE_fnc_fsStudioArsenal
    };
    if !(_ace isEqualTo true) then { _arsenal = "BIS"; _aceMissing = true };
};
_session set ["arsenal", _arsenal];

// 4. the working faction
(["loadCurrent"] call ALiVE_fnc_fsDataStore) params ["_state", "_faction", "_problems", "_notes"];
private _status = [];

switch (_state) do {
    case "ok": {
        missionNamespace setVariable ["ALiVE_FS_faction", _faction];
    };
    case "refused": {
        missionNamespace setVariable ["ALiVE_FS_faction", [] call ALiVE_fnc_fsDataNew];
        private _why = "";
        if ((count _problems) > 0) then {
            private _problem = _problems select 0;
            if (_problem isEqualType [] && {(count _problem) > 1}) then {
                _why = _problem select 1;
                if !(_why isEqualType "") then { _why = str _why };
            };
        };
        _status = [2, "S_LOAD_REFUSED", [_why]];
    };
    default {
        // "none": a new faction, tagged from the module's prefix when it passes the tag rule
        private _tag = "";
        if (_mode == "module") then {
            private _prefix = _logic getVariable ["prefix", ""];
            if (_prefix isEqualType "") then {
                _prefix = (toUpper _prefix) select [0, 8];
                if (([_prefix, "tag"] call ALiVE_fnc_fsDataCheckValue) isEqualTo "") then { _tag = _prefix };
            };
        };
        missionNamespace setVariable ["ALiVE_FS_faction", ["", _tag, 1] call ALiVE_fnc_fsDataNew];
    };
};

// the status the start leaves on the line: ready, or the refused load
if (_status isEqualTo []) then {
    private _f = missionNamespace getVariable ["ALiVE_FS_faction", createHashMap];
    private _n = _f getOrDefault ["name", ""];
    if (_n isEqualTo "") then { _n = _f getOrDefault ["tag", ""] };
    // a faction with neither name nor tag yet says so, not "ready: ."
    _status = if (_n isEqualTo "") then { [0, "S_READY_NEW", [FS_NAME]] } else { [0, "S_READY", [FS_NAME, _n]] };
};
_status call ALiVE_fnc_fsStudioStatus;
if (_aceMissing) then { [1, "S_ACE_MISSING", []] call ALiVE_fnc_fsStudioStatus };

// 5. stage, camera, display
if (!isNil "ALiVE_fnc_fsStudioStage") then { ["create"] call ALiVE_fnc_fsStudioStage };
if (!isNil "ALiVE_fnc_fsStudioCamera") then { ["create"] call ALiVE_fnc_fsStudioCamera };
[] call ALiVE_fnc_fsStudioOpen;
_session set ["starting", false];

// 6. module mode: Arsenal preload and the ALiVE menu row, once per logic
if (_mode == "module") then {
    if (_arsenal == "BIS") then { ["Preload"] call BIS_fnc_arsenal };

    if !(_logic getVariable ["ALiVE_FS_menuAdded", false]) then {
        [
            "player",
            [] call ALiVE_fnc_menuKeys,
            -9500,
            [
                "call ALiVE_fnc_orbatCreatorMenuDef",
                ["main", "alive_flexiMenu_rscPopup"]
            ]
        ] call CBA_fnc_flexiMenu_Add;
        _logic setVariable ["ALiVE_FS_menuAdded", true];
    };
};

// 7. static data (it waits, so it runs here), then the class index
call ALiVE_fnc_staticDataHandler;

if (isNil { uiNamespace getVariable "ALiVE_FS_index" } && {!(missionNamespace getVariable ["ALiVE_FS_indexBuilding", false])}) then {
    missionNamespace setVariable ["ALiVE_FS_indexBuilding", true];
    [0, "BR_BUILDING", [(count (configFile >> "CfgVehicles")) toFixed 0]] call ALiVE_fnc_fsStudioStatus;
    [] call ALiVE_fnc_fsIndexBuild;
    _status call ALiVE_fnc_fsStudioStatus;
};
