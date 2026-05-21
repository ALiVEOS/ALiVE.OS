#include "\x\alive\addons\mil_ied\script_component.hpp"
SCRIPT(removeBomber);

// Remove Suicide Bomber
private ["_suic","_location","_debug"];

_debug = MOD(mil_ied) getVariable ["debug", false];

if !(isServer) exitWith {["RemoveBomber Not running on server!"] call ALiVE_fnc_dump;};

_location = _this select 0;


// Ambient bomber is deleted automatically when time runs out or dies

