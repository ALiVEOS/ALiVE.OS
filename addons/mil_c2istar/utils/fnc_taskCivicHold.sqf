#include "\x\alive\addons\mil_c2istar\script_component.hpp"
SCRIPT(taskCivicHold);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_taskCivicHold

Description:
The hold that ends a Hearts and Minds task once its action is done (#1082): opening the clinic, the
meeting with the local leader, the repair, the aid handed over. The players have to stay and hold the
area for Civic Hold Time (C2ISTAR, ALIVE_civicHoldDuration) before the task succeeds, which gives an
enemy commander time to answer it. The countdown stops while enemies are within 150 m, and the task
fails when no player of the side has been within 200 m for 30 seconds. Players hear the time left
every 30 seconds. 0 seconds keeps the old behaviour: the task succeeds as soon as the action is done.

Call it from the task's stage once its completion flag is set; it keeps its state in the task's
params hash ("holdLeft", "holdAway", "holdNext"). On a failure it sets "holdFailed", which the task's
failure check reads.

Parameters:
    _this select 0: HASH  - the task's params
    _this select 1: ARRAY - the task's position
    _this select 2: STRING - the task's side

Returns:
    BOOL - true once the hold is done

Author:
Jman
---------------------------------------------------------------------------- */

params ["_params", "_pos", "_side"];

private _duration = missionNamespace getVariable ["ALIVE_civicHoldDuration", 120];
if (_duration <= 0) exitWith { true };

private _now = serverTime;
private _left = [_params, "holdLeft", -1] call ALIVE_fnc_hashGet;
private _last = [_params, "holdLast", _now] call ALIVE_fnc_hashGet;
private _sideObj = [_side] call ALIVE_fnc_sideTextToObject;
private _say = { params ["_text", ["_noLog", false]]; ["COIN Update", _text, _noLog] remoteExec ["ALIVE_fnc_taskSubtitle", _sideObj] };

if (_left < 0) exitWith {
    [_params, "holdLeft", _duration] call ALIVE_fnc_hashSet;
    [_params, "holdLast", _now] call ALIVE_fnc_hashSet;
    [_params, "holdAway", 0] call ALIVE_fnc_hashSet;
    [_params, "holdNext", _now + 30] call ALIVE_fnc_hashSet;
    [format ["Hold the area for %1 minutes while it gets under way.", ceil (_duration / 60)]] call _say;
    false
};

private _step = (_now - _last) max 0;
[_params, "holdLast", _now] call ALIVE_fnc_hashSet;

// players of the side near: none for 30 seconds and the task is lost
private _near = (allPlayers select { alive _x && {side group _x == _sideObj} && {(_x distance2D _pos) < 200} }) isNotEqualTo [];
private _away = if (_near) then { 0 } else { ([_params, "holdAway", 0] call ALIVE_fnc_hashGet) + _step };
[_params, "holdAway", _away] call ALIVE_fnc_hashSet;
if (_away >= 30) exitWith {
    [_params, "holdFailed", true] call ALIVE_fnc_hashSet;
    ["The area was left before it was done."] call _say;
    false
};

// enemies close stop the clock until they are dealt with
private _contested = [_pos, _side, 150, true] call ALIVE_fnc_isEnemyNear;
if (!_contested && {_near}) then { _left = _left - _step };
[_params, "holdLeft", _left max 0] call ALIVE_fnc_hashSet;

if (_now >= ([_params, "holdNext", 0] call ALIVE_fnc_hashGet) && {_left > 0}) then {
    [_params, "holdNext", _now + 30] call ALIVE_fnc_hashSet;
    [if (_contested) then { "Enemies close by: clear them to carry on." } else { format ["Hold position: %1:%2 left.", floor (_left / 60), [floor (_left mod 60), 2] call CBA_fnc_formatNumber] }, true] call _say;
};

_left <= 0
