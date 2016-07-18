#include <\x\alive\addons\x_lib\script_component.hpp>
SCRIPT(getFactionConfig);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_getFactionConfig

Description:
Returns config path of given faction
searches missionConfigFile before configFile

Parameters:
String - faction

Returns:
Config Path - path to faction config

Examples:
(begin example)
_side = "OPF_F" call ALiVE_fnc_getFactionConfig;
(end)

See Also:
- nil

Author:
SpyderBlack723

Peer reviewed:
nil
---------------------------------------------------------------------------- */

private "_path";

_path = missionConfigFile >> "CfgFactionClasses" >> _this;

if !(isClass _path) then {_path = configFile >> "CfgFactionClasses" >> _this};

_path