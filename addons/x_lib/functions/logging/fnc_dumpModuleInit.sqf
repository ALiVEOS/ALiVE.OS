#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(dumpModuleInit);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_dumpModuleInit

Description:
Dumps logo to RPT

Parameters:
Mixed

Returns:

Examples:
(begin example)
// dump variable
[_logic] call ALIVE_fnc_dumpModuleInit;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_logic","_start","_moduleID","_message"];

_logic = _this select 0;
_start = if(count _this > 1) then {_this select 1} else {false};
_moduleID = if(count _this > 2) then {_this select 2} else {""};

if(isNil "ALIVE_firstModuleInit") then {

    ALiVE_SYS_DATA_DEBUG_ON = false;
    ALiVE_SYS_PROFILE_DEBUG_ON = false;
    
    ALIVE_firstModuleInit = true;
    ALIVE_moduleCount = 0;
    // Cleared alongside the module counter so a mission restarted without closing the
    // game starts fresh lists rather than inheriting the last run's.
    ALiVE_initRunning = [];
    ALiVE_initActivity = [];
    ALiVE_initWarnings = [];
    [] call ALIVE_fnc_dumpLogo;
    ["Global INIT"] call ALiVE_fnc_dump;
    [true,"Global Init Timer Started","INIT"] call ALIVE_fnc_timer;
};

// Tell every machine which module is working, so the startup screen can say what is
// happening instead of showing nothing. This is the one place every module passes
// through, at its start and again at its finish, so a single hook here covers all of
// them and no module needs to know the screen exists.
//
// The name shown is the module's own name from the editor, so it reads as something a
// player recognises rather than a class name. Only the server tracks this, because the
// wait everyone sits through is the server's work.
if (isServer) then {
    private _name = getText (configFile >> "CfgVehicles" >> typeOf _logic >> "displayName");
    if ((_name find "$") == 0) then { _name = localize (_name select [1]) };
    if (_name == "") then { _name = typeOf _logic };

    if (isNil "ALiVE_initRunning") then { ALiVE_initRunning = [] };

    // Several modules of the same kind can be placed, and they finish at different
    // times, so each one is counted separately. Otherwise the first to finish would
    // take the name off the screen while its twin was still working. The screen shows
    // each name once regardless of how many are behind it.
    // Kept as the module type alongside its readable name. Whoever shows this decides
    // which modules are worth naming, and needs the type to tell them apart; keeping both
    // means this end does not have to know or care what that decision is.
    private _type = typeOf _logic;

    if (_start) then {
        ALiVE_initRunning pushBack [_type, _name];
    } else {
        private _at = ALiVE_initRunning findIf {(_x select 0) == _type};
        if (_at >= 0) then { ALiVE_initRunning deleteAt _at };
    };

    publicVariable "ALiVE_initRunning";

    // A running commentary of modules starting and finishing, for the startup screen to show
    // underneath the rest. Module init is the right thing to report there because it is what
    // the wait is actually made of.
    //
    // This was first taken from the general log channel instead, which was wrong: that
    // channel carries anything a module cares to say, so with OPCOM debug switched on the
    // screen filled with target reservations that say nothing about loading, and buried what
    // did. Here, nothing can appear that is not a module starting or finishing.
    if (isNil "ALiVE_initActivity") then { ALiVE_initActivity = [] };

    ALiVE_initActivity pushBack (
        if (_start) then { format ["%1 starting", _name] } else { format ["%1 finished", _name] }
    );
    while {count ALiVE_initActivity > 3} do { ALiVE_initActivity deleteAt 0 };

    publicVariable "ALiVE_initActivity";
};

if(_start) then {
    _moduleID = format["m_%1", ALIVE_moduleCount];
    _message = format["[%3|%1] Module %2 INIT",(getNumber(configfile >> "CfgVehicles" >>  typeOf _logic >> "functionPriority")), typeof _logic, _moduleID];
    [true, _message, _moduleID] call ALIVE_fnc_timer;
    ALIVE_moduleCount = ALIVE_moduleCount + 1;
}else{
    _message = format["[%3|%1] Module %2 INIT COMPLETE TIME: ",(getNumber(configfile >> "CfgVehicles" >>  typeOf _logic >> "functionPriority")), typeof _logic, _moduleID];
    [false, _message, _moduleID] call ALIVE_fnc_timer;
};

_moduleID
