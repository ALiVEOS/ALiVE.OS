#include "\x\alive\addons\sup_fob\script_component.hpp"
SCRIPT(fobTimer);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_fobTimer

Description:
The FOB module's Deploy Time and Dismantle Time, on the player's machine. When either is set the
server answers a deploy or dismantle with "start" here, after its own checks have passed: the
player kneels to work and stays put while a bar like the FOB window's counts the time down. Once it
is full the same request goes back to the server marked as finished, which acts on it only when the
time has really passed (ALiVE_fnc_fobOps, deploy and dismantle). Stop The Timer If decides what stops it early:
moving, or moving and coming under fire. Being killed or knocked down, getting into or out of a
vehicle, and Esc always stop it. With Never the player is kept where he started.

Parameters:
String - "start" (from the server), "tick" (each frame), or "stop"
Array - start: [kind ("deploy" or "dismantle"), the request's arguments, seconds, "NEVER", "MOVE" or "FIRE"]
        stop: [why: "" when the time is up, else "MOVED", "FIRE" or "CANCEL"]

Returns:
Nothing

Author:
Jman
---------------------------------------------------------------------------- */

params [["_op", "", [""]], ["_args", [], [[]]]];
if (!hasInterface) exitWith {};

switch (_op) do {
    case "start": {
        // only the server starts one, and one at a time
        if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {};
        if (!isNil "ALiVE_FOB_timer") exitWith {};
        _args params [["_kind", "", [""]], ["_request", [], [[]]], ["_wait", 0, [0]], ["_cancel", "MOVE", [""]]];
        if (_wait <= 0 || {!alive player} || {!(_kind in ["deploy", "dismantle"])}) exitWith {};
        _cancel = toUpper _cancel;
        if !(_cancel in ["NEVER", "MOVE", "FIRE"]) then { _cancel = "MOVE" };

        private _d = findDisplay 46;
        private _x0 = 0.37 * safezoneW + safezoneX;
        private _y0 = 0.74 * safezoneH + safezoneY;
        private _w = 0.26 * safezoneW;
        private _ctrls = [];
        private _back = _d ctrlCreate ["FobUI_RscText", -1];
        _back ctrlSetPosition [_x0, _y0, _w, 0.075 * safezoneH];
        _back ctrlSetBackgroundColor [0, 0, 0, 0.65];
        private _head = _d ctrlCreate ["FobUI_RscText", -1];
        _head ctrlSetPosition [_x0, _y0 - 0.028 * safezoneH, _w, 0.028 * safezoneH];
        _head ctrlSetBackgroundColor [0.788, 0.443, 0.157, 0.65];
        _head ctrlSetText localize (["STR_ALIVE_FOB_TIMER_DISMANTLE", "STR_ALIVE_FOB_TIMER_DEPLOY"] select (_kind == "deploy"));
        private _track = _d ctrlCreate ["FobUI_RscText", -1];
        _track ctrlSetPosition [_x0 + 0.01 * safezoneW, _y0 + 0.012 * safezoneH, _w - 0.02 * safezoneW, 0.016 * safezoneH];
        _track ctrlSetBackgroundColor [1, 1, 1, 0.15];
        private _fill = _d ctrlCreate ["FobUI_RscText", -1];
        _fill ctrlSetPosition [_x0 + 0.01 * safezoneW, _y0 + 0.012 * safezoneH, 0, 0.016 * safezoneH];
        _fill ctrlSetBackgroundColor [0.788, 0.443, 0.157, 0.9];
        private _text = _d ctrlCreate ["FobUI_RscStructuredText", -1];
        _text ctrlSetPosition [_x0 + 0.01 * safezoneW, _y0 + 0.034 * safezoneH, _w - 0.02 * safezoneW, 0.035 * safezoneH];
        _text ctrlSetBackgroundColor [0, 0, 0, 0];
        { _x ctrlCommit 0; _ctrls pushBack _x } forEach [_back, _head, _track, _fill, _text];

        // come under fire: hit, or a hostile's rounds landing close
        private _ehs = [];
        if (_cancel == "FIRE") then {
            _ehs pushBack ["Hit", player addEventHandler ["Hit", { ALiVE_FOB_timer set [9, true] }]];
            _ehs pushBack ["Suppressed", player addEventHandler ["Suppressed", {
                params ["_unit", "", "_shooter"];
                if (!isNull _shooter && {((side group _shooter) getFriend (side group _unit)) < 0.6}) then { ALiVE_FOB_timer set [9, true] };
            }]];
        };
        private _key = _d displayAddEventHandler ["KeyDown", {
            params ["", "_dik"];
            if (_dik == 1 && {!isNil "ALiVE_FOB_timer"}) exitWith { ["stop", ["CANCEL"]] call ALiVE_fnc_fobTimer; true };
            false
        }];
        private _frame = addMissionEventHandler ["EachFrame", { ["tick"] call ALiVE_fnc_fobTimer }];

        //                 0      1         2     3      4        5               6               7       8     9      10    11     12
        ALiVE_FOB_timer = [_kind, _request, time, _wait, _cancel, getPosASL player, vehicle player, _ctrls, _ehs, false, _key, _frame, -10];
    };

    case "tick": {
        if (isNil "ALiVE_FOB_timer") exitWith {};
        ALiVE_FOB_timer params ["_kind", "_request", "_t0", "_wait", "_cancel", "_at", "_veh", "_ctrls", "", "_fired", "", "", "_animAt"];
        private _done = time - _t0;
        if (!alive player || {lifeState player == "INCAPACITATED"} || {vehicle player != _veh}) exitWith { ["stop", ["CANCEL"]] call ALiVE_fnc_fobTimer };
        if (_fired) exitWith { ["stop", ["FIRE"]] call ALiVE_fnc_fobTimer };
        private _moved = (getPosASL player) distance2D _at;
        if (_cancel == "NEVER") then {
            // kept where he started
            if (_moved > 0.6 && {vehicle player == player}) then { player setPosASL _at; player setVelocity [0, 0, 0] };
        } else {
            if (_moved > 1.5) exitWith { ["stop", ["MOVED"]] call ALiVE_fnc_fobTimer };
        };
        if (isNil "ALiVE_FOB_timer") exitWith {};
        if (_done >= _wait) exitWith { ["stop", [""]] call ALiVE_fnc_fobTimer };

        // at work, kneeling, on foot
        if (vehicle player == player && {time - _animAt > 1} && {!("medic" in toLower animationState player)}) then {
            player playActionNow "Medic";
            ALiVE_FOB_timer set [12, time];
        };

        _ctrls params ["", "", "_track", "_fill", "_text"];
        private _p = ctrlPosition _track;
        _fill ctrlSetPosition [_p select 0, _p select 1, (_p select 2) * ((_done / _wait) min 1), _p select 3];
        _fill ctrlCommit 0;
        _text ctrlSetStructuredText parseText format ["<t align='left' size='0.9'>%1</t><t align='right' size='0.8' color='#B0B0B0'>%2</t>",
            format [localize "STR_ALIVE_FOB_TIMER_LEFT", ceil (_wait - _done)], localize "STR_ALIVE_FOB_TIMER_ESC"];
    };

    case "stop": {
        if (isNil "ALiVE_FOB_timer") exitWith {};
        _args params [["_why", "CANCEL", [""]]];
        ALiVE_FOB_timer params ["_kind", "_request", "", "", "", "", "", "_ctrls", "_ehs", "", "_key", "_frame"];
        ALiVE_FOB_timer = nil;
        { ctrlDelete _x } forEach _ctrls;
        { player removeEventHandler _x } forEach _ehs;
        (findDisplay 46) displayRemoveEventHandler ["KeyDown", _key];
        removeMissionEventHandler ["EachFrame", _frame];
        if (_why == "") exitWith {
            [_kind, _request + [true]] remoteExecCall ["ALiVE_fnc_fobRequest", 2];
        };
        [localize "STR_ALIVE_FOB", localize (switch (_why) do {
            case "MOVED": { "STR_ALIVE_FOB_TIMER_MOVED" };
            case "FIRE": { "STR_ALIVE_FOB_TIMER_FIRE" };
            default { "STR_ALIVE_FOB_TIMER_STOPPED" };
        }), true] call ALIVE_fnc_sendHint;
    };
};
