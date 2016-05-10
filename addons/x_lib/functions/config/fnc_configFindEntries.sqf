#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configFindEntries);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_configFindEntries

Description:
Finds all config entries by given part of name

Parameters:
Config - Config path
String - String to find

Returns:
Array

Examples:
(begin example)
// get objectTypes containing the String "AA_"
AA_types = [configFile >> "cfgVehicles","AA_"] call ALiVE_fnc_configFindEntries;
(end)

See Also:

Author:
Highhead
---------------------------------------------------------------------------- */

private ["_config","_find","_output"];

_config = _this select 0;
_find = _this select 1;

_output = [];

for "_i" from 0 to (count _config)-1 do {

	 private ["_cfg","_default"];
        
    _cfg = _config select _i;

	if (isClass _cfg) then {
        _default = configName _cfg;
        
        if (((_default) find _find) > -1) then {
        	_output pushback _default;
    	};
    };
};

_output;
