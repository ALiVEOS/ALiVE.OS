// Detect - ran on client only
#include "\x\alive\addons\mil_IED\script_component.hpp"
SCRIPT(detectIED);
private ["_IED", "_radius","_players","_detection","_device"];

_IED = _this select 0;
_radius = _this select 1;
_players = _this select 2;
_detection = _this select 3;
_device = _this select 4;

if (_detection == 0) exitWith {};

if (_detection == 1) exitWith {
    {
        if (_device in (items _x)) then {
            [localize "STR_ALIVE_ied", format["IED detected within %1 meters.", floor(_x distance _IED)]] remoteExec ["ALIVE_fnc_sendHint", _x];
        };

    } foreach _players;
};

if (_detection == 2) then {
    {
        if (_device in (items _x)) then {
            [_x, format["Alive_IED_Detection%1", ceil(random(4))]] call CBA_fnc_globalSay3D;
        };

    } foreach _players;
};


