#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(bomberHuntForTarget);

params ["_args","_handle"];

_args params ["_victim","_bomber","_pos","_blowUpFunc"];

if (!isNil "_victim" && {time - _timer > 15}) then {
    [_bomber, getposATL _victim] call ALiVE_fnc_doMoveRemote;

    // todo: create this perframehandler only when debug is enabled/disabled
    if (ADDON getVariable ["debug",false]) then {
        private _marker = _bomber getVariable ["marker", nil];
        if (isNil "_marker" || {!(_marker in allMapMarkers)}) then {
            private ["_markers"];
            _marker = [format ["suic_%1", random 1000], position _bomber , "Icon", [1,1], "TEXT:", "Suicide", "TYPE:", "mil_dot", "COLOR:", "ColorRed", "GLOBAL"] call CBA_fnc_createMarker;
            _bomber setVariable ["marker", _marker];
        } else {
            _marker setmarkerpos position _bomber;
        };
    } else {
        private _marker = _bomber getVariable ["marker", ""];
        deletemarker _marker;
    };
    _timer = time;
};

if (isnil "_victim" || { !(alive _victim) }) exitWith {
    deletevehicle _bomber;
    [_handle] call CBA_fnc_removePerFrameHandler;
};

private _endConditionReached = (_bomber distance _victim < 8) || (time > _time) || !(alive _bomber);
if (_endConditionReached) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    [ALiVE_fnc_bomberDetonate, [_victim,_bomber, _pos]] call CBA_fnc_execNextFrame;
};