#include <\x\alive\addons\main\script_component.hpp>
SCRIPT(isModuleSynced);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isModuleSynced
Description:
Returns true if all target objects (array, _this select 1) are synced to source object (_this select 0)

Parameters:
Nil

Returns:
Bool

Examples:
(begin example)
[_logic,["ALiVE_sys_profile","ALiVE_mil_placement"] call ALiVE_fnc_isModuleSynced;
(end)

See Also:
- nil

Author:
Highhead

Peer reviewed:
nil
---------------------------------------------------------------------------- */
private ["_source","_target","_result"];

_source = _this select 0;
_target = _this select 1;

_result = false;

for "_i" from 0 to ((count synchronizedObjects _source)-1) do {
	private ["_obj","_mod"];
    
    _mod = (synchronizedObjects _source) select _i;
    
    if ((typeof _mod) in _target) then {
		_target = _target - [(typeof _mod)];
    };
};

if (count _target > 0) then {false} else {true};