#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(reportDefaultFaction);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_reportDefaultFaction

Description:
Writes one RPT line when a module is left on the vanilla faction it starts with in a
mission whose commanders and placements use mod factions. It waits 90 seconds for those
modules to start, and says nothing when the mission really does use that faction, or
uses no mod faction at all.

Parameters:
Array - [module name, default faction, reason]

Returns:
Nothing

Examples:
(begin example)
["Military Air Component Commander", "OPF_F", "its Faction setting was not changed"] call ALiVE_fnc_reportDefaultFaction;
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

params [["_module", "", [""]], ["_default", "", [""]], ["_reason", "", [""]]];

if (!isServer || {_default == ""}) exitWith {};

if (isNil "ALiVE_defaultFactionsReported") then { ALiVE_defaultFactionsReported = createHashMap };

private _key = toLower (_module + "|" + _default);
if (_key in ALiVE_defaultFactionsReported) exitWith {};
ALiVE_defaultFactionsReported set [_key, false];

[_module, _default, _reason, _key] spawn {
    params ["_module", "_default", "_reason", "_key"];

    waitUntil { sleep 5; time > 90 };

    private _used = [] call ALiVE_fnc_listMissionFactions;
    if (((_used apply { toLower _x }) find (toLower _default)) != -1) exitWith {};
    if ((_used findIf { !([_x] call ALiVE_fnc_factionIsVanilla) }) == -1) exitWith {};

    ALiVE_defaultFactionsReported set [_key, [_module, _default, _reason]];
    ["ALiVE vanilla fallback: %1 is using its default faction %2, because %3", _module, _default, _reason] call ALiVE_fnc_dump;
};
