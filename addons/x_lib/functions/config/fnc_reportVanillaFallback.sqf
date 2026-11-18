#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(reportVanillaFallback);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_reportVanillaFallback

Description:
Writes one RPT line the first time a module uses the game's default list for a mod
faction that has no list of its own. Each module, faction and list is reported once
on each machine. A vanilla faction using its own side's list is not reported. This
only reports: it changes nothing about what the module does.

Parameters:
Array - [module name, faction, what is missing, side]

Returns:
Nothing

Examples:
(begin example)
["Military Logistics", "UK3CB_MEE_O", "air transport", "EAST"] call ALiVE_fnc_reportVanillaFallback;
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

params [["_module", "", [""]], ["_faction", "", [""]], ["_list", "", [""]], ["_side", ""]];

if (_faction == "") exitWith {};

if (isNil "ALiVE_vanillaFallbacksReported") then { ALiVE_vanillaFallbacksReported = createHashMap };

private _key = toLower (_module + "|" + _faction + "|" + _list);
if (_key in ALiVE_vanillaFallbacksReported) exitWith {};
ALiVE_vanillaFallbacksReported set [_key, true];

if ([_faction] call ALiVE_fnc_factionIsVanilla) exitWith {};

["ALiVE vanilla fallback: %1, %2 has no %3, using %4 defaults", _module, _faction, _list, _side] call ALiVE_fnc_dump;
