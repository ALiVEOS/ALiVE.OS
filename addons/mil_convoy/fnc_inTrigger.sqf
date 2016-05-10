#include <\x\alive\addons\mil_convoy\script_component.hpp>
private ["_posCheck","_quit","_exitcheck"];

_posCheck = _this select 0;
_quit = false;
_exitcheck = 0;

for "_i" from 0 to 10 do {
    if (_quit || _i > _exitcheck + 1) exitwith {};
	if !(isnil format ["BIS_ZORA_%1",_i]) then {
        _exitcheck = _i;
        _trigger = call compile format  ["BIS_ZORA_%1",_i];
        if ([_trigger, _posCheck] call BIS_fnc_inTrigger) exitwith {_quit = true};
    };
};
_quit;