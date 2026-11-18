#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(listVanillaFallbacks);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_listVanillaFallbacks

Description:
Debug console command. Lists every list a mod faction is missing, so the modules that
read it would use the game's default classes. Covers the factions in the running mission,
or the one faction passed in. It spawns nothing and changes nothing. The result is
written to the RPT and returned.

Parameters:
String - optional faction class name

Returns:
Array - one [faction, list, side defaults used, modules that read it] for each gap

Examples:
(begin example)
[] call ALiVE_fnc_listVanillaFallbacks;
["UK3CB_MEE_O"] call ALiVE_fnc_listVanillaFallbacks;
(end)

See Also:
- ALiVE_fnc_reportVanillaFallback
- ALiVE_fnc_listVanillaFallbacks

Author:
Jman
---------------------------------------------------------------------------- */

params [["_only", "", [""]]];

private _factions = if (_only != "") then { [_only] } else { [] call ALiVE_fnc_listMissionFactions };

private _lists = [
    ["ground transport", "ALIVE_factionDefaultTransport", "Military Logistics"],
    ["air transport", "ALIVE_factionDefaultAirTransport", "Military Logistics, AI Commander, Player Resupply"],
    ["containers", "ALIVE_factionDefaultContainers", "Military Logistics, Combat Support"],
    ["supplies", "ALIVE_factionDefaultSupplies", "Military Placement, Military Placement (Custom)"],
    ["supports", "ALIVE_factionDefaultSupports", "Military Placement, Military Placement (Custom), Civilian Placement"],
    ["resupply vehicle options", "ALIVE_factionDefaultResupplyVehicleOptions", "Player Resupply"],
    ["resupply group options", "ALIVE_factionDefaultResupplyGroupOptions", "Player Resupply"]
];

private _gaps = [];

{
    private _faction = _x;
    private _config = configFile >> "CfgFactionClasses" >> _faction;

    if (isClass _config && {!([_faction] call ALiVE_fnc_factionIsVanilla)}) then {
        private _listed = [_faction] call ALiVE_fnc_factionCompilerGetConfigFaction;
        private _side = (getNumber (_config >> "side")) call ALIVE_fnc_sideNumberToText;

        {
            _x params ["_label", "_registry", "_modules"];
            private _hash = missionNamespace getVariable [_registry, []];
            private _classes = if (_hash isEqualTo []) then { [] } else { [_hash, _listed, []] call ALIVE_fnc_hashGet };

            if (_classes isEqualTo [] && {!(_label == "ground transport" && {([_faction] call ALiVE_fnc_factionOwnTroopTrucks) isNotEqualTo []})}) then {
                _gaps pushBack [_faction, _label, _side, _modules];
            };
        } forEach _lists;
    };
} forEach _factions;

private _defaults = [];
if (!isNil "ALiVE_defaultFactionsReported") then {
    {
        private _entry = ALiVE_defaultFactionsReported get _x;
        if (_entry isEqualType []) then { _defaults pushBack _entry };
    } forEach (keys ALiVE_defaultFactionsReported);
};

["ALiVE vanilla fallback check: %1 factions, %2 gaps, %3 modules on a default faction", count _factions, count _gaps, count _defaults] call ALiVE_fnc_dump;
{
    _x params ["_faction", "_label", "_side", "_modules"];
    ["ALiVE vanilla fallback check: %1 has no %2, so %3 use %4 defaults", _faction, _label, _modules, _side] call ALiVE_fnc_dump;
} forEach _gaps;
{
    _x params ["_module", "_default", "_reason"];
    ["ALiVE vanilla fallback check: %1 is using its default faction %2, because %3", _module, _default, _reason] call ALiVE_fnc_dump;
    _gaps pushBack ["", "default faction", _default, _module];
} forEach _defaults;

_gaps
