#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(isModuleAvailable);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isModuleAvailable
Description:
Returns true if all target modules (array) are available

Parameters:
Nil

Returns:
Bool

Examples:
(begin example)
["ALiVE_sys_profile","ALiVE_mil_placement"] call ALIVE_fnc_isModuleAvailable;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_targets","_result"];

_targets = _this;
_result = false;

for "_i" from 0 to ((count _targets)-1) do {
	private ["_mod"];
    if (count _targets == 0) exitwith {};
    
    _mod = _targets select 0;
    
    if !(isnil "_mod") then {
	    if ((({(typeof _x) == _mod} count (entities "Module_F") > 0))) then {
			_targets = _targets - [_mod];
	    };
    };
};

if ({!(isnil "_x")} count _targets > 0) then {false} else {true};