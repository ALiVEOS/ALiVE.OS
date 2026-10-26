#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(groupArtilleryType);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_groupArtilleryType

Description:
The kind of artillery a CfgGroups group carries: the ALIVE_fnc_getArtilleryType
of its first artillery vehicle, or "" when it has none (an infantry mortar team)
or the group can't be resolved.

Parameters:
String - faction classname
String - group classname

Returns:
String - "MORTAR", "TOWED", "SP" or ""

Examples:
(begin example)
_type = ["rhs_faction_msv", "rhs_mortar_section"] call ALIVE_fnc_groupArtilleryType;
(end)

See Also:
ALIVE_fnc_getArtilleryType, ALIVE_fnc_groupIsRocketArtillery

Author:
Jman
---------------------------------------------------------------------------- */

params ["_faction","_groupName"];

if (isNil "ALIVE_groupArtilleryTypeCache") then { ALIVE_groupArtilleryTypeCache = [] call ALIVE_fnc_hashCreate };
private _key = format ["%1_%2", _faction, _groupName];
private _cached = [ALIVE_groupArtilleryTypeCache, _key] call ALIVE_fnc_hashGet;
if (!isNil "_cached") exitWith { _cached };

private _result = "";
// a custom-mapped faction draws its groups from the mapped group faction, as configGetRandomGroup does
private _groupFaction = _faction;
if (!isNil "ALIVE_factionCustomMappings" && {_faction in (ALIVE_factionCustomMappings select 1)}) then {
    private _mapped = [[ALIVE_factionCustomMappings, _faction] call ALIVE_fnc_hashGet, "GroupFactionName", _faction] call ALIVE_fnc_hashGet;
    if (_mapped isEqualType "" && {_mapped != ""}) then { _groupFaction = _mapped };
};
private _cfg = [_groupFaction, _groupName] call ALIVE_fnc_configGetGroup;
if ((_cfg isEqualType (configFile >> "CfgVehicles")) && {isClass _cfg}) then {
    {
        private _v = getText (_x >> "vehicle");
        // exitWith inside an if-block only leaves that block, so the test sits at forEach level
        private _t = if (_v != "") then { [_v] call ALIVE_fnc_getArtilleryType } else { "" };
        if (_t != "") exitWith { _result = _t };
    } forEach ("isClass _x" configClasses _cfg);
};

[ALIVE_groupArtilleryTypeCache, _key, _result] call ALIVE_fnc_hashSet;
_result
