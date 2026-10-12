#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobObjectives);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobObjectives

Description:
A FOB as an objective for its own side's AI Commanders, so they send men to hold it. One
objective per commander of that side, at the front of its list, sized to the build range and
marked with the FOB's id ("fobID"). The commander never saves it (the FOB is saved here
instead and adds it again on load), and an insurgent commander with nobody free borrows a
section for it as it does for a player's objective.

A side with no commander still has its FOBs; they just have no objective.

reconcile works out the objectives a FOB should have and adds what is missing, so a commander
that reloaded its objectives, or a step cut short, is put right on the next watchdog pass.

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

switch (_op) do {

    case "register";
    case "reconcile": {
        private _side = [_entry, "side", ""] call ALIVE_fnc_hashGet;
        private _pos = [_entry, "pos", [0,0,0]] call ALIVE_fnc_hashGet;
        private _size = [_logic, "attribute", ["fob_build_range"]] call ALiVE_fnc_FOB;
        private _pairs = [];
        {
            if (([_x, "side", ""] call ALiVE_fnc_HashGet) == _side) then {
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
            };
        } forEach (missionNamespace getVariable ["OPCOM_instances", []]);

        if !(([_entry, "objectiveIDs", []] call ALIVE_fnc_hashGet) isEqualTo _pairs) then {
            [_entry, "objectiveIDs", _pairs] call ALIVE_fnc_hashSet;
            ALiVE_FOB_dirty = true;
        };
        if (_debug && {_result > 0}) then {
            ["ALiVE Player FOBs - %1 (%2): %3 objectives added, %4 in all", _id, _side, _result, count _pairs] call ALiVE_fnc_dump;
        };
        if (_op == "register") then { _result = count _pairs };
    };

    case "unregister": {
        {
            _x params ["_opcomID", "_oid"];
            private _i = (missionNamespace getVariable ["OPCOM_instances", []]) findIf { ([_x, "opcomID", ""] call ALiVE_fnc_HashGet) == _opcomID };
            if (_i > -1) then {
                private _opcom = OPCOM_instances select _i;
                if !(isNil {([_opcom, "objectivesByID", createHashMap] call ALiVE_fnc_HashGet) get _oid}) then {
                    [_opcom, "removeObjective", _oid] call ALiVE_fnc_OPCOM;
                    _result = _result + 1;
                };
            };
        } forEach ([_entry, "objectiveIDs", []] call ALIVE_fnc_hashGet);
        [_entry, "objectiveIDs", []] call ALIVE_fnc_hashSet;
        ALiVE_FOB_dirty = true;
    };
};

_result
