#include <\x\alive\addons\sys_adminactions\script_component.hpp>
SCRIPT(adminGhost);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_adminGhost

Description:
Turn on / off admin ghost mode

Examples:
(begin example)
// get vehicle type 
_result = [] call ALIVE_fnc_adminGhost;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_player","_enabled"];

_player = _this select 0;
_enabled = _this select 1;

if(isServer) then {
    _player hideObjectGlobal _enabled;
}else{
    [_this,"ALIVE_fnc_adminGhost",false,false] spawn BIS_fnc_MP;
};