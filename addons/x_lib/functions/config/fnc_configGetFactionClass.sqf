#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(configGetFactionClass);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_configGetFactionClass

Description:
Returns config path of given faction
searches missionConfigFile before configFile

Parameters:
String - faction

Returns:
Config Path - path to faction config

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_configGetFactionClass;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private _value = if (typeName _this == "ARRAY") then {
	["INCORRECT TYPE PASSED TO configGetFactionClass: %1", _this] call ALiVE_fnc_dump;
	(_this select 0)
} else { _this };

private _path = missionConfigFile >> "CfgFactionClasses" >> _value;

if !(isClass _path) then { _path = configFile >> "CfgFactionClasses" >> _value };

if !(isClass _path) then {
	// Check to see if faction has a mapping within groups
	if (!isnil "ALiVE_factionCustomMappings") then {
		{
	       private _factionData = [ALiVE_factionCustomMappings, _x] call ALiVE_fnc_hashGet;
		   private _factionSide = [_factionData,"GroupSideName"] call ALiVE_fnc_hashGet;
		   private _faction = [_factionData,"GroupFactionName"] call ALiVE_fnc_hashGet;

		   if (_value == _faction) then {
		   		_path = missionConfigFile >> "CfgFactionClasses" >> _x;
				if !(isClass _path) then {_path = configFile >> "CfgFactionClasses" >> _x};
		   };
			false
		} count (ALiVE_factionCustomMappings select 1);
	};
};

_path