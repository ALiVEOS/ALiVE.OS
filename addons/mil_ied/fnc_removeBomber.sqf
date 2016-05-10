#include <\x\alive\addons\mil_ied\script_component.hpp>
SCRIPT(removeBomber);

// Remove Suicide Bomber
private ["_suic","_location","_debug"];

_debug = MOD(mil_ied) getVariable ["debug", 0];

if !(isServer) exitWith {diag_log "RemoveBomber Not running on server!";};

_location = _this select 0;


// Ambient bomber is deleted automatically when time runs out or dies

