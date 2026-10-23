#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskKnownEnemy);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskKnownEnemy

Description:
Tasks Only Against Known Enemy on the C2ISTAR module (A. Ares on Discord, 23 Oct): a task against enemy kit or an
installation is only aimed at what the task's side knows of. What a side knows is what its AI Commanders know
(ALiVE_fnc_OPCOM "knownEnemy": what their units have seen in the last 30 minutes, spot reports, recon task reports,
prisoners' and civilians' answers). With the setting off, or no AI Commander on the side, everything passes, as before.
Server side.

Parameters:
    STRING - "vehicles", "groups", "place", "places" or "report"
    STRING - the task's side ("WEST", "EAST", "GUER")
    ARRAY  - "vehicles": vehicle profile IDs; "groups": entity profile IDs; "place": a position;
             "places": several positions;
             "report": the positions a player passed on

Returns:
    "vehicles" / "groups": the IDs that are known (all of them when the rule doesn't apply)
    "place": true when the place is known (or the rule doesn't apply)
    "places": true or false for each position, in order

Author:
Jman
---------------------------------------------------------------------------- */

params [["_what", "", [""]], ["_side", "", [""]], ["_arg", []]];

// the side's AI Commanders (RESISTANCE and GUER are one side)
private _norm = { if (_this in ["RESISTANCE", "INDEPENDENT"]) then { "GUER" } else { _this } };
private _mySide = _side call _norm;
private _sideHandlers = {
    (missionNamespace getVariable ["OPCOM_instances", []]) select {
        (([_x, "side", ""] call ALiVE_fnc_HashGet) call _norm) == _mySide
    }
};

// "report": what a player of this side passed on (a spot report, a prisoner's or a civilian's answer), as positions.
// The enemy groups within 150 m of each become known to the side's AI Commanders (ALiVE_fnc_OPCOM "reportSeen"),
// for this setting and for their own Tasks Only Against Known Enemy. Called from any machine
if (_what == "report") exitWith {
    if (!isServer) exitWith { ["report", _side, _arg] remoteExecCall ["ALIVE_fnc_taskKnownEnemy", 2] };
    if (isNil "ALiVE_profileSystem") exitWith {};
    {
        private _h = _x;
        private _ids = [];
        private _poss = [];
        {
            private _at = _x;
            if (_at isEqualType [] && {count _at > 1}) then {
                {
                    {
                        private _id = [_x, "profileID", ""] call ALiVE_fnc_HashGet;
                        if (_id != "" && {!(_id in _ids)}) then {
                            _ids pushBack _id;
                            _poss pushBack ([_x, "position", _at] call ALiVE_fnc_HashGet);
                        };
                    } forEach ([_at, 150, [_x, "entity"]] call ALIVE_fnc_getNearProfiles);
                } forEach ([_h, "sidesenemy", []] call ALiVE_fnc_HashGet);
            };
        } forEach _arg;
        private _places = _arg select { _x isEqualType [] && {count _x > 1} };
        [_h, "reportSeen", [_ids, _poss, _places]] call ALiVE_fnc_OPCOM;
        ["C2ISTAR - known enemy: %1 told of %2 place(s) and %3 group(s) near %4", _mySide, count _places, count _ids, _places apply { mapGridPosition _x }] call ALiVE_fnc_Dump;
    } forEach (call _sideHandlers);
};

private _pass = switch (_what) do { case "place": { true }; case "places": { _arg apply { true } }; default { _arg } };
if !(missionNamespace getVariable ["ALiVE_c2istar_tasksKnownOnly", false]) exitWith { _pass };

private _handlers = call _sideHandlers;
if (_handlers isEqualTo []) exitWith { _pass };

// what they know between them: [entity profile IDs, their positions]
private _ids = [];
private _pos = [];
{
    ([_x, "knownEnemy"] call ALiVE_fnc_OPCOM) params [["_i", []], ["_p", []]];
    { if !(_x in _ids) then { _ids pushBack _x; _pos pushBack (_p param [_forEachIndex, [0, 0, 0]]) } } forEach _i;
} forEach _handlers;
private _known = [_ids, _pos];
private _h = _handlers select 0;

private _out = switch (_what) do {
    case "vehicles": {
        _arg select {
            private _vp = [ALiVE_ProfileHandler, "getProfile", _x] call ALIVE_fnc_ProfileHandler;
            !isNil "_vp" && {[_h, "knownVehicle", [_vp, _known]] call ALiVE_fnc_OPCOM}
        }
    };
    case "groups": { _arg select { _x in _ids } };
    case "place": {
        _arg isEqualType [] && {count _arg > 1} && {[_h, "knownPlace", [_arg, _known]] call ALiVE_fnc_OPCOM}
    };
    case "places": {
        _arg apply { _x isEqualType [] && {count _x > 1} && {[_h, "knownPlace", [_x, _known]] call ALiVE_fnc_OPCOM} }
    };
    default { _pass };
};
// something was turned down for not being known: the task handler tells a player who asked for the task
if (_out isEqualTo false || {_what == "places" && {false in _out}} || {_what in ["vehicles", "groups"] && {count _out < count _arg}}) then {
    ALiVE_c2istar_knownFiltered = true
};
_out
