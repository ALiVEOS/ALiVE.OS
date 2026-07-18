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

// bare "he"/"HE" matched any classname containing that letter pair (chem,
// shells, launcher...) - underscore-boundary tokens only. Real HE shells the
// tokens miss are still caught by the CfgAmmo ancestry fallback below.
#define HE_SUBSTRINGS      ["Mo_shells", "_he", "he_", "_HE", "HE_"];
#define SMOKE_SUBSTRINGS   ["Mo_smoke", "smoke", "Smoke","smokeshell","SmokeShell","NB","nb"];
#define PHOS_SUBSTRINGS    ["wp", "WP"];
#define GUIDED_SUBSTRINGS  ["Mo_guided"];
#define CLUSTER_SUBSTRINGS ["Mo_Cluster"];
#define LASER_SUBSTRINGS   ["Mo_LG", "laser"];
#define MINE_SUBSTRINGS    ["Mo_Mine"];
#define AT_MINE_SUBSTRINGS ["Mo_AT_mine"];
#define ROCKET_SUBSTRINGS  ["rockets"];
#define ILLUM_SUBSTRINGS   ["illum", "ilum", "flare", "lume"];
// VN 105mm naming: wp classifies by the "wp" pattern above; ab / frag / chem
// carry no pattern and classify by the CfgAmmo fallback (ab -> CLUSTER + HE,
// frag -> HE, chem -> intentionally nothing - it is a gas round).

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

// plain-shell test shared by HE and the CLUSTER carrier arm - shell
// simulation is the mod-proof fallback when the ammo has its own class tree
private _fnc_isShell = {
    (_ammo isKindOf ["ShellBase", _cfgAmmoRoot]) || {(toLower getText (_ammoCfg >> "simulation")) == "shotshell"}
};

switch (_ordnanceType) do {
    case "ILLUM": {
        _ammo isKindOf ["FlareCore", _cfgAmmoRoot]
    };
    case "SMOKE": {
        // WP rounds are smoke-parented in config - keep them out of SMOKE
        (
            (_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])
            // a shell that deploys HARMLESS smoke submunitions is a smoke round.
            // Spearhead's M84 smoke shell is ShellBase-parented with no splash,
            // so parentage alone misses it - its submunition is SmokeShell-
            // parented. Two guards keep everything else out. The carrier must do
            // no damage: a shell that explodes is HE, whose branch owns
            // indirectHit>0, so requiring ==0 here keeps the two disjoint. And
            // the smoke submunition itself must be harmless: a gas/chem cloud or
            // a WP wedge is SmokeShell-derived too, but it poisons or burns, so
            // a submunition that deals damage is not plain concealment smoke.
            || {
                ((call _fnc_isDispenser) || {call _fnc_isShell})
                    && {getNumber (_ammoCfg >> "indirectHit") == 0}
                    && {
                        (call _fnc_submunitions) findIf {
                            (_x isKindOf ["SmokeShell", _cfgAmmoRoot])
                                && {getNumber (_cfgAmmoRoot >> _x >> "indirectHit") == 0}
                                && {getNumber (_cfgAmmoRoot >> _x >> "hit") == 0}
                        } > -1
                    }
            }
        ) && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
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
        // a dispenser round, or a real shell that deploys submunitions on the
        // way down (SOG 105mm airburst simulates as shotShell). Array-form
        // submunitionAmmo is the discriminator on the shell arm: bare-string
        // form is a single follow-through penetrator (tandem HEAT), never a
        // cluster - the isArray gate is what rejects those and is NOT
        // redundant with the count check below (which rejects empty arrays,
        // e.g. the SOG frag round). Smoke / flare / laser carriers mirror the
        // HE guards; smoke or flare submunitions and WP-named rounds are held
        // out so picking CLUSTER can never fire smoke or WP.
        ((call _fnc_isDispenser) || {
            (call _fnc_isShell)
                && {!(_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])}
                && {!(_ammo isKindOf ["FlareCore", _cfgAmmoRoot])}
                && {getNumber (_ammoCfg >> "laserLock") == 0}
                && {isArray (_ammoCfg >> "submunitionAmmo")}
        }) && {
            private _subs = call _fnc_submunitions;
            private _isMine = (_subs findIf { _x isKindOf ["MineBase", _cfgAmmoRoot] || {_x isKindOf ["TimeBombCore", _cfgAmmoRoot]} }) > -1;
            private _isGuided = (_subs findIf { getNumber (_cfgAmmoRoot >> _x >> "laserLock") > 0 || {getNumber (_cfgAmmoRoot >> _x >> "irLock") > 0} }) > -1;
            private _isSmokeOrFlare = (_subs findIf { _x isKindOf ["SmokeShell", _cfgAmmoRoot] || {_x isKindOf ["FlareCore", _cfgAmmoRoot]} }) > -1;
            (count _subs > 0) && {!_isMine} && {!_isGuided} && {!_isSmokeOrFlare}
                && {!((call { PHOS_SUBSTRINGS }) call _fnc_nameMatchesAny)}
        }
    };
    case "ROCKETS": {
        // parentage first, then simulation type - mod rocket ammo (e.g. RHS
        // Grad) often has its own class tree but always simulates as a rocket
        (_ammo isKindOf ["RocketBase", _cfgAmmoRoot])
            || {(toLower getText (_ammoCfg >> "simulation")) in ["shotrocket","shotmissile"]}
    };
    case "HE": {
        // plain shell only - anything smoke / flare / guided / dispenser /
        // rocket parented belongs to its own type. Shell simulation is the
        // mod-proof fallback when the ammo has its own class tree.
        (call _fnc_isShell)
            && {!(_ammo isKindOf ["SmokeShell", _cfgAmmoRoot])}
            && {!(_ammo isKindOf ["FlareCore", _cfgAmmoRoot])}
            && {getNumber (_ammoCfg >> "laserLock") == 0}
            && {!(call _fnc_isDispenser)}
            // an HE round explodes. Spearhead parents its smoke shell on
            // ShellBase and gives it no splash at all, so parentage alone reads
            // it as HE and an HE fire mission puts smoke on the target. Every
            // real HE shell carries indirect damage - vanilla's 155 has 125,
            // Spearhead's own HE has 250, its smoke has none - so ask whether
            // the thing actually goes off rather than what it inherits from.
            // Vanilla never reaches here: its names match at the pattern test
            // above and exit before any of this runs.
            && {getNumber (_ammoCfg >> "indirectHit") > 0}
    };
    default { false };
};
