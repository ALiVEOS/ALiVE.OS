#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(isModuleInisitalised);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_isModuleInitialised
Description:
mini registry, checks for startupComplete var of modules defined

Parameters:
ARRAY, type of module like ALiVE_sys_profile

Returns:
Bool - if all given modules are initialised, will return true if module is not available (failsafe)

Examples:
(begin example)
["ALiVE_sys_profile","ALiVE_mil_placement"] call ALiVE_fnc_isModuleInitialised;
(end)

See Also:
- nil

Author:
ARJay, Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_waitModules","_initialising","_startupComplete"];

_waitModules = _this;
_initialising = false;

waitUntil {
    _initialising = true;
    {
        if (typeof _x in _waitModules) then {
            _startupComplete = _x getVariable ["startupComplete",false];
            
            if !(_startupComplete) then {
                _initialising = false;
            };
        };
    } foreach (entities "Module_F");
	_initialising
};

_initialising;