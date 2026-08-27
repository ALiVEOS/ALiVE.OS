#include "\x\alive\addons\x_lib\script_component.hpp"
SCRIPT(inferUnitRole);

/* ----------------------------------------------------------------------------
Function: ALiVE_fnc_inferUnitRole

Description:
Classifies a CfgVehicles Man-class unit by combat role using a weapons-
based heuristic. Used by ALiVE_fnc_substituteFactionUnit during Phase 3c.2
spawn-time substitution: when an inferred-faction spawn uses a vanilla
faction's group definition, each vanilla unit gets classified into a
role and a role-equivalent mod unit is substituted.

Results are cached per unit classname because CfgVehicles and CfgWeapons
are static for the mission session. This complements substituteFactionUnit's
per-faction role-pool cache: the pool caches target candidates, while this
cache avoids reclassifying both source and target classnames.

Heuristic priority order (first match wins):
  1. Officer    - displayName / classname patterns
  2. Medic      - linkedItems contains MediKit, OR classname/displayName
                  contains "medic"
  3. AA         - launcher with AA-style magazine (stinger / igla / strela)
  4. AT         - any weapon kindOf "Launcher" (after AA check)
  5. Sniper     - kindOf "SniperRifle" weapon, OR "sniper"/"marksman"
                  patterns in classname
  6. MG         - kindOf "MGun" weapon, OR machinegun/lmg/hmg/gunner
                  patterns in classname
  7. Engineer   - "engineer"/"demolition"/"sapper" patterns
  8. Crewman    - kindOf Pilot_F, OR "pilot"/"crew" patterns
  9. Rifleman   - default fallback

Parameters:
String - unit classname (must be a real CfgVehicles entry that isKindOf "Man")

Returns:
STRING - role token, or "" if class not found / not a Man unit.

Examples:
(begin example)
_role = "O_Soldier_AT_F" call ALiVE_fnc_inferUnitRole;     // -> "AT"
_role = "rhs_msv_emr_medic" call ALiVE_fnc_inferUnitRole;  // -> "Medic"
(end)

See Also:
- ALiVE_fnc_substituteFactionUnit  (the consumer)

Author:
Jman
---------------------------------------------------------------------------- */

private _unit = _this;
if (typeName _unit != "STRING" || {_unit == ""}) exitWith { "" };

if (isNil "ALiVE_inferUnitRoleCache") then {
    ALiVE_inferUnitRoleCache = createHashMap;
};

if (_unit in ALiVE_inferUnitRoleCache) exitWith {
    ALiVE_inferUnitRoleCache get _unit
};

private _result = call {
private _cfg = configFile >> "CfgVehicles" >> _unit;
if !(isClass _cfg) exitWith { "" };
if !(_unit isKindOf "Man") exitWith { "" };

private _cnLower = toLower _unit;
private _dnLower = toLower (getText (_cfg >> "displayName"));

// Helper: check whether either classname or displayName contains substring
private _matches = {
    params ["_needle"];
    ([_needle, _cnLower] call BIS_fnc_inString) ||
    {[_needle, _dnLower] call BIS_fnc_inString}
};

// 1. Officer / Squad Leader
if (
    (["officer"] call _matches) ||
    {["leader"]    call _matches} ||
    {["_sl_"]      call _matches} ||
    {(_cnLower select [count _cnLower - 3]) == "_sl"}
) exitWith { "Officer" };

// 2. Medic
private _linkedItems = getArray (_cfg >> "linkedItems");
if (
    (["medic"] call _matches) ||
    {("MediKit" in _linkedItems) || {"FirstAidKit" in _linkedItems}}
) exitWith { "Medic" };

// Walk weapons once to derive launcher / sniper / mgun flags
private _hasLauncher = false;
private _hasAA       = false;
private _hasSniper   = false;
private _hasMG       = false;

{
    private _w = _x;
    private _wCfg = configFile >> "CfgWeapons" >> _w;
    if (isClass _wCfg) then {
        if (_w isKindOf ["Launcher", configFile >> "CfgWeapons"]) then {
            _hasLauncher = true;
            // AA detection: scan magazines for AA-style classnames
            {
                private _magLower = toLower _x;
                if (
                    ("stinger" in [_magLower]) ||
                    {["stinger", _magLower] call BIS_fnc_inString} ||
                    {["igla",    _magLower] call BIS_fnc_inString} ||
                    {["strela",  _magLower] call BIS_fnc_inString} ||
                    {["_aa_",    _magLower] call BIS_fnc_inString}
                ) then {
                    _hasAA = true;
                };
            } forEach (getArray (_wCfg >> "magazines"));
        };
        if (_w isKindOf ["SniperRifle", configFile >> "CfgWeapons"]) then {
            _hasSniper = true;
        };
        if (_w isKindOf ["MGun", configFile >> "CfgWeapons"]) then {
            _hasMG = true;
        };
    };
} forEach (getArray (_cfg >> "weapons"));

// 3. AA (subset of AT, check first)
if (_hasAA) exitWith { "AA" };

// 4. AT
if (_hasLauncher) exitWith { "AT" };

// 5. Sniper / Marksman
if (
    _hasSniper ||
    {(["sniper"]       call _matches)} ||
    {(["marksman"]     call _matches)} ||
    {(["sharpshooter"] call _matches)}
) exitWith { "Sniper" };

// 6. MG (machine gunner)
if (
    _hasMG ||
    {(["machinegun"] call _matches)} ||
    {(["_mg_"]       call _matches)} ||
    {(["lmg_"]       call _matches)} ||
    {(["hmg_"]       call _matches)} ||
    {(["gunner"]     call _matches) && !(["assistant"] call _matches)}
) exitWith { "MG" };

// 7. Engineer
if (
    (["engineer"]   call _matches) ||
    {(["demolition"] call _matches)} ||
    {(["explosive"]  call _matches)} ||
    {(["sapper"]     call _matches)}
) exitWith { "Engineer" };

// 8. Crewman / Pilot
if (
    (_unit isKindOf "Pilot_F") ||
    {(["pilot"]   call _matches)} ||
    {(["crew"]    call _matches)} ||
    {(["crewman"] call _matches)}
) exitWith { "Crewman" };

// 9. Rifleman (default)
"Rifleman"
};

// Cache empty results too. Invalid and non-Man classnames are just as static
// as valid unit definitions and may otherwise be rejected repeatedly.
ALiVE_inferUnitRoleCache set [_unit, _result];

_result
