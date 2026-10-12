#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobObjectives);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobObjectives

Description:
A FOB as an objective for the AI Commanders. Its own side's commanders get it at the front of
their list, sized to the build range, so they send men to hold it. Enemy commanders get it too,
so they send men to take it: from the start with Enemy Targeting set to Immediate, or once that
side has found the FOB with Contact (its men came within the Discovery Radius, or shot at the
headquarters). Off keeps enemy commanders out of it.

Every objective carries the FOB's id ("fobID"). Commanders never save these (the FOB is saved
here and adds them again on load), and an insurgent commander with nobody free borrows a
section for one as it does for a player's objective.

reconcile works out the objectives a FOB should have and adds or removes to match, so a
commander that reloaded its objectives, a FOB that changed hands, or a step cut short is put
right on the next watchdog pass.

Parameters:
String - The operation
Array - Its arguments

Returns:
register - [fobID] -> the number of objectives the FOB now has
unregister - [fobID] -> the number removed
reconcile - [fobID] -> the number added

Author:
Jman
---------------------------------------------------------------------------- */

if (isRemoteExecuted && {remoteExecutedOwner != 2} && {isNil "_ALiVE_fobCaller"}) exitWith {};
if (!isServer) exitWith {};

params [["_op", "", [""]], ["_args", [], [[]]]];
_args params [["_id", "", [""]]];

private _entry = [ALiVE_FOB_registry, _id] call ALIVE_fnc_hashGet;
if (isNil "_entry") exitWith {0};

private _logic = missionNamespace getVariable ["ALiVE_sup_fob", objNull];
private _debug = [_logic, "attribute", ["fob_debug"]] call ALiVE_fnc_FOB;
private _result = 0;

// The objective id in a commander: its own id, then the FOB's, so it is the same every session
private _objID = { format ["%1_%2", [_this, "opcomID", ""] call ALiVE_fnc_HashGet, _id] };
private _opcomByID = {
    private _i = (missionNamespace getVariable ["OPCOM_instances", []]) findIf { ([_x, "opcomID", ""] call ALiVE_fnc_HashGet) == _this };
    if (_i < 0) then { nil } else { OPCOM_instances select _i }
};

switch (_op) do {

    case "register";
    case "reconcile": {
        private _side = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        private _size = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        private _mode = [_logic, "attribute", ["fob_enemy_targeting"]] call ALiVE_fnc_FOB;
        private _found = [_entry, "discoveredBy", []] call ALIVE_fnc_hashGet;

        // which commanders should have it
        private _want = (missionNamespace getVariable ["OPCOM_instances", []]) select {
            private _s = [_x, "side", ""] call ALiVE_fnc_HashGet;
            (_s == _side) || {_mode != "OFF" && {_side in ([_x, "sidesenemy", []] call ALiVE_fnc_HashGet)} && {_mode == "IMMEDIATE" || {_s in _found}}}
        };

        // add what's missing
        private _pairs = [];
        {
            private _opcom = _x;
            private _opcomID = [_opcom, "opcomID", ""] call ALiVE_fnc_HashGet;
            private _oid = _opcom call _objID;
            private _have = ([_opcom, "objectivesByID", createHashMap] call ALiVE_fnc_HashGet) get _oid;
            if (isNil "_have" || {[_have, "deleted", false] call ALiVE_fnc_HashGet}) then {
                private _obj = [_opcom, "addObjective", [_oid, _pos, _size, "fob", 100, "unassigned", "none", _opcomID, false, true]] call ALiVE_fnc_OPCOM;
                if (!isNil "_obj") then {
                    [_obj, "fobID", _id] call ALiVE_fnc_HashSet;
                    _result = _result + 1;
                };
            };
            _pairs pushBack [_opcomID, _oid];
        } forEach _want;

        // remove what shouldn't be there any more (a FOB that changed hands, targeting switched off)
        {
            _x params ["_opcomID", "_oid"];
            if !(_x in _pairs) then {
                private _opcom = _opcomID call _opcomByID;
                if (!isNil "_opcom" && {!isNil {([_opcom, "objectivesByID", createHashMap] call ALiVE_fnc_HashGet) get _oid}}) then {
                    [_opcom, "removeObjective", _oid] call ALiVE_fnc_OPCOM;
                };
            };
        } forEach ([_entry, "objectiveIDs", []] call ALIVE_fnc_hashGet);

        if !(([_entry, "objectiveIDs", []] call ALIVE_fnc_hashGet) isEqualTo _pairs) then {
            [_entry, "objectiveIDs", _pairs] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
        };
        if (_debug && {_result > 0}) then {
            ["ALiVE Player FOBs - %1 (%2): %3 objectives added, %4 in all, found by %5", _id, _side, _result, count _pairs, _found] call ALiVE_fnc_dump;
        };
        if (_op == "register") then { _result = count _pairs };
    };

    case "unregister": {
        {
            _x params ["_opcomID", "_oid"];
            private _opcom = _opcomID call _opcomByID;
            if (!isNil "_opcom" && {!isNil {([_opcom, "objectivesByID", createHashMap] call ALiVE_fnc_HashGet) get _oid}}) then {
                [_opcom, "removeObjective", _oid] call ALiVE_fnc_OPCOM;
                _result = _result + 1;
            };
        } forEach ([_entry, "objectiveIDs", []] call ALIVE_fnc_hashGet);
        [_entry, "objectiveIDs", []] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
    };
};

_result
