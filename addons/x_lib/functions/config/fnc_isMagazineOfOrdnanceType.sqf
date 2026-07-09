#include "\x\alive\addons\x_lib\script_component.hpp"

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_isMagazineOfOrdnanceType

Description:
Check if magazine is of ordnance type. Matches by classname pattern first;
when the name matches no pattern, classifies by the round's CfgAmmo ancestry
(mod magazines carry real-world designations like rhs_mag_155mm_m795_28 that
match none of the patterns, which left mod guns with no usable ordnance).

Parameters:
String - Ordnance type
String - Magazine classname

Returns:
Boolean

Examples:
(begin example)
private _result = ["HE", _magazineClassName] call ALIVE_fnc_isMagazineOfOrdnanceType;
(end)

See Also:

Author:
marceldev89
Jman
---------------------------------------------------------------------------- */

#define HE_SUBSTRINGS      ["Mo_shells", "he", "HE"];
#define SMOKE_SUBSTRINGS   ["Mo_smoke", "smoke", "Smoke","smokeshell","SmokeShell","NB","nb"];
#define PHOS_SUBSTRINGS    ["wp", "WP"];
#define GUIDED_SUBSTRINGS  ["Mo_guided"];
#define CLUSTER_SUBSTRINGS ["Mo_Cluster"];
#define LASER_SUBSTRINGS   ["Mo_LG", "laser"];
#define MINE_SUBSTRINGS    ["Mo_Mine"];
#define AT_MINE_SUBSTRINGS ["Mo_AT_mine"];
#define ROCKET_SUBSTRINGS  ["rockets"];
#define ILLUM_SUBSTRINGS   ["illum", "flare", "lume"];
/*
unknown substrings for VN:
- ab    (air burst)
- frag  (frag)
- wp    (white phospherous)
- chem  (mustard gas)
*/

private _ordnanceType      = param [0];
private _magazineClassName = param [1];

private _substrings = switch (_ordnanceType) do {
    case "HE":      { HE_SUBSTRINGS };
    case "SMOKE":   { SMOKE_SUBSTRINGS };
    case "WP":      { PHOS_SUBSTRINGS };
    case "SADARM":  { GUIDED_SUBSTRINGS };
    case "CLUSTER": { CLUSTER_SUBSTRINGS };
    case "LASER":   { LASER_SUBSTRINGS };
    case "MINE":    { MINE_SUBSTRINGS };
    case "AT MINE": { AT_MINE_SUBSTRINGS };
    case "ROCKETS": { ROCKET_SUBSTRINGS };
    case "ILLUM":   { ILLUM_SUBSTRINGS };
    default         { [] };
};

private _found = false;

{
    if (_x in _magazineClassName) exitWith {
        _found = true;
    };
} foreach _substrings;

if (_found) exitWith { true };

// #887 - config-ancestry fallback. Each branch carries a guard so vanilla
// magazines (whose names the patterns already classify) keep their exact
// previous answers - e.g. a WP round is smoke-parented in config but must
// not start answering true for SMOKE.
private _ammo = getText (configfile >> "CfgMagazines" >> _magazineClassName >> "ammo");
if (_ammo == "") exitWith { false };

private _ammoCfg = configfile >> "CfgAmmo" >> _ammo;
private _cfgAmmoRoot = configfile >> "CfgAmmo";

private _fnc_isDispenser = {
    (toLower getText (_ammoCfg >> "simulation")) == "shotsubmunitions"
};
private _fnc_submunitions = {
    private _subs = [];
    private _subEntry = _ammoCfg >> "submunitionAmmo";
    if (isText _subEntry) then { _subs pushBack (getText _subEntry) };
    if (isArray _subEntry) then {
        { if (_x isEqualType "") then { _subs pushBack _x }; } forEach (getArray _subEntry);
    };
    _subs
};
// takes the pattern array as _this (the pattern defines carry a trailing
// semicolon, so they can only expand inside a block body)
private _fnc_nameMatchesAny = {
    (_this findIf { _x in _magazineClassName }) > -1
};

switch (_ordnanceType) do {
    case "ILLUM": {
        _ammo isKindOf ["FlareCore", _cfgAmmoRoot]
    };
    case "SMOKE": {
        // WP rounds are smoke-parented in config - keep them out of SMOKE
        (_ammo isKindOf ["SmokeShell", _cfgAmmoRoot]) && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
    };
    case "LASER": {
        getNumber (_ammoCfg >> "laserLock") > 0
    };
    case "SADARM": {
        (call _fnc_isDispenser) && {
            ((call _fnc_submunitions) findIf {
                getNumber (_cfgAmmoRoot >> _x >> "laserLock") > 0 || {getNumber (_cfgAmmoRoot >> _x >> "irLock") > 0}
            }) > -1
        }
    };
    case "MINE": {
        // AT mine rounds stay AT MINE only (name layer), never plain MINE
        (call _fnc_isDispenser) && {!((call { AT_MINE_SUBSTRINGS }) call _fnc_nameMatchesAny)} && {
            ((call _fnc_submunitions) findIf {
                _x isKindOf ["MineBase", _cfgAmmoRoot] || {_x isKindOf ["TimeBombCore", _cfgAmmoRoot]}
            }) > -1
        }
    };
    case "CLUSTER": {
        (call _fnc_isDispenser) && {
            private _subs = call _fnc_submunitions;
            private _isMine = (_subs findIf { _x isKindOf ["MineBase", _cfgAmmoRoot] || {_x isKindOf ["TimeBombCore", _cfgAmmoRoot]} }) > -1;
            private _isGuided = (_subs findIf { getNumber (_cfgAmmoRoot >> _x >> "laserLock") > 0 || {getNumber (_cfgAmmoRoot >> _x >> "irLock") > 0} }) > -1;
            !_isMine && {!_isGuided}
        }
    };
    case "ROCKETS": {
        _ammo isKindOf ["RocketBase", _cfgAmmoRoot]
    };
    case "HE": {
        // plain shell only - anything smoke / flare / guided / dispenser /
        // rocket parented belongs to its own type
        (_ammo isKindOf ["ShellBase", _cfgAmmoRoot])
            && {!(_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])}
            && {!(_ammo isKindOf ["FlareCore", _cfgAmmoRoot])}
            && {getNumber (_ammoCfg >> "laserLock") == 0}
            && {!(call _fnc_isDispenser)}
    };
    default { false };
};
